create or replace package body acq_ui_terminal_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , o_row_count            out  com_api_type_pkg.t_long_id
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_contract_id               com_api_type_pkg.t_medium_id;
    l_account_id                com_api_type_pkg.t_medium_id;
    l_merchant_number           com_api_type_pkg.t_name;
    l_terminal_number           com_api_type_pkg.t_name;
    l_status                    com_api_type_pkg.t_dict_value;
    l_terminal_type             com_api_type_pkg.t_dict_value;
    l_terminal_id               com_api_type_pkg.t_medium_id;
    l_merchant_id               com_api_type_pkg.t_short_id;
    l_privil_limitation         com_api_type_pkg.t_full_desc;

    CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10);
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select t.id'                           ||
        ', t.is_template'                   ||
        ', t.terminal_number'               ||
        ', t.terminal_type'                 ||
        ', s.id standard_id'                ||
        ', t.merchant_id'                   ||
        ', t.plastic_number'                ||
        ', t.card_data_input_cap'           ||
        ', t.crdh_auth_cap'                 ||
        ', t.card_capture_cap'              ||
        ', t.term_operating_env'            ||
        ', t.crdh_data_present'             ||
        ', t.card_data_present'             ||
        ', t.card_data_input_mode'          ||
        ', t.crdh_auth_method'              ||
        ', t.crdh_auth_entity'              ||
        ', t.card_data_output_cap'          ||
        ', t.term_data_output_cap'          ||
        ', t.pin_capture_cap'               ||
        ', t.status'                        ||
        ', c.product_id'                    ||
        ', t.inst_id'                       ||
        ', t.seqnum'                        ||
        ', t.is_mac'                        ||
        ', t.gmt_offset'                    ||
        ', t.device_id'                     ||
        ', p_lang lang'                     ||
        ', t.contract_id'                   ||
        ', t.cash_dispenser_present'        ||
        ', t.payment_possibility'           ||
        ', t.use_card_possibility'          ||
        ', t.cash_in_present'               ||
        ', t.available_network'             ||
        ', t.available_operation'           ||
        ', t.available_currency'            ||
        ', t.mcc_template_id'               ||
        ', t.mcc'                           ||
        ', t.cat_level'                     ||
        ', pt.instalment_support'           ||
        ', t.terminal_profile'              ||
        ', t.pin_block_format'              ||
        ', p.product_type'                  ||
        ', p.product_number'                ||
        ', c.contract_number'               ||
        ', c.customer_id'                   ||
        ', m.merchant_number'               ||
        ', cu.entity_type as customer_type' ||
        ', cu.customer_number'              ||
        ', cm.id mcc_id '
      ;

    l_ref_source            com_api_type_pkg.t_text :=
     'from acq_terminal t'                                  ||
        ', com_mcc cm'                                      ||
        ', prd_contract c'                                  ||
        ', prd_product p'                                   ||
        ', acq_merchant m'                                  ||
        ', pos_terminal pt'                                 ||
        ', prd_customer cu'                                 ||
        ', cmn_standard_object s'                           ||
        ', (select :p_lang as p_lang'                       ||
                ', :p_inst_id as p_inst_id'                 ||
                ', :p_merchant_number as p_merchant_number' ||
                ', :p_terminal_number as p_terminal_number' ||
                ', :p_customer_id as p_customer_id'         ||
                ', :p_status as p_status'                   ||
                ', :p_terminal_type as p_terminal_type'     ||
                ', :p_contract_id as p_contract_id'         ||
                ', :p_account_id as p_account_id'           ||
                ', :p_terminal_id as p_terminal_id'         ||
                ', :p_merchant_id as p_merchant_id'         ||
             ' from dual) '                                 ||
    'where t.contract_id = c.id'                            ||
      ' and c.product_id = p.id'                            ||
      ' and t.merchant_id = m.id'                           ||
      ' and c.customer_id = cu.id'                          ||
      ' and t.id = s.object_id(+)'                          ||
      ' and t.mcc = cm.mcc(+)'                              ||
      ' and t.id = pt.id(+)'                                ||
      ' and s.entity_type(+) = ''ENTTTRMN'''                ||
      ' and s.standard_type(+) = ''STDT0002''';

    l_sorting_source            com_api_type_pkg.t_text;
    l_ref_query                 com_api_type_pkg.t_text;

    function get_sorting_param(
        i_sorting_tab       in       com_param_map_tpt
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select nvl2(list, 'order by '||list, '')
          into l_result
          from (select rtrim(xmlagg(xmlelement(e,name||' '||char_value,',').extract('//text()')),',') list
                  from table(cast(i_sorting_tab as com_param_map_tpt))
               );

        return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_sorting_param FAILED; '||
                              'dumping i_sorting_tab for debug...');
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
            raise;
    end;

    -- !!! this function does NOT return an param value !!! it return string such as 'p_card_number'!!!
    function get_string(
        i_param_name        in     com_api_type_pkg.t_name
      , i_is_format         in     com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select
          case
              --------------------------------------------------------------
              when i_is_format = com_api_const_pkg.FALSE then
                  'p_'||lower(i_param_name)
              --------------------------------------------------------------
              when date_value is not null then
                  ' and '||lower(i_param_name)||' '||nvl(condition, '=')||' p_'||lower(i_param_name)
              when char_value is not null and substr(char_value, 1, 1) = '%' then
                  ' and reverse(lower(nvl('||lower(i_param_name)||',''%''))) '||nvl(condition, 'like')||' reverse(lower(p_'||lower(i_param_name)||'))'
              when char_value is not null and instr(char_value, '%') != 0 then
                  ' and lower(nvl('||lower(i_param_name)||',''%'')) '||nvl(condition, 'like')||' lower(p_'||lower(i_param_name)||')'
              when char_value is not null then
                  ' and lower('||lower(i_param_name)||') '||nvl(condition, '=')||' lower(p_'||lower(i_param_name)||')'
              when number_value is not null then
                  ' and '||lower(i_param_name)||' '||nvl(condition, '=')||' p_'||lower(i_param_name)
              else null
          end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

        return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_string FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

    function get_char_value(
        i_param_name        in     com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select char_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_char_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

    function get_date_value(
        i_param_name        in     com_api_type_pkg.t_name
    ) return date is
        l_result            date;
    begin
        select date_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_date_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

    function get_number_value(
        i_param_name        in     com_api_type_pkg.t_name
    ) return number is
        l_result            number;
    begin
        select number_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_number_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || ', i_tab_name = "' || i_tab_name || '"');
    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    if i_tab_name = 'TERMINAL' then
        l_terminal_id := get_number_value('TERMINAL_ID');
        if l_terminal_id is not null then
            l_ref_source := l_ref_source || ' and t.id = '|| get_string('TERMINAL_ID', com_api_const_pkg.FALSE);
        end if;

        l_customer_id := get_number_value('CUSTOMER_ID');
        if l_customer_id is not null then
            l_ref_source := l_ref_source || ' and c.customer_id = '|| get_string('CUSTOMER_ID', com_api_const_pkg.FALSE);
        end if;

        l_inst_id := get_number_value('INST_ID');
        if l_inst_id is not null then
            l_ref_source := l_ref_source || ' and t.inst_id = '|| get_string('INST_ID', com_api_const_pkg.FALSE);
        end if;

        l_merchant_number := get_string('MERCHANT_NUMBER');
        if l_merchant_number is not null then
            l_ref_source := l_ref_source || l_merchant_number;
        end if;

        l_terminal_number := get_string('TERMINAL_NUMBER');
        if l_terminal_number is not null then
            l_ref_source := l_ref_source || l_terminal_number;
        end if;

        l_status := get_char_value('STATUS');
        if l_status is not null then
            l_ref_source := l_ref_source || ' and t.status = ' || get_string('STATUS', com_api_const_pkg.FALSE);
        end if;

        l_terminal_type := get_char_value('TERMINAL_TYPE');
        if l_terminal_type is not null then
            l_ref_source := l_ref_source || ' and t.terminal_type = ' || get_string('TERMINAL_TYPE', com_api_const_pkg.FALSE);
        end if;

    elsif i_tab_name = 'ACCOUNT' then
        l_account_id := get_number_value('ACCOUNT_ID');
        if l_account_id is not null then
            l_ref_source := l_ref_source
                         || ' and t.id in (select object_id from acc_account_object where entity_type = ''ENTTTRMN'' and  account_id = '
                         || get_string('ACCOUNT_ID', com_api_const_pkg.FALSE) || ') ';
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_TERMINALS'
            );
        end if;

    elsif i_tab_name = 'CONTRACT' then
        l_contract_id := get_number_value('CONTRACT_ID');
        if l_contract_id is not null then
            l_ref_source := l_ref_source || ' and t.contract_id = ' || get_string('CONTRACT_ID', com_api_const_pkg.FALSE);
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_TERMINALS'
            );
        end if;

    elsif i_tab_name = 'MERCHANT' then
        l_merchant_id := get_number_value('MERCHANT_ID');
        if l_merchant_id is not null then
            l_ref_source := l_ref_source || ' and t.merchant_id = ' || get_string('MERCHANT_ID', com_api_const_pkg.FALSE);
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_TERMINALS'
            );
        end if;

    else
        com_api_error_pkg.raise_error(
            i_error => 'INVALID_TAB_NAME'
        );
    end if;

    l_ref_source := l_ref_source || ' and t.inst_id in (select inst_id from acm_cu_inst_vw) ';

    trc_log_pkg.debug('PRIVIL_LIMITATION: '|| get_char_value('PRIVIL_LIMITATION'));
    l_privil_limitation := ' and '|| nvl( get_char_value('PRIVIL_LIMITATION'), ' 1 = 1');
    l_ref_source := l_ref_source || l_privil_limitation;

    l_sorting_source := get_sorting_param(i_sorting_tab);

    l_ref_query := 'select t.* '                                                                                              ||
                   ', com_api_i18n_pkg.get_text(''com_mcc'', ''name'', t.mcc_id, t.lang) as mcc_name'                         ||
                   ', get_object_desc(''ENTTTRMN'', t.id, i_enable_empty => 1) as terminal_name'                                                   ||
                   ', get_text(''acq_terminal'', ''description'', t.id, t.lang) as description'                               ||
                   ', get_text(''com_array'', ''label'', t.available_network, t.lang) as available_network_name'              ||
                   ', get_text(''com_array'', ''label'', t.available_operation, t.lang) as available_operation_name'          ||
                   ', get_text(''com_array'', ''label'', t.available_currency, t.lang) as available_currency_name'            ||
                   ', get_text(''prd_product'', ''label'', product_id, t.lang) as product_name'                               ||
                   ', get_text(''ost_institution'', ''name'', t.inst_id, t.lang) as inst_name'                                ||
                   ', get_text(''acq_merchant'', ''label'', t.merchant_id, t.lang) as merchant_name'                          ||
                   ', com_api_address_pkg.get_address_string(i_address_id => acq_api_terminal_pkg.get_terminal_address_id(t.id), i_enable_empty => 1) as address ' ||
                   ' from ('                                                                                                  ||
                           ' select * from( '                                                                                 ||
                                    ' select a.*, rownum rn '                                                                 ||
                                       'from ( '                                                                              ||
                                            ' select * from ('                                                                ||
                                                'select * from ('                                                             ||
                                                    COLUMN_LIST || l_ref_source                                               ||
                                                ') '                                                                          ||
                                            ') ' || l_sorting_source                                                          ||
                                    ') a '                                                                                    ||
                         ' ) where rn between :p_first_row and :p_last_row '                                                  ||
                   ') t'
                   ;
    trc_log_pkg.debug(l_ref_query);
    --dbms_output.put_line(l_ref_query);

    if  i_is_first_call = com_api_const_pkg.TRUE then
        execute immediate 'select count(1) '|| l_ref_source
        into o_row_count
        using
            get_char_value('LANG')
          , l_inst_id
          , get_char_value('MERCHANT_NUMBER')
          , get_char_value('TERMINAL_NUMBER')
          , l_customer_id
          , l_status
          , l_terminal_type
          , l_contract_id
          , l_account_id
          , l_terminal_id
          , l_merchant_id;
    else
        open o_ref_cur for l_ref_query
        using
            get_char_value('LANG')
          , l_inst_id
          , get_char_value('MERCHANT_NUMBER')
          , get_char_value('TERMINAL_NUMBER')
          , l_customer_id
          , l_status
          , l_terminal_type
          , l_contract_id
          , l_account_id
          , l_terminal_id
          , l_merchant_id
          , i_first_row
          , i_last_row;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.get_ref_cur_base FAILED: i_tab_name ['||i_tab_name||']:' || CRLF
                   || 'i_is_first_call ['||i_is_first_call||']' || CRLF
                   || 'l_inst_id ['||l_inst_id||']' || CRLF
                   || 'l_customer_id ['||l_customer_id||']' || CRLF
                   || 'l_account_id ['||l_account_id||']' || CRLF
                   || 'l_merchant_id ['||l_merchant_id||']' || CRLF
                   || 'l_merchant_number ['||l_merchant_number||']' || CRLF
                   || 'l_status ['||l_status||']' || CRLF
                   || 'l_contract_id ['||l_contract_id||']' || CRLF
                   || 'l_terminal_number ['||l_terminal_number||']' || CRLF
                   || 'l_terminal_type ['||l_terminal_type||']' || CRLF
                   || 'l_terminal_id ['||l_terminal_id||']' || CRLF
                   || 'i_first_row ['||i_first_row||']' || CRLF
                   || 'i_last_row ['||i_last_row||'];' || CRLF
                   || 'dumping i_param_tab for debug...'
        );
        utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required
        raise;
end;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_row_count         in      com_api_type_pkg.t_medium_id  default null
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt             default null
) is
    l_row_count         com_api_type_pkg.t_long_id;
begin
    get_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , o_row_count         => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end;

procedure get_row_count(
    o_row_count         out     com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    get_ref_cur_base(
        o_ref_cur           => l_ref_cur
      , o_row_count         => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end;

end acq_ui_terminal_search_pkg;
/
