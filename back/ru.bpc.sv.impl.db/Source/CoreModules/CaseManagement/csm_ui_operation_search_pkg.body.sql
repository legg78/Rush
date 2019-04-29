create or replace package body csm_ui_operation_search_pkg is

g_param_tab         com_param_map_tpt;
g_sorting_tab       com_param_map_tpt;

function get_sorting_param(
    i_sorting_tab       in      com_param_map_tpt
) return com_api_type_pkg.t_name
is
    l_result  com_api_type_pkg.t_name;
begin
    select nvl2(list, ' order by '||list, '')
      into l_result
      from (select rtrim(xmlagg(xmlelement(e, name||' '||char_value, ', ').extract('//text()')), ', ') as list
              from table(cast(i_sorting_tab as com_param_map_tpt))
             where name is not null
           );

    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_sorting_param [' || l_result || ']');

    -- Always add sorting by opr_operation.id
    return
        case when l_result is null           then ' order by id desc'
             when instr(l_result, ' id') = 0 then l_result || ', id desc'
                                             else l_result
        end;
exception
    when no_data_found then
        return null;
    when others then
        trc_log_pkg.debug('get_sorting_param FAILED, l_result [' || l_result || ']; '
                                     || 'dumping i_sorting_tab for debug...');
        utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
        raise;
end get_sorting_param;

function get_card_number_condition(
    i_field_name        in     com_api_type_pkg.t_oracle_name
) return com_api_type_pkg.t_name
is
    l_result            com_api_type_pkg.t_name;
