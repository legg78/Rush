create or replace package body opr_ui_operation_search_pkg is

g_param_tab               com_param_map_tpt;
g_sorting_tab             com_param_map_tpt;

g_last_sql_statement      com_api_type_pkg.t_sql_statement;
g_object_list_tab         opr_ui_operation_list_tpt  := opr_ui_operation_list_tpt();
g_object_id_tab           num_tab_tpt                := num_tab_tpt();

type t_oper_rec is record(
    id                                com_api_type_pkg.t_long_id
  , session_id                        com_api_type_pkg.t_long_id
  , is_reversal                       com_api_type_pkg.t_boolean
  , original_id                       com_api_type_pkg.t_long_id
  , oper_type                         com_api_type_pkg.t_dict_value
  , oper_reason                       com_api_type_pkg.t_dict_value
  , msg_type                          com_api_type_pkg.t_dict_value
  , status                            com_api_type_pkg.t_dict_value
  , status_reason                     com_api_type_pkg.t_dict_value
  , sttl_type                         com_api_type_pkg.t_dict_value
  , sttl_amount                       com_api_type_pkg.t_money
  , sttl_currency                     com_api_type_pkg.t_curr_code
  , acq_inst_bin                      com_api_type_pkg.t_rrn
  , forw_inst_bin                     com_api_type_pkg.t_rrn
  , terminal_number                   com_api_type_pkg.t_terminal_number
  , terminal_type                     com_api_type_pkg.t_dict_value
  , merchant_number                   com_api_type_pkg.t_merchant_number
  , merchant_name                     com_api_type_pkg.t_name
  , merchant_street                   com_api_type_pkg.t_name
  , merchant_city                     com_api_type_pkg.t_name
  , merchant_region                   com_api_type_pkg.t_name
  , merchant_country                  com_api_type_pkg.t_curr_code
  , merchant_postcode                 com_api_type_pkg.t_name
  , mcc                               com_api_type_pkg.t_mcc
  , originator_refnum                 com_api_type_pkg.t_rrn
  , network_refnum                    com_api_type_pkg.t_rrn
  , oper_count                        com_api_type_pkg.t_long_id
  , oper_request_amount               com_api_type_pkg.t_money
  , oper_amount_algorithm             com_api_type_pkg.t_dict_value
  , oper_amount                       com_api_type_pkg.t_money
  , oper_currency                     com_api_type_pkg.t_curr_code
  , oper_cashback_amount              com_api_type_pkg.t_money
  , oper_replacement_amount           com_api_type_pkg.t_money
  , oper_surcharge_amount             com_api_type_pkg.t_money
  , oper_date                         date
  , host_date                         date
  , unhold_date                       date
  , match_status                      com_api_type_pkg.t_dict_value
  , match_id                          com_api_type_pkg.t_long_id
  , dispute_id                        com_api_type_pkg.t_long_id
  , payment_order_id                  com_api_type_pkg.t_long_id
  , payment_host_id                   com_api_type_pkg.t_tiny_id
  , forced_processing                 com_api_type_pkg.t_boolean
  , auth_code                         com_api_type_pkg.t_auth_code
  , iss_inst_id                       com_api_type_pkg.t_inst_id
  , iss_network_id                    com_api_type_pkg.t_network_id
  , card_network_id                   com_api_type_pkg.t_network_id
  , acq_inst_id                       com_api_type_pkg.t_inst_id
  , acq_network_id                    com_api_type_pkg.t_network_id
  , iss_client_id_type                com_api_type_pkg.t_dict_value
  , iss_client_id_value               com_api_type_pkg.t_name
  , iss_card_number                   com_api_type_pkg.t_card_number
  , acq_client_id_type                com_api_type_pkg.t_dict_value
  , acq_client_id_value               com_api_type_pkg.t_name
  , acq_card_number                   com_api_type_pkg.t_card_number
  , iss_account_number                com_api_type_pkg.t_account_number
  , acq_account_number                com_api_type_pkg.t_account_number
  , mcc_id                            com_api_type_pkg.t_tiny_id
  , external_auth_id                  com_api_type_pkg.t_attr_name
  , iss_card_token                    com_api_type_pkg.t_card_number
  , rn                                com_api_type_pkg.t_medium_id
);

type t_oper_tab is table of t_oper_rec index by binary_integer;


procedure get_opr_account_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , o_row_count            out  com_api_type_pkg.t_short_id
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    l_sorting_tab       com_param_map_tpt := null;
    l_ref_source        com_api_type_pkg.t_text;
    l_where             com_api_type_pkg.t_text;
    l_sub_query         com_api_type_pkg.t_text;
    l_group_by          com_api_type_pkg.t_name;
    l_host_date_from    date;
    l_host_date_till    date;
    l_account_id        com_api_type_pkg.t_account_id;
    l_privil_limitation com_api_type_pkg.t_full_desc;

    CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10);
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_opr_account_ref_cur_base';
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
        'select op.id'            ||
             ', op.host_date'     ||
             ', op.oper_amount'   ||
             ', op.oper_type'     ||
             ', op.is_reversal'   ||
             ', op.msg_type'      ||
             ', op.sttl_type'     ||
             ', op.status'        ||
             ', op.status_reason' ||
             ', op.oper_reason'   ||
         ' from opr_operation op ';

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

        -- Always add sorting by opr_operation.id
        l_result := case when l_result is null           then ' order by id desc'
                         when instr(l_result, ' id') = 0 then l_result || ', id desc'
                         else l_result
                    end;

        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_sorting_param [' || l_result || ']');

        return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug('get_sorting_param FAILED, l_result [' || l_result || ']; '
                                         || 'dumping i_sorting_tab for debug...');
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
            raise;
    end get_sorting_param;

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

begin
    trc_log_pkg.debug(LOG_PREFIX || ': START');

    trc_log_pkg.debug(LOG_PREFIX || ': i_is_first_call [' || i_is_first_call || ']');
    --save into global params
    g_param_tab   := i_param_tab;
    g_sorting_tab := i_sorting_tab;

    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    l_account_id     := get_number_value('ACCOUNT_ID');
    l_host_date_from := get_date_value('HOST_DATE_FROM');
    l_host_date_till := get_date_value('HOST_DATE_TILL');
    trc_log_pkg.debug(
        LOG_PREFIX ||
        ': l_account_id [' || l_account_id || '], ' ||
        'l_host_date_from [' || to_char(l_host_date_from, com_api_const_pkg.DATE_FORMAT) || '],' ||
        'l_host_date_till [' || to_char(l_host_date_till, com_api_const_pkg.DATE_FORMAT) || ']'
    );

    if  l_host_date_from is not null and nvl(l_host_date_till, trunc(sysdate)) - l_host_date_from > 60 then
        com_api_error_pkg.raise_error(
            i_error => 'PERIOD_GREATER_60'
        );
    end if;

    l_where := ' where op.id = x.oper_id';
    l_sub_query :=
         ', (select o.id oper_id'                           ||
         '        , count(1) cnt'                           ||
         '     from acc_entry e'                            ||
         '        , acc_macros m'                           ||
         '        , opr_operation o'                        ||
         '        , (select :p_account_id p_account_id'     ||
         '                , :p_start_date p_start_date'     ||
         '                , :p_end_date p_end_date '        ||
         '             from dual) x '                       ||
         '    where e.account_id  = x.p_account_id '        ||
         '      and m.id          = e.macros_id '           ||
         '      and m.entity_type = ''ENTTOPER'''           ||
         '      and m.object_id   = o.id ';

    l_group_by := ' group by o.id) x';

    if l_host_date_from is not null then
        l_sub_query := l_sub_query || ' and o.host_date >= p_start_date';
    end if;

    if l_host_date_till is not null then
        l_sub_query := l_sub_query || ' and o.host_date <= p_end_date';
    end if;

    l_privil_limitation := ' and ' || nvl(get_char_value('PRIVIL_LIMITATION'), ' 1 = 1 ');

    l_ref_source := COLUMN_LIST || l_sub_query || l_group_by || l_where || l_privil_limitation;

    if i_is_first_call = com_api_const_pkg.TRUE then
        trc_log_pkg.debug(
            LOG_PREFIX || ': select count(1) from (' || l_ref_source || ')'
        );
        execute immediate 'select count(1) from (' || l_ref_source || ')'
          into o_row_count
         using l_account_id
             , l_host_date_from
             , l_host_date_till;

        trc_log_pkg.debug(LOG_PREFIX || ': o_row_count [' || o_row_count || ']');

    else
        l_ref_source := 'select * from(select a.* , rownum rn from (' || l_ref_source || ' ' || get_sorting_param(l_sorting_tab) || ') a) where rn between :p_first_row and :p_last_row';
        trc_log_pkg.debug(
            LOG_PREFIX || ': ' || l_ref_source
        );

        open o_ref_cur for l_ref_source
        using l_account_id
            , l_host_date_from
            , l_host_date_till
            , i_first_row
            , i_last_row;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ': END');
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || ': FAILED with '
                   || 'i_is_first_call ['  || i_is_first_call || ']' || CRLF
                   || 'l_account_id ['     || l_account_id || ']' || CRLF
                   || 'l_host_date_from [' || l_host_date_from || ']' || CRLF
                   || 'l_host_date_till [' || l_host_date_till || ']' || CRLF
                   || 'i_first_row ['      || i_first_row || ']' || CRLF
                   || 'i_last_row ['       || i_last_row || ']'
        );
        raise;
