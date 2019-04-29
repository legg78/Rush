create or replace package body acc_ui_account_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur              out com_api_type_pkg.t_ref_cur
  , io_row_count        in out com_api_type_pkg.t_long_id
  , i_first_row         in     com_api_type_pkg.t_long_id
  , i_last_row          in     com_api_type_pkg.t_long_id
  , i_tab_name          in     com_api_type_pkg.t_name
  , i_param_tab         in     com_param_map_tpt
  , i_sorting_tab       in     com_param_map_tpt
  , i_is_first_call     in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ref_cur_base: ';
    TAB_NAME_ACCOUNTS          constant com_api_type_pkg.t_name := 'ACCOUNT';
    TAB_NAME_CUSTOMER          constant com_api_type_pkg.t_name := 'CUSTOMER';
    TAB_NAME_CONTRACT          constant com_api_type_pkg.t_name := 'CONTRACT';
    PART_MODE_ISSUING          constant com_api_type_pkg.t_name := 'ISS';
    PART_MODE_ACQUIRING        constant com_api_type_pkg.t_name := 'ACQ';

    PROD_TYPE_CONDITION_ISS    constant com_api_type_pkg.t_name := q'['PRDT0100', 'PRDT0300']';
    PROD_TYPE_CONDITION_ACQ    constant com_api_type_pkg.t_name := q'['PRDT0200']';
    PROD_TYPE_CONDITION_DEF    constant com_api_type_pkg.t_name :=
                                   PROD_TYPE_CONDITION_ISS || ', ' || PROD_TYPE_CONDITION_ACQ;
    SORTING_CLAUSE_PLCHLDR     constant com_api_type_pkg.t_name := '@SORTING_CLAUSE@';
    SUBQUERY_PLCHLDR           constant com_api_type_pkg.t_name := '@SUBQUERY@';
    PROD_TYPE_PLCHLDR          constant com_api_type_pkg.t_name := '@PROD_TYPE@';

    l_param_tab                 com_param_map_tpt               := i_param_tab;

    l_account_id               com_api_type_pkg.t_account_id;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_agent_id                 com_api_type_pkg.t_agent_id;
    l_customer_id              com_api_type_pkg.t_medium_id;
    l_contract_id              com_api_type_pkg.t_medium_id;
    l_account_number           com_api_type_pkg.t_name;
    l_account_type             com_api_type_pkg.t_dict_value;
    l_currency                 com_api_type_pkg.t_dict_value;
    l_status                   com_api_type_pkg.t_name;
    l_product_number           com_api_type_pkg.t_name;
    l_entity_type              com_api_type_pkg.t_dict_value;
    l_object_id                com_api_type_pkg.t_long_id;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_customer_number          com_api_type_pkg.t_name;
    l_contract_number          com_api_type_pkg.t_name;
    l_participant_mode         com_api_type_pkg.t_dict_value;

    l_privil_limitation        com_api_type_pkg.t_full_desc;
    l_order_by                 com_api_type_pkg.t_name;
    l_user_id                  com_api_type_pkg.t_short_id;

    SELECT_STMT                constant com_api_type_pkg.t_text := '
with subquery as (' || SUBQUERY_PLCHLDR || ')
select t.*
     , acc_api_balance_pkg.get_aval_balance_amount_only(t.id) as balance
     , get_text(''ost_institution'', ''name'', t.inst_id, t.lang) as inst_name
     , get_text(''ost_agent'', ''name'', t.agent_id, t.lang) as agent_name
     , get_text(''prd_product'', ''label'', t.product_id, t.lang) as product_name
     , case t.is_pos_currency
            when 1 then case t.is_atm_currency
                             when 1 then get_label_text(''acc.atm_pos_default_account_per_currency'', t.lang)
                             else get_label_text(''acc.pos_default_account_per_currency'', t.lang)
                        end
            else case t.is_atm_currency
                      when 1 then get_label_text(''acc.atm_default_account_per_currency'', t.lang)
                      else null
                 end
       end as default_acc_per_cur
     , to_char(null) as status_reason 
  from (
    select l.*
         , rownum as rn
      from (
        select v.*
          from subquery v
          ' || SORTING_CLAUSE_PLCHLDR || '
      ) l
  ) t