begin
    begin
        select case
                   when iss_api_token_pkg.is_token_enabled() = com_api_type_pkg.FALSE then
                       ' and reverse(' || i_field_name || ') like reverse(''' || t.char_value || ''')'
                   when instr(t.char_value, '%') = 0 then
                       ' and reverse(' || i_field_name || ')' ||
                           ' like reverse(''' || iss_api_token_pkg.encode_card_number(i_card_number => t.char_value) || ''')'
                   else
                       ' and reverse(' || i_field_name || ')' ||
                           ' like reverse(''%'' || substr(''' || t.char_value ||
                                     ''', -'||iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_ENDING || '))' ||
                       ' and iss_api_token_pkg.decode_card_number(i_card_number => ' || i_field_name || ')' ||
                           ' like ''' || t.char_value || ''''
               end
          into l_result
          from table(cast(g_param_tab as com_param_map_tpt)) t
         where t.name = 'CARD_MASK';
    exception
        when no_data_found then null;
    end;

    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_card_number_condition [' || l_result || ']');

    return l_result;
end get_card_number_condition;

function get_number_value(
    i_param_name        in      com_api_type_pkg.t_name
) return number
is
    l_result            number;
begin
    select number_value
      into l_result
      from table(cast(g_param_tab as com_param_map_tpt))
     where name = i_param_name;

    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        trc_log_pkg.debug('get_number_value() FAILED with i_param_name [' || i_param_name || ']');
        raise;
end get_number_value;

function get_char_value(
    i_param_name        in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_name
is
    l_result            com_api_type_pkg.t_name;
begin
    begin
        select char_value
          into l_result
          from table(cast(g_param_tab as com_param_map_tpt))
         where upper(name) = upper(i_param_name);
    exception
        when no_data_found then
            null;
        when others then
            trc_log_pkg.debug('get_char_value() FAILED with i_param_name [' || i_param_name || ']');
            raise;
    end;
    return l_result;
end get_char_value;

function get_date_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_is_character      in      com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
) return date
is
    l_result            date;
begin
    select t.date_value
      into l_result
      from table(cast(g_param_tab as com_param_map_tpt)) t
     where upper(name) = upper(i_param_name);

    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        trc_log_pkg.debug('get_date_value() FAILED with i_param_name [' || i_param_name || ']');
        raise;
end get_date_value;

function get_to_date(
    i_date              in      date
) return com_api_type_pkg.t_name
is
begin
    return 'to_date(''' || to_char(i_date, com_api_const_pkg.DATE_FORMAT)
            || ''', ''' || com_api_const_pkg.DATE_FORMAT || ''')';
exception
    when others then
        trc_log_pkg.debug('get_to_date() FAILED');
        raise;
end get_to_date;

-- The function returns string with filtering condition for WHERE clause.
-- Flag <i_use_reverse> should be used ONLY if there is an index with reverse() function on field <i_field_name>,
-- and this field doesn't contain multi-byte strings, because reverse() function can be applied to a byte sequence only.
-- Otherwise, exception ORA-29275 will be raised for multi-byte strings.
function get_condition(
    i_param_name         in     com_api_type_pkg.t_oracle_name
  , i_field_name         in     com_api_type_pkg.t_oracle_name   default null
  , i_use_reverse       in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_name is
    l_result                    com_api_type_pkg.t_name;
begin
    select case
               when t.number_value is not null then
                   lower(nvl(i_field_name, 'op.' || i_param_name)) ||
                   nvl(t.condition, ' = ') ||
                   t.number_value
               when t.date_value is not null then
                   lower(nvl(i_field_name, 'op.' || i_param_name)) ||
                   nvl(t.condition, ' = ') ||
                   'to_date(''' || to_char(date_value, com_api_const_pkg.DATE_FORMAT)
                                || ''', ''' || com_api_const_pkg.DATE_FORMAT || ''')'
               when t.char_value is not null and i_use_reverse = com_api_type_pkg.TRUE then
                   'reverse(' || nvl(i_field_name, 'op.' || i_param_name) ||
                   ') like reverse(replace(''' || t.char_value || ''', ''*'',''%''))'
               when t.char_value is not null then
                   case
                       when instr(t.char_value, '%') != 0
                       then 'lower(nvl(' || nvl(i_field_name, 'op.' || i_param_name) || ', ''%''))' ||
                            nvl(t.condition, ' like ')
                       else 'lower(' || nvl(i_field_name, 'op.' || i_param_name) || ')' ||
                            nvl(t.condition, ' = ')
                   end
                   || 'lower(''' || t.char_value || ''')'
           end
      into l_result
      from table(cast(g_param_tab as com_param_map_tpt)) t
     where t.name = upper(i_param_name);

    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_condition [' || l_result || ']');

    return case when l_result is not null then ' and ' || l_result else null end;
exception
    when no_data_found then
        return null;
end get_condition;

procedure get_ref_cur_base(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , o_row_count         out     com_api_type_pkg.t_short_id
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_oper_date_from            date;
    l_oper_date_till            date;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_auth_code                 com_api_type_pkg.t_auth_code;
    l_card_number               com_api_type_pkg.t_card_number;

    CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10);
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ref_cur_base';
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
       'select /*+first_rows*/'
        ||   ' op.id'
        ||  ', op.session_id'
        ||  ', op.is_reversal'
        ||  ', op.original_id'
        ||  ', op.oper_type'
        ||  ', op.oper_reason'
        ||  ', op.msg_type'
        ||  ', op.status'
        ||  ', op.status_reason'
        ||  ', op.sttl_type'
        ||  ', op.sttl_amount'
        ||  ', op.sttl_currency'
        ||  ', op.acq_inst_bin'
        ||  ', op.forw_inst_bin'
        ||  ', op.terminal_number'
        ||  ', op.terminal_type'
        ||  ', op.merchant_number'
        ||  ', op.merchant_name'
        ||  ', op.merchant_street'
        ||  ', op.merchant_city'
        ||  ', op.merchant_region'
        ||  ', op.merchant_country'
        ||  ', op.merchant_postcode'
        ||  ', op.mcc'
        ||  ', op.originator_refnum'
        ||  ', op.network_refnum'
        ||  ', op.oper_count'
        ||  ', op.oper_request_amount'
        ||  ', op.oper_amount_algorithm'
        ||  ', op.oper_amount'
        ||  ', op.oper_currency'
        ||  ', op.oper_cashback_amount'
        ||  ', op.oper_replacement_amount'
        ||  ', op.oper_surcharge_amount'
        ||  ', op.oper_date'
        ||  ', op.host_date'
        ||  ', op.unhold_date'
        ||  ', op.match_status'
        ||  ', op.match_id'
        ||  ', op.dispute_id'
        ||  ', op.payment_order_id'
        ||  ', op.payment_host_id'
        ||  ', op.forced_processing'
        ||  ', op.incom_sess_file_id'
        ||  ', f.file_name'
        ||  ', f.file_type'
        ||  ', i.auth_code'
        ||  ', i.inst_id iss_inst_id'
        ||  ', i.network_id iss_network_id'
        ||  ', i.card_network_id card_network_id'
        ||  ', a.inst_id acq_inst_id'
        ||  ', a.network_id acq_network_id'
        ||  ', i.client_id_type iss_client_id_type'
        ||  ', i.client_id_value iss_client_id_value'
        ||  ', oc.card_number as iss_card_number' -- PAN isn't displayed on GUI - only its mask
        ||  ', a.client_id_type acq_client_id_type'
        ||  ', a.client_id_value acq_client_id_value'
        ||  ', null as acq_card_number'
        ||  ', i.account_number as iss_account_number'
        ||  ', a.account_number as acq_account_number'
        ||  ', mcc.id mcc_id'
        ||  ', auth.external_auth_id'
    ;
    l_from_statement            com_api_type_pkg.t_text :=
        ' from opr_ui_operation_vw op'
        ||  ', prc_session_file f '
        ||  ', opr_participant i'
        ||  ', opr_participant a'
        ||  ', opr_card oc'
        ||  ', com_mcc mcc'
        ||  ', aut_auth auth'
    ;
    l_where_statement           com_api_type_pkg.t_text :=
       ' where op.mcc = mcc.mcc(+)'
    ||   ' and op.incom_sess_file_id = f.id(+)'
    ||   ' and op.id = auth.id(+)'
    ||   ' and oc.participant_type(+) = i.participant_type'
    ||   ' and oc.oper_id(+) = i.oper_id'
    ||   ' and op.id = i.oper_id(+)'
    ||   ' and i.participant_type(+) = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''''
    ||   ' and op.id = a.oper_id(+)'
    ||   ' and a.participant_type(+) = ''' || com_api_const_pkg.PARTICIPANT_ACQUIRER || ''''
    ;
    l_sql_statement             com_api_type_pkg.t_sql_statement;
begin
    trc_log_pkg.debug(LOG_PREFIX || ': START with i_is_first_call [' || i_is_first_call || ']');
    -- Save into global params
    g_param_tab   := i_param_tab;
    g_sorting_tab := i_sorting_tab;

    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    l_customer_id           := get_number_value('CUSTOMER_ID');
    l_oper_date_from        := get_date_value('OPER_DATE_FROM');
    l_oper_date_till        := get_date_value('OPER_DATE_TILL');

    trc_log_pkg.debug(
        LOG_PREFIX || ': l_customer_id [' || l_customer_id || ']'
    );

    if l_customer_id is not null then
        l_where_statement := l_where_statement
                          || ' and i.customer_id  = ' || to_char(l_customer_id);
    end if;

    if l_oper_date_from is not null then
        l_where_statement := l_where_statement
                          || ' and op.oper_date >= ' || get_to_date(i_date => l_oper_date_from);
    end if;

    if l_oper_date_till is not null then
        l_where_statement := l_where_statement
                          || ' and op.oper_date <= ' || get_to_date(i_date => l_oper_date_till);
    end if;

    l_where_statement := l_where_statement
                      || get_condition(i_param_name => 'merchant_number')
                      || get_condition(i_param_name => 'terminal_number')
                      || get_condition(i_param_name => 'merchant_name');

    l_card_id := get_number_value('CARD_ID');
    if l_card_id is not null then
        l_where_statement := l_where_statement || ' and i.card_id = ' || to_char(l_card_id);
    end if;

    l_card_number := get_char_value('CARD_NUMBER');
    if l_card_number is not null then
        l_where_statement := l_where_statement || get_card_number_condition(i_field_name => 'c.card_number');
    end if;

    l_auth_code := get_char_value('AUTH_CODE');
    if l_auth_code is not null then
        l_where_statement := l_where_statement
                     || ' and i.auth_code = ''' || l_auth_code || '''';
    end if;
    
    if  get_char_value('PARTICIPANT_TYPE') is not null
    then
        l_where_statement := l_where_statement || ' and op.id in (select p.oper_id from opr_participant p';
        l_where_statement := l_where_statement
                          || get_condition(i_param_name  => 'participant_type'
                                         , i_field_name  => 'p.participant_type');
        l_where_statement := l_where_statement || ')';
    end if;

    if  i_is_first_call = com_api_const_pkg.TRUE then
        l_sql_statement := 'select /*+first_rows*/ count(1)' || l_from_statement
                        || l_where_statement;

        trc_log_pkg.debug(LOG_PREFIX || ': l_sql_statement [' || substr(l_sql_statement, 1, 3900) || ']');

        execute immediate l_sql_statement into o_row_count;

        trc_log_pkg.debug(LOG_PREFIX || ': o_row_count [' || o_row_count || ']');
    else
        l_sql_statement :=
        'select o.*' ||
             ', opr_api_reversal_pkg.reversal_exists(i_id => o.id) reversal_exists' ||
             ', nvl(o.iss_client_id_type, o.acq_client_id_type) client_id_type' ||
             ', coalesce(decode(o.iss_client_id_type, ''CITPACCT'', o.iss_account_number'
                   ||        ', ''CITPCARD'', iss_api_card_pkg.get_card_mask(o.iss_card_number), o.iss_client_id_value)'
                   || ', decode(o.acq_client_id_type, ''CITPACCT'', o.acq_account_number'
                   ||        ', ''CITPCARD'', iss_api_card_pkg.get_card_mask(o.acq_card_number), o.acq_client_id_value)' ||
               ') client_id_value' ||
             ', get_text(''com_mcc'', ''name'', o.mcc_id) mcc_name' ||
             ', o.auth_code' ||
             ', o.iss_inst_id' ||
             ', get_text(''ost_institution'', ''name'', o.iss_inst_id) iss_inst_name' ||
             ', o.iss_network_id' ||
             ', get_text(''net_network'', ''name'', o.iss_network_id) iss_network_name' ||
             ', o.card_network_id' ||
             ', get_text(''net_network'', ''name'', o.card_network_id) card_network_name' ||
             ', o.acq_inst_id' ||
             ', get_text(''ost_institution'', ''name'', o.acq_inst_id) acq_inst_name' ||
             ', o.acq_network_id' ||
             ', get_text(''net_network'', ''name'', o.acq_network_id) acq_network_name' ||
             ', get_article_text(o.terminal_type) terminal_type_name' ||
         ' from (' ||
              'select a.*, row_number() over (' || get_sorting_param(i_sorting_tab) || ') as rn ' ||
                'from (' ||
                    'select * from (' ||
                         COLUMN_LIST || l_from_statement || l_where_statement
                         || ') ' ||
                ') a ' ||
          ') o' ||
        ' where o.rn between :p_first_row and :p_last_row' ||
        ' order by o.rn';

        trc_log_pkg.debug(LOG_PREFIX || ': l_sql_statement [' || substr(l_sql_statement, 1, 3900) || ']');

        open o_ref_cur for l_sql_statement using i_first_row, i_last_row;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ': END');
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || ': FAILED with:' || CRLF
                   || 'i_is_first_call [' || i_is_first_call || ']' || CRLF
                   || 'l_customer_id [' || l_customer_id || ']' || CRLF
                   || 'l_card_id [' || l_card_id || ']' || CRLF
                   || 'l_oper_date_from [' || l_oper_date_from || ']' || CRLF
                   || 'l_oper_date_till [' || l_oper_date_till || ']' || CRLF
                   || 'l_auth_code [' || l_auth_code || ']' || CRLF
                   || 'i_first_row [' || i_first_row || ']' || CRLF
                   || 'i_last_row [' || i_last_row || '];'
        );
        raise;
end get_ref_cur_base;

procedure get_ref_cur(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
) is
    l_row_count         com_api_type_pkg.t_short_id;
begin
    get_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , o_row_count         => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end get_ref_cur;

procedure get_row_count(
    o_row_count         out     com_api_type_pkg.t_short_id
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
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end get_row_count;

end csm_ui_operation_search_pkg;
/
