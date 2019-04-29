create or replace package body cln_ui_credit_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , io_row_count        in out  com_api_type_pkg.t_long_id
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name   := lower($$PLSQL_UNIT) || '.get_ref_cur_base';
    l_param_tab                 com_param_map_tpt         := i_param_tab;

    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_account_number            com_api_type_pkg.t_name;
    l_customer_number           com_api_type_pkg.t_name;
    l_first_name                com_api_type_pkg.t_name;
    l_last_name                 com_api_type_pkg.t_name;
    l_case_number               com_api_type_pkg.t_name;
    l_aging_period_min          com_api_type_pkg.t_tiny_id;
    l_aging_period_max          com_api_type_pkg.t_tiny_id;
    l_overdue_condition         com_api_type_pkg.t_dict_value;
    l_quick_search              com_api_type_pkg.t_name;
    
    l_lang                      com_api_type_pkg.t_dict_value;
    l_user_id                   com_api_type_pkg.t_short_id;
    l_order_by                  com_api_type_pkg.t_name;
    l_add_where                 com_api_type_pkg.t_text;

    COLUMN_LIST        constant com_api_type_pkg.t_text :=
        'select t.account_id'
        ||   ', t.account_number'
        ||   ', t.account_currency'
        ||   ', t.customer_number'
        ||   ', t.customer_id'
        ||   ', p.first_name'
        ||   ', p.second_name'
        ||   ', p.surname as last_name'
        ||   ', t.inst_id'
        ||   ', get_text(i_table_name => ''OST_INSTITUTION'', i_column_name => ''NAME'', i_object_id => t.inst_id, i_lang => l.lang) as inst_name'
        ||   ', t.credit_limit'
        ||   ', t.tad'
        ||   ', t.overdue'
        ||   ', t.aging_period'
        ||   ', t.case_id'
        ||   ', t.case_number'
        ||   ', t.case_status'
        ||   ', get_article_text(i_article => t.case_status, i_lang => l.lang) as case_status_name'
        ||   ', t.case_creation_date'
        ||   ', l.lang';

    l_query                     com_api_type_pkg.t_text :=
        ' from ('
        ||    'select a.id as account_id'
        ||         ', a.account_number'
        ||         ', a.currency as account_currency'
        ||         ', s.id as customer_id'
        ||         ', s.customer_number'
        ||         ', s.object_id as person_id'
        ||         ', a.inst_id'
        ||         ', i.exceed_limit as credit_limit'
        ||         ', i.total_amount_due as tad'
        ||         ', (i.overdue_balance + i.overdue_intr_balance) as overdue'
        ||         ', i.aging_period'
        ||         ', c.case_number'
        ||         ', c.status as case_status'
        ||         ', c.creation_date as case_creation_date'
        ||         ', c.id as case_id'
        ||         ', x.*'
        ||     ' from acc_account a'
        ||         ', prd_customer s'
        ||         ', crd_invoice i'
        ||         ', cln_case c'
        ||         ', ('
        ||      'select :p_inst_id as p_inst_id'
        ||           ', :p_customer_number as p_customer_number'
        ||           ', :p_first_name as p_first_name'
        ||           ', :p_last_name as p_last_name'
        ||           ', :p_case_number as p_case_number'
        ||           ', :p_aging_period_min as p_aging_period_min'
        ||           ', :p_aging_period_max as p_aging_period_max'
        ||           ', :p_overdue_condition as p_overdue_condition'
        ||           ', :p_lang as p_lang'
        ||           ', :p_user_id as p_user_id'
        ||       ' from dual'
        ||           ') x'
        ||    ' where s.inst_id in (select ui.inst_id from acm_user_inst_mvw ui where ui.user_id = x.p_user_id)'
        ||      ' and a.id = i.account_id'
        ||      ' and a.customer_id = s.id'
        ||      ' and s.entity_type = ''ENTTPERS'''
        ||      ' and a.split_hash = s.split_hash'
        ||      ' and i.id = crd_invoice_pkg.get_last_invoice_id(a.id, a.split_hash, 1)'
        ||      ' and c.customer_id(+) = a.customer_id'
        ||      ' and c.split_hash(+) = a.split_hash'
        ||      ' and ('
        ||      ' (i.overdue_balance + i.overdue_intr_balance) > 0'
        ||      ' or i.aging_period > 0'
        ||      ' or (c.id is not null'
        ||      ' and c.status <> ''CLST0003'')'
        ||      ' )'
        ||    ') t'
        ||    ', (select id'
        ||            ', min(lang) keep(dense_rank first order by decode(lang, :p_lang, 1, ''LANGENG'', 2, 3)) lang'
        ||        ' from com_person'
        ||       ' group by id'
        ||      ') l'
        ||    ', com_person p'
        || ' where l.id = t.person_id'
        ||   ' and p.id = l.id'
        ||   ' and p.lang = l.lang';

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' START with i_tab_name [#1], i_is_first_call [#2], io_row_count [#3]'
      , i_env_param1 => i_tab_name
      , i_env_param2 => i_is_first_call
      , i_env_param3 => io_row_count
    );
    -- Logging collections with input parameters for debugging
    utl_data_pkg.print_table(i_param_tab => i_param_tab);

    l_order_by := 'order by inst_id asc, account_currency asc, overdue desc, tad desc';

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
                                      when 'CASE_STATUS_DESCR'
                                      then 'CASE_STATUS'
                                      else upper(i_sorting_tab(i).name)
                                  end
                                  || ' ' || i_sorting_tab(i).char_value;
                end loop;
            end if;

            trc_log_pkg.debug(LOG_PREFIX || 'l_order_by: ' || l_order_by);
        end if;
    end if;

    l_lang    := com_ui_object_search_pkg.get_char_value(l_param_tab, 'LANG');
    l_user_id := com_ui_user_env_pkg.get_user_id;

    if i_tab_name = 'CLN_OVERDUE' then
        l_add_where         := ' ';
      
        l_quick_search      := com_ui_object_search_pkg.get_char_value(l_param_tab, 'QUICK_SEARCH');
        if l_quick_search is not null then
            l_quick_search := '''%' || upper(l_quick_search) || '%''';
            l_add_where := l_add_where
                || ' and (t.inst_id like ' || l_quick_search
                || ' or account_number like ' || l_quick_search
                || ' or upper(t.customer_number) like ' || l_quick_search
                || ' or upper(p.first_name) like ' || l_quick_search
                || ' or upper(p.surname) like ' || l_quick_search
                || ' or upper(t.case_number) like ' || l_quick_search
                || ')';
         

        else 
            l_inst_id           := com_ui_object_search_pkg.get_number_value(l_param_tab, 'INST_ID');
            l_customer_number   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CUSTOMER_NUMBER');
            l_first_name        := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'FIRST_NAME');
            l_last_name         := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'LAST_NAME');
            l_case_number       := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CASE_NUMBER');
            l_aging_period_min  := com_ui_object_search_pkg.get_number_value(l_param_tab, 'AGING_PERIOD_MIN');
            l_aging_period_max  := com_ui_object_search_pkg.get_number_value(l_param_tab, 'AGING_PERIOD_MAX');
            l_overdue_condition := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'OVERDUE_CONDITION');

                      
            if l_inst_id is not null then
                l_add_where := l_add_where || ' and t.inst_id = t.p_inst_id';
            end if;

            if l_customer_number is not null then
                l_add_where := l_add_where || ' and upper(t.customer_number) like upper(t.p_customer_number)';
            end if;

            if l_first_name is not null then
                l_add_where := l_add_where || ' and upper(p.first_name) like upper(t.p_first_name)';
            end if;

            if l_last_name is not null then
                l_add_where := l_add_where || ' and upper(p.surname) like upper(t.p_last_name)';
            end if;

            if l_case_number is not null then
                l_add_where := l_add_where || ' and upper(t.case_number) like upper(t.p_case_number)';
            end if;

            if l_aging_period_min is not null then
                l_add_where := l_add_where || ' and t.aging_period >= t.p_aging_period_min';
            end if;

            if l_aging_period_max is not null then
                l_add_where := l_add_where || ' and t.aging_period <= t.p_aging_period_max';
            end if;

            if l_overdue_condition is not null then
                if l_overdue_condition = cln_api_const_pkg.COLL_OVERDUE_COND_OVRD_ONLY then
                    l_add_where := l_add_where || ' and t.overdue > 0';
                elsif l_overdue_condition = cln_api_const_pkg.COLL_OVERDUE_COND_WO_OVRD_ONLY then
                    l_add_where := l_add_where || ' and (t.overdue is null or t.overdue = 0)';
                end if;
            end if;
        end if;
        
        l_query := l_query || replace(l_add_where, '*', '%');
    end if;

    com_ui_object_search_pkg.start_search(
        i_is_first_call => i_is_first_call
    );

    if  i_is_first_call = com_api_const_pkg.TRUE then
        l_query := 'select count(*)' || l_query;

        execute immediate l_query
        into io_row_count
        using
            l_inst_id
          , l_customer_number
          , l_first_name
          , l_last_name
          , l_case_number
          , l_aging_period_min
          , l_aging_period_max
          , l_overdue_condition
          , l_lang
          , l_user_id
          , l_lang;

    else
        l_query :=   'select q.*'
                   ||     ', get_text(''PRD_CUSTOMER'', ''LABEL'', q.customer_id, q.lang) as customer_name'
                   || ' from (select z.*'
                   ||             ', rownum as rn'
                   ||         ' from ('
                   || COLUMN_LIST || l_query || ') z ' || l_order_by
                   || ') q where q.rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_query
        using
            l_inst_id
          , l_customer_number
          , l_first_name
          , l_last_name
          , l_case_number
          , l_aging_period_min
          , l_aging_period_max
          , l_overdue_condition
          , l_lang
          , l_user_id
          , l_lang
          , i_first_row
          , i_last_row;

    end if;

    com_ui_object_search_pkg.finish_search(
        i_is_first_call => i_is_first_call
      , i_row_count     => io_row_count
      , i_sql_statement => l_query
    );

exception
    when others then
        com_ui_object_search_pkg.finish_search(
            i_is_first_call => i_is_first_call
          , i_row_count     => io_row_count
          , i_sql_statement => l_query
          , i_is_failed     => com_api_type_pkg.TRUE
          , i_sqlerrm_text  => SQLERRM
        );
        raise;
end get_ref_cur_base;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_row_count         in      com_api_type_pkg.t_long_id    default null
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt             default null
) is
    l_row_count         com_api_type_pkg.t_long_id := i_row_count;
begin
    get_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , io_row_count        => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end get_ref_cur;

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    get_ref_cur_base(
        o_ref_cur           => l_ref_cur
      , io_row_count        => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end get_row_count;

end cln_ui_credit_search_pkg;
/