end;

procedure get_opr_account_row_count(
    o_row_count            out  com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    get_opr_account_ref_cur_base(
        o_ref_cur           => l_ref_cur
      , o_row_count         => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end;

procedure get_opr_account_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt := null
) is
    l_row_count         com_api_type_pkg.t_short_id;
begin
    get_opr_account_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , o_row_count         => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end;

procedure get_search_param(
    i_tab_name          in             com_api_type_pkg.t_name
  , i_param_tab         in             com_param_map_tpt
  , o_param_rec            out         t_search_param_rec
) is
    LAST_WEEK_OFFSET         constant  com_api_type_pkg.t_tiny_id := 7;           -- 7 days
    END_OF_TOMORROW_OFFSET   constant  com_api_type_pkg.t_tiny_id := 2 - com_api_const_pkg.ONE_SECOND;
    RECORDS_LIMIT            constant  pls_integer                := 1000;

    l_sysdate                          date;
    l_name                             com_api_type_pkg.t_name;
    l_search_param_list                com_api_type_pkg.t_full_desc;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    o_param_rec.tab_name      := i_tab_name;
    o_param_rec.records_limit := nvl(
                                     set_ui_value_pkg.get_inst_param_n(
                                         i_param_name => 'OPERATIONS_SEARCH_RESULT_MAX_RECORDS'
                                       , i_inst_id    => com_ui_user_env_pkg.get_user_inst
                                     )
                                   , RECORDS_LIMIT
                                 );

    l_search_param_list := 'tab_name [' || o_param_rec.tab_name || '], records_limit [' || o_param_rec.records_limit || ']';

    if i_param_tab is not null then
        for i in 1 .. i_param_tab.count loop
            l_name := upper(i_param_tab(i).name);

            if i_param_tab(i).number_value  is not null then
              l_search_param_list := l_search_param_list || ', ' || l_name || '(number)=[' || to_char(i_param_tab(i).number_value) || ']';
            elsif i_param_tab(i).char_value is not null then
              l_search_param_list := l_search_param_list || ', ' || l_name || '(char)=[' || i_param_tab(i).char_value || ']';
            elsif i_param_tab(i).date_value is not null then
              l_search_param_list := l_search_param_list || ', ' || l_name || '(date)=[' || to_char(i_param_tab(i).date_value, com_api_const_pkg.LOG_DATE_FORMAT) || ']';
            end if;

            -- Global search mode:
            if    l_name = 'PARTICIPANT_MODE'    then  o_param_rec.participant_mode    := i_param_tab(i).char_value;
            elsif l_name = 'IS_H2H_OPERATIONS'   then  o_param_rec.is_h2h_operations   := i_param_tab(i).number_value;
            elsif l_name = 'PRIVIL_LIMITATION'   then  o_param_rec.privil_limitation   := i_param_tab(i).char_value;

            -- Common search values (left column):
            elsif l_name = 'HOST_DATE_FROM'      then  o_param_rec.host_date_from      := i_param_tab(i).date_value;
            elsif l_name = 'HOST_DATE_TILL'      then  o_param_rec.host_date_till      := i_param_tab(i).date_value;
            elsif l_name = 'STATUS'              then  o_param_rec.status              := i_param_tab(i).char_value;
            elsif l_name = 'STATUS_REASON'       then  o_param_rec.status_reason       := i_param_tab(i).char_value;
            elsif l_name = 'MSG_TYPE'            then  o_param_rec.msg_type            := i_param_tab(i).char_value;
            elsif l_name = 'STTL_TYPE'           then  o_param_rec.sttl_type           := i_param_tab(i).char_value;
            elsif l_name = 'STTL_TYPES'          then  o_param_rec.sttl_types          := i_param_tab(i).char_value;
            elsif l_name = 'AUTH_CODE'           then  o_param_rec.auth_code           := i_param_tab(i).char_value;
            elsif l_name = 'IS_REVERSAL'         then  o_param_rec.is_reversal         := i_param_tab(i).number_value;
            elsif l_name = 'TERMINAL_TYPE'       then  o_param_rec.terminal_type       := i_param_tab(i).char_value;
            elsif l_name = 'FE_UTRNNO'           then  o_param_rec.external_auth_id    := i_param_tab(i).char_value;

            -- Common search values (right column):
            elsif l_name = 'OPER_ID'             then  o_param_rec.oper_id             := i_param_tab(i).number_value;
            elsif l_name = 'TERMINAL_NUMBER'     then  o_param_rec.terminal_number     := i_param_tab(i).char_value;
            elsif l_name = 'OPER_TYPE'           then  o_param_rec.oper_type           := i_param_tab(i).char_value;
            elsif l_name = 'SESSION_ID'          then  o_param_rec.session_id          := i_param_tab(i).number_value;
            elsif l_name = 'ORIGINATOR_REFNUM'   then  o_param_rec.originator_refnum   := i_param_tab(i).char_value;    -- RRN
            elsif l_name = 'NETWORK_REFNUM'      then  o_param_rec.network_refnum      := i_param_tab(i).char_value;    -- ARN
            elsif l_name = 'MCC'                 then  o_param_rec.mcc                 := i_param_tab(i).char_value;
            elsif l_name = 'OPER_DATE_FROM'      then  o_param_rec.oper_date_from      := i_param_tab(i).date_value;
            elsif l_name = 'OPER_DATE_TILL'      then  o_param_rec.oper_date_till      := i_param_tab(i).date_value;
            elsif l_name = 'OPER_REASON'         then  o_param_rec.oper_reason         := i_param_tab(i).date_value;

            -- Participant search values:
            elsif l_name = 'PARTICIPANT_TYPE'    then  o_param_rec.participant_type    := i_param_tab(i).char_value;
            elsif l_name = 'CARD_MASK'           then  o_param_rec.card_mask           := i_param_tab(i).char_value;
            elsif l_name = 'CLIENT_ID_VALUE'     then  o_param_rec.client_id_value     := i_param_tab(i).char_value;
            elsif l_name = 'MERCHANT_NAME'       then  o_param_rec.merchant_name       := i_param_tab(i).char_value;
            elsif l_name = 'ACQ_INST_BIN'        then  o_param_rec.acq_inst_bin        := i_param_tab(i).char_value;
            elsif l_name = 'INST_ID'             then  o_param_rec.inst_id             := i_param_tab(i).number_value;
            elsif l_name = 'ACCOUNT_NUMBER'      then  o_param_rec.account_number      := i_param_tab(i).char_value;
            elsif l_name = 'CLIENT_ID_TYPE'      then  o_param_rec.client_id_type      := i_param_tab(i).char_value;
            elsif l_name = 'MERCHANT_NUMBER'     then  o_param_rec.merchant_number     := i_param_tab(i).char_value;
            elsif l_name = 'CARD_TOKEN'          then  o_param_rec.card_token          := i_param_tab(i).char_value;

            -- Tags search values:
            elsif l_name = 'TAG_VALUE'           then  o_param_rec.tag_value           := i_param_tab(i).char_value;
            elsif l_name = 'TAG_ID'              then  o_param_rec.tag_id              := i_param_tab(i).number_value;

            -- Payment order search values:
            elsif l_name = 'PURPOSE_ID'               then  o_param_rec.purpose_id               := i_param_tab(i).number_value;
            elsif l_name = 'CUSTOMER_NUMBER'          then  o_param_rec.sender_customer_number   := upper(i_param_tab(i).char_value);
                                                            o_param_rec.customer_number          := upper(i_param_tab(i).char_value);
            elsif l_name = 'ORDER_STATUS'             then  o_param_rec.order_status             := i_param_tab(i).char_value;
            elsif l_name = 'RECIEVER_CUSTOMER_NUMBER' then  o_param_rec.reciever_customer_number := upper(i_param_tab(i).char_value);

            -- Document search values:
            elsif l_name = 'DOCUMENT_NUMBER'     then  o_param_rec.document_number     := i_param_tab(i).char_value;
            elsif l_name = 'DOCUMENT_DATE'       then  o_param_rec.document_date       := i_param_tab(i).date_value;
            elsif l_name = 'DOCUMENT_TYPE'       then  o_param_rec.document_type       := i_param_tab(i).char_value;

            -- Customer search values:
            elsif l_name = 'CUSTOMER_NUMBER'     then  o_param_rec.customer_number     := upper(i_param_tab(i).char_value);
            elsif l_name = 'CUSTOMER_ID'         then  o_param_rec.customer_id         := i_param_tab(i).number_value;

            -- Card search values:
            elsif l_name = 'CARD_ID'             then  o_param_rec.card_id             := i_param_tab(i).number_value;
            elsif l_name = 'EXPIR_DATE'          then  o_param_rec.card_expir_date     := i_param_tab(i).date_value;

            -- Account search values:
            elsif l_name = 'ACCOUNT_ID'          then  o_param_rec.account_id          := i_param_tab(i).number_value;
            elsif l_name = 'SPLIT_HASH'          then  o_param_rec.split_hash          := i_param_tab(i).number_value;

            end if;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text             => 'Search parameters: ' || l_search_param_list
    );

    o_param_rec.card_mask_postfix := substr(o_param_rec.card_mask, - iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_ENDING);
    o_param_rec.encoded_card_mask := iss_api_token_pkg.encode_card_number(o_param_rec.card_mask);

    select reverse(o_param_rec.card_mask)
         , reverse(o_param_rec.encoded_card_mask)
      into o_param_rec.reversed_card_mask
         , o_param_rec.encoded_card_mask
      from dual;

    -- Get partition key restriction
    if o_param_rec.host_date_from is null then
        o_param_rec.host_date_from := trunc(l_sysdate) - LAST_WEEK_OFFSET;
    end if;
    if o_param_rec.host_date_till is null then
        o_param_rec.host_date_till := trunc(l_sysdate) + END_OF_TOMORROW_OFFSET;
    end if;

    o_param_rec.host_id_from := com_api_id_pkg.get_from_id(
                                    i_date => o_param_rec.host_date_from
                                );
    o_param_rec.host_id_till := com_api_id_pkg.get_from_id(
                                    i_date => o_param_rec.host_date_till + com_api_id_pkg.TILL_ID_OFFSET + 1
                                );

    trc_log_pkg.debug(
        i_text             => 'Partition key restrictions: host_date_from [#1], host_date_till [#2], host_id_from [#3], host_id_till [#4], reversed_card_mask [#5], card_mask_postfix [#6]'
      , i_env_param1       =>  to_char(o_param_rec.host_date_from, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param2       =>  to_char(o_param_rec.host_date_till, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3       =>  o_param_rec.host_id_from
      , i_env_param4       =>  o_param_rec.host_id_till
      , i_env_param5       =>  o_param_rec.reversed_card_mask
      , i_env_param6       =>  o_param_rec.card_mask_postfix
    );

end get_search_param;

procedure check_search_param(
    io_param_rec  in out nocopy t_search_param_rec
) is
begin
    -- Some preventive/initial checks
    case
        when io_param_rec.tab_name = 'DOCUMENT' then
            if io_param_rec.document_number is null or io_param_rec.document_date is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
                  , i_env_param1 => case when io_param_rec.document_number is null then 'DOCUMENT_NUMBER'
                                         when io_param_rec.document_date is null   then 'DOCUMENT_DATE'
                                    end
                );
            end if;
        when io_param_rec.tab_name = 'TAG' then
            if io_param_rec.tag_id is null or io_param_rec.tag_value is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
                  , i_env_param1 => case when io_param_rec.tag_id is null    then 'TAG_ID'
                                         when io_param_rec.tag_value is null then 'TAG_VALUE'
                                    end
                );
            end if;
        when io_param_rec.tab_name not in ('CARD') then
            if io_param_rec.participant_mode is null
               and nvl(io_param_rec.is_h2h_operations, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
            then
                com_api_error_pkg.raise_error(
                    i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
                  , i_env_param1 => 'PARTICIPANT_MODE'
                );
            elsif io_param_rec.oper_id            is null
                  and io_param_rec.session_id     is null
                  and io_param_rec.host_date_from is null
            then
                com_api_error_pkg.raise_error(
                    i_error => 'NOT_ENOUGH_DATA_TO_FIND_OPERATIONS'
                );
            end if;
        else
            null; -- checks for i_tab_name in ('CARD') are defined below
    end case;

    if io_param_rec.tab_name = 'CARD' and io_param_rec.card_id is null then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ENOUGH_DATA_TO_FIND_OPERATIONS'
        );
    end if;

    if io_param_rec.tab_name = 'ACCOUNT' and io_param_rec.account_id is null then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ENOUGH_DATA_TO_FIND_OPERATIONS'
        );
    end if;

