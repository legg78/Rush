create or replace package body cst_bsm_api_svgate_pkg as

function get_cycle_id(
    i_product_id        in  com_api_type_pkg.t_short_id
  , i_service_id        in  com_api_type_pkg.t_short_id
  , i_customer_id       in  com_api_type_pkg.t_medium_id
  , i_split_hash        in  com_api_type_pkg.t_tiny_id
  , i_eff_date          in  date
) return com_param_map_tpt
is
    l_cycle_id_tab  com_param_map_tpt;
begin
    trc_log_pkg.debug(
        i_text          => lower($$PLSQL_UNIT) || '.get_cycle_id: i_product_id=[#1], i_service_id=[#2], i_customer_id=[#3], i_split_hash=[#4], i_eff_date=[#5]'
      , i_env_param1    => i_product_id 
      , i_env_param2    => i_service_id 
      , i_env_param3    => i_customer_id 
      , i_env_param4    => i_split_hash 
      , i_env_param5    => i_eff_date 
    );

    select com_param_map_tpr(
               attr_name
             , null
             , convert_to_number(attr_value)
             , null
             , null
           )
      bulk collect into l_cycle_id_tab
      from (select attr_name
                 , attr_value
                 , row_number() over(partition by attr_name order by priority asc) as rn
              from (select v.attr_value
                         , a.attr_name
                         , 1 as priority
                      from prd_attribute_value v
                         , prd_attribute a
                     where v.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                       and v.object_id   = i_customer_id
                       and v.split_hash  = i_split_hash
                       and v.service_id  = i_service_id
                       and a.id          = v.attr_id
                       and a.attr_name   in ('CUSTOMER_CYCLE_1', 'CUSTOMER_CYCLE_2', 'CUSTOMER_CYCLE_3', 'CUSTOMER_CYCLE_4')
                       and i_eff_date between v.start_date and nvl(v.end_date, i_eff_date)
                    union all
                    select v.attr_value
                         , a.attr_name
                         , (3 - p.top_flag) as priority
                      from (select connect_by_root id product_id
                                 , level level_priority
                                 , id parent_id
                                 , product_type
                                 , case when parent_id is null then 1 else 0 end top_flag
                              from prd_product
                             connect by prior parent_id = id
                               start with id = i_product_id
                           ) p
                         , prd_attribute_value v
                         , prd_attribute a
                         , prd_service s
                         , prd_product_service ps
                     where ps.product_id     = p.product_id
                       and ps.service_id     = s.id
                       and v.service_id      = s.id
                       and a.service_type_id = s.service_type_id
                       and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                       and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                       and v.attr_id         = a.id
                       and s.id              = i_service_id
                       and a.attr_name       in ('CUSTOMER_CYCLE_1', 'CUSTOMER_CYCLE_2', 'CUSTOMER_CYCLE_3', 'CUSTOMER_CYCLE_4')
                       and i_eff_date between v.start_date and nvl(v.end_date, i_eff_date)
                   )
           )
     where rn = 1;

    return l_cycle_id_tab;

end get_cycle_id;

procedure get_auto_debit_cycles(
    i_service_id            in     com_api_type_pkg.t_short_id
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
) is
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_prd_service_id        com_api_type_pkg.t_short_id;
    l_product_id            com_api_type_pkg.t_short_id;
    l_cycle_id_tab          com_param_map_tpt;
