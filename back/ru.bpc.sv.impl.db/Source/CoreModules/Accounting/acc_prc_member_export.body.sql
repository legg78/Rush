create or replace package body acc_prc_member_export is

-- internal engine for ver 1.0
procedure unload_member_engine_1_0(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_date_type           in     com_api_type_pkg.t_dict_value
  , i_full_export         in     com_api_type_pkg.t_boolean
  , i_count               in     com_api_type_pkg.t_medium_id
  , i_start_date          in     date
  , i_end_date            in     date
  , i_array_trans_type_id in     com_api_type_pkg.t_medium_id
  , i_array_settl_type_id in     com_api_type_pkg.t_medium_id
  , i_masking_card        in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || '.export_cards(export_card_engine_1_0): ';
    C_CRLF        constant  com_api_type_pkg.t_name := chr(13)||chr(10);

    l_sess_file_id         com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_estimated_count      pls_integer := 0;
    l_total_count          pls_integer := 0;
    l_stage                com_api_type_pkg.t_name;
    l_event_tab            num_tab_tpt := num_tab_tpt();   -- list of eo in case of full = false
    l_entry_tab            num_tab_tpt := num_tab_tpt();
    l_container_id         com_api_type_pkg.t_long_id;
    cur_entries            sys_refcursor;
    l_params               com_api_type_pkg.t_param_tab;

    -- transparent procedure to gather entries
    procedure oper_entries(
        o_cursor               out sys_refcursor
    ) is
    begin
        trc_log_pkg.debug('i_full_export=' || i_full_export || ' i_inst_id=' || i_inst_id);
        if i_full_export = com_api_const_pkg.TRUE then
            open o_cursor for
            select distinct e.id as entry_id
                 , null          as eo_id
              from acc_entry e
                 , acc_macros m
                 , opr_operation op
                 , acc_account aa               -- to make inst_id filter, actually we don't need accounts here
             where e.macros_id   = m.id
               and e.status     != acc_api_const_pkg.ENTRY_STATUS_CANCELED
               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and op.id         = m.object_id
               and aa.id         = e.account_id
               and i_inst_id in (aa.inst_id, ost_api_const_pkg.DEFAULT_INST)
               and e.split_hash  in (select split_hash from com_api_split_map_vw)
               and ((i_start_date is null or i_end_date is null)
                    or
                    decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date, null)
                          between i_start_date and i_end_date
                   )
               and (i_array_trans_type_id is null
                     or e.transaction_type in (select element_value
                                                 from com_array_element
                                                where array_id = i_array_trans_type_id
                                               )
                   )
               and (i_array_settl_type_id is null
                     or op.sttl_type in (select element_value
                                           from com_array_element
                                          where array_id = i_array_settl_type_id
                                        )
                   );
        else
            open o_cursor for
            select distinct e.id as entry_id
                 ,          o.id as eo_id
              from evt_event_object o
                 , acc_entry e
                 , acc_macros m
                 , opr_operation op
             where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ACC_PRC_MEMBER_EXPORT.UNLOAD_MEMBER_TURNOVER'
               and (o.container_id is null or l_container_id is null or o.container_id = l_container_id)
               and i_inst_id in (o.inst_id, ost_api_const_pkg.DEFAULT_INST)
               and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
               and o.object_id     = e.id
               and e.macros_id   = m.id
               and e.status     != acc_api_const_pkg.ENTRY_STATUS_CANCELED
               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and op.id         = m.object_id
               and i_inst_id in (o.inst_id, ost_api_const_pkg.DEFAULT_INST)
               and e.split_hash  in (select split_hash from com_api_split_map_vw)
               and ((i_start_date is null or i_end_date is null)
                    or
                    decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date, null)
                          between i_start_date and i_end_date
                   )
               and (i_array_trans_type_id is null
                     or e.transaction_type in (select element_value
                                                 from com_array_element
                                                where array_id = i_array_trans_type_id
                                               )
                   )
               and (i_array_settl_type_id is null
                     or op.sttl_type in (select element_value
                                           from com_array_element
                                          where array_id = i_array_settl_type_id
                                        )
                   );
        end if;
    end;

    -- transparent procedure to generate xml into l_file
    procedure generate_xml
    is
        cursor main_xml_cur is
        with entry_tab as (
            select column_value as id from table(l_entry_tab)
        )
        , rawdata as (   -- full sql query for l_entry_tab is here
            select -- list of data for xml
                   o.id as oper_id
                 , o.oper_type
                 , o.msg_type
                 , to_char(o.oper_date, com_api_const_pkg.XML_DATE_FORMAT) as oper_date
                 , to_char(o.host_date, com_api_const_pkg.XML_DATE_FORMAT) as host_date
                 , o.oper_amount
                 , o.oper_currency
                 , o.originator_refnum
                 , o.network_refnum
                 , o.is_reversal
                 , o.merchant_number
                 , o.mcc
                 , o.merchant_name
                 , o.merchant_street
                 , o.merchant_city
                 , o.merchant_region
                 , o.merchant_country
                 , o.merchant_postcode
                 , o.terminal_type
                 , o.terminal_number
                 , case when i_masking_card = com_api_const_pkg.TRUE
                       then
                           iss_api_card_pkg.get_card_mask(i_card_number => oc.card_number)
                       else iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number)
                   end as card_number
                 , op.card_seq_number
                 , to_char(op.card_expir_date, com_api_const_pkg.XML_DATE_FORMAT) as card_expir_date
                 , op.auth_code
                 , pi.inst_id as iss_inst_id
                 , pa.inst_id as acq_inst_id
                 , to_char(o.sttl_date, com_api_const_pkg.XML_DATE_FORMAT) as sttl_date
                 , o.oper_reason
              from opr_operation o
              left join opr_participant pi on o.id = pi.oper_id and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              left join opr_participant pa on o.id = pa.oper_id and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
              left join opr_participant op on o.id = op.oper_id
              left join opr_card oc on oc.oper_id = op.oper_id and oc.participant_type = op.participant_type
             where (o.id, op.account_id) in (    -- operation filter by entry list
                    select m1.object_id, e1.account_id
                      from acc_macros m1
                      join acc_entry e1 on e1.macros_id = m1.id
                                    and e1.id in (select id from entry_tab)
                     where entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                    )
                -- inject operation filter
               and (i_array_settl_type_id is null
                     or o.sttl_type in (select element_value
                                           from com_array_element
                                          where array_id = i_array_settl_type_id
                                        )
                    )
        )
        select com_api_const_pkg.XML_HEADER || C_CRLF ||
               xmlelement(
                   "settlement"
                 , xmlattributes('http://sv.bpc.in/SVXP/Settlement' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_sess_file_id))
                 , xmlelement("file_type", acc_api_const_pkg.FILE_TYPE_SETTLEMENT)
                 , xmlelement("inst_id"  , to_char(i_inst_id))
                 ,     xmlagg(
                            xmlelement(
                                "operation"
                              , xmlelement("oper_type"              , oper_type)
                              , xmlelement("msg_type"               , msg_type)
                              , xmlelement("oper_date"              , oper_date)
                              , xmlelement("host_date"              , host_date)
                              , xmlelement("oper_amount"
                                  , xmlelement("amount_value"       , oper_amount)
                                  , xmlelement("currency"           , oper_currency)
                                )
                              , xmlelement("originator_refnum"      , originator_refnum)
                              , xmlelement("network_refnum"         , network_refnum)
                              , xmlelement("is_reversal"            , is_reversal)
                              , xmlelement("merchant_number"        , merchant_number)
                              , xmlelement("mcc"                    , mcc)
                              , xmlelement("merchant_name"          , merchant_name)
                              , xmlelement("merchant_street"        , merchant_street)
                              , xmlelement("merchant_city"          , merchant_city)
                              , xmlelement("merchant_region"        , merchant_region)
                              , xmlelement("merchant_country"       , merchant_country)
                              , xmlelement("merchant_postcode"      , merchant_postcode)
                              , xmlelement("terminal_type"          , terminal_type)
                              , xmlelement("terminal_number"        , terminal_number)
                              , xmlelement("card_number"            , card_number)
                              , xmlelement("card_seq_number"        , card_seq_number)
                              , xmlelement("card_expir_date"        , card_expir_date)
                              , xmlelement("auth_code"              , auth_code)
                              , xmlelement("iss_inst_id"            , iss_inst_id)
                              , xmlelement("acq_inst_id"            , acq_inst_id)
                              , xmlelement("oper_reason"            , oper_reason)
                              , xmlelement("sttl_date"              , sttl_date)
                              , (select xmlagg(
                                     xmlelement(
                                         "transaction"
                                       , xmlelement("transaction_id"          , ttt.transaction_id)
                                       , xmlelement("transaction_type"        , ttt.transaction_type)
                                       , xmlelement("posting_date"            , ttt.posting_date)
                                       , xmlelement("conversion_rate"         , ttt.conversion_rate)
                                       , xmlelement("amount_purpose"          , ttt.amount_purpose)
                                       , (select xmlagg(
                                             xmlelement(
                                                 "debit_entry"
                                                , xmlelement("entry_id"               , e1.id)
                                                , xmlelement(
                                                      "account"
                                                    , xmlelement("account_number"          , a.account_number)
                                                    , xmlelement("account_currency"        , a.currency)
                                                  )
                                                , xmlelement(
                                                      "amount"
                                                    , xmlelement("amount_value"            , e1.amount)
                                                    , xmlelement("amount_currency"         , e1.currency)
                                                  )
                                             )
                                          ) from acc_entry e1
                                            left join acc_account a on e1.account_id = a.id
                                           where e1.transaction_id = ttt.transaction_id
                                             and e1.balance_impact = -1
                                             and e1.id in (select id from entry_tab)
                                         )
                                       , (select xmlagg(
                                             xmlelement(
                                                 "credit_entry"
                                                , xmlelement("entry_id"               , e1.id)
                                                , xmlelement(
                                                      "account"
                                                    , xmlelement("account_number"          , a.account_number)
                                                    , xmlelement("account_currency"        , a.currency)
                                                  )
                                                , xmlelement(
                                                      "amount"
                                                    , xmlelement("amount_value"            , e1.amount)
                                                    , xmlelement("amount_currency"         , e1.currency)
                                                  )
                                             )
                                          ) from acc_entry e1
                                            left join acc_account a on e1.account_id = a.id
                                           where e1.transaction_id = ttt.transaction_id
                                             and e1.balance_impact = 1
                                             and e1.id in (select id from entry_tab)
                                         )
                                     )
                                  ) from
                                        (select
                                            e.transaction_id,
                                            e.transaction_type,
                                            e.posting_date,
                                            m.conversion_rate,
                                            m.amount_purpose,
                                            m.object_id  -- LINK
                                         from
                                        acc_entry e
                                        join acc_macros m on e.macros_id = m.id
                                       where m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
                                         -- inject entry filter here
                                         and (i_array_trans_type_id is null
                                               or e.transaction_type in (select element_value
                                                                           from com_array_element
                                                                          where array_id = i_array_trans_type_id
                                                                         )
                                             )
                                         and e.id in (select id from entry_tab)
                                       group by e.transaction_id
                                              , e.transaction_type
                                              , e.posting_date
                                              , m.conversion_rate
                                              , m.amount_purpose
                                              , m.object_id
                                       ) ttt where ttt.object_id = rawdata.oper_id
                                ) t
                            )
                       )
               ).getclobval() as card_data
          from rawdata;

    begin
        open main_xml_cur;
        fetch main_xml_cur
         into l_file;
        close main_xml_cur;
    end;