end check_search_param;

-- You can run this method and see the result query for dynamic SQL for the operation search.
procedure get_query_statement(
    io_param_rec     in out nocopy  t_search_param_rec
  , o_sql_statement     out nocopy  com_api_type_pkg.t_sql_statement
) is
    LOG_PREFIX       constant   com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_query_statement';
    --TILL_DATE_LAG  constant   pls_integer := 14;

    l_from                      com_api_type_pkg.t_text;
    l_where                     com_api_type_pkg.t_text;
    l_use_id_interval           com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE;
    l_use_iss_participant       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_use_acq_participant       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_use_aut_auth              com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_use_pmo_order             com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_use_evt_status_log        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_use_participant_columns   com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_participant_alias         com_api_type_pkg.t_oracle_name; -- alias for table OPR_PARTICIPANT
    l_tag_id                    com_api_type_pkg.t_short_id;

    COLUMN_LIST                 constant com_api_type_pkg.t_text :=
       'select /*+first_rows*/'
        ||   ' op.id';

    PARAMETER_STATEMENT         constant com_api_type_pkg.t_text :=
        '(select'
               -- Global search mode:
        ||  '  :tab_name as tab_name'
        ||  ', :participant_mode as participant_mode'
        ||  ', :host_id_from as host_id_from'
        ||  ', :host_id_till as host_id_till'
        ||  ', :records_limit as records_limit'
               -- Common search values (left column):
        ||  ', :host_date_from as host_date_from'
        ||  ', :host_date_till as host_date_till'
        ||  ', :status as status'
        ||  ', :status_reason as status_reason'
        ||  ', :msg_type as msg_type'
        ||  ', :sttl_type as sttl_type'
        ||  ', :auth_code as auth_code'
        ||  ', :is_reversal as is_reversal'
        ||  ', :terminal_type as terminal_type'
        ||  ', :external_auth_id as external_auth_id'
               -- Common search values (right column):
        ||  ', :oper_id as oper_id'
        ||  ', :terminal_number as terminal_number'
        ||  ', :oper_type as oper_type'
        ||  ', :session_id as session_id'
        ||  ', :originator_refnum as originator_refnum'  -- RRN
        ||  ', :network_refnum as network_refnum'        -- ARN
        ||  ', :mcc as mcc'
        ||  ', :oper_date_from as oper_date_from'
        ||  ', :oper_date_till as oper_date_till'
        ||  ', :oper_reason as oper_reason'
               -- Participant search values:
        ||  ', :participant_type as participant_type'
        ||  ', :card_mask as card_mask'
        ||  ', :card_mask_postfix as card_mask_postfix'
        ||  ', :reversed_card_mask as reversed_card_mask'
        ||  ', :encoded_card_mask as encoded_card_mask'
        ||  ', :client_id_value as client_id_value'
        ||  ', :merchant_name as merchant_name'
        ||  ', :acq_inst_bin as acq_inst_bin'
        ||  ', :inst_id as inst_id'
        ||  ', :account_number as account_number'
        ||  ', :client_id_type as client_id_type'
        ||  ', :merchant_number as merchant_number'
        ||  ', :card_token as card_token'
               -- Tags search values:
        ||  ', :tag_value as tag_value'
        ||  ', :tag_id as tag_id'
               -- Payment order search values:
        ||  ', :purpose_id as purpose_id'
        ||  ', :sender_customer_number as sender_customer_number'
        ||  ', :order_status as order_status'
        ||  ', :reciever_customer_number as reciever_customer_number'
               -- Document search values:
        ||  ', :document_number as document_number'
        ||  ', :document_date as document_date'
        ||  ', :document_type as document_type'
               -- Customer search values:
        ||  ', :customer_number as customer_number'
        ||  ', :customer_id as customer_id'
               -- Card search values:
        ||  ', :card_id as card_id'
        ||  ', :card_expir_date as card_expir_date'
               -- Account search values:
        ||  ', :account_id as account_id'
        ||  ', :split_hash as split_hash'
        ||  ' from dual) x'
    ;