begin

    trc_log_pkg.debug(
        i_text          => lower($$PLSQL_UNIT) || '.get_auto_debit_cycles: i_service_id = [#1]'
      , i_env_param1    => i_service_id 
    );

    begin
        select c.id
             , c.split_hash
             , c.inst_id
          into l_customer_id
             , l_split_hash
             , l_inst_id
          from prd_customer c
             , pmo_purpose p
         where p.service_id = i_service_id
           and c.ext_entity_type = PMO_API_CONST_PKG.ENTITY_TYPE_SERVICE_PROVIDER --'ENTTSRVP'
           and c.ext_object_id = p.provider_id
           ;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'SERVICE_NOT_FOUND'
              , i_env_param1    => i_service_id
            );
    end;

    l_prd_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id   => l_customer_id
          , i_attr_name   => 'CUSTOMER_CYCLE_1'
          , i_split_hash  => l_split_hash
          , i_eff_date    => get_sysdate
          , i_inst_id     => l_inst_id
          , i_mask_error  => com_api_type_pkg.FALSE
        );

    l_product_id := 
        prd_api_product_pkg.get_product_id(
            i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id   => l_customer_id
          , i_eff_date    => get_sysdate
          , i_inst_id     => l_inst_id
        );

    if l_prd_service_id is not null and l_product_id is not null then   
        l_cycle_id_tab := 
            get_cycle_id(
                i_product_id    => l_product_id
              , i_service_id    => l_prd_service_id
              , i_customer_id   => l_customer_id
              , i_split_hash    => l_split_hash
              , i_eff_date      => get_sysdate
            );

        open o_ref_cur for
            select c.cycle_id
                 , c.shift_type
                 , c.shift_sign
                 , c.length_type
                 , c.shift_length 
              from fcl_cycle_shift c
                 , table(cast(l_cycle_id_tab as com_param_map_tpt)) ct
             where c.cycle_id = ct.number_value
             order by 
                   ct.name
                 , c.cycle_id
                 , c.length_type desc
                 ;

    elsif l_product_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'PRODUCT_NOT_FOUND_BY_CUSTOMER'
          , i_env_param1    => l_customer_id
          , i_env_param2    => l_inst_id
        );
    end if;

exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end get_auto_debit_cycles;

procedure get_cust_payment_cycles(
    i_service_id            in     com_api_type_pkg.t_short_id
  , i_cycle_order_id        in     com_api_type_pkg.t_tiny_id
  , i_row_start             in     com_api_type_pkg.t_tiny_id
  , i_row_count             in     com_api_type_pkg.t_tiny_id
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
) is
    l_ref_cur               com_api_type_pkg.t_ref_cur;
    l_count                 com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text          => lower($$PLSQL_UNIT) ||'.get_cust_payment_cycles: i_service_id=[#1], i_cycle_order_id=[#2]'
      , i_env_param1    => i_service_id 
      , i_env_param2    => i_cycle_order_id
    );
    
    open o_ref_cur for
        select *
          from (select rownum as rn
                     , t.*
                  from (select listagg (p.param_name || '=' || d.param_value, chr (10)) within group (order by o.id, p.id) as params
                             , o.purpose_id
                             , o.customer_id
                             , o.inst_id
                             , s.event_type
                             , s.entity_type
                             , s.object_id
                             , s.attempt_limit
                             , case s.entity_type
                                   when com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                   then prd_api_customer_pkg.get_customer_number(i_customer_id => s.object_id)
                                   when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                   then acc_api_account_pkg.get_account_number(i_account_id => s.object_id)
                                   else null
                               end as object_number
                          from pmo_schedule s
                             , pmo_order o
                             , pmo_order_data d
                             , pmo_parameter p
                             , pmo_purpose u
                         where o.purpose_id = u.id
                           and s.order_id = o.id
                           and d.order_id = o.id
                           and d.param_id = p.id
                           and o.templ_status = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD  --'POTSVALD'
                           and u.service_id = i_service_id
                           and s.attempt_limit = nvl(i_cycle_order_id, s.attempt_limit)
                         group by 
                               o.purpose_id
                             , o.customer_id
                             , o.inst_id
                             , s.event_type
                             , s.entity_type
                             , s.object_id
                             , s.attempt_limit
                        ) t
                ) m
         where m.rn between i_row_start and i_row_start + i_row_count
         ;

exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end get_cust_payment_cycles;

end cst_bsm_api_svgate_pkg;
/
