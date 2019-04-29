create or replace package body iss_ui_card_search_pkg is

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
    l_cardholder_name           com_api_type_pkg.t_name;
    l_customer_id               com_api_type_pkg.t_long_id;
    l_card_type_id              com_api_type_pkg.t_inst_id;
    l_contract_number           com_api_type_pkg.t_name;
    l_customer_number           com_api_type_pkg.t_name;
    l_product_number            com_api_type_pkg.t_name;
    l_surname                   com_api_type_pkg.t_name;
    l_first_name                com_api_type_pkg.t_name;
    l_account_id                com_api_type_pkg.t_account_id;
    l_cardholder_id             com_api_type_pkg.t_medium_id;
    l_contract_id               com_api_type_pkg.t_medium_id;
    l_agent_id                  com_api_type_pkg.t_medium_id;
    l_card_id                   com_api_type_pkg.t_long_id;
    l_expir_date                date;
    l_card_uid                  com_api_type_pkg.t_name;
    l_card_state                com_api_type_pkg.t_dict_value;
    l_card_status               com_api_type_pkg.t_dict_value;
    l_card_statuses             com_api_type_pkg.t_param_value;
    l_contract_type             com_api_type_pkg.t_dict_value;
    l_card_number               com_api_type_pkg.t_card_number;
    l_card_mask                 com_api_type_pkg.t_card_number;
    l_lang                      com_api_type_pkg.t_dict_value;

    l_privil_limitation         com_api_type_pkg.t_full_desc;
    l_order_by                  com_api_type_pkg.t_name;
    l_user_id                   com_api_type_pkg.t_short_id;

    COLUMN_LIST        constant com_api_type_pkg.t_text :=
        'select c.id'
      ||     ', c.split_hash'
      ||     ', c.card_hash'
      ||     ', c.card_mask'
      ||     ', c.inst_id'
      ||     ', c.card_type_id'
      ||     ', c.country'
      ||     ', c.cardholder_id'
      ||     ', c.contract_id'
      ||     ', c.reg_date'
      ||     ', c.customer_id'
      ||     ', c.category'
      ||     ', cntr.product_id'
      ||     ', cntr.contract_number'
      ||     ', s.cardholder_name'
      ||     ', ch.cardholder_number'
      ||     ', cu.customer_number'
      ||     ', cu.entity_type customer_type'
      ||     ', p.product_type'
      ||     ', p.product_number'
      ||     ', c.reg_date regdate'
      ||     ', s.agent_id'
      ||     ', s.card_uid'
      ||     ', cntr.contract_type'
      ||     ', s.expir_date'
      ||     ', x.p_lang as lang'
      ||     ', s.state'
      ||     ', s.status'
      ||     ', cn.card_number'
      ||     ', s.id as card_instance_id'
      ;

    l_from                      com_api_type_pkg.t_text :=
         ' from iss_card c'
      ||     ', prd_contract cntr'
      ||     ', iss_card_instance s'
      ||     ', iss_cardholder ch'
      ||     ', iss_card_number cn'
      ||     ', prd_product p'
      ||     ', prd_customer cu'
      ||     ', (select :p_inst_id p_inst_id'
      ||             ', :p_cardholder_name p_cardholder_name'
      ||             ', :p_customer_id p_customer_id'
      ||             ', :p_card_number p_card_number'
      ||             ', :p_card_mask p_card_mask'
      ||             ', :p_card_type_id p_card_type_id'
      ||             ', :p_contract_number p_contract_number'
      ||             ', :p_customer_number p_customer_number'
      ||             ', :p_first_name p_first_name'
      ||             ', :p_surname p_surname'
      ||             ', :p_lang p_lang'
      ||             ', :p_product_number p_product_number'
      ||             ', :p_account_id p_account_id'
      ||             ', :p_cardholder_id p_cardholder_id'
      ||             ', :p_contract_id p_contract_id'
      ||             ', :p_agent_id p_agent_id'
      ||             ', :p_expir_date p_expir_date'
      ||             ', :p_card_id p_card_id'
      ||             ', :p_card_uid p_card_uid'
      ||             ', :p_card_state p_card_state'
      ||             ', :p_card_status p_card_status'
      ||             ', :p_card_statuses p_card_statuses'
      ||             ', :p_contract_type p_contract_type'
      ||             ', :p_user_id p_user_id'
      ||         ' from dual'
      ||       ') x ';

    l_where                     com_api_type_pkg.t_text :=
        ' where c.inst_id in (select ui.inst_id from acm_user_inst_mvw ui where ui.user_id = x.p_user_id)'
      ||  ' and s.agent_id in (select ai.agent_id from acm_user_agent_mvw ai where ai.user_id = x.p_user_id)'
      ||  ' and c.contract_id = cntr.id'
      ||  ' and c.id = s.card_id'
      ||  ' and s.is_last_seq_number = ' || com_api_type_pkg.TRUE
      ||  ' and c.cardholder_id = ch.id(+)'
      ||  ' and c.id = cn.card_id'
      ||  ' and c.customer_id = cu.id'
      ||  ' and cntr.product_id = p.id';

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
                                      when 'CARD_TYPE_NAME'
                                      then 'CARD_TYPE_ID'
                                      when 'PRODUCT_NAME'
                                      then 'PRODUCT_ID'
                                      when 'CARD_STATE_DESCR'
                                      then 'STATE'
                                      when 'CARD_STATUS_DESCR'
                                      then 'STATUS'
                                      when 'CARD_NUMBER'
                                      then 'CARD_MASK'
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

    if i_tab_name = 'CARD' then

        l_card_id         := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CARD_ID');
        l_inst_id         := com_ui_object_search_pkg.get_number_value(l_param_tab, 'INST_ID');
        l_customer_id     := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CUSTOMER_ID');
        l_card_number     := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_NUMBER');
        l_card_type_id    := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CARD_TYPE_ID');
        l_product_number  := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'PRODUCT_NUMBER');
        l_agent_id        := com_ui_object_search_pkg.get_number_value(l_param_tab, 'AGENT_ID');
        l_expir_date      := com_ui_object_search_pkg.get_date_value  (l_param_tab, 'EXPIR_DATE');
        l_card_uid        := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_UID');
        l_card_state      := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_STATE');
        l_card_status     := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_STATUS');
        l_card_statuses   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_STATUSES');
        l_contract_type   := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CONTRACT_TYPE');
        l_account_id      := com_ui_object_search_pkg.get_number_value(l_param_tab, 'ACCOUNT_ID');

        l_cardholder_name := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CARDHOLDER_NAME'));
        l_customer_number := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CUSTOMER_NUMBER'));
        l_contract_number := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CONTRACT_NUMBER'));
        l_surname         := lower(com_ui_object_search_pkg.get_char_value(l_param_tab, 'SURNAME'));
        l_first_name      := lower(com_ui_object_search_pkg.get_char_value(l_param_tab, 'FIRST_NAME'));

        -- card_id
        if l_card_id is not null then
            l_where := l_where || ' and c.id = x.p_card_id';
        end if;

        -- inst_id
        if l_inst_id is not null then
            l_where := l_where || ' and c.inst_id = x.p_inst_id';
        end if;

        -- cardholder_name
        if l_cardholder_name is not null then
            if instr(l_cardholder_name, '%') != 0 then
                l_where := l_where || ' and ch.cardholder_name like x.p_cardholder_name';
            else
                l_where := l_where || ' and ch.cardholder_name = x.p_cardholder_name';
            end if;
        end if;

        -- customer_id
        if l_customer_id is not null then
            l_where := l_where || ' and cu.id = x.p_customer_id';
        end if;

        -- card_number
        if l_card_number is not null then
            l_card_mask  := iss_api_card_pkg.get_card_mask(l_card_number);

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
        end if;

        -- card_type_id
        if l_card_type_id is not null then
            l_where := l_where || ' and c.card_type_id = x.p_card_type_id';
        end if;

        -- contract_number
        if l_contract_number is not null then
            if instr(l_contract_number, '%') != 0 then
                l_where := l_where || ' and reverse(cntr.contract_number) like reverse(x.p_contract_number)';
            else
                l_where := l_where || ' and reverse(cntr.contract_number) = reverse(x.p_contract_number)';
            end if;
        end if;

        -- customer_number
        if l_customer_number is not null then
            if instr(l_customer_number, '%') != 0 then
                l_where := l_where || ' and reverse(cu.customer_number) like reverse(x.p_customer_number)';
            else
                l_where := l_where || ' and reverse(cu.customer_number) = reverse(x.p_customer_number)';
            end if;
        end if;

        -- surname / first_name
        if l_surname is not null then
            l_where := l_where || ' and ch.person_id in (select id from com_person ps where lower(ps.surname) = x.p_surname';

            if l_first_name is not null then
                l_where := l_where || ' and lower(ps.first_name) = x.p_first_name';
            end if;

            l_where := l_where || ')';
        end if;

        -- product_number
        if l_product_number is not null then
            l_where := l_where || ' and p.product_number = x.p_product_number';
        end if;

        -- agent_id
        if l_agent_id is not null then
            l_where := l_where || ' and s.agent_id = x.p_agent_id';
        end if;

        -- expir_date
        if l_expir_date is not null then
            l_where := l_where || ' and trunc(s.expir_date, ''MM'') = trunc(x.p_expir_date, ''MM'')';
        end if;

        -- card_uid
        if l_card_uid is not null then
            if instr(l_card_uid, '%') != 0 then
                l_where := l_where || ' and reverse(s.card_uid) like reverse(x.p_card_uid)';
            else
                l_where := l_where || ' and reverse(s.card_uid) = reverse(x.p_card_uid)';
            end if;
        end if;

        -- card_state
        if l_card_state is not null then
            l_where := l_where || ' and s.state = x.p_card_state';
        end if;

        -- card_status
        if l_card_status is not null then
            l_where := l_where || ' and s.status = x.p_card_status';
        end if;

        -- card_statuses
        if l_card_statuses is not null then
            l_where := l_where || ' and instr(x.p_card_statuses, s.status) > 0';
        end if;

        -- contract_type
        if l_contract_type is not null then
            l_where := l_where || ' and cntr.contract_type = x.p_contract_type';
        end if;

        -- account_id
        if l_account_id is not null then
            l_where := l_where || ' and c.id in (select object_id from acc_account_object'
                                                       || ' where entity_type = ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''''
                                                       || ' and account_id = x.p_account_id)';
        end if;

    elsif i_tab_name = 'ACCOUNT' then
        l_account_id := com_ui_object_search_pkg.get_number_value(l_param_tab, 'ACCOUNT_ID');

        if l_account_id is not null then
            l_where := l_where || ' and c.id in (select object_id from acc_account_object'
                                                       || ' where entity_type = ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''''
                                                       || ' and account_id = x.p_account_id)';
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_CARDS'
            );
        end if;

    elsif i_tab_name = 'CARDHOLDER' then
        l_cardholder_id := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CARDHOLDER_ID');

        if l_cardholder_id is not null then
            l_where := l_where || ' and c.cardholder_id = x.p_cardholder_id';
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_CARDS'
            );
        end if;

    elsif i_tab_name = 'CUSTOMER' then
        l_customer_id := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CUSTOMER_ID');

        if l_customer_id is not null then
            l_where := l_where || ' and cu.id = x.p_customer_id';
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_CARDS'
            );
        end if;

    elsif i_tab_name = 'CONTRACT' then
        l_contract_id   := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CONTRACT_ID');
        l_contract_type := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CONTRACT_TYPE');

        if l_contract_id is not null then
            l_where := l_where || ' and cntr.id = x.p_contract_id';
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_CARDS'
            );
        end if;

        if l_contract_type is not null then
            l_where := l_where || ' and cntr.contract_type = x.p_contract_type';
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
        using
            l_inst_id
          , l_cardholder_name
          , l_customer_id
          , l_card_number
          , l_card_mask
          , l_card_type_id
          , upper(l_contract_number)
          , upper(l_customer_number)
          , l_first_name
          , l_surname
          , l_lang
          , l_product_number
          , l_account_id
          , l_cardholder_id
          , l_contract_id
          , l_agent_id
          , l_expir_date
          , l_card_id
          , l_card_uid
          , l_card_state
          , l_card_status
          , l_card_statuses
          , l_contract_type
          , l_user_id;

    else
        l_query := 'select t.*'
                     || ', get_text(''ost_institution'',''name'', t.inst_id, t.lang) inst_name'
                     || ', get_text(''net_card_type'', ''name'', t.card_type_id, t.lang) card_type_name'
                     || ', iss_api_token_pkg.decode_card_number(i_card_number => t.card_number) as card_number'
                     || ', get_text(''prd_product'', ''label'', t.product_id, t.lang) product_name'
                     || ', acc_api_account_pkg.get_default_accounts(i_object_id => t.id, i_entity_type => ''ENTTCARD'', i_use_atm_default => 0, i_use_pos_default => 1) as pos_default_account '
                     || ', acc_api_account_pkg.get_default_accounts(i_object_id => t.id, i_entity_type => ''ENTTCARD'', i_use_atm_default => 1, i_use_pos_default => 0) as atm_default_account '
                     || ', t.state || '' - '' || com_api_dictionary_pkg.get_article_text(t.state, t.lang) card_state_descr '
                     || ', t.status || '' - '' || com_api_dictionary_pkg.get_article_text(t.status, t.lang) card_status_descr '
                     || ', get_text(''ost_agent'',''name'', t.agent_id, t.lang) as agent_name'
                     || ', (select agent_number from ost_agent ag where ag.id = t.agent_id) as agent_number'
                     || ', t.card_instance_id'
                     || ' from (select a.*, rownum rn from (select * from ('
                     || COLUMN_LIST || l_from || l_where || ') ' || l_order_by
                     || ') a) t where rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_query
        using
            l_inst_id
          , l_cardholder_name
          , l_customer_id
          , l_card_number
          , l_card_mask
          , l_card_type_id
          , upper(l_contract_number)
          , upper(l_customer_number)
          , l_first_name
          , l_surname
          , l_lang
          , l_product_number
          , l_account_id
          , l_cardholder_id
          , l_contract_id
          , l_agent_id
          , l_expir_date
          , l_card_id
          , l_card_uid
          , l_card_state
          , l_card_status
          , l_card_statuses
          , l_contract_type
          , l_user_id
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
  , i_sorting_tab       in      com_param_map_tpt
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

end iss_ui_card_search_pkg;
/