begin
    l_stage := 'Init';
    l_container_id      := prc_api_session_pkg.get_container_id;
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );
    prc_api_stat_pkg.log_start;

    l_stage := 'Get entry list';

    oper_entries(
        o_cursor => cur_entries
    );

    l_stage := 'Process ';

    rul_api_param_pkg.set_param (
        i_name          => 'INST_ID'
      , i_value         => i_inst_id
      , io_params       => l_params
    );

    loop
        begin
            savepoint sp_prc_member_export;
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'try to query ' || i_count);

            l_stage := 'Fetch';
            fetch cur_entries
             bulk collect into
                  l_entry_tab
                , l_event_tab
            limit i_count;

            l_entry_tab := set(l_entry_tab);
            l_estimated_count := l_entry_tab.count;
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Records were fetched from cursor cur_entries [' || l_estimated_count || ']'
            );

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );

            if l_estimated_count > 0 then
                l_stage := 'Open file for ' || l_estimated_count;
                prc_api_file_pkg.open_file(
                    o_sess_file_id => l_sess_file_id
                  , i_file_type    => acc_api_const_pkg.FILE_TYPE_SETTLEMENT
                  , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
                  , io_params      => l_params
                );

                l_stage := 'Generate';
                -- from l_entry_tab into l_file
                generate_xml;

                l_stage := 'Put';
                prc_api_file_pkg.put_file(
                    i_sess_file_id  => l_sess_file_id
                  , i_clob_content  => l_file
                );
                if i_full_export = com_api_const_pkg.FALSE then
                    l_stage := 'Set event object';
                    trc_log_pkg.debug(
                        i_text       => LOG_PREFIX || ' estimated [#1] events'
                      , i_env_param1 => l_event_tab.count
                    );
                    evt_api_event_pkg.process_event_object(
                        i_event_object_id_tab    => l_event_tab
                    );
                end if;

                l_total_count := l_estimated_count + l_total_count;
                l_stage := 'Close file';
                prc_api_file_pkg.close_file(
                    i_sess_file_id  => l_sess_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                  , i_record_count  => l_estimated_count
                );

                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'file saved, cnt=' || l_estimated_count || ', length=' || length(l_file)
                );
                prc_api_stat_pkg.log_current (
                    i_current_count   => l_estimated_count
                  , i_excepted_count  => 0
                );
            else
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'zero estimation, no file will be created'
                );
            end if;

            exit when cur_entries%notfound;

        exception
            when others then
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || sqlerrm
                );
                rollback to sp_prc_member_export;
                raise;
        end;
    end loop;

    l_stage := 'End (' || l_total_count || ')';

    close cur_entries;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' end (' || l_total_count || ')'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || sqlerrm || ' on stage ' || l_stage
        );
        if cur_entries%isopen then
            close cur_entries;
        end if;
        raise;

end;

procedure unload_member_turnover(
    i_mbr_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_date_type           in     com_api_type_pkg.t_dict_value
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_array_trans_type_id in     com_api_type_pkg.t_medium_id     default null
  , i_array_settl_type_id in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.unload_member_turnover: ';
    DEFAULT_BULK_LIMIT constant com_api_type_pkg.t_count      := 2000;

    l_full_export               com_api_type_pkg.t_boolean    := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_masking_card              com_api_type_pkg.t_boolean    := nvl(i_masking_card, com_api_const_pkg.TRUE);
    l_count                     com_api_type_pkg.t_medium_id  := nvl(i_count, DEFAULT_BULK_LIMIT);

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START'
    );

    if i_mbr_version between '1.0' and '1.0' then
        unload_member_engine_1_0(
            i_inst_id          => i_inst_id
          , i_date_type        => i_date_type
          , i_full_export      => l_full_export
          , i_count            => l_count
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_array_trans_type_id => i_array_trans_type_id
          , i_array_settl_type_id => i_array_settl_type_id
          , i_masking_card     => l_masking_card
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_mbr_version
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || sqlerrm
        );

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        else
            raise;
        end if;
end;

end;
/