begin
    trc_log_pkg.debug(LOG_PREFIX || ': START with tab_name [' || io_param_rec.tab_name || ']');

    check_search_param(
        io_param_rec  =>  io_param_rec
    );

    if io_param_rec.is_h2h_operations = com_api_type_pkg.TRUE then
        l_use_iss_participant := com_api_type_pkg.TRUE;
        l_use_acq_participant := com_api_type_pkg.TRUE;
        l_where := l_where         || ' and (i.inst_id is null or i.inst_id in (select inst_id from acm_cu_inst_vw))';
        l_where := l_where         || ' and (a.inst_id is null or a.inst_id in (select inst_id from acm_cu_inst_vw))';

    elsif io_param_rec.participant_mode = com_api_const_pkg.PARTICIPANT_ISSUER then
        l_use_iss_participant := com_api_type_pkg.TRUE;
        l_participant_alias   := 'i';
        l_where := l_where         || ' and (i.inst_id is null or i.inst_id in (select inst_id from acm_cu_inst_vw))';

    elsif io_param_rec.participant_mode = com_api_const_pkg.PARTICIPANT_ACQUIRER then
        l_use_acq_participant := com_api_type_pkg.TRUE;
        l_participant_alias   := 'a';
        l_where := l_where         || ' and (a.inst_id is null or a.inst_id in (select inst_id from acm_cu_inst_vw))';

    else
        -- PRTYISS is meant as a default value for tabs CARD and ACCOUNT
        l_use_iss_participant := com_api_type_pkg.TRUE;
        l_participant_alias   := 'i';
        l_where := l_where         || ' and x.tab_name in (''ACCOUNT'', ''CARD'')';

    end if;

    if io_param_rec.oper_id is not null then
        l_where := l_where         || ' and op.id = x.oper_id';
    else
        -- host_date_from, host_date_till is mandatory parameters
        l_where := l_where         || ' and op.host_date between x.host_date_from and x.host_date_till';

        -- Important: Use index by "originator_refnum"
        if io_param_rec.originator_refnum is not null then
            l_where := l_where     || ' and op.originator_refnum = x.originator_refnum';
        end if;

        -- Important: Use index by "network_refnum"
        if io_param_rec.network_refnum is not null then
            l_where := l_where     || ' and op.network_refnum = x.network_refnum';
        end if;

        -- Important: Use index by "customer_id"
        if io_param_rec.customer_id is not null then
            if io_param_rec.is_h2h_operations = com_api_type_pkg.TRUE then
                l_where := l_where     || ' and x.customer_id in (i.customer_id, a.customer_id)';
            else
                l_where := l_where     || ' and ' || l_participant_alias || '.customer_id = x.customer_id';
            end if;
        end if;

        if io_param_rec.customer_number is not null then
            if io_param_rec.is_h2h_operations = com_api_type_pkg.TRUE then
                l_where := l_where     || ' and ('
                                       || case -- Don't use index by "customer_id" for this condition
                                              when io_param_rec.customer_id is not null
                                              then 'i.customer_id+0'
                                              else 'i.customer_id'
                                          end
                                       || ' in (select pc.id'
                                       ||       ' from prd_customer pc'
                                       ||      ' where reverse(pc.customer_number) = reverse(x.customer_number))'
                                       || ' or '
                                       || case -- Don't use index by "customer_id" for this condition
                                              when io_param_rec.customer_id is not null
                                              then 'a.customer_id+0'
                                              else 'a.customer_id'
                                          end
                                       || ' in (select pc.id'
                                       ||       ' from prd_customer pc'
                                       ||      ' where reverse(pc.customer_number) = reverse(x.customer_number))'
                                       || ' )'
                                       ;
            else
                l_where := l_where     || ' and ' || l_participant_alias
                                       || case -- Don't use index by "customer_id" for this condition
                                              when io_param_rec.customer_id is not null
                                              then '.customer_id+0'
                                              else '.customer_id'
                                          end
                                       || ' in (select pc.id'
                                       ||       ' from prd_customer pc'
                                       ||      ' where reverse(pc.customer_number) = reverse(x.customer_number))';
            end if;
        end if;

        if io_param_rec.oper_date_from is not null then
            l_where := l_where     || ' and op.oper_date >= x.oper_date_from';
        end if;

        if io_param_rec.oper_date_till is not null then
            l_where := l_where     || ' and op.oper_date <= x.oper_date_till';
        end if;

        if io_param_rec.oper_reason is not null then
            l_where := l_where || ' and op.oper_reason like x.oper_reason';
        end if;

        if io_param_rec.auth_code is not null then
            if io_param_rec.is_h2h_operations = com_api_type_pkg.TRUE then
                l_where := l_where     || ' and x.auth_code in (i.auth_code, a.auth_code)';
            else
                l_where := l_where     || ' and ' || l_participant_alias || '.auth_code = x.auth_code';
            end if;
        end if;

        if io_param_rec.session_id is not null then
            l_use_evt_status_log := com_api_type_pkg.TRUE;
            l_where := l_where     || ' and sl.session_id = x.session_id'
                                   || ' and sl.entity_type = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || ''''
                                   || ' and op.id = sl.object_id';
        end if;

        if io_param_rec.tab_name not in ('ACCOUNT', 'CARD') then -- Operations tab

            -- Connect to "aut_auth" table
            if io_param_rec.external_auth_id is not null
               or io_param_rec.status_reason is not null
            then
                l_use_aut_auth := com_api_type_pkg.TRUE;

                -- Important: Use index by "external_auth_id".
                if io_param_rec.external_auth_id is not null then
                    l_where := l_where || ' and auth.id = op.id';
                    if instr(io_param_rec.external_auth_id, '%') > 0 then
                        l_where := l_where || ' and auth.external_auth_id like x.external_auth_id';
                    else
                        l_where := l_where || ' and auth.external_auth_id = x.external_auth_id';
                    end if;
                    l_use_id_interval  := com_api_type_pkg.FALSE;
                else
                    l_where := l_where || ' and auth.id(+) = op.id';
                end if;

                if io_param_rec.status_reason is not null then
                    l_where := l_where || ' and (case op.status_reason when cast(''' || aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE
                                       ||                            ''' as varchar2(8)) then auth.resp_code else op.status_reason end) = x.status_reason';
                end if;
            end if;

            if io_param_rec.merchant_number is not null then
                l_where := l_where || ' and op.merchant_number like x.merchant_number';
            end if;
            if io_param_rec.terminal_number is not null then
                l_where := l_where || ' and op.terminal_number like x.terminal_number';
            end if;
            if io_param_rec.merchant_name is not null then
                l_where := l_where || ' and op.merchant_name like x.merchant_name';
            end if;
            if io_param_rec.oper_type is not null then
                l_where := l_where || ' and op.oper_type = x.oper_type';
            end if;
            if io_param_rec.status is not null then
                l_where := l_where || ' and op.status = x.status';
            end if;
            if io_param_rec.is_reversal is not null then
                l_where := l_where || ' and op.is_reversal = x.is_reversal';
            end if;
            if io_param_rec.msg_type is not null then
                l_where := l_where || ' and op.msg_type = x.msg_type';
            end if;
            if io_param_rec.sttl_type is not null then
                l_where := l_where || ' and op.sttl_type = x.sttl_type';
            end if;
            if io_param_rec.sttl_types is not null then
                l_where := l_where || ' and op.sttl_type in (''' || io_param_rec.sttl_types || ''')';
            end if;
            if io_param_rec.terminal_type is not null then
                l_where := l_where || ' and op.terminal_type = x.terminal_type';
            end if;
            if io_param_rec.mcc is not null then
                l_where := l_where || ' and op.mcc = x.mcc';
            end if;

        end if;

        if io_param_rec.tab_name = 'DOCUMENT' then
            l_where := l_where ||
                ' and op.id in (select m.object_id from acc_ui_macros_vw m'           ||
                               ' where m.entity_type = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION  || '''' ||
                                 ' and m.object_id between x.host_id_from and x.host_id_till' ||
                                 ' and id in (select t.macros_id'                     ||
                                              ' from acc_ui_transaction_vw t, rpt_ui_document_vw d' ||
                                             ' where t.transaction_id = d.object_id'  ||
                                               ' and d.entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_TRANSACTION || '''';

            if io_param_rec.document_number is not null then
                l_where := l_where || ' and d.document_number like x.document_number';
            end if;
            if io_param_rec.document_date is not null then
                l_where := l_where || ' and d.document_date = x.document_date';
            end if;
            if io_param_rec.document_type is not null then
                l_where := l_where || ' and d.document_type = x.document_type';
            end if;

            l_where := l_where     || '))';

        elsif io_param_rec.tab_name = 'PAYMENT_ORDER' then

            l_use_pmo_order := com_api_type_pkg.TRUE;
            l_where := l_where     || ' and op.payment_order_id = o.id';

            if io_param_rec.order_status is not null then
                l_where := l_where || ' and o.status = x.order_status';
            end if;
            if io_param_rec.purpose_id is not null then
                l_where := l_where || ' and o.purpose_id = x.purpose_id';
            end if;

            if io_param_rec.sender_customer_number is not null then
                l_where := l_where
                    || ' and op.id in (select pt.oper_id from opr_ui_participant_vw pt'
                    ||                ' where reverse(pt.customer_number) like reverse(x.sender_customer_number)'
                    ||                  ' and pt.oper_id between x.host_id_from and x.host_id_till'
                    ||                  ' and pt.participant_type = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''')';
            end if;

            if io_param_rec.reciever_customer_number is not null then
                l_where := l_where
                    || ' and op.id in (select pt.oper_id from opr_ui_participant_vw pt'
                    ||                ' where reverse(pt.customer_number) like reverse(x.reciever_customer_number)'
                    ||                  ' and pt.oper_id between x.host_id_from and x.host_id_till'
                    ||                  ' and pt.participant_type = ''' || com_api_const_pkg.PARTICIPANT_DEST || ''')';
            end if;

        elsif io_param_rec.tab_name in ('PARTICIPANT', 'DISPUTE', 'ORIGINAL_CASE_OPERATIONS') then

            if io_param_rec.card_mask           is not null
               or io_param_rec.participant_type is not null
               or io_param_rec.inst_id          is not null
               or io_param_rec.account_id       is not null
               or io_param_rec.client_id_type   is not null
               or io_param_rec.client_id_value  is not null
            then
                if io_param_rec.card_mask             is not null then
                    l_use_id_interval  := com_api_type_pkg.FALSE;

                   if io_param_rec.inst_id             is null
                      and io_param_rec.account_id      is null
                      and io_param_rec.client_id_type  is null
                      and io_param_rec.client_id_value is null
                   then
                       -- Case when card_mask is filled and participant columns is not filled
                       l_where := l_where      || ' and op.id in (select c.oper_id from opr_card c where 1 = 1';

                       if io_param_rec.participant_type is not null then
                           l_where := l_where  || ' and c.participant_type = x.participant_type';
                       end if;
                   else
                       -- Case when card_mask and participant columns is filled
                       l_use_participant_columns := com_api_type_pkg.TRUE;

                       l_where := l_where      || ' and op.id in (select p.oper_id from opr_participant p, opr_card c';
                       l_where := l_where      || ' where c.oper_id = p.oper_id';
                       l_where := l_where      || ' and c.participant_type = p.participant_type';

                       if io_param_rec.participant_type is not null then
                           l_where := l_where  || ' and c.participant_type = x.participant_type';
                       end if;
                   end if;
                else
                    -- Case when card_mask is not filled and participant columns is filled
                    l_use_participant_columns := com_api_type_pkg.TRUE;

                    l_where := l_where         || ' and op.id in (select p.oper_id from opr_participant p where 1 = 1';
                end if;

                -- Prefix for Card mask is filled
                if io_param_rec.card_mask_postfix is not null then
                    if instr(io_param_rec.card_mask_postfix, '%') = 0 then
                        l_where := l_where         || ' and c.card_number_postfix = x.card_mask_postfix';
                    else
                        l_where := l_where         || ' and c.card_number_postfix like x.card_mask_postfix';
                    end if;

                    if iss_api_token_pkg.is_token_enabled = com_api_type_pkg.FALSE then
                        if instr(io_param_rec.reversed_card_mask, '%') = 0 then
                            l_where := l_where || ' and reverse(c.card_number) = x.reversed_card_mask';
                        else
                            l_where := l_where || ' and reverse(c.card_number) like x.reversed_card_mask';
                        end if;
                    else
                        if instr(io_param_rec.reversed_card_mask, '%') = 0 then
                            l_where := l_where || ' and reverse(c.card_number) = x.encoded_card_mask';
                        else
                            l_where := l_where || ' and reverse(iss_api_token_pkg.decode_card_number(c.card_number)) like x.reverse_card_mask';
                        end if;
                    end if;
                end if;

                -- Search with opr_participant columns
                if l_use_participant_columns = com_api_type_pkg.TRUE then
                    if io_param_rec.inst_id is not null then
                        l_where := l_where     || ' and p.inst_id = x.inst_id';
                    end if;
                    if io_param_rec.participant_type is not null then
                        l_where := l_where     || ' and p.participant_type = x.participant_type';
                    end if;
                    if io_param_rec.account_id is not null then
                        l_use_id_interval    := com_api_type_pkg.FALSE;

                        -- Use local index for "account_id" together with its partition key and subpartition key
                        l_where := l_where     || ' and p.account_id = x.account_id';
                        l_where := l_where     || ' and p.part_key between x.host_date_from and x.host_date_till';
                        l_where := l_where     || ' and p.split_hash = x.split_hash';
                    end if;
                    if io_param_rec.client_id_type is not null then
                        l_where := l_where     || ' and p.client_id_type = x.client_id_type';
                    end if;
                    if io_param_rec.client_id_value is not null then
                        if instr(io_param_rec.client_id_value, '%') = 0 then
                            l_where := l_where || ' and p.client_id_value = x.client_id_value';
                        else
                            l_where := l_where || ' and p.client_id_value like x.client_id_value';
                        end if;
                    end if;
                end if;

                l_where := l_where         || ')';
            end if;

            -- Search with authorization tag DF8765 (CARD_TOKEN)
            if io_param_rec.card_token is not null then
                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8765');  -- CARD_TOKEN

                if instr(io_param_rec.card_token, '%') = 0 then
                    l_where := l_where     || ' and exists (select 1 from aup_tag_value v where v.auth_id = op.id and v.tag_id = ' || to_char(l_tag_id)
                                           || ' and nvl(v.seq_number, 1) = 1 and v.tag_value = x.card_token)';
                else
                    l_where := l_where     || ' and exists (select 1 from aup_tag_value v where v.auth_id = op.id and v.tag_id = ' || to_char(l_tag_id)
                                           || ' and nvl(v.seq_number, 1) = 1 and v.tag_value like x.card_token)';
                end if;
            end if;

        elsif io_param_rec.tab_name = 'CARD' then
            l_use_id_interval  := com_api_type_pkg.FALSE;
            l_use_iss_participant := com_api_type_pkg.TRUE;

            -- x.card_id is mandatory parameter
            l_where := l_where     || ' and i.card_id = x.card_id';

            if io_param_rec.card_expir_date is not null then
                l_where := l_where || ' and i.card_expir_date = x.card_expir_date';
            end if;

        elsif io_param_rec.tab_name = 'ACCOUNT' then
            l_use_id_interval  := com_api_type_pkg.FALSE;

            -- x.account_id is mandatory parameter
            if io_param_rec.is_h2h_operations = com_api_type_pkg.TRUE then
                l_where := l_where     || ' and x.account_id in (i.account_id, a.account_id)';
            else
                l_where := l_where     || ' and ' || l_participant_alias || '.account_id = x.account_id';
            end if;

        elsif io_param_rec.tab_name = 'TAG' then
            l_where := l_where     || ' and op.id in (select auth_id from aup_tag_value atv where 1 = 1';
            l_where := l_where     ||                  ' and atv.tag_id = x.tag_id';
            l_where := l_where     ||                  ' and atv.tag_value like x.tag_value';
            l_where := l_where     ||                  ' and atv.auth_id between x.host_id_from and x.host_id_till';
            l_where := l_where     ||                ')';

        end if;

        -- Important: Use the "partition key interval" when is missed the good index search by "id" in "opr_operation" table.
        -- host_id_from, host_id_till is mandatory parameters.
        if l_use_id_interval = com_api_type_pkg.TRUE then
            l_where := l_where     || ' and op.id between x.host_id_from and x.host_id_till';
        end if;

    end if;

    if io_param_rec.privil_limitation is not null then
        l_where := l_where         || ' and (' || io_param_rec.privil_limitation || ')';
    end if;

    if l_use_acq_participant = com_api_type_pkg.TRUE then
      l_where := l_where           || ' and a.oper_id(+) = op.id'
                                   || ' and a.participant_type(+) = ''' || com_api_const_pkg.PARTICIPANT_ACQUIRER || '''';
    end if;

    if l_use_iss_participant = com_api_type_pkg.TRUE then
      l_where := l_where           || ' and i.oper_id(+) = op.id'
                                   || ' and i.participant_type(+) = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || '''';
    end if;

    l_where := l_where             || ' and rownum <= x.records_limit';

    l_from :=
            case when l_use_acq_participant = com_api_type_pkg.TRUE then ', opr_participant a' else null end
        ||  case when l_use_iss_participant = com_api_type_pkg.TRUE then ', opr_participant i' else null end
        ||  ', opr_operation op'
        ||  case when l_use_evt_status_log  = com_api_type_pkg.TRUE then ', evt_status_log sl' else null end
        ||  case when l_use_pmo_order       = com_api_type_pkg.TRUE then ', pmo_order o'       else null end
        ||  case when l_use_aut_auth        = com_api_type_pkg.TRUE then ', aut_auth auth'     else null end
        ||  ', ' || PARAMETER_STATEMENT
    ;

    -- Remove ", " from 'l_from' variable and remove " and " from 'l_where' variable.
    o_sql_statement := COLUMN_LIST || ' from ' || substr(l_from, 3) || ' where ' || substr(l_where, 5);

    trc_log_pkg.debug(LOG_PREFIX || ': END o_sql_statement [' || substr(o_sql_statement, 1, 3900) || ']');

