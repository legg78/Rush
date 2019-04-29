create or replace package body iss_ui_cardholder_search_pkg is

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
    l_customer_number           com_api_type_pkg.t_name;
    l_contract_number           com_api_type_pkg.t_name;
    l_card_mask                 com_api_type_pkg.t_card_number;
    l_card_number               com_api_type_pkg.t_card_number;
    l_card_uid                  com_api_type_pkg.t_name;
    l_cardholder_number         com_api_type_pkg.t_name;
    l_cardholder_name           com_api_type_pkg.t_name;
    l_first_name                com_api_type_pkg.t_name;
    l_surname                   com_api_type_pkg.t_name;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_id_type                   com_api_type_pkg.t_dict_value;
    l_id_number                 com_api_type_pkg.t_name;
    l_cardholder_id             com_api_type_pkg.t_medium_id;
    l_cardholder_ids            com_api_type_pkg.t_full_desc;
    l_customer_id               com_api_type_pkg.t_medium_id;

    l_privil_limitation         com_api_type_pkg.t_full_desc;
    l_order_by                  com_api_type_pkg.t_name;
    l_user_id                   com_api_type_pkg.t_short_id;

    COLUMN_LIST        constant com_api_type_pkg.t_text :=
        'select ch.id'
      ||     ', ch.person_id'
      ||     ', ch.cardholder_number'
      ||     ', ch.cardholder_name'
      ||     ', ch.relation'
      ||     ', ch.resident'
      ||     ', ch.nationality'
      ||     ', ch.marital_status'
      ||     ', ch.inst_id'
      ||     ', ch.seqnum'
      ||     ', p.lang'
      ||     ', p.title'
      ||     ', p.first_name'
      ||     ', p.second_name'
      ||     ', p.surname'
      ||     ', p.suffix'
      ||     ', p.gender'
      ||     ', p.birthday'
      ||     ', p.place_of_birth'
      ||     ', p.seqnum as person_seqnum';

    l_from                      com_api_type_pkg.t_text :=
         ' from iss_cardholder ch'
      ||     ', com_person p'
      ||     ', (select :p_inst_id p_inst_id'
      ||             ', :p_cardholder_number p_cardholder_number'
      ||             ', :p_cardholder_name p_cardholder_name'
      ||             ', :p_card_number p_card_number'
      ||             ', :p_card_mask p_card_mask'
      ||             ', :p_card_uid p_card_uid'
      ||             ', :p_customer_number p_customer_number'
      ||             ', :p_contract_number p_contract_number'
      ||             ', :p_first_name p_first_name'
      ||             ', :p_surname p_surname'
      ||             ', :p_id_type p_id_type'
      ||             ', :p_id_number p_id_number'
      ||             ', :p_lang p_lang'
      ||             ', :p_cardholder_id p_cardholder_id'
      ||             ', :p_customer_id p_customer_id'
      ||             ', :p_user_id p_user_id'
      ||          ' from dual'
      ||       ') x';

    l_where                     com_api_type_pkg.t_text :=
        ' where ch.inst_id in (select ui.inst_id from acm_user_inst_mvw ui where ui.user_id = x.p_user_id)'
      ||     '  and p.id(+) = ch.person_id'
      ||     '  and (p.lang is null or coalesce('
      ||             ' (select s.lang from com_person s where s.id = ch.person_id and s.lang = x.p_lang)'
      ||            ', (select s.lang from com_person s where s.id = ch.person_id and s.lang = ''' || com_api_const_pkg.LANGUAGE_ENGLISH || ''')'
      ||            ', (select s.lang from com_person s where s.id = ch.person_id and rownum = 1)'
      ||           ', ''LANGENG'') = p.lang)';

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
                                      else upper(i_sorting_tab(i).name)
                                  end
                                  || ' ' || i_sorting_tab(i).char_value;
                end loop;
            end if;

            trc_log_pkg.debug(LOG_PREFIX || 'l_order_by: ' || l_order_by);
        end if;
    end if;

    l_inst_id           := com_ui_object_search_pkg.get_number_value(l_param_tab, 'INST_ID');
    l_card_number       := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_NUMBER');
    l_card_uid          := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_UID');
    l_id_type           := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'ID_TYPE');
    l_id_number         := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'ID_NUMBER');
    l_lang              := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'LANG');
    l_cardholder_id     := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARDHOLDER_ID');
    l_cardholder_ids    := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARDHOLDER_IDS');
    l_customer_id       := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CUSTOMER_ID');

    l_cardholder_number := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CARDHOLDER_NUMBER'));
    l_cardholder_name   := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CARDHOLDER_NAME'));
    l_customer_number   := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CUSTOMER_NUMBER'));
    l_contract_number   := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CONTRACT_NUMBER'));
    l_first_name        := lower(com_ui_object_search_pkg.get_char_value(l_param_tab, 'FIRST_NAME'));
    l_surname           := lower(com_ui_object_search_pkg.get_char_value(l_param_tab, 'SURNAME'));

    l_user_id           := com_ui_user_env_pkg.get_user_id;

    if l_card_number is not null then
        l_card_mask     := iss_api_card_pkg.get_card_mask(l_card_number);
    else
        l_card_mask     := com_ui_object_search_pkg.get_char_value(l_param_tab, 'CARD_MASK');
    end if;

    -- cardholder_id
    if l_cardholder_id is not null then
        l_where := l_where || ' and ch.id = x.p_cardholder_id';

    -- cardholder_ids
    elsif l_cardholder_ids is not null then
        l_where := l_where || ' and ch.id in (' || l_cardholder_ids || ')';

    elsif i_tab_name = 'CARDHOLDER' then

        -- inst_id (not index field)
        if l_inst_id is not null then
            l_where := l_where || ' and ch.inst_id = x.p_inst_id';
        end if;

        -- cardholder_number (not index field)
        if l_cardholder_number is not null then
            if instr(l_cardholder_number, '%') != 0 then
                l_where := l_where || ' and ch.cardholder_number like x.p_cardholder_number';
            else
                l_where := l_where || ' and ch.cardholder_number = x.p_cardholder_number';
            end if;
        end if;

        -- cardholder_name (not index field)
        if l_cardholder_name is not null then
            if instr(l_cardholder_name, '%') != 0 then
                l_where := l_where || ' and ch.cardholder_name like x.p_cardholder_name';
            else
                l_where := l_where || ' and ch.cardholder_name = x.p_cardholder_name';
            end if;
        end if;

        if l_card_number        is not null
           or l_card_mask       is not null
           or l_card_uid        is not null
           or l_customer_id     is not null
           or l_customer_number is not null
           or l_contract_number is not null
        then
            l_where := l_where || ' and ch.id in (select c.cardholder_id from iss_card c'
                               || case when l_card_number     is not null  then ', iss_card_number cn'        else null end
                               || case when l_card_uid        is not null  then ', iss_card_instance ci'      else null end
                               || case when l_customer_number is not null  then ', prd_customer cu'           else null end
                               || case when l_contract_number is not null  then ', prd_contract co'           else null end
                               ||                                          ' where 1 = 1'
                               || case when l_card_number     is not null  then  ' and cn.card_id = c.id'      else null end
                               || case when l_card_uid        is not null  then  ' and ci.card_id = c.id'      else null end
                               || case when l_customer_number is not null  then  ' and cu.id = c.customer_id'  else null end
                               || case when l_contract_number is not null  then  ' and co.id = c.contract_id'  else null end;

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
                l_where := l_where || ' and reverse(c.card_mask) like reverse(x.p_card_mask)';
            end if;

            -- customer_id
            if l_customer_id is not null then
                l_where := l_where || ' and c.customer_id = x.p_customer_id';
            end if;

            -- card_uid
            if l_card_uid is not null then
                if instr(l_card_uid, '%') != 0 then
                    l_where := l_where || ' and reverse(ci.card_uid) like reverse(x.p_card_uid)';
                else
                    l_where := l_where || ' and reverse(ci.card_uid) = reverse(x.p_card_uid)';
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

            -- contract_number
            if l_contract_number is not null then
                if instr(l_contract_number, '%') != 0 then
                    l_where := l_where || ' and reverse(co.contract_number) like reverse(x.p_contract_number)';
                else
                    l_where := l_where || ' and reverse(co.contract_number) = reverse(x.p_contract_number)';
                end if;
            end if;

            l_where := l_where || ')';
        end if;

        -- surname, first_name
        if l_surname is not null then
            l_where := l_where || ' and p.id = ch.person_id';

            if instr(l_surname, '%') != 0 then
                l_where := l_where || ' and lower(p.surname) like lower(x.p_surname)';
            else
                l_where := l_where || ' and lower(p.surname) = lower(x.p_surname)';
            end if;

            if l_first_name is not null then
                if instr(l_first_name, '%') != 0 then
                    l_where := l_where || ' and lower(p.first_name) like lower(x.p_first_name)';
                else
                    l_where := l_where || ' and lower(p.first_name) = lower(x.p_first_name)';
                end if;
            end if;
        end if;

        -- id_type, id_number
        if l_id_number is not null then
            l_where := l_where || ' and ch.person_id in (select io.object_id from com_id_object io'
                               ||                       ' where io.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_PERSON || ''''
                               ||                         ' and io.id_type = x.p_id_type';

            if instr(l_id_number, '%') != 0 then
                l_where := l_where || ' and io.id_number like x.p_id_number';
            else
                l_where := l_where || ' and io.id_number = x.p_id_number';
            end if;

            l_where := l_where || ')';
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
              , l_cardholder_number
              , l_cardholder_name
              , l_card_number
              , l_card_mask
              , l_card_uid
              , l_customer_number
              , l_contract_number
              , l_first_name
              , l_surname
              , l_id_type
              , l_id_number
              , l_lang
              , l_cardholder_id
              , l_customer_id
              , l_user_id;

    else
        l_query := 'select t.*'
                     || ', get_text(''ost_institution'',''name'', t.inst_id, t.lang) inst_name'
                     || ' from (select a.*'
                     ||             ', rownum rn'
                     || ' from (select * from ('
                     || COLUMN_LIST || l_from || l_where || ') ' || l_order_by
                     || ') a) t where rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_query
          using l_inst_id
              , l_cardholder_number
              , l_cardholder_name
              , l_card_number
              , l_card_mask
              , l_card_uid
              , l_customer_number
              , l_contract_number
              , l_first_name
              , l_surname
              , l_id_type
              , l_id_number
              , l_lang
              , l_cardholder_id
              , l_customer_id
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

end iss_ui_cardholder_search_pkg;
/
