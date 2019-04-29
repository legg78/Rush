create or replace package body acq_api_revenue_sharing_pkg is

procedure get_fee_id (
    i_customer_id               in  com_api_type_pkg.t_medium_id    default null
    , i_provider_id             in  com_api_type_pkg.t_short_id     default null
    , i_terminal_id             in  com_api_type_pkg.t_short_id     default null
    , i_account_id              in  com_api_type_pkg.t_medium_id    default null
    , i_service_id              in  com_api_type_pkg.t_short_id     default null
    , i_purpose_id              in  com_api_type_pkg.t_short_id     default null
    , i_fee_type                in  com_api_type_pkg.t_dict_value   
    , i_inst_id                 in  com_api_type_pkg.t_inst_id      
    , i_params                  in  com_api_type_pkg.t_param_tab    
    , i_raise_error             in  com_api_type_pkg.t_boolean      := com_api_const_pkg.TRUE
    , o_fee_id                  out com_api_type_pkg.t_medium_id
    , i_eff_date                in  date                            default null
)is
    l_mods                      com_api_type_pkg.t_number_tab;
    l_fees                      com_api_type_pkg.t_varchar2_tab;
    l_result                    com_api_type_pkg.t_param_value;
    l_customers                 com_api_type_pkg.t_medium_tab;
    l_service_id                com_api_type_pkg.t_short_id;
    l_product_id                com_api_type_pkg.t_short_id;
    l_eff_date                  date;
    l_cnt                       com_api_type_pkg.t_count := 0;
    l_split_hash                com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text          => 'acq_api_revenue_sharing_pkg.get_fee_id: i_customer_id [#1], i_provider_id [#2], i_terminal_id [#3], i_purpose_id [#4], i_fee_type [#5]'
      , i_env_param1    => i_customer_id 
      , i_env_param2    => i_provider_id 
      , i_env_param3    => i_terminal_id 
      , i_env_param4    => i_purpose_id  
      , i_env_param5    => i_fee_type   
    );

    select t.fee_id
           , t.mod_id 
           , t.customer_id
       bulk collect into
           l_fees 
           , l_mods
           , l_customers
        from(  
            select s.* 
                 , m.priority
                 , case when nvl(s.customer_id, 0) = nvl(i_customer_id, 0) then 1 else 0 end + 
                 case when nvl(s.provider_id, 0) = nvl(i_provider_id, 0) then 1 else 0 end + 
                 case when nvl(s.terminal_id, 0) = nvl(i_terminal_id, 0) then 1 else 0 end + 
                 case when nvl(s.account_id, 0) = nvl(i_account_id, 0) then 1 else 0 end +
                 case when nvl(s.service_id, 0) = nvl(i_service_id, 0) then 1 else 0 end +
                 case when nvl(s.purpose_id, 0) = nvl(i_purpose_id, 0) then 1 else 0 end summ 
              from acq_revenue_sharing s
                 , rul_mod m
             where nvl(s.customer_id, 0) in (nvl(i_customer_id, 0), 0)
               and nvl(s.provider_id, 0) in (nvl(i_provider_id, 0), 0)
               and nvl(s.terminal_id, 0) in (nvl(i_terminal_id, 0), 0)
               and nvl(s.account_id, 0) in (nvl(i_account_id, 0), 0)
               and nvl(s.service_id, 0) in (nvl(i_service_id, 0), 0)
               and nvl(s.purpose_id, 0) in (nvl(i_purpose_id, 0), 0)
               and s.fee_type = i_fee_type
               and s.inst_id = i_inst_id
               and s.mod_id = m.id(+)
        )t
        order by t.summ desc nulls last
               , t.priority nulls last;
               
    -- attribute value dates check
    if l_fees.count > 0 then
        for i in l_fees.first .. l_fees.last loop
            if l_customers(i) is not null then
                l_eff_date :=
                    nvl(
                        i_eff_date
                      , com_api_sttl_day_pkg.get_calc_date(
                            i_inst_id => i_inst_id
                        )
                    );
                l_split_hash :=
                    com_api_hash_pkg.get_split_hash(
                        i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id   => l_customers(i)
                    );
                
                l_service_id :=
                    prd_api_service_pkg.get_active_service_id(
                        i_entity_type      => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id        => l_customers(i)
                      , i_attr_name        => null
                      , i_service_type_id  => acq_api_const_pkg.REVENUE_SHAR_SERVICE_TYPE_ID
                      , i_mask_error       => com_api_const_pkg.TRUE
                      , i_split_hash       => l_split_hash
                      , i_eff_date         => l_eff_date
                    );
                
                if l_service_id is not null then
                    l_product_id :=
                        prd_api_product_pkg.get_product_id(
                            i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          , i_object_id    => l_customers(i)
                          , i_eff_date     => l_eff_date
                        );
                    trc_log_pkg.debug('Checking dates for fee_id = ' || l_fees(i));
                    
                    select count(*) 
                      into l_cnt
                      from (
                        select 1
                          from prd_attribute_value v
                             , prd_attribute a
                         where v.entity_type  = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                           and v.object_id    = l_customers(i)
                           and v.service_id   = l_service_id
                           and v.split_hash   = l_split_hash
                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_FEE
                           and a.object_type  = i_fee_type
                           and a.id           = v.attr_id
                           and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                           and v.attr_value   = to_char(l_fees(i), com_api_const_pkg.NUMBER_FORMAT)
                       union all
                        select 1
                          from (
                                select connect_by_root id product_id
                                     , level level_priority
                                     , id parent_id
                                     , product_type
                                     , case when parent_id is null then 1 else 0 end top_flag
                                  from prd_product
                                 connect by prior parent_id = id
                                   start with id = l_product_id
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
                           and s.id              = l_service_id
                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
                           and a.object_type     = i_fee_type
                           and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                           and v.attr_value      = to_char(l_fees(i), com_api_const_pkg.NUMBER_FORMAT)
                           );

                    -- fee not found
                    if l_cnt = 0 then
                        l_mods.delete(i);
                        l_fees.delete(i);
                        l_customers.delete(i);
                    end if;
                else
                    trc_log_pkg.debug('Service not found for fee_id = ' || l_fees(i));
                    -- service not found
                    l_mods.delete(i);
                    l_fees.delete(i);
                    l_customers.delete(i);
                end if;
            end if;
        end loop;
    end if;

    if l_fees.count > 0 then          
        l_result := rul_api_mod_pkg.select_value (
            i_mods    => l_mods
          , i_values  => l_fees
          , i_params  => i_params
        );
            
        o_fee_id := l_result;
    else
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error       => 'FEE_NOT_DEFINED'
              , i_env_param1  => i_fee_type
              , i_env_param2  => i_customer_id
              , i_env_param3  => i_provider_id
              , i_env_param4  => i_terminal_id
              , i_env_param5  => i_account_id
              , i_env_param6  => i_inst_id
            );
        else
            o_fee_id := null;
        end if;
    end if;
end;        
           
end;
/