end get_query_statement;

procedure read_object_list(
    io_param_rec      in out nocopy  t_search_param_rec
  , io_sql_statement  in out nocopy  com_api_type_pkg.t_sql_statement
) is
    LOG_PREFIX        constant       com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.read_object_list';
    l_oper_cur        sys_refcursor;
begin
    trc_log_pkg.debug(LOG_PREFIX || ': Start');

    g_object_id_tab.delete;

    open l_oper_cur for io_sql_statement
      using
            -- Global search mode:
            io_param_rec.tab_name
          , io_param_rec.participant_mode
          , io_param_rec.host_id_from
          , io_param_rec.host_id_till
          , io_param_rec.records_limit
            -- Common search values (left column):
          , io_param_rec.host_date_from
          , io_param_rec.host_date_till
          , io_param_rec.status
          , io_param_rec.status_reason
          , io_param_rec.msg_type
          , io_param_rec.sttl_type
          , io_param_rec.auth_code
          , io_param_rec.is_reversal
          , io_param_rec.terminal_type
          , io_param_rec.external_auth_id
            -- Common search values (right column):
          , io_param_rec.oper_id
          , io_param_rec.terminal_number
          , io_param_rec.oper_type
          , io_param_rec.session_id
          , io_param_rec.originator_refnum  -- RRN
          , io_param_rec.network_refnum     -- ARN
          , io_param_rec.mcc
          , io_param_rec.oper_date_from
          , io_param_rec.oper_date_till
          , io_param_rec.oper_reason
            -- Participant search values:
          , io_param_rec.participant_type
          , io_param_rec.card_mask
          , io_param_rec.card_mask_postfix
          , io_param_rec.reversed_card_mask
          , io_param_rec.encoded_card_mask
          , io_param_rec.client_id_value
          , io_param_rec.merchant_name
          , io_param_rec.acq_inst_bin
          , io_param_rec.inst_id
          , io_param_rec.account_number
          , io_param_rec.client_id_type
          , io_param_rec.merchant_number
          , io_param_rec.card_token
            -- Tags search values:
          , io_param_rec.tag_value
          , io_param_rec.tag_id
            -- Payment order search values:
          , io_param_rec.purpose_id
          , io_param_rec.sender_customer_number
          , io_param_rec.order_status
          , io_param_rec.reciever_customer_number
            -- Document search values:
          , io_param_rec.document_number
          , io_param_rec.document_date
          , io_param_rec.document_type
            -- Customer search values:
          , io_param_rec.customer_number
          , io_param_rec.customer_id
            -- Card search values:
          , io_param_rec.card_id
          , io_param_rec.card_expir_date
            -- Account search values:
          , io_param_rec.account_id
          , io_param_rec.split_hash
         ;

    trc_log_pkg.debug(LOG_PREFIX || ': After open cursor');

    fetch l_oper_cur bulk collect into g_object_id_tab limit io_param_rec.records_limit;

    trc_log_pkg.debug(LOG_PREFIX || ': Finish');