where t.rn between :p_first_row and :p_last_row';

    SELECT_LIST                constant com_api_type_pkg.t_text := '
select distinct
       a.id
     , a.account_type
     , a.account_number
     , a.currency
     , a.inst_id
     , a.agent_id
     , ag.agent_number
     , a.status
     , a.contract_id
     , c.contract_number
     , a.customer_id
     , cu.entity_type as customer_type
     , c.product_id
     , p.product_type
     , p.product_number
     , a.split_hash
     , x.p_lang lang
     , nvl(ao.is_pos_currency, 0) as is_pos_currency
     , nvl(ao.is_atm_currency, 0) as is_atm_currency
';

    l_query                    com_api_type_pkg.t_text := '
  from acc_account a
  join ost_institution i           on i.id = a.inst_id
  join prd_customer cu             on cu.id = a.customer_id
  left join ost_agent ag           on ag.id = a.agent_id
  left join prd_contract c         on c.id = a.contract_id
  left join prd_product p          on p.id = c.product_id
                                     and p.product_type in (' || PROD_TYPE_PLCHLDR || ')
  left join acc_account_object ao  on ao.account_id  = a.id
  cross join (
      select :p_account_id as p_account_id
           , :p_inst_id as p_inst_id
           , :p_agent_id as p_agent_id
           , :p_customer_id as p_customer_id
           , :p_contract_id as p_contract_id
           , :p_account_number as p_account_number
           , :p_account_type as p_account_type
           , :p_currency as p_currency
           , :p_status as p_status
           , :p_customer_number as p_customer_number
           , :p_contract_number as p_contract_number
           , :p_product_number as p_product_number
           , :p_entity_type as p_entity_type
           , :p_object_id as p_object_id
           , :p_lang as p_lang
           , :p_user_id as p_user_id
        from dual
  ) x
 where a.inst_id in (select ui.inst_id from acm_user_inst_mvw ui where ui.user_id = x.p_user_id)
   and a.agent_id in (select ai.agent_id from acm_user_agent_mvw ai where ai.user_id = x.p_user_id)';

    l_full_query               com_api_type_pkg.t_text;

begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_tab_name [' || i_tab_name || '], i_is_first_call [' || i_is_first_call || ']');

    -- Logging collections with input parameters for debugging
    utl_data_pkg.print_table(i_param_tab => i_param_tab);

    if i_tab_name = TAB_NAME_ACCOUNTS then
        l_query := l_query || '
   and exists (select 1 from acc_account_type_vw t
               where t.account_type = a.account_type
                 and t.inst_id = a.inst_id
                 and t.product_type in (' || PROD_TYPE_PLCHLDR || '))';

    elsif i_tab_name not in (TAB_NAME_CUSTOMER, TAB_NAME_CONTRACT) then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_TAB_NAME'
          , i_env_param1 => i_tab_name
        );
    end if;

    -- Use table's column instead of calculated column in "Order by" clause
    if i_sorting_tab is not null then
        if com_ui_object_search_pkg.is_used_sorting(
               i_is_first_call => i_is_first_call
             , i_sorting_count => i_sorting_tab.count
             , i_row_count     => io_row_count
             , i_mask_error    => com_api_type_pkg.FALSE
           ) = com_api_type_pkg.TRUE
        then
            trc_log_pkg.debug(LOG_PREFIX || 'Sorting by:');
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab);

            if i_sorting_tab.count > 0 then
                for i in 1 .. i_sorting_tab.count loop
                    l_order_by := l_order_by
                                  || case
                                         when l_order_by is not null
                                         then ','
                                         else 'order by '
                                     end
                                  || case upper(i_sorting_tab(i).name)
                                      when 'INST_NAME'
                                      then 'INST_ID'
                                      when 'BALANCE'
                                      then '1'        -- Do not sorting by "Balance"
                                      when 'STATUS_REASON'
                                      then '1'        -- Do not sorting by "Status_reason"
                                      else upper(i_sorting_tab(i).name)
                                  end
                                  || ' ' || i_sorting_tab(i).char_value;
                end loop;
            end if;

            trc_log_pkg.debug(LOG_PREFIX || 'l_order_by: ' || l_order_by);
        end if;
    end if;

    l_account_id       := com_ui_object_search_pkg.get_number_value(l_param_tab, 'ACCOUNT_ID');
    l_inst_id          := com_ui_object_search_pkg.get_number_value(l_param_tab, 'INST_ID');
    l_agent_id         := com_ui_object_search_pkg.get_number_value(l_param_tab, 'AGENT_ID');
    l_customer_id      := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CUSTOMER_ID');
    l_contract_id      := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CONTRACT_ID');
    l_account_number   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'ACCOUNT_NUMBER');
    l_account_type     := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'ACCOUNT_TYPE');
    l_currency         := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CURRENCY');
    l_status           := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'STATUS');
    l_product_number   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'PRODUCT_NUMBER');
    l_entity_type      := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'ENTITY_TYPE');
    l_object_id        := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'OBJECT_ID');
    l_lang             := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'LANG');
    l_participant_mode := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'PARTICIPANT_MODE');

    l_customer_number  := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CUSTOMER_NUMBER'));
    l_contract_number  := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CONTRACT_NUMBER'));

    l_user_id          := com_ui_user_env_pkg.get_user_id;

    -- Parameter PARTICIPANT_MODE defines filtering by product type
    l_query := replace(l_query
                     , PROD_TYPE_PLCHLDR
                     , case l_participant_mode
                           when PART_MODE_ISSUING   then PROD_TYPE_CONDITION_ISS
                           when PART_MODE_ACQUIRING then PROD_TYPE_CONDITION_ACQ
                                                    else PROD_TYPE_CONDITION_DEF
                       end);

    -- account_id
    if l_account_id is not null then
        l_query := l_query || ' and a.id = x.p_account_id';
    end if;

    -- inst_id
    if l_inst_id is not null then
        l_query := l_query || ' and a.inst_id = x.p_inst_id';
    end if;

    -- agent_id
    if l_agent_id is not null then
        l_query := l_query || ' and a.agent_id = x.p_agent_id';
    end if;

    -- customer_id
    if l_customer_id is not null then
        l_query := l_query || ' and cu.id = x.p_customer_id';
    end if;

    -- contract_id
    if l_contract_id is not null then
        l_query := l_query || ' and a.contract_id = x.p_contract_id';
    end if;

    -- account_type
    if l_account_type is not null then
        l_query := l_query || ' and a.account_type = x.p_account_type';
    end if;

    -- account_number
    if l_account_number is not null then
        if instr(l_account_number, '%') != 0 then
            l_query := l_query || ' and reverse(a.account_number) like reverse(x.p_account_number)';
        else
            l_query := l_query || ' and reverse(a.account_number) = reverse(x.p_account_number)';
        end if;
    end if;

    -- currency
    if l_currency is not null then
        l_query := l_query || ' and a.currency = x.p_currency';
    end if;

    -- status
    if l_status is not null then
        l_query := l_query || ' and x.p_status like ''%'' || a.status || ''%''';
    end if;

    -- customer_number
    if l_customer_number is not null then
        if instr(l_customer_number, '%') != 0 then
            l_query := l_query || ' and reverse(cu.customer_number) like reverse(x.p_customer_number)';
        else
            l_query := l_query || ' and reverse(cu.customer_number) = reverse(x.p_customer_number)';
        end if;
    end if;

    -- contract_number
    if l_contract_number is not null then
        if instr(l_contract_number, '%') != 0 then
            l_query := l_query || ' and reverse(c.contract_number) like reverse(x.p_contract_number)';
        else
            l_query := l_query || ' and reverse(c.contract_number) = reverse(x.p_customer_number)';
        end if;
    end if;

    -- product_number
    if l_product_number is not null then
        if instr(l_product_number, '%') != 0 then
            l_query := l_query || ' and reverse(p.product_number) like reverse(x.p_product_number)';
        else
            l_query := l_query || ' and reverse(p.product_number) = reverse(x.p_product_number)';
        end if;
    end if;

    -- entity_type
    if l_entity_type is not null then
        l_query := l_query || ' and ao.entity_type = x.p_entity_type';
    end if;

    -- object_id
    if l_object_id is not null then
        l_query := l_query || ' and ao.object_id = x.p_object_id';
    end if;

    -- Extra condition (limitation) is defined by privileges
    l_privil_limitation := com_ui_object_search_pkg.get_char_value(l_param_tab, 'PRIVIL_LIMITATION');
    trc_log_pkg.debug(LOG_PREFIX || 'PRIVIL_LIMITATION [' || l_privil_limitation || ']');
    if l_privil_limitation is not null then
        l_query := l_query || ' and ' || l_privil_limitation;
    end if;

    com_ui_object_search_pkg.start_search(
        i_is_first_call => i_is_first_call
    );

    if i_is_first_call = com_api_const_pkg.TRUE then
        l_full_query := 'select count(distinct a.id) '|| l_query;

        execute immediate l_full_query
        into io_row_count
        using l_account_id
            , l_inst_id
            , l_agent_id
            , l_customer_id
            , l_contract_id
            , l_account_number
            , l_account_type
            , l_currency
            , l_status
            , l_customer_number
            , l_contract_number
            , l_product_number
            , l_entity_type
            , l_object_id
            , l_lang
            , l_user_id;
    else
        l_full_query := replace(SELECT_STMT, SUBQUERY_PLCHLDR, SELECT_LIST || l_query);
        l_full_query := replace(l_full_query
                              , SORTING_CLAUSE_PLCHLDR
                              , l_order_by
                        );
        open o_ref_cur for l_full_query
        using l_account_id
            , l_inst_id
            , l_agent_id
            , l_customer_id
            , l_contract_id
            , l_account_number
            , l_account_type
            , l_currency
            , l_status
            , l_customer_number
            , l_contract_number
            , l_product_number
            , l_entity_type
            , l_object_id
            , l_lang
            , l_user_id
            , i_first_row
            , i_last_row;
    end if;

    com_ui_object_search_pkg.finish_search(
        i_is_first_call => i_is_first_call
      , i_row_count     => io_row_count
      , i_sql_statement => l_full_query
    );

