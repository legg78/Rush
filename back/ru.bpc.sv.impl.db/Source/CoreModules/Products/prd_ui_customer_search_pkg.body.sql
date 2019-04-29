create or replace package body prd_ui_customer_search_pkg is
/*********************************************************
 *  UI for customer search <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.12.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_ui_customer_search_pkg  <br />
 *  @headcom
 **********************************************************/

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
    l_inst_id                   com_api_type_pkg.t_name;
    l_agent_id                  com_api_type_pkg.t_name;
    l_customer_number           com_api_type_pkg.t_name;
    l_contract_number           com_api_type_pkg.t_name;
    l_contract_start_date_from  date;
    l_contract_start_date_till  date;
    l_id_number                 com_api_type_pkg.t_name;
    l_id_type                   com_api_type_pkg.t_name;
    l_entity_type               com_api_type_pkg.t_name;
    l_surname                   com_api_type_pkg.t_name;
    l_first_name                com_api_type_pkg.t_name;
    l_birthday                  date;
    l_gender                    com_api_type_pkg.t_name;
    l_company_name              com_api_type_pkg.t_name;
    l_account_number            com_api_type_pkg.t_name;
    l_card_number               com_api_type_pkg.t_name;
    l_card_mask                 com_api_type_pkg.t_card_number;
    l_expir_date                date;
    l_merchant_number           com_api_type_pkg.t_name;
    l_merchant_name             com_api_type_pkg.t_name;
    l_terminal_number           com_api_type_pkg.t_name;
    l_phone_number              com_api_type_pkg.t_name;
    l_email                     com_api_type_pkg.t_name;
    l_im_number                 com_api_type_pkg.t_name;
    l_postal_code               com_api_type_pkg.t_name;
    l_city                      com_api_type_pkg.t_name;
    l_country                   com_api_type_pkg.t_name;
    l_street                    com_api_type_pkg.t_name;
    l_house                     com_api_type_pkg.t_name;
    l_ext_entity_type           com_api_type_pkg.t_name;
    l_product_type              com_api_type_pkg.t_name;
    l_card_id                   com_api_type_pkg.t_long_id;
    l_card_uid                  com_api_type_pkg.t_name;

    l_privil_limitation         com_api_type_pkg.t_full_desc;
    l_order_by                  com_api_type_pkg.t_name;
    l_user_id                   com_api_type_pkg.t_short_id;

    COLUMN_LIST        constant com_api_type_pkg.t_text :=
        'select c.id'
          || ', c.customer_number'
          || ', d.contract_number'
          || ', c.entity_type'
          || ', c.status'
          || ', c.ext_entity_type'
          || ', c.ext_object_id'
          || ', c.object_id'
          || ', prd_api_customer_pkg.get_customer_aging(i_customer_id => c.id) as max_aging_period'
          || ', d.agent_id'
          || ', x.p_lang as lang';

    l_query            com_api_type_pkg.t_text :=
          ' from prd_customer c'
          || ', prd_contract d'
          || ', ('
          ||    'select :p_inst_id p_inst_id'
          ||         ', :p_agent_id p_agent_id'
          ||         ', :p_lang p_lang'
          ||         ', :p_customer_number p_customer_number'
          ||         ', :p_contract_number p_contract_number'
          ||         ', :p_contract_start_date_from p_contract_start_date_from'
          ||         ', :p_contract_start_date_till p_contract_start_date_till'
          ||         ', :p_id_number p_id_number'
          ||         ', :p_id_type p_id_type'
          ||         ', :p_entity_type p_entity_type'
          ||         ', :p_surname p_surname'
          ||         ', :p_first_name p_first_name'
          ||         ', :p_second_name p_second_name'
          ||         ', :p_birthday p_birthday'
          ||         ', :p_gender p_gender'
          ||         ', :p_company_name p_company_name'
          ||         ', :p_account_number p_account_number'
          ||         ', :p_card_number p_card_number'
          ||         ', :p_card_type_id p_card_type_id'
          ||         ', :p_expir_date p_expir_date'
          ||         ', :p_merchant_number p_merchant_number'
          ||         ', :p_merchant_name p_merchant_name'
          ||         ', :p_merchant_type p_merchant_type'
          ||         ', :p_terminal_number p_terminal_number'
          ||         ', :p_phone_number p_phone_number'
          ||         ', :p_email p_email'
          ||         ', :p_im_number p_im_number'
          ||         ', :p_postal_code p_postal_code'
          ||         ', :p_city p_city'
          ||         ', :p_country p_country'
          ||         ', :p_street p_street'
          ||         ', :p_house p_house'
          ||         ', :p_apartment p_apartment'
          ||         ', :p_ext_entity_type p_ext_entity_type'
          ||         ', :p_product_type p_product_type'
          ||         ', :p_card_id p_card_id'
          ||         ', :p_card_uid p_card_uid'
          ||         ', :p_card_mask p_card_mask'
          ||         ', :p_user_id p_user_id'
          ||         ', get_sysdate p_sysdate'
          ||      ' from dual'
          ||   ') x'
          || ' where c.contract_id = d.id'
          ||   ' and c.inst_id in (select ui.inst_id from acm_user_inst_mvw ui where ui.user_id = x.p_user_id)'
          ||   ' and d.agent_id in (select ai.agent_id from acm_user_agent_mvw ai where ai.user_id = x.p_user_id)';

    -- The function returns string with filtering condition for WHERE clause.
    -- Flag <i_use_reverse> should be used ONLY if there is an index with reverse() function on field <i_field_name>,
    -- and this field doesn't contain multi-byte strings, because reverse() function can be applied to a byte sequence only.
    -- Otherwise, exception ORA-29275 will be raised for multi-byte strings.
    function add_condition(
        i_param_name        in      com_api_type_pkg.t_name
      , i_use_reverse       in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
      , i_use_upper_reverse in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
      , i_use_upper_case    in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select case
                   when t.number_value is not null
                     or t.date_value is not null
                   then
                       ' and '||lower(i_param_name)||' '||nvl(condition, '=') || ' x.p_'||lower(i_param_name)

                   when t.char_value is not null
                    and (i_use_upper_reverse = com_api_type_pkg.TRUE
                         or i_use_upper_case = com_api_type_pkg.TRUE
                        )
                   then
                       case
                           when i_use_upper_reverse = com_api_type_pkg.TRUE
                            and substr(t.char_value, 1, 1) = '%'
                            and instr(substr(t.char_value, 2), '%') = 0
                           then
                               ' and reverse('||lower(i_param_name)||') '
                               || nvl(condition, 'like') || ' reverse(upper(substr(x.p_'||lower(i_param_name)||', 2)))||''%'''

                           when instr(t.char_value, '%') != 0 then
                               ' and '||lower(i_param_name)||' '
                               || nvl(condition, 'like') || ' upper(x.p_'||lower(i_param_name)||')'

                           else
                               ' and '||lower(i_param_name)||' '
                               || nvl(condition, '=') || ' upper(x.p_'||lower(i_param_name)||')'
                       end

                   when t.char_value is not null then
                       case
                           when i_use_reverse = com_api_type_pkg.TRUE then
                               ' and reverse(lower(nvl('||lower(i_param_name)||', ''%''))) '
                               || nvl(condition, 'like') || ' reverse(lower(x.p_'||lower(i_param_name)||'))'

                           when instr(t.char_value, '%') != 0 then
                               ' and lower(nvl('||lower(i_param_name)||', ''%'')) '
                               || nvl(condition, 'like') || ' lower(x.p_'||lower(i_param_name)||')'

                           else
                               ' and lower('||lower(i_param_name)||') '
                               || nvl(condition, '=') || ' lower(x.p_'||lower(i_param_name)||')'
                       end
               end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt)) t
         where t.name = upper(i_param_name);

        trc_log_pkg.debug(LOG_PREFIX || '->add_condition [' || l_result || ']');
        return l_result;
    exception
        when no_data_found then
            return null;
    end;