end read_object_list;

procedure read_object_info(
    i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_sorting_tab       in      com_param_map_tpt
) is
    LOG_PREFIX        constant  com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.read_object_info';
    l_oper_cur                  sys_refcursor;
    l_oper_tab                  t_oper_tab;
    l_sql_statement             com_api_type_pkg.t_sql_statement;
    l_index                     com_api_type_pkg.t_short_id;
    l_last_records_limit        com_api_type_pkg.t_medium_id;

    l_reversal_exists           com_api_type_pkg.t_boolean;
    l_client_id_type            com_api_type_pkg.t_dict_value;
    l_client_id_value           com_api_type_pkg.t_name;
    l_iss_card_mask             com_api_type_pkg.t_card_number;
    l_iss_card_id               com_api_type_pkg.t_medium_id;
    l_iss_card_token            com_api_type_pkg.t_card_number;
    l_tag_id                    com_api_type_pkg.t_short_id;

    COLUMN_LIST      constant   com_api_type_pkg.t_text :=
             ' op.id'
        ||  ', op.session_id'
        ||  ', op.is_reversal'
        ||  ', op.original_id'
        ||  ', op.oper_type'
        ||  ', op.oper_reason'
        ||  ', op.msg_type'
        ||  ', op.status'
        ||  ', case op.status_reason'
        ||  '      when ''' || aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE || ''' then ('
        ||  '          select a.resp_code'
        ||  '            from aut_auth a'
        ||  '           where a.id = op.id'
        ||  '      )'
        ||  '      else op.status_reason'
        ||  '  end status_reason'
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
        ||  ', i.auth_code'
        ||  ', i.inst_id iss_inst_id'
        ||  ', i.network_id iss_network_id'
        ||  ', i.card_network_id card_network_id'
        ||  ', a.inst_id acq_inst_id'
        ||  ', a.network_id acq_network_id'
        ||  ', i.client_id_type iss_client_id_type'
        ||  ', i.client_id_value iss_client_id_value'
        ||  ', (select cast(oc.card_number as varchar2(24))'
        ||      ' from opr_card oc'
        ||     ' where oc.oper_id(+) = i.oper_id'
        ||       ' and oc.participant_type(+) = i.participant_type'
        ||   ' ) as iss_card_number'      -- PAN isn't displayed on GUI - only its mask
        ||  ', a.client_id_type acq_client_id_type'
        ||  ', a.client_id_value acq_client_id_value'
        ||  ', null as acq_card_number'
        ||  ', i.account_number as iss_account_number'
        ||  ', a.account_number as acq_account_number'
        ||  ', null as mcc_id'
        ||  ', auth.external_auth_id'
        ||  ', null as iss_card_token'    -- Card token isn't displayed on GUI
    ;
begin
    g_object_list_tab.delete;

    l_last_records_limit := g_object_id_tab.count;
    trc_log_pkg.debug(LOG_PREFIX || ': l_last_records_limit [' || l_last_records_limit || ']');

    if l_last_records_limit > 0 then

        -- Concatenation with "l_last_records_limit" is need for query optimization
        l_sql_statement :=
            'select o.*'
            || ' from ('
            ||      'select t.*'
            ||           ', row_number() over (' || com_ui_object_search_pkg.get_sorting_clause(i_sorting_tab, com_api_type_pkg.TRUE) || ') as rn '
            ||       ' from ('
            ||          'select'
            ||                  COLUMN_LIST
            ||               ' from aut_auth auth'
            ||               ', opr_participant a'
            ||               ', opr_participant i'
            ||               ', opr_operation op'
            ||          ' where op.id in (select column_value from table(cast(opr_ui_operation_search_pkg.get_cached_object_id as num_tab_tpt)) where rownum <= ' || l_last_records_limit || ')'
            ||            ' and auth.id(+) = op.id'
            ||            ' and i.oper_id(+) = op.id'
            ||            ' and i.participant_type(+) = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''''
            ||            ' and a.oper_id(+) = op.id'
            ||            ' and a.participant_type(+) = ''' || com_api_const_pkg.PARTICIPANT_ACQUIRER || ''''
            ||  ') t) o'
            || ' where o.rn between ' || i_first_row || ' and ' || i_last_row
            || ' order by o.rn'
        ;

        trc_log_pkg.debug(LOG_PREFIX || ': l_sql_statement [' || substr(l_sql_statement, 1, 3900) || ']');

        open l_oper_cur for l_sql_statement;

        trc_log_pkg.debug(LOG_PREFIX || ': after open cursor');

        fetch l_oper_cur bulk collect into l_oper_tab limit l_last_records_limit;

        trc_log_pkg.debug(LOG_PREFIX || ': after fetch cursor');

        for i in 1 .. l_oper_tab.count loop

            g_object_list_tab.extend;
            l_index := g_object_list_tab.count;

            -- Get "reversal_exists" flag
            begin
                select 1
                  into l_reversal_exists
                  from opr_operation r
                     , aut_auth t
                 where r.original_id = l_oper_tab(i).id
                   and r.is_reversal = com_api_type_pkg.TRUE
                   and t.id(+) = r.id
                   and case r.status_reason
                           when aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE
                           then t.resp_code
                           else nvl(r.status_reason, aup_api_const_pkg.RESP_CODE_OK)
                       end     = aup_api_const_pkg.RESP_CODE_OK
                   and rownum  = 1;

            exception
                when no_data_found then
                    l_reversal_exists := com_api_type_pkg.FALSE;
            end;

            -- Get client_id_type and client_id_value
            l_iss_card_mask   := iss_api_card_pkg.get_card_mask(l_oper_tab(i).iss_card_number);
            l_client_id_type  := coalesce(l_oper_tab(i).iss_client_id_type, l_oper_tab(i).acq_client_id_type);
            l_client_id_value := coalesce(
                                     case l_oper_tab(i).iss_client_id_type
                                          when opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                                          then l_oper_tab(i).iss_account_number
                                          when opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                          then l_iss_card_mask
                                          else l_oper_tab(i).iss_client_id_value
                                     end
                                   , case l_oper_tab(i).acq_client_id_type
                                         when opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                                         then l_oper_tab(i).acq_account_number
                                         when opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                         then null      -- "iss_api_card_pkg.get_card_mask(o.acq_card_number)" is null always yet
                                         else l_oper_tab(i).acq_client_id_value
                                     end
                                 );
            l_iss_card_id     := iss_api_card_pkg.get_card_id(l_oper_tab(i).iss_card_number);
            l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8765');  -- CARD_TOKEN
            l_iss_card_token  := aup_api_tag_pkg.get_tag_value(i_auth_id => l_oper_tab(i).id, i_tag_id => l_tag_id);

            -- Get row
            g_object_list_tab(l_index) := opr_ui_operation_list_tpr(
                                              l_oper_tab(i).id
                                            , l_oper_tab(i).session_id
                                            , l_oper_tab(i).is_reversal
                                            , l_oper_tab(i).original_id
                                            , l_oper_tab(i).oper_type
                                            , l_oper_tab(i).oper_reason
                                            , l_oper_tab(i).msg_type
                                            , l_oper_tab(i).status
                                            , l_oper_tab(i).status_reason
                                            , l_oper_tab(i).sttl_type
                                            , l_oper_tab(i).sttl_amount
                                            , l_oper_tab(i).sttl_currency
                                            , l_oper_tab(i).acq_inst_bin
                                            , l_oper_tab(i).forw_inst_bin
                                            , l_oper_tab(i).terminal_number
                                            , l_oper_tab(i).terminal_type
                                            , l_oper_tab(i).merchant_number
                                            , l_oper_tab(i).merchant_name
                                            , l_oper_tab(i).merchant_street
                                            , l_oper_tab(i).merchant_city
                                            , l_oper_tab(i).merchant_region
                                            , l_oper_tab(i).merchant_country
                                            , l_oper_tab(i).merchant_postcode
                                            , l_oper_tab(i).mcc
                                            , l_oper_tab(i).originator_refnum
                                            , l_oper_tab(i).network_refnum
                                            , l_oper_tab(i).oper_count
                                            , l_oper_tab(i).oper_request_amount
                                            , l_oper_tab(i).oper_amount_algorithm
                                            , l_oper_tab(i).oper_amount
                                            , l_oper_tab(i).oper_currency
                                            , l_oper_tab(i).oper_cashback_amount
                                            , l_oper_tab(i).oper_replacement_amount
                                            , l_oper_tab(i).oper_surcharge_amount
                                            , l_oper_tab(i).oper_date
                                            , l_oper_tab(i).host_date
                                            , l_oper_tab(i).unhold_date
                                            , l_oper_tab(i).match_status
                                            , l_oper_tab(i).match_id
                                            , l_oper_tab(i).dispute_id
                                            , l_oper_tab(i).payment_order_id
                                            , l_oper_tab(i).payment_host_id
                                            , l_oper_tab(i).forced_processing
                                            , l_oper_tab(i).auth_code
                                            , l_oper_tab(i).iss_inst_id
                                            , l_oper_tab(i).iss_network_id
                                            , l_oper_tab(i).card_network_id
                                            , l_oper_tab(i).acq_inst_id
                                            , l_oper_tab(i).acq_network_id
                                            , l_oper_tab(i).iss_client_id_type
                                            , l_oper_tab(i).iss_client_id_value
                                            , l_iss_card_mask
                                            , l_oper_tab(i).acq_client_id_type
                                            , l_oper_tab(i).acq_client_id_value
                                            , l_oper_tab(i).acq_card_number
                                            , l_oper_tab(i).iss_account_number
                                            , l_oper_tab(i).acq_account_number
                                            , l_oper_tab(i).mcc_id
                                            , l_oper_tab(i).external_auth_id
                                            , com_api_type_pkg.FALSE
                                            , l_index
                                            , l_reversal_exists
                                            , l_client_id_type
                                            , l_client_id_value
                                            , com_ui_object_search_pkg.get_mcc_name        (l_oper_tab(i).mcc)
                                            , com_ui_object_search_pkg.get_inst_name       (l_oper_tab(i).iss_inst_id)
                                            , com_ui_object_search_pkg.get_network_name    (l_oper_tab(i).iss_network_id)
                                            , com_ui_object_search_pkg.get_network_name    (l_oper_tab(i).card_network_id)
                                            , com_ui_object_search_pkg.get_inst_name       (l_oper_tab(i).acq_inst_id)
                                            , com_ui_object_search_pkg.get_network_name    (l_oper_tab(i).acq_network_id)
                                            , com_ui_object_search_pkg.get_dictionary_name (l_oper_tab(i).terminal_type)
                                            , l_iss_card_token
                                          );

            -- Remove these two columns from type:
            -- g_object_list_tab(l_index).is_calculated           := com_api_type_pkg.FALSE;
            -- g_object_list_tab(l_index).array_index             := l_index;

        end loop;
    end if;  -- if l_last_records_limit > 0

    trc_log_pkg.debug(LOG_PREFIX || ': finish');

end read_object_info;

function get_cached_object_id return num_tab_tpt is
begin
    return g_object_id_tab;
end get_cached_object_id;

function get_cached_object_list return opr_ui_operation_list_tpt is
begin
    return g_object_list_tab;
end get_cached_object_list;

procedure get_object_list(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , o_row_count            out  com_api_type_pkg.t_short_id
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
  , i_force_search      in      com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE  -- Refresh search cache when search conditions is not changed
  , io_oper_id_tab      in out  nocopy num_tab_tpt
) is
    LOG_PREFIX       constant   com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_object_list';

    l_sql_statement             com_api_type_pkg.t_sql_statement;
    l_param_rec                 t_search_param_rec;
    l_timestamp_step_1          timestamp;
    l_timestamp_step_2          timestamp;
    l_timestamp_step_3          timestamp;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ': Start. i_first_row [#1] i_last_row [#2] i_tab_name [#3] i_is_first_call [#4] i_force_search [#5]'
      , i_env_param1 => i_first_row
      , i_env_param2 => i_last_row
      , i_env_param3 => i_tab_name
      , i_env_param4 => i_is_first_call
      , i_env_param5 => i_force_search
    );

    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    l_timestamp_step_1 := systimestamp;

    if i_is_first_call = com_api_type_pkg.TRUE then


        get_search_param(
            i_tab_name    =>  i_tab_name
          , i_param_tab   =>  i_param_tab
          , o_param_rec   =>  l_param_rec
        );

        get_query_statement(
            io_param_rec     => l_param_rec
          , o_sql_statement  => l_sql_statement
        );

        l_timestamp_step_2 := systimestamp;

        if l_sql_statement is null then
            return;
        elsif i_force_search = com_api_type_pkg.TRUE
              or g_last_sql_statement is null
              or g_last_sql_statement != l_sql_statement
              or com_ui_object_search_pkg.check_changed_param(
                    i_old_param_tab    => g_param_tab
                  , i_new_param_tab    => i_param_tab
                ) = com_api_type_pkg.TRUE
        then
            read_object_list(
                io_param_rec      => l_param_rec
              , io_sql_statement  => l_sql_statement
            );
        end if;

        -- Save into global params
        g_param_tab          := i_param_tab;
        g_last_sql_statement := l_sql_statement;
        io_oper_id_tab       := g_object_id_tab;
        o_row_count          := g_object_id_tab.count;

    else

        g_object_id_tab      := io_oper_id_tab;

        read_object_info(
            i_first_row   => i_first_row
          , i_last_row    => i_last_row
          , i_sorting_tab => i_sorting_tab
        );

        l_timestamp_step_2 := systimestamp;

        open o_ref_cur for 'select t.* from table(cast(opr_ui_operation_search_pkg.get_cached_object_list as opr_ui_operation_list_tpt)) t';

    end if;

    l_timestamp_step_3 := systimestamp;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': Finished. Total [#1], Step 1 [#2] seconds, Step 2 [#3], o_row_count [#4]'
      , i_env_param1 => to_char((l_timestamp_step_3 - l_timestamp_step_1))
      , i_env_param2 => to_char((l_timestamp_step_2 - l_timestamp_step_1))
      , i_env_param3 => to_char((l_timestamp_step_3 - l_timestamp_step_2))
      , i_env_param4 => o_row_count
    );

exception
    when others then
        trc_log_pkg.debug('>>> SQLERRM=' || sqlerrm);
        raise;
end get_object_list;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_short_id
  , i_last_row          in      com_api_type_pkg.t_short_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_force_search      in      com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE  -- Refresh search cache when search conditions is not changed
  , i_one_step_search   in      com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE  -- Search without call of the "get_row_count" method
  , io_oper_id_tab      in out  nocopy num_tab_tpt
) is
    l_row_count         com_api_type_pkg.t_short_id;
    l_force_search      com_api_type_pkg.t_boolean  := i_force_search;
begin
    trc_log_pkg.debug('get_ref_cur: Start i_one_step_search=' || i_one_step_search);

    if i_one_step_search = com_api_type_pkg.TRUE then
        l_force_search  := com_api_type_pkg.TRUE;

        get_row_count(
            o_row_count     => l_row_count
          , i_tab_name      => i_tab_name
          , i_param_tab     => i_param_tab
          , i_force_search  => l_force_search
          , o_oper_id_tab   => io_oper_id_tab
        );
    end if;

    get_object_list(
        o_ref_cur           => o_ref_cur
      , o_row_count         => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_type_pkg.FALSE
      , i_force_search      => l_force_search
      , io_oper_id_tab      => io_oper_id_tab
    );

    trc_log_pkg.debug('get_ref_cur: Finish');
end get_ref_cur;

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_short_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_force_search      in      com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE  -- Refresh search cache when search conditions is not changed
  , o_oper_id_tab          out  nocopy num_tab_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    trc_log_pkg.debug('get_row_count: Start');

    get_object_list(
        o_ref_cur           => l_ref_cur
      , o_row_count         => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
      , i_force_search      => i_force_search
      , io_oper_id_tab      => o_oper_id_tab
    );

    trc_log_pkg.debug('get_row_count: Finish');
end get_row_count;

end opr_ui_operation_search_pkg;
/
