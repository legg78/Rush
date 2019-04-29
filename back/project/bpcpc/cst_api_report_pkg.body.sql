create or replace package body cst_api_report_pkg is

function get_transfers(
    i_begin_oper_id        in com_api_type_pkg.t_rate
  , i_end_oper_id          in com_api_type_pkg.t_rate
  , i_inst_id              in com_api_type_pkg.t_inst_id
  , i_split_status         in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return cst_transfers_tpt pipelined
is
begin
    for i in (
        select case when op_i.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD    then iss_api_card_pkg.get_card_mask(i_card_number => oc_i.card_number)
                    when op_i.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT then op_i.account_number
                    else op_i.client_id_value
               end as card_mask
             , oo.id as oper_id
             , op_i.card_network_id
             , oo.oper_date
             , oo.host_date
             , case when op_d.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD    then iss_api_card_pkg.get_card_mask(i_card_number => oc_d.card_number)
                    when op_d.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT then op_d.account_number
                    else op_d.client_id_value
               end as dst_card_mask
             , op_d.card_network_id as dst_card_network_id
             , oo.status
             , oo.status_reason
             , oo.oper_type
             , oo.terminal_number
             , oo.oper_request_amount as oper_amount
             , cc.exponent
             , cc.name as oper_currency
             , oo.is_reversal
             , oo.original_id
             , oo.merchant_name
             , op_i.network_id as network_id_source

          from opr_operation oo
          join aut_auth aa             on aa.id = oo.id
                                      and aa.resp_code = case when i_split_status = com_api_type_pkg.TRUE then pmo_api_const_pkg.SUCCESSFUL_AUTHORIZATION
                                                              else aa.resp_code
                                                         end
          join opr_participant op_i    on op_i.oper_id = oo.id
                                      and op_i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          join opr_participant op_d    on op_d.oper_id = oo.id
                                      and op_d.participant_type = com_api_const_pkg.PARTICIPANT_DEST
          join opr_participant op_a    on op_a.oper_id = oo.id
                                      and op_a.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
          left join opr_card oc_i      on oc_i.oper_id = oo.id
                                      and oc_i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          left join opr_card oc_d      on oc_d.oper_id = oo.id
                                      and oc_d.participant_type = com_api_const_pkg.PARTICIPANT_DEST
          left join com_currency_vw cc on cc.code = oo.oper_currency
         where oo.msg_type not in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT, opr_api_const_pkg.MESSAGE_TYPE_SPLIT)
           and oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P
           and oo.oper_amount != 0
           and ((i_split_status = com_api_type_pkg.TRUE and oo.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSING
                                                                        , opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                                                        , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                                                        , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                                                                        , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES
                                                                        , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)) or -- success only, default
                (i_split_status = com_api_type_pkg.FALSE and oo.status in (opr_api_const_pkg.OPERATION_STATUS_MANUAL
                                                                         , opr_api_const_pkg.OPERATION_STATUS_WRONG_DATA
                                                                         , opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                                                                         , opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL
                                                                         , opr_api_const_pkg.OPERATION_STATUS_NO_RULES))) -- failed only
           and nvl(oo.oper_reason, 'null') != cst_bpcpc_api_const_pkg.AUTH_SPLITING_PLUGIN_P2P_ATM
           and oo.id between i_begin_oper_id and i_end_oper_id
           and (i_inst_id = ost_api_const_pkg.DEFAULT_INST or
                i_inst_id = op_i.inst_id or
                i_inst_id = op_d.inst_id or
                i_inst_id = op_a.inst_id)

         union all

        select case when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT then t.card_mask
                    when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT then t.dst_card_mask
               end as card_mask
             , t.oper_id
             , case when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT then t.card_network_id
                    when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT then t.dst_card_network_id
               end as card_network_id
             , t.oper_date
             , t.host_date
             , case when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT then t.dst_card_mask
                    when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT then t.card_mask
               end as dst_card_mask
             , case when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT then t.dst_card_network_id
                    when t.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT then t.card_network_id
               end as dst_card_network_id
             , t.status
             , t.status_reason
             , t.oper_type
             , t.terminal_number
             , t.oper_amount
             , t.exponent
             , t.oper_currency
             , t.is_reversal
             , t.original_id
             , t.merchant_name
             , t.network_id_source

          from (select case when op_i.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD    then iss_api_card_pkg.get_card_mask(i_card_number => oc_i.card_number)
                            when op_i.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT then op_i.account_number
                            else op_i.client_id_value
                       end as card_mask
                     , oo.id as oper_id
                     , op_i.card_network_id
                     , oo.oper_date
                     , oo.host_date
                     , null as dst_card_mask
                     , null as dst_card_network_id
                     , oo.status
                     , oo.status_reason
                     , oo.oper_type
                     , oo.terminal_number
                     , oo.oper_request_amount as oper_amount
                     , cc.exponent
                     , cc.name as oper_currency
                     , oo.is_reversal
                     , oo.original_id
                     , oo.merchant_name
                     , op_i.network_id as network_id_source
                     , par.status as parent_status
                  from opr_operation oo
                  join aut_auth aa             on aa.id = oo.id
                                              and aa.resp_code = case when i_split_status = com_api_type_pkg.TRUE
                                                                         then pmo_api_const_pkg.SUCCESSFUL_AUTHORIZATION
                                                                      else aa.resp_code
                                                                 end
                  join opr_participant op_i    on op_i.oper_id = oo.id
                                              and op_i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                  join opr_participant op_a    on op_a.oper_id = oo.id
                                              and op_a.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                  join opr_card oc_i           on oc_i.oper_id = oo.id
                                              and oc_i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                  left join opr_operation par  on par.id = aa.parent_id
                  left join com_currency_vw cc on cc.code = oo.oper_currency
                 where oo.msg_type not in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT,  opr_api_const_pkg.MESSAGE_TYPE_SPLIT)
                   and oo.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT, opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                   and (((i_split_status = com_api_type_pkg.TRUE) and oo.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSING
                                                                                  , opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                                                                  , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                                                                  , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                                                                                  , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES
                                                                                  , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)) or -- success only, default
                        ((i_split_status = com_api_type_pkg.FALSE) and oo.status in (opr_api_const_pkg.OPERATION_STATUS_MANUAL
                                                                                   , opr_api_const_pkg.OPERATION_STATUS_WRONG_DATA
                                                                                   , opr_api_const_pkg.OPERATION_STATUS_EXCEPTION
                                                                                   , opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL
                                                                                   , opr_api_const_pkg.OPERATION_STATUS_NO_RULES))) -- failed only
                   and oo.id between i_begin_oper_id and i_end_oper_id
                   and (i_inst_id = ost_api_const_pkg.DEFAULT_INST or
                           op_i.inst_id = i_inst_id or
                           op_a.inst_id = i_inst_id)
               ) t
          where t.parent_status is null -- parent does not exist
             or t.parent_status not in (opr_api_const_pkg.OPERATION_STATUS_PROCESSING
                                      , opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                      , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                      , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                                      , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES
                                      , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD) -- parent status is unacceptable
    ) loop
        pipe row (cst_transfers_tpr(i.oper_id
                                  , i.oper_date
                                  , i.host_date
                                  , i.status
                                  , i.status_reason
                                  , i.is_reversal
                                  , i.original_id
                                  , i.merchant_name
                                  , i.oper_type
                                  , i.terminal_number
                                  , i.oper_amount
                                  , i.card_mask
                                  , i.card_network_id
                                  , i.dst_card_network_id
                                  , i.dst_card_mask
                                  , i.exponent
                                  , i.oper_currency
                                  , i.network_id_source
                                  )
                 );
    end loop;

    return;
end get_transfers;

procedure transfers(
    o_xml                    out    clob
  , i_begin_oper_date            in date                            default null
  , i_end_oper_date              in date                            default null
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id
  , i_split_status               in com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
) is
    l_header                 xmltype;
    l_transfers              xmltype;
    l_result                 xmltype;
    l_lang                   com_api_type_pkg.t_dict_value;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_begin_oper_date        date;
    l_end_oper_date          date;
    l_begin_id               number;
    l_end_id                 number;
    l_split_status           com_api_type_pkg.t_boolean;
begin
    -- Report "The report of payments"
    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);
    l_split_status := i_split_status;

    l_begin_oper_date := trunc(nvl(i_begin_oper_date, get_sysdate - 1), 'dd');
    l_end_oper_date := trunc(nvl(i_end_oper_date, get_sysdate - 1) + 1, 'dd') - com_api_const_pkg.ONE_SECOND;

    l_begin_id := com_api_id_pkg.get_from_id(l_begin_oper_date);
    l_end_id   := com_api_id_pkg.get_till_id(l_end_oper_date);

    trc_log_pkg.debug(
        i_text => 'START: cst_api_report_pkg.transfers l_begin_oper_date[#1] l_end_oper_date[#2] i_inst_id[#3]'
      , i_env_param1  => l_begin_oper_date
      , i_env_param2  => l_end_oper_date
      , i_env_param3  => i_inst_id
    );

    -- 1 header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION', 'NAME', l_inst_id, l_lang))
            , xmlelement("begin_trans_date", to_char(l_begin_oper_date, 'dd.mm.yyyy'))
            , xmlelement("end_trans_date", to_char(l_end_oper_date, 'dd.mm.yyyy'))
        )
      into l_header
      from dual;

    -- 2 data
    select
        xmlelement("transfers"
            , xmlagg(
                xmlelement("transfer"
                    , xmlelement("card_mask", card_mask)
                    , xmlelement("oper_id", oper_id)
                    , xmlelement("is_reversal", is_reversal)
                    , xmlelement("original_id", original_id)
                    , xmlelement("card_network_id", card_network_id)
                    , xmlelement("card_network_name", card_network_name)
                    , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                    , xmlelement("host_date", host_date)
                    , xmlelement("dst_card_mask", dst_card_mask)
                    , xmlelement("dst_card_network_id", dst_card_network_id)
                    , xmlelement("dst_card_network_name", dst_card_network_name)
                    , xmlelement("status", status)
                    , xmlelement("status_name", status_name)
                    , xmlelement("oper_type", oper_type)
                    , xmlelement("oper_type_name", oper_type_name)
                    , xmlelement("oper_amount", to_char(oper_amount / power(10, exponent), format, 'nls_numeric_characters=,.'))
                    , xmlelement("oper_currency", oper_currency)
                    , xmlelement("terminal_number", terminal_number)
                    , xmlelement("source_network_name", source_network_name)
                )
                order by oper_id
            )
       )
      into l_transfers
      from (
        select t.card_mask
             , t.oper_id
             , t.is_reversal
             , t.original_id
             , t.card_network_id
             , com_api_i18n_pkg.get_text(
                   i_table_name   => 'net_network'
                 , i_column_name  => 'name'
                 , i_object_id    => t.card_network_id
                 , i_lang         => l_lang) as card_network_name
             , t.oper_date
             , t.host_date
             , t.dst_card_mask
             , t.dst_card_network_id
             , com_api_i18n_pkg.get_text(
                   i_table_name   => 'net_network'
                 , i_column_name  => 'name'
                 , i_object_id    => t.dst_card_network_id
                 , i_lang         => l_lang) as dst_card_network_name
             , t.status
             , com_api_dictionary_pkg.get_article_text(
                   i_article => t.status
                 , i_lang    => l_lang) as status_name
             , t.oper_type
             , com_api_dictionary_pkg.get_article_text(
                   i_article => t.oper_type
                 , i_lang    => l_lang) as oper_type_name
             , t.terminal_number
             , t.oper_amount
             , t.oper_currency
             , t.exponent
             , 'FM999999999999999990' || decode ( nvl(t.exponent, 0), 0, null, 'D' || lpad('0', t.exponent, '0')) as format
             , nvl(c1.text, c2.text) as source_network_name

          from table(get_transfers(
                         i_begin_oper_id => l_begin_id
                       , i_end_oper_id   => l_end_id
                       , i_inst_id       => l_inst_id
                       , i_split_status  => l_split_status)) t
          left join com_i18n c1 on c1.object_id = t.network_id_source
                               and c1.table_name = 'NET_NETWORK'
                               and c1.column_name = 'NAME'
                               and c1.lang = 'LANGRUS'
          left join com_i18n c2 on c2.object_id = t.network_id_source
                               and c2.table_name = 'NET_NETWORK'
                               and c2.column_name = 'NAME'
                               and c2.lang = 'LANGENG'
      );

    -- Fill in the transfer tag to form empty reports
    for i in (
        select 1
          from dual
         where existsnode(l_transfers, '/transfers/transfer') = 0
    ) loop
      select xmlelement("transfers", xmlagg(xmlelement("transfer")))
        into l_transfers
        from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
                     , l_header
                     , l_transfers
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.transfers');

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text => sqlerrm
        );
end transfers;

procedure act_transactions(
    i_begin_oper_date            in date                            default null
  , i_end_oper_date              in date                            default null
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id      default null
) is
    l_begin_oper_date   date;
    l_end_oper_date     date;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;

    procedure rendered_services(
        i_launching_mode        in number
      , i_begin_date            in date                             default null
      , i_end_date              in date                             default null
      , i_lang                  in com_api_type_pkg.t_dict_value    default null
      , i_inst_id               in com_api_type_pkg.t_inst_id       default null
    ) is
        l_from_id           com_api_type_pkg.t_long_id;
        l_till_id           com_api_type_pkg.t_long_id;
        l_sql               com_api_type_pkg.t_sql_statement;
        l_sql_1             com_api_type_pkg.t_sql_statement;
        l_sql_2             com_api_type_pkg.t_sql_statement;
        l_sql_3             com_api_type_pkg.t_sql_statement;
        l_sql_4             com_api_type_pkg.t_sql_statement;
    begin
        trc_log_pkg.debug(
            i_text => 'START: cst_api_report_pkg.rendered_services'
        );

        l_from_id := com_api_id_pkg.get_from_id(i_begin_date);
        l_till_id := com_api_id_pkg.get_till_id(i_end_date);

        l_sql_1 :=  '
        insert into cst_act_transactions
        select
           to_char(o.id) as oper_id,
           o.host_date,
           o.oper_amount / nvl(power(10, curr.exponent), 1) as oper_amount,
           curr.name as oper_currency,
           case when substr(rd.raw_data, 266, 3)  = ''' || com_api_currency_pkg.RUBLE || ''' then to_number(nvl(trim(substr(rd.raw_data, 299, 15)), 0))
                when substr(rd.raw_data, 266, 3) != ''' || com_api_currency_pkg.RUBLE || ''' then round(com_api_rate_pkg.convert_amount (
                                                                          i_src_amount      => to_number(nvl(trim(substr(rd.raw_data, 299, 15)), 0))
                                                                        , i_src_currency    => substr(rd.raw_data, 266, 3)
                                                                        , i_dst_currency    => ''' || com_api_currency_pkg.RUBLE || '''
                                                                        , i_rate_type       => ''' || cst_bpcpc_api_const_pkg.RATE_TYPE_CUSTOMER || '''
                                                                        , i_inst_id         => '' || to_char(nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)) || ''
                                                                        , i_eff_date        => o.host_date
                                                                        , i_mask_exception  => 0
                                                                        , i_exception_value => null
                                                                        , i_conversion_type => ''' || com_api_const_pkg.CONVERSION_TYPE_SELLING || ''' ))
           end / nvl(power(10, curr.exponent), 1) as acc_amount,
           substr(rd.raw_data, 266, 3) as acc_currency,
           o.oper_type || '' - '' || com_api_dictionary_pkg.get_article_text(i_article => o.oper_type) as oper_type,
           decode(substr(rd.raw_data, 59, 1), ''R'', ''1'', '''') is_reversal,
           to_char(o.original_id) as original_id,
           o.status || '' - '' || com_api_dictionary_pkg.get_article_text(i_article => o.status) as status,
           case when o.status_reason is not null
                    then decode(o.status_reason, ''' || aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE || ''', aa.resp_code, o.status_reason)
                        || '' - '' || com_api_dictionary_pkg.get_article_text(i_article => o.status_reason)
                else null
           end as status_reason,
           case when :l_launching_mode not in (1, 3) then o.merchant_number else null end as merchant_number,
           o.merchant_name,
           (select max(a.account_number)
              from acc_account_vw        a,
                   acc_account_object_vw ao,
                   opr_participant       p
             where p.oper_id = o.id
               and p.merchant_id = ao.object_id
               and ao.account_id = a.id
               and ao.entity_type = ''' || acq_api_const_pkg.ENTITY_TYPE_MERCHANT || '''
               and p.participant_type in (''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''')) as merchant_account,
           case when :l_launching_mode not in (1, 3) then nvl(c1.text, c11.text) else null end terminal_type,
           sf.file_name,
           case when substr(rd.raw_data, 455, 1) = ''E'' then ''MasterCard''
                when substr(rd.raw_data, 455, 1) = ''V'' then ''VISA''
                when substr(rd.raw_data, 455, 1) = ''O'' then ''ORS''
                when substr(rd.raw_data, 455, 1) = ''1'' then ''US_ON_US''
                when substr(rd.raw_data, 455, 1) = ''N'' and
                     (op.card_network_id = ' || cmp_api_const_pkg.MC_NETWORK || ' or substr(rd.raw_data, 161, 2) in (''EC'', ''MC'')) then ''MC NSPK''
                when substr(rd.raw_data, 455, 1) = ''N'' and
                     (op.card_network_id = ' || cmp_api_const_pkg.VISA_NETWORK || ' or substr(rd.raw_data, 161, 2) in (''PC'', ''VC'')) then ''VISA NSPK''
                else null
           end as network,
           ';

        l_sql_2 := case when i_launching_mode = 1 then '''ECOM_THEM_ON_US'''
                        when i_launching_mode = 2 then '''ECOM_US_ON_US'''
                        when i_launching_mode = 3 then '''MPOS_THEM_ON_US'''
                        when i_launching_mode = 4 then '''MPOS_US_ON_US'''
                   end;

        l_sql_3 := ' as fill_mode
      from opr_operation o
      join opr_participant op     on op.oper_id = o.id
                                 and op.participant_type = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || '''
      join com_currency_vw curr   on curr.code = o.oper_currency
      join evt_event_object ev    on ev.object_id = o.id
                                 and ev.entity_type = ''' || opr_api_const_pkg.ENTITY_TYPE_OPERATION || '''
      join prc_session_file sf    on sf.session_id = ev.proc_session_id
      join prc_file_raw_data rd   on rd.session_file_id = sf.id
                                 and substr(rd.raw_data, 1, 2) = ''RD''
                                 and substr(rd.raw_data, 9, 16) = case when substr(rd.raw_data, 59, 1) != ''R''
                                                                           then to_char(o.id) else to_char(o.original_id)
                                                                  end
      join com_dictionary d1      on d1.dict||d1.code = o.terminal_type
      left join aut_auth aa       on aa.id = o.id
      left join com_i18n_vw c1    on c1.object_id = d1.id
                                 and c1.table_name = ''COM_DICTIONARY''
                                 and c1.lang = ''LANGRUS''
                                 and c1.column_name = ''NAME''
      left join com_i18n_vw c11   on c11.object_id = d1.id
                                 and c11.table_name = ''COM_DICTIONARY''
                                 and c11.lang = ''LANGENG''
                                 and c11.column_name = ''NAME''
     where o.status = ''' || opr_api_const_pkg.OPERATION_STATUS_PROCESSED || '''
       and o.msg_type not in (''' || opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION || ''')
       and o.msg_type not in (''' || opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK || ''', '''
                                  || opr_api_const_pkg.MESSAGE_TYPE_REPRESENTMENT || ''', '''
                                  || aut_api_const_pkg.MESSAGE_TYPE_ARBITR_CHARGEBACK || ''')
       and o.terminal_number not between ''10000017'' and ''10000023''
       and o.id between :from_id and :till_id ' ;

        l_sql_4 := case when i_launching_mode = 1 then 'and o.terminal_type = ''' || acq_api_const_pkg.TERMINAL_TYPE_EPOS || '''
                                                        and sf.file_type = ''' || cst_bpcpc_api_const_pkg.FILE_TYPE_OPENWAY_M_FILE_EPOS || '''
                                                        and substr(rd.raw_data, 455, 1) in (''E'', ''V'', ''N'', ''O'')'
                        when i_launching_mode = 2 then 'and o.terminal_type = ''' || acq_api_const_pkg.TERMINAL_TYPE_EPOS || '''
                                                        and sf.file_type = ''' || cst_bpcpc_api_const_pkg.FILE_TYPE_OPENWAY_M_FILE_EPOS || '''
                                                        and substr(rd.raw_data, 455, 1) in (''1'')'
                        when i_launching_mode = 3 then 'and o.terminal_type = ''' || acq_api_const_pkg.TERMINAL_TYPE_POS || '''
                                                        and sf.file_type = ''' || cst_bpcpc_api_const_pkg.FILE_TYPE_OPENWAY_M_FILE_POS || '''
                                                        and substr(rd.raw_data, 455, 1) in (''E'', ''V'', ''N'', ''O'')'
                        when i_launching_mode = 4 then 'and o.terminal_type = ''' || acq_api_const_pkg.TERMINAL_TYPE_POS || '''
                                                        and sf.file_type = ''' || cst_bpcpc_api_const_pkg.FILE_TYPE_OPENWAY_M_FILE_POS || '''
                                                        and substr(rd.raw_data, 455, 1) in (''1'')'
                    end;

        l_sql := l_sql_1 || l_sql_2 || l_sql_3 || l_sql_4;

        execute immediate l_sql using i_launching_mode, i_launching_mode, l_from_id, l_till_id;

        trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.rendered_services');
    exception
        when no_data_found then
            trc_log_pkg.debug ( i_text => sqlerrm );
    end rendered_services;

    procedure fix_transactions
        is
    begin
        delete from cst_act_transactions a
         where exists (select 1 from cst_act_transactions b
                             where b.oper_id = a.original_id
                               and a.is_reversal = 1
                               and b.is_reversal is null
                               and b.file_name = a.file_name)
            or exists (select 1 from cst_act_transactions b,
                                     cst_act_transactions c
                             where b.oper_id = c.original_id
                               and c.is_reversal = 1
                               and b.is_reversal is null
                               and b.file_name = c.file_name
                               and c.original_id = a.oper_id);
    end fix_transactions;

begin
    execute immediate 'alter session set NLS_LANGUAGE = RUSSIAN';
    execute immediate 'truncate table cst_act_transactions drop storage';

    trc_log_pkg.debug(
        i_text => 'START: cst_api_report_pkg.act_transactions'
    );

    l_begin_oper_date     := nvl(trunc(i_begin_oper_date), trunc(trunc(get_sysdate, 'MM' ) - 1, 'MM' ));
    l_end_oper_date       := nvl(trunc(i_end_oper_date), trunc(get_sysdate, 'MM') - 1);

    for i in (select 1 as code_id, 'ECOM_THEM_ON_US'    as code from dual union all
              select 2 as code_id, 'ECOM_US_ON_US'      as code from dual union all
              select 3 as code_id, 'MPOS_THEM_ON_US'    as code from dual union all
              select 4 as code_id, 'MPOS_US_ON_US'      as code from dual
              ) loop
        rendered_services(
            i_launching_mode   => i.code_id
          , i_begin_date       => l_begin_oper_date
          , i_end_date         => l_end_oper_date
          , i_lang             => i_lang
          , i_inst_id          => i_inst_id
        );
        commit;
    end loop;
    fix_transactions;

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.act_transactions');
exception
    when no_data_found then
        trc_log_pkg.debug ( i_text => sqlerrm );
end act_transactions;

procedure act_transactions_group(
    o_xml                    out    clob
  , i_launching_mode             in number
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id      default null
) is
    l_header            xmltype;
    l_result            xmltype;
    l_operations        xmltype;
    l_lang              com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_launching_mode    com_api_type_pkg.t_attr_name;
begin
    execute immediate 'alter session set NLS_LANGUAGE = RUSSIAN';

    trc_log_pkg.debug(
        i_text => 'START: cst_api_report_pkg.act_transactions_group'
    );

    l_lang           := nvl(i_lang, get_user_lang);
    l_inst_id        := nvl(i_inst_id, 9999);
    l_launching_mode := case when i_launching_mode = 1 then 'ECOM_THEM_ON_US'
                             when i_launching_mode = 2 then 'ECOM_US_ON_US'
                             when i_launching_mode = 3 then 'MPOS_THEM_ON_US'
                             when i_launching_mode = 4 then 'MPOS_US_ON_US'
                        end;

    -- 1 header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION', 'NAME', l_inst_id, l_lang))
            , xmlelement("launching_mode", l_launching_mode)
        )
      into l_header
      from dual;

    -- 2 data
    select
            xmlelement("operations"
                , xmlagg(
                    xmlelement("operation"
                        , xmlelement("oper_id", oper_id)
                        , xmlelement("host_date", host_date)
                        , xmlelement("acc_amount", acc_amount)
                        , xmlelement("acc_currency", acc_currency)
                        , xmlelement("oper_type", oper_type)
                        , xmlelement("is_reversal", is_reversal)
                        , xmlelement("original_id", original_id)
                        , xmlelement("status", status)
                        , xmlelement("status_reason", status_reason)
                        , xmlelement("merchant_number", merchant_number)
                        , xmlelement("merchant_name", merchant_name)
                        , xmlelement("merchant_account", merchant_account)
                        , xmlelement("terminal_type", terminal_type)
                        , xmlelement("file_name", file_name)
                        , xmlelement("network", network)
                    )
                    order by oper_id
                )
           )
      into l_operations
      from (select oper_id
                 , to_char(host_date, 'dd/mm/yyyy hh24:mi:ss') as host_date
                 , acc_amount
                 , acc_currency
                 , oper_type
                 , is_reversal
                 , original_id
                 , status
                 , status_reason
                 , merchant_number
                 , merchant_name
                 , merchant_account
                 , terminal_type
                 , file_name
                 , network
              from cst_act_transactions
             where fill_mode = l_launching_mode);

    -- Fill in the operation tag to form empty reports
    for i in (
        select 1
          from dual
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
        select xmlelement("operations", xmlagg(xmlelement("operation")))
          into l_operations
          from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
                     , l_header
                     , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.act_transactions_group');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end act_transactions_group;

procedure act_rendered_services(
    o_xml                    out    clob
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id      default null
  , i_begin_oper_date            in date                            default null
  , i_end_oper_date              in date                            default null
  , i_auth_price                 in com_api_type_pkg.t_rate         default 0
  , i_sms_notif_price            in com_api_type_pkg.t_rate         default 1
  , i_reb_card_percent           in com_api_type_pkg.t_rate         default 0
  , i_other_card_percent         in com_api_type_pkg.t_rate         default 0
  , i_e_commerce_percent         in com_api_type_pkg.t_rate         default 0
) is
    l_header            xmltype;
    l_result            xmltype;
    l_lang              com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_begin_oper_date   date;
    l_end_oper_date     date;
    l_begin_oper_date_v com_api_type_pkg.t_original_data;
    l_end_oper_date_v   com_api_type_pkg.t_original_data;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;
    l_sms_notif_count   com_api_type_pkg.t_long_id;
    l_operation_count   com_api_type_pkg.t_long_id;
    l_reb_card_sum      com_api_type_pkg.t_rate;
    l_other_card_sum    com_api_type_pkg.t_rate;
    l_e_commerce_sum    com_api_type_pkg.t_rate;
    l_sms_notif_sum     com_api_type_pkg.t_rate;
    l_total_sum         com_api_type_pkg.t_rate;
    l_us_on_us_sum      com_api_type_pkg.t_rate;
    l_them_on_us_sum    com_api_type_pkg.t_rate;
    l_ecom_sum          com_api_type_pkg.t_rate;

begin
    execute immediate 'alter session set NLS_LANGUAGE = RUSSIAN';

    trc_log_pkg.debug(
        i_text => 'START: cst_api_report_pkg.act_rendered_services'
    );

    l_lang          := nvl(i_lang, get_user_lang);
    l_inst_id       := nvl(i_inst_id, 9999);

    l_begin_oper_date     := nvl(trunc(i_begin_oper_date), trunc(trunc(get_sysdate, 'MM' ) - 1, 'MM'));
    l_end_oper_date       := nvl(trunc(i_end_oper_date), trunc(get_sysdate, 'MM' ) - 1);

    l_begin_oper_date_v   := cst_util_pkg.get_formated_date(l_begin_oper_date);
    l_end_oper_date_v     := cst_util_pkg.get_formated_date(l_end_oper_date);

    l_from_id := com_api_id_pkg.get_from_id(nvl(i_begin_oper_date, l_begin_oper_date));
    l_till_id := com_api_id_pkg.get_till_id(nvl(i_end_oper_date, l_end_oper_date));

    select count(id) into l_sms_notif_count
      from ntf_message nm
     where nm.delivery_date between l_begin_oper_date and
                                    l_end_oper_date + 1 - com_api_const_pkg.ONE_SECOND;

    select count(1) into l_operation_count
      from opr_operation o
     where o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
       and o.id between l_from_id and l_till_id
       and o.oper_type != opr_api_const_pkg.OPERATION_PAYMENT_NOTIFICATION
       and o.sttl_type in (opr_api_const_pkg.SETTLEMENT_USONUS, opr_api_const_pkg.SETTLEMENT_USONTHEM);

    select sum(case when a.fill_mode = 'MPOS_US_ON_US' then a.acc_amount else 0 end) over() as us_on_us
         , sum(case when a.fill_mode = 'MPOS_THEM_ON_US' then a.acc_amount  else 0 end) over() as them_on_us
         , sum(case when a.fill_mode in ('ECOM_THEM_ON_US', 'ECOM_US_ON_US') then a.acc_amount else 0 end) over() as ecom
      into l_us_on_us_sum, l_them_on_us_sum, l_ecom_sum
      from cst_act_transactions a;

    l_reb_card_sum   := l_us_on_us_sum * i_reb_card_percent / 100;
    l_other_card_sum := l_them_on_us_sum * i_other_card_percent / 100;
    l_e_commerce_sum := l_ecom_sum * i_e_commerce_percent / 100;

    l_sms_notif_sum := l_sms_notif_count * i_sms_notif_price;
    l_total_sum := l_sms_notif_sum + i_auth_price + l_reb_card_sum + l_other_card_sum + l_e_commerce_sum;

    -- 1 header
    select
        xmlconcat(
              xmlelement("inst_id_header",     l_inst_id)
            , xmlelement("inst_header",        com_api_i18n_pkg.get_text('OST_INSTITUTION', 'NAME', l_inst_id, l_lang))
            , xmlelement("start_date",         l_begin_oper_date_v)
            , xmlelement("end_date",           l_end_oper_date_v)
            , xmlelement("end_date",           l_end_oper_date_v)
            , xmlelement("auth_price",         trim(to_char(i_auth_price, '999G999G999G999G999D99')))
            , xmlelement("auth_count",         l_operation_count)
            , xmlelement("sms_notif_price",    trim(to_char(i_sms_notif_price, '999G999G999G999G999D99')))
            , xmlelement("sms_notif_count",    l_sms_notif_count)
            , xmlelement("sms_notif_sum",      trim(to_char(l_sms_notif_sum, '999G999G999G999G999D99')))
            , xmlelement("reb_card_percent",   to_char(i_reb_card_percent, 'FM999999999990D999999999999'))
            , xmlelement("other_card_percent", to_char(i_other_card_percent, 'FM999999999990D999999999999'))
            , xmlelement("e_commerce_percent", to_char(i_e_commerce_percent, 'FM999999999990D999999999999'))
            , xmlelement("reb_card_sum",       trim(to_char(l_reb_card_sum, '999G999G999G999G999D99')))
            , xmlelement("other_card_sum",     trim(to_char(l_other_card_sum, '999G999G999G999G999D99')))
            , xmlelement("e_commerce_sum",     trim(to_char(l_e_commerce_sum, '999G999G999G999G999D99')))
            , xmlelement("reb_card",           trim(to_char(l_us_on_us_sum, '999G999G999G999G999')))
            , xmlelement("other_card",         trim(to_char(l_them_on_us_sum, '999G999G999G999G999')))
            , xmlelement("e_commerce",         trim(to_char(l_ecom_sum, '999G999G999G999G999')))
            , xmlelement("total_sum",          trim(to_char(l_total_sum, '999G999G999G999G999D99')))
            , xmlelement("total_sum_str",      cst_util_pkg.get_sum_str(l_total_sum))
        )
      into l_header
      from dual;

    -- 2 output
    select xmlelement("report"
                    , l_header
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.act_rendered_services');
exception
    when no_data_found then
        trc_log_pkg.debug ( i_text => sqlerrm );
end act_rendered_services;

procedure nonexist_cards_operations(
    o_xml                    out    clob
  , i_oper_date                  in date default null
  , i_lang                       in com_api_type_pkg.t_dict_value default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id    default null
) is
    l_header                 xmltype;
    l_operations             xmltype;
    l_result                 xmltype;
    l_lang                   com_api_type_pkg.t_dict_value;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_begin_id               com_api_type_pkg.t_long_id;
    l_end_id                 com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text => 'START: cst_api_report_pkg.nonexist_cards_operations [#1] [#2] [#3]'
      , i_env_param1  => i_oper_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang      := nvl(i_lang, get_user_lang);
    l_inst_id   := nvl(i_inst_id, 0);

    l_begin_id  := com_api_id_pkg.get_from_id(i_date => nvl(i_oper_date, sysdate - 1));
    l_end_id    := com_api_id_pkg.get_till_id(i_date => nvl(i_oper_date, sysdate - 1));

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
          , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION', 'NAME', l_inst_id, l_lang))
          , xmlelement("report_date", to_char(nvl(i_oper_date, sysdate - 1), 'dd.mm.yyyy'))
        )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
                     , xmlagg(
                            xmlelement("operation"
                                        , xmlelement("card_number", card_number)
                                        , xmlelement("id", id)
                                        , xmlelement("reversal_indicator", reversal_indicator)
                                        , xmlelement("oper_type", oper_type)
                                        , xmlelement("oper_direction", oper_direction)
                                        , xmlelement("msg_type", msg_type)
                                        , xmlelement("status", status)
                                        , xmlelement("acq_inst", acq_inst)
                                        , xmlelement("acq_inst_bin", acq_inst_bin)
                                        , xmlelement("merchant_number", merchant_number)
                                        , xmlelement("merchant_name", merchant_name)
                                        , xmlelement("merchant_city", merchant_city)
                                        , xmlelement("merchant_country", merchant_country)
                                        , xmlelement("mcc", mcc)
                                        , xmlelement("originator_refnum", originator_refnum)
                                        , xmlelement("network_refnum", network_refnum)
                                        , xmlelement("auth_code", auth_code)
                                        , xmlelement("oper_amount", oper_amount)
                                        , xmlelement("oper_currency", oper_currency)
                                        , xmlelement("sttl_amount", sttl_amount)
                                        , xmlelement("sttl_currency", sttl_currency)
                                        , xmlelement("oper_date", oper_date)
                                        , xmlelement("host_date", host_date)
                                        , xmlelement("file_name", file_name)
                                        )
                           order by id desc
                           )
                     )
      into l_operations
      from (with oo as (
                select oc.card_number
                     , o.id
                     , decode(o.is_reversal, 0, 'No',
                                             1, 'Yes',
                                             'Unknown') as reversal_indicator
                     , o.oper_type
                     , case
                            when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                                               , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                               , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                               , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                               , opr_api_const_pkg.OPERATION_TYPE_CREDIT_ACCOUNT) then 'CREDIT'
                            else 'DEBIT'
                       end oper_direction
                     , o.msg_type
                     , o.status
                     , case
                            when opa.inst_id in ('9009', '9959') then 'NSPK Mastercard'
                            when opa.inst_id = '9949' then 'NSPK VISA'
                            when opa.inst_id in('9001', '9954') then 'Mastercard'
                            when opa.inst_id = '9944' then 'VISA'
                            when opa.inst_id = '9947' then 'UCS'
                            else 'OTHER'
                       end acq_inst
                     , o.acq_inst_bin
                     , o.merchant_number
                     , o.merchant_name
                     , o.merchant_city
                     , o.merchant_country
                     , o.mcc
                     , o.originator_refnum
                     , o.network_refnum
                     , op.auth_code
                     , o.oper_amount
                     , o.oper_currency
                     , o.sttl_amount
                     , o.sttl_currency
                     , o.oper_date
                     , o.host_date
                     , o.incom_sess_file_id
                  from opr_operation o
                     , opr_participant op
                     , opr_participant opa
                     , opr_card oc
                 where o.id between l_begin_id and l_end_id
                   and o.id = op.oper_id and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                   and (op.inst_id = l_inst_id or l_inst_id = 0)
                   and o.id = opa.oper_id and opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                   and o.id = oc.oper_id and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                   and o.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                    , opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                                    , opr_api_const_pkg.MESSAGE_TYPE_REPRESENTMENT
                                    , opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT
                                    , opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL)
                   and o.incom_sess_file_id is not null
                   and o.status != opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                   and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_FEE_CREDIT, opr_api_const_pkg.OPERATION_TYPE_FEE_DEBIT)
                   and (o.match_id is null or o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                                                                , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                                                , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                                                , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                                                , opr_api_const_pkg.OPERATION_TYPE_CREDIT_ACCOUNT))
                   and not exists (select null from acc_macros a where a.object_id = o.id)
                   and o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM
            )
            select oo.card_number
                 , oo.id
                 , oo.reversal_indicator
                 , oo.oper_type || '-' || com_api_dictionary_pkg.get_article_text(i_article => oo.oper_type, i_lang => 'LANGRUS') as oper_type
                 , oo.oper_direction
                 , oo.msg_type || '-' || com_api_dictionary_pkg.get_article_text(i_article => oo.msg_type, i_lang => 'LANGRUS') as msg_type
                 , oo.status || '-' || com_api_dictionary_pkg.get_article_text(i_article => oo.status, i_lang => 'LANGRUS') as status
                 , oo.acq_inst
                 , oo.acq_inst_bin
                 , oo.merchant_number
                 , oo.merchant_name
                 , oo.merchant_city
                 , oo.merchant_country
                 , oo.mcc
                 , oo.originator_refnum
                 , oo.network_refnum
                 , oo.auth_code
                 , round(oo.oper_amount / nvl(power(10, curr.exponent), 1), 2) as oper_amount
                 , curr.name as oper_currency
                 , round(oo.sttl_amount / nvl(power(10, curr_sttl.exponent), 1), 2) as sttl_amount
                 , curr_sttl.name as sttl_currency
                 , oo.oper_date
                 , oo.host_date
                 , case
                       when incom_sess_file_id < 100000 then (select file_name
                                                                from prc_session_file
                                                               where id = (select session_file_id
                                                                             from mcw_file
                                                                            where id = oo.incom_sess_file_id))
                       else (select file_name from prc_session_file where id = oo.incom_sess_file_id)
                   end as file_name
             from oo
             left join com_currency_vw curr      on curr.code = oo.oper_currency
             left join com_currency_vw curr_sttl on curr_sttl.code = oo.sttl_currency
           );

    -- Fill in the operation tag to form empty reports
    for i in (
        select 1
          from dual
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
        select xmlelement("operations", xmlagg(xmlelement("operation")))
          into l_operations
          from dual;
    end loop;

    -- output
    select xmlelement("report"
                     , l_header
                     , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.nonexist_cards_operations');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end nonexist_cards_operations;

procedure account_statement (
    o_xml                    out    clob
  , i_account_number             in com_api_type_pkg.t_account_number
  , i_start_date                 in date
  , i_end_date                   in date
  , i_lang                       in com_api_type_pkg.t_dict_value
) is
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug (
        i_text        => 'cst_api_report_pkg.account_statement [#1][#2][#3]'
      , i_env_param1  => i_account_number
      , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
      , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    begin
        -- header
        select
            xmlconcat(
                xmlelement("account_number",  z.account_number)
                , xmlelement("currency",      z.currency_name)
                , xmlelement("start_date",    to_char(l_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date",      to_char(l_end_date, 'dd.mm.yyyy'))
                , xmlelement("customer_name", z.customer_name || nvl2(z.id_card, ', ' || z.id_card, ''))
                , xmlelement("incoming_balance", com_api_currency_pkg.get_amount_str(nvl(z.incoming_avail_balance,0), z.currency, com_api_type_pkg.TRUE))
                , xmlelement("outgoing_balance", com_api_currency_pkg.get_amount_str(nvl(z.outgoing_avail_balance,0), z.currency, com_api_type_pkg.TRUE))
            )
        into
            l_header
        from (
            select
                a.account_number
                , a.currency
                , r.name as currency_name
                , com_ui_object_pkg.get_object_desc(t.entity_type, t.object_id, l_lang)     as customer_name
                , com_ui_id_object_pkg.get_id_card_desc(t.entity_type, t.object_id, l_lang) as id_card
                , q.incoming_avail_balance
                , q.outgoing_avail_balance
            from
              (select
                  sum(x.incoming_balance * z.aval_impact) as incoming_avail_balance,
                  sum(x.outgoing_balance * z.aval_impact) as outgoing_avail_balance
                from
                    (select distinct
                      t.inst_id
                      , t.account_type
                      , e.balance_type
                      , first_value(e.balance - e.balance_impact * e.amount)
                            over (partition by e.balance_type order by e.id asc) incoming_balance
                      , first_value(e.balance)
                            over (partition by e.balance_type order by e.id desc) outgoing_balance
                    from
                        acc_entry e
                        , acc_account t
                        , acc_macros m
                    where 1=1
                      and t.account_number = i_account_number
                      and e.account_id = t.id
                      and m.id = e.macros_id
                      and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      and e.balance_type in (
                          ACC_API_CONST_PKG.BALANCE_TYPE_LEDGER
                        , ACC_API_CONST_PKG.BALANCE_TYPE_HOLD)
                      and e.posting_date between l_start_date and l_end_date
                      and e.status != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                      -- exclude unholded transactions
                      and (case when e.balance_type = ACC_API_CONST_PKG.BALANCE_TYPE_HOLD
                                and (m.cancel_indicator = com_api_const_pkg.INDICATOR_CANCELED
                                      or exists (select 1 from acc_entry x
                                                  where x.bunch_id = e.bunch_id
                                                    and e.balance_type = ACC_API_CONST_PKG.BALANCE_TYPE_LEDGER)
                                     )
                                then 0
                                else 1
                          end) = 1
                    ) x
                join acc_balance_type z on (
                    z.inst_id = x.inst_id
                    and z.account_type = x.account_type
                    and z.balance_type = x.balance_type)
            ) q
            join acc_account  a on (a.account_number = i_account_number)
            join prd_customer t on (t.id = a.customer_id)
            join com_currency r on (r.code = a.currency)
        ) z;
    exception
        when no_data_found then
            null;
    end;

    begin
        -- details
        select
            xmlelement("operations"
                , xmlagg(
                    xmlelement("operation"
                        , xmlelement("posting_date", to_char(posting_date, 'dd.mm.yyyy'))
                        , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy'))
                        , xmlelement("currency", currency)
                        , xmlelement("amount", com_api_currency_pkg.get_amount_str(nvl(x.balance_impact*x.amount, 0), x.currency, com_api_type_pkg.TRUE))
                        , xmlelement("account_amount", com_api_currency_pkg.get_amount_str(nvl(x.balance_impact*x.account_amount, 0), x.account_currency, com_api_type_pkg.TRUE))
                        , xmlelement("card_mask", nvl(x.card_mask, com_api_label_pkg.get_label_text('BANK_TRANSACTIONS', l_lang)))
                        , xmlelement("oper_desc", nvl(cst_api_operation_pkg.build_operation_desc(x.operation_id), x.oper_desc))
                        , xmlelement("auth_code", x.auth_code)
                        , xmlelement("balance_type", com_api_dictionary_pkg.get_article_text(x.balance_type, l_lang))
                        , xmlelement("balance_amount"
                                   , com_api_currency_pkg.get_amount_str(
                                         i_amount         => nvl(x.balance_amount, 0)
                                       , i_curr_code      => x.account_currency
                                       , i_mask_curr_code => com_api_type_pkg.TRUE
                                    ))
                    )
                    order by
                        balance_type
                        , posting_date
                        , transaction_id
                )
            )
        into
            l_detail
        from (
            select
                e.transaction_id
                , o.id operation_id
                , e.posting_date
                , o.oper_date
                , o.oper_currency currency
                , abs(o.oper_amount) amount
                , e.balance_impact
                , a.currency account_currency
                , e.amount account_amount
                , o.card_mask
                , o.auth_code
                , get_article_desc(o.oper_type)
                    ||'-'||o.merchant_name
                    ||'\'||o.merchant_postcode
                    ||'\'||o.merchant_street
                    ||'\'||o.merchant_city
                    ||'\'||o.merchant_region
                    ||'\'||o.merchant_country
                  as oper_desc
                , e.balance_type
                , sum(e.balance_impact*e.amount) over (partition by e.balance_type) as balance_amount
            from
                acc_account a
                , acc_entry e
                , acc_macros m
                , opr_operation_participant_vw o
            where
                a.account_number = i_account_number
                and e.account_id = a.id
                and e.balance_type in (
                    ACC_API_CONST_PKG.BALANCE_TYPE_LEDGER
                  , ACC_API_CONST_PKG.BALANCE_TYPE_HOLD)
                and e.posting_date between l_start_date and l_end_date
                and e.status != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                and m.id = e.macros_id
                and m.object_id = o.id
                and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                -- exclude unholded transactions
                and (case when e.balance_type = ACC_API_CONST_PKG.BALANCE_TYPE_HOLD
                          and (m.cancel_indicator = com_api_const_pkg.INDICATOR_CANCELED
                              or exists (select 1 from acc_entry x
                                          where x.bunch_id = e.bunch_id
                                            and e.balance_type = ACC_API_CONST_PKG.BALANCE_TYPE_LEDGER)
                              )
                          then 0
                          else 1
                    end) = 1
        ) x;
    exception
        when no_data_found then
            select xmlelement("operations", '')
              into l_detail
              from dual;

            trc_log_pkg.debug (
                i_text  => 'Operations not found'
            );
    end;

    select xmlelement ("report"
                      , l_header
                      , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text => 'cst_api_report_pkg.account_statement - ok'
    );
exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end account_statement;

procedure check_operations(
    o_xml                    out    clob
  , i_begin_oper_date            in date default null
  , i_end_oper_date              in date default null
  , i_network_id                 in com_api_type_pkg.t_network_id
  , i_sttl_date                  in com_api_type_pkg.t_tiny_id default null
  , i_file_id                    in com_api_type_pkg.t_long_id default null
  , i_lang                       in com_api_type_pkg.t_dict_value default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id
) is
  l_header                 xmltype;
  l_operations             xmltype;
  l_result                 xmltype;
  --
  l_lang                   com_api_type_pkg.t_dict_value;
  l_inst_id                com_api_type_pkg.t_inst_id;
  l_network_id             com_api_type_pkg.t_network_id;
  l_begin_oper_date        date;
  l_end_oper_date          date;
  l_session                com_api_type_pkg.t_long_id;
  l_upload_session_id      com_api_type_pkg.t_long_id;
  l_upload_process_id      com_api_type_pkg.t_medium_id;
  l_file_id_tab            num_tab_tpt       := num_tab_tpt();
  l_report_by_clearing     com_api_type_pkg.t_boolean;
  l_file_name              com_api_type_pkg.t_name;
  l_header_str             com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.check_operations [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_begin_oper_date
      , i_env_param3  => i_end_oper_date
      , i_env_param4  => i_lang
      , i_env_param5  => i_inst_id
    );
    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);
    l_network_id := nvl(i_network_id, 0);

    if i_sttl_date is not null then
        select sd.open_timestamp begin_oper_date
             , sd2.open_timestamp as end_oper_date
          into l_begin_oper_date
             , l_end_oper_date
          from com_settlement_day sd
          left join com_settlement_day sd2 on to_number(sd2.sttl_day) - 1 = sd.sttl_day
         where sd.sttl_day = i_sttl_date;
    else
        l_begin_oper_date := trunc(i_begin_oper_date);
        l_end_oper_date := trunc(i_end_oper_date);
    end if;

    begin
        l_session := get_session_id;
        trc_log_pkg.debug(
            i_text => 'Check process uploading clearing for session [' || l_session || '].'
        );
        trc_log_pkg.debug(
            i_text => 'Network_id = ' || l_network_id
        );

        select s.id as session_id
             , process_id
             , sf.file_name
          into l_upload_session_id
             , l_upload_process_id
             , l_file_name
          from prc_session  s
          join prc_session_file sf on sf.session_id = s.id
         where process_id in (10000012, 10000841, 10000990)
           and parent_id = (select parent_id
                              from prc_session
                             where id = l_session);

        select coalesce(f.id, vf.id, mf.id, sf.id) as file_id
          bulk collect into l_file_id_tab
          from prc_session_file sf
          left join mcw_file f  on f.session_file_id = sf.id
          left join vis_file vf on vf.session_file_id = sf.id
          left join mup_file mf on mf.session_file_id = sf.id
         where sf.session_id = l_upload_session_id;

        trc_log_pkg.debug(
            i_text => 'Process [' || l_upload_process_id || '] have session_id [' || l_upload_session_id || ']!'
        );

        l_report_by_clearing := 1;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text => 'Process uploading clearing not found!'
            );
            l_report_by_clearing := 0;
            if i_file_id is not null then -- Launched from reports for file clearing
                select coalesce(f.id, vf.id, sf.id) as file_id
                  bulk collect into l_file_id_tab
                  from prc_session_file sf
                  left join mcw_file f on f.session_file_id = sf.id
                  left join vis_file vf on vf.session_file_id = sf.id
                 where sf.session_id = i_file_id;

                select sf.file_name
                  into l_file_name
                  from prc_session_file sf
                 where sf.session_id = i_file_id;

                l_upload_session_id := i_file_id;
                trc_log_pkg.debug(
                    i_text => 'File have session_id [' || l_upload_session_id || '].'
                );
                l_report_by_clearing := 1;
            end if;
    end;

    l_header_str := case when l_end_oper_date is not null
                              then com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.period_from', i_lang => 'LANGRUS') || ' ' ||
                                   to_char(l_begin_oper_date, 'dd.mm.yyyy') ||
                                   com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.year', i_lang => 'LANGRUS') || ' ' ||
                                   com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.period_to', i_lang => 'LANGRUS') || ' ' ||
                                   to_char(l_end_oper_date, 'dd.mm.yyyy') ||
                                   com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.year', i_lang => 'LANGRUS')
                         else com_api_label_pkg.get_label_text(i_name => 'rpt_trnsl.clearing_file', i_lang => 'LANGRUS') || ' ' || l_file_name
                    end;
    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
          , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION', 'NAME', l_inst_id, l_lang))
          , xmlelement("header_str", l_header_str)
        )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
                     , xmlagg(xmlelement("operation"
                                , xmlelement("oper_id", id)
                                , xmlelement("host_date", host_date)
                                , xmlelement("oper_amount", oper_amount)
                                , xmlelement("oper_currency", oper_currency)
                                , xmlelement("oper_type", oper_type)
                                , xmlelement("is_reversal", is_reversal)
                                , xmlelement("original_id", original_id)
                                , xmlelement("status", status)
                                , xmlelement("status_reason", status_reason)
                                , xmlelement("send_bank", send_bank)
                                , xmlelement("send_clearing", send_clearing)
                                , xmlelement("accounting_1", accounting_1)
                                , xmlelement("second_clearing", second_clearing)
                                , xmlelement("accounting_2", accounting_2)
                                , xmlelement("reverse_clearing", reverse_clearing)
                                , xmlelement("merchant_account", merchant_account)
                                , xmlelement("merchant_name", merchant_name)
                                , xmlelement("sttl_currency", sttl_currency)
                                , xmlelement("network_id", network_id)
                                , xmlelement("network_type_name", network_type_name)
                                , xmlelement("acq_oper_type", acq_oper_type)
                                , xmlelement("card_mask", card_mask)
                                , xmlelement("processing_code", processing_code)
                                , xmlelement("reject_id", reject_id)
                                , xmlelement("m_file_name", m_file_name)
                                )
                            order by network_id, id
                            )
          )
        into l_operations
        from (
            select distinct
                   o.id
                 , to_char(o.host_date, 'dd.mm.yyyy hh24:mi:ss') as host_date
                 , decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, opr_api_const_pkg.OPERATION_TYPE_REFUND, -1, 1) *
                       round(o.oper_amount / nvl(power(10, curr.exponent), 1), 2) as oper_amount
                 , curr.name as oper_currency
                 , o.oper_type || ' - ' ||com_api_dictionary_pkg.get_article_text(i_article => o.oper_type) as oper_type
                 , o.is_reversal as is_reversal
                 , o.original_id
                 , o.status || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.status) as status
                 , case when o.status_reason is not null
                        then o.status_reason || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.status_reason)
                        else null
                   end as status_reason
                 , (select max(sf.file_date)
                      from prc_session_file sf
                      join cst_oper_file f on f.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and f.oper_id = o.id) as send_bank
                 , to_char(m.file_date, 'dd.mm.yyyy hh24:mi:ss') as send_clearing
                 , null as accounting_1
                 , null as second_clearing
                 , null as accounting_2
                 , null as reverse_clearing
                 , null as accounting_3
                 , (select max(a.account_number)
                      from acc_account_vw a
                         , acc_account_object_vw ao
                         , opr_participant p
                     where p.oper_id = o.id
                       and p.merchant_id = ao.object_id
                       and ao.account_id = a.id
                       and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and p.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)) as merchant_account
                 , o.merchant_name as merchant_name
                 , decode(nvl(r.country, '643'), '643', 'RUB', 'USD') as sttl_currency
                 , l_network_id as network_id
                 , 'VISA' as network_type_name
                 , case when cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                        then 'Customs payment'
                        when nvl(o.mcc, ' ') in ('6010', '6011')
                        then 'ATM'
                        when nvl(o.oper_type, ' ') in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                     , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                        then 'ATM'
                        when o.terminal_number in ('10000018', '10000019', '10000020')
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                        then 'POS'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                        then 'E-Commerce'
                   end as acq_oper_type
                 , nvl(op.card_mask, iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)) as card_mask
                 , null as processing_code
                 , null as reject_id
                 , null as m_file_name
              from opr_ui_operation_vw o
                 , opr_participant op
                 , com_currency_vw curr
                 , (select m.id
                         , f.file_date
                      from vis_fin_message m
                         , prc_session_file f
                     where m.status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
                       and m.file_id = f.id) m
                 , opr_card c
                 , vis_bin_range r
             where o.oper_currency = curr.code
               and op.oper_id = o.id
               and o.id = m.id(+)
               and o.id = c.oper_id(+)
               and rpad(c.card_number, 19, '0') >= r.pan_low (+)
               and rpad(c.card_number, 19, '0') <= r.pan_high (+)
               and o.msg_type != opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
               and o.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and op.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)
               and op.network_id in (1003, 5004)
               and cst_util_pkg.is_nonfinancial(o.oper_type) = com_api_const_pkg.FALSE
               and (cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                    and o.msg_type != opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                    or cst_util_pkg.is_custom(o.id) = com_api_const_pkg.FALSE
                    )
               and l_network_id = 1
               and l_end_oper_date is not null
               and (i_sttl_date is not null
                    and o.host_date between nvl(l_begin_oper_date, o.host_date)
                                        and nvl(l_end_oper_date, o.host_date)
                    or
                    i_sttl_date is null
                    and trunc(o.host_date) between nvl(l_begin_oper_date, trunc(o.host_date))
                                               and nvl(l_end_oper_date, trunc(o.host_date))
                    )
            union
            select distinct
                   o.id
                 , to_char(o.host_date, 'dd.mm.yyyy hh24:mi:ss') as host_date
                 , decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, opr_api_const_pkg.OPERATION_TYPE_REFUND, -1, 1) *
                       round(o.oper_amount / nvl(power(10, curr.exponent), 1), 2) as oper_amount
                 , curr.name as oper_currency
                 , o.oper_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.oper_type) as oper_type
                 , o.is_reversal as is_reversal
                 , o.original_id
                 , o.status || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.status) as status
                 , case when o.status_reason is not null
                        then o.status_reason || ' - ' ||
                             com_api_dictionary_pkg.get_article_text(i_article => o.status_reason)
                        else null
                   end as status_reason
                 , (select max(sf.file_date)
                      from prc_session_file sf
                      join cst_oper_file f on f.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and f.oper_id  = o.id) as send_bank
                 , to_char(m.file_date, 'dd.mm.yyyy hh24:mi:ss') as send_clearing
                 , null as accounting_1
                 , null as second_clearing
                 , null as accounting_2
                 , null as reverse_clearing
                 , null as accounting_3
                 , (select max(a.account_number)
                      from acc_account_vw a
                         , acc_account_object_vw ao
                         , opr_participant p
                     where p.oper_id = o.id
                       and p.merchant_id = ao.object_id
                       and ao.account_id = a.id
                       and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and p.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)) as merchant_account
                 , o.merchant_name as merchant_name
                 , decode(nvl(r.country, '643'), '643', 'RUB', 'USD') as sttl_currency
                 , l_network_id as network_id
                 , 'MasterCard' as network_type_name
                 , case when cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                        then 'Customs payment'
                        when nvl(o.mcc, ' ') in ('6010', '6011')
                        then 'ATM'
                        when nvl(o.oper_type, ' ') in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                     , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                        then 'ATM'
                        when o.terminal_number in ('10000018', '10000019', '10000020')
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                        then 'POS'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                        then 'E-Commerce'
                   end as acq_oper_type
                 , nvl(op.card_mask, iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)) as card_mask
                 , null as processing_code
                 , null as reject_id
                 , null as m_file_name
              from opr_ui_operation_vw o
                 , opr_participant op
                 , com_currency_vw curr
                 , (select m.id, f.file_date
                      from mcw_fin m
                         , mcw_file mf
                         , prc_session_file f
                     where m.status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
                       and m.file_id = mf.id
                       and mf.session_file_id = f.id) m
                 , opr_card c
                 , mcw_bin_range r
             where o.oper_currency = curr.code
               and op.oper_id = o.id
               and o.id = m.id(+)
               and o.id = c.oper_id(+)
               and rpad(c.card_number, 19, '0') >= r.pan_low (+)
               and rpad(c.card_number, 19, '0') <= r.pan_high (+)
               and o.msg_type != opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
               and o.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and op.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)
               and op.network_id in (1002, 7013)
               and cst_util_pkg.is_nonfinancial(o.oper_type) = com_api_const_pkg.FALSE
               and (cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                    and o.msg_type != opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                    or cst_util_pkg.is_custom(o.id) = com_api_const_pkg.FALSE
                    )
               and l_network_id = 2
               and l_end_oper_date is not null
               and (i_sttl_date is not null
                    and o.host_date between nvl(l_begin_oper_date, o.host_date)
                                        and nvl(l_end_oper_date, o.host_date)
                    or
                    i_sttl_date is null
                    and trunc(o.host_date) between nvl(l_begin_oper_date, trunc(o.host_date))
                                               and nvl(l_end_oper_date, trunc(o.host_date))
                    )
              union -- MIR transactions by date
             select distinct
                   o.id
                 , to_char(o.host_date, 'dd.mm.yyyy hh24:mi:ss') as host_date
                 , decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, opr_api_const_pkg.OPERATION_TYPE_REFUND, -1, 1) *
                       round(o.oper_amount / nvl(power(10, curr.exponent), 1), 2) as oper_amount
                 , curr.name as oper_currency
                 , o.oper_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.oper_type) as oper_type
                 , o.is_reversal as is_reversal
                 , o.original_id
                 , o.status || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.status) as status
                 , case when o.status_reason is not null
                        then o.status_reason || ' - ' ||
                             com_api_dictionary_pkg.get_article_text(i_article => o.status_reason)
                        else null
                    end as status_reason
                 , (select max(sf.file_date)
                      from prc_session_file sf
                      join cst_oper_file f on f.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and f.oper_id  = o.id) as send_bank
                 , to_char(m.file_date, 'dd.mm.yyyy hh24:mi:ss') as send_clearing
                 , null as accounting_1
                 , null as second_clearing
                 , null as accounting_2
                 , null as reverse_clearing
                 , null as accounting_3
                 , (select max(a.account_number)
                      from acc_account_vw a
                         , acc_account_object_vw ao
                         , opr_participant p
                     where p.oper_id = o.id
                       and p.merchant_id = ao.object_id
                       and ao.account_id = a.id
                       and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and p.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)) as merchant_account
                 , o.merchant_name as merchant_name
                 , decode(nvl(r.country, '643'), '643', 'RUB', 'USD') as sttl_currency
                 , l_network_id as network_id
                 , 'MIR' as network_type_name
                 , case when cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                        then 'Customs payment'
                        when nvl(o.mcc, ' ') in ('6010', '6011')
                        then 'ATM'
                        when nvl(o.oper_type, ' ') in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                     , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                        then 'ATM'
                        when o.terminal_number in ('10000018', '10000019', '10000020')
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                        then 'POS'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                        then 'E-Commerce'
                   end as acq_oper_type
                 , nvl(op.card_mask, iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)) as card_mask
                 , null as processing_code
                 , null as reject_id
                 , null as m_file_name
              from opr_ui_operation_vw o
                 , opr_participant op
                 , com_currency_vw curr
                 , (select m.id
                         , f.file_date
                      from mup_fin m
                         , mup_file mf
                         , prc_session_file f
                     where m.status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
                       and m.file_id = mf.id
                       and mf.session_file_id = f.id) m
                 , opr_card c
                 , mup_bin_range r
             where o.oper_currency = curr.code
               and op.oper_id = o.id
               and o.id = m.id(+)
               and o.id = c.oper_id(+)
               and rpad(c.card_number, 19, '0') >= r.pan_low (+)
               and rpad(c.card_number, 19, '0') <= r.pan_high (+)
               and o.msg_type != opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
               and o.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and op.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)
               and op.network_id = 7017
               and cst_util_pkg.is_nonfinancial(o.oper_type) = com_api_const_pkg.FALSE
               and (cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                    and o.msg_type != opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                    or cst_util_pkg.is_custom(o.id) = com_api_const_pkg.FALSE
                    )
               and l_network_id = 3
               and o.msg_type not in (opr_api_const_pkg.MESSAGE_TYPE_SPLIT)
               and l_end_oper_date is not null
               and (i_sttl_date is not null
                    and o.host_date between nvl(l_begin_oper_date, o.host_date)
                                        and nvl(l_end_oper_date, o.host_date)
                    or
                    i_sttl_date is null
                    and trunc(o.host_date) between nvl(l_begin_oper_date, trunc(o.host_date))
                                               and nvl(l_end_oper_date, trunc(o.host_date))
                   )
              union -- for l_report_by_clearing = 1
            select o.id
                 , to_char(o.host_date, 'dd.mm.yyyy hh24:mi:ss') as host_date
                 , decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, opr_api_const_pkg.OPERATION_TYPE_REFUND, -1, 1) *
                       round(o.oper_amount / nvl(power(10, curr.exponent), 1), 2) as oper_amount
                 , curr.name as oper_currency
                 , o.oper_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.oper_type) as oper_type
                 , o.is_reversal as is_reversal
                 , o.original_id
                 , o.status || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.status) as status
                 , case when o.status_reason is not null
                        then o.status_reason || ' - ' ||
                             com_api_dictionary_pkg.get_article_text(i_article => o.status_reason)
                        else null
                   end as status_reason
                 , (select max(sf.file_date)
                      from prc_session_file sf
                      join cst_oper_file f on f.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and f.oper_id  = o.id) as send_bank
                 , to_char(f.file_date, 'dd.mm.yyyy hh24:mi:ss') as send_clearing
                 , null as accounting_1
                 , case when m.reject_id is null then 'No' else 'Yes' end as second_clearing
                 , null as accounting_2
                 , null as reverse_clearing
                 , null as accounting_3
                 , (select max(a.account_number)
                      from acc_account_vw a
                         , acc_account_object_vw ao
                         , opr_participant p
                     where p.oper_id = o.id
                       and p.merchant_id = ao.object_id
                       and ao.account_id = a.id
                       and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and p.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)) as merchant_account
                 , o.merchant_name as merchant_name
                 , decode(nvl(p.card_country, '643'), '643', 'RUB', 'USD') as sttl_currency
                 , l_network_id as network_id
                 , 'MasterCard' as network_type_name
                 , case when cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                        then 'Customs payment'
                        when nvl(o.mcc, ' ') in ('6010', '6011')
                        then 'ATM'
                        when nvl(o.oper_type, ' ') in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                     , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                        then 'ATM'
                        when o.terminal_number in ('10000018', '10000019', '10000020')
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                        then 'POS'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                        then 'E-Commerce'
                   end as acq_oper_type
                 , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as card_mask
                 , decode(m.de003_1, '00', m.de003_1 || ' - Purchase',
                                     '01', m.de003_1 || ' - ATM Cash Withdrawal',
                                     '12', m.de003_1 || ' - Cash Disbursement',
                                     '17', m.de003_1 || ' - Convenience Check',
                                     '18', m.de003_1 || ' - Unique Transaction',
                                     '19', m.de003_1 || ' - Fee Collection',
                                     '20', m.de003_1 || ' - Refund',
                                     '28', m.de003_1 || ' - Payment Transaction',
                                     '29', m.de003_1 || ' - Fee Collection',
                                     m.de003_1 || ' - Other') as processing_code
                 , m.reject_id as reject_id
                 , (select max(sf.file_name)
                      from prc_session_file sf
                      join cst_oper_file ff on ff.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and ff.oper_id = o.id) as m_file_name
              from mcw_fin m
              join opr_ui_operation_vw o on o.id = m.id
              join opr_participant p     on p.oper_id = m.id
                                        and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              join mcw_file mf           on mf.id = m.file_id
              join prc_session_file f    on f.id = mf.session_file_id
              join com_currency_vw curr  on o.oper_currency = curr.code
              left join opr_card c       on c.oper_id = o.id
             where m.file_id member of l_file_id_tab
               and l_network_id = 2
               and l_report_by_clearing = 1
             union
            select o.id
                 , to_char(o.host_date, 'dd.mm.yyyy hh24:mi:ss') as host_date
                 , decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, opr_api_const_pkg.OPERATION_TYPE_REFUND, -1, 1) *
                       round(o.oper_amount / nvl(power(10, curr.exponent), 1), 2) as oper_amount
                 , curr.name as oper_currency
                 , o.oper_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.oper_type) as oper_type
                 , o.is_reversal as is_reversal
                 , o.original_id
                 , o.status || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.status) as status
                 , case when o.status_reason is not null
                        then o.status_reason || ' - ' ||
                             com_api_dictionary_pkg.get_article_text(i_article => o.status_reason)
                        else null
                   end as status_reason
                 , (select max(sf.file_date)
                      from prc_session_file sf
                      join cst_oper_file f on f.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and f.oper_id  = o.id) as send_bank
                 , to_char(f.file_date, 'dd.mm.yyyy hh24:mi:ss') as send_clearing
                 , null as accounting_1
                 , null as second_clearing
                 , null as accounting_2
                 , null as reverse_clearing
                 , null as accounting_3
                 , (select max(a.account_number)
                      from acc_account_vw a
                         , acc_account_object_vw ao
                         , opr_participant p
                     where p.oper_id = o.id
                       and p.merchant_id = ao.object_id
                       and ao.account_id = a.id
                       and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and p.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)) as merchant_account
                 , o.merchant_name as merchant_name
                 , decode(nvl(p.card_country, '643'), '643', 'RUB', 'USD') as sttl_currency
                 , l_network_id as network_id
                 , 'VISA' as network_type_name
                 , case when cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                        then 'Customs payment'
                        when nvl(o.mcc, ' ') in ('6010', '6011')
                        then 'ATM'
                        when nvl(o.oper_type, ' ') in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                     , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                        then 'ATM'
                        when o.terminal_number in ('10000018', '10000019', '10000020')
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                        then 'POS'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                        then 'E-Commerce'
                   end as acq_oper_type
                 , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as card_mask
                 , decode(v.trans_code, '05', v.trans_code || ' - Sales Draft',
                                        '06', v.trans_code || ' - Credit Voucher',
                                        '07', v.trans_code || ' - Cash Disbursement',
                                        '15', v.trans_code || ' - Chargeback, Sales Draft',
                                        '16', v.trans_code || ' - Chargeback, Credit Voucher',
                                        '17', v.trans_code || ' - Chargeback, Cash Disbursement',
                                        '25', v.trans_code || ' - Reversal, Sales Draft',
                                        '26', v.trans_code || ' - Reversal, Credit Voucher',
                                        '27', v.trans_code || ' - Reversal, Cash Disbursement',
                                        '35', v.trans_code || ' - Chargeback Reversal of Sales Draft',
                                        '36', v.trans_code || ' - Chargeback Reversal of Credit Voucher',
                                        '37', v.trans_code || ' - Chargeback Reversal of Cash Disbursement',
                                        v.trans_code || ' - Other') as processing_code
                 , null as reject_id
                 , null as m_file_name
              from vis_fin_message v
              join opr_ui_operation_vw o   on o.id = v.id
              join opr_participant p       on p.oper_id = v.id
                                          and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              join com_currency_vw curr    on o.oper_currency = curr.code
              left join vis_file vf        on vf.id = v.file_id
              left join prc_session_file f on f.id = vf.session_file_id
              left join opr_card c         on c.oper_id = o.id
             where file_id member of l_file_id_tab
               and l_network_id = 1
               and l_report_by_clearing = 1
             union -- MIR transactions from file
             select o.id
                 , to_char(o.host_date, 'dd.mm.yyyy hh24:mi:ss') as host_date
                 , decode(o.is_reversal, 1, -1, 1) * decode(o.oper_type, opr_api_const_pkg.OPERATION_TYPE_REFUND, -1, 1) *
                       round(o.oper_amount / nvl(power(10, curr.exponent), 1), 2) as oper_amount
                 , curr.name as oper_currency
                 , o.oper_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.oper_type) as oper_type
                 , o.is_reversal as is_reversal
                 , o.original_id
                 , o.status || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.status) as status
                 , case when o.status_reason is not null
                        then o.status_reason || ' - ' ||
                             com_api_dictionary_pkg.get_article_text(i_article => o.status_reason)
                        else null
                   end as status_reason
                 , (select max(sf.file_date)
                      from prc_session_file sf
                      join cst_oper_file f on f.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and f.oper_id  = o.id) as send_bank
                 , to_char(f.file_date, 'dd.mm.yyyy hh24:mi:ss') as send_clearing
                 , null as accounting_1
                 , case when m.reject_id is null then 'No' else 'Yes' end as second_clearing
                 , null as accounting_2
                 , null as reverse_clearing
                 , null as accounting_3
                 , (select max(a.account_number)
                      from acc_account_vw a
                         , acc_account_object_vw ao
                         , opr_participant p
                     where p.oper_id = o.id
                       and p.merchant_id = ao.object_id
                       and ao.account_id = a.id
                       and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and p.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)) as merchant_account
                 , o.merchant_name as merchant_name
                 , decode(nvl(p.card_country, '643'), '643', 'RUB', 'USD') as sttl_currency
                 , l_network_id as network_id
                 , 'MIR' as network_type_name
                 , case when cst_util_pkg.is_custom(o.id) = com_api_const_pkg.TRUE
                        then 'Customs payment'
                        when nvl(o.mcc, ' ') in ('6010', '6011')
                        then 'ATM'
                        when nvl(o.oper_type, ' ') in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                     , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                        then 'ATM'
                        when o.terminal_number in ('10000018', '10000019', '10000020')
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                        then 'ATM'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                        then 'POS'
                        when o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                        then 'E-Commerce'
                   end as acq_oper_type
                 , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as card_mask
                 , decode(m.de003_1, '00', m.de003_1 || ' - Purchase',
                                     '01', m.de003_1 || ' - ATM Cash Withdrawal',
                                     '12', m.de003_1 || ' - Cash Disbursement',
                                     '17', m.de003_1 || ' - Convenience Check',
                                     '18', m.de003_1 || ' - Unique Transaction',
                                     '19', m.de003_1 || ' - Fee Collection',
                                     '20', m.de003_1 || ' - Refund',
                                     '28', m.de003_1 || ' - Payment Transaction',
                                     '29', m.de003_1 || ' - Fee Collection',
                                     m.de003_1 || ' - Other') as processing_code
                 , m.reject_id as reject_id
                 , (select max(sf.file_name)
                      from prc_session_file sf
                      join cst_oper_file ff on ff.session_file_id = sf.id
                     where sf.file_type in ('FLTPOWME', 'FLTPOWMP', 'FLTPOWMA')
                       and ff.oper_id = o.id) as m_file_name
              from mup_fin m
              join opr_ui_operation_vw o on o.id = m.id
              join opr_participant p     on p.oper_id = m.id
                                        and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              join mup_file mf           on mf.id = m.file_id
              join prc_session_file f    on f.id = mf.session_file_id
              join com_currency_vw curr  on o.oper_currency = curr.code
              left join opr_card c       on c.oper_id = o.id
             where m.file_id member of l_file_id_tab
               and l_network_id = 3
               and l_report_by_clearing = 1
            );

    -- output
    select xmlelement("report"
                     , l_header
                     , l_operations
                   )
      into l_result
      from dual;

    for i in (
        select 1
          from dual
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
        select xmlelement("operations", xmlagg(xmlelement("operation")))
          into l_operations
          from dual;
    end loop;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'END cst_api_report_pkg.check_operations'
    );
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text => sqlerrm
        );
end check_operations;

function get_ica(
    i_inst_id    in    com_api_type_pkg.t_inst_id
  , i_network_id in    com_api_type_pkg.t_tiny_id default c_mc_sv2sv_nspk_network)
  return com_api_type_pkg.t_cmid is
    l_host_id            com_api_type_pkg.t_tiny_id;
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_return             com_api_type_pkg.t_cmid;
begin
    l_host_id      := net_api_network_pkg.get_host_id(i_inst_id, i_network_id);

    l_standard_id  := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    select distinct v.param_value
      into l_return
      from cmn_parameter p
         , net_api_interface_param_val_vw v
         , net_member m
     where p.name = mcw_api_const_pkg.CMID
       and p.standard_id    = l_standard_id
       and p.id             = v.param_id
       and m.id             = v.consumer_member_id
       and v.host_member_id = l_host_id
       and m.inst_id        = i_inst_id;

    return l_return;
end get_ica;

-- convert number to varchar2 with format 'xx xxx.xx'
function format(i_number in number) return varchar2 is
    l_return varchar2(30);
begin
    l_return := trim(to_char(i_number, '999G999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS = ''. '''));

    if substr(l_return, 1, 1) = '.' 
    or substr(l_return, 1, 2) = '-.' then
        l_return := replace(l_return, '.', '0.');
    end if;
    return l_return;
end format;

function get_payment_code(i_op_id      in number,
                          i_op_id_preu in number)
    return varchar2 is
    l_return com_api_type_pkg.t_dict_value;
begin
    if cst_util_pkg.is_cyberplat(i_oper_id => nvl(i_op_id_preu, i_op_id)) = com_api_const_pkg.TRUE then
        l_return := 'CP';
    end if;

    if l_return is null and cst_util_pkg.is_tag_exists(i_oper_id => nvl(i_op_id_preu, i_op_id), i_tag_id => 114) = com_api_const_pkg.TRUE then
       l_return := aup_api_tag_pkg.get_tag_value(i_auth_id => nvl(i_op_id_preu, i_op_id) ,i_tag_id => '114');
    end if;
    return l_return;
end get_payment_code;

-- Mastercard settlement report in RUR
procedure master_card_settl_rub(
    o_xml            out clob
  , i_report_date in     date default null
  , i_lang        in     com_api_type_pkg.t_dict_value default null
  , i_inst_id     in     com_api_type_pkg.t_inst_id    default null
) is
  l_header        xmltype;
  l_operations    xmltype;
  l_result        xmltype;

  l_lang          com_api_type_pkg.t_dict_value;
  l_inst_id       com_api_type_pkg.t_inst_id;
  l_inst_ica      com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.master_card_settlement [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_inst_id  := nvl(i_inst_id, 0);
    l_inst_ica := '00000'||get_ica(l_inst_id);

    -- header
    select xmlconcat(
               xmlelement("inst_id", l_inst_id)
             , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
             , xmlelement("report_date", to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
           )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("part",                       part)
                     , xmlelement("settlement_currency",        settlement_currency)
                     , xmlelement("activity",                   activity)
                     , xmlelement("file_id",                    file_id)
                     , xmlelement("message_type",               message_type)
                     , xmlelement("function_code",              function_code)
                     , xmlelement("transaction_type",           transaction_type)
                     , xmlelement("quantity",                   quantity)
                     , xmlelement("settlement_amount",          format(settlement_amount))
                     , xmlelement("settlement_fee",             format(settlement_fee))
                     , xmlelement("settlement_total",           format(settlement_total))
                     , xmlelement("clearing_currency",          clearing_currency)
                     , xmlelement("clearing_amount",            format(clearing_amount))
                     , xmlelement("file_name",                  file_name)
                     , xmlelement("tot_quantity",               tot_quantity)
                     , xmlelement("tot_settlement_amount",      format(tot_settlement_amount))
                     , xmlelement("tot_settlement_fee",         format(tot_settlement_fee))
                     , xmlelement("tot_settlement_total",       format(tot_settlement_total))
                     , xmlelement("tot_clearing_amount",        format(tot_clearing_amount))
                     , xmlelement("tot_settlement_total_p1_p2", format(tot_settlement_total_p1_p2))
                     , xmlelement("tot_clearing_amount_p1",     format(tot_clearing_amount_p1))
                     , xmlelement("tot_settlement_amount_p1",   format(tot_settlement_amount_p1))
                     , xmlelement("tot_settlement_amount_p2",   format(tot_settlement_amount_p2))
                     , xmlelement("diff1",                      format(diff1))
                     , xmlelement("diff2",                      format(diff2))
                     , xmlelement("exported",                   format(exported))
                     , xmlelement("not_exported",               format(not_exported))
                   )
                   order by part
                          , settlement_currency
                          , activity
                          , file_id
                          , message_type
                          , function_code
               )
           )
      into l_operations
      from (with t as -- PART 1, 2
               (select decode(substr(p0300, 1, 3), '002', 1, 2) as part
                     , de050 as settlement_currency
                     , decode(substr(p0300,1,3), '001', 'Issuing settled'
                                               , '021', 'Issuing settled'
                                               , '002', 'Acquiring settled'
                                               ,        'Acquiring settled') as activity
                     , substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6)  || '/' || 
                       substr(p0300, 10, 11)  || '/' || substr(p0300, 21, 5) as file_id
                     , p0372_1 || ' - ' || decode (p0372_1, '1240', 'Presentment'
                                                          , '1442', 'Chargeback'
                                                          , '1740', 'Fee Collection'
                                                          ,         'Other') as message_type
                     , p0372_2  || ' - ' ||decode (p0372_2, '200', 'First Presentment'
                                                          , '205', 'Second presentment (Full)'
                                                          , '282', 'Second presentment (Partial)'
                                                          , '450', 'First Chargeback (Full)'
                                                          , '451', 'Arbitration Chargeback (Full)'
                                                          , '453', 'First Chargeback (Partial)'
                                                          , '454', 'Arbitration Chargeback (Partial)'
                                                          ,        'Other') as function_code
                     , p0374 || ' - ' || decode(p0374, '00', 'Purchase'
                                                     , '01', 'ATM Cash Withdrawal'
                                                     , '12', 'Cash Disbursement'
                                                     , '17', 'Convenience Check'
                                                     , '18', 'Unique Transaction'
                                                     , '19', 'Fee Collection'
                                                     , '20', 'Refund'
                                                     , '28', 'Payment Transaction'
                                                     , '29', 'Fee Collection'
                                                     ,       'Other') as transaction_type
                     , p0402 as quantity
                     , p0394_2 * decode(p0394_1, 'D', -1, 1) / 100 as settlement_amount
                     , p0395_2 * decode(p0395_1, 'D', -1, 1) / 100 as settlement_fee
                     , p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 as settlement_total
                     , de049 as clearing_currency
                     , p0384_2 * decode(p0384_1, 'D', -1, 1) / 100 as clearing_amount
                     , null as file_name
                  from mcw_fpd mf
                 where substr(p0300,  1,  3) || '/' || substr(p0300,  4, 6) || '/' ||
                       substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4)
                    in ('002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'
                      , '021/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0110')
                   and de050 = 643
                 union all -- PART 3
                select distinct 
                       3 as part
                     , clearing_currency
                     , 'Acquirer processed' as activity
                     , file_id
                     , message_type
                     , function_code
                     , transaction_type
                     , count(*) over (partition by payment_network
                                                 , clearing_currency
                                                 , file_date
                                                 , file_id
                                                 , message_type
                                                 , function_code
                                                 , transaction_type
                                                 , m_file_name) as quantity
                     , null as settlement_amount
                     , null as settlement_fee
                     , null as settlement_total
                     , null as clearing_currency
                     , sum(clearing_amount) over (partition by payment_network
                                                             , clearing_currency
                                                             , file_date
                                                             , file_id
                                                             , message_type
                                                             , function_code
                                                             , transaction_type
                                                             , m_file_name) as clearing_amount
                     , m_file_name as file_name
                  from (select payment_network
                             , mastercard_file_id as file_id
                             , mastercard_file_date as file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount as clearing_amount
                             , transaction_currency as clearing_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution
                             , listagg (m_file_name, ',') within group (order by transaction_id) as m_file_name
                          from (select decode(mff.network_id, '1002', 'MasterCard'
                                                            , '7013', 'MasterCard'
                                                            , '1009', 'MasterCard NSPK'
                                                            , '7014', 'MasterCard NSPK'
                                                            ,         mff.network_id) as payment_network
                                     , substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                     , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                     , mf.id as transaction_id
                                     , mc.card_number as card_number
                                     , decode(mf.mti, '1240', mf.mti || ' - Presentment'
                                                    , '1442', mf.mti || ' - Chargeback'
                                                    , '1740', mf.mti || ' - Fee collection'
                                                    ,         mf.mti || ' - Other') as message_type
                                     , mf.de024 || ' - ' || decode (mf.de024, '200', 'First Presentment'
                                                                            , '205', 'Second presentment (Full)'
                                                                            , '282', 'Second presentment (Partial)'
                                                                            , '450', 'First Chargeback (Full)'
                                                                            , '451', 'Arbitration Chargeback (Full)'
                                                                            , '453', 'First Chargeback (Partial)'
                                                                            , '454', 'Arbitration Chargeback (Partial)'
                                                                            , '700', 'Fee Collection (Member-generated)'
                                                                            , '780', 'Fee Collection Return'
                                                                            , '781', 'Fee Collection Resubmission'
                                                                            , '782', 'Fee Collection Arbitration Return'
                                                                            , '783', 'Fee Collection (Clearing System-generated)'
                                                                            , '790', 'Fee Collection (Funds Transfer)'
                                                                            , '791', 'Fee Collection (Funds Transfer Backout)'
                                                                            ,        'Other') as function_code
                                     , mf.de003_1 || ' - ' || decode(mf.de003_1, '00', 'Purchase'
                                                                               , '01', 'ATM Cash Withdrawal'
                                                                               , '12', 'Cash Disbursement'
                                                                               , '17', 'Convenience Check'
                                                                               , '18', 'Unique Transaction'
                                                                               , '19', 'Fee Collection'
                                                                               , '20', 'Refund'
                                                                               , '28', 'Payment Transaction'
                                                                               , '29', 'Fee Collection'
                                                                               ,       'Other') as transaction_type
                                     , decode(oo.is_reversal, 0, 'No'
                                                            , 1, 'Yes'
                                                            ,    'Unknown') as reversal_indicator
                                     , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                     , decode(mf.de003_1, '00', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '01', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '12', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '17', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '18', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '19', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '20', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        , '28', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        , '29', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        ,       decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)) as transaction_amount
                                     , de049 as transaction_currency
                                     , mf.de005 / 100 as settlement_amount
                                     , de050 as settlement_currency
                                     , de038 as approval_code
                                     , de037 as rrn
                                     , de031 as arn
                                     , de041 as terminal_id
                                     , de042 as merchant_id
                                     , de026 as mcc
                                     , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                       rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                     , decode(mf.de025, null,   mf.de025
                                                      , '1400', mf.de025 || ' - Not previously authorized'
                                                      , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                      , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                      , '2011', mf.de025 || ' - Credit previously issued'
                                                      , '2700', mf.de025 || ' - Chargeback remedied'
                                                      , '4808', mf.de025 || ' - Required authorization not obtained'
                                                      , '4809', mf.de025 || ' - Transaction not reconciled'
                                                      , '4831', mf.de025 || ' - Transaction amount differs'
                                                      , '4834', mf.de025 || ' - Duplicate processing'
                                                      , '4842', mf.de025 || ' - Late presentment'
                                                      , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                      , '4859', mf.de025 || ' - Service not rendered'
                                                      , '4860', mf.de025 || ' - Credit not processed'
                                                      , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                      , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                      , '6341', mf.de025 || ' - Fraud investigation'
                                                      , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                      , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                      , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                      , '7800', mf.de025 || ' - MasterCard member settlement'
                                                      ,         mf.de025 || ' - Other') as reason_code
                                     , de093 as destination_institution
                                     , mf.de094 as originator_institution
                                     , decode(mf.inst_id, '9945', 'Customs payment', pcf.file_name) as m_file_name
                                  from mcw_fin mf
                                  join mcw_card mc              on mf.id = mc.id
                                  join mcw_file mff             on mff.id = mf.file_id
                                                               and mff.network_id in (1009, 7014)
                                 join opr_operation oo          on oo.id = mf.id
                                 left join cst_oper_file cof    on cof.oper_id = oo.id
                                 left join prc_session_file pcf on pcf.id = cof.session_file_id
                                where substr(mff.p0105,  1,  3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                      substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 4)
                                   in ('002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'))
                             group by payment_network
                                    , mastercard_file_id
                                    , mastercard_file_date
                                    , message_type
                                    , function_code
                                    , transaction_type
                                    , reversal_indicator
                                    , transaction_id
                                    , card_number
                                    , transaction_date
                                    , transaction_amount
                                    , transaction_currency
                                    , settlement_amount
                                    , settlement_currency
                                    , approval_code
                                    , rrn
                                    , arn
                                    , terminal_id
                                    , merchant_id
                                    , mcc
                                    , merchant
                                    , reason_code
                                    , destination_institution
                                    , originator_institution)
                         union all -- PART 4
                        select distinct
                               4 as part
                             , settlement_currency as clearing_currency
                             , 'Issuer processed' as activity
                             , file_id
                             , message_type
                             , function_code
                             , transaction_type
                             , count(*) over (partition by settlement_currency
                                                         , file_date
                                                         , file_id
                                                         , message_type
                                                         , function_code
                                                         , transaction_type
                                                         , c_file) as quantity
                             , null as settlement_amount
                             , null as settlement_fee
                             , null as settlement_total
                             , null as clearing_currency
                             , sum(settlement_amount) over (partition by settlement_currency
                                                                       , file_date
                                                                       , file_id
                                                                       , message_type
                                                                       , function_code
                                                                       , transaction_type
                                                                       , c_file) as clearing_amount
                             , c_file as file_name
                         from (select mastercard_file_id as file_id
                                    , mastercard_file_date as file_date
                                    , message_type
                                    , function_code
                                    , transaction_type
                                    , reversal_indicator
                                    , transaction_id
                                    , card_number
                                    , transaction_date
                                    , transaction_amount
                                    , transaction_currency
                                    , settlement_amount
                                    , settlement_currency
                                    , approval_code
                                    , rrn
                                    , arn
                                    , terminal_id
                                    , merchant_id
                                    , mcc
                                    , merchant
                                    , reason_code
                                    , destination_institution
                                    , originator_institution
                                    , listagg (c_file_name, ',') 
                                      within group (order by substr(c_file_name
                                                                  , instr(c_file_name,'.')+1
                                                                  , 3)
                                                          || substr(c_file_name
                                                                  , instr(c_file_name, '__') + 3
                                                                  , instr(c_file_name, '.') - instr(c_file_name, '__') - 2)
                                                   ) as c_file
                                 from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                              substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                            , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                            , mf.id as transaction_id
                                            , mc.card_number as card_number
                                            , mf.mti || ' - ' || decode (mf.mti, '1240', 'Presentment'
                                                                               , '1442', 'Chargeback'
                                                                               , '1740', 'Fee collection',
                                                                                         'Other') as message_type
                                            , mf.de024 || ' - ' || decode (mf.de024, '200', 'First Presentment'
                                                                                   , '205', 'Second presentment (Full)'
                                                                                   , '282', 'Second presentment (Partial)'
                                                                                   , '450', 'First Chargeback (Full)'
                                                                                   , '451', 'Arbitration Chargeback (Full)'
                                                                                   , '453', 'First Chargeback (Partial)'
                                                                                   , '454', 'Arbitration Chargeback (Partial)'
                                                                                   , '700', 'Fee Collection (Member-generated)'
                                                                                   , '780', 'Fee Collection Return'
                                                                                   , '781', 'Fee Collection Resubmission'
                                                                                   , '782', 'Fee Collection Arbitration Return'
                                                                                   , '783', 'Fee Collection (Clearing System-generated)'
                                                                                   , '790', 'Fee Collection (Funds Transfer)'
                                                                                   , '791', 'Fee Collection (Funds Transfer Backout)'
                                                                                   ,        'Other') as function_code
                                            , mf.de003_1 || ' - ' || decode(mf.de003_1, '00', 'Purchase',
                                                                                        '01', 'ATM Cash Withdrawal',
                                                                                        '12', 'Cash Disbursement',
                                                                                        '17', 'Convenience Check',
                                                                                        '18', 'Unique Transaction',
                                                                                        '19', 'Fee Collection',
                                                                                        '20', 'Refund',
                                                                                        '28', 'Payment Transaction',
                                                                                        '29', 'Fee Collection',
                                                                                              'Other') as transaction_type
                                            , decode(oo.is_reversal, 0, 'No'
                                                                   , 1, 'Yes',
                                                                        'Unknown') as reversal_indicator
                                            , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                            , mf.de004 / 100 as transaction_amount
                                            , de049 as transaction_currency
                                            , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                               , '26', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                               , '28', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                               , '29', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100),
                                                                       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100))
                                                * decode(l_inst_ica, '00000017621', -1, 1) as settlement_amount
                                            , de050 as settlement_currency
                                            , de038 as approval_code
                                            , de037 as rrn
                                            , de031 as arn
                                            , de041 as terminal_id
                                            , de042 as merchant_id
                                            , de026 as mcc
                                            , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                              rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                            , decode(mf.de025, null,   mf.de025
                                                             , '1400', mf.de025 || ' - Not previously authorized'
                                                             , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                             , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                             , '2011', mf.de025 || ' - Credit previously issued'
                                                             , '2700', mf.de025 || ' - Chargeback remedied'
                                                             , '4808', mf.de025 || ' - Required authorization not obtained'
                                                             , '4809', mf.de025 || ' - Transaction not reconciled'
                                                             , '4831', mf.de025 || ' - Transaction amount differs'
                                                             , '4834', mf.de025 || ' - Duplicate processing'
                                                             , '4842', mf.de025 || ' - Late presentment'
                                                             , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                             , '4859', mf.de025 || ' - Service not rendered'
                                                             , '4860', mf.de025 || ' - Credit not processed'
                                                             , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                             , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                             , '6341', mf.de025 || ' - Fraud investigation'
                                                             , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                             , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                             , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                             , '7800', mf.de025 || ' - MasterCard member settlement'
                                                             ,         mf.de025 || ' - Other') as reason_code
                                            , de093 as destination_institution
                                            , mf.de094 as originator_institution
                                            , pcf.file_name as c_file_name
                                         from mcw_fin mf
                                         join mcw_card mc               on mf.id = mc.id
                                         join mcw_file mff              on mff.id = mf.file_id
                                         join opr_operation oo          on oo.id = mf.id
                                         left join cst_oper_file cof    on cof.oper_id = mf.id
                                         left join prc_session_file pcf on pcf.id = cof.session_file_id
                                        where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' ||
                                              substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                                                in ('021/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/01101')
                                          and not mf.de003_1 = '28'
                                        union all
                                       select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                              substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                            , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                            , mf.id as transaction_id
                                            , mc.card_number as card_number
                                            , mf.mti || ' - ' || decode (mf.mti, '1240', 'Presentment'
                                                                               , '1442', 'Chargeback'
                                                                               , '1740', 'Fee collection'
                                                                               ,         'Other') as message_type
                                            , mf.de024 || ' - ' || decode (mf.de024, '200', 'First Presentment'
                                                                                   , '205', 'Second presentment (Full)'
                                                                                   , '282', 'Second presentment (Partial)'
                                                                                   , '450', 'First Chargeback (Full)'
                                                                                   , '451', 'Arbitration Chargeback (Full)'
                                                                                   , '453', 'First Chargeback (Partial)'
                                                                                   , '454', 'Arbitration Chargeback (Partial)'
                                                                                   , '700', 'Fee Collection (Member-generated)'
                                                                                   , '780', 'Fee Collection Return'
                                                                                   , '781', 'Fee Collection Resubmission'
                                                                                   , '782', 'Fee Collection Arbitration Return'
                                                                                   , '783', 'Fee Collection (Clearing System-generated)'
                                                                                   , '790', 'Fee Collection (Funds Transfer)'
                                                                                   , '791', 'Fee Collection (Funds Transfer Backout)'
                                                                                   ,        'Other') as function_code
                                            , mf.de003_1 || ' - ' || decode(mf.de003_1, '00', 'Purchase'
                                                                                      , '01', 'ATM Cash Withdrawal'
                                                                                      , '12', 'Cash Disbursement'
                                                                                      , '17', 'Convenience Check'
                                                                                      , '18', 'Unique Transaction'
                                                                                      , '19', 'Fee Collection'
                                                                                      , '20', 'Refund'
                                                                                      , '28', 'Payment Transaction'
                                                                                      , '29', 'Fee Collection'
                                                                                      ,       'Other') as transaction_type
                                            , decode(oo.is_reversal, 0, 'No'
                                                                   , 1, 'Yes'
                                                                   ,    'Unknown') as reversal_indicator
                                            , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                            , mf.de004/100 as transaction_amount
                                            , de049 as transaction_currency
                                            , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                               , '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                               , '28', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                               , '29', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                               ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100))
                                                * decode(l_inst_ica, '00000017621', -1, 1) as settlement_amount
                                            , de050 as settlement_currency
                                            , de038 as approval_code
                                            , de037 as rrn
                                            , de031 as arn
                                            , de041 as terminal_id
                                            , de042 as merchant_id
                                            , de026 as mcc
                                            , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                              rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                            , decode(mf.de025, null,   mf.de025
                                                             , '1400', mf.de025 || ' - Not previously authorized'
                                                             , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                             , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                             , '2011', mf.de025 || ' - Credit previously issued'
                                                             , '2700', mf.de025 || ' - Chargeback remedied'
                                                             , '4808', mf.de025 || ' - Required authorization not obtained'
                                                             , '4809', mf.de025 || ' - Transaction not reconciled'
                                                             , '4831', mf.de025 || ' - Transaction amount differs'
                                                             , '4834', mf.de025 || ' - Duplicate processing'
                                                             , '4842', mf.de025 || ' - Late presentment'
                                                             , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                             , '4859', mf.de025 || ' - Service not rendered'
                                                             , '4860', mf.de025 || ' - Credit not processed'
                                                             , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                             , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                             , '6341', mf.de025 || ' - Fraud investigation'
                                                             , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                             , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                             , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                             , '7800', mf.de025 || ' - MasterCard member settlement'
                                                             ,         mf.de025 || ' - Other') as reason_code
                                            , de093 as destination_institution
                                            , mf.de094 as originator_institution
                                            , pcf.file_name as c_file_name
                                         from mcw_fin mf
                                         join mcw_card mc               on mf.id = mc.id
                                         join mcw_file mff              on mff.id = mf.file_id
                                         join opr_operation oo          on oo.id = mf.id
                                         left join cst_oper_file cof    on cof.oper_id = oo.match_id
                                         left join prc_session_file pcf on pcf.id = cof.session_file_id
                                        where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' ||
                                              substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                                           in ('021/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/01101')
                                          and mf.de003_1 = '28')
                                     group by mastercard_file_id
                                            , mastercard_file_date
                                            , message_type
                                            , function_code
                                            , transaction_type
                                            , reversal_indicator
                                            , transaction_id
                                            , card_number
                                            , transaction_date
                                            , transaction_amount
                                            , transaction_currency
                                            , settlement_amount
                                            , settlement_currency
                                            , approval_code
                                            , rrn
                                            , arn
                                            , terminal_id
                                            , merchant_id
                                            , mcc
                                            , merchant
                                            , reason_code
                                            , destination_institution
                                            , originator_institution))
              select a.*
                   , a.tot_clearing_amount_p1 - tot_clearing_amount as diff1
                   , a.tot_settlement_amount_p2 * decode(l_inst_ica, '00000017621', -1, 1) - tot_clearing_amount as diff2
                   , a.tot_clearing_amount - a.not_exported as exported
                from (select t.part
                           , t.settlement_currency
                           , t.activity
                           , t.file_id
                           , t.message_type
                           , t.function_code
                           , t.transaction_type
                           , t.quantity
                           , t.settlement_amount
                           , t.settlement_fee
                           , t.settlement_total
                           , t.clearing_currency
                           , t.clearing_amount
                           , t.file_name
                           , sum(t.quantity)          over (partition by t.part) as tot_quantity
                           , sum(t.settlement_amount) over (partition by t.part) as tot_settlement_amount
                           , sum(t.settlement_fee)    over (partition by t.part) as tot_settlement_fee
                           , sum(t.settlement_total)  over (partition by t.part) as tot_settlement_total
                           , sum(t.clearing_amount)   over (partition by t.part) as tot_clearing_amount
                           , sum(decode(t.part, 1, t.settlement_total, 2, t.settlement_total, 0)) over () as tot_settlement_total_p1_p2
                           , sum(case when t.part = 1          then t.clearing_amount   else 0 end) over () as tot_clearing_amount_p1
                           , sum(case when t.part = 1          then t.settlement_amount else 0 end) over () as tot_settlement_amount_p1
                           , sum(case when t.part = 2          then t.settlement_amount else 0 end) over () as tot_settlement_amount_p2
                           , sum(case when t.file_name is null then t.clearing_amount else 0 end) over (partition by t.part) as not_exported
                        from t) a);

    -- fill with "operation" tag for empty reports creation
    for i in (select 1 
                from dual 
               where existsnode(l_operations, '/operations/operation') = 0) loop
        select xmlelement("operations", xmlagg(xmlelement("operation"))) 
          into l_operations 
          from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.master_card_settlement');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end master_card_settl_rub;

-- Mastercard settlement report in USD
procedure master_card_settl_usd(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
) is
  l_header         xmltype;
  l_operations     xmltype;
  l_result         xmltype;

  l_lang           com_api_type_pkg.t_dict_value;
  l_inst_id        com_api_type_pkg.t_inst_id;
  l_inst_ica       com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_sttl_report_pkg.master_card_settl_usd [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_inst_id  := nvl(i_inst_id, 0);
    l_inst_ica := '00000'||get_ica(l_inst_id);

    -- header
    select xmlconcat(
               xmlelement("inst_id", l_inst_id)
                 , xmlelement("inst",             com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
                 , xmlelement("report_date",      to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
                 , xmlelement("report_next_date", to_char(nvl(i_report_date + 1, sysdate),'dd.mm.yyyy'))
           )
      into l_header
      from dual;

  -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("part",                     part)
                     , xmlelement("settlement_currency",      settlement_currency)
                     , xmlelement("activity",                 activity)
                     , xmlelement("file_id",                  file_id)
                     , xmlelement("message_type",             message_type)
                     , xmlelement("function_code",            function_code)
                     , xmlelement("transaction_type",         transaction_type)
                     , xmlelement("quantity",                 quantity)
                     , xmlelement("settlement_amount",        format(settlement_amount))
                     , xmlelement("settlement_fee",           format(settlement_fee))
                     , xmlelement("settlement_total",         format(settlement_total))
                     , xmlelement("clearing_currency",        clearing_currency)
                     , xmlelement("clearing_amount",          format(clearing_amount))
                     , xmlelement("file_name",                file_name)
                     , xmlelement("tot_quantity",             tot_quantity)
                     , xmlelement("tot_settlement_amount",    format(tot_settlement_amount))
                     , xmlelement("tot_settlement_fee",       format(tot_settlement_fee))
                     , xmlelement("tot_clearing_amount",      format(tot_clearing_amount))
                     , xmlelement("tot_settlement_total_p1",  format(tot_settlement_total_p1))
                     , xmlelement("tot_settlement_total_p2",  format(tot_settlement_total_p2))
                     , xmlelement("tot_clearing_amount_p1",   format(tot_clearing_amount_p1))
                     , xmlelement("tot_settlement_amount_p1", format(tot_settlement_amount_p1))
                     , xmlelement("tot_settlement_amount_p2", format(tot_settlement_amount_p2))
                     , xmlelement("diff1",                    format(diff1))
                     , xmlelement("diff2",                    format(diff2))
                     , xmlelement("exported",                 format(exported))
                     , xmlelement("not_exported",             format(not_exported))
                     , xmlelement("clearing_cycle_1_pre",     format(clearing_cycle_1_pre))
                     , xmlelement("clearing_cycle_2_pre",     format(clearing_cycle_2_pre))
                     , xmlelement("clearing_cycle_2_pre_sum", format(clearing_cycle_2_pre_sum))
                     , xmlelement("clearing_cycle_3",         format(clearing_cycle_3))
                     , xmlelement("clearing_cycle_3_sum",     format(clearing_cycle_3_sum))
                     , xmlelement("clearing_cycle_4",         format(clearing_cycle_4))
                     , xmlelement("clearing_cycle_4_sum",     format(clearing_cycle_4_sum))
                     , xmlelement("clearing_cycle_5",         format(clearing_cycle_5))
                     , xmlelement("clearing_cycle_5_sum",     format(clearing_cycle_5_sum))
                     , xmlelement("clearing_cycle_6",         format(clearing_cycle_6))
                     , xmlelement("clearing_cycle_6_sum",     format(clearing_cycle_6_sum))
                     , xmlelement("clearing_cycle_1",         format(clearing_cycle_1))
                     , xmlelement("clearing_cycle_1_sum",     format(clearing_cycle_1_sum))
                     , xmlelement("clearing_cycle_2",         format(clearing_cycle_2))
                     , xmlelement("clearing_cycle_2_sum",     format(clearing_cycle_2_sum))
                   ) 
                   order by part
                          , settlement_currency
                          , activity
                          , file_id
                          , message_type
                          , function_code
                )
           )
      into l_operations
      from(with t as 
              -- PART 1, 2
              (select decode(substr(p0300, 1, 3), '001', 2, 1) as part
                    , de050 as settlement_currency
                    , decode(substr(p0300,1,3), '001', 'Issuing settled'
                                              , '021', 'Issuing settled'
                                              , '002', 'Acquiring settled'
                                              ,        'Acquiring settled') as activity
                    , substr(p0300, 1, 3)    || '/' || substr(p0300, 4, 6)  || '/' || 
                      substr(p0300, 10, 11)  || '/' || substr(p0300, 21, 5) as file_id
                    , p0372_1 || ' - ' || decode (p0372_1, '1240', 'Presentment'
                                                         , '1442', 'Chargeback'
                                                         , '1740', 'Fee Collection'
                                                         , 'Other') as message_type
                    , p0372_2 || ' - ' || decode (p0372_2, '200', 'First Presentment'
                                                         , '205', 'Second presentment (Full)'
                                                         , '282', 'Second presentment (Partial)'
                                                         , '450', 'First Chargeback (Full)'
                                                         , '451', 'Arbitration Chargeback (Full)'
                                                         , '453', 'First Chargeback (Partial)'
                                                         , '454', 'Arbitration Chargeback (Partial)'
                                                         ,        'Other') as function_code
                    , p0374 || ' - ' || decode(p0374, '00', 'Purchase'
                                                    , '01', 'ATM Cash Withdrawal'
                                                    , '12', 'Cash Disbursement'
                                                    , '17', 'Convenience Check'
                                                    , '18', 'Unique Transaction'
                                                    , '19', 'Fee Collection'
                                                    , '20', 'Refund'
                                                    , '28', ' Payment Transaction'
                                                    , '29', 'Fee Collection'
                                                    ,       'Other') as transaction_type
                    , case when substr(p0300,1,3) not in ('901', '904') then p0402 else null end as quantity
                    , p0394_2 * decode(p0394_1, 'D', -1, 1) / 100 as settlement_amount
                    , p0395_2 * decode(p0395_1, 'D', -1, 1) / 100 as settlement_fee
                    , p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 as settlement_total
                    , de049 as clearing_currency
                    , case when substr(p0300, 1, 3) not in ('901', '904') 
                           then p0384_2 * decode(p0384_1, 'D', -1, 1) / 100 
                           else null end as clearing_amount
                    , sf.file_name
                 from mcw_fpd mf
            left join mcw_file f          on f.id = mf.file_id
            left join prc_session_file sf on sf.id = f.session_file_id
                where de050 = 840
                  and ((substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4)
                    = '002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000')
                   or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5) 
                      in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/03301'
                        , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/04401'
                        , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                        , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                        , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                        , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                   or (mf.file_id in (select distinct file_id 
                                        from mcw_fpd mf
                                       where ((substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                               substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4) 
                                           =  '002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'
                                          or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                             substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5) 
                                          in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/03301'
                                            , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/04401'
                                            , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                                            , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                                            , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                            , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201'))
                                         and de050 = 840))
                  and substr(p0300,1,3) in ('901', '904')))
                union all -- PART 3
               select distinct
                      3 as part
                    , clearing_currency
                    , 'Acquirer processed' as activity
                    , file_id
                    , message_type
                    , function_code
                    , transaction_type
                    , count(*) over (partition by payment_network
                                                , clearing_currency
                                                , file_date
                                                , file_id
                                                , message_type
                                                , function_code
                                                , transaction_type
                                                , m_file_name) as quantity
                    , null as settlement_amount
                    , null as settlement_fee
                    , null as settlement_total
                    , null as clearing_currency
                    , sum(clearing_amount) over (partition by payment_network
                                                            , clearing_currency
                                                            , file_date
                                                            , file_id
                                                            , message_type
                                                            , function_code
                                                            , transaction_type
                                                            , m_file_name) as clearing_amount
                    , m_file_name as file_name
                 from (select payment_network
                            , mastercard_file_id as file_id
                            , mastercard_file_date as file_date
                            , message_type
                            , function_code
                            , transaction_type
                            , reversal_indicator
                            , transaction_id
                            , card_number
                            , transaction_date
                            , transaction_amount as clearing_amount
                            , transaction_currency as clearing_currency
                            , settlement_amount
                            , settlement_currency
                            , approval_code
                            , rrn
                            , arn
                            , terminal_id
                            , merchant_id
                            , mcc
                            , merchant
                            , reason_code
                            , destination_institution
                            , originator_institution
                            , listagg (m_file_name, ',') within group (order by transaction_id) as m_file_name
                         from (select decode(mff.network_id, '1002', 'MasterCard'
                                                           , '7013', 'MasterCard'
                                                           , '1009', 'MasterCard NSPK'
                                                           , '7014', 'MasterCard NSPK'
                                                           ,         mff.network_id) as payment_network
                                    , substr(mff.p0105, 1,  3) || '/' || substr(mff.p0105, 4,  6) || '/' ||
                                      substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21,  5)as mastercard_file_id
                                    , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                    , mf.id as transaction_id
                                    , mc.card_number as card_number
                                    , mf.mti || ' - ' || decode(mf.mti, '1240', ' - Presentment'
                                                                      , '1442', 'Chargeback'
                                                                      , '1740', 'Fee collection'
                                                                      ,         'Other') as message_type
                                    , mf.de024 || ' - ' || decode(mf.de024, '200', 'First Presentment'
                                                                          , '205', 'Second presentment (Full)'
                                                                          , '282', 'Second presentment (Partial)'
                                                                          , '450', 'First Chargeback (Full)'
                                                                          , '451', 'Arbitration Chargeback (Full)'
                                                                          , '453', 'First Chargeback (Partial)'
                                                                          , '454', 'Arbitration Chargeback (Partial)'
                                                                          , '700', 'Fee Collection (Member-generated)'
                                                                          , '780', 'Fee Collection Return'
                                                                          , '781', 'Fee Collection Resubmission'
                                                                          , '782', 'Fee Collection Arbitration Return'
                                                                          , '783', 'Fee Collection (Clearing System-generated)'
                                                                          , '790', 'Fee Collection (Funds Transfer)'
                                                                          , '791', 'Fee Collection (Funds Transfer Backout)'
                                                                          ,        'Other') as function_code
                                    , mf.de003_1 || ' - ' || decode(mf.de003_1, '00', 'Purchase'
                                                                              , '01', 'ATM Cash Withdrawal'
                                                                              , '12', 'Cash Disbursement'
                                                                              , '17', 'Convenience Check'
                                                                              , '18', 'Unique Transaction'
                                                                              , '19', 'Fee Collection'
                                                                              , '20', 'Refund'
                                                                              , '28', 'Payment Transaction'
                                                                              , '29', 'Fee Collection'
                                                                              ,       'Other') as transaction_type
                                    , decode(oo.is_reversal, 0, 'No'
                                                           , 1, 'Yes'
                                                           ,    'Unknown') as reversal_indicator
                                    , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                    , decode(mf.de003_1, '00', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                       , '01', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                       , '12', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                       , '17', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                       , '18', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                       , '19', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                       , '20', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                       , '28', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                       , '29', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                       ,       decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)) as transaction_amount
                                    , de049 as transaction_currency
                                    , mf.de005/100 as settlement_amount
                                    , de050 as settlement_currency
                                    , de038 as approval_code
                                    , de037 as rrn
                                    , de031 as arn
                                    , de041 as terminal_id
                                    , de042 as merchant_id
                                    , de026 as mcc
                                    , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                      rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                    , decode(mf.de025, null,   mf.de025
                                                     , '1400', mf.de025 || ' - Not previously authorized'
                                                     , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                     , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                     , '2011', mf.de025 || ' - Credit previously issued'
                                                     , '2700', mf.de025 || ' - Chargeback remedied'
                                                     , '4808', mf.de025 || ' - Required authorization not obtained'
                                                     , '4809', mf.de025 || ' - Transaction not reconciled'
                                                     , '4831', mf.de025 || ' - Transaction amount differs'
                                                     , '4834', mf.de025 || ' - Duplicate processing'
                                                     , '4842', mf.de025 || ' - Late presentment'
                                                     , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                     , '4859', mf.de025 || ' - Service not rendered'
                                                     , '4860', mf.de025 || ' - Credit not processed'
                                                     , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                     , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                     , '6341', mf.de025 || ' - Fraud investigation'
                                                     , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                     , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                     , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                     , '7800', mf.de025 || ' - MasterCard member settlement'
                                                     ,         mf.de025 || ' - Other') as reason_code
                                    , de093 as destination_institution
                                    , mf.de094 as originator_institution
                                    , decode(mf.inst_id,'9945','Customs payment',pcf.file_name) as m_file_name
                                 from mcw_fin mf
                                 join mcw_card mc          on mf.id = mc.id
                                 join mcw_file mff         on mff.id = mf.file_id
                                                          and mff.network_id not in (1009, 7014)
                                 join opr_operation oo     on oo.id = mf.id
                                                          and oo.oper_currency != 978
                            left join cst_oper_file cof    on cof.oper_id = oo.id
                            left join prc_session_file pcf on pcf.id = cof.session_file_id
                                where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                      substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 4)
                                   in ('002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'))
                             group by payment_network
                                    , mastercard_file_id
                                    , mastercard_file_date
                                    , message_type
                                    , function_code
                                    , transaction_type
                                    , reversal_indicator
                                    , transaction_id
                                    , card_number
                                    , transaction_date
                                    , transaction_amount
                                    , transaction_currency
                                    , settlement_amount
                                    , settlement_currency
                                    , approval_code
                                    , rrn
                                    , arn
                                    , terminal_id
                                    , merchant_id
                                    , mcc
                                    , merchant
                                    , reason_code
                                    , destination_institution
                                    , originator_institution)
                            union all -- PART 4
                               select distinct
                                      4 as part
                                    , settlement_currency as clearing_currency
                                    , 'Issuer processed' as activity
                                    , file_id
                                    , message_type
                                    , function_code
                                    , transaction_type
                                    , count(*) over (partition by settlement_currency
                                                                , file_date
                                                                , file_id
                                                                , message_type
                                                                , function_code
                                                                , transaction_type
                                                                , c_file) as quantity
                                    , null as settlement_amount
                                    , null as settlement_fee
                                    , null as settlement_total
                                    , null as clearing_currency
                                    , sum(settlement_amount) over (partition by settlement_currency
                                                                              , file_date
                                                                              , file_id
                                                                              , message_type
                                                                              , function_code
                                                                              , transaction_type
                                                                              , c_file) as clearing_amount
                                    , c_file as file_name
                                 from (select mastercard_file_id as file_id
                                            , mastercard_file_date as file_date
                                            , message_type
                                            , function_code
                                            , transaction_type
                                            , reversal_indicator
                                            , transaction_id
                                            , card_number
                                            , transaction_date
                                            , transaction_amount
                                            , transaction_currency
                                            , settlement_amount
                                            , settlement_currency
                                            , approval_code
                                            , rrn
                                            , arn
                                            , terminal_id
                                            , merchant_id
                                            , mcc
                                            , merchant
                                            , reason_code
                                            , destination_institution
                                            , originator_institution
                                            , listagg (c_file_name, ',') 
                                              within group (order by substr(c_file_name
                                                                          , instr(c_file_name,'.') + 1
                                                                          , 3)
                                                                  || substr(c_file_name
                                                                          , instr(c_file_name,'__') + 3
                                                                          , instr(c_file_name,'.') - instr(c_file_name,'__') - 2)
                                                           ) as c_file
                                         from (select substr(mff.p0105, 1, 3) || '/' || 
                                                      substr(mff.p0105, 4, 6) || '/' ||
                                                      substr(mff.p0105, 10, 11) || '/' || 
                                                      substr(mff.p0105, 21, 5) as mastercard_file_id
                                                    , to_char(mff.proc_date,'yyyymmdd') as mastercard_file_date
                                                    , mf.id as transaction_id
                                                    , mc.card_number as card_number
                                                    , mf.mti || ' - ' || decode (mf.mti, '1240', 'Presentment'
                                                                                       , '1442', 'Chargeback'
                                                                                       , '1740', 'Fee collection'
                                                                                       ,         'Other') as message_type
                                                    , mf.de024 || ' - ' || decode (mf.de024, '200', 'First Presentment'
                                                                                           , '205', 'Second presentment (Full)'
                                                                                           , '282', 'Second presentment (Partial)'
                                                                                           , '450', 'irst Chargeback (Full)'
                                                                                           , '451', 'Arbitration Chargeback (Full)'
                                                                                           , '453', 'First Chargeback (Partial)'
                                                                                           , '454', 'Arbitration Chargeback (Partial)'
                                                                                           , '700', 'Fee Collection (Member-generated)'
                                                                                           , '780', 'Fee Collection Return'
                                                                                           , '781', 'Fee Collection Resubmission'
                                                                                           , '782', 'Fee Collection Arbitration Return'
                                                                                           , '783', 'Fee Collection (Clearing System-generated)'
                                                                                           , '790', 'Fee Collection (Funds Transfer)'
                                                                                           , '791', 'Fee Collection (Funds Transfer Backout)'
                                                                                           ,        'Other') as function_code
                                                    , mf.de003_1 || ' - ' || decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                                                              , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                                                              , '12', mf.de003_1 || ' - Cash Disbursement'
                                                                                              , '17', mf.de003_1 || ' - Convenience Check'
                                                                                              , '18', mf.de003_1 || ' - Unique Transaction'
                                                                                              , '19', mf.de003_1 || ' - Fee Collection'
                                                                                              , '20', mf.de003_1 || ' - Refund'
                                                                                              , '28', mf.de003_1 || ' - Payment Transaction'
                                                                                              , '29', mf.de003_1 || ' - Fee Collection'
                                                                                              ,       mf.de003_1 || ' - Other') as transaction_type
                                                    , decode(oo.is_reversal, 0, 'No'
                                                                           , 1, 'Yes'
                                                                           ,    'Unknown') as reversal_indicator
                                                    , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                                    , mf.de004 / 100 as transaction_amount
                                                    , de049 as transaction_currency
                                                    , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                       , '26', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                       , '28', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                       , '29', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                       ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                                    , de050 as settlement_currency
                                                    , de038 as approval_code
                                                    , de037 as rrn
                                                    , de031 as arn
                                                    , de041 as terminal_id
                                                    , de042 as merchant_id
                                                    , de026 as mcc
                                                    , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' ||
                                                      rtrim(de043_3) || ', ' || rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                                    , decode(mf.de025, null,   mf.de025
                                                                     , '1400', mf.de025 || ' - Not previously authorized'
                                                                     , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                                     , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                                     , '2011', mf.de025 || ' - Credit previously issued'
                                                                     , '2700', mf.de025 || ' - Chargeback remedied'
                                                                     , '4808', mf.de025 || ' - Required authorization not obtained'
                                                                     , '4809', mf.de025 || ' - Transaction not reconciled'
                                                                     , '4831', mf.de025 || ' - Transaction amount differs'
                                                                     , '4834', mf.de025 || ' - Duplicate processing'
                                                                     , '4842', mf.de025 || ' - Late presentment'
                                                                     , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                                     , '4859', mf.de025 || ' - Service not rendered'
                                                                     , '4860', mf.de025 || ' - Credit not processed'
                                                                     , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                                     , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                                     , '6341', mf.de025 || ' - Fraud investigation'
                                                                     , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                                     , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                                     , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                                     , '7800', mf.de025 || ' - MasterCard member settlement'
                                                                     ,         mf.de025 || ' - Other') as reason_code
                                                    , de093 as destination_institution
                                                    , mf.de094 as originator_institution
                                                    , pcf.file_name as c_file_name
                                                 from mcw_fin mf
                                                 join mcw_card mc               on mf.id       = mc.id
                                                 join mcw_file mff              on mff.id      = mf.file_id
                                                 join opr_operation oo          on oo.id       = mf.id
                                                 left join cst_oper_file cof    on cof.oper_id = mf.id
                                                 left join prc_session_file pcf on pcf.id      = cof.session_file_id
                                                where substr(mff.p0105, 1, 3)||'/'||substr(mff.p0105, 4, 6)||'/'||
                                                      substr(mff.p0105, 10, 11)||'/'||substr(mff.p0105, 21, 5)
                                                      in ('001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/03301',
                                                          '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/04401',
                                                          '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/05501',
                                                          '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/06601',
                                                          '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/01101',
                                                          '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                  and not mf.de003_1 = '28'
                                                  and mf.de050       = 840
                                          union all
                                         select substr(mff.p0105, 1, 3)   || '/' || substr(mff.p0105, 4, 6) || '/' ||
                                                substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                              , to_char(mff.proc_date,'yyyymmdd') as mastercard_file_date
                                              , mf.id as transaction_id
                                              , mc.card_number as card_number
                                              , mf.mti || ' - ' || decode (mf.mti, '1240', 'Presentment'
                                                                                 , '1442', 'Chargeback'
                                                                                 , '1740', 'Fee collection'
                                                                                 ,         'Other') as message_type
                                              , mf.de024 || ' - ' || decode (mf.de024, '200', 'First Presentment'
                                                                                     , '205', 'Second presentment (Full)'
                                                                                     , '282', 'Second presentment (Partial)'
                                                                                     , '450', 'First Chargeback (Full)'
                                                                                     , '451', 'Arbitration Chargeback (Full)'
                                                                                     , '453', 'First Chargeback (Partial)'
                                                                                     , '454', 'Arbitration Chargeback (Partial)'
                                                                                     , '700', 'Fee Collection (Member-generated)'
                                                                                     , '780', 'Fee Collection Return'
                                                                                     , '781', 'Fee Collection Resubmission'
                                                                                     , '782', 'Fee Collection Arbitration Return'
                                                                                     , '783', 'Fee Collection (Clearing System-generated)'
                                                                                     , '790', 'Fee Collection (Funds Transfer)'
                                                                                     , '791', 'Fee Collection (Funds Transfer Backout)'
                                                                                     ,        'Other') as function_code
                                              , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase',
                                                                   '01', mf.de003_1 || ' - ATM Cash Withdrawal',
                                                                   '12', mf.de003_1 || ' - Cash Disbursement',
                                                                   '17', mf.de003_1 || ' - Convenience Check',
                                                                   '18', mf.de003_1 || ' - Unique Transaction',
                                                                   '19', mf.de003_1 || ' - Fee Collection',
                                                                   '20', mf.de003_1 || ' - Refund',
                                                                   '28', mf.de003_1 || ' - Payment Transaction',
                                                                   '29', mf.de003_1 || ' - Fee Collection',
                                                                         mf.de003_1 || ' - Other') as transaction_type
                                              , decode(oo.is_reversal, 0, 'No'
                                                                     , 1, 'Yes'
                                                                     ,    'Unknown') as reversal_indicator
                                              , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                              , mf.de004 / 100 as transaction_amount
                                              , de049 as transaction_currency
                                              , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                 , '26', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                 , '28', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                 , '29', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                 ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                              , de050 as settlement_currency
                                              , de038 as approval_code
                                              , de037 as rrn
                                              , de031 as arn
                                              , de041 as terminal_id
                                              , de042 as merchant_id
                                              , de026 as mcc
                                              , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                                rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                              , decode(mf.de025, null,   mf.de025
                                                               , '1400', mf.de025 || ' - Not previously authorized'
                                                               , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                               , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                               , '2011', mf.de025 || ' - Credit previously issued'
                                                               , '2700', mf.de025 || ' - Chargeback remedied'
                                                               , '4808', mf.de025 || ' - Required authorization not obtained'
                                                               , '4809', mf.de025 || ' - Transaction not reconciled'
                                                               , '4831', mf.de025 || ' - Transaction amount differs'
                                                               , '4834', mf.de025 || ' - Duplicate processing'
                                                               , '4842', mf.de025 || ' - Late presentment'
                                                               , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                               , '4859', mf.de025 || ' - Service not rendered'
                                                               , '4860', mf.de025 || ' - Credit not processed'
                                                               , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                               , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                               , '6341', mf.de025 || ' - Fraud investigation'
                                                               , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                               , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                               , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                               , '7800', mf.de025 || ' - MasterCard member settlement'
                                                               ,         mf.de025 || ' - Other') as reason_code
                                              , de093 as destination_institution
                                              , mf.de094 as originator_institution
                                              , pcf.file_name as c_file_name
                                           from mcw_fin mf
                                           join mcw_card mc               on mf.id = mc.id
                                           join mcw_file mff              on mff.id = mf.file_id
                                           join opr_operation oo          on oo.id = mf.id
                                      left join cst_oper_file cof    on cof.oper_id = oo.match_id
                                      left join prc_session_file pcf on pcf.id = cof.session_file_id
                                          where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                                substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                                             in ('001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/03301'
                                               , '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/04401'
                                               , '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/05501'
                                               , '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/06601'
                                               , '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                               , '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                             and mf.de003_1 = '28'
                                             and mf.de050 = 840)
                                     group by mastercard_file_id
                                            , mastercard_file_date
                                            , message_type
                                            , function_code
                                            , transaction_type
                                            , reversal_indicator
                                            , transaction_id
                                            , card_number
                                            , transaction_date
                                            , transaction_amount
                                            , transaction_currency
                                            , settlement_amount
                                            , settlement_currency
                                            , approval_code
                                            , rrn
                                            , arn
                                            , terminal_id
                                            , merchant_id
                                            , mcc
                                            , merchant
                                            , reason_code
                                            , destination_institution
                                            , originator_institution
                  )
              )
              select a.*
                   , a.tot_clearing_amount_p1 - tot_clearing_amount as diff1
                   , a.tot_settlement_amount_p2 - tot_clearing_amount as diff2
                   , a.tot_clearing_amount - a.not_exported as exported
                   , a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_2_pre_sum
                   , a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_3_sum
                   , a.clearing_cycle_4 + a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_4_sum
                   , a.clearing_cycle_5 + a.clearing_cycle_4 + a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_5_sum
                   , a.clearing_cycle_6 + a.clearing_cycle_5 + a.clearing_cycle_4 + a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_6_sum
                   , a.clearing_cycle_1 + a.tot_settlement_total_p1_cyc as clearing_cycle_1_sum
                   , a.clearing_cycle_2 + a.clearing_cycle_1  + a.tot_settlement_total_p1_cyc as clearing_cycle_2_sum
                from (select t.part
                           , t.settlement_currency
                           , t.activity
                           , t.file_id
                           , t.message_type
                           , t.function_code
                           , t.transaction_type
                           , t.quantity
                           , t.settlement_amount
                           , t.settlement_fee
                           , t.settlement_total
                           , t.clearing_currency
                           , t.clearing_amount
                           , t.file_name
                           , sum(nvl(t.quantity, 0)) over (partition by t.part) as tot_quantity
                           , sum(t.settlement_amount) over (partition by t.part) as tot_settlement_amount
                           , sum(t.settlement_fee) over (partition by t.part) as tot_settlement_fee
                           , sum(nvl(t.clearing_amount, 0)) over (partition by t.part) as tot_clearing_amount
                           , sum(case when t.part = 1 then t.settlement_total else 0 end) over () as tot_settlement_total_p1
                           , sum(case when t.part = 1 and substr(file_id, 1, 3) not in ('901', '904') 
                                      then t.settlement_total 
                                      else 0 
                                      end) over () as tot_settlement_total_p1_cyc
                           , sum(case when t.part = 2 then t.settlement_total else 0 end) over () as tot_settlement_total_p2
                           , sum(case when t.part = 1 then t.clearing_amount else 0 end) over () as tot_clearing_amount_p1
                           , sum(case when t.part = 1 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p1
                           , sum(case when t.part = 2 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p2
                           , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                    from mcw_fpd mf
                                   where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5) 
                                       =  '001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                       or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4) 
                                       =  '002/' || to_char(i_report_date-1, 'YYMMDD') || '/' || l_inst_ica || '/0000'
                                       or mf.file_id in (select distinct file_id
                                                           from mcw_fpd mf
                                                          where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                 substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                             in ('001/'||to_char(i_report_date, 'YYMMDD')||'/'||l_inst_ica||'/01101')
                                                            and de050 = 840))
                                     and substr(p0300,1,3) in ('901', '904'))
                                     and de050 = 840), 0) as clearing_cycle_1_pre
                           , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                    from mcw_fpd mf
                                   where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                      in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                      or mf.file_id in (select distinct file_id
                                                          from mcw_fpd mf
                                                         where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                            in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                           and de050 = 840)
                                                       )
                                         and substr(p0300,1,3) in ('901', '904')
                                         )
                                     and de050 = 840), 0) as clearing_cycle_2_pre
                           , sum(case when t.file_name is null then t.clearing_amount else 0 end) over (partition by t.part) as not_exported
                           , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 3 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300,21,5)
                                                                      in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/03301')
                                                                     and de050 = 840)
                                                                 )
                                                    and substr(p0300,1,3) in ('901', '904')
                                                  )
                                            and de050 = 840)
                                      , 0) as clearing_cycle_3
                           , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 4 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                      in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                                                                     and de050 = 840)
                                                                  )
                                                    and substr(p0300,1,3) in ('901', '904')
                                                  )
                                               and de050 = 840), 0) as clearing_cycle_4
                           , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 5 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300, 1, 3)   || '/' || substr(p0300, 4, 6) || '/' || 
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                      in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/05501')
                                                                     and de050 = 840)
                                                                 )
                                                    and substr(p0300,1,3) in ('901', '904')
                                                  )
                                           and de050 = 840)
                                     , 0) as clearing_cycle_5
                           , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 6 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total 
                                 else 0 end) over () 
                               + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                        from mcw_fpd mf
                                      where (mf.file_id in (select distinct file_id
                                                              from mcw_fpd mf
                                                             where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                    substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                 in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/06601')
                                                                    and de050 = 840)
                                                           )
                                             and substr(p0300, 1, 3) in ('901', '904')
                                             )
                                             and de050 = 840
                                      )
                                   , 0) as clearing_cycle_6
                           , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 1 and substr(file_id, 5, 6) = to_char(i_report_date+1, 'YYMMDD')
                                      then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' ||
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                      in ('001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101')
                                                                     and de050 = 840)
                                                                  )
                                                   and substr(p0300,1,3) in ('901', '904')
                                                  )
                                              and de050 = 840)
                                        , 0) as clearing_cycle_1
                           , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 2 and substr(file_id, 5, 6) = to_char(i_report_date+1, 'YYMMDD')
                                      then t.settlement_total 
                                      else 0 end) over () 
                           + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                    from mcw_fpd mf
                                   where (mf.file_id in (select distinct file_id
                                                           from mcw_fpd mf
                                                          where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6)
                                                            || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                           in ('001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                            and de050 = 840)
                                                        )
                                          and substr(p0300, 1, 3) in ('901', '904')
                                         )
                                     and de050 = 840)
                               , 0) as clearing_cycle_2
                        from t) a);

     --  fill with "operation" tag for empty reports creation
    for i in (select 1 
                from dual 
               where existsnode(l_operations, '/operations/operation') = 0) loop
        select xmlelement("operations", xmlagg(xmlelement("operation"))) 
          into l_operations 
          from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.master_card_settl_usd');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end master_card_settl_usd;

-- Mastercard settlement report in EUR
procedure master_card_settl_eur(
    o_xml            out clob
  , i_report_date in     date default null
  , i_lang        in     com_api_type_pkg.t_dict_value default null
  , i_inst_id     in     com_api_type_pkg.t_inst_id    default null
) is
    l_header      xmltype;
    l_operations  xmltype;
    l_result      xmltype;

    l_lang        com_api_type_pkg.t_dict_value;
    l_inst_id     com_api_type_pkg.t_inst_id;
    l_inst_ica    com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.master_card_settl_eur [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_inst_id  := nvl(i_inst_id, 0);
    l_inst_ica := '00000'||get_ica(l_inst_id);

    -- header
    select xmlconcat(
                xmlelement("inst_id",          l_inst_id)
              , xmlelement("inst",             com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
              , xmlelement("report_date",      to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
              , xmlelement("report_next_date", to_char(nvl(i_report_date + 1, sysdate),'dd.mm.yyyy'))
           )
      into l_header
      from dual;

  -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("part",                     part)
                     , xmlelement("settlement_currency",      settlement_currency)
                     , xmlelement("activity",                 activity)
                     , xmlelement("file_id",                  file_id)
                     , xmlelement("message_type",             message_type)
                     , xmlelement("function_code",            function_code)
                     , xmlelement("transaction_type",         transaction_type)
                     , xmlelement("quantity",                 quantity)
                     , xmlelement("settlement_amount",        format(settlement_amount))
                     , xmlelement("settlement_fee",           format(settlement_fee))
                     , xmlelement("settlement_total",         format(settlement_total))
                     , xmlelement("clearing_currency",        clearing_currency)
                     , xmlelement("clearing_amount",          format(clearing_amount))
                     , xmlelement("file_name",                file_name)
                     , xmlelement("tot_quantity",             tot_quantity)
                     , xmlelement("tot_settlement_amount",    format(tot_settlement_amount))
                     , xmlelement("tot_settlement_fee",       format(tot_settlement_fee))
                     , xmlelement("tot_clearing_amount",      format(tot_clearing_amount))
                     , xmlelement("tot_settlement_total_p1",  format(tot_settlement_total_p1))
                     , xmlelement("tot_settlement_total_p2",  format(tot_settlement_total_p2))
                     , xmlelement("tot_clearing_amount_p1",   format(tot_clearing_amount_p1))
                     , xmlelement("tot_settlement_amount_p1", format(tot_settlement_amount_p1))
                     , xmlelement("tot_settlement_amount_p2", format(tot_settlement_amount_p2))
                     , xmlelement("diff1",                    format(diff1))
                     , xmlelement("diff2",                    format(diff2))
                     , xmlelement("exported",                 format(exported))
                     , xmlelement("not_exported",             format(not_exported))
                     , xmlelement("clearing_cycle_1_pre",     format(clearing_cycle_1_pre))
                     , xmlelement("clearing_cycle_2_pre",     format(clearing_cycle_2_pre))
                     , xmlelement("clearing_cycle_2_pre_sum", format(clearing_cycle_2_pre_sum))
                     , xmlelement("clearing_cycle_3",         format(clearing_cycle_3))
                     , xmlelement("clearing_cycle_3_sum",     format(clearing_cycle_3_sum))
                     , xmlelement("clearing_cycle_4",         format(clearing_cycle_4))
                     , xmlelement("clearing_cycle_4_sum",     format(clearing_cycle_4_sum))
                     , xmlelement("clearing_cycle_5",         format(clearing_cycle_5))
                     , xmlelement("clearing_cycle_5_sum",     format(clearing_cycle_5_sum))
                     , xmlelement("clearing_cycle_6",         format(clearing_cycle_6))
                     , xmlelement("clearing_cycle_6_sum",     format(clearing_cycle_6_sum))
                     , xmlelement("clearing_cycle_1",         format(clearing_cycle_1))
                     , xmlelement("clearing_cycle_1_sum",     format(clearing_cycle_1_sum))
                     , xmlelement("clearing_cycle_2",         format(clearing_cycle_2))
                     , xmlelement("clearing_cycle_2_sum",     format(clearing_cycle_2_sum))
                    )
                    order by part, settlement_currency, activity, file_id, message_type, function_code
                )
           )
      into l_operations
      from (with t as (
             -- PART 1, 2
                select decode(substr(p0300, 1, 3), '001', 2, 1) as part
                     , de050 as settlement_currency
                     , decode(substr(p0300, 1, 3), '001', 'Issuing settled'
                                                 , '021', 'Issuing settled'
                                                 , '002', 'Acquiring settled'
                                                 ,        'Acquiring settled') as activity
                     , substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6)  || '/' || 
                       substr(p0300, 10, 11)  || '/' || substr(p0300, 21, 5) as file_id
                     , p0372_1 || ' - ' || decode (p0372_1, '1240', 'Presentment',
                                                            '1442', 'Chargeback',
                                                            '1740', 'Fee Collection',
                                                                    'Other') as message_type
                     , p0372_2 || ' - ' || decode (p0372_2, '200', 'First Presentment'
                                                          , '205', 'Second presentment (Full)'
                                                          , '282', 'Second presentment (Partial)'
                                                          , '450', 'First Chargeback (Full)'
                                                          , '451', 'Arbitration Chargeback (Full)'
                                                          , '453', 'First Chargeback (Partial)'
                                                          , '454', 'Arbitration Chargeback (Partial)'
                                                          ,        'Other') as function_code
                     , p0374 || ' - ' || decode(p0374, '00', 'Purchase',
                                                       '01', 'ATM Cash Withdrawal',
                                                       '12', 'Cash Disbursement',
                                                       '17', 'Convenience Check',
                                                       '18', 'Unique Transaction',
                                                       '19', 'Fee Collection',
                                                       '20', 'Refund',
                                                       '28', 'Payment Transaction',
                                                       '29', 'Fee Collection',
                                                             'Other') as transaction_type
                     , case when substr(p0300,1,3) != '904' then p0402 else null end as quantity
                     , p0394_2 * decode(p0394_1, 'D', -1, 1) / 100 as settlement_amount
                     , p0395_2 * decode(p0395_1, 'D', -1, 1) / 100 as settlement_fee
                     , p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 as settlement_total
                     , de049 as clearing_currency
                     , case when substr(p0300,1,3) not in ('901', '904') 
                            then p0384_2 * decode(p0384_1, 'D', -1, 1) / 100
                            else null 
                            end as clearing_amount
                     , sf.file_name
                  from mcw_fpd mf
             left join mcw_file f          on f.id  = mf.file_id
             left join prc_session_file sf on sf.id = f.session_file_id
                 where de050 = 978
                   and ((substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4) 
                      = '002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000')
                      or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11 )|| '/' || substr(p0300, 21, 5) 
                      in ('001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/03301',
                          '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/04401',
                          '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/05501',
                          '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/06601',
                          '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/01101',
                          '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                      or (mf.file_id in (select distinct file_id
                                                    from mcw_fpd mf
                                                   where ((substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                           substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4) 
                                                        = '002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'
                                                      or
                                                           substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' ||
                                                           substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5) 
                                                      in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/03301'
                                                        , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/04401'
                                                        , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                                                        , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                                                        , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                                        , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                          )
                                                    and de050 = 978)
                                        )
                                   and substr(p0300,1,3) in ('901', '904')
                         )
                     )
                 union all -- PART 3
                select distinct
                       3 as part
                     , clearing_currency
                     , 'Acquirer processed' as activity
                     , file_id
                     , message_type
                     , function_code
                     , transaction_type
                     , count(*) over (partition by payment_network
                                                 , clearing_currency
                                                 , file_date
                                                 , file_id
                                                 , message_type
                                                 , function_code
                                                 , transaction_type
                                                 , m_file_name) as quantity
                     , null as settlement_amount
                     , null as settlement_fee
                     , null as settlement_total
                     , null as clearing_currency
                     , sum(clearing_amount) over (partition by payment_network
                                                             , clearing_currency
                                                             , file_date
                                                             , file_id
                                                             , message_type
                                                             , function_code
                                                             , transaction_type
                                                             , m_file_name) as clearing_amount
                     , m_file_name as file_name
                  from (select payment_network
                             , mastercard_file_id as file_id
                             , mastercard_file_date as file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount as clearing_amount
                             , transaction_currency as clearing_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution
                             , listagg (m_file_name, ',') within group (order by transaction_id) as m_file_name
                          from (select decode(mff.network_id, '1002', 'MasterCard',
                                                              '7013', 'MasterCard',
                                                              '1009', 'MasterCard NSPK',
                                                              '7014', 'MasterCard NSPK',
                                                                      mff.network_id) as payment_network
                                     , substr(mff.p0105, 1, 3)   || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)as mastercard_file_id
                                     , to_char(mff.proc_date,'yyyymmdd') as mastercard_file_date
                                     , mf.id as transaction_id
                                     , mc.card_number as card_number
                                     , decode(mf.mti, '1240', mf.mti || ' - Presentment'
                                                    , '1442', mf.mti || ' - Chargeback'
                                                    , '1740', mf.mti || ' - Fee collection',
                                                              mf.mti || ' - Other') as message_type
                                     , decode(mf.de024, '200', mf.de024 || ' - First Presentment'
                                                      , '205', mf.de024 || ' - Second presentment (Full)'
                                                      , '282', mf.de024 || ' - Second presentment (Partial)'
                                                      , '450', mf.de024 || ' - First Chargeback (Full)'
                                                      , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                      , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                      , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                      , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                      , '780', mf.de024 || ' - Fee Collection Return'
                                                      , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                      , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                      , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                      , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                      , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                      ,        mf.de024 || ' - Other') as function_code
                                     , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                        , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                        , '12', mf.de003_1 || ' - Cash Disbursement'
                                                        , '17', mf.de003_1 || ' - Convenience Check'
                                                        , '18', mf.de003_1 || ' - Unique Transaction'
                                                        , '19', mf.de003_1 || ' - Fee Collection'
                                                        , '20', mf.de003_1 || ' - Refund'
                                                        , '28', mf.de003_1 || ' - Payment Transaction'
                                                        , '29', mf.de003_1 || ' - Fee Collection'
                                                        ,       mf.de003_1 || ' - Other') as transaction_type
                                     , decode(oo.is_reversal, 0, 'No'
                                                            , 1, 'Yes'
                                                            ,    'Unknown') as reversal_indicator
                                     , to_char(mf.de012,'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                     , decode(mf.de003_1, '00', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '01', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '12', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '17', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '18', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '19', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '20', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        , '28', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        , '29', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        ,       decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)) as transaction_amount
                                     , de049 as transaction_currency
                                     , mf.de005/100 as settlement_amount
                                     , de050 as settlement_currency
                                     , de038 as approval_code
                                     , de037 as rrn
                                     , de031 as arn
                                     , de041 as terminal_id
                                     , de042 as merchant_id
                                     , de026 as mcc
                                     , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                       rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                     , decode(mf.de025, null,   mf.de025
                                                      , '1400', mf.de025 || ' - Not previously authorized'
                                                      , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                      , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                      , '2011', mf.de025 || ' - Credit previously issued'
                                                      , '2700', mf.de025 || ' - Chargeback remedied'
                                                      , '4808', mf.de025 || ' - Required authorization not obtained'
                                                      , '4809', mf.de025 || ' - Transaction not reconciled'
                                                      , '4831', mf.de025 || ' - Transaction amount differs'
                                                      , '4834', mf.de025 || ' - Duplicate processing'
                                                      , '4842', mf.de025 || ' - Late presentment'
                                                      , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                      , '4859', mf.de025 || ' - Service not rendered'
                                                      , '4860', mf.de025 || ' - Credit not processed'
                                                      , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                      , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                      , '6341', mf.de025 || ' - Fraud investigation'
                                                      , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                      , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                      , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                      , '7800', mf.de025 || ' - MasterCard member settlement'
                                                      ,         mf.de025 || ' - Other') as reason_code
                                     , de093 as destination_institution
                                     , mf.de094 as originator_institution
                                     , decode(mf.inst_id,'9945','Customs payment',pcf.file_name) as m_file_name
                                  from mcw_fin mf
                                  join mcw_card mc          on mf.id   = mc.id
                                  join mcw_file mff         on mff.id  = mf.file_id
                                                           and mff.network_id not in (1009, 7014)
                                  join opr_operation oo     on oo.id   = mf.id
                                                          and oo.oper_currency = 978
                             left join cst_oper_file cof    on cof.oper_id     = oo.id
                             left join prc_session_file pcf on pcf.id = cof.session_file_id
                                 where substr(mff.p0105,  1,  3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 4)
                                    in ('002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000')
                               )
                      group by payment_network
                             , mastercard_file_id
                             , mastercard_file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount
                             , transaction_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution
                      )
                 union all 
                   -- PART 4
                select distinct
                       4 as part
                     , settlement_currency as clearing_currency
                     , 'Issuer processed' as activity
                     , file_id
                     , message_type
                     , function_code
                     , transaction_type
                     , count(*) over (partition by settlement_currency
                                                 , file_date
                                                 , file_id
                                                 , message_type
                                                 , function_code
                                                 , transaction_type
                                                 , c_file) as quantity
                     , null as settlement_amount
                     , null as settlement_fee
                     , null as settlement_total
                     , null as clearing_currency
                     , sum(settlement_amount) over (partition by settlement_currency
                                                               , file_date
                                                               , file_id
                                                               , message_type
                                                               , function_code
                                                               , transaction_type
                                                               , c_file) as clearing_amount
                     , c_file as file_name
                  from (select mastercard_file_id as file_id
                             , mastercard_file_date as file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount
                             , transaction_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution
                             , listagg (c_file_name, ',') 
                               within group (order by substr(c_file_name, instr(c_file_name, '.')+1, 3)||
                                                      substr(c_file_name, 
                                                             instr(c_file_name,'__') + 3, 
                                                             instr(c_file_name, '.') - instr(c_file_name, '__') - 2)) 
                               as c_file
                          from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                     , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                     , mf.id as transaction_id
                                     , mc.card_number as card_number
                                     , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                     , '1442', mf.mti || ' - Chargeback'
                                                     , '1740', mf.mti || ' - Fee collection'
                                                     ,         mf.mti || ' - Other') as message_type
                                     , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                       , '205', mf.de024 || ' - Second presentment (Full)'
                                                       , '282', mf.de024 || ' - Second presentment (Partial)'
                                                       , '450', mf.de024 || ' - First Chargeback (Full)'
                                                       , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                       , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                       , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                       , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                       , '780', mf.de024 || ' - Fee Collection Return'
                                                       , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                       , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                       , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                       , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                       , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                       ,        mf.de024 || ' - Other') as function_code
                                     , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                        , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                        , '12', mf.de003_1 || ' - Cash Disbursement'
                                                        , '17', mf.de003_1 || ' - Convenience Check'
                                                        , '18', mf.de003_1 || ' - Unique Transaction'
                                                        , '19', mf.de003_1 || ' - Fee Collection'
                                                        , '20', mf.de003_1 || ' - Refund'
                                                        , '28', mf.de003_1 || ' - Payment Transaction'
                                                        , '29', mf.de003_1 || ' - Fee Collection'
                                                        ,       mf.de003_1 || ' - Other') as transaction_type
                                     , decode(oo.is_reversal, 0, 'No'
                                                            , 1, 'Yes'
                                                            ,    'Unknown') as reversal_indicator
                                     , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                     , mf.de004/100 as transaction_amount
                                     , de049 as transaction_currency
                                     , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '26', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '28', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '29', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                     , de050 as settlement_currency
                                     , de038 as approval_code
                                     , de037 as rrn
                                     , de031 as arn
                                     , de041 as terminal_id
                                     , de042 as merchant_id
                                     , de026 as mcc
                                     , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                       rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                     , decode(mf.de025, null,   mf.de025
                                                      , '1400', mf.de025 || ' - Not previously authorized'
                                                      , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                      , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                      , '2011', mf.de025 || ' - Credit previously issued'
                                                      , '2700', mf.de025 || ' - Chargeback remedied'
                                                      , '4808', mf.de025 || ' - Required authorization not obtained'
                                                      , '4809', mf.de025 || ' - Transaction not reconciled'
                                                      , '4831', mf.de025 || ' - Transaction amount differs'
                                                      , '4834', mf.de025 || ' - Duplicate processing'
                                                      , '4842', mf.de025 || ' - Late presentment'
                                                      , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                      , '4859', mf.de025 || ' - Service not rendered'
                                                      , '4860', mf.de025 || ' - Credit not processed'
                                                      , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                      , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                      , '6341', mf.de025 || ' - Fraud investigation'
                                                      , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                      , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                      , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                      , '7800', mf.de025 || ' - MasterCard member settlement'
                                                      ,         mf.de025 || ' - Other') as reason_code
                                     , de093 as destination_institution
                                     , mf.de094 as originator_institution
                                     , pcf.file_name as c_file_name
                                  from mcw_fin mf
                                  join mcw_card mc          on mf.id   = mc.id
                                  join mcw_file mff         on mff.id  = mf.file_id
                                  join opr_operation oo     on oo.id   = mf.id
                             left join cst_oper_file cof    on cof.oper_id = mf.id
                             left join prc_session_file pcf on pcf.id = cof.session_file_id
                            where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                  substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                               in ('001/' || to_char(i_report_date,    'YYMMDD') || '/' || l_inst_ica || '/03301',
                                   '001/' || to_char(i_report_date,    'YYMMDD') || '/' || l_inst_ica || '/04401',
                                   '001/' || to_char(i_report_date,    'YYMMDD') || '/' || l_inst_ica || '/05501',
                                   '001/' || to_char(i_report_date,    'YYMMDD') || '/' || l_inst_ica || '/06601',
                                   '001/' || to_char(i_report_date +1, 'YYMMDD') || '/' || l_inst_ica || '/01101',
                                   '001/' || to_char(i_report_date +1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                              and not mf.de003_1 = '28'
                              and mf.de050 = 978
                            union
                           select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                  substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                , to_char(mff.proc_date,'yyyymmdd') as mastercard_file_date
                                , mf.id as transaction_id
                                , mc.card_number as card_number
                                , decode(mf.mti, '1240', mf.mti || ' - Presentment'
                                               , '1442', mf.mti || ' - Chargeback'
                                               , '1740', mf.mti || ' - Fee collection'
                                               ,         mf.mti || ' - Other') as message_type
                                , decode(mf.de024, '200', mf.de024 || ' - First Presentment'
                                                 , '205', mf.de024 || ' - Second presentment (Full)'
                                                 , '282', mf.de024 || ' - Second presentment (Partial)'
                                                 , '450', mf.de024 || ' - First Chargeback (Full)'
                                                 , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                 , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                 , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                 , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                 , '780', mf.de024 || ' - Fee Collection Return'
                                                 , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                 , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                 , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                 , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                 , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                 ,        mf.de024 || ' - Other') as function_code
                                , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                   , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                   , '12', mf.de003_1 || ' - Cash Disbursement'
                                                   , '17', mf.de003_1 || ' - Convenience Check'
                                                   , '18', mf.de003_1 || ' - Unique Transaction' 
                                                   , '19', mf.de003_1 || ' - Fee Collection'
                                                   , '20', mf.de003_1 || ' - Refund'
                                                   , '28', mf.de003_1 || ' - Payment Transaction'
                                                   , '29', mf.de003_1 || ' - Fee Collection'
                                                   ,       mf.de003_1 || ' - Other') as transaction_type
                                , decode(oo.is_reversal, 0, 'No'
                                                       , 1, 'Yes'
                                                       ,    'Unknown') as reversal_indicator
                                , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                , mf.de004/100 as transaction_amount
                                , de049 as transaction_currency
                                , decode(mf.de003_1, '20', decode(mf.is_reversal,0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                   , '26', decode(mf.is_reversal,0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                   , '28', decode(mf.is_reversal,0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                   , '29', decode(mf.is_reversal,0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                   ,       decode(mf.is_reversal,0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                , de050 as settlement_currency
                                , de038 as approval_code
                                , de037 as rrn
                                , de031 as arn
                                , de041 as terminal_id
                                , de042 as merchant_id
                                , de026 as mcc
                                , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                  rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                , decode(mf.de025, null,   mf.de025
                                                 , '1400', mf.de025 || ' - Not previously authorized'
                                                 , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                 , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                 , '2011', mf.de025 || ' - Credit previously issued'
                                                 , '2700', mf.de025 || ' - Chargeback remedied'
                                                 , '4808', mf.de025 || ' - Required authorization not obtained'
                                                 , '4809', mf.de025 || ' - Transaction not reconciled'
                                                 , '4831', mf.de025 || ' - Transaction amount differs'
                                                 , '4834', mf.de025 || ' - Duplicate processing'
                                                 , '4842', mf.de025 || ' - Late presentment'
                                                 , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                 , '4859', mf.de025 || ' - Service not rendered'
                                                 , '4860', mf.de025 || ' - Credit not processed'
                                                 , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                 , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                 , '6341', mf.de025 || ' - Fraud investigation'
                                                 , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                 , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                 , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                 , '7800', mf.de025 || ' - MasterCard member settlement'
                                                 ,         mf.de025 || ' - Other') as reason_code
                                , de093 as destination_institution
                                , mf.de094 as originator_institution
                                , pcf.file_name as c_file_name
                             from mcw_fin mf
                             join mcw_card mc          on mf.id = mc.id
                             join mcw_file mff         on mff.id = mf.file_id
                             join opr_operation oo     on oo.id = mf.id
                        left join cst_oper_file cof    on cof.oper_id = oo.match_id
                        left join prc_session_file pcf on pcf.id = cof.session_file_id
                            where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                  substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                              in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/03301',
                                  '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/04401',
                                  '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501',
                                  '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601',
                                  '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101',
                                  '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                              and mf.de003_1 = '28'
                              and mf.de050 = 978
                               )
                      group by mastercard_file_id
                             , mastercard_file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount
                             , transaction_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution
                          )
                   )
         select a.*
              , a.tot_clearing_amount_p1 - tot_clearing_amount as diff1
              , a.tot_settlement_amount_p2 - tot_clearing_amount as diff2
              , a.tot_clearing_amount - a.not_exported as exported
              , a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_2_pre_sum
              , a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_3_sum
              , a.clearing_cycle_4 + a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_4_sum
              , a.clearing_cycle_5 + a.clearing_cycle_4 + a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_5_sum
              , a.clearing_cycle_6 + a.clearing_cycle_5 + a.clearing_cycle_4 + a.clearing_cycle_3 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre as clearing_cycle_6_sum
              , a.clearing_cycle_1 + a.tot_settlement_total_p1_cyc as clearing_cycle_1_sum
              , a.clearing_cycle_2 + a.clearing_cycle_1  + a.tot_settlement_total_p1_cyc as clearing_cycle_2_sum
           from (select t.part
                      , t.settlement_currency
                      , t.activity
                      , t.file_id
                      , t.message_type
                      , t.function_code
                      , t.transaction_type
                      , t.quantity
                      , t.settlement_amount
                      , t.settlement_fee
                      , t.settlement_total
                      , t.clearing_currency
                      , t.clearing_amount
                      , t.file_name
                      , sum(nvl(t.quantity, 0)) over (partition by t.part) as tot_quantity
                      , sum(t.settlement_amount) over (partition by t.part) as tot_settlement_amount
                      , sum(t.settlement_fee) over (partition by t.part) as tot_settlement_fee
                      , sum(nvl(t.clearing_amount, 0)) over (partition by t.part) as tot_clearing_amount
                      , sum(case when t.part = 1 then t.settlement_total else 0 end) over () as tot_settlement_total_p1
                      , sum(case when t.part = 1 and substr(file_id,1,3) not in ('901', '904')
                                then t.settlement_total else 0 end) over () as tot_settlement_total_p1_cyc
                      , sum(case when t.part = 2 then t.settlement_total else 0 end) over () as tot_settlement_total_p2
                      , sum(case when t.part = 1 then t.clearing_amount else 0 end) over () as tot_clearing_amount_p1
                      , sum(case when t.part = 1 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p1
                      , sum(case when t.part = 2 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p2
                      , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                               from mcw_fpd mf
                              where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                     substr(p0300, 10,11 ) || '/' || substr(p0300, 21, 5) 
                                  =  '001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                 or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4) 
                                  =  '002/' || to_char(i_report_date - 1, 'YYMMDD') || '/' || l_inst_ica || '/0000'
                                 or mf.file_id in (select distinct file_id
                                                     from mcw_fpd mf
                                                    where (substr(p0300, 1, 3)   || '/' || substr(p0300, 4, 6) || '/' || 
                                                           substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                       in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/01101')
                                                    and de050 = 978)
                                                   )
                                     and substr(p0300,1,3) in ('901', '904')
                                    )
                                     and de050 = 978)
                          , 0) as clearing_cycle_1_pre
                      , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                               from mcw_fpd mf
                              where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                     substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                 in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                 or mf.file_id in (select distinct file_id
                                                     from mcw_fpd mf
                                                    where (substr(p0300,  1,  3) || '/' || substr(p0300,  4, 6) || '/' ||
                                                           substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                       in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                           and de050 = 978)
                                                   )
                                      and substr(p0300,1,3) in ('901', '904')
                                     )
                                     and de050 = 978)
                          , 0) as clearing_cycle_2_pre
                      , sum(case when t.file_name is null then t.clearing_amount else 0 end) over (partition by t.part) as not_exported
                      , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 3 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum(p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300,  1,  3) || '/' || substr(p0300,  4, 6) || '/' || 
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                      in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/03301')
                                                                      and de050 = 978)
                                                                 )
                                                       and substr(p0300,1,3) in ('901', '904')
                                                  )
                                               and de050 = 978)
                                        , 0) as clearing_cycle_3
                      , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 4 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in(select distinct file_id
                                                                   from mcw_fpd mf
                                                                  where (substr(p0300,1,3)||'/'||substr(p0300,4,6)||'/'||substr(p0300,10,11)||'/'||substr(p0300,21,5)
                                                                     in ('001/'||to_char(i_report_date, 'YYMMDD')||'/'||l_inst_ica||'/04401')
                                                                    and de050 = 978)
                                                                )
                                                    and substr(p0300,1,3) in ('901', '904')
                                                  )
                                               and de050 = 978)
                                        , 0) as clearing_cycle_4
                      , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 5 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300,  1,  3) || '/' || substr(p0300,  4, 6) || '/' ||
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                       in ('001/'||to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/05501')
                                                                    and de050 = 978)
                                                                 )
                                                   and substr(p0300,1,3) in ('901', '904')
                                                  )
                                               and de050 = 978)
                                        , 0) as clearing_cycle_5
                      , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 6 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum(p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300,  1,  3) || '/' || substr(p0300,  4, 6) || '/' ||
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                       in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/06601')
                                                                          and de050 = 978)
                                                                 )
                                                     and substr(p0300,1,3) in ('901', '904')
                                                   )
                                                and de050 = 978)
                                        , 0) as clearing_cycle_6
                      , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 1 and substr(file_id, 5, 6) = to_char(i_report_date+1, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300,  1,  3) || '/' || substr(p0300,  4, 6) || '/' ||
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                      in ('001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101')
                                                                     and de050 = 978)
                                                                 )
                                                          and substr(p0300,1,3) in ('901', '904')
                                                   )
                                               and de050 = 978)
                                        , 0) as clearing_cycle_1
                      , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 2 and substr(file_id, 5, 6) = to_char(i_report_date+1, 'YYMMDD')
                                 then t.settlement_total else 0 end) over () 
                                    + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                             from mcw_fpd mf
                                            where (mf.file_id in (select distinct file_id
                                                                    from mcw_fpd mf
                                                                   where (substr(p0300,  1,  3) || '/' || substr(p0300,  4, 6) || '/' ||
                                                                          substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                       in ('001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                                      and de050 = 978)
                                                                  )
                                                     and substr(p0300,1,3) in ('901', '904')
                                                  )
                                              and de050 = 978)
                                        , 0) as clearing_cycle_2
                        from t) a);

     --  fill with "operation" tag for empty reports creation
    for i in(select 1 
               from dual 
              where existsnode(l_operations, '/operations/operation') = 0) 
    loop
        select xmlelement("operations", xmlagg(xmlelement("operation"))) 
          into l_operations 
          from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.master_card_settl_eur');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end master_card_settl_eur;



-- MasterCard report transactions - acq
procedure master_card_transactions_acq(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
) is
    l_header               xmltype;
    l_operations           xmltype;
    l_result               xmltype;

    l_lang                 com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_inst_ica             com_api_type_pkg.t_cmid;
begin
    execute immediate 'alter session set NLS_LANGUAGE=RUSSIAN';

    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.master_card_transactions_acq [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_inst_id  := nvl(i_inst_id, 0);
    l_inst_ica := '00000'||get_ica(l_inst_id);

    -- header
    select
        xmlconcat(
            xmlelement("inst_id",     l_inst_id)
          , xmlelement("inst",        com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
          , xmlelement("report_date", to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
          , xmlelement("part",        'Acquirer transactions')
        )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("mastercard_file_id",      mastercard_file_id)
                     , xmlelement("message_type",            message_type)
                     , xmlelement("function_code",           function_code)
                     , xmlelement("transaction_type",        transaction_type)
                     , xmlelement("reversal_indicator",      reversal_indicator)
                     , xmlelement("transaction_id",          transaction_id)
                     , xmlelement("card_number",             card_number)
                     , xmlelement("transaction_date",        transaction_date)
                     , xmlelement("transaction_amount",      transaction_amount)
                     , xmlelement("transaction_currency",    transaction_currency)
                     , xmlelement("settlement_amount",       settlement_amount)
                     , xmlelement("settlement_currency",     settlement_currency)
                     , xmlelement("approval_code",           approval_code)
                     , xmlelement("rrn",                     rrn)
                     , xmlelement("arn",                     arn)
                     , xmlelement("terminal_id",             terminal_id)
                     , xmlelement("merchant_id",             merchant_id)
                     , xmlelement("mcc",                     mcc)
                     , xmlelement("merchant",                merchant)
                     , xmlelement("reason_code",             reason_code)
                     , xmlelement("is_rejected",             is_rejected)
                     , xmlelement("destination_institution", destination_institution)
                     , xmlelement("originator_institution",  originator_institution)
                     , xmlelement("file_name",               file_name)
                     , xmlelement("fee_coll_detail",         fee_coll_detail)
                     , xmlelement("reject_id",               reject_id)
                     , xmlelement("payment_code",            payment_code)
                     , xmlelement("oper_type",               oper_type)
                     , xmlelement("card_country",            card_country)
                   )
                  order by mastercard_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
               )
           )
      into l_operations
      from (select mastercard_file_id
                 , message_type
                 , function_code
                 , transaction_type
                 , reversal_indicator
                 , transaction_id
                 , card_number
                 , transaction_date
                 , transaction_amount
                 , transaction_currency
                 , settlement_amount
                 , settlement_currency
                 , approval_code
                 , rrn
                 , arn
                 , terminal_id
                 , merchant_id
                 , mcc
                 , merchant
                 , reason_code
                 , is_rejected
                 , destination_institution
                 , originator_institution
                 , listagg (m_file_name, ',') within group (order by transaction_id) as file_name
                 , fee_coll_detail
                 , reject_id
                 , payment_code
                 , oper_type
                 , card_country
              from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                         , mf.id as transaction_id
                         , mc.card_number as card_number
                         , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                         , '1442', mf.mti || ' - Chargeback'
                                         , '1740', mf.mti || ' - Fee collection'
                                         , '1644', mf.mti || ' - Retrieval request'
                                         ,         mf.mti || ' - Other') as message_type
                         , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                           , '205', mf.de024 || ' - Second presentment (Full)'
                                           , '282', mf.de024 || ' - Second presentment (Partial)'
                                           , '450', mf.de024 || ' - First Chargeback (Full)'
                                           , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                           , '453', mf.de024 || ' - First Chargeback (Partial)'
                                           , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                           , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                           , '780', mf.de024 || ' - Fee Collection Return'
                                           , '781', mf.de024 || ' - Fee Collection Resubmission'
                                           , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                           , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                           , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                           , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                           ,        mf.de024 || ' - Other') as function_code
                         , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                            , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                            , '12', mf.de003_1 || ' - Cash Disbursement'
                                            , '17', mf.de003_1 || ' - Convenience Check'
                                            , '18', mf.de003_1 || ' - Unique Transaction'
                                            , '19', mf.de003_1 || ' - Fee Collection'
                                            , '20', mf.de003_1 || ' - Refund'
                                            , '28', mf.de003_1 || ' - Payment Transaction'
                                            , '29', mf.de003_1 || ' - Fee Collection'
                                            ,       mf.de003_1 || ' - Other') as transaction_type
                         , decode(oo.is_reversal, 0, 'No'
                                                , 1, 'Yes'
                                                ,    'Unknown') as reversal_indicator
                         , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                         , case when mf.de024 in ('450', '451', '453', '454') then mf.de030_1/100
                                else mf.de004/100 end
                           *
                           case when (oo.oper_type in ('OPTP0026' -- OPTP0026
                                                     , 'OPTP0022' -- Cash-In
                                                     , 'OPTP0020' -- return (credit)
                                                       )
                                      and oo.is_reversal = 0)
                                    or
                                     (oo.oper_type not in ('OPTP0026' -- OPTP0026
                                                         , 'OPTP0022' -- Cash-In
                                                         , 'OPTP0020' -- return (credit)
                                                           )
                                      and oo.is_reversal != 0)
                                then -1 else 1 end as transaction_amount
                         , case when mf.de024 in ('450', '451', '453', '454') then mf.p0149_1
                                else mf.de049 end as transaction_currency
                         , decode(mff.network_id, '1009', 'MasterCard NSPK'
                                                , '7014', 'MasterCard NSPK'
                                                , '1002', 'MasterCard'
                                                , '7013', 'MasterCard'
                                                ,         mff.network_id) as settlement_amount
                         , decode(mff.network_id, '1009', '643'
                                                , '7014', '643'
                                                , '1002', '840'
                                                , '7013', '840'
                                                ,         '840') as settlement_currency
                         , de038 as approval_code
                         , de037 as rrn
                         , de031 as arn
                         , de041 as terminal_id
                         , de042 as merchant_id
                         , de026 as mcc
                         , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                           rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                         , decode(mf.de025, null,   mf.de025
                                          , '1400', mf.de025 || ' - Not previously authorized'
                                          , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                          , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                          , '2011', mf.de025 || ' - Credit previously issued'
                                          , '2700', mf.de025 || ' - Chargeback remedied'
                                          , '4808', mf.de025 || ' - Required authorization not obtained'
                                          , '4809', mf.de025 || ' - Transaction not reconciled'
                                          , '4831', mf.de025 || ' - Transaction amount differs'
                                          , '4834', mf.de025 || ' - Duplicate processing'
                                          , '4842', mf.de025 || ' - Late presentment'
                                          , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                          , '4859', mf.de025 || ' - Service not rendered'
                                          , '4860', mf.de025 || ' - Credit not processed'
                                          , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                          , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                          , '6341', mf.de025 || ' - Fraud investigation'
                                          , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                          , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                          , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                          , '7800', mf.de025 || ' - MasterCard member settlement'
                                          ,         mf.de025 || ' - Other') as reason_code
                         , decode(mf.is_rejected, 0, 'Sent'
                                                , 1, 'Rejected'
                                                ,    'Unknown') as is_rejected
                         , de093 as destination_institution
                         , mf.de094 as originator_institution
                         , decode(mf.inst_id,'9945','Customs payment',pcf.file_name) as m_file_name
                         , case when mf.de025 <> '7621' and mf.mti = '1740' then mf.de072 else null end as fee_coll_detail
                         , mf.reject_id as reject_id
                         , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                then get_payment_code(i_op_id      => decode(oo.is_reversal, 1, oo.original_id, oo.id),
                                                      i_op_id_preu => case when oo.msg_type = 'MSGTCMPL' and oo.oper_type = 'OPTP0060'
                                                                           then oo.original_id else null end)
                                else null end as payment_code,
                           oo.oper_type||' - '||com_api_dictionary_pkg.get_article_text(i_article => oo.oper_type) as oper_type
                         , cc.name as card_country
                      from mcw_fin mf
                      join mcw_card mc               on mf.id               = mc.id
                      join mcw_file mff              on mff.id              = mf.file_id
                      join opr_operation oo          on oo.id               = mf.id
                      left join opr_participant op   on op.oper_id          = oo.id
                                                    and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                      left join com_country cc       on cc.code             = op.card_country
                      left join cst_oper_file cof    on cof.oper_id         = oo.id
                      left join prc_session_file pcf on pcf.id              = cof.session_file_id
                     where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 4)
                           in ('002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'))
                  group by mastercard_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
                         , card_number
                         , transaction_date
                         , transaction_amount
                         , transaction_currency
                         , settlement_amount
                         , settlement_currency
                         , approval_code
                         , rrn
                         , arn
                         , terminal_id
                         , merchant_id
                         , mcc
                         , merchant
                         , reason_code
                         , is_rejected
                         , destination_institution
                         , originator_institution
                         , fee_coll_detail
                         , reject_id
                         , payment_code
                         , oper_type
                         , card_country);

    -- fill with "operation" tag for empty reports creation
    for i in (
        select 1 
          from dual 
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
      select xmlelement("operations", xmlagg(xmlelement("operation"))) 
        into l_operations 
        from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.master_card_transactions_acq');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end master_card_transactions_acq;

-- MasterCard transactions report - iss
procedure master_card_transactions_iss(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
) is
  l_header                 xmltype;
  l_operations             xmltype;
  l_result                 xmltype;

  l_lang                   com_api_type_pkg.t_dict_value;
  l_inst_id                com_api_type_pkg.t_inst_id;
  l_inst_ica               com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.master_card_transactions_iss [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_inst_id  := nvl(i_inst_id, 0);
    l_inst_ica := '00000'||get_ica(l_inst_id);

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
              , xmlelement("inst",        com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
              , xmlelement("report_date", to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
              , xmlelement("part",        'Issuer transactions')
        )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("mastercard_file_id",      mastercard_file_id)
                     , xmlelement("message_type",            message_type)
                     , xmlelement("function_code",           function_code)
                     , xmlelement("transaction_type",        transaction_type)
                     , xmlelement("reversal_indicator",      reversal_indicator)
                     , xmlelement("transaction_id",          transaction_id)
                     , xmlelement("card_number",             card_number)
                     , xmlelement("transaction_date",        transaction_date)
                     , xmlelement("transaction_amount",      transaction_amount)
                     , xmlelement("transaction_currency",    transaction_currency)
                     , xmlelement("settlement_amount",       settlement_amount)
                     , xmlelement("settlement_currency",     settlement_currency)
                     , xmlelement("approval_code",           approval_code)
                     , xmlelement("rrn",                     rrn)
                     , xmlelement("arn",                     arn)
                     , xmlelement("terminal_id",             terminal_id)
                     , xmlelement("merchant_id",             merchant_id)
                     , xmlelement("mcc",                     mcc)
                     , xmlelement("merchant",                merchant)
                     , xmlelement("reason_code",             reason_code)
                     , xmlelement("is_rejected",             is_rejected)
                     , xmlelement("destination_institution", destination_institution)
                     , xmlelement("originator_institution",  originator_institution)
                     , xmlelement("file_name",               file_name)
                     , xmlelement("fee_coll_detail",         fee_coll_detail)
                     , xmlelement("reject_id",               reject_id)
                     , xmlelement("payment_code",            payment_code)
                     , xmlelement("oper_type",               oper_type)
                     , xmlelement("card_acceptor_country",   card_acceptor_country)
                   )
                  order by mastercard_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
               )
            )
      into l_operations
      from (select t.mastercard_file_id
                 , t.message_type
                 , t.function_code
                 , t.transaction_type
                 , t.reversal_indicator
                 , t.transaction_id
                 , t.card_number
                 , t.transaction_date
                 , t.transaction_amount * t.direction as transaction_amount
                 , t.transaction_currency
                 , t.settlement_amount * t.direction as settlement_amount
                 , t.settlement_currency
                 , t.approval_code
                 , t.rrn
                 , t.arn
                 , t.terminal_id
                 , t.merchant_id
                 , t.mcc
                 , t.merchant
                 , t.reason_code
                 , 'Sent' as is_rejected
                 , t.destination_institution
                 , t.originator_institution
                 , listagg (t.c_file_name, ',') within group (order by t.transaction_id) as file_name
                 , t.fee_coll_detail
                 , t.reject_id
                 , t.payment_code
                 , t.oper_type
                 , t.card_acceptor_country
             from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                          substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                        , mf.id as transaction_id
                        , mc.card_number as card_number
                        , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                        , '1442', mf.mti || ' - Chargeback'
                                        , '1740', mf.mti || ' - Fee collection'
                                        , '1644', mf.mti || ' - Retrieval request'
                                        ,         mf.mti || ' - Other') as message_type
                        , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                          , '205', mf.de024 || ' - Second presentment (Full)'
                                          , '282', mf.de024 || ' - Second presentment (Partial)'
                                          , '450', mf.de024 || ' - First Chargeback (Full)'
                                          , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                          , '453', mf.de024 || ' - First Chargeback (Partial)'
                                          , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                          , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                          , '780', mf.de024 || ' - Fee Collection Return'
                                          , '781', mf.de024 || ' - Fee Collection Resubmission'
                                          , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                          , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                          , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                          , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                          ,        mf.de024 || ' - Other') as function_code
                        , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                           , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                           , '12', mf.de003_1 || ' - Cash Disbursement'
                                           , '17', mf.de003_1 || ' - Convenience Check'
                                           , '18', mf.de003_1 || ' - Unique Transaction'
                                           , '19', mf.de003_1 || ' - Fee Collection'
                                           , '20', mf.de003_1 || ' - Refund'
                                           , '28', mf.de003_1 || ' - Payment Transaction'
                                           , '29', mf.de003_1 || ' - Fee Collection'
                                           ,       mf.de003_1 || ' - Other') as transaction_type
                        , decode(oo.is_reversal, 0, 'No'
                                               , 1, 'Yes',
                                                    'Unknown') as reversal_indicator
                        , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                        , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, 1, -1)
                                           , '26', decode(mf.is_reversal, 0, 1, -1)
                                           , '28', decode(mf.is_reversal, 0, 1, -1)
                                           , '29', decode(mf.is_reversal, 0, 1, -1)
                                           ,       decode(mf.is_reversal, 0, -1, 1)) as direction
                        , case when mf.de024 in ('450', '451', '453', '454') 
                               then oo.oper_amount/100
                               else mf.de004/100 
                               end as transaction_amount
                        , case when mf.de024 in ('450', '451', '453', '454') 
                               then oo.oper_currency
                               else mf.de049 end as transaction_currency
                        , to_char(mf.de005/100) as settlement_amount
                        , de050 as settlement_currency
                        , de038 as approval_code
                        , de037 as rrn
                        , de031 as arn
                        , de041 as terminal_id
                        , de042 as merchant_id
                        , de026 as mcc
                        , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                          rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                        , decode(mf.de025, null,   mf.de025
                                         , '1400', mf.de025 || ' - Not previously authorized'
                                         , '1401' ,mf.de025 || ' - Previously approved authorization - amount same'
                                         , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                         , '2011', mf.de025 || ' - Credit previously issued'
                                         , '2700', mf.de025 || ' - Chargeback remedied'
                                         , '4808', mf.de025 || ' - Required authorization not obtained'
                                         , '4809', mf.de025 || ' - Transaction not reconciled'
                                         , '4831', mf.de025 || ' - Transaction amount differs'
                                         , '4834', mf.de025 || ' - Duplicate processing'
                                         , '4842', mf.de025 || ' - Late presentment'
                                         , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                         , '4859', mf.de025 || ' - Service not rendered'
                                         , '4860', mf.de025 || ' - Credit not processed'
                                         , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                         , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                         , '6341', mf.de025 || ' - Fraud investigation'
                                         , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                         , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                         , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                         , '7800', mf.de025 || ' - MasterCard member settlement'
                                         ,         mf.de025 || ' - Other') as reason_code
                        , null as is_rejected
                        , de093 as destination_institution
                        , mf.de094 as originator_institution
                        , pcf.file_name as c_file_name
                        , case when mf.de025 <> '7621' and mf.mti = '1740' then mf.de072 else null end as fee_coll_detail
                        , mf.reject_id as reject_id
                        , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                               then get_payment_code(i_op_id      => decode(oo.is_reversal, 1, oo.original_id, oo.id)
                                                   , i_op_id_preu => case when oo.msg_type = 'MSGTCMPL' and oo.oper_type = 'OPTP0060'
                                                                          then oo.original_id 
                                                                          else null end)
                               else null end as payment_code
                        , oo.oper_type||' - '||com_api_dictionary_pkg.get_article_text(i_article => oo.oper_type) as oper_type
                        , mf.de043_6 as card_acceptor_country
                     from mcw_fin mf
                     join mcw_card mc                on mf.id = mc.id
                     join mcw_file mff              on mff.id = mf.file_id
                     join opr_operation oo           on oo.id = mf.id
                left join cst_oper_file cof    on cof.oper_id = mf.id
                left join prc_session_file pcf on pcf.id      = cof.session_file_id
                   where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                         substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 2)
                     in ('021/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/01'
                       , '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/03'
                       , '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/04'
                       , '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/05'
                       , '001/' || to_char(i_report_date,   'YYMMDD') || '/' || l_inst_ica || '/06'
                       , '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/01'
                       , '001/' || to_char(i_report_date+1, 'YYMMDD') || '/' || l_inst_ica || '/02')
                    and not mf.de003_1 = '28'
                  union
                   select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                          substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                        , mf.id as transaction_id
                        , mc.card_number as card_number
                        , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                        , '1442', mf.mti || ' - Chargeback'
                                        , '1740', mf.mti || ' - Fee collection'
                                        , '1644', mf.mti || ' - Retrieval request'
                                        ,         mf.mti || ' - Other') as message_type
                        , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                          , '205', mf.de024 || ' - Second presentment (Full)'
                                          , '282', mf.de024 || ' - Second presentment (Partial)'
                                          , '450', mf.de024 || ' - First Chargeback (Full)'
                                          , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                          , '453', mf.de024 || ' - First Chargeback (Partial)'
                                          , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                          , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                          , '780', mf.de024 || ' - Fee Collection Return'
                                          , '781', mf.de024 || ' - Fee Collection Resubmission'
                                          , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                          , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                          , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                          , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                          ,        mf.de024 || ' - Other') as function_code
                       , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                          , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                          , '12', mf.de003_1 || ' - Cash Disbursement'
                                          , '17', mf.de003_1 || ' - Convenience Check'
                                          , '18', mf.de003_1 || ' - Unique Transaction'
                                          , '19', mf.de003_1 || ' - Fee Collection'
                                          , '20', mf.de003_1 || ' - Refund'
                                          , '28', mf.de003_1 || ' - Payment Transaction'
                                          , '29', mf.de003_1 || ' - Fee Collection'
                                          ,       mf.de003_1 || ' - Other') as transaction_type
                       , decode(oo.is_reversal, 0, 'No'
                                              , 1, 'Yes'
                                              ,    'Unknown') as reversal_indicator
                       , to_char(mf.de012,'dd/mm/yyyy hh24:mi:ss') as transaction_date
                       , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, 1, -1)
                                          , '26', decode(mf.is_reversal, 0, 1, -1)
                                          , '28', decode(mf.is_reversal, 0, 1, -1)
                                          , '29', decode(mf.is_reversal, 0, 1, -1)
                                          ,       decode(mf.is_reversal, 0, -1, 1)) as direction
                       , case when mf.de024 in ('450', '451', '453', '454') 
                              then oo.oper_amount/100
                              else mf.de004/100 
                              end as transaction_amount
                       , case when mf.de024 in ('450', '451', '453', '454') then oo.oper_currency
                                else mf.de049 end as transaction_currency
                       , to_char(mf.de005/100) as settlement_amount
                       , de050 as settlement_currency
                       , de038 as approval_code
                       , de037 as rrn
                       , de031 as arn
                       , de041 as terminal_id
                       , de042 as merchant_id
                       , de026 as mcc
                       , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                         rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                       , decode(mf.de025, null,   mf.de025
                                        , '1400', mf.de025 || ' - Not previously authorized'
                                        , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                        , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                        , '2011', mf.de025 || ' - Credit previously issued'
                                        , '2700', mf.de025 || ' - Chargeback remedied'
                                        , '4808', mf.de025 || ' - Required authorization not obtained'
                                        , '4809', mf.de025 || ' - Transaction not reconciled'
                                        , '4831', mf.de025 || ' - Transaction amount differs'
                                        , '4834', mf.de025 || ' - Duplicate processing'
                                        , '4842', mf.de025 || ' - Late presentment'
                                        , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                        , '4859', mf.de025 || ' - Service not rendered'
                                        , '4860', mf.de025 || ' - Credit not processed'
                                        , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                        , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                        , '6341', mf.de025 || ' - Fraud investigation'
                                        , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                        , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                        , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                        , '7800', mf.de025 || ' - MasterCard member settlement'
                                        ,         mf.de025 || ' - Other') as reason_code
                       , null as is_rejected
                       , de093 as destination_institution
                       , mf.de094 as originator_institution
                       , pcf.file_name as c_file_name
                       , case when mf.de025 <> '7621' and mf.mti = '1740' then mf.de072 else null end as fee_coll_detail
                       , mf.reject_id as reject_id
                       , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                              then get_payment_code(i_op_id      => decode(oo.is_reversal, 1, oo.original_id, oo.id)
                                                  , i_op_id_preu => case when oo.msg_type = 'MSGTCMPL' and oo.oper_type = 'OPTP0060'
                                                                         then oo.original_id 
                                                                         else null end)
                              else null end as payment_code
                       , oo.oper_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => oo.oper_type) as oper_type
                       , mf.de043_6 as card_acceptor_country
                    from mcw_fin mf
                    join mcw_card mc          on mf.id       = mc.id
                    join mcw_file mff         on mff.id      = mf.file_id
                    join opr_operation oo     on oo.id       = mf.id
               left join cst_oper_file cof    on cof.oper_id = oo.match_id
               left join prc_session_file pcf on pcf.id      = cof.session_file_id
                   where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                         substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 2)
                      in ('021/'||to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/01'
                        , '001/'||to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/03'
                        , '001/'||to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/04'
                        , '001/'||to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05'
                        , '001/'||to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06'
                        , '001/'||to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01'
                        , '001/'||to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02')
                     and mf.de003_1 = '28') t
             group by mastercard_file_id
                    , message_type
                    , function_code
                    , transaction_type
                    , reversal_indicator
                    , transaction_id
                    , card_number
                    , transaction_date
                    , direction
                    , transaction_amount
                    , transaction_currency
                    , settlement_amount
                    , settlement_currency
                    , approval_code
                    , rrn
                    , arn
                    , terminal_id
                    , merchant_id
                    , mcc
                    , merchant
                    , reason_code
                    , is_rejected
                    , destination_institution
                    , originator_institution
                    , fee_coll_detail
                    , reject_id
                    , payment_code
                    , oper_type
                    , card_acceptor_country);

    -- fill with empty "operation" tag for empty reports creation
    for i in (select 1 
                from dual 
               where existsnode(l_operations, '/operations/operation') = 0
    ) loop
        select xmlelement("operations", xmlagg(xmlelement("operation"))) 
          into l_operations 
          from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.master_card_transactions_iss');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end master_card_transactions_iss;


-- For report MasterCard-USD and MasterCard-EUR
procedure mc_settl(
    o_xml            out clob
  , i_report_date in     date default null
  , i_curr_code   in     com_api_type_pkg.t_curr_code
  , i_lang        in     com_api_type_pkg.t_dict_value default null
  , i_inst_id     in     com_api_type_pkg.t_inst_id    default null
) is
  l_header               xmltype;
  l_operations           xmltype;
  l_result               xmltype;

  l_lang                 com_api_type_pkg.t_dict_value;
  l_inst_id              com_api_type_pkg.t_inst_id;
  l_inst_ica             com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_sttl_report_pkg.mc_settl [#1] [#2] [#3] [#4] '
      , i_env_param1  => i_report_date
      , i_env_param2  => i_curr_code
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_inst_id  := nvl(i_inst_id, 0);
    l_inst_ica := '00000'||get_ica(l_inst_id);

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("curr_name", case when i_curr_code = com_api_currency_pkg.USDOLLAR then 'USD'
                                           when i_curr_code = com_api_currency_pkg.EURO then 'EUR'
                                           else 'RUR' end)
            , xmlelement("report_date", to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
            , xmlelement("report_next_date", to_char(nvl(i_report_date + 1, sysdate),'dd.mm.yyyy'))
        )
      into l_header
      from dual;

  -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("part",                     part)
                     , xmlelement("settlement_currency",      settlement_currency)
                     , xmlelement("activity",                 activity)
                     , xmlelement("file_id",                  file_id)
                     , xmlelement("message_type",             message_type)
                     , xmlelement("function_code",            function_code)
                     , xmlelement("transaction_type",         transaction_type)
                     , xmlelement("quantity",                 quantity)
                     , xmlelement("settlement_amount",        format(settlement_amount))
                     , xmlelement("settlement_fee",           format(settlement_fee))
                     , xmlelement("settlement_total",         format(settlement_total))
                     , xmlelement("clearing_currency",        clearing_currency)
                     , xmlelement("clearing_amount",          format(clearing_amount))
                     , xmlelement("file_name",                file_name)
                     , xmlelement("tot_quantity",             tot_quantity)
                     , xmlelement("tot_settlement_amount",    format(tot_settlement_amount))
                     , xmlelement("tot_settlement_fee",       format(tot_settlement_fee))
                     , xmlelement("tot_clearing_amount",      format(tot_clearing_amount))
                     , xmlelement("tot_settlement_total_p1",  format(tot_settlement_total_p1))
                     , xmlelement("tot_settlement_total_p2",  format(tot_settlement_total_p2))
                     , xmlelement("tot_clearing_amount_p1",   format(tot_clearing_amount_p1))
                     , xmlelement("tot_settlement_amount_p1", format(tot_settlement_amount_p1))
                     , xmlelement("tot_settlement_amount_p2", format(tot_settlement_amount_p2))
                     , xmlelement("diff1",                    format(diff1))
                     , xmlelement("diff2",                    format(diff2))
                     , xmlelement("exported",                 format(exported))
                     , xmlelement("not_exported",             format(not_exported))
                     , xmlelement("clearing_cycle_1_pre",     format(clearing_cycle_1_pre))
                     , xmlelement("clearing_cycle_2_pre",     format(clearing_cycle_2_pre))
                     , xmlelement("clearing_cycle_3",         format(clearing_cycle_3))
                     , xmlelement("clearing_cycle_3_sum",     format(clearing_cycle_3_sum))
                     , xmlelement("clearing_cycle_4",         format(clearing_cycle_4))
                     , xmlelement("clearing_cycle_4_sum",     format(clearing_cycle_4_sum))
                     , xmlelement("clearing_cycle_5",         format(clearing_cycle_5))
                     , xmlelement("clearing_cycle_5_sum",     format(clearing_cycle_5_sum))
                     , xmlelement("clearing_cycle_6",         format(clearing_cycle_6))
                     , xmlelement("clearing_cycle_6_sum",     format(clearing_cycle_6_sum))
                     , xmlelement("clearing_cycle_1",         format(clearing_cycle_1))
                     , xmlelement("clearing_cycle_1_sum",     format(clearing_cycle_1_sum))
                     , xmlelement("clearing_cycle_2",         format(clearing_cycle_2))
                     , xmlelement("clearing_cycle_2_sum",     format(clearing_cycle_2_sum))
                   )
                   order by part, settlement_currency, activity, file_id, message_type, function_code
               )
           )
      into l_operations
      from (with t as 
          -- PART 1, 2
               (select decode(substr(p0300, 1, 3), '001', 2, 1) as part
                     , de050 as settlement_currency
                     , decode(substr(p0300,1,3), '001', 'Issuing settled'
                                               , '021', 'Issuing settled'
                                               , '002', 'Acquiring settled'
                                               ,        'Acquiring settled') as activity
                     , substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6)  || '/' || substr(p0300, 10, 11)  || '/' || substr(p0300, 21, 5) as file_id
                     , decode(p0372_1, '1240', p0372_1 || ' - Presentment'
                                     , '1442', p0372_1 || ' - Chargeback'
                                     , '1740', p0372_1 || ' - Fee Collection'
                                     ,         p0372_1 || ' - Other') as message_type
                     , decode (p0372_2, '200', p0372_2 || ' - First Presentment'
                                      , '205', p0372_2 || ' - Second presentment (Full)'
                                      , '282', p0372_2 || ' - Second presentment (Partial)'
                                      , '450', p0372_2 || ' - First Chargeback (Full)'
                                      , '451', p0372_2 || ' - Arbitration Chargeback (Full)'
                                      , '453', p0372_2 || ' - First Chargeback (Partial)'
                                      , '454', p0372_2 || ' - Arbitration Chargeback (Partial)'
                                      ,        p0372_2 || ' - Other') as function_code
                     , decode(p0374, '00', p0374 || ' - Purchase'
                                   , '01', p0374 || ' - ATM Cash Withdrawal'
                                   , '12', p0374 || ' - Cash Disbursement'
                                   , '17', p0374 || ' - Convenience Check'
                                   , '18', p0374 || ' - Unique Transaction'
                                   , '19', p0374 || ' - Fee Collection'
                                   , '20', p0374 || ' - Refund'
                                   , '28', p0374 || ' - Payment Transaction'
                                   , '29', p0374 || ' - Fee Collection'
                                   ,       p0374 || ' - Other') as transaction_type
                     , case when substr(p0300,1,3) not in ('901', '904') then p0402 else null end as quantity
                     , p0394_2 * decode(p0394_1, 'D', -1, 1) / 100 as settlement_amount
                     , p0395_2 * decode(p0395_1, 'D', -1, 1) / 100 as settlement_fee
                     , p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 as settlement_total
                     , de049 as clearing_currency
                     , case when substr(p0300,1,3) not in ('901', '904') 
                            then p0384_2 * decode(p0384_1, 'D', -1, 1) / 100
                            else null end as clearing_amount
                     , null as file_name
                  from mcw_fpd mf
                 where de050 = i_curr_code
                   and ((substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 4) 
                    = '002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000')
                    or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5) 
                     in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                       , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                       , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                       , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201'
                       , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/03301'
                       , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                    or (mf.file_id in (select distinct file_id
                                         from mcw_fpd mf
                                        where ((substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                               substr(p0300, 10, 11) || '/' || substr(p0300,21,4)
                                            = '002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'
                                            or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                               substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5) 
                                            in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                                              , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                                              , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                              , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201'
                                              , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/03301'
                                              , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/04401'))
                                           and de050 = i_curr_code))
                                 and substr(p0300,1,3) in ('901', '904'))
                            )

                 union -- PART 3

                select distinct
                       3 as part
                     , clearing_currency
                     , 'Acquirer processed' as activity
                     , file_id
                     , message_type
                     , function_code
                     , transaction_type
                     , count(*) over (partition by payment_network
                                                 , clearing_currency
                                                 , file_date
                                                 , file_id
                                                 , message_type
                                                 , function_code
                                                 , transaction_type
                                                 , m_file_name) as quantity
                     , null as settlement_amount
                     , null as settlement_fee
                     , null as settlement_total
                     , null as clearing_currency
                     , sum(clearing_amount) over (partition by payment_network
                                                             , clearing_currency
                                                             , file_date
                                                             , file_id
                                                             , message_type
                                                             , function_code
                                                             , transaction_type
                                                             , m_file_name) as clearing_amount
                     , m_file_name as file_name
                 from (select payment_network
                            , mastercard_file_id as file_id
                            , mastercard_file_date as file_date
                            , message_type
                            , function_code
                            , transaction_type
                            , reversal_indicator
                            , transaction_id
                            , card_number
                            , transaction_date
                            , transaction_amount as clearing_amount
                            , transaction_currency as clearing_currency
                            , settlement_amount
                            , settlement_currency
                            , approval_code
                            , rrn
                            , arn
                            , terminal_id
                            , merchant_id
                            , mcc
                            , merchant
                            , reason_code
                            , destination_institution
                            , originator_institution
                            , listagg (m_file_name, ',') within group (order by transaction_id) as m_file_name
                         from (select decode(mff.network_id, '1002', 'MasterCard'
                                                           , '7013', 'MasterCard'
                                                           , '1009', 'MasterCard NSPK'
                                                           , '7014', 'MasterCard NSPK'
                                                           ,         mff.network_id) as payment_network
                                     , substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)as mastercard_file_id
                                     , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                     , mf.id as transaction_id
                                     , mc.card_number as card_number
                                     , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                     , '1442', mf.mti || ' - Chargeback'
                                                     , '1740', mf.mti || ' - Fee collection'
                                                     ,         mf.mti || ' - Other') as message_type
                                     , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                       , '205', mf.de024 || ' - Second presentment (Full)'
                                                       , '282', mf.de024 || ' - Second presentment (Partial)'
                                                       , '450', mf.de024 || ' - First Chargeback (Full)'
                                                       , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                       , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                       , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                       , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                       , '780', mf.de024 || ' - Fee Collection Return'
                                                       , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                       , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                       , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                       , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                       , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                       ,        mf.de024 || ' - Other') as function_code
                                      , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                         , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                         , '12', mf.de003_1 || ' - Cash Disbursement'
                                                         , '17', mf.de003_1 || ' - Convenience Check'
                                                         , '18', mf.de003_1 || ' - Unique Transaction'
                                                         , '19', mf.de003_1 || ' - Fee Collection'
                                                         , '20', mf.de003_1 || ' - Refund'
                                                         , '28', mf.de003_1 || ' - Payment Transaction'
                                                         , '29', mf.de003_1 || ' - Fee Collection'
                                                         ,       mf.de003_1 || ' - Other') as transaction_type
                                      , decode(oo.is_reversal, 0, 'No'
                                                             , 1, 'Yes'
                                                             ,    'Unknown') as reversal_indicator
                                      , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                      , decode(mf.de003_1, '00', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                         , '01', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                         , '12', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                         , '17', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                         , '18', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                         , '19', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                         , '20', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                         , '28', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                         , '29', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                         ,       decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)) as transaction_amount
                                      , de049 as transaction_currency
                                      , mf.de005 / 100 as settlement_amount
                                      , de050 as settlement_currency
                                      , de038 as approval_code
                                      , de037 as rrn
                                      , de031 as arn
                                      , de041 as terminal_id
                                      , de042 as merchant_id
                                      , de026 as mcc
                                      , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                        rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                      , decode(mf.de025, null,   mf.de025
                                                       , '1400', mf.de025 || ' - Not previously authorized'
                                                       , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                       , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                       , '2011', mf.de025 || ' - Credit previously issued'
                                                       , '2700', mf.de025 || ' - Chargeback remedied'
                                                       , '4808', mf.de025 || ' - Required authorization not obtained'
                                                       , '4809', mf.de025 || ' - Transaction not reconciled'
                                                       , '4831', mf.de025 || ' - Transaction amount differs'
                                                       , '4834', mf.de025 || ' - Duplicate processing'
                                                       , '4842', mf.de025 || ' - Late presentment'
                                                       , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                       , '4859', mf.de025 || ' - Service not rendered'
                                                       , '4860', mf.de025 || ' - Credit not processed'
                                                       , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                       , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                       , '6341', mf.de025 || ' - Fraud investigation'
                                                       , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                       , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                       , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                       , '7800', mf.de025 || ' - MasterCard member settlement'
                                                       ,         mf.de025 || ' - Other') as reason_code
                                      , de093 as destination_institution
                                      , mf.de094 as originator_institution
                                      , decode(mf.inst_id, '9945', 'Customs payment', pcf.file_name) as m_file_name
                                   from mcw_fin mf
                                   join mcw_card mc          on mf.id = mc.id
                                   join mcw_file mff         on mff.id = mf.file_id
                                                            and mff.network_id not in (1009, 7014)
                                   join opr_operation oo     on oo.id = mf.id
                              left join cst_oper_file cof    on cof.oper_id = oo.id
                              left join prc_session_file pcf on pcf.id = cof.session_file_id
                             where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                   substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 4)
                                in ('002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000')
                               and ((i_curr_code = com_api_currency_pkg.USDOLLAR and mf.de049 != com_api_currency_pkg.EURO) 
                                 or (i_curr_code = com_api_currency_pkg.EURO     and mf.de049 = com_api_currency_pkg.EURO)))
                          group by payment_network
                                 , mastercard_file_id
                                 , mastercard_file_date
                                 , message_type
                                 , function_code
                                 , transaction_type
                                 , reversal_indicator
                                 , transaction_id
                                 , card_number
                                 , transaction_date
                                 , transaction_amount
                                 , transaction_currency
                                 , settlement_amount
                                 , settlement_currency
                                 , approval_code
                                 , rrn
                                 , arn
                                 , terminal_id
                                 , merchant_id
                                 , mcc
                                 , merchant
                                 , reason_code
                                 , destination_institution
                                 , originator_institution) 
                             union all -- PART 4
                            select distinct 
                                   4 as part
                                 , settlement_currency as clearing_currency
                                 , 'Issuer processed' as activity
                                 , file_id
                                 , message_type
                                 , function_code
                                 , transaction_type
                                 , count(*) over (partition by settlement_currency
                                                             , file_date
                                                             , file_id
                                                             , message_type
                                                             , function_code
                                                             , transaction_type
                                                             , c_file) as quantity
                                 , null as settlement_amount
                                 , null as settlement_fee
                                 , null as settlement_total
                                 , null as clearing_currency
                                 , sum(settlement_amount) over (partition by settlement_currency
                                                                           , file_date
                                                                           , file_id
                                                                           , message_type
                                                                           , function_code
                                                                           , transaction_type
                                                                           , c_file) as clearing_amount
                                 , c_file as file_name
                              from (select mastercard_file_id as file_id
                                         , mastercard_file_date as file_date
                                         , message_type
                                         , function_code
                                         , transaction_type
                                         , reversal_indicator
                                         , transaction_id
                                         , card_number
                                         , transaction_date
                                         , transaction_amount
                                         , transaction_currency
                                         , settlement_amount
                                         , settlement_currency
                                         , approval_code
                                         , rrn
                                         , arn
                                         , terminal_id
                                         , merchant_id
                                         , mcc
                                         , merchant
                                         , reason_code
                                         , destination_institution
                                         , originator_institution
                                         , listagg (c_file_name, ',') 
                                           within group (order by substr(c_file_name,instr(c_file_name, '.') + 1, 3)||
                                                                  substr(c_file_name
                                                                       , instr(c_file_name, '__') + 3
                                                                       , instr(c_file_name, '.') - instr(c_file_name, '__') - 2)
                                                        ) as c_file
                                      from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                                   substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                                 , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                                 , mf.id as transaction_id
                                                 , mc.card_number as card_number
                                                 , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                                 , '1442', mf.mti || ' - Chargeback'
                                                                 , '1740', mf.mti || ' - Fee collection'
                                                                 ,         mf.mti || ' - Other') as message_type
                                                 , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                                   , '205', mf.de024 || ' - Second presentment (Full)'
                                                                   , '282',mf.de024 || ' - Second presentment (Partial)'
                                                                   , '450',mf.de024 || ' - First Chargeback (Full)'
                                                                   , '451',mf.de024 || ' - Arbitration Chargeback (Full)'
                                                                   , '453',mf.de024 || ' - First Chargeback (Partial)'
                                                                   , '454',mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                                   , '700',mf.de024 || ' - Fee Collection (Member-generated)'
                                                                   , '780',mf.de024 || ' - Fee Collection Return'
                                                                   , '781',mf.de024 || ' - Fee Collection Resubmission'
                                                                   , '782',mf.de024 || ' - Fee Collection Arbitration Return'
                                                                   , '783',mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                                   , '790',mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                                   , '791',mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                                   ,       mf.de024 || ' - Other') as function_code
                                                 , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                                    , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                                    , '12', mf.de003_1 || ' - Cash Disbursement'
                                                                    , '17', mf.de003_1 || ' - Convenience Check'
                                                                    , '18', mf.de003_1 || ' - Unique Transaction'
                                                                    , '19', mf.de003_1 || ' - Fee Collection'
                                                                    , '20', mf.de003_1 || ' - Refund'
                                                                    , '28', mf.de003_1 || ' - Payment Transaction'
                                                                    , '29', mf.de003_1 || ' - Fee Collection'
                                                                    ,       mf.de003_1 || ' - Other') as transaction_type
                                                 , decode(oo.is_reversal, 0, 'No'
                                                                        , 1, 'Yes'
                                                                        ,    'Unknown') as reversal_indicator
                                                 , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                                 , mf.de004/100 as transaction_amount
                                                 , de049 as transaction_currency
                                                 , decode(mf.de003_1, '00', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '01', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '12', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '17', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '18', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '19', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '20', decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)
                                                                    , '28', decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)
                                                                    , '29', decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)
                                                                    ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                                 , de050 as settlement_currency
                                                 , de038 as approval_code
                                                 , de037 as rrn
                                                 , de031 as arn
                                                 , de041 as terminal_id
                                                 , de042 as merchant_id
                                                 , de026 as mcc
                                                 , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                                   rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                                 , decode(mf.de025, null,   mf.de025
                                                                  , '1400', mf.de025 || ' - Not previously authorized'
                                                                  , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                                  , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                                  , '2011', mf.de025 || ' - Credit previously issued'
                                                                  , '2700', mf.de025 || ' - Chargeback remedied'
                                                                  , '4808', mf.de025 || ' - Required authorization not obtained'
                                                                  , '4809', mf.de025 || ' - Transaction not reconciled'
                                                                  , '4831', mf.de025 || ' - Transaction amount differs'
                                                                  , '4834', mf.de025 || ' - Duplicate processing'
                                                                  , '4842', mf.de025 || ' - Late presentment'
                                                                  , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                                  , '4859', mf.de025 || ' - Service not rendered'
                                                                  , '4860', mf.de025 || ' - Credit not processed'
                                                                  , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                                  , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                                  , '6341', mf.de025 || ' - Fraud investigation'
                                                                  , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                                  , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                                  , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                                  , '7800', mf.de025 || ' - MasterCard member settlement'
                                                                  ,         mf.de025 || ' - Other') as reason_code
                                                 , de093 as destination_institution
                                                 , mf.de094 as originator_institution
                                                 , pcf.file_name as c_file_name
                                              from mcw_fin mf
                                              join mcw_card mc               on mf.id = mc.id
                                              join mcw_file mff              on mff.id = mf.file_id
                                              join opr_operation oo          on oo.id = mf.id
                                         left join cst_oper_file cof    on cof.oper_id = mf.id
                                         left join prc_session_file pcf on pcf.id = cof.session_file_id
                                             where substr(mff.p0105, 1, 3)   || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                                   substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                                                in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                                                  , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                                                  , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                                  , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201'
                                                  , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/03301'
                                                  , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                                               and not mf.de003_1 = '28'
                                               and mf.de050       = i_curr_code
                                             union
                                            select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                                   substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                                 , to_char(mff.proc_date, 'yyyymmdd') as mastercard_file_date
                                                 , mf.id as transaction_id
                                                 , mc.card_number as card_number
                                                 , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                                 , '1442', mf.mti || ' - Chargeback'
                                                                 , '1740', mf.mti || ' - Fee collection'
                                                                 ,         mf.mti || ' - Other') as message_type
                                                 , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                                   , '205', mf.de024 || ' - Second presentment (Full)'
                                                                   , '282', mf.de024 || ' - Second presentment (Partial)'
                                                                   , '450', mf.de024 || ' - First Chargeback (Full)'
                                                                   , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                                   , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                                   , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                                   , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                                   , '780', mf.de024 || ' - Fee Collection Return'
                                                                   , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                                   , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                                   , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                                   , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                                   , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                                   ,        mf.de024 || ' - Other') as function_code
                                                 , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                                    , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                                    , '12', mf.de003_1 || ' - Cash Disbursement'
                                                                    , '17', mf.de003_1 || ' - Convenience Check'
                                                                    , '18', mf.de003_1 || ' - Unique Transaction'
                                                                    , '19', mf.de003_1 || ' - Fee Collection'
                                                                    , '20', mf.de003_1 || ' - Refund'
                                                                    , '28', mf.de003_1 || ' - Payment Transaction'
                                                                    , '29', mf.de003_1 || ' - Fee Collection'
                                                                    ,       mf.de003_1 || ' - Other') as transaction_type
                                                 , decode(oo.is_reversal, 0, 'No'
                                                                        , 1, 'Yes',
                                                                             'Unknown') as reversal_indicator
                                                 , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                                 , mf.de004 / 100 as transaction_amount
                                                 , de049 as transaction_currency
                                                 , decode(mf.de003_1, '00', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '01', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '12', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '17', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '18', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '19', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                                    , '20', decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)
                                                                    , '28', decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)
                                                                    , '29', decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)
                                                                    ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                                 , de050 as settlement_currency
                                                 , de038 as approval_code
                                                 , de037 as rrn
                                                 , de031 as arn
                                                 , de041 as terminal_id
                                                 , de042 as merchant_id
                                                 , de026 as mcc
                                                 , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                                   rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                                 , decode(mf.de025, null,   mf.de025
                                                                  , '1400', mf.de025 || ' - Not previously authorized'
                                                                  , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                                  , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                                  , '2011', mf.de025 || ' - Credit previously issued'
                                                                  , '2700', mf.de025 || ' - Chargeback remedied'
                                                                  , '4808', mf.de025 || ' - Required authorization not obtained'
                                                                  , '4809', mf.de025 || ' - Transaction not reconciled'
                                                                  , '4831', mf.de025 || ' - Transaction amount differs'
                                                                  , '4834', mf.de025 || ' - Duplicate processing'
                                                                  , '4842', mf.de025 || ' - Late presentment'
                                                                  , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                                  , '4859', mf.de025 || ' - Service not rendered'
                                                                  , '4860', mf.de025 || ' - Credit not processed'
                                                                  , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                                  , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                                  , '6341', mf.de025 || ' - Fraud investigation'
                                                                  , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                                  , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                                  , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                                  , '7800', mf.de025 || ' - MasterCard member settlement'
                                                                  ,         mf.de025 || ' - Other') as reason_code
                                                 , de093 as destination_institution
                                                 , mf.de094 as originator_institution
                                                 , pcf.file_name as c_file_name
                                              from mcw_fin mf
                                              join mcw_card mc          on mf.id       = mc.id
                                              join mcw_file mff         on mff.id      = mf.file_id
                                              join opr_operation oo     on oo.id       = mf.id
                                         left join cst_oper_file cof    on cof.oper_id = oo.match_id
                                         left join prc_session_file pcf on pcf.id      = cof.session_file_id
                                             where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                                   substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                                               in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                                                 , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                                                 , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                                 , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201'
                                                 , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/03301'
                                                 , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                                               and mf.de003_1 = '28'
                                               and mf.de050   = i_curr_code)
                                          group by mastercard_file_id
                                                 , mastercard_file_date
                                                 , message_type
                                                 , function_code
                                                 , transaction_type
                                                 , reversal_indicator
                                                 , transaction_id
                                                 , card_number
                                                 , transaction_date
                                                 , transaction_amount
                                                 , transaction_currency
                                                 , settlement_amount
                                                 , settlement_currency
                                                 , approval_code
                                                 , rrn
                                                 , arn
                                                 , terminal_id
                                                 , merchant_id
                                                 , mcc
                                                 , merchant
                                                 , reason_code
                                                 , destination_institution
                                                 , originator_institution))
            select a.*
                 , a.tot_clearing_amount_p1 - tot_clearing_amount as diff1
                 , abs(a.tot_settlement_amount_p2) - tot_clearing_amount as diff2
                 , a.tot_clearing_amount - a.not_exported as exported
                 , a.clearing_cycle_1_pre + a.clearing_cycle_2_pre + a.clearing_cycle_3_pre + a.clearing_cycle_4_pre as clearing_cycle_4_pre_sum   -- for analysis
                 , a.clearing_cycle_5 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre + a.clearing_cycle_3_pre + a.clearing_cycle_4_pre as clearing_cycle_5_sum
                 , a.clearing_cycle_6 + a.clearing_cycle_5 + a.clearing_cycle_1_pre + a.clearing_cycle_2_pre + a.clearing_cycle_3_pre + a.clearing_cycle_4_pre as clearing_cycle_6_sum
                 , a.clearing_cycle_1 + a.tot_settlement_total_p1_cyc as clearing_cycle_1_sum
                 , a.clearing_cycle_2 + a.clearing_cycle_1 + a.tot_settlement_total_p1_cyc as clearing_cycle_2_sum
                 , a.clearing_cycle_3 + a.clearing_cycle_1 + a.clearing_cycle_2 + a.tot_settlement_total_p1_cyc as clearing_cycle_3_sum
                 , a.clearing_cycle_4 + a.clearing_cycle_3 + a.clearing_cycle_1 + a.clearing_cycle_2 + a.tot_settlement_total_p1_cyc as clearing_cycle_4_sum
              from (select t.part
                         , t.settlement_currency
                         , t.activity
                         , t.file_id
                         , t.message_type
                         , t.function_code
                         , t.transaction_type
                         , t.quantity
                         , t.settlement_amount
                         , t.settlement_fee
                         , t.settlement_total
                         , t.clearing_currency
                         , t.clearing_amount
                         , t.file_name
                         , sum(nvl(t.quantity, 0)) over (partition by t.part) as tot_quantity
                         , sum(t.settlement_amount) over (partition by t.part) as tot_settlement_amount
                         , sum(t.settlement_fee) over (partition by t.part) as tot_settlement_fee
                         , sum(nvl(t.clearing_amount, 0)) over (partition by t.part) as tot_clearing_amount
                         , sum(case when t.part = 1 then t.settlement_total else 0 end) over () as tot_settlement_total_p1
                         , sum(case when t.part = 1 and substr(file_id,1,3) not in ('901', '904')
                                    then t.settlement_total 
                                    else 0 end) over () as tot_settlement_total_p1_cyc
                         , sum(case when t.part = 2 then t.settlement_total  else 0 end) over () as tot_settlement_total_p2
                         , sum(case when t.part = 1 then t.clearing_amount   else 0 end) over () as tot_clearing_amount_p1
                         , sum(case when t.part = 1 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p1
                         , sum(case when t.part = 2 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p2
                         -- cycle 1 pre
                         , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                  from mcw_fpd mf
                                 where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                        substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5) 
                                     = '001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                                    or substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300,21,4) 
                                     = '002/' || to_char(i_report_date - 1, 'YYMMDD') || '/' || l_inst_ica || '/0000'
                                    or mf.file_id in (select distinct file_id
                                                        from mcw_fpd mf
                                                       where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                              substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                          in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/01101')
                                                         and de050 = i_curr_code)
                                                     )
                                      and substr(p0300,1,3) in ('901', '904'))
                                   and de050 = i_curr_code), 0) as clearing_cycle_1_pre
                         -- cycle 2 pre
                         , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                  from mcw_fpd mf
                                 where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                        substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                     in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                    or mf.file_id in (select distinct file_id
                                                        from mcw_fpd mf
                                                       where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                              substr(p0300, 10, 11) || '/'||substr(p0300, 21, 5)
                                                          in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                         and de050 = i_curr_code)
                                                     )
                                        and substr(p0300,1,3) in ('901', '904')
                                       )
                                   and de050 = i_curr_code), 0) as clearing_cycle_2_pre
                          -- cycle 3 pre
                         , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                  from mcw_fpd mf
                                 where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                        substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                    in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/03301')
                                    or mf.file_id in (select distinct file_id
                                                        from mcw_fpd mf
                                                       where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                              substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                          in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/03301')
                                                         and de050 = i_curr_code)
                                                      )
                                         and substr(p0300,1,3) in ('901', '904')
                                       )
                                   and de050 = i_curr_code), 0) as clearing_cycle_3_pre
                         -- cycle 4 pre
                         , nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                  from mcw_fpd mf
                                 where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                        substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                     in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                                     or mf.file_id in (select distinct file_id
                                                         from mcw_fpd mf
                                                        where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                               substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                            in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                                                          and de050 = i_curr_code)
                                                      )
                                        and substr(p0300,1,3) in ('901', '904')
                                       )
                                   and de050 = i_curr_code), 0) as clearing_cycle_4_pre
                         , sum(case when t.file_name is null then t.clearing_amount else 0 end) over (partition by t.part) as not_exported
                         --cycle 5
                         , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 5 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                   then t.settlement_total else 0 end) over () 
                                      + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                               from mcw_fpd mf
                                              where (mf.file_id in (select distinct file_id
                                                                      from mcw_fpd mf
                                                                     where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                            substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                        in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/05501')
                                                                       and de050 = i_curr_code)
                                                                   )
                                                    and substr(p0300,1,3) in ('901', '904')
                                                    )
                                                and de050 = i_curr_code), 0) as clearing_cycle_5
                         --cycle 6
                         , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 6 and substr(file_id, 5, 6) = to_char(i_report_date, 'YYMMDD')
                                    then t.settlement_total else 0 end) over () 
                                       + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                                from mcw_fpd mf
                                               where (mf.file_id in (select distinct file_id
                                                                       from mcw_fpd mf
                                                                      where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' ||
                                                                             substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                         in ('001/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/06601')
                                                                             and de050 = i_curr_code)
                                                                    )
                                                      and substr(p0300,1,3) in ('901', '904')
                                                     )
                                        and de050 = i_curr_code), 0) as clearing_cycle_6
                         --cycle 1
                         , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 1 and substr(file_id, 5, 6) = to_char(i_report_date+1, 'YYMMDD')
                                    then t.settlement_total else 0 end) over () 
                                       + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                                from mcw_fpd mf
                                               where (mf.file_id in (select distinct file_id
                                                                       from mcw_fpd mf
                                                                      where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                             substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                          in ('001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101')
                                                                         and de050 = i_curr_code)
                                                                     )
                                                       and substr(p0300,1,3) in ('901', '904')
                                                     )
                                       and de050 = i_curr_code), 0) as clearing_cycle_1
                         --cycle 2
                         , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 2 and substr(file_id, 5, 6) = to_char(i_report_date + 1, 'YYMMDD')
                                    then t.settlement_total else 0 end) over () 
                                  + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                           from mcw_fpd mf
                                          where (mf.file_id in (select distinct file_id
                                                                  from mcw_fpd mf
                                                                 where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                        substr(p0300, 10, 11)||'/'||substr(p0300, 21, 5)
                                                                    in ('001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201')
                                                                   and de050 = i_curr_code)
                                                                 )
                                            and substr(p0300,1,3) in ('901', '904'))
                                            and de050 = i_curr_code), 0) as clearing_cycle_2
                         --cycle 3
                         , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 3 and substr(file_id, 5, 6) = to_char(i_report_date + 1, 'YYMMDD')
                                    then t.settlement_total else 0 end) over () 
                                  + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                           from mcw_fpd mf
                                          where (mf.file_id in (select distinct file_id
                                                                  from mcw_fpd mf
                                                                 where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                        substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                    in ('001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/03301')
                                                                   and de050 = i_curr_code)
                                                                )
                                                 and substr(p0300,1,3) in ('901', '904')
                                                )
                                            and de050 = i_curr_code), 0) as clearing_cycle_3
                         --cycle 4
                         , sum(case when t.part = 2 and substr(t.file_id, 25, 1) = 4 and substr(file_id, 5, 6) = to_char(i_report_date+1, 'YYMMDD')
                                    then t.settlement_total else 0 end) over () 
                                  + nvl((select sum( p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 ) as settlement_total
                                           from mcw_fpd mf
                                          where (mf.file_id in (select distinct file_id
                                                                  from mcw_fpd mf
                                                                where (substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || 
                                                                       substr(p0300, 10, 11) || '/' || substr(p0300, 21, 5)
                                                                   in ('001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                                                                  and de050 = i_curr_code)
                                                               )
                                                  and substr(p0300,1,3) in ('901', '904')
                                                 )
                                            and de050 = i_curr_code), 0) as clearing_cycle_4
                      from t) a);

     -- fill with "operation" tag for empty report creation
    for i in (select 1  
                from dual 
               where existsnode(l_operations, '/operations/operation') = 0
    ) loop
      select xmlelement("operations", xmlagg(xmlelement("operation"))) 
        into l_operations 
        from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.mc_settl');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end;


-- Report MasterCard - USD ( with crearing cycles 5->6->1->2->3->4 )
procedure mc_settl_usd(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.mc_settl_usd [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    mc_settl(
        o_xml         =>  o_xml
      , i_report_date => i_report_date
      , i_curr_code   => com_api_currency_pkg.USDOLLAR
      , i_lang        => i_lang
      , i_inst_id     => i_inst_id
    );

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.mc_settl_usd');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end;

-- Report MasterCard - EUR ( with crearing cycles 5->6->1->2->3->4 )
procedure mc_settl_eur(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.mc_settl_eur [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    mc_settl(
        o_xml         =>  o_xml
      , i_report_date => i_report_date
      , i_curr_code   => com_api_currency_pkg.EURO
      , i_lang        => i_lang
      , i_inst_id     => i_inst_id
    );

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.mc_settl_eur');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end;


-- MasterCard transactions report
procedure mc_transactions(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
) is
    l_header              xmltype;
    l_operations          xmltype;
    l_result              xmltype;

    l_lang                com_api_type_pkg.t_dict_value;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_inst_ica            com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text       => 'START: cst_api_report_pkg.mc_transactions [#1] [#2] [#3]'
      , i_env_param1 => i_report_date
      , i_env_param3 => i_lang
      , i_env_param4 => i_inst_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_inst_id  := nvl(i_inst_id, 0);
    l_inst_ica := '00000'||get_ica(l_inst_id);

    -- header
    select xmlconcat(
               xmlelement("inst_id", l_inst_id)
                 , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
                 , xmlelement("report_date", to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
               )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("part",                    part)
                     , xmlelement("mastercard_file_id",      mastercard_file_id)
                     , xmlelement("message_type",            message_type)
                     , xmlelement("function_code",           function_code)
                     , xmlelement("transaction_type",        transaction_type)
                     , xmlelement("reversal_indicator",      reversal_indicator)
                     , xmlelement("transaction_id",          transaction_id)
                     , xmlelement("card_number",             card_number)
                     , xmlelement("transaction_date",        transaction_date)
                     , xmlelement("transaction_amount",      format(transaction_amount))
                     , xmlelement("transaction_currency",    transaction_currency)
                     , xmlelement("settlement_amount",       settlement_amount)
                     , xmlelement("settlement_currency",     settlement_currency)
                     , xmlelement("approval_code",           approval_code)
                     , xmlelement("rrn",                     rrn)
                     , xmlelement("arn",                     arn)
                     , xmlelement("terminal_id",             terminal_id)
                     , xmlelement("merchant_id",             merchant_id)
                     , xmlelement("mcc",                     mcc)
                     , xmlelement("merchant",                merchant)
                     , xmlelement("reason_code",             reason_code)
                     , xmlelement("is_rejected",             is_rejected)
                     , xmlelement("destination_institution", destination_institution)
                     , xmlelement("originator_institution",  originator_institution)
                     , xmlelement("file_name",               file_name)
                     , xmlelement("reject_id",               reject_id)
                   )
                   order by part
                          , mastercard_file_id
                          , message_type
                          , function_code
                          , transaction_type
                          , reversal_indicator
                          , transaction_id
               )
           )
      into l_operations
      from (select 1 as part
                 , mastercard_file_id
                 , message_type
                 , function_code
                 , transaction_type
                 , reversal_indicator
                 , transaction_id
                 , card_number
                 , transaction_date
                 , transaction_amount
                 , transaction_currency
                 , settlement_amount
                 , settlement_currency
                 , approval_code
                 , rrn
                 , arn
                 , terminal_id
                 , merchant_id
                 , mcc
                 , merchant
                 , reason_code
                 , is_rejected
                 , destination_institution
                 , originator_institution
                 , listagg (m_file_name, ',') within group (order by transaction_id) as file_name
                 , reject_id
              from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                         , mf.id as transaction_id
                         , mc.card_number as card_number
                         , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                         , '1442', mf.mti || ' - Chargeback'
                                         , '1740', mf.mti || ' - Fee collection'
                                         , '1644', mf.mti || ' - Retrieval request'
                                         ,         mf.mti || ' - Other') as message_type
                         , decode (mf.de024, '200' ,mf.de024 || ' - First Presentment'
                                           , '205', mf.de024 || ' - Second presentment (Full)'
                                           , '282', mf.de024 || ' - Second presentment (Partial)'
                                           , '450', mf.de024 || ' - First Chargeback (Full)'
                                           , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                           , '453', mf.de024 || ' - First Chargeback (Partial)'
                                           , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                           , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                           , '780', mf.de024 || ' - Fee Collection Return'
                                           , '781', mf.de024 || ' - Fee Collection Resubmission'
                                           , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                           , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                           , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                           , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                           ,        mf.de024 || ' - Other') as function_code
                         , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                            , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                            , '12', mf.de003_1 || ' - Cash Disbursement'
                                            , '17', mf.de003_1 || ' - Convenience Check'
                                            , '18', mf.de003_1 || ' - Unique Transaction'
                                            , '19', mf.de003_1 || ' - Fee Collection'
                                            , '20', mf.de003_1 || ' - Refund'
                                            , '28', mf.de003_1 || ' - Payment Transaction'
                                            , '29', mf.de003_1 || ' - Fee Collection'
                                            ,       mf.de003_1 || ' - Other') as transaction_type
                         , decode(oo.is_reversal, 0, 'No'
                                                , 1, 'Yes'
                                                ,    'Unknown') as reversal_indicator
                         , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                         , mf.de004*case when (oo.oper_type in ('OPTP0026' -- OPTP0026
                                                               , 'OPTP0022' -- Cash-In
                                                               , 'OPTP0020' -- return (credit)
                                                                )
                                                and oo.is_reversal = 0)
                                            or (oo.oper_type not in ('OPTP0026' -- OPTP0026
                                                                   , 'OPTP0022' -- Cash-In
                                                                   , 'OPTP0020' -- return (credit)
                                                                     )
                                                 and oo.is_reversal != 0
                                               )
                                         then -1 else 1 end/100 as transaction_amount
                         , de049 as transaction_currency
                         , decode(mff.network_id, '1009', 'MasterCard NSPK'
                                                , '7014', 'MasterCard NSPK'
                                                , '1002', 'MasterCard'
                                                , '7013', 'MasterCard'
                                                ,         mff.network_id) as settlement_amount
                         , decode(mff.network_id, '1009', '643'
                                                , '7014', '643'
                                                , '1002', '840'
                                                , '7013', '840'
                                                ,         '840') as settlement_currency
                         , de038 as approval_code
                         , de037 as rrn
                         , de031 as arn
                         , de041 as terminal_id
                         , de042 as merchant_id
                         , de026 as mcc
                         , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                           rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                         , decode(mf.de025, null,   mf.de025
                                          , '1400', mf.de025 || ' - Not previously authorized'
                                          , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                          , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                          , '2011', mf.de025 || ' - Credit previously issued'
                                          , '2700', mf.de025 || ' - Chargeback remedied'
                                          , '4808', mf.de025 || ' - Required authorization not obtained'
                                          , '4809', mf.de025 || ' - Transaction not reconciled'
                                          , '4831', mf.de025 || ' - Transaction amount differs'
                                          , '4834', mf.de025 || ' - Duplicate processing'
                                          , '4842', mf.de025 || ' - Late presentment'
                                          , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                          , '4859', mf.de025 || ' - Service not rendered'
                                          , '4860', mf.de025 || ' - Credit not processed'
                                          , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                          , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                          , '6341', mf.de025 || ' - Fraud investigation'
                                          , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                          , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                          , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                          , '7800', mf.de025 || ' - MasterCard member settlement'
                                          ,         mf.de025 || ' - Other') as reason_code
                         , decode(mf.is_rejected, 0, 'Sent'
                                                , 1, 'Rejected'
                                                ,    'Unknown') as is_rejected
                         , de093 as destination_institution
                         , mf.de094 as originator_institution
                         , decode(mf.inst_id, '9945', 'Customs payment', pcf.file_name) as m_file_name
                         , mf.reject_id as reject_id
                      from mcw_fin mf
                      join mcw_card mc          on mf.id       = mc.id
                      join mcw_file mff         on mff.id      = mf.file_id
                      join opr_operation oo     on oo.id       = mf.id
                 left join cst_oper_file cof    on cof.oper_id = oo.id
                 left join prc_session_file pcf on pcf.id      = cof.session_file_id
                     where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 4)
                        in ('002/' || to_char(i_report_date, 'YYMMDD') || '/' || l_inst_ica || '/0000'))
                  group by mastercard_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
                         , card_number
                         , transaction_date
                         , transaction_amount
                         , transaction_currency
                         , settlement_amount
                         , settlement_currency
                         , approval_code
                         , rrn
                         , arn
                         , terminal_id
                         , merchant_id
                         , mcc
                         , merchant
                         , reason_code
                         , is_rejected
                         , destination_institution
                         , originator_institution
                         , reject_id
                     union all
                    select 2 as part
                         , mastercard_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
                         , card_number
                         , transaction_date
                         , transaction_amount
                         , transaction_currency
                         , settlement_amount
                         , settlement_currency
                         , approval_code
                         , rrn
                         , arn
                         , terminal_id
                         , merchant_id
                         , mcc
                         , merchant
                         , reason_code
                         , 'Sent' as is_rejected
                         , destination_institution
                         , originator_institution
                         , listagg (c_file_name, ',') within group (order by transaction_id) as file_name
                         , reject_id
                      from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' ||
                                   substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                                 , mf.id as transaction_id
                                 , mc.card_number as card_number
                                 , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                 , '1442', mf.mti || ' - Chargeback'
                                                 , '1740', mf.mti || ' - Fee collection'
                                                 , '1644', mf.mti || ' - Retrieval request'
                                                 ,         mf.mti || ' - Other') as message_type
                                 , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                   , '205', mf.de024 || ' - Second presentment (Full)'
                                                   , '282', mf.de024 || ' - Second presentment (Partial)'
                                                   , '450', mf.de024 || ' - First Chargeback (Full)'
                                                   , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                   , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                   , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                   , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                   , '780', mf.de024 || ' - Fee Collection Return'
                                                   , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                   , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                   , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                   , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                   , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                   ,        mf.de024 || ' - Other') as function_code
                                 , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                    , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                    , '12', mf.de003_1 || ' - Cash Disbursement'
                                                    , '17', mf.de003_1 || ' - Convenience Check'
                                                    , '18', mf.de003_1 || ' - Unique Transaction'
                                                    , '19', mf.de003_1 || ' - Fee Collection'
                                                    , '20', mf.de003_1 || ' - Refund'
                                                    , '28', mf.de003_1 || ' - Payment Transaction'
                                                    , '29', mf.de003_1 || ' - Fee Collection'
                                                    ,       mf.de003_1 || ' - Other') as transaction_type
                                 , decode(oo.is_reversal, 0, 'No'
                                                        , 1, 'Yes'
                                                        ,    'Unknown') as reversal_indicator
                                 , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                 , case when mf.de024 in ('450', '451', '453', '454') 
                                        then oo.oper_amount
                                        else mf.de004 end
                                  *case when (oo.oper_type in ('OPTP0026' -- OPTP0026
                                                             , 'OPTP0022' -- Cash-In
                                                             , 'OPTP0020' -- return (credit)
                                                              )
                                               and oo.is_reversal = 0
                                             )
                                          or (oo.oper_type not in ('OPTP0026' -- OPTP0026
                                                                 , 'OPTP0022' -- Cash-In
                                                                 , 'OPTP0020' -- return (credit)
                                                                  )
                                              and oo.is_reversal != 0)
                                        then 1 else -1 end/100 as transaction_amount
                                 , case when mf.de024 in ('450', '451', '453', '454') then oo.oper_currency
                                        else mf.de049 end as transaction_currency
                                 , to_char(mf.de005/100) as settlement_amount
                                 , de050 as settlement_currency
                                 , de038 as approval_code
                                 , de037 as rrn
                                 , de031 as arn
                                 , de041 as terminal_id
                                 , de042 as merchant_id
                                 , de026 as mcc 
                                 , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                   rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                 , decode(mf.de025, null,   mf.de025
                                                  , '1400', mf.de025 || ' - Not previously authorized'
                                                  , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                  , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                  , '2011', mf.de025 || ' - Credit previously issued'
                                                  , '2700', mf.de025 || ' - Chargeback remedied'
                                                  , '4808', mf.de025 || ' - Required authorization not obtained'
                                                  , '4809', mf.de025 || ' - Transaction not reconciled'
                                                  , '4831', mf.de025 || ' - Transaction amount differs'
                                                  , '4834', mf.de025 || ' - Duplicate processing'
                                                  , '4842', mf.de025 || ' - Late presentment'
                                                  , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                  , '4859', mf.de025 || ' - Service not rendered'
                                                  , '4860', mf.de025 || ' - Credit not processed'
                                                  , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                  , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                  , '6341', mf.de025 || ' - Fraud investigation'
                                                  , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                  , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                  , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                  , '7800', mf.de025 || ' - MasterCard member settlement'
                                                  ,         mf.de025 || ' - Other') as reason_code
                                 , null as is_rejected
                                 , de093 as destination_institution
                                 , mf.de094 as originator_institution
                                 , pcf.file_name as c_file_name
                                 , mf.reject_id as reject_id
                              from mcw_fin mf
                              join mcw_card mc          on mf.id       = mc.id
                              join mcw_file mff         on mff.id      = mf.file_id
                              join opr_operation oo     on oo.id       = mf.id
                         left join cst_oper_file cof    on cof.oper_id = mf.id
                         left join prc_session_file pcf on pcf.id      = cof.session_file_id
                     where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                       in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                         , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                         , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                         , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201'
                         , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/03301'
                         , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                       and not mf.de003_1 = '28'
                     union
                    select substr(mff.p0105, 1, 3)   || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mastercard_file_id
                         , mf.id as transaction_id
                         , mc.card_number as card_number
                         , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                         , '1442', mf.mti || ' - Chargeback'
                                         , '1740', mf.mti || ' - Fee collection'
                                         , '1644', mf.mti || ' - Retrieval request'
                                         ,         mf.mti || ' - Other') as message_type
                         , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                           , '205', mf.de024 || ' - Second presentment (Full)'
                                           , '282', mf.de024 || ' - Second presentment (Partial)'
                                           , '450', mf.de024 || ' - First Chargeback (Full)'
                                           , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                           , '453', mf.de024 || ' - First Chargeback (Partial)'
                                           , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                           , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                           , '780', mf.de024 || ' - Fee Collection Return'
                                           , '781', mf.de024 || ' - Fee Collection Resubmission'
                                           , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                           , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                           , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                           , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                           ,        mf.de024 || ' - Other') as function_code
                         , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                            , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                            , '12', mf.de003_1 || ' - Cash Disbursement'
                                            , '17', mf.de003_1 || ' - Convenience Check'
                                            , '18', mf.de003_1 || ' - Unique Transaction'
                                            , '19', mf.de003_1 || ' - Fee Collection'
                                            , '20', mf.de003_1 || ' - Refund'
                                            , '28', mf.de003_1 || ' - Payment Transaction'
                                            , '29', mf.de003_1 || ' - Fee Collection'
                                            ,       mf.de003_1 || ' - Other') as transaction_type
                         , decode(oo.is_reversal, 0, 'No'
                                                , 1, 'Yes'
                                                ,    'Unknown') as reversal_indicator
                         , to_char(mf.de012,'dd/mm/yyyy hh24:mi:ss') as transaction_date
                         , case when mf.de024 in ('450', '451', '453', '454') 
                                then oo.oper_amount
                                else mf.de004 end
                         * case when (oo.oper_type in ('OPTP0026' -- OPTP0026
                                                     , 'OPTP0022' -- Cash-In
                                                     , 'OPTP0020' -- return (credit)
                                                      )
                                      and oo.is_reversal = 0)
                                   or (oo.oper_type not in ('OPTP0026' -- OPTP0026
                                                          , 'OPTP0022' -- Cash-In
                                                          , 'OPTP0020' -- return (credit)
                                                           )
                                         and oo.is_reversal != 0
                                       )
                                then 1 else -1 end/100 as transaction_amount
                         , case when mf.de024 in ('450', '451', '453', '454') 
                                then oo.oper_currency
                                else mf.de049 end as transaction_currency
                         , to_char(mf.de005/100) as settlement_amount
                         , de050 as settlement_currency
                         , de038 as approval_code
                         , de037 as rrn
                         , de031 as arn
                         , de041 as terminal_id
                         , de042 as merchant_id
                         , de026 as mcc
                         , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                           rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                         , decode(mf.de025, null,   mf.de025
                                          , '1400', mf.de025 || ' - Not previously authorized'
                                          , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                          , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                          , '2011', mf.de025 || ' - Credit previously issued'
                                          , '2700', mf.de025 || ' - Chargeback remedied'
                                          , '4808', mf.de025 || ' - Required authorization not obtained'
                                          , '4809', mf.de025 || ' - Transaction not reconciled'
                                          , '4831', mf.de025 || ' - Transaction amount differs'
                                          , '4834', mf.de025 || ' - Duplicate processing'
                                          , '4842', mf.de025 || ' - Late presentment'
                                          , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                          , '4859', mf.de025 || ' - Service not rendered'
                                          , '4860', mf.de025 || ' - Credit not processed'
                                          , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                          , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                          , '6341', mf.de025 || ' - Fraud investigation'
                                          , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                          , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                          , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                          , '7800', mf.de025 || ' - MasterCard member settlement'
                                          ,         mf.de025 || ' - Other') as reason_code
                         , null as is_rejected
                         , de093 as destination_institution
                         , mf.de094 as originator_institution
                         , pcf.file_name as c_file_name
                         , mf.reject_id as reject_id
                      from mcw_fin mf
                      join mcw_card mc          on mf.id       = mc.id
                      join mcw_file mff         on mff.id      = mf.file_id
                      join opr_operation oo     on oo.id       = mf.id
                 left join cst_oper_file cof    on cof.oper_id = oo.match_id
                 left join prc_session_file pcf on pcf.id      = cof.session_file_id
                     where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5)
                        in ('001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/05501'
                          , '001/' || to_char(i_report_date,     'YYMMDD') || '/' || l_inst_ica || '/06601'
                          , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/01101'
                          , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/02201'
                          , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/03301'
                          , '001/' || to_char(i_report_date + 1, 'YYMMDD') || '/' || l_inst_ica || '/04401')
                       and mf.de003_1 = '28')
                  group by mastercard_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
                         , card_number
                         , transaction_date
                         , transaction_amount
                         , transaction_currency
                         , settlement_amount
                         , settlement_currency
                         , approval_code
                         , rrn
                         , arn
                         , terminal_id
                         , merchant_id
                         , mcc
                         , merchant
                         , reason_code
                         , is_rejected
                         , destination_institution
                         , originator_institution
                         , reject_id
                  );

    -- fill with "operation" tag for empty reports creation
    for i in (
        select 1 
          from dual 
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
      select xmlelement("operations", xmlagg(xmlelement("operation"))) 
        into l_operations 
        from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.mc_transactions');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end;

function get_up_sre(i_inst_id  in com_api_type_pkg.t_inst_id,
                    i_currency in com_api_type_pkg.t_curr_code)
    return com_api_type_pkg.t_cmid is
    l_return com_api_type_pkg.t_cmid;
begin
    l_return := case when i_inst_id in (2005, 2006, 2011, 2012, 2013) and i_currency = com_api_currency_pkg.RUBLE 
                     then '1000175561'
                     when i_inst_id in (2005, 2006, 2011, 2012, 2013) and i_currency = com_api_currency_pkg.USDOLLAR 
                     then '1000175560'
                     when i_inst_id in (2005, 2006, 2011, 2012, 2013) and i_currency = com_api_currency_pkg.EURO 
                     then '1000175562'
                     else '00000000000'
                end;
    return l_return;
end get_up_sre;

procedure visa_settl(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
  , i_curr_code    in      com_api_type_pkg.t_curr_code  default null
) is
    l_header               xmltype;
    l_operations           xmltype;
    l_result               xmltype;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_inst_name            com_api_type_pkg.t_full_desc;
    l_curr                 com_api_type_pkg.t_curr_name;
    l_up_sre               com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.visa_settl [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_lang    := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);
    l_up_sre  := get_up_sre(l_inst_id, i_curr_code);

    select c.name 
      into l_curr 
      from com_currency_vw c 
     where c.code = i_curr_code;

    case when l_inst_id in (2005, 2006, 2011, 2012, 2013)
             then l_inst_name := com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', 2005, l_lang)||', '||
                                 com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', 2011, l_lang)||', '||
                                 com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', 2012, l_lang)||', '||
                                 com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', 2013, l_lang);
         else l_inst_name := com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang);
    end case;

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", l_inst_name)
            , xmlelement("report_date", to_char(nvl(i_report_date, sysdate - 1),'dd.mm.yyyy'))
            , xmlelement("report_curr", l_curr)
            , xmlelement("report_curr_code", i_curr_code)
        )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("part",                part)
                     , xmlelement("settlement_currency", settlement_currency)
                     , xmlelement("activity",            activity)
                     , xmlelement("file_id",             file_id)
                     , xmlelement("transaction_type",    transaction_type)
                     , xmlelement("quantity",            quantity)
                     , xmlelement("amount",              format(amount))
                     , xmlelement("credit",              format(credit))
                     , xmlelement("credit_by_part",      format(credit_by_part))
                     , xmlelement("debit",               format(debit))
                     , xmlelement("debit_by_part",       format(debit_by_part))
                     , xmlelement("credit_fee",          format(credit_fee))
                     , xmlelement("credit_fee_by_part",  format(credit_fee_by_part))
                     , xmlelement("debit_fee",           format(debit_fee))
                     , xmlelement("debit_fee_by_part",   format(debit_fee_by_part))
                     , xmlelement("file_name",           file_name)
                     , xmlelement("cnt_by_part",         cnt_by_part)
                     , xmlelement("sum_by_part",         format(interch_sum_by_part))
                     , xmlelement("total",               format(total))
                     , xmlelement("total_p1p2",          format(total_p1p2))
                     , xmlelement("total_by_part",       format(total_by_part))
                     , xmlelement("clearing_tot",        format(clearing_tot))
                     , xmlelement("clearing_totals_p1",  format(clearing_totals_p1))
                     , xmlelement("tot_amount_p2",       format(tot_amount_p2))
                     , xmlelement("diff1",               format(diff1))
                     , xmlelement("diff2",               format(diff2))
                     , xmlelement("exported",            format(exported))
                     , xmlelement("not_exported",        format(not_exported))
                     , xmlelement("message_type",        message_type)
                     , xmlelement("clear_currency",      clear_currency)
                     , xmlelement("oper_currency",       oper_currency)
                  )
                  order by part
                         , transaction_type
                )
           )
      into l_operations
      from (with t as
            -- PART 1, 2
               (select case when f.bus_mode = 1 then 1 else 2 end as part
                     , f.file_id
                     , case when f.bus_tr_cycle in (0) then 'Fee'
                            when f.bus_tr_cycle in (1, 5, 6) then 'Presentment'
                            when f.bus_tr_cycle in (2, 4) then 'Chargeback'
                            when f.bus_tr_cycle in (3) then 'Representment'
                            when f.bus_tr_cycle in (504) then 'Reimbursement'
                            when f.bus_tr_cycle in (505) then 'VISA Charge'
                            when f.bus_tr_cycle in (506) then 'Optional Issuer FEE'
                            else 'Other - '|| f.bus_tr_cycle end message_type
                     , case when f.bus_tr_type = 100 then f.bus_tr_type || ' - Purchase'
                            when f.bus_tr_type = 120 then f.bus_tr_type || ' - Quasi-cash'
                            when f.bus_tr_type = 200 then f.bus_tr_type || ' - Merchandise credit'
                            when f.bus_tr_type = 300 then f.bus_tr_type || ' - Manual Cash'
                            when f.bus_tr_type = 310 then f.bus_tr_type || ' - ATM Cash'
                            when f.bus_tr_type = 330 then f.bus_tr_type || ' - Original credit'
                            when to_number(f.bus_tr_type) between 500 and 599 then f.bus_tr_type || ' - Fee Collection'
                            when to_number(f.bus_tr_type) between 600 and 699 then f.bus_tr_type || ' - Funds Disbursement'
                            when f.bus_tr_type = 852 then f.bus_tr_type || ' - ATM balance inquiry'
                            when f.bus_tr_type = 856 then f.bus_tr_type || ' - ATM decline'
                            when to_number(f.bus_tr_type) between 700 and 999 then f.bus_tr_type || ' - Nonfinancial'
                            else f.bus_tr_type || ' - Other' end as transaction_type
                     , f.first_count as quantity
                     , f.second_amount
                     , f.third_amount
                     , a.bus_tr_type_nf
                     , a.bus_mode_nf
                     , a.first_amount_nf
                     , null as oper_currency
                     , a.second_amount_nf
                     , a.third_amount_nf
                     , a.clear_currency_nf
                     , null as file_name
                     , null as sttl_amount
                  from (select v.bus_mode
                             , v.file_id
                             , v.bus_tr_type
                             , v.bus_tr_cycle
                             , sum(v.first_count) as first_count
                             , sum(v.second_amount) as second_amount
                             , sum(v.third_amount) as third_amount
                          from vis_vss4 v
                         where trunc(v.sttl_date) = trunc(i_report_date)--to_date( '09/02/2015', 'mm/dd/yyyy')
                           and v.sttl_currency = i_curr_code
                           and v.rep_id_num = 130
                           and v.summary_level = 10
                           and v.up_sre_id = l_up_sre
                      group by v.bus_mode
                             , v.file_id
                             , v.bus_tr_type
                             , v.bus_tr_cycle) f
                      ,(select v.bus_tr_type as bus_tr_type_nf
                             , v.bus_tr_cycle as bus_tr_cycle_nf
                             , v.bus_mode as bus_mode_nf
                             , sum(v.first_amount) as first_amount_nf
                             , sum(v.second_amount) as second_amount_nf
                             , sum(v.third_amount) as third_amount_nf
                             , v.clear_currency as clear_currency_nf
                             , null as oper_type
                             , null as file_name
                             , null as sttl_amount
                          from vis_vss4 v
                         where trunc(v.sttl_date) = trunc(i_report_date)--to_date( '09/02/2015', 'mm/dd/yyyy')
                           and v.sttl_currency = i_curr_code
                           and v.rep_id_num = 120
                           and v.summary_level = 10
                           and v.up_sre_id = l_up_sre
                      group by v.bus_tr_type
                             , v.bus_mode
                             , v.bus_tr_cycle
                             , v.clear_currency) a
                 where f.bus_tr_type = a.bus_tr_type_nf(+)
                   and f.bus_mode = a.bus_mode_nf(+)
                   and f.bus_tr_cycle = a.bus_tr_cycle_nf(+)
             union all -- Vss_fee
                select 1 as part
                     , v.file_id
                     , case when v.bus_tr_cycle in (0) then 'Fee'
                            when v.bus_tr_cycle in (1, 5, 6) then 'Presentment'
                            when v.bus_tr_cycle in (2, 4) then 'Chargeback'
                            when v.bus_tr_cycle in (3) then 'Representment'
                            when v.bus_tr_cycle in (504) then 'Reimbursement'
                            when v.bus_tr_cycle in (505) then 'VISA Charge'
                            when v.bus_tr_cycle in (506) then 'Optional Issuer FEE'
                            else 'Other - '|| v.bus_tr_cycle end message_type
                     , case when to_number(v.bus_tr_type) between 500 and 599
                            then v.bus_tr_type || ' - Fee Collection'
                            else v.bus_tr_type || ' - Other' end as transaction_type
                     , v.first_count as quantity
                     , null as second_amount
                     , null as third_amount
                     , v.bus_tr_type as bus_tr_type_nf
                     , null as bus_mode_nf
                     , v.first_amount as first_amount_nf
                     , null as oper_currency
                     , v.second_amount as second_amount_nf
                     , v.third_amount as third_amount_nf
                     , null as clear_currency_nf
                     , null as file_name
                     , null as sttl_amount
                  from vis_vss4 v
                 where trunc(v.sttl_date) = trunc(i_report_date)--to_date( '09/02/2015', 'mm/dd/yyyy')
                   and v.sttl_currency = i_curr_code
                   and v.rep_id_num = 120
                   and v.summary_level = 10
                   and v.bus_mode = 3
                   and v.up_sre_id = l_up_sre
                 union all
                select 2 as part
                     , charge.file_id
                     , 'Fee' as message_type
                     , 'VISA Charges' as transaction_type
                     , charge.first_count as quantity
                     , case when charge.third_amount < 0 then 0 else charge.third_amount end as second_amount
                     , case when charge.third_amount < 0 then charge.third_amount else 0 end as third_amount
                     , null as bus_tr_type_nf
                     , null as bus_mode_nf
                     , null as first_amount_nf
                     , null as oper_currency
                     , null as second_amount_nf
                     , null as third_amount_nf
                     , null as clear_currency_nf
                     , null as file_name
                     , null as sttl_amount
                  from (select v.file_id
                             , v.bus_tr_cycle
                             , sum(v.first_count) as first_count
                             , sum(v.third_amount) as third_amount
                          from vis_vss4 v
                         where trunc(v.sttl_date) = trunc(i_report_date)--to_date('03/17/2016', 'mm/dd/yyyy')
                           and v.sttl_currency = i_curr_code
                           and v.rep_id_num = 140
                           and v.summary_level = 9
                           and v.up_sre_id = l_up_sre
                           and v.third_amount <> 0
                           and v.bus_mode = 2
                         group by v.bus_mode, v.file_id, v.bus_tr_cycle) charge
                  union all
                select 2 as part
                     , charge.file_id
                     , 'Fee' as message_type
                     , 'OPT Issue Fee' as transaction_type
                     , null as quantity
                     , case when charge.fifth_amount < 0 then 0 else charge.fifth_amount end as second_amount
                     , case when charge.fifth_amount < 0 then charge.fifth_amount else 0 end as third_amount
                     , null as bus_tr_type_nf
                     , null as bus_mode_nf
                     , null as first_amount_nf
                     , null as oper_currency
                     , null as second_amount_nf
                     , null as third_amount_nf
                     , null as clear_currency_nf
                     , null as file_name
                     , null as sttl_amount
                  from (select v.file_id
                             , v.bus_tr_cycle
                             , sum(v.fifth_amount) as fifth_amount
                          from vis_vss4 v
                         where trunc(v.sttl_date) = trunc(i_report_date)--to_date('03/17/2016', 'mm/dd/yyyy')
                           and v.sttl_currency = i_curr_code
                           and v.rep_id_num = 210
                           and v.summary_level = 8
                           and v.up_sre_id = l_up_sre
                           and v.third_amount <> 0
                           and v.bus_mode = 2
                      group by v.bus_mode
                             , v.file_id
                             , v.bus_tr_cycle) charge
            union all
                   -- 3 Acquiring settled totals
                select distinct
                       3 as part
                     , t.file_id
                     , t.message_type
                     , t.transaction_type
                     , count(1) over (partition by t.message_type, t.transaction_type, t.file_name) as quantity
                     , null as second_amount
                     , null as third_amount
                     , null as bus_tr_type_nf
                     , null as bus_mode_nf
                     , sum(t.oper_amount) over (partition by t.message_type, t.transaction_type, t.file_name, t.oper_currency) as first_amount_nf
                     , t.oper_currency
                     , null as second_amount_nf
                     , null as third_amount_nf
                     , null as clear_currency_nf
                     , t.file_name
                     , null as sttl_amount
                  from (select vf.id as file_id
                             , case when o.msg_type in ('MSGTAUTH', 'MSGTFPST', 'MSGTCMPL', 'MSGTPRES') then 'Presentment'
                                    when o.msg_type in ('MSGTCHBK', 'MSGTACBK') then 'Chargeback'
                                    when o.msg_type in ('MSGTREPR') then 'Representment'
                                    else 'Other - '||o.msg_type
                               end as message_type
                             , case when o.oper_type = 'OPTP0000' then '100 - Purchase'
                                    when o.oper_type = 'OPTP0001' then '310 - ATM Cash'
                                    when o.oper_type = 'OPTP0010' then '120 - P2P Debit'
                                    when o.oper_type = 'OPTP0012' then '300 - Manual Cash'
                                    when o.oper_type = 'OPTP0018' then '120 - Quasi-cach'
                                    when o.oper_type in ('OPTP0020', 'OPTP0028') then '200 - Merchandise credit'
                                    when o.oper_type = 'OPTP0026' then '330 - Original credit'
                                    else 'Other - '||o.oper_type
                               end as transaction_type
                             , f.oper_amount
                               *
                               case when (o.msg_type not in ('MSGTCHBK', 'MSGTACBK') 
                                      and o.oper_type not in ('OPTP0020' -- return (credit)
                                                            , 'OPTP0022' -- Cash-in
                                                            , 'OPTP0028' -- Payment
                                                            , 'OPTP0026' -- P2P Credit
                                                              )
                                          ) 
                                       or (o.msg_type in ('MSGTCHBK', 'MSGTACBK') 
                                       and o.oper_type in ('OPTP0020' -- return (credit)
                                                         , 'OPTP0022' -- Cash-in
                                                         , 'OPTP0028' -- Payment
                                                         , 'OPTP0026' -- P2P Credit
                                                           )
                                          )
                                    then decode(f.is_reversal,0, 1, -1)
                                    else decode(f.is_reversal,0, -1, 1)
                                    end as oper_amount
                             , f.oper_currency
                             , o.oper_type
                             , pcf.file_name
                          from vis_fin_message f
                          join vis_file vf on vf.id = f.file_id
                                          and trunc(vf.proc_date) = trunc(i_report_date - 1)
                                          and vf.is_incoming = 0
                                          and ((i_curr_code = com_api_currency_pkg.RUBLE and vf.proc_bin like '9%') 
                                             or(i_curr_code = com_api_currency_pkg.EURO and vf.proc_bin like '4%' and f.oper_currency = com_api_currency_pkg.EURO) 
                                             or(i_curr_code = com_api_currency_pkg.USDOLLAR and vf.proc_bin like '4%'))
                                          and vf.proc_bin in ('914076', '414076')
                     left join opr_operation o on o.id = f.id
                     left join cst_oper_file cof    on cof.oper_id = f.id
                     left join prc_session_file pcf on pcf.id = cof.session_file_id
                         where f.trans_code <> 15
                                -- and f.sttl_currency = i_curr_code
               union all
                        select vf.id as file_id
                             , case when o.msg_type in ('MSGTAUTH', 'MSGTFPST', 'MSGTCMPL', 'MSGTPRES') then 'Presentment'
                                    when o.msg_type in ('MSGTCHBK', 'MSGTACBK') then 'Chargeback'
                                    when o.msg_type in ('MSGTREPR') then 'Representment'
                                    else 'Other - '||o.msg_type
                               end as message_type
                             , case when o.oper_type = 'OPTP0000' then '100 - Purchase'
                                    when o.oper_type = 'OPTP0001' then '310 - ATM Cash'
                                    when o.oper_type = 'OPTP0010' then '120 - P2P Debit'
                                    when o.oper_type = 'OPTP0012' then '300 - Manual Cash'
                                    when o.oper_type = 'OPTP0018' then '120 - Quasi-cach'
                                    when o.oper_type in ('OPTP0020', 'OPTP0028') then '200 - Merchandise credit'
                                    when o.oper_type = 'OPTP0026' then '330 - Original credit'
                                    else 'Other - '||o.oper_type
                               end as transaction_type
                             , f.sttl_amount
                               *
                               case when (o.msg_type not in ('MSGTCHBK', 'MSGTACBK') and
                                           o.oper_type not in ('OPTP0020' -- return (credit)
                                                             , 'OPTP0022' -- Cash-in
                                                             , 'OPTP0028' -- Payment
                                                             , 'OPTP0026' -- P2P Credit
                                                              )
                                         ) 
                                      or (o.msg_type in ('MSGTCHBK', 'MSGTACBK') and
                                                o.oper_type in ('OPTP0020' -- return (credit)
                                                              , 'OPTP0022' -- Cash-in
                                                              , 'OPTP0028' -- Payment
                                                              , 'OPTP0026' -- P2P Credit
                                                             )
                                         )
                                    then decode(f.is_reversal,0, 1, -1)
                                    else decode(f.is_reversal,0, -1, 1)
                                    end as oper_amount
                             , f.sttl_currency as oper_currency
                             , o.oper_type
                             , pcf.file_name
                          from vis_fin_message f
                          join vis_file vf on vf.id = f.file_id
                                          and trunc(vf.proc_date) = trunc(i_report_date)
                                          and vf.is_incoming = 1
                                          and ((i_curr_code = com_api_currency_pkg.RUBLE and vf.proc_bin like '9%') or
                                               (i_curr_code = com_api_currency_pkg.EURO and vf.proc_bin like '4%' and f.oper_currency = com_api_currency_pkg.EURO) 
                                             or
                                               (i_curr_code = com_api_currency_pkg.USDOLLAR and vf.proc_bin like '4%')
                                              )
                                          and vf.proc_bin in ('914076', '414076')
                     left join opr_operation o on o.id = f.id
                     left join cst_oper_file cof    on cof.oper_id = f.id
                     left join prc_session_file pcf on pcf.id = cof.session_file_id
                         where f.trans_code = 15 and f.is_incoming = 1
                             ) t
                     union all
                        -- sms transactions
                       select distinct
                              3 as part
                            , null as file_id
                            , case when oo.msg_type in ('MSGTAUTH', 'MSGTFPST', 'MSGTCMPL', 'MSGTPRES') then 'Presentment'
                                   when oo.msg_type in ('MSGTCHBK', 'MSGTACBK') then 'Chargeback'
                                          when oo.msg_type in ('MSGTREPR') then 'Representment'
                                          else 'Other - '||oo.msg_type
                                      end as message_type
                            , case when oo.oper_type = 'OPTP0001' then '310 - ATM Cash'
                                   when oo.oper_type = 'OPTP0012' then '300 - Manual Cash'
                                   when oo.oper_type = 'OPTP0010' then '330 - P2P Debit'
                                   when oo.oper_type = 'OPTP0011' then '330 - P2P'
                                   when oo.oper_type = 'OPTP0026' then '330 - Original Credit'
                                   else oo.oper_type || ' - Other' end as transaction_type
                            , count(1) over (partition by oo.oper_type, oo.oper_currency, psf.file_name) as quantity
                            , null as second_amount
                            , null as third_amount
                            , null as bus_tr_type_nf
                            , null as bus_mode_nf
                            , sum(oo.oper_amount
                                   *
                                   case when (oo.msg_type not in ('MSGTCHBK', 'MSGTACBK') and
                                              oo.oper_type not in ('OPTP0020' -- return (credit)
                                                                 , 'OPTP0022' -- Cash-in
                                                                 , 'OPTP0028' -- payment
                                                                 , 'OPTP0026' -- P2P Credit
                                                                   )
                                             ) 
                                          or
                                             (oo.msg_type in ('MSGTCHBK', 'MSGTACBK') and
                                              oo.oper_type in ('OPTP0020' -- return (credit)
                                                             , 'OPTP0022' -- Cash-in
                                                             , 'OPTP0028' -- payment
                                                             , 'OPTP0026' -- P2P Credit
                                                              )
                                             )
                                          then decode(oo.is_reversal,0, 1, -1)
                                          else decode(oo.is_reversal,0, -1, 1)
                                    end
                                   ) over (partition by oo.oper_type
                                                      , oo.oper_currency
                                                      , psf.file_name) as first_amount_nf
                            , oo.oper_currency as operation_currency
                            , null as second_amount_nf
                            , null as third_amount_nf
                            , null as clear_currency_nf
                            , psf.file_name as file_name
                            , null as sttl_amount
                         from opr_operation oo
                         join opr_participant op   on oo.id = op.oper_id
                                                   and op.participant_type = 'PRTYISS'
                                                   and ((i_curr_code = com_api_currency_pkg.RUBLE and op.network_id in (1008, 7004)) or
                                                        (i_curr_code = com_api_currency_pkg.EURO
                                                         and op.network_id in (1003, 5004)
                                                         and oo.oper_currency = i_curr_code) or
                                                        (i_curr_code = com_api_currency_pkg.USDOLLAR
                                                         and op.network_id in (1003, 5004)
                                                         and oo.oper_currency != com_api_currency_pkg.EURO))
                    left join evt_event_object eeo on oo.id = eeo.object_id
                                                  and eeo.procedure_name = 'CST_OW_PKG.UPLOAD_M_FILE'
                                                  and eeo.status = 'EVST0002'
                                                  and ((l_inst_id in (2005, 2006, 2011, 2012, 2013) and eeo.inst_id in ('2005', '2011', '2012', '2013')) or
                                                        (l_inst_id not in (2005, 2006, 2011, 2012, 2013) and eeo.inst_id = l_inst_id))
                    left join prc_session_file psf on eeo.proc_session_id = psf.session_id
                        where oo.id between com_api_id_pkg.get_from_id(i_date => i_report_date - 2)
                                        and com_api_id_pkg.get_till_id(i_date => i_report_date)
                          and oo.host_date between trunc(i_report_date) - 11/24
                                               and trunc(i_report_date) + 13/24 - 1/86400
                          and oo.oper_type in ('OPTP0001', 'OPTP0012', 'OPTP0010', 'OPTP0011', 'OPTP0026')
                          and oo.terminal_type in ('TRMT0002', 'TRMT0003')
                          and oo.sttl_type    = 'STTT0200'
                          and oo.msg_type     = 'MSGTAUTH'
                          and oo.acq_inst_bin = '464153'
                    union all
                        -- 4 Issuing processed totals
                       select distinct
                              4 as part
                            , t.id as file_id
                            , case when t.msg_type in ('MSGTAUTH', 'MSGTFPST', 'MSGTCMPL', 'MSGTPRES') then 'Presentment'
                                   when t.msg_type in ('MSGTCHBK', 'MSGTACBK') then 'Chargeback'
                                   when t.msg_type in ('MSGTREPR') then 'Representment'
                                   else 'Other - '||t.msg_type end as message_type
                            , t.oper_type as transaction_type
                            , count(1) over (partition by t.msg_type, t.oper_type, t.file_name) as quantity
                            , null as second_amount
                            , null as third_amount
                            , null as bus_tr_type_nf
                            , null as bus_mode_nf
                            , sum(t.sttl_amount) over (partition by t.msg_type, t.oper_type, t.file_name) as first_amount_nf
                            , null as oper_currency
                            , null as second_amount_nf
                            , null as third_amount_nf
                            , null as clear_currency_nf
                            , t.file_name
                            , null as sttl_amount
                         from (select case when f.sttl_currency <> 643 and f.network_currency = 643
                                           then f.network_amount
                                           else f.sttl_amount end
                                      *
                                      case when o.oper_type in ('OPTP0020' -- return (credit)
                                                              , 'OPTP0022' -- Cash-in
                                                              , 'OPTP0028' -- Payment
                                                              , 'OPTP0026' -- P2P Credit
                                                               )
                                           then decode(f.is_reversal,0, -1, 1)
                                           else decode(f.is_reversal,0, 1, -1)
                                      end as sttl_amount
                                     , nvl(pcf.file_name, pcf2.file_name) as file_name
                                     , vf.id
                                     , nvl(pcf.file_date, pcf2.file_date) as file_date
                                     , case when o.oper_type = 'OPTP0000' then '100 - Purchase'
                                            when o.oper_type = 'OPTP0001' then '310 - ATM Cash'
                                            when o.oper_type = 'OPTP0010' then '120 - P2P Debit'
                                            when o.oper_type = 'OPTP0012' then '300 - Manual Cash'
                                            when o.oper_type = 'OPTP0018' then '120 - Quasi-cach'
                                            when o.oper_type in ('OPTP0020', 'OPTP0028') then '200 - Merchandise credit'
                                            when o.oper_type = 'OPTP0026' then '330 - Original credit'
                                            else 'Other - '||o.oper_type
                                       end as oper_type
                                     , o.msg_type
                                     , f.oper_currency
                                 from vis_fin_message f
                                 join opr_operation o on o.id = f.id
                                 join vis_file vf on vf.id = f.file_id
                                                 and trunc(vf.sttl_date) = trunc(i_report_date) --to_date('09/02/2015', 'mm/dd/yyyy')
                                                 and ((i_curr_code = com_api_currency_pkg.RUBLE and vf.proc_bin like '9%') or
                                                      (i_curr_code != com_api_currency_pkg.RUBLE and vf.proc_bin like '4%'))
                                                 and vf.proc_bin in ('914076', '414076')
                                                 and vf.is_incoming = 1
                            left join evt_event_object eo  on eo.object_id       = o.id
                                                          and eo.procedure_name  = 'CST_OW_PKG.UPLOAD_C_FILE'
                                                          and eo.entity_type     = 'ENTTOPER'
                            left join prc_session_file pcf on pcf.session_id     = eo.proc_session_id
                            left join evt_event_object eo2 on eo2.object_id      = o.match_id
                                                          and eo2.procedure_name = 'CST_OW_PKG.UPLOAD_C_FILE'
                                                          and eo2.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                                                          and o.oper_type = 'OPTP0026'
                            left join prc_session_file pcf2 on pcf2.session_id = eo2.proc_session_id
                                where f.trans_code <> 15
                                  and ((i_curr_code = com_api_currency_pkg.USDOLLAR and
                                    f.sttl_currency = i_curr_code and
                                   f.oper_currency != com_api_currency_pkg.EURO) or
                                        (i_curr_code = com_api_currency_pkg.EURO and
                                         (f.sttl_currency = i_curr_code or (f.sttl_currency = com_api_currency_pkg.USDOLLAR and
                                                                           f.oper_currency = com_api_currency_pkg.EURO))) or
                                        (i_curr_code = com_api_currency_pkg.RUBLE))
                            union all
                               select case when f.sttl_currency <> 643 and f.network_currency = 643
                                            then f.network_amount
                                            else f.sttl_amount end
                                       * (-1)
                                       *
                                       case when o.oper_type in ('OPTP0020', -- return (credit)
                                                                 'OPTP0022', -- Cash-in
                                                                 'OPTP0028', -- Merchandise credit
                                                                 'OPTP0026'  -- P2P Credit
                                                                 )
                                            then decode(f.is_reversal,0, -1, 1)
                                            else decode(f.is_reversal,0, 1, -1)
                                       end as sttl_amount
                                     , pcf.file_name
                                     , vf.id
                                     , pcf.file_date
                                     , case when o.oper_type = 'OPTP0000' then '100 - Purchase'
                                            when o.oper_type = 'OPTP0001' then '310 - ATM Cash'
                                            when o.oper_type = 'OPTP0010' then '120 - P2P Debit'
                                            when o.oper_type = 'OPTP0012' then '300 - Manual Cash'
                                            when o.oper_type = 'OPTP0018' then '120 - Quasi-cach'
                                            when o.oper_type in ('OPTP0020', 'OPTP0028') then '200 - Merchandise credit'
                                            when o.oper_type = 'OPTP0026' then '330 - Original credit'
                                            else 'Other - '||o.oper_type
                                       end as oper_type
                                     , o.msg_type
                                     , f.oper_currency
                                  from vis_fin_message f
                                  join vis_file vf on vf.id = f.file_id
                                                  and trunc(vf.proc_date) = trunc(i_report_date - 1)--to_date('09/01/2015', 'mm/dd/yyyy')
                                                  and vf.is_incoming = 0
                                                  and ((i_curr_code = com_api_currency_pkg.RUBLE and vf.proc_bin like '9%') or
                                                       (i_curr_code != com_api_currency_pkg.RUBLE and vf.proc_bin like '4%'))
                                                  and vf.proc_bin in ('914076', '414076')
                                  join opr_operation o on o.id = f.id
                                                      and o.msg_type = 'MSGTCHBK'
                                  left join cst_oper_file cof    on cof.oper_id = f.id
                                  left join prc_session_file pcf on pcf.id = cof.session_file_id
                                 where ((i_curr_code = com_api_currency_pkg.USDOLLAR and
                                          f.sttl_currency = i_curr_code and
                                          f.oper_currency != com_api_currency_pkg.EURO) or
                                        (i_curr_code != com_api_currency_pkg.USDOLLAR))
                                  ) t
                        )
                        -- result
                        select r2.*
                             , r2.clearing_totals_p1 - r2.sum_by_part as diff1
                             , r2.tot_amount_p2 + r2.sum_by_part as diff2
                             , r2.sum_by_part - r2.not_exported as exported
                          from (select r.activity
                                     , r.part
                                     , r.file_id
                                     , r.settlement_currency
                                     , r.message_type
                                     , r.transaction_type
                                     , r.quantity
                                     , r.interch_amount as amount
                                     , r.credit
                                     , r.credit_by_part
                                     , r.debit
                                     , r.debit_by_part
                                     , r.credit_fee
                                     , r.credit_fee_by_part
                                     , r.debit_fee
                                     , r.debit_fee_by_part
                                     , r.file_name
                                     , r.cnt_by_part
                                     , sum(r.amount) over (partition by r.part) as sum_by_part
                                     , sum(r.interch_amount) over (partition by r.part) as interch_sum_by_part
                                     , r.tot_amount_p2
                                     , r.not_exported
                                     , nvl(r.amount, 0) + nvl(r.credit_fee, 0) + nvl(r.debit_fee, 0) as total
                                     , sum(case when r.part in (1, 2) then nvl(r.amount, 0) + nvl(r.credit_fee, 0) + nvl(r.debit_fee, 0)
                                              else 0 end) over () as total_p1p2
                                     , sum(nvl(r.amount, 0) + nvl(r.credit_fee, 0) + nvl(r.debit_fee, 0)) over (partition by r.part) as total_by_part
                                     , r.clearing_tot
                                     , r.clearing_totals_p1
                                     , r.clear_currency
                                     , r.oper_currency
                                  from (select decode(t.part, 1, 'Acquiring settled totals',
                                                              2, 'Issuing settled totals',
                                                              3, 'Acquiring settled totals',
                                                              4, 'Issuing processed totals') as activity
                                              , t.part
                                              , t.file_id
                                              , cc.name as settlement_currency
                                              , t.transaction_type
                                              , t.quantity
                                              , case when i_curr_code in ('978') and t.part in (1, 2)
                                                        then round(t.second_amount_nf/ nvl(power(10, cc.exponent),1),2) + round(t.third_amount_nf/ nvl(power(10, cc.exponent),1),2)
                                                    else round(t.first_amount_nf/ nvl(power(10, cc.exponent),1),2)
                                                 end as interch_amount
                                              , case when i_curr_code in ('840', '978') and t.part in (1, 2)
                                                        then round(t.second_amount_nf/ nvl(power(10, cc.exponent),1),2) + round(t.third_amount_nf/ nvl(power(10, cc.exponent),1),2)
                                                    else round(t.first_amount_nf/ nvl(power(10, cc.exponent),1),2)
                                                 end as amount
                                              , round(t.second_amount_nf/ nvl(power(10, cc.exponent),1),2) as credit
                                              , sum(round(t.second_amount_nf/ nvl(power(10, cc.exponent),1),2)) over (partition by t.part) as credit_by_part
                                              , round(t.third_amount_nf/ nvl(power(10, cc.exponent),1),2) as debit
                                              , sum(round(t.third_amount_nf/ nvl(power(10, cc.exponent),1),2)) over (partition by t.part) as debit_by_part
                                              , round(t.second_amount/ nvl(power(10, cc.exponent),1),2) as credit_fee
                                              , sum(round(t.second_amount/ nvl(power(10, cc.exponent),1),2)) over (partition by t.part) as credit_fee_by_part
                                              , round(t.third_amount/ nvl(power(10, cc.exponent),1),2) as debit_fee
                                              , sum(round(t.third_amount/ nvl(power(10, cc.exponent),1),2)) over (partition by t.part) as debit_fee_by_part
                                              , t.file_name
                                              , sum(t.quantity) over (partition by t.part) as cnt_by_part
                                              , sum(case when t.part = 2 and i_curr_code != '978' then round(t.first_amount_nf/ nvl(power(10, cc.exponent),1),2)
                                                         when t.part = 2 and i_curr_code = '978' then round((t.second_amount_nf + t.third_amount_nf)/ nvl(power(10, cc.exponent),1),2)
                                                         else 0 end) over () as tot_amount_p2
                                              , sum(case when t.file_name is null
                                                         then round(t.first_amount_nf/ nvl(power(10, cc.exponent),1),2) else 0 end)
                                                     over (partition by t.part) as not_exported
                                              , case when t.transaction_type != '519 - Fee Collection'
                                                         then round(t.first_amount_nf/ nvl(power(10, cc.exponent),1),2)
                                                         else null end as clearing_tot
                                              , t.first_amount_nf
                                              , cc.exponent
                                              , sum(case when t.part = 1 and t.transaction_type != '519 - Fee Collection'
                                                         then round(t.first_amount_nf/ nvl(power(10, cc.exponent),1),2)
                                                         else 0 end) over () as clearing_totals_p1
                                              , t.message_type
                                              , clear_currency_nf as clear_currency
                                              , oper_currency
                                          from t
                                          join com_ui_currency_vw cc on cc.code = i_curr_code
                                                                    and cc.lang = 'LANGENG'
                                         order by t.part, t.transaction_type) r )r2
);
    -- fill "operations" tag for empty report creation
    for i in (
        select 1 
          from dual 
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
      select xmlelement("operations", xmlagg(xmlelement("operation"))) 
        into l_operations 
        from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.visa_settl');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end;


-- Visa report  RUB
procedure visa_settl_rub(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.visa_settl_rub [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    visa_settl(
        o_xml          =>  o_xml
      , i_report_date  => i_report_date
      , i_lang         => i_lang
      , i_inst_id      => i_inst_id
      , i_curr_code    => com_api_currency_pkg.RUBLE
    );

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.visa_settl_rub');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end visa_settl_rub;

-- Visa report USD
procedure visa_settl_usd(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
) is
begin
    trc_log_pkg.debug(
        i_text => 'START: cst_api_report_pkg.visa_settl_usd [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    visa_settl(
        o_xml         =>  o_xml
      , i_report_date => i_report_date
      , i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_curr_code   => com_api_currency_pkg.USDOLLAR
    );

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.visa_settl_usd');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end visa_settl_usd;

-- Visa report EUR
procedure visa_settl_eur(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.visa_settl_eur [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    visa_settl(
        o_xml         =>  o_xml
      , i_report_date => i_report_date
      , i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_curr_code   => com_api_currency_pkg.EURO
    );

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.visa_settl_eur');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end visa_settl_eur;

function get_member_id(
    i_inst_id in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_cmid is
    l_return com_api_type_pkg.t_cmid;
begin
    l_return := case when i_inst_id = 2000 then '99991380901'
                     when i_inst_id = 2002 then '99991380901'
                     when i_inst_id = 2003 then '99991380901'
                     when i_inst_id = 2005 then '99991380901'
                     when i_inst_id = 2006 then '99991380901'
                     when i_inst_id = 2011 then '99991380901'
                     when i_inst_id = 2012 then '99991380901'
                     when i_inst_id = 2013 then '99991380901'
                     else '00000000000'
                end;
    return l_return;
end get_member_id;

-- MIR report transactions - acq
procedure mup_transactions_acq(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
) is
    l_header       xmltype;
    l_operations   xmltype;
    l_result       xmltype;

    l_report_date  date;
    l_lang         com_api_type_pkg.t_dict_value;
    l_inst_id      com_api_type_pkg.t_inst_id;
    l_inst_ica     com_api_type_pkg.t_cmid;
begin
    execute immediate 'alter session set NLS_LANGUAGE=RUSSIAN';

    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.mup_transactions_acq [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_report_date := nvl(i_report_date, sysdate - 1);
    l_lang        := nvl(i_lang, get_user_lang);
    l_inst_id     := nvl(i_inst_id, 0);
    l_inst_ica    := get_member_id(l_inst_id);

    -- header
    select xmlconcat(
               xmlelement("inst_id",        l_inst_id)
                , xmlelement("inst",        com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
                , xmlelement("report_date", to_char(l_report_date,'dd.mm.yyyy'))
                , xmlelement("part",        'Acquirer transactions')
           )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("mastercard_file_id",      mup_file_id)
                     , xmlelement("message_type",            message_type)
                     , xmlelement("function_code",           function_code)
                     , xmlelement("transaction_type",        transaction_type)
                     , xmlelement("reversal_indicator",      reversal_indicator)
                     , xmlelement("transaction_id",          transaction_id)
                     , xmlelement("card_number",             card_number)
                     , xmlelement("transaction_date",        transaction_date)
                     , xmlelement("transaction_amount",      transaction_amount)
                     , xmlelement("transaction_currency",    transaction_currency)
                     , xmlelement("settlement_amount",       settlement_amount)
                     , xmlelement("settlement_currency",     settlement_currency)
                     , xmlelement("approval_code",           approval_code)
                     , xmlelement("rrn",                     rrn)
                     , xmlelement("arn",                     arn)
                     , xmlelement("terminal_id",             terminal_id)
                     , xmlelement("merchant_id",             merchant_id)
                     , xmlelement("mcc",                     mcc)
                     , xmlelement("merchant",                merchant)
                     , xmlelement("reason_code",             reason_code)
                     , xmlelement("is_rejected",             is_rejected)
                     , xmlelement("destination_institution", destination_institution)
                     , xmlelement("originator_institution",  originator_institution)
                     , xmlelement("file_name",               file_name)
                     , xmlelement("fee_coll_detail",         fee_coll_detail)
                     , xmlelement("reject_id",               reject_id)
                     , xmlelement("payment_code",            payment_code)
                     , xmlelement("oper_type",               oper_type)
                     , xmlelement("card_country",            card_country)
                   ) 
              order by mup_file_id
                     , message_type
                     , function_code
                     , transaction_type
                     , reversal_indicator
                     , transaction_id
               )
           )
      into l_operations
      from (select mup_file_id
                 , message_type
                 , function_code
                 , transaction_type
                 , reversal_indicator
                 , transaction_id
                 , card_number
                 , transaction_date
                 , transaction_amount
                 , transaction_currency
                 , settlement_amount
                 , settlement_currency
                 , approval_code
                 , rrn
                 , arn
                 , terminal_id
                 , merchant_id
                 , mcc
                 , merchant
                 , reason_code
                 , is_rejected
                 , destination_institution
                 , originator_institution
                 , listagg (m_file_name, ',') within group (order by transaction_id) as file_name
                 , fee_coll_detail
                 , reject_id
                 , payment_code
                 , oper_type
                 , card_country 
              from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mup_file_id
                         , mf.id as transaction_id
                         , mc.card_number as card_number
                         , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                         , '1442', mf.mti || ' - Chargeback'
                                         , '1740', mf.mti || ' - Fee collection'
                                         , '1644', mf.mti || ' - Retrieval request'
                                         , '1244', mf.mti || ' - Financial notification'
                                         ,         mf.mti || ' - Other') as message_type
                         , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                           , '205', mf.de024 || ' - Second presentment (Full)'
                                           , '282', mf.de024 || ' - Second presentment (Partial)'
                                           , '299', mf.de024 || ' - Financial notification'
                                           , '450', mf.de024 || ' - First Chargeback (Full)'
                                           , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                           , '453', mf.de024 || ' - First Chargeback (Partial)'
                                           , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                           , '603', mf.de024 || ' - Retrieval request'
                                           , '680', mf.de024 || ' - File Currency Summary'
                                           , '685', mf.de024 || ' - Financial Position Detail'
                                           , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                           , '780', mf.de024 || ' - Fee Collection Return'
                                           , '781', mf.de024 || ' - Fee Collection Resubmission'
                                           , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                           , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                           , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                           , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                           ,        mf.de024 || ' - Other') as function_code
                         , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                            , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                            , '12', mf.de003_1 || ' - Cash Disbursement'
                                            , '17', mf.de003_1 || ' - Convenience Check'
                                            , '18', mf.de003_1 || ' - Unique Transaction'
                                            , '19', mf.de003_1 || ' - Fee Collection'
                                            , '20', mf.de003_1 || ' - Refund'
                                            , '26', mf.de003_1 || ' - Cash-to-Card Payments'
                                            , '28', mf.de003_1 || ' - Card-to-Card Payments'
                                            , '29', mf.de003_1 || ' - Fee Collection'
                                            , '30', mf.de003_1 || ' - Balance Inquiry'
                                            , '92', mf.de003_1 || ' - PIN change'
                                            ,       mf.de003_1 || ' - Other') as transaction_type
                         , decode(oo.is_reversal, 0, 'No'
                                                , 1, 'Yes'
                                                , 'Unknown') as reversal_indicator
                         , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                         , mf.de004 * case when (oo.oper_type in ('OPTP0026' -- OPTP0026
                                                                , 'OPTP0022' -- Cash-In
                                                                , 'OPTP0020' -- return (credit)
                                                                  )
                                                and oo.is_reversal = 0)
                                              or
                                                (oo.oper_type not in ('OPTP0026' -- OPTP0026
                                                                    , 'OPTP0022' -- Cash-In
                                                                    , 'OPTP0020' -- return (credit)
                                                                      )
                                                and oo.is_reversal != 0)
                                           then -1 else 1 end/100 as transaction_amount
                         , de049 as transaction_currency
                         , decode(mff.network_id, '7017', 'MIR NSPK'
                                                ,         mff.network_id) as settlement_amount
                         , decode(mff.network_id, '7017', '643'
                                                ,         '643') as settlement_currency
                         , de038 as approval_code
                         , de037 as rrn
                         , de031 as arn
                         , de041 as terminal_id
                         , de042 as merchant_id
                         , de026 as mcc
                         , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                           rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                         , mf.de025 as reason_code
                         , decode(mf.is_rejected, 0, 'Sent'
                                                , 1, 'Rejected'
                                                , 'Unknown') as is_rejected
                         , de093 as destination_institution
                         , mf.de094 as originator_institution
                         , decode(mf.inst_id,'9945','Customs payment',pcf.file_name) as m_file_name
                         , case when mf.de025 <> '7621' and mf.mti = '1740' then mf.de072 else null end as fee_coll_detail
                         , mf.reject_id as reject_id
                         , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                then get_payment_code(i_op_id      => decode(oo.is_reversal, 1, oo.original_id, oo.id)
                                                    , i_op_id_preu => case when oo.msg_type = 'MSGTCMPL' and oo.oper_type = 'OPTP0060'
                                                                           then oo.original_id else null end)
                                else null end as payment_code
                         , oo.oper_type||' - '||com_api_dictionary_pkg.get_article_text(i_article => oo.oper_type) as oper_type
                         , op.card_country
                      from mup_fin mf
                      join mup_card mc               on mf.id = mc.id
                      join mup_file mff              on mff.id = mf.file_id
                      join opr_operation oo          on oo.id = mf.id
                 left join opr_participant op   on op.oper_id = mf.id
                                               and op.participant_type = 'PRTYISS'
                 left join cst_oper_file cof    on cof.oper_id = oo.id
                 left join prc_session_file pcf on pcf.id = cof.session_file_id
                     where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 3)
                        in ('102/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/000')
                       and ((l_inst_id in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id in (2005, 2006, 2011, 2012, 2013, 2014)) 
                          or(l_inst_id not in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id = l_inst_id))
                       and mf.p0165 != 'R')
                  group by mup_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
                         , card_number
                         , transaction_date
                         , transaction_amount
                         , transaction_currency
                         , settlement_amount
                         , settlement_currency
                         , approval_code
                         , rrn
                         , arn
                         , terminal_id
                         , merchant_id
                         , mcc
                         , merchant
                         , reason_code
                         , is_rejected
                         , destination_institution
                         , originator_institution
                         , fee_coll_detail
                         , reject_id
                         , payment_code
                         , oper_type
                         , card_country);

    -- fill Operation tag for empty report creation
    for i in (select 1 from dual where existsnode(l_operations, '/operations/operation') = 0) loop
      select xmlelement("operations", xmlagg(xmlelement("operation"))) into l_operations from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.master_card_transactions_acq');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end mup_transactions_acq;

-- MIR report transactions - iss
procedure mup_transactions_iss(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
) is
    l_header       xmltype;
    l_operations   xmltype;
    l_result       xmltype;

    l_report_date  date;
    l_lang         com_api_type_pkg.t_dict_value;
    l_inst_id      com_api_type_pkg.t_inst_id;
    l_inst_ica     com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.mup_transactions_iss [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_report_date := nvl(i_report_date, sysdate - 1);
    l_lang        := nvl(i_lang, get_user_lang);
    l_inst_id     := nvl(i_inst_id, 0);
    l_inst_ica    := get_member_id(l_inst_id);

    -- header
    select xmlconcat(
               xmlelement("inst_id", l_inst_id)
                 , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
                 , xmlelement("report_date", to_char(l_report_date,'dd.mm.yyyy'))
                 , xmlelement("part", 'Issuer transactions')
           )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("mastercard_file_id",      mup_file_id)
                     , xmlelement("message_type",            message_type)
                     , xmlelement("function_code",           function_code)
                     , xmlelement("transaction_type",        transaction_type)
                     , xmlelement("reversal_indicator",      reversal_indicator)
                     , xmlelement("transaction_id",          transaction_id)
                     , xmlelement("card_number",             card_number)
                     , xmlelement("transaction_date",        transaction_date)
                     , xmlelement("transaction_amount",      transaction_amount)
                     , xmlelement("transaction_currency",    transaction_currency)
                     , xmlelement("settlement_amount",       settlement_amount)
                     , xmlelement("settlement_currency",     settlement_currency)
                     , xmlelement("interchange_fee",         interchange_fee)
                     , xmlelement("approval_code",           approval_code)
                     , xmlelement("rrn",                     rrn)
                     , xmlelement("arn",                     arn)
                     , xmlelement("terminal_id",             terminal_id)
                     , xmlelement("merchant_id",             merchant_id)
                     , xmlelement("mcc",                     mcc)
                     , xmlelement("merchant",                merchant)
                     , xmlelement("reason_code",             reason_code)
                     , xmlelement("is_rejected",             is_rejected)
                     , xmlelement("destination_institution", destination_institution)
                     , xmlelement("originator_institution",  originator_institution)
                     , xmlelement("file_name",               file_name)
                     , xmlelement("fee_coll_detail",         fee_coll_detail)
                     , xmlelement("reject_id",               reject_id)
                     , xmlelement("payment_code",            payment_code)
                     , xmlelement("oper_type",               oper_type)
                     , xmlelement("card_acceptor_country",   card_acceptor_country)
                     , xmlelement("product_id",              product_id)
                     , xmlelement("ifd",                     ifd)
                   )
                   order by mup_file_id
                          , message_type
                          , function_code
                          , transaction_type
                          , reversal_indicator
                          , transaction_id
               )
           )
      into l_operations
      from (select t.mup_file_id
                 , t.message_type
                 , t.function_code
                 , t.transaction_type
                 , t.reversal_indicator
                 , t.transaction_id
                 , t.card_number
                 , t.transaction_date
                 , t.transaction_amount * t.direction as transaction_amount
                 , t.transaction_currency
                 , t.settlement_amount * t.direction as settlement_amount
                 , t.settlement_currency
                 , t.interchange_fee
                 , t.approval_code
                 , t.rrn
                 , t.arn
                 , t.terminal_id
                 , t.merchant_id
                 , t.mcc
                 , t.merchant
                 , t.reason_code
                 , 'Sent' as is_rejected
                 , t.destination_institution
                 , t.originator_institution
                 , listagg (t.c_file_name, ',') within group (order by t.transaction_id) as file_name
                 , t.fee_coll_detail
                 , t.reject_id
                 , t.payment_code
                 , t.oper_type
                 , t.card_acceptor_country
                 , t.product_id
                 , t.ifd
              from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mup_file_id
                         , mf.id as transaction_id
                         , mc.card_number as card_number
                         , decode(mf.mti, '1240', mf.mti || ' - Presentment'
                                        , '1442', mf.mti || ' - Chargeback'
                                        , '1740', mf.mti || ' - Fee collection'
                                        , '1644', mf.mti || ' - Retrieval request'
                                        , '1244', mf.mti || ' - Financial notification'
                                        ,         mf.mti || ' - Other') as message_type
                         , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                           , '205', mf.de024 || ' - Second presentment (Full)'
                                           , '282', mf.de024 || ' - Second presentment (Partial)'
                                           , '299', mf.de024 || ' - Financial notification'
                                           , '450', mf.de024 || ' - First Chargeback (Full)'
                                           , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                           , '453', mf.de024 || ' - First Chargeback (Partial)'
                                           , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                           , '603', mf.de024 || ' - Retrieval request'
                                           , '680', mf.de024 || ' - File Currency Summary'
                                           , '685', mf.de024 || ' - Financial Position Detail'
                                           , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                           , '780', mf.de024 || ' - Fee Collection Return'
                                           , '781', mf.de024 || ' - Fee Collection Resubmission'
                                           , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                           , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                           , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                           , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                           ,        mf.de024 || ' - Other') as function_code
                         , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                            , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                            , '12', mf.de003_1 || ' - Cash Disbursement'
                                            , '17', mf.de003_1 || ' - Convenience Check'
                                            , '18', mf.de003_1 || ' - Unique Transaction'
                                            , '19', mf.de003_1 || ' - Fee Collection'
                                            , '20', mf.de003_1 || ' - Refund'
                                            , '26', mf.de003_1 || ' - Cash-to-Card Payments'
                                            , '28', mf.de003_1 || ' - Card-to-Card Payments'
                                            , '29', mf.de003_1 || ' - Fee Collection'
                                            , '30', mf.de003_1 || ' - Balance Inquiry'
                                            , '92', mf.de003_1 || ' - PIN change'
                                            ,       mf.de003_1 || ' - Other') as transaction_type
                         , decode(oo.is_reversal, 0, 'No'
                                                , 1, 'Yes'
                                                ,    'Unknown') as reversal_indicator
                         , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                         , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, 1, -1)
                                            , '26', decode(mf.is_reversal, 0, 1, -1)
                                            , '28', decode(mf.is_reversal, 0, 1, -1)
                                            , '29', decode(mf.is_reversal, 0, 1, -1)
                                            ,       decode(mf.is_reversal, 0, -1, 1)) as direction
                         , case when mf.de024 in ('450', '451', '453', '454') 
                                then oo.oper_amount / 100
                                else mf.de004 / 100 end as transaction_amount
                         , case when mf.de024 in ('450', '451', '453', '454') 
                                then oo.oper_currency
                                else mf.de049 end as transaction_currency
                         , to_char(mf.de005 / 100) as settlement_amount
                         , to_char(mf.p0146_net / 100) as interchange_fee
                         , de050 as settlement_currency
                         , de038 as approval_code
                         , de037 as rrn
                         , de031 as arn
                         , de041 as terminal_id
                         , de042 as merchant_id
                         , de026 as mcc
                         , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                           rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                         , mf.de025 as reason_code
                         , null as is_rejected
                         , de093 as destination_institution
                         , mf.de094 as originator_institution
                         , pcf.file_name as c_file_name
                         , case when mf.de025 <> '7621' and mf.mti = '1740' then mf.de072 else null end as fee_coll_detail
                         , mf.reject_id as reject_id
                         , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                then get_payment_code(i_op_id      => decode(oo.is_reversal, 1, oo.original_id, oo.id),
                                                      i_op_id_preu => case when oo.msg_type = 'MSGTCMPL' and oo.oper_type = 'OPTP0060'
                                                                           then oo.original_id else null end)
                                else null end as payment_code
                         , oo.oper_type||' - '||com_api_dictionary_pkg.get_article_text(i_article => oo.oper_type) as oper_type
                         , mf.de043_6 as card_acceptor_country
                         , mf.p2158_5 as product_id
                         , mf.p2158_6 as ifd
                      from mup_fin mf
                      join mup_card mc               on mf.id  = mc.id
                      join mup_file mff              on mff.id = mf.file_id
                      join opr_operation oo          on oo.id  = mf.id
                 left join cst_oper_file cof    on cof.oper_id = mf.id
                 left join prc_session_file pcf on pcf.id      = cof.session_file_id
                     where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 3)
                        in ('101/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/011')
                       and not mf.de003_1 = '28'
                     union
                    select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mup_file_id
                         , mf.id as transaction_id
                         , mc.card_number as card_number
                         , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                         , '1442', mf.mti || ' - Chargeback'
                                         , '1740', mf.mti || ' - Fee collection'
                                         , '1644', mf.mti || ' - Retrieval request'
                                         , '1244', mf.mti || ' - Financial notification'
                                         ,         mf.mti || ' - Other') as message_type
                         , decode(mf.de024, '200', mf.de024 || ' - First Presentment'
                                          , '205', mf.de024 || ' - Second presentment (Full)'
                                          , '282', mf.de024 || ' - Second presentment (Partial)'
                                          , '299', mf.de024 || ' - Financial notification'
                                          , '450', mf.de024 || ' - First Chargeback (Full)'
                                          , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                          , '453', mf.de024 || ' - First Chargeback (Partial)'
                                          , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                          , '603', mf.de024 || ' - Retrieval request'
                                          , '680', mf.de024 || ' - File Currency Summary'
                                          , '685', mf.de024 || ' - Financial Position Detail'
                                          , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                          , '780', mf.de024 || ' - Fee Collection Return'
                                          , '781', mf.de024 || ' - Fee Collection Resubmission'
                                          , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                          , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                          , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                          , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                          ,        mf.de024 || ' - Other') as function_code
                         , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                            , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                            , '12', mf.de003_1 || ' - Cash Disbursement'
                                            , '17', mf.de003_1 || ' - Convenience Check'
                                            , '18', mf.de003_1 || ' - Unique Transaction'
                                            , '19', mf.de003_1 || ' - Fee Collection'
                                            , '20', mf.de003_1 || ' - Refund'
                                            , '26', mf.de003_1 || ' - Cash-to-Card Payments'
                                            , '28', mf.de003_1 || ' - Card-to-Card Payments'
                                            , '29', mf.de003_1 || ' - Fee Collection'
                                            , '30', mf.de003_1 || ' - Balance Inquiry'
                                            , '92', mf.de003_1 || ' - PIN change'
                                            ,       mf.de003_1 || ' - Other') as transaction_type
                         , decode(oo.is_reversal, 0, 'No'
                                                , 1, 'Yes'
                                                ,    'Unknown') as reversal_indicator
                         , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                         , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, 1, -1)
                                            , '26', decode(mf.is_reversal, 0, 1, -1)
                                            , '28', decode(mf.is_reversal, 0, 1, -1)
                                            , '29', decode(mf.is_reversal, 0, 1, -1)
                                            ,       decode(mf.is_reversal, 0, -1, 1)) as direction
                         , case when mf.de024 in ('450', '451', '453', '454') 
                                then oo.oper_amount / 100
                                else mf.de004 / 100 
                           end as transaction_amount
                         , case when mf.de024 in ('450', '451', '453', '454') 
                                then oo.oper_currency
                                else mf.de049 
                           end as transaction_currency
                         , to_char(mf.de005 / 100) as settlement_amount
                         , de050 as settlement_currency
                         , to_char(mf.p0146_net / 100) as interchange_fee
                         , de038 as approval_code
                         , de037 as rrn
                         , de031 as arn
                         , de041 as terminal_id
                         , de042 as merchant_id
                         , de026 as mcc
                         , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                           rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                         , mf.de025 as reason_code
                         , null as is_rejected
                         , de093 as destination_institution
                         , mf.de094 as originator_institution
                         , pcf.file_name as c_file_name
                         , case when mf.de025 <> '7621' and mf.mti = '1740' then mf.de072 else null end as fee_coll_detail
                         , mf.reject_id as reject_id
                         , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                then get_payment_code(i_op_id      => decode(oo.is_reversal, 1, oo.original_id, oo.id)
                                                    , i_op_id_preu => case when oo.msg_type = 'MSGTCMPL' and oo.oper_type = 'OPTP0060'
                                                                      then oo.original_id 
                                                                      else null end)
                                else null end as payment_code
                         , oo.oper_type||' - '||com_api_dictionary_pkg.get_article_text(i_article => oo.oper_type) as oper_type
                         , mf.de043_6 as card_acceptor_country
                         , mf.p2158_5 as product_id
                         , mf.p2158_6 as ifd
                      from mup_fin mf
                      join mup_card mc               on mf.id = mc.id
                      join mup_file mff              on mff.id = mf.file_id
                      join opr_operation oo          on oo.id = mf.id
                      left join cst_oper_file cof    on cof.oper_id = oo.match_id
                      left join prc_session_file pcf on pcf.id = cof.session_file_id
                     where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                           substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 3)
                        in ('101/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/011')
                       and mf.de003_1 = '28'
                       and ((l_inst_id in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id in (2005, 2006, 2011, 2012, 2013, 2014)) 
                          or(l_inst_id not in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id = l_inst_id))) t
                  group by mup_file_id
                         , message_type
                         , function_code
                         , transaction_type
                         , reversal_indicator
                         , transaction_id
                         , card_number
                         , transaction_date
                         , direction
                         , transaction_amount
                         , transaction_currency
                         , settlement_amount
                         , settlement_currency
                         , interchange_fee
                         , approval_code
                         , rrn
                         , arn
                         , terminal_id
                         , merchant_id
                         , mcc
                         , merchant
                         , reason_code
                         , is_rejected
                         , destination_institution
                         , originator_institution
                         , fee_coll_detail
                         , reject_id
                         , payment_code
                         , oper_type
                         , card_acceptor_country
                         , product_id
                         , ifd
                    );

    -- fill with "operation" tag for empty report creation
    for i in (
        select 1 
          from dual 
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
        select xmlelement("operations", xmlagg(xmlelement("operation"))) 
          into l_operations 
          from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.master_card_transactions_iss');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end mup_transactions_iss;



-- MIR settlement in RUR report
procedure mup_settl_rub(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
) is
    l_header       xmltype;
    l_operations   xmltype;
    l_result       xmltype;

    l_report_date  date;
    l_lang         com_api_type_pkg.t_dict_value;
    l_inst_id      com_api_type_pkg.t_inst_id;
    l_inst_ica     com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'START: cst_api_report_pkg.mup_settl_rub [#1] [#2] [#3]'
      , i_env_param1  => i_report_date
      , i_env_param3  => i_lang
      , i_env_param4  => i_inst_id
    );

    l_report_date := nvl(i_report_date, sysdate - 1);
    l_lang        := nvl(i_lang, get_user_lang);
    l_inst_id     := nvl(i_inst_id, 0);
    l_inst_ica    := get_member_id(l_inst_id);

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("report_date", to_char(l_report_date,'dd.mm.yyyy'))
        )
      into l_header
      from dual;

    -- data
    select xmlelement("operations"
             , xmlagg(
                   xmlelement("operation"
                     , xmlelement("part",                       part)
                     , xmlelement("settlement_currency",        settlement_currency)
                     , xmlelement("activity",                   activity)
                     , xmlelement("file_id",                    file_id)
                     , xmlelement("message_type",               message_type)
                     , xmlelement("function_code",              function_code)
                     , xmlelement("transaction_type",           transaction_type)
                     , xmlelement("ifd",                        ifd)
                     , xmlelement("product_id",                 product_id)
                     , xmlelement("quantity",                   quantity)
                     , xmlelement("settlement_amount",          format(settlement_amount))
                     , xmlelement("settlement_fee",             format(settlement_fee))
                     , xmlelement("settlement_total",           format(settlement_total))
                     , xmlelement("clearing_currency",          clearing_currency)
                     , xmlelement("clearing_amount",            format(clearing_amount))
                     , xmlelement("file_name",                  file_name)
                     , xmlelement("tot_quantity",               tot_quantity)
                     , xmlelement("tot_settlement_amount",      format(tot_settlement_amount))
                     , xmlelement("tot_settlement_fee",         format(tot_settlement_fee))
                     , xmlelement("tot_settlement_total",       format(tot_settlement_total))
                     , xmlelement("tot_clearing_amount",        format(tot_clearing_amount))
                     , xmlelement("tot_settlement_total_p1_p2", format(tot_settlement_total_p1_p2))
                     , xmlelement("tot_clearing_amount_p1",     format(tot_clearing_amount_p1))
                     , xmlelement("tot_settlement_amount_p1",   format(tot_settlement_amount_p1))
                     , xmlelement("tot_settlement_amount_p2",   format(tot_settlement_amount_p2))
                     , xmlelement("diff1",                      format(diff1))
                     , xmlelement("diff2",                      format(diff2))
                     , xmlelement("exported",                   format(exported))
                     , xmlelement("not_exported",               format(not_exported))
                   )
                   order by part
                          , settlement_currency
                          , activity
                          , file_id
                          , message_type
                          , function_code
               )
           )
      into l_operations
      from (with t as 
            -- PART 1, 2
               (select decode(substr(p0300, 1, 3), '102', 1, 2) as part
                     , de050 as settlement_currency
                     , decode(substr(p0300, 1, 3), '101', 'Issuing settled'
                                                 , '102', 'Acquiring settled'
                                                 ,        'Acquiring settled') as activity
                     , substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6)  || '/' || 
                       substr(p0300, 10, 11)  || '/' || substr(p0300, 21, 5) as file_id
                     , decode(p0372_1, '1240', p0372_1 || ' - Presentment'
                                     , '1442', p0372_1 || ' - Chargeback'
                                     , '1740', p0372_1 || ' - Fee Collection'
                                     , '1644', p0372_1 || ' - Retrieval request'
                                     , '1244', p0372_1 || ' - Financial notification'
                                     ,         p0372_1 || ' - Other') as message_type
                     , decode (p0372_2, '200', p0372_2 || ' - First Presentment'
                                      , '205', p0372_2 || ' - Second presentment (Full)'
                                      , '282', p0372_2 || ' - Second presentment (Partial)'
                                      , '299', p0372_2 || ' - Financial notification'
                                      , '450', p0372_2 || ' - First Chargeback (Full)'
                                      , '451', p0372_2 || ' - Arbitration Chargeback (Full)'
                                      , '453', p0372_2 || ' - First Chargeback (Partial)'
                                      , '454', p0372_2 || ' - Arbitration Chargeback (Partial)'
                                      , '603', p0372_2 || ' - Retrieval request'
                                      , '680', p0372_2 || ' - File Currency Summary'
                                      , '685', p0372_2 || ' - Financial Position Detail'
                                      ,        p0372_2 || ' - Other') as function_code
                     , decode(p0374, '00', p0374 || ' - Purchase'
                                   , '01', p0374 || ' - ATM Cash Withdrawal'
                                   , '12', p0374 || ' - Cash Disbursement'
                                   , '17', p0374 || ' - Convenience Check'
                                   , '18', p0374 || ' - Unique Transaction'
                                   , '19', p0374 || ' - Fee Collection'
                                   , '20', p0374 || ' - Refund'
                                   , '26', p0374 || ' - Cash-to-Card Payments'
                                   , '28', p0374 || ' - Card-to-Card Payments'
                                   , '29', p0374 || ' - Fee Collection'
                                   , '30', p0374 || ' - Balance Inquiry'
                                   , '92', p0374 || ' - PIN change'
                                   ,       p0374 || ' - Other') as transaction_type
                     , p2358_6 as ifd
                     , p2358_5 as product_id
                     , p0402 as quantity
                     , p0394_2 * decode(p0394_1, 'D', -1, 1) / 100 as settlement_amount
                     , p0395_2 * decode(p0395_1, 'D', -1, 1) / 100 as settlement_fee
                     , p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 as settlement_total
                     , de049 as clearing_currency
                     , p0384_2 * decode(p0384_1, 'D', -1, 1) / 100 as clearing_amount
                     , null as file_name
                  from mup_fpd mf
                 where substr(p0300, 1, 3) || '/' || substr(p0300, 4, 6) || '/' || substr(p0300, 10, 11) || '/' || substr(p0300, 21, 3)
                    in ('102/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/000'
                      , '101/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/011')
                   and de050 = 643
                   and ((l_inst_id in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id in (2005, 2006, 2011, 2012, 2013, 2014)) 
                     or (l_inst_id not in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id = l_inst_id)
                       )
                 union all -- PART 3
                select distinct
                       3 as part
                     , clearing_currency
                     , 'Acquirer processed' as activity
                     , file_id
                     , message_type
                     , function_code
                     , transaction_type
                     , null as ifd
                     , null as product_id
                     , count(*) over (partition by payment_network
                                                 , clearing_currency
                                                 , file_date
                                                 , file_id
                                                 , message_type
                                                 , function_code
                                                 , transaction_type
                                                 , m_file_name) as quantity
                     , null as settlement_amount
                     , null as settlement_fee
                     , null as settlement_total
                     , null as clearing_currency
                     , sum(clearing_amount) over (partition by payment_network
                                                             , clearing_currency
                                                             , file_date
                                                             , file_id
                                                             , message_type
                                                             , function_code
                                                             , transaction_type
                                                             , m_file_name) as clearing_amount
                     , m_file_name as file_name
                  from (select payment_network
                             , mir_file_id as file_id
                             , mir_file_date as file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount as clearing_amount
                             , transaction_currency as clearing_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution
                             , listagg (m_file_name, ',') within group (order by transaction_id) as m_file_name
                          from (select decode(mff.network_id, '7017', 'MIR', mff.network_id) as payment_network
                                     , substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mir_file_id
                                     , to_char(mff.proc_date,'yyyymmdd') as mir_file_date
                                     , mf.id as transaction_id
                                     , mc.card_number as card_number
                                     , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                     , '1442', mf.mti || ' - Chargeback'
                                                     , '1740', mf.mti || ' - Fee collection'
                                                     , '1644', mf.mti || ' - Retrieval request'
                                                     , '1244', mf.mti || ' - Financial notification'
                                                     ,         mf.mti || ' - Other') as message_type
                                     , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                       , '205', mf.de024 || ' - Second presentment (Full)'
                                                       , '282', mf.de024 || ' - Second presentment (Partial)'
                                                       , '299', mf.de024 || ' - Financial notification'
                                                       , '450', mf.de024 || ' - First Chargeback (Full)'
                                                       , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                       , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                       , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                       , '603', mf.de024 || ' - Retrieval request'
                                                       , '680', mf.de024 || ' - File Currency Summary'
                                                       , '685', mf.de024 || ' - Financial Position Detail'
                                                       , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                       , '780', mf.de024 || ' - Fee Collection Return'
                                                       , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                       , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                       , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                       , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                       , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                       ,        mf.de024 || ' - Other') as function_code
                                     , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                        , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                        , '12', mf.de003_1 || ' - Cash Disbursement'
                                                        , '17', mf.de003_1 || ' - Convenience Check'
                                                        , '18', mf.de003_1 || ' - Unique Transaction'
                                                        , '19', mf.de003_1 || ' - Fee Collection'
                                                        , '20', mf.de003_1 || ' - Refund'
                                                        , '26', mf.de003_1 || ' - Cash-to-Card Payments'
                                                        , '28', mf.de003_1 || ' - Card-to-Card Payments'
                                                        , '29', mf.de003_1 || ' - Fee Collection'
                                                        , '30', mf.de003_1 || ' - Balance Inquiry'
                                                        , '92', mf.de003_1 || ' - PIN change'
                                                        ,       mf.de003_1 || ' - Other') as transaction_type
                                     , decode(oo.is_reversal, 0, 'No'
                                                            , 1, 'Yes'
                                                            , 'Unknown') as reversal_indicator
                                     , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                     , decode(mf.de003_1, '00', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '01', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '12', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '17', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '18', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '19', decode(mf.is_reversal, 0, mf.de004 / 100, 0 - mf.de004 / 100)
                                                        , '20', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        , '28', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        , '29', decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)
                                                        ,       decode(mf.is_reversal, 0, 0 - mf.de004 / 100, mf.de004 / 100)) as transaction_amount
                                     , de049 as transaction_currency
                                     , mf.de005/100 as settlement_amount
                                     , de050 as settlement_currency
                                     , de038 as approval_code
                                     , de037 as rrn
                                     , de031 as arn
                                     , de041 as terminal_id
                                     , de042 as merchant_id
                                     , de026 as mcc
                                     , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                       rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                     , decode(mf.de025, null,   mf.de025
                                                      , '1400', mf.de025 || ' - Not previously authorized'
                                                      , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                      , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                      , '2011', mf.de025 || ' - Credit previously issued'
                                                      , '2700', mf.de025 || ' - Chargeback remedied'
                                                      , '4808', mf.de025 || ' - Required authorization not obtained'
                                                      , '4809', mf.de025 || ' - Transaction not reconciled'
                                                      , '4831', mf.de025 || ' - Transaction amount differs'
                                                      , '4834', mf.de025 || ' - Duplicate processing'
                                                      , '4842', mf.de025 || ' - Late presentment'
                                                      , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                      , '4859', mf.de025 || ' - Service not rendered'
                                                      , '4860', mf.de025 || ' - Credit not processed'
                                                      , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                      , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                      , '6341', mf.de025 || ' - Fraud investigation'
                                                      , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                      , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                      , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                      , '7800', mf.de025 || ' - MasterCard member settlement'
                                                      ,         mf.de025 || ' - Other') as reason_code
                                     , de093 as destination_institution
                                     , mf.de094 as originator_institution
                                     , decode(mf.inst_id, '9945', 'Customs payment', pcf.file_name) as m_file_name
                                  from mup_fin mf
                                  join mup_card mc          on mf.id          = mc.id
                                  join mup_file mff         on mff.id         = mf.file_id
                                                           and mff.network_id = 7017
                                  join opr_operation oo     on oo.id          = mf.id
                             left join cst_oper_file cof    on cof.oper_id    = oo.id
                             left join prc_session_file pcf on pcf.id         = cof.session_file_id
                                 where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 3)
                                    in ('102/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/000')
                                   and ((l_inst_id in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id in (2005, 2006, 2011, 2012, 2013, 2014)) 
                                     or(l_inst_id not in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id = l_inst_id))
                                   and mf.p0165 != 'R')
                              group by payment_network
                                     , mir_file_id
                                     , mir_file_date
                                     , message_type
                                     , function_code
                                     , transaction_type
                                     , reversal_indicator
                                     , transaction_id
                                     , card_number
                                     , transaction_date
                                     , transaction_amount
                                     , transaction_currency
                                     , settlement_amount
                                     , settlement_currency
                                     , approval_code
                                     , rrn
                                     , arn
                                     , terminal_id
                                     , merchant_id
                                     , mcc
                                     , merchant
                                     , reason_code
                                     , destination_institution
                                     , originator_institution)
                 union all 
                 -- PART 4
                select distinct
                       4 as part
                     , settlement_currency as clearing_currency
                     , 'Issuer processed' as activity
                     , file_id
                     , message_type
                     , function_code
                     , transaction_type
                     , null as ifd
                     , null as product_id
                     , count(*) over (partition by settlement_currency
                                                 , file_date
                                                 , file_id
                                                 , message_type
                                                 , function_code
                                                 , transaction_type
                                                 , c_file) as quantity
                     , null as settlement_amount
                     , null as settlement_fee
                     , null as settlement_total
                     , null as clearing_currency
                     , sum(settlement_amount) over (partition by settlement_currency
                                                               , file_date
                                                               , file_id
                                                               , message_type
                                                               , function_code
                                                               , transaction_type
                                                               , c_file) as clearing_amount
                     , c_file as file_name
                  from (select mir_file_id as file_id
                             , mir_file_date as file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount
                             , transaction_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution
                             , listagg (c_file_name, ',') 
                               within group (order by substr(c_file_name, instr(c_file_name, '.') + 1, 3) || 
                                                      substr(c_file_name
                                                           , instr(c_file_name, '__') + 3
                                                           , instr(c_file_name,'.') - instr(c_file_name,'__')-2
                                                             )
                                             ) as c_file
                          from (select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mir_file_id
                                     , to_char(mff.proc_date, 'yyyymmdd') as mir_file_date
                                     , mf.id as transaction_id
                                     , mc.card_number as card_number
                                     , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                     , '1442', mf.mti || ' - Chargeback'
                                                     , '1740', mf.mti || ' - Fee collection'
                                                     , '1644', mf.mti || ' - Retrieval request'
                                                     , '1244', mf.mti || ' - Financial notification'
                                                     ,         mf.mti || ' - Other') as message_type
                                     , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                       , '205', mf.de024 || ' - Second presentment (Full)'
                                                       , '282', mf.de024 || ' - Second presentment (Partial)'
                                                       , '299', mf.de024 || ' - Financial notification'
                                                       , '450', mf.de024 || ' - First Chargeback (Full)'
                                                       , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                       , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                       , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                       , '603', mf.de024 || ' - Retrieval request'
                                                       , '680', mf.de024 || ' - File Currency Summary'
                                                       , '685', mf.de024 || ' - Financial Position Detail'
                                                       , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                       , '780', mf.de024 || ' - Fee Collection Return'
                                                       , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                       , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                       , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                       , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                       , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                       ,        mf.de024 || ' - Other') as function_code
                                     , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                        , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                        , '12', mf.de003_1 || ' - Cash Disbursement'
                                                        , '17', mf.de003_1 || ' - Convenience Check'
                                                        , '18', mf.de003_1 || ' - Unique Transaction'
                                                        , '19', mf.de003_1 || ' - Fee Collection'
                                                        , '20', mf.de003_1 || ' - Refund'
                                                        , '26', mf.de003_1 || ' - Cash-to-Card Payments'
                                                        , '28', mf.de003_1 || ' - Card-to-Card Payments'
                                                        , '29', mf.de003_1 || ' - Fee Collection'
                                                        , '30', mf.de003_1 || ' - Balance Inquiry'
                                                        , '92', mf.de003_1 || ' - PIN change'
                                                        ,       mf.de003_1 || ' - Other') as transaction_type
                                     , decode(oo.is_reversal, 0, 'No'
                                                            , 1, 'Yes'
                                                            ,    'Unknown') as reversal_indicator
                                     , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                     , mf.de004 / 100 as transaction_amount
                                     , de049 as transaction_currency
                                     , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '26', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '28', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '29', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                     , de050 as settlement_currency
                                     , de038 as approval_code
                                     , de037 as rrn
                                     , de031 as arn
                                     , de041 as terminal_id
                                     , de042 as merchant_id
                                     , de026 as mcc
                                     , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                       rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                     , decode(mf.de025, null,   mf.de025
                                                      , '1400', mf.de025 || ' - Not previously authorized'
                                                      , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                      , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                      , '2011', mf.de025 || ' - Credit previously issued'
                                                      , '2700', mf.de025 || ' - Chargeback remedied'
                                                      , '4808', mf.de025 || ' - Required authorization not obtained'
                                                      , '4809', mf.de025 || ' - Transaction not reconciled'
                                                      , '4831', mf.de025 || ' - Transaction amount differs'
                                                      , '4834', mf.de025 || ' - Duplicate processing'
                                                      , '4842', mf.de025 || ' - Late presentment'
                                                      , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                      , '4859', mf.de025 || ' - Service not rendered'
                                                      , '4860', mf.de025 || ' - Credit not processed'
                                                      , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                      , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                      , '6341', mf.de025 || ' - Fraud investigation'
                                                      , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                      , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                      , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                      , '7800', mf.de025 || ' - MasterCard member settlement'
                                                      ,         mf.de025 || ' - Other') as reason_code
                                     , de093 as destination_institution
                                     , mf.de094 as originator_institution
                                     , pcf.file_name as c_file_name
                                  from mup_fin mf
                                  join mup_card mc          on mf.id       = mc.id
                                  join mup_file mff         on mff.id      = mf.file_id
                                  join opr_operation oo     on oo.id       = mf.id
                             left join cst_oper_file cof    on cof.oper_id = mf.id
                             left join prc_session_file pcf on pcf.id = cof.session_file_id
                                 where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 3)
                                    in ('101/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/011')
                                   and not mf.de003_1 = '28'
                                   and ((l_inst_id in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id in (2005, 2006, 2011, 2012, 2013, 2014)) 
                                      or(l_inst_id not in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id = l_inst_id))
                                 union
                                select substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 5) as mir_file_id
                                     , to_char(mff.proc_date,'yyyymmdd') as mir_file_date
                                     , mf.id as transaction_id
                                     , mc.card_number as card_number
                                     , decode (mf.mti, '1240', mf.mti || ' - Presentment'
                                                     , '1442', mf.mti || ' - Chargeback'
                                                     , '1740', mf.mti || ' - Fee collection'
                                                     , '1644', mf.mti || ' - Retrieval request'
                                                     , '1244', mf.mti || ' - Financial notification'
                                                     ,         mf.mti || ' - Other') as message_type
                                     , decode (mf.de024, '200', mf.de024 || ' - First Presentment'
                                                       , '205', mf.de024 || ' - Second presentment (Full)'
                                                       , '282', mf.de024 || ' - Second presentment (Partial)'
                                                       , '299', mf.de024 || ' - Financial notification'
                                                       , '450', mf.de024 || ' - First Chargeback (Full)'
                                                       , '451', mf.de024 || ' - Arbitration Chargeback (Full)'
                                                       , '453', mf.de024 || ' - First Chargeback (Partial)'
                                                       , '454', mf.de024 || ' - Arbitration Chargeback (Partial)'
                                                       , '603', mf.de024 || ' - Retrieval request'
                                                       , '680', mf.de024 || ' - File Currency Summary'
                                                       , '685', mf.de024 || ' - Financial Position Detail'
                                                       , '700', mf.de024 || ' - Fee Collection (Member-generated)'
                                                       , '780', mf.de024 || ' - Fee Collection Return'
                                                       , '781', mf.de024 || ' - Fee Collection Resubmission'
                                                       , '782', mf.de024 || ' - Fee Collection Arbitration Return'
                                                       , '783', mf.de024 || ' - Fee Collection (Clearing System-generated)'
                                                       , '790', mf.de024 || ' - Fee Collection (Funds Transfer)'
                                                       , '791', mf.de024 || ' - Fee Collection (Funds Transfer Backout)'
                                                       ,        mf.de024 || ' - Other') as function_code
                                     , decode(mf.de003_1, '00', mf.de003_1 || ' - Purchase'
                                                        , '01', mf.de003_1 || ' - ATM Cash Withdrawal'
                                                        , '12', mf.de003_1 || ' - Cash Disbursement'
                                                        , '17', mf.de003_1 || ' - Convenience Check'
                                                        , '18', mf.de003_1 || ' - Unique Transaction'
                                                        , '19', mf.de003_1 || ' - Fee Collection'
                                                        , '20', mf.de003_1 || ' - Refund'
                                                        , '26', mf.de003_1 || ' - Cash-to-Card Payments'
                                                        , '28', mf.de003_1 || ' - Card-to-Card Payments'
                                                        , '29', mf.de003_1 || ' - Fee Collection'
                                                        , '30', mf.de003_1 || ' - Balance Inquiry'
                                                        , '92', mf.de003_1 || ' - PIN change'
                                                        ,       mf.de003_1 || ' - Other') as transaction_type
                                     , decode(oo.is_reversal, 0, 'No'
                                                            , 1, 'Yes'
                                                            ,    'Unknown') as reversal_indicator
                                     , to_char(mf.de012, 'dd/mm/yyyy hh24:mi:ss') as transaction_date
                                     , mf.de004 / 100 as transaction_amount
                                     , de049 as transaction_currency
                                     , decode(mf.de003_1, '20', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '26', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '28', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        , '29', decode(mf.is_reversal, 0, mf.de005 / 100, 0 - mf.de005 / 100)
                                                        ,       decode(mf.is_reversal, 0, 0 - mf.de005 / 100, mf.de005 / 100)) as settlement_amount
                                     , de050 as settlement_currency
                                     , de038 as approval_code
                                     , de037 as rrn
                                     , de031 as arn
                                     , de041 as terminal_id
                                     , de042 as merchant_id
                                     , de026 as mcc
                                     , rtrim(de043_1) || ', ' || rtrim(de043_2) || ', ' || rtrim(de043_3) || ', ' || 
                                       rtrim(de043_4) || ', ' || rtrim(de043_6) as merchant
                                     , decode(mf.de025, '1400', mf.de025 || ' - Not previously authorized'
                                                      , '1401', mf.de025 || ' - Previously approved authorization - amount same'
                                                      , '1402', mf.de025 || ' - Previously approved authorization - amount differs'
                                                      , '2011', mf.de025 || ' - Credit previously issued'
                                                      , '2700', mf.de025 || ' - Chargeback remedied'
                                                      , '4808', mf.de025 || ' - Required authorization not obtained'
                                                      , '4809', mf.de025 || ' - Transaction not reconciled'
                                                      , '4831', mf.de025 || ' - Transaction amount differs'
                                                      , '4834', mf.de025 || ' - Duplicate processing'
                                                      , '4842', mf.de025 || ' - Late presentment'
                                                      , '4855', mf.de025 || ' - Non-receipt of merchandise'
                                                      , '4859', mf.de025 || ' - Service not rendered'
                                                      , '4860', mf.de025 || ' - Credit not processed'
                                                      , '6321', mf.de025 || ' - Cardholder does not recognize transaction'
                                                      , '6323', mf.de025 || ' - Cardholder needs information for personal records'
                                                      , '6341', mf.de025 || ' - Fraud investigation'
                                                      , '6342', mf.de025 || ' - Potential chargeback documentation is required'
                                                      , '7621', mf.de025 || ' - ATM balance inquiry fee'
                                                      , '7629', mf.de025 || ' - Non-financial ATM service fee (declined transaction)'
                                                      , '7800', mf.de025 || ' - MasterCard member settlement'
                                                      ,         mf.de025 || ' - Other') as reason_code
                                     , de093 as destination_institution
                                     , mf.de094 as originator_institution
                                     , pcf.file_name as c_file_name
                                  from mup_fin mf
                                  join mup_card mc          on mf.id       = mc.id
                                  join mup_file mff         on mff.id      = mf.file_id
                                  join opr_operation oo     on oo.id       = mf.id
                             left join cst_oper_file cof    on cof.oper_id = oo.match_id
                             left join prc_session_file pcf on pcf.id      = cof.session_file_id
                                 where substr(mff.p0105, 1, 3) || '/' || substr(mff.p0105, 4, 6) || '/' || 
                                       substr(mff.p0105, 10, 11) || '/' || substr(mff.p0105, 21, 3)
                                    in ('101/' || to_char(l_report_date, 'YYMMDD') || '/' || l_inst_ica || '/011')
                                   and mf.de003_1 = '28'
                                   and ((l_inst_id in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id in (2005, 2006, 2011, 2012, 2013, 2014)) 
                                     or(l_inst_id not in (2005, 2006, 2011, 2012, 2013, 2014) and mf.inst_id = l_inst_id)))
                      group by mir_file_id
                             , mir_file_date
                             , message_type
                             , function_code
                             , transaction_type
                             , reversal_indicator
                             , transaction_id
                             , card_number
                             , transaction_date
                             , transaction_amount
                             , transaction_currency
                             , settlement_amount
                             , settlement_currency
                             , approval_code
                             , rrn
                             , arn
                             , terminal_id
                             , merchant_id
                             , mcc
                             , merchant
                             , reason_code
                             , destination_institution
                             , originator_institution)
                         )
    select a.*
         , a.tot_clearing_amount_p1 - tot_clearing_amount as diff1
         , a.tot_settlement_amount_p2 - tot_clearing_amount as diff2
         , a.tot_clearing_amount - a.not_exported as exported
      from (select t.part
                 , t.settlement_currency
                 , t.activity
                 , t.file_id
                 , t.message_type
                 , t.function_code
                 , t.transaction_type
                 , t.ifd
                 , t.product_id
                 , t.quantity
                 , t.settlement_amount
                 , t.settlement_fee
                 , t.settlement_total
                 , t.clearing_currency
                 , t.clearing_amount
                 , t.file_name
                 , sum(t.quantity) over (partition by t.part) as tot_quantity
                 , sum(t.settlement_amount) over (partition by t.part) as tot_settlement_amount
                 , sum(t.settlement_fee) over (partition by t.part) as tot_settlement_fee
                 , sum(t.settlement_total) over (partition by t.part) as tot_settlement_total
                 , sum(t.clearing_amount) over (partition by t.part) as tot_clearing_amount
                 , sum(decode(t.part, 1, t.settlement_total, 2, t.settlement_total, 0)) over () as tot_settlement_total_p1_p2
                 , sum(case when t.part = 1 then t.clearing_amount else 0 end) over () as tot_clearing_amount_p1
                 , sum(case when t.part = 1 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p1
                 , sum(case when t.part = 2 then t.settlement_amount else 0 end) over () as tot_settlement_amount_p2
                 , sum(case when t.file_name is null then t.clearing_amount else 0 end) over (partition by t.part) as not_exported
              from t) a);

    -- fill with "operation" tag for empty report creation
    for i in (select 1 
                from dual 
               where existsnode(l_operations, '/operations/operation') = 0
    ) loop
      select xmlelement("operations", xmlagg(xmlelement("operation"))) 
        into l_operations 
        from dual;
    end loop;

    -- 4 output
    select xmlelement("report"
             , l_header
             , l_operations
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_sttl_report_pkg.mup_settl_rub');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end mup_settl_rub;

procedure check_entry_c_in_ctf (
    o_xml                   out clob
  , i_session_id_ctf_1   in     com_api_type_pkg.t_long_id
  , i_session_id_ctf_2   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_3   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_4   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_5   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_6   in     com_api_type_pkg.t_long_id default null
  , i_session_id_c       in     com_api_type_pkg.t_long_id
  , i_lang               in     com_api_type_pkg.t_dict_value default null
  , i_inst_id            in     com_api_type_pkg.t_inst_id
) is
    l_header                 xmltype;
    l_operations             xmltype;
    l_result                 xmltype;
    l_lang                   com_api_type_pkg.t_dict_value;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_file_name_ctf          com_api_type_pkg.t_name;
    l_file_name_c            com_api_type_pkg.t_name;

    function get_file_name(
        i_session_id       in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select listagg(f.file_name, ', ')
               within group (order by f.file_date) as file_name
          into l_result
          from prc_session_file f
         where f.session_id = i_session_id;

        return l_result;
    end;
begin
    -- Report "The report of daily stats"
    trc_log_pkg.debug(
        i_text         => 'START: cst_api_report_pkg.check_entry_c_in_ctf [#1] [#2] [#3] [#4]'
      , i_env_param1   => i_session_id_ctf_1
      , i_env_param2   => i_session_id_c
      , i_env_param3   => i_lang
      , i_env_param4   => i_inst_id
    );
    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);

    l_file_name_ctf := get_file_name(i_session_id_ctf_1);

    if i_session_id_ctf_2 is not null then
        l_file_name_ctf := l_file_name_ctf || ', ' || get_file_name(i_session_id_ctf_2);
    end if;
    if i_session_id_ctf_3 is not null then
        l_file_name_ctf := l_file_name_ctf || ', ' || get_file_name(i_session_id_ctf_3);
    end if;
    if i_session_id_ctf_4 is not null then
        l_file_name_ctf := l_file_name_ctf || ', ' || get_file_name(i_session_id_ctf_4);
    end if;
    if i_session_id_ctf_5 is not null then
        l_file_name_ctf := l_file_name_ctf || ', ' || get_file_name(i_session_id_ctf_5);
    end if;
    if i_session_id_ctf_6 is not null then
        l_file_name_ctf := l_file_name_ctf || ', ' || get_file_name(i_session_id_ctf_6);
    end if;

    select f.file_name
      into l_file_name_c
      from prc_session_file f
     where f.id = i_session_id_c;

    -- header
    select xmlconcat(
                xmlelement("inst_id", l_inst_id)
                , xmlelement("inst", com_api_i18n_pkg.get_text(
                                         i_table_name   => 'OST_INSTITUTION'
                                       , i_column_name  => 'NAME'
                                       , i_object_id    => l_inst_id
                                       , i_lang         => l_lang)
                            )
                , xmlelement("file_name_ctf", l_file_name_ctf)
                , xmlelement("file_name_c", l_file_name_c)
           )
      into l_header
      from dual;

    -- data
    select
            xmlelement("operations"
                , xmlagg(
                    xmlelement("operation"
                        , xmlelement("oper_id", oper_id)
                        , xmlelement("is_reversal", is_reversal)
                        , xmlelement("oper_type_name", oper_type_name)
                        , xmlelement("oper_date", oper_date)
                        , xmlelement("oper_currency_name", oper_currency_name)
                        , xmlelement("oper_amount", oper_amount)
                        , xmlelement("sttl_currency_name", sttl_currency_name)
                        , xmlelement("sttl_amount", sttl_amount)
                        , xmlelement("auth_code", auth_code)
                        , xmlelement("arn", arn)
                        , xmlelement("terminal_number", terminal_number)
                        , xmlelement("merchant_name", merchant_name)
                        , xmlelement("group_total_sum", group_total_sum)
                        , xmlelement("other_file_name", other_file_name)
                    )
                    order by oper_type_name, sttl_currency_name
                )
           )
        into l_operations
        from (with t as (select substr(ct.raw_data, 27, 23) as arn
                              , substr(ct.raw_data, 152, 6) auth_code
                              , substr(ct.raw_data, 0, 2) as trans_code
                              , ct.raw_data rd
                           from prc_file_raw_data ct
                           join prc_session_file f on f.id = ct.session_file_id
                                                  and f.session_id in (i_session_id_ctf_1
                                                                     , i_session_id_ctf_2
                                                                     , i_session_id_ctf_3
                                                                     , i_session_id_ctf_4
                                                                     , i_session_id_ctf_5)
                          where (ct.raw_data like '0500%'
                                 or ct.raw_data like '0510%'
                                 or ct.raw_data like '0600%'
                                 or ct.raw_data like '0620%'
                                 or ct.raw_data like '0700%'
                                 or ct.raw_data like '2500%'
                                 or ct.raw_data like '2510%'
                                 or ct.raw_data like '2600%'
                                 or ct.raw_data like '2700%')
                            and not exists (select 1 from prc_file_raw_data c
                                             where c.session_file_id = i_session_id_c
                                               and substr(c.raw_data, 422, 6) = substr(ct.raw_data, 152, 6)
                                               and substr(c.raw_data, 59, 1) = decode(substr(ct.raw_data, 0, 2), 25, 'R', 26, 'R', 27, 'R', ' ')))
              select oo.oper_id
                   , oo.is_reversal
                   , oo.oper_type_name
                   , oo.oper_date
                   , oo.oper_currency_name
                   , oo.oper_amount
                   , oo.sttl_currency_name
                   , oo.sttl_amount
                   , oo.auth_code
                   , oo.arn
                   , oo.terminal_number
                   , oo.merchant_name
                   , oo.group_total_sum
                   , oo.other_file_name
                from (select o.id as oper_id
                           , o.is_reversal
                           , o.oper_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => o.oper_type, i_lang => l_lang) as oper_type_name
                           , to_char(o.oper_date, 'dd.mm.yyyy') oper_date
                           , co.name oper_currency_name
                           , round(o.oper_amount / nvl(power(10, co.exponent), 1), 2) as oper_amount
                           , ct.name sttl_currency_name
                           , round(o.sttl_amount / nvl(power(10, co.exponent), 1), 2) as sttl_amount
                           , t.auth_code
                           , v.arn
                           , o.terminal_number
                           , o.merchant_number || ' - ' ||o.merchant_name as merchant_name
                           , sum(nvl(o.oper_amount / nvl(power(10, co.exponent), 1), 0))
                                 over (partition by o.sttl_amount, o.oper_type, o.is_reversal) as group_total_sum
                           , (select max(f.file_name)
                                from prc_session_file f
                                   , prc_file_raw_data c
                               where f.id between com_api_id_pkg.get_from_id(to_date(substr(i_session_id_c, 0,6), 'YY.MM.DD')-3)
                                              and com_api_id_pkg.get_from_id(to_date(substr(i_session_id_c, 0,6), 'YY.MM.DD')+3)
                                 and f.file_name like 'C' || to_char(i_inst_id) || '__%'
                                 and c.session_file_id = f.id
                                 and c.session_file_id != i_session_id_c
                                 and substr(c.raw_data, 422, 6) = t.auth_code) other_file_name
                            , o.acq_inst_bin
                        from t
                        left join vis_fin_message v on v.arn = t.arn
                                                   and v.trans_code = t.trans_code
                        left join opr_operation_vw o on o.id = v.id
                        left join com_ui_currency_vw co on co.code = o.oper_currency
                                                       and co.lang = l_lang
                        left join com_ui_currency_vw ct on ct.code = o.sttl_currency
                                                       and ct.lang = l_lang) oo
               where nvl(oo.acq_inst_bin, '1') != '001300'
             );

    -- Fill in the operation tag to form empty reports
    for i in (
        select 1
          from dual
         where existsnode(l_operations, '/operations/operation') = 0
    ) loop
        select xmlelement("operations", xmlagg(xmlelement("operation")))
          into l_operations
          from dual;
    end loop;

    -- output
    select xmlelement("report"
                     , l_header
                     , l_operations
                   )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'END cst_api_report_pkg.check_entry_c_in_ctf');
exception
    when no_data_found then
        trc_log_pkg.debug(i_text => sqlerrm);
end check_entry_c_in_ctf;

end cst_api_report_pkg;
/