begin
    trc_log_pkg.debug(LOG_PREFIX || ': START with i_tab_name [' || i_tab_name
                                 || '], i_is_first_call [' || i_is_first_call || ']');

    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

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
                                      when 'CUSTOMER_NAME'
                                      then 'ID'
                                      when 'CUSTOMER_DOCUMENT'
                                      then '1'        -- Do not sorting by "Customer_document"
                                      else upper(i_sorting_tab(i).name)
                                  end
                                  || ' ' || i_sorting_tab(i).char_value;
                end loop;
            end if;

            trc_log_pkg.debug(LOG_PREFIX || 'l_order_by: ' || l_order_by);
        end if;
    end if;

    l_user_id    := com_ui_user_env_pkg.get_user_id;

    l_inst_id    := com_ui_object_search_pkg.get_number_value(l_param_tab, 'INST_ID');
    l_agent_id   := com_ui_object_search_pkg.get_number_value(l_param_tab, 'AGENT_ID');

    l_query := l_query || ' and c.inst_id = '||to_char(l_inst_id, 'TM9');

    if l_agent_id is not null then
        l_query := l_query || ' and d.agent_id = '||l_agent_id;
    end if;

    if i_tab_name = 'CUSTOMER' then
        l_contract_start_date_from := com_ui_object_search_pkg.get_date_value(l_param_tab, 'CONTRACT_START_DATE_FROM');
        l_contract_start_date_till := com_ui_object_search_pkg.get_date_value(l_param_tab, 'CONTRACT_START_DATE_TILL');
        l_product_type             := com_ui_object_search_pkg.get_char_value(l_param_tab, 'PRODUCT_TYPE');
        l_ext_entity_type          := com_ui_object_search_pkg.get_char_value(l_param_tab, 'EXT_ENTITY_TYPE');

        l_customer_number          := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CUSTOMER_NUMBER'));
        l_contract_number          := upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CONTRACT_NUMBER'));

        -- customer_number
        if l_customer_number is not null then 
            l_query := l_query || add_condition(i_param_name        => 'CUSTOMER_NUMBER'
                                              , i_use_upper_reverse => com_api_type_pkg.TRUE);
        end if;

        -- contract_number
        if l_contract_number is not null then 
            l_query := l_query || ' and c.id in (select customer_id from prd_ui_contract_vw where 1=1';
            l_query := l_query || add_condition(i_param_name => 'CONTRACT_NUMBER'
                                              , i_use_upper_reverse => com_api_type_pkg.TRUE);
            -- contract_start_date_from
            if l_contract_start_date_from is not null then
                l_query := l_query || ' and start_date >= p_contract_start_date_from ';
            end if;

            -- contract_start_date_till
            if l_contract_start_date_till is not null then
                l_query := l_query || ' and start_date <= p_contract_start_date_till ';
            end if;

            if l_contract_start_date_from is not null
                and l_contract_start_date_till is not null
                and l_contract_start_date_from > l_contract_start_date_till
            then
                com_api_error_pkg.raise_error(
                    i_error      => 'INCONSISTENT_DATE'
                  , i_env_param1 => to_char(l_contract_start_date_from, 'dd.mm.yyyy hh24:mi:ss')
                  , i_env_param2 => to_char(l_contract_start_date_till, 'dd.mm.yyyy hh24:mi:ss')
                );
            end if;

            -- product_type
            if l_product_type is not null then
                l_query := l_query || ' and product_type = p_product_type ';
            end if;

            l_query := l_query || ')';
        end if;

        -- ext_entity_type
        if l_ext_entity_type is not null then
            l_query := l_query || add_condition(i_param_name      => 'EXT_ENTITY_TYPE'
                                              , i_use_upper_case  => com_api_type_pkg.TRUE);
        end if;

        -- product_type
        if l_product_type is not null and l_contract_number is null then
            l_query := l_query
                         || ' and c.id in (select customer_id from prd_ui_contract_vw where product_type = p_product_type)';
        end if;
        
        if l_customer_number is null and l_contract_number is null and l_ext_entity_type is null and l_product_type is null then
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'ID_CARD' then
        l_entity_type := com_ui_object_search_pkg.get_char_value(l_param_tab, 'ENTITY_TYPE');
        l_id_type     := com_ui_object_search_pkg.get_char_value(l_param_tab, 'ID_TYPE');
        l_id_number   := com_ui_object_search_pkg.get_char_value(l_param_tab, 'ID_NUMBER');

        if l_id_number is not null
           or l_id_type is not null
           or l_entity_type is not null
        then
            l_query := l_query     ||' and (c.entity_type, c.object_id) in (select entity_type, object_id from com_id_object where 7 = 7';

            if l_id_number is not null then
                l_query := l_query || ' and lower(id_series||id_number) like lower(x.p_id_number)';
            end if;

            if l_id_type is not null then
                l_query := l_query || ' and id_type = x.p_id_type';
            end if;

            if l_entity_type is not null then
                l_query := l_query || ' and entity_type = x.p_entity_type';
            end if;

            l_query := l_query || ')';
        else
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'PERSON' then
        l_surname    := com_ui_object_search_pkg.get_char_value(l_param_tab, 'SURNAME');
        l_first_name := com_ui_object_search_pkg.get_char_value(l_param_tab, 'FIRST_NAME');
        l_birthday   := com_ui_object_search_pkg.get_date_value(l_param_tab, 'BIRTHDAY');
        l_gender     := com_ui_object_search_pkg.get_char_value(l_param_tab, 'GENDER');

        if l_surname is not null then
            l_query := l_query
                         || ' and (c.entity_type, c.object_id) in (select ''ENTTPERS'', a.id from com_person a where 1=1'
                         || add_condition(i_param_name => 'SURNAME');

            if l_first_name is not null then
                l_query := l_query || add_condition(i_param_name => 'FIRST_NAME');
            end if;

            l_query := l_query || add_condition(i_param_name => 'SECOND_NAME');

            if l_birthday is not null then
                l_query := l_query || ' and trunc(birthday) = trunc(x.p_birthday)';
            end if;

            if l_gender is not null then
                l_query := l_query || add_condition(i_param_name => 'GENDER');
            end if;

            l_query := l_query || ')';

        else
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'COMPANY' then
        l_company_name := com_ui_object_search_pkg.get_char_value(l_param_tab, 'COMPANY_NAME');

        if l_company_name is not null then
            l_query := l_query
                         || ' and (c.entity_type, c.object_id) in ('
                         || 'select ''' || com_api_const_pkg.ENTITY_TYPE_COMPANY || ''', object_id from com_i18n '
                         ||  'where table_name = ''COM_COMPANY'' and lower(text) like lower(x.p_company_name)'
                         || ')';
        else
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'ACCOUNT' then

        l_account_number := com_ui_object_search_pkg.get_char_value(l_param_tab, 'ACCOUNT_NUMBER');

        if l_account_number is not null then
            -- Using index (account_number, inst_id) on acc_account
            l_query := l_query
                         || ' and c.id in (select t.customer_id from acc_account t where t.inst_id = x.p_inst_id'
                         || add_condition(i_param_name => 'ACCOUNT_NUMBER')
                         || ')';
        else
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'CARD' then
        l_card_id     := com_ui_object_search_pkg.get_number_value(l_param_tab, 'CARD_ID');
        l_card_number := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_NUMBER');
        l_card_uid    := com_ui_object_search_pkg.get_char_value  (l_param_tab, 'CARD_UID');
        l_expir_date  := com_ui_object_search_pkg.get_date_value  (l_param_tab, 'EXPIR_DATE');

        l_card_mask     := iss_api_card_pkg.get_card_mask(l_card_number);

        -- card_id
        if l_card_id is not null then
            l_query := l_query
                         || ' and c.id in (select a.customer_id from iss_card a where a.id = x.p_card_id)';

        -- card_uid
        elsif l_card_uid is not null then
            l_query := l_query
                         || ' and c.id in (select a.customer_id from iss_card a, iss_card_instance i'
                         || ' where i.card_id = a.id';

            if instr(l_card_uid, '%') != 0 then
                l_query := l_query || ' and reverse(i.card_uid) like reverse(x.p_card_uid)';
            else
                l_query := l_query || ' and reverse(i.card_uid) = reverse(x.p_card_uid)';
            end if;

            l_query := l_query || ')';

        -- card_number
        elsif l_card_number is not null then
            l_query := l_query
                         || ' and c.id in (select a.customer_id from iss_card a, iss_card_number n, iss_card_instance i'
                         || ' where i.card_id = a.id'
                         ||   ' and n.card_id = a.id';

            if iss_api_token_pkg.is_token_enabled() = com_api_type_pkg.FALSE then
                if instr(l_card_number, '%') != 0 then
                    l_query := l_query || ' and reverse(n.card_number) like reverse(x.p_card_number)';
                else
                    l_query := l_query || ' and reverse(n.card_number) = reverse(x.p_card_number)';
                end if;
            else
                if instr(l_card_number, '%') != 0 then
                    l_query := l_query || ' and reverse(a.card_mask) like reverse(x.p_card_mask)'
                                       || ' and n.card_number like x.p_card_number';
                else
                    l_query := l_query || ' and reverse(n.card_number) = reverse(x.p_card_number)';
                end if;
            end if;

            if l_expir_date is not null then
                l_query := l_query || ' and trunc(i.expir_date, ''MM'') = trunc(x.p_expir_date, ''MM'')';
            end if;

            l_query := l_query || add_condition(i_param_name => 'CARD_TYPE_ID');
            l_query := l_query || ')';

        else
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'MERCHANT' then
        l_merchant_number := com_ui_object_search_pkg.get_char_value(l_param_tab, 'MERCHANT_NUMBER');
        l_merchant_name   := com_ui_object_search_pkg.get_char_value(l_param_tab, 'MERCHANT_NAME');

        l_query := l_query || ' and d.id in (select contract_id from acq_merchant where 1=1';

        -- merchant_number
        if l_merchant_number is not null then
            l_query := l_query || add_condition(i_param_name => 'MERCHANT_NUMBER')
                               || add_condition(i_param_name => 'MERCHANT_TYPE');
        end if;

        -- merchant_name
        if l_merchant_name is not null then
            l_query := l_query || add_condition(i_param_name => 'MERCHANT_NAME')
                               || add_condition(i_param_name => 'MERCHANT_TYPE');
        end if;

        if l_merchant_number is null and l_merchant_name is null then
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;
        l_query := l_query || ')';

    elsif i_tab_name = 'TERMINAL' then
        l_terminal_number := com_ui_object_search_pkg.get_char_value(l_param_tab, 'TERMINAL_NUMBER');

        if l_terminal_number is not null then
            l_query := l_query || ' and d.id in (select contract_id from acq_terminal where 1=1';
            l_query := l_query || add_condition(i_param_name  => 'TERMINAL_NUMBER'
                                              , i_use_reverse => com_api_type_pkg.TRUE);
            l_query := l_query || ')';
        else
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'CONTACT' then
        l_phone_number := com_ui_object_search_pkg.get_char_value(l_param_tab, 'PHONE_NUMBER');
        l_email        := com_ui_object_search_pkg.get_char_value(l_param_tab, 'EMAIL');
        l_im_number    := com_ui_object_search_pkg.get_char_value(l_param_tab, 'IM_NUMBER');

        if l_phone_number is not null then
            l_query := l_query || ' and c.id in ('
                         || 'select b.object_id from com_contact a, com_contact_object b, com_contact_data e '
                         ||  'where a.id = b.contact_id and a.id = e.contact_id '
                         ||    'and b.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                         ||    'and upper(e.commun_address) like upper(x.p_phone_number) and (e.end_date is null or e.end_date > x.p_sysdate) '
                         ||    'and e.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_MOBILE || ''''
                         || ')';
        end if;

        if l_email is not null then
            l_query := l_query || ' and c.id in ('
                         || 'select b.object_id from com_contact a, com_contact_object b, com_contact_data e '
                         ||  'where a.id = b.contact_id and a.id = e.contact_id '
                         ||    'and b.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                         ||    'and upper(e.commun_address) like upper(x.p_email) and (e.end_date is null or e.end_date > x.p_sysdate) '
                         ||    'and e.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_EMAIL || ''''
                         || ')';
        end if;

        if l_im_number is not null then
            l_query := l_query || ' and c.id in ('
                         || 'select b.object_id from com_contact a, com_contact_object b, com_contact_data e '
                         ||  'where a.id = b.contact_id and a.id = e.contact_id '
                         ||    'and b.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                         ||    'and upper(e.commun_address) like upper(x.p_im_number) and (e.end_date is null or e.end_date > x.p_sysdate) '
                         ||    'and e.commun_method in (''' || com_api_const_pkg.COMMUNICATION_METHOD_SKYPE || ''', '''
                                                            || com_api_const_pkg.COMMUNICATION_METHOD_AOL || ''', '''
                                                            || com_api_const_pkg.COMMUNICATION_METHOD_WLMESS || ''', '''
                                                            || com_api_const_pkg.COMMUNICATION_METHOD_IC || ''', '''
                                                            || com_api_const_pkg.COMMUNICATION_METHOD_YAHOO || ''', '''
                                                            || com_api_const_pkg.COMMUNICATION_METHOD_JABBER || ''')'
                         || ')';
        end if;

        if l_phone_number is null and l_email is null and l_im_number is null then
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;

    elsif i_tab_name = 'ADDRESS' then
        l_postal_code := com_ui_object_search_pkg.get_char_value(l_param_tab, 'POSTAL_CODE');
        l_house       := com_ui_object_search_pkg.get_char_value(l_param_tab, 'HOUSE');
        l_city        := com_ui_object_search_pkg.get_char_value(l_param_tab, 'CITY');
        l_street      := com_ui_object_search_pkg.get_char_value(l_param_tab, 'STREET');
        l_country     := com_ui_object_search_pkg.get_char_value(l_param_tab, 'COUNTRY');

        if (l_postal_code is not null and l_house is not null) or
           (l_city is not null and l_street is not null and l_house is not null)
        then
            l_query := l_query || ' and c.id in ('
                         || 'select b.object_id from com_address a, com_address_object b '
                         ||  'where a.id = b.address_id and b.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''''
                         ||   add_condition(i_param_name => 'POSTAL_CODE')
                         ||   ' and house like regexp_substr(x.p_house, ''^(\d*)'')||''%'''
                         ||   add_condition(i_param_name => 'CITY')
                         ||   add_condition(i_param_name => 'STREET')
                         ||   add_condition(i_param_name => 'APARTMENT');
            if l_country is not null then
                l_query := l_query || add_condition(i_param_name => 'COUNTRY');
            end if;
            l_query := l_query || ')';
        else
            com_api_error_pkg.raise_error(
                i_error         => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
            );
        end if;
    end if;

    -- Extra condition (limitation) is defined by privileges
    l_privil_limitation := com_ui_object_search_pkg.get_char_value(l_param_tab, 'PRIVIL_LIMITATION');
    if l_privil_limitation is not null then
        l_query := l_query || ' and ' || l_privil_limitation;
    end if;

    com_ui_object_search_pkg.start_search(
        i_is_first_call => i_is_first_call
    );

    if i_is_first_call = com_api_const_pkg.TRUE then
        l_query := 'select count(1) '|| l_query;

        execute immediate l_query
        into io_row_count
        using
            l_inst_id 
          , l_agent_id
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'LANG')
          , upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CUSTOMER_NUMBER'))
          , upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CONTRACT_NUMBER'))
          , com_ui_object_search_pkg.get_date_value(l_param_tab, 'CONTRACT_START_DATE_FROM')
          , com_ui_object_search_pkg.get_date_value(l_param_tab, 'CONTRACT_START_DATE_TILL')
          , l_id_number 
          , l_id_type 
          , l_entity_type 
          , l_surname 
          , l_first_name 
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'SECOND_NAME')
          , l_birthday 
          , l_gender 
          , l_company_name 
          , l_account_number 
          , l_card_number 
          , com_ui_object_search_pkg.get_number_value(l_param_tab, 'CARD_TYPE_ID')
          , l_expir_date 
          , l_merchant_number 
          , l_merchant_name 
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'MERCHANT_TYPE')
          , l_terminal_number 
          , l_phone_number 
          , l_email 
          , l_im_number 
          , l_postal_code 
          , l_city 
          , l_country 
          , l_street 
          , l_house 
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'APARTMENT')
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'EXT_ENTITY_TYPE')
          , l_product_type 
          , l_card_id
          , l_card_uid
          , l_card_mask
          , l_user_id; 

    else
        l_query := 'select t.*'
                    ||  ', com_ui_object_pkg.get_object_desc(t.entity_type, t.object_id, t.lang) customer_name'
                    ||  ', com_ui_id_object_pkg.get_id_card_desc(t.entity_type, t.object_id) customer_document'
                    ||  ', com_ui_object_pkg.get_object_desc(t.ext_entity_type, t.ext_object_id, t.lang) ext_entity_desc'
                    ||  ', ost_ui_agent_pkg.get_agent_name(t.agent_id, t.lang) agent_name'
                    ||  ', ost_ui_agent_pkg.get_agent_number(t.agent_id) agent_number'
                    || ' from (select a.*, rownum rn from (select * from (select * from ('
                    || COLUMN_LIST || l_query || ')) ' || l_order_by
                    || ') a) t where rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_query
        using
            l_inst_id 
          , l_agent_id
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'LANG')
          , upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CUSTOMER_NUMBER'))
          , upper(com_ui_object_search_pkg.get_char_value(l_param_tab, 'CONTRACT_NUMBER'))
          , com_ui_object_search_pkg.get_date_value(l_param_tab, 'CONTRACT_START_DATE_FROM')
          , com_ui_object_search_pkg.get_date_value(l_param_tab, 'CONTRACT_START_DATE_TILL')
          , l_id_number
          , l_id_type 
          , l_entity_type
          , l_surname 
          , l_first_name 
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'SECOND_NAME')
          , l_birthday 
          , l_gender 
          , l_company_name 
          , l_account_number 
          , l_card_number 
          , com_ui_object_search_pkg.get_number_value(l_param_tab, 'CARD_TYPE_ID')
          , l_expir_date 
          , l_merchant_number 
          , l_merchant_name 
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'MERCHANT_TYPE')
          , l_terminal_number 
          , l_phone_number 
          , l_email 
          , l_im_number 
          , l_postal_code 
          , l_city 
          , l_country 
          , l_street 
          , l_house 
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'APARTMENT')
          , com_ui_object_search_pkg.get_char_value(l_param_tab, 'EXT_ENTITY_TYPE')
          , l_product_type 
          , l_card_id 
          , l_card_uid
          , l_card_mask
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
end;

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
end;

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
end;

end prd_ui_customer_search_pkg;
/