exception
    when others then
        com_ui_object_search_pkg.finish_search(
            i_is_first_call => i_is_first_call
          , i_row_count     => io_row_count
          , i_sql_statement => l_full_query
          , i_is_failed     => com_api_type_pkg.TRUE
          , i_sqlerrm_text  => SQLERRM
        );
        raise;
end get_ref_cur_base;

procedure get_ref_cur(
    o_ref_cur              out com_api_type_pkg.t_ref_cur
  , i_row_count         in     com_api_type_pkg.t_medium_id  default null
  , i_first_row         in     com_api_type_pkg.t_long_id
  , i_last_row          in     com_api_type_pkg.t_long_id
  , i_tab_name          in     com_api_type_pkg.t_name
  , i_param_tab         in     com_param_map_tpt
  , i_sorting_tab       in     com_param_map_tpt             default null
) is
    l_row_count         com_api_type_pkg.t_medium_id  := i_row_count;
begin
    get_ref_cur_base(
        o_ref_cur       => o_ref_cur
      , io_row_count    => l_row_count
      , i_first_row     => i_first_row
      , i_last_row      => i_last_row
      , i_tab_name      => i_tab_name
      , i_param_tab     => i_param_tab
      , i_sorting_tab   => i_sorting_tab
      , i_is_first_call => com_api_const_pkg.FALSE
    );
end get_ref_cur;

procedure get_row_count(
    o_row_count            out com_api_type_pkg.t_long_id
  , i_tab_name          in     com_api_type_pkg.t_name
  , i_param_tab         in     com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt := com_param_map_tpt();
begin
    get_ref_cur_base(
        o_ref_cur       => l_ref_cur
      , io_row_count    => o_row_count
      , i_first_row     => null
      , i_last_row      => null
      , i_tab_name      => i_tab_name
      , i_param_tab     => i_param_tab
      , i_sorting_tab   => l_sorting_tab
      , i_is_first_call => com_api_const_pkg.TRUE
    );
end get_row_count;

end acc_ui_account_search_pkg;
/
