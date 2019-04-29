create or replace package body prd_ui_contract_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , io_row_count        in out  com_api_type_pkg.t_medium_id
  , i_first_row         in      com_api_type_pkg.t_medium_id
  , i_last_row          in      com_api_type_pkg.t_medium_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.get_ref_cur_base: ';

    l_param_tab                 com_param_map_tpt             := i_param_tab;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_product_id                com_api_type_pkg.t_short_id;
    l_start_date_from           date;
    l_start_date_to             date;
    l_end_date_from             date;
    l_end_date_to               date;
    l_contract_type             com_api_type_pkg.t_dict_value;
    l_contract_number           com_api_type_pkg.t_name;
    l_customer_number           com_api_type_pkg.t_name;
    l_card_mask                 com_api_type_pkg.t_card_number;
    l_card_number               com_api_type_pkg.t_card_number;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_contract_id               com_api_type_pkg.t_medium_id;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_customer_type             com_api_type_pkg.t_dict_value;
    l_product_type              com_api_type_pkg.t_dict_value;
    l_account_number            com_api_type_pkg.t_name;
    l_account_id                com_api_type_pkg.t_medium_id;
    l_merchant_number           com_api_type_pkg.t_name;
    l_merchant_id               com_api_type_pkg.t_short_id;
    l_terminal_number           com_api_type_pkg.t_name;
    l_terminal_id               com_api_type_pkg.t_short_id;

    l_privil_limitation         com_api_type_pkg.t_full_desc;
    l_order_by                  com_api_type_pkg.t_name;
    l_user_id                   com_api_type_pkg.t_short_id;

    COLUMN_LIST        constant com_api_type_pkg.t_text :=
        'select co.id'
      ||     ', co.seqnum'
      ||     ', co.product_id'
      ||     ', co.start_date'
      ||     ', co.end_date'
      ||     ', co.contract_number'
      ||     ', co.inst_id'
      ||     ', co.customer_id'
      ||     ', co.split_hash'
      ||     ', co.agent_id'
      ||     ', co.contract_type'
      ||     ', cu.customer_number'
      ||     ', cu.entity_type as customer_type'
      ||     ', cu.object_id as customer_object_id'
      ||     ', cu.contract_id as customer_contract_id'
      ||     ', p.product_type'
      ||     ', p.product_number'
      ||     ', x.p_lang as lang';

    l_from                      com_api_type_pkg.t_text :=
        ' from prd_contract co'
      ||   ',  prd_customer cu'
      ||   ',  prd_product p'
      ||   ', (select :p_inst_id p_inst_id'
      ||           ', :p_product_id p_product_id'
      ||           ', :p_start_date_from p_start_date_from'
      ||           ', :p_start_date_to p_start_date_to'
      ||           ', :p_end_date_from p_end_date_from'
      ||           ', :p_end_date_to p_end_date_to'
      ||           ', :p_contract_type p_contract_type'
      ||           ', :p_contract_number p_contract_number'
      ||           ', :p_customer_number p_customer_number'
      ||           ', :p_card_number p_card_number'
      ||           ', :p_card_mask p_card_mask'
      ||           ', :p_lang p_lang'
      ||           ', :p_contract_id p_contract_id'
      ||           ', :p_customer_id p_customer_id'
      ||           ', :p_customer_type p_customer_type'
      ||           ', :p_user_id p_user_id'
      ||           ', :p_product_type p_product_type'
      ||        ' from dual'
      ||     ') x';

    l_where                     com_api_type_pkg.t_text :=
        ' where co.inst_id in (select ui.inst_id from acm_user_inst_mvw ui where ui.user_id = x.p_user_id)'
      ||  ' and cu.id = co.customer_id'
      ||  ' and p.id = co.product_id';

    l_query                     com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_tab_name [#1], i_is_first_call [#2], io_row_count [#3]'
      , i_env_param1 => i_tab_name
      , i_env_param2 => i_is_first_call
      , i_env_param3 => io_row_count
    );
    -- Logging collections with input parameters for debugging
    utl_data_pkg.print_table(i_param_tab => i_param_tab);

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
                                      when 'CONTRACT_TYPE_NAME'
                                      then 'CONTRACT_TYPE'
                                      when 'PRODUCT_NAME'
                                      then 'PRODUCT_ID'
                                      else upper(i_sorting_tab(i).name)
                                  end
                                  || ' ' || i_sorting_tab(i).char_value;
                end loop;
            end if;

            trc_log_pkg.debug(LOG_PREFIX || 'l_order_by: ' || l_order_by);
        end if;
    end if;

    l_inst_id           := com_ui_object_search_pkg.get_number_value(l_param_tab, 'INST_ID');
    l_product_id        := com_ui_object_search_pkg.get_number_value(l_param_tab, 'PRODUCT_ID');
    l_start_date_from   := com_ui_object_search_pkg.get_date_value  (l_param_tab, 'START_DATE_FROM');
    l_start_date_to     := com_ui_object_search_pkg.get_date_value  (l_param_tab, 'START_DATE_TO');
    l_end_date_from     := com_ui_object_search_pkg.get_date_value  (l_param_tab, 'END_DATE_FROM');
    l_end_date_to       := com_ui_object_search_pkg.get_date_value  (l_param_tab, 'END_DATE_TO');
    l_contract_type     := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CONTRACT_TYPE');
    l_contract_number   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CONTRACT_NUMBER');
    l_customer_number   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CUSTOMER_NUMBER');
    l_card_number       := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_NUMBER');
    l_card_id           := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_ID');
    l_lang              := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'LANG');
    l_contract_id       := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CONTRACT_ID');
    l_customer_id       := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CUSTOMER_ID');
    l_customer_type     := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CUSTOMER_TYPE');
    l_product_type      := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'PRODUCT_TYPE');
    l_account_number    := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'ACCOUNT_NUMBER');
    l_account_id        := com_ui_object_search_pkg.get_number_value(l_param_tab, 'ACCOUNT_ID');
    l_merchant_number   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'MERCHANT_NUMBER');
    l_merchant_id       := com_ui_object_search_pkg.get_number_value(l_param_tab, 'MERCHANT_ID');
    l_terminal_number   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'TERMINAL_NUMBER');
    l_terminal_id       := com_ui_object_search_pkg.get_number_value(l_param_tab, 'TERMINAL_ID');

    l_user_id           := com_ui_user_env_pkg.get_user_id;

    -- contract_id
    if l_contract_id is not null then
        l_where := l_where             || ' and co.id = x.p_contract_id';

   elsif i_tab_name = 'CONTRACT' then

        -- inst_id (not index field)
        if l_inst_id is not null then
            l_where := l_where         || ' and co.inst_id = x.p_inst_id';
        end if;

        if l_card_number  is not null
           or l_card_mask is not null
           or l_card_id   is not null
        then
            l_where := l_where || ' and co.id in (select c.contract_id from iss_card c'
                               || case when l_card_number is not null  then ', iss_card_number cn'     else null end
                               ||                                          ' where 1 = 1'
                               || case when l_card_number is not null  then  ' and cn.card_id = c.id'  else null end;

            -- card_number
            if l_card_number is not null then
                if iss_api_token_pkg.is_token_enabled() = com_api_type_pkg.FALSE then
                    if instr(l_card_number, '%') != 0 then
                        l_where := l_where || ' and reverse(cn.card_number) like reverse(x.p_card_number)';
                    else
                        l_where := l_where || ' and reverse(cn.card_number) = reverse(x.p_card_number)';
                    end if;
                else
                    if instr(l_card_number, '%') != 0 then
                        l_where := l_where || ' and reverse(c.card_mask) like reverse(x.p_card_mask)'
                                           || ' and cn.card_number like x.p_card_number';
                    else
                        l_where := l_where || ' and reverse(cn.card_number) = reverse(x.p_card_number)';
                    end if;
                end if;

            -- card_mask when card_number is null
            elsif l_card_mask is not null then
                l_where := l_where         || ' and reverse(c.card_mask) like reverse(x.p_card_mask)';
            end if;

            -- card_id
            if l_card_id is not null then
                l_where := l_where         || ' and c.id = x.p_card_id';
            end if;

            l_where := l_where || ')';
        end if;

        -- customer_number
        if l_customer_number is not null then
            if instr(l_customer_number, '%') != 0 then
                l_where := l_where     || ' and reverse(cu.customer_number) like reverse(x.p_customer_number)';
            else
                l_where := l_where     || ' and reverse(cu.customer_number) = reverse(x.p_customer_number)';
            end if;
        end if;

        -- contract_number
        if l_contract_number is not null then
            if instr(l_contract_number, '%') != 0 then
                l_where := l_where     || ' and reverse(co.contract_number) like reverse(x.p_contract_number)';
            else
                l_where := l_where     || ' and reverse(co.contract_number) = reverse(x.p_contract_number)';
            end if;
        end if;

        -- product_id
        if l_product_id is not null then
            l_where := l_where         || ' and co.product_id = x.p_product_id';
        end if;

        -- customer_id
        if l_customer_id is not null then
            l_where := l_where         || ' and co.customer_id = x.p_customer_id';
        end if;

        -- customer_type
        if l_customer_type is not null then
            l_where := l_where         || ' and cu.entity_type = x.p_customer_type';
        end if;

        -- start_date_from
        if l_start_date_from is not null then
            l_where := l_where         || ' and trunc(co.start_date) >= trunc(x.p_start_date_from)';
        end if;

        -- start_date_to
        if l_start_date_to is not null then
            l_where := l_where         || ' and trunc(co.start_date) <= trunc(x.p_start_date_to)';
        end if;

        -- end_date_from
        if l_end_date_from is not null then
            l_where := l_where         || ' and trunc(co.end_date) >= trunc(x.p_end_date_from)';
        end if;

        -- end_date_to
        if l_end_date_to is not null then
            l_where := l_where         || ' and trunc(co.end_date) <= trunc(x.p_end_date_to)'
                                       || ' and (trunc(co.start_date) <= trunc(x.p_end_date_to) or co.start_date is null)';
        end if;

        -- contract_type
        if l_contract_type is not null then
            l_where := l_where         || ' and co.contract_type = x.p_contract_type';
        end if;

        -- product_type
        if l_product_type is not null then
            l_where := l_where         || ' and p.product_type = x.p_product_type';
        end if;

        -- account_number / account_id
        if l_account_number is not null
           or l_account_id  is not null
        then
            l_where := l_where         || ' and co.id in (select a.contract_id from acc_account a where 1 = 1';

            -- account_number
            if l_account_number is not null then
                if instr(l_account_number, '%') != 0 then
                    l_where := l_where || ' and reverse(a.account_number) like reverse(x.p_account_number)';
                else
                    l_where := l_where || ' and reverse(a.account_number) = reverse(x.p_account_number)';
                end if;
            end if;

            -- account_id
            if l_account_id  is not null then
                l_where := l_where     || ' and a.id = x.p_account_id';
            end if;

            l_where := l_where         || ')';
        end if;

        -- merchant_number / merchant_id
        if l_merchant_number is not null
           or l_merchant_id  is not null
        then
            l_where := l_where         || ' and co.id in (select m.contract_id from acq_merchant m where 1 = 1';

            -- merchant_number
            if l_merchant_number is not null then
                if instr(l_merchant_number, '%') != 0 then
                    l_where := l_where || ' and reverse(m.merchant_number) like reverse(x.p_merchant_number)';
                else
                    l_where := l_where || ' and reverse(m.merchant_number) = reverse(x.p_merchant_number)';
                end if;
            end if;

            -- merchant_id
            if l_merchant_id  is not null then
                l_where := l_where     || ' and m.id = x.p_merchant_id';
            end if;

            l_where := l_where         || ')';
        end if;

        -- terminal_number / terminal_id
        if l_terminal_number is not null
           or l_terminal_id  is not null
        then
            l_where := l_where         || ' and co.id in (select t.contract_id from acq_terminal t where 1 = 1';

            -- terminal_number
            if l_terminal_number is not null then
                if instr(l_terminal_number, '%') != 0 then
                    l_where := l_where || ' and reverse(t.terminal_number) like reverse(x.p_terminal_number)';
                else
                    l_where := l_where || ' and reverse(t.terminal_number) = reverse(x.p_terminal_number)';
                end if;
            end if;

            -- terminal_id
            if l_terminal_id  is not null then
                l_where := l_where     || ' and t.id = x.p_terminal_id';
            end if;
        end if;

    else
        com_api_error_pkg.raise_error(
            i_error => 'INVALID_TAB_NAME'
        );
    end if;

    -- Extra condition (limitation) is defined by privileges
    l_privil_limitation := com_ui_object_search_pkg.get_char_value(l_param_tab, 'PRIVIL_LIMITATION');
    trc_log_pkg.debug(LOG_PREFIX || 'PRIVIL_LIMITATION [' || l_privil_limitation || ']');
    if l_privil_limitation is not null then
        l_where := l_where || ' and ' || l_privil_limitation;
    end if;

    com_ui_object_search_pkg.start_search(
        i_is_first_call => i_is_first_call
    );

    if  i_is_first_call = com_api_const_pkg.TRUE then
        l_query := 'select count(1) '|| l_from || l_where;

        --execute immediate 'explain plan set statement_id = ''card_search_count'' for ' || l_where;
        --select stragg(plan_table_output||CRLF)
        --  into l_plan
        --  from table(dbms_xplan.display(null, 'card_search_count', 'BASIC'));
        --trc_log_pkg.debug(substr(l_plan, 1, 3950));

        execute immediate l_query
           into io_row_count
          using l_inst_id
              , l_product_id
              , l_start_date_from
              , l_start_date_to
              , l_end_date_from
              , l_end_date_to
              , l_contract_type
              , l_contract_number
              , l_customer_number
              , l_card_number
              , l_card_mask
              , l_lang
              , l_contract_id
              , l_customer_id
              , l_customer_type
              , l_user_id
              , l_product_type;

    else
        l_query := 'select t.*'
                     || ', get_text(''ost_institution'',''name'', t.inst_id, t.lang) as inst_name'
                     || ', get_article_text(t.contract_type, t.lang) as contract_type_name'
                     || ', get_text(''prd_product'', ''label'', t.product_id, t.lang) as product_name'
                     || ', case t.customer_type'
                     || '  when ''ENTTCOMP'' then get_text(''COM_COMPANY'',''LABEL'', t.customer_object_id, t.lang)'
                     || '  when ''ENTTPERS'' then com_ui_person_pkg.get_person_name(t.customer_object_id, t.lang)'
                     || '  end as customer_name'
                     || ', (select cc.contract_number from prd_contract cc where cc.id = t.customer_contract_id) as customer_contract_number'
                     || ' from (select a.*, rownum rn'
                     || ' from (select * from ('
                     || COLUMN_LIST || l_from || l_where || ') ' || l_order_by
                     || ') a) t where rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_query
          using l_inst_id
              , l_product_id
              , l_start_date_from
              , l_start_date_to
              , l_end_date_from
              , l_end_date_to
              , l_contract_type
              , l_contract_number
              , l_customer_number
              , l_card_number
              , l_card_mask
              , l_lang
              , l_contract_id
              , l_customer_id
              , l_customer_type
              , l_user_id
              , l_product_type
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
  , i_row_count         in      com_api_type_pkg.t_medium_id  default null
  , i_first_row         in      com_api_type_pkg.t_medium_id
  , i_last_row          in      com_api_type_pkg.t_medium_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt             default null
) is
    l_row_count                 com_api_type_pkg.t_medium_id  := i_row_count;
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
    o_row_count            out  com_api_type_pkg.t_medium_id
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

end prd_ui_contract_search_pkg;
/
