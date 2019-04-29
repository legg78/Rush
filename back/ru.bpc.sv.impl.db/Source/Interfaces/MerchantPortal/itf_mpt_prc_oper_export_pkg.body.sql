create or replace package body itf_mpt_prc_oper_export_pkg is

g_inst_flag_tab                      com_api_type_pkg.t_boolean_tab;

function check_inst_id(i_inst_id  in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_boolean
is
begin
    return case
               when g_inst_flag_tab.exists(i_inst_id)
                and g_inst_flag_tab(i_inst_id) = com_api_const_pkg.TRUE
               then com_api_const_pkg.TRUE
               else com_api_const_pkg.FALSE
            end;
end check_inst_id;

procedure process_1_2(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_date_type           in     com_api_type_pkg.t_dict_value    default com_api_const_pkg.DATE_PURPOSE_PROCESSING
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_OPER_EXPORT_PKG.PROCESS';

    -- Defult bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := DEFAULT_BULK_LIMIT;
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_long_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_sysdate               date := get_sysdate;
    l_start_date            date;
    l_end_date              date;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with acc_entries_tab as (
            select column_value as id from table(cast(l_object_id_tab as num_tab_tpt))
        )
        select
            xmlelement(
                "operations"
              , xmlattributes('http://sv.bpc.in/SVXP/Operations' as "xmlns")
              , xmlelement("file_id", to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_id",   g.oper_id)
                      , xmlelement("inst_id",   g.acq_inst_id)
                      , xmlelement("agent_id",  g.agent_id)
                      , xmlelement("oper_type", g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
                      , xmlelement("status",    g.status)
                      , xmlforest(g.resp_code as "resp_code")
                      , xmlelement("oper_date", to_char(g.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("host_date", to_char(g.host_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("oper_amount"
                          , xmlelement("amount_value", g.oper_amount)
                          , xmlelement("currency", g.oper_currency)
                        )
                      , (select xmlagg(
                                    xmlelement("sttl_amount"
                                      , xmlelement("amount_value", g.sttl_amount)
                                      , xmlelement("currency", g.sttl_currency)
                                    )
                                )
                           from dual
                          where g.sttl_amount is not null
                            and g.sttl_currency is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_request_amount"
                                      , xmlelement("amount_value", g.oper_request_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_request_amount is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_surcharge_amount"
                                      , xmlelement("amount_value", g.oper_surcharge_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_surcharge_amount is not null
                        )
                      , xmlforest(
                            g.originator_refnum  as "originator_refnum"
                          , g.network_refnum     as "network_refnum"
                          , g.is_reversal        as "is_reversal"
                          , g.merchant_number    as "merchant_number"
                          , g.mcc                as "mcc"
                          , g.merchant_name      as "merchant_name"
                          , g.merchant_street    as "merchant_street"
                          , g.merchant_city      as "merchant_city"
                          , g.merchant_region    as "merchant_region"
                          , g.merchant_country   as "merchant_country"
                          , g.merchant_postcode  as "merchant_postcode"
                          , g.terminal_type      as "terminal_type"
                          , g.terminal_number    as "terminal_number"
                          , g.merchant_id        as "merchant_id"
                          , g.terminal_id        as "terminal_id"
                          , g.card_number        as "card_number"
                          , g.card_network_id    as "card_network_id"
                          , g.card_type_id       as "card_type_id"
                        )
                      , (select xmlagg(
                                    xmlelement(
                                        "entry"
                                      , xmlelement("entry_id",         xa.id)
                                      , xmlelement("transaction_type", xa.transaction_type)
                                      , xmlelement("posting_date",     to_char(xa.posting_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("sttl_date",        to_char(xa.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("balance_impact",   xa.balance_impact)
                                      , xmlforest(xm.amount_purpose as "amount_purpose")
                                      , xmlelement(
                                            "account"
                                          , xmlattributes(zz.id as "account_id")
                                          , xmlelement("account_number", zz.account_number)
                                          , xmlelement("currency", zz.currency)
                                        )
                                      , xmlelement(
                                            "amount"
                                          , xmlelement("amount_value", xa.amount)
                                          , xmlelement("currency", xa.currency)
                                        )
                                      , xmlforest(case check_inst_id(i_inst_id  => zz.inst_id)
                                                      when com_api_const_pkg.TRUE then xa.is_settled
                                                      else null
                                                   end as "is_settled")
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                              , acc_account zz
                              , acc_entries_tab e
                          where xa.macros_id   = xm.id
                            and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and xm.object_id   = g.oper_id
                            and xa.account_id  = zz.id
                            and xa.id          = e.id
                        ) entry
                    )
                )
            ).getclobval()
          , count(*)
        from (select
                oo.id as oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.status
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
              , oo.oper_request_amount
              , oo.oper_surcharge_amount
              , oo.originator_refnum
              , oo.network_refnum
              , oo.status_reason as response_code
              , oo.merchant_number
              , oo.mcc
              , oo.merchant_name
              , oo.merchant_street
              , oo.merchant_city
              , oo.merchant_country
              , oo.merchant_postcode
              , oo.merchant_region
              , oo.terminal_type
              , case when length(oo.terminal_number) >= 8 
                    then substr(oo.terminal_number, -8)
                    else oo.terminal_number
                end as terminal_number
              , oo.clearing_sequence_num
              , oo.clearing_sequence_count
              , oo.is_reversal
              , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                    then
                        coalesce(
                            b.card_mask
                          , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                        )
                    when l_is_token_enabled = com_api_const_pkg.FALSE then
                        c.card_number
                    else
                        iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                end as card_number
              , b.card_id
              , b.card_instance_id
              , b.card_seq_number
              , b.card_expir_date
              , b.card_country
              , b.card_network_id
              , b.inst_id    as iss_inst_id
              , b.network_id as iss_network_id
              , b.auth_code
              , a.inst_id    acq_inst_id
              , a.network_id acq_network_id
              , a.auth_code  acq_auth_code
              , a.account_number
              , a.account_amount
              , a.account_currency
              , a.terminal_id
              , a.merchant_id
              , t.resp_code
              , ic.card_type_id
              , ct.agent_id
            from (
                    select distinct o.id as oper_id
                      from opr_operation o
                         , acc_entry f
                         , acc_macros m
                         , acc_entries_tab e
                     where f.id = e.id
                       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and m.id = f.macros_id
                       and m.object_id = o.id
                 ) x
               , opr_operation oo
               , opr_participant b
               , opr_card c
               , opr_participant a
               , aut_auth t
               , iss_card ic
               , acq_merchant m
               , prd_contract ct
            where x.oper_id = oo.id
              and oo.id = b.oper_id(+)
              and b.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
              and c.oper_id(+) = oo.id 
              and oo.id = a.oper_id(+)
              and a.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
              and t.id(+) = oo.id
              and ic.id(+) = b.card_id
              and m.id(+) = a.merchant_id
              and ct.id(+) = m.contract_id
            order by oo.id
          ) g;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');

            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );

            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;

            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all records those are processed...');
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get objects by events using dates and ignoring status
            open o_cursor for
                select e.id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where o.procedure_name = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date      between l_start_date and l_end_date
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date, null) between l_start_date and l_end_date
                   and e.macros_id     = m.id
                 order by m.object_id;
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , e.id as entity_id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and e.macros_id     = m.id
                 order by m.object_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_operations_1_2: START with ' 
                     || 'l_full_export [#1], ' 
                     || 'i_inst_id [#2], '
                     || 'i_masking_card [#3], '
                     || 'i_date_type [#4], '
                     || 'i_start_date [#5], '
                     || 'i_end_date [#6]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_masking_card
      , i_env_param4 => i_date_type
      , i_env_param5 => to_char(i_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param6 => to_char(i_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );
    
    l_container_id      := prc_api_session_pkg.get_container_id;
    l_process_id        := prc_api_session_pkg.get_process_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and f.process_id   = l_process_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    set_ui_value_pkg.get_inst_by_param_n(
        i_param_name        => 'CBS_SETTLEMENT_FLAG'
      , o_inst_id           => g_inst_flag_tab
    );

    trc_log_pkg.debug(
        i_text       => 'l_file_type [#1], '
                     || 'l_start_date [#2], '
                     || 'l_end_date [#3] '
      , i_env_param1 => l_file_type
      , i_env_param2 => to_char(l_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param3 => to_char(l_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_oper_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null) and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_oper_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_operations_1_2: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_1_3(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_date_type           in     com_api_type_pkg.t_dict_value    default com_api_const_pkg.DATE_PURPOSE_PROCESSING
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_OPER_EXPORT_PKG.PROCESS';

    -- Defult bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := DEFAULT_BULK_LIMIT;
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_long_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_sysdate               date := get_sysdate;
    l_start_date            date;
    l_end_date              date;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with acc_entries_tab as (
            select column_value as id from table(cast(l_object_id_tab as num_tab_tpt))
        )
        select
            xmlelement(
                "operations"
              , xmlattributes('http://sv.bpc.in/SVXP/Operations' as "xmlns")
              , xmlelement("file_id", to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_id",   g.oper_id)
                      , xmlelement("inst_id",   g.acq_inst_id)
                      , xmlelement("agent_id",  g.agent_id)
                      , xmlelement("oper_type", g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
                      , xmlelement("status",    g.status)
                      , xmlforest(g.resp_code as "resp_code")
                      , xmlelement("oper_date", to_char(g.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("host_date", to_char(g.host_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("oper_amount"
                          , xmlelement("amount_value", g.oper_amount)
                          , xmlelement("currency", g.oper_currency)
                        )
                      , (select xmlagg(
                                    xmlelement("sttl_amount"
                                      , xmlelement("amount_value", g.sttl_amount)
                                      , xmlelement("currency", g.sttl_currency)
                                    )
                                )
                           from dual
                          where g.sttl_amount is not null
                            and g.sttl_currency is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_request_amount"
                                      , xmlelement("amount_value", g.oper_request_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_request_amount is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_surcharge_amount"
                                      , xmlelement("amount_value", g.oper_surcharge_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_surcharge_amount is not null
                        )
                      , xmlforest(
                            g.originator_refnum  as "originator_refnum"
                          , g.network_refnum     as "network_refnum"
                          , g.is_reversal        as "is_reversal"
                          , g.merchant_number    as "merchant_number"
                          , g.mcc                as "mcc"
                          , g.merchant_name      as "merchant_name"
                          , g.merchant_street    as "merchant_street"
                          , g.merchant_city      as "merchant_city"
                          , g.merchant_region    as "merchant_region"
                          , g.merchant_country   as "merchant_country"
                          , g.merchant_postcode  as "merchant_postcode"
                          , g.terminal_type      as "terminal_type"
                          , g.terminal_number    as "terminal_number"
                          , g.merchant_id        as "merchant_id"
                          , g.terminal_id        as "terminal_id"
                          , g.card_number        as "card_number"
                          , g.card_network_id    as "card_network_id"
                          , g.card_type_id       as "card_type_id"
                        )
                      , (select xmlagg(
                                    xmlelement(
                                        "entry"
                                      , xmlelement("entry_id",         xa.id)
                                      , xmlelement("transaction_type", xa.transaction_type)
                                      , xmlelement("posting_date",     to_char(xa.posting_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("sttl_date",        to_char(xa.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("balance_impact",   xa.balance_impact)
                                      , xmlforest(xm.amount_purpose as "amount_purpose")
                                      , xmlelement(
                                            "account"
                                          , xmlattributes(zz.id as "account_id")
                                          , xmlelement("account_number", zz.account_number)
                                          , xmlelement("currency", zz.currency)
                                        )
                                      , xmlelement(
                                            "amount"
                                          , xmlelement("amount_value", xa.amount)
                                          , xmlelement("currency", xa.currency)
                                        )
                                      , xmlforest(case check_inst_id(i_inst_id  => zz.inst_id)
                                                      when com_api_const_pkg.TRUE then xa.is_settled
                                                      else null
                                                   end as "is_settled")
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                              , acc_account zz
                              , acc_entries_tab e
                          where xa.macros_id   = xm.id
                            and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and xm.object_id   = g.oper_id
                            and xa.account_id  = zz.id
                            and xa.id          = e.id
                        ) entry
                    )
                )
            ).getclobval()
          , count(*)
        from (select
                oo.id as oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.status
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
              , oo.oper_request_amount
              , oo.oper_surcharge_amount
              , oo.originator_refnum
              , oo.network_refnum
              , oo.status_reason as response_code
              , oo.merchant_number
              , oo.mcc
              , oo.merchant_name
              , oo.merchant_street
              , oo.merchant_city
              , oo.merchant_country
              , oo.merchant_postcode
              , oo.merchant_region
              , oo.terminal_type
              , oo.terminal_number
              , oo.clearing_sequence_num
              , oo.clearing_sequence_count
              , oo.is_reversal
              , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                    then
                        coalesce(
                            b.card_mask
                          , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                        )
                    when l_is_token_enabled = com_api_const_pkg.FALSE then
                        c.card_number
                    else
                        iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                end as card_number
              , b.card_id
              , b.card_instance_id
              , b.card_seq_number
              , b.card_expir_date
              , b.card_country
              , b.card_network_id
              , b.inst_id    as iss_inst_id
              , b.network_id as iss_network_id
              , b.auth_code
              , a.inst_id    acq_inst_id
              , a.network_id acq_network_id
              , a.auth_code  acq_auth_code
              , a.account_number
              , a.account_amount
              , a.account_currency
              , a.terminal_id
              , a.merchant_id
              , t.resp_code
              , ic.card_type_id
              , ct.agent_id
            from (
                    select distinct o.id as oper_id
                      from opr_operation o
                         , acc_entry f
                         , acc_macros m
                         , acc_entries_tab e
                     where f.id = e.id
                       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and m.id = f.macros_id
                       and m.object_id = o.id
                 ) x
               , opr_operation oo
               , opr_participant b
               , opr_card c
               , opr_participant a
               , aut_auth t
               , iss_card ic
               , acq_merchant m
               , prd_contract ct
            where x.oper_id = oo.id
              and oo.id = b.oper_id(+)
              and b.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
              and c.oper_id(+) = oo.id 
              and oo.id = a.oper_id(+)
              and a.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
              and t.id(+) = oo.id
              and ic.id(+) = b.card_id
              and m.id(+) = a.merchant_id
              and ct.id(+) = m.contract_id
            order by oo.id
          ) g;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all records those are processed...');
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get objects by events using dates and ignoring status
            open o_cursor for
                select e.id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where o.procedure_name = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date      between l_start_date and l_end_date
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date, null) between l_start_date and l_end_date
                   and e.macros_id     = m.id
                 order by m.object_id;
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , e.id as entity_id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and e.macros_id     = m.id
                 order by m.object_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_operations_1_3: START with ' 
                     || 'l_full_export [#1], ' 
                     || 'i_inst_id [#2], '
                     || 'i_masking_card [#3], '
                     || 'i_date_type [#4], '
                     || 'i_start_date [#5], '
                     || 'i_end_date [#6]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_masking_card
      , i_env_param4 => i_date_type
      , i_env_param5 => to_char(i_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param6 => to_char(i_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );
    
    l_container_id      := prc_api_session_pkg.get_container_id;
    l_process_id        := prc_api_session_pkg.get_process_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and f.process_id   = l_process_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    set_ui_value_pkg.get_inst_by_param_n(
        i_param_name        => 'CBS_SETTLEMENT_FLAG'
      , o_inst_id           => g_inst_flag_tab
    );

    trc_log_pkg.debug(
        i_text       => 'l_file_type [#1], '
                     || 'l_start_date [#2], '
                     || 'l_end_date [#3] '
      , i_env_param1 => l_file_type
      , i_env_param2 => to_char(l_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param3 => to_char(l_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_oper_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null) and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_oper_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_operations_1_3: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_1_5(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_date_type           in     com_api_type_pkg.t_dict_value    default com_api_const_pkg.DATE_PURPOSE_PROCESSING
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_OPER_EXPORT_PKG.PROCESS';

    -- Defult bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := DEFAULT_BULK_LIMIT;
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_long_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_sysdate               date := get_sysdate;
    l_start_date            date;
    l_end_date              date;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with acc_entries_tab as (
            select column_value as id from table(cast(l_object_id_tab as num_tab_tpt))
        )
        select
            xmlelement(
                "operations"
              , xmlattributes('http://sv.bpc.in/SVXP/Operations' as "xmlns")
              , xmlelement("file_id", to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_id",   g.oper_id)
                      , xmlelement("inst_id",   g.acq_inst_id)
                      , xmlelement("agent_id",  g.agent_id)
                      , xmlelement("oper_type", g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
                      , xmlelement("status",    g.status)
                      , xmlforest(g.resp_code as "resp_code")
                      , xmlelement("oper_date", to_char(g.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("host_date", to_char(g.host_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("oper_amount"
                          , xmlelement("amount_value", g.oper_amount)
                          , xmlelement("currency", g.oper_currency)
                        )
                      , (select xmlagg(
                                    xmlelement("sttl_amount"
                                      , xmlelement("amount_value", g.sttl_amount)
                                      , xmlelement("currency", g.sttl_currency)
                                    )
                                )
                           from dual
                          where g.sttl_amount is not null
                            and g.sttl_currency is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_request_amount"
                                      , xmlelement("amount_value", g.oper_request_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_request_amount is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_surcharge_amount"
                                      , xmlelement("amount_value", g.oper_surcharge_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_surcharge_amount is not null
                        )
                      , xmlforest(
                            g.originator_refnum  as "originator_refnum"
                          , g.network_refnum     as "network_refnum"
                          , g.is_reversal        as "is_reversal"
                          , g.merchant_number    as "merchant_number"
                          , g.mcc                as "mcc"
                          , g.merchant_name      as "merchant_name"
                          , g.merchant_street    as "merchant_street"
                          , g.merchant_city      as "merchant_city"
                          , g.merchant_region    as "merchant_region"
                          , g.merchant_country   as "merchant_country"
                          , g.merchant_postcode  as "merchant_postcode"
                          , g.terminal_type      as "terminal_type"
                          , g.terminal_number    as "terminal_number"
                          , g.merchant_id        as "merchant_id"
                          , g.terminal_id        as "terminal_id"
                          , g.card_number        as "card_number"
                          , g.card_network_id    as "card_network_id"
                          , g.card_type_id       as "card_type_id"
                        )
                      , (select xmlagg(
                                    xmlelement(
                                        "entry"
                                      , xmlelement("entry_id",         xa.id)
                                      , xmlelement("transaction_type", xa.transaction_type)
                                      , xmlelement("posting_date",     to_char(xa.posting_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("sttl_date",        to_char(xa.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("balance_impact",   xa.balance_impact)
                                      , xmlforest(xm.amount_purpose as "amount_purpose")
                                      , xmlelement(
                                            "account"
                                          , xmlattributes(zz.id as "account_id")
                                          , xmlelement("account_number", zz.account_number)
                                          , xmlelement("currency", zz.currency)
                                        )
                                      , xmlelement(
                                            "amount"
                                          , xmlelement("amount_value", xa.amount)
                                          , xmlelement("currency", xa.currency)
                                        )
                                      , xmlforest(case check_inst_id(i_inst_id  => zz.inst_id)
                                                      when com_api_const_pkg.TRUE then xa.is_settled
                                                      else null
                                                   end as "is_settled")
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                              , acc_account zz
                              , acc_entries_tab e
                          where xa.macros_id   = xm.id
                            and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and xm.object_id   = g.oper_id
                            and xa.account_id  = zz.id
                            and xa.id          = e.id
                        ) entry
                      , xmlelement("auth_code",   g.auth_code)
                      , (select xmlagg(
                                    xmlelement("flexible_data"
                                      , xmlelement("field_name",  ff.name)
                                      , xmlelement(
                                            "field_value"
                                           , case when ff.data_type = com_api_const_pkg.DATA_TYPE_CHAR
                                                       then fd.field_value
                                                  when ff.data_type = com_api_const_pkg.DATA_TYPE_NUMBER
                                                       then case 
                                                            when instr(fd.field_value, '.0000') <> 0
                                                                 then to_char(to_number(fd.field_value, com_api_const_pkg.NUMBER_FORMAT))
                                                                 else fd.field_value
                                                            end
                                                  when ff.data_type = com_api_const_pkg.DATA_TYPE_DATE
                                                       then to_char(
                                                                to_date(fd.field_value, ff.data_format)
                                                              , com_api_const_pkg.XML_DATETIME_FORMAT
                                                            )
                                             end
                                        )
                                    )
                                )
                           from com_flexible_data  fd
                              , com_flexible_field ff
                          where ff.id = fd.field_id
                            and fd.object_id = g.oper_id
                        ) flexible_data
                    )
                )
            ).getclobval()
          , count(*)
        from (select
                oo.id as oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.status
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
              , oo.oper_request_amount
              , oo.oper_surcharge_amount
              , oo.originator_refnum
              , oo.network_refnum
              , oo.status_reason as response_code
              , oo.merchant_number
              , oo.mcc
              , oo.merchant_name
              , oo.merchant_street
              , oo.merchant_city
              , oo.merchant_country
              , oo.merchant_postcode
              , oo.merchant_region
              , oo.terminal_type
              , oo.terminal_number
              , oo.clearing_sequence_num
              , oo.clearing_sequence_count
              , oo.is_reversal
              , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                    then
                        coalesce(
                            b.card_mask
                          , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                        )
                    when l_is_token_enabled = com_api_const_pkg.FALSE then
                        c.card_number
                    else
                        iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                end as card_number
              , b.card_id
              , b.card_instance_id
              , b.card_seq_number
              , b.card_expir_date
              , b.card_country
              , b.card_network_id
              , b.inst_id    as iss_inst_id
              , b.network_id as iss_network_id
              , b.auth_code
              , a.inst_id    acq_inst_id
              , a.network_id acq_network_id
              , a.auth_code  acq_auth_code
              , a.account_number
              , a.account_amount
              , a.account_currency
              , a.terminal_id
              , a.merchant_id
              , t.resp_code
              , ic.card_type_id
              , ct.agent_id
            from (
                    select distinct o.id as oper_id
                      from opr_operation o
                         , acc_entry f
                         , acc_macros m
                         , acc_entries_tab e
                     where f.id = e.id
                       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and m.id = f.macros_id
                       and m.object_id = o.id
                 ) x
               , opr_operation oo
               , opr_participant b
               , opr_card c
               , opr_participant a
               , aut_auth t
               , iss_card ic
               , acq_merchant m
               , prd_contract ct
            where x.oper_id = oo.id
              and oo.id = b.oper_id(+)
              and b.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
              and c.oper_id(+) = oo.id 
              and oo.id = a.oper_id(+)
              and a.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
              and t.id(+) = oo.id
              and ic.id(+) = b.card_id
              and m.id(+) = a.merchant_id
              and ct.id(+) = m.contract_id
            order by oo.id
          ) g;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all records those are processed...');
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get objects by events using dates and ignoring status
            open o_cursor for
                select e.id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where o.procedure_name = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date      between l_start_date and l_end_date
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date, null) between l_start_date and l_end_date
                   and e.macros_id     = m.id
                 order by m.object_id;
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , e.id as entity_id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and e.macros_id     = m.id
                 order by m.object_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_operations_1_5: START with ' 
                     || 'l_full_export [#1], ' 
                     || 'i_inst_id [#2], '
                     || 'i_masking_card [#3], '
                     || 'i_date_type [#4], '
                     || 'i_start_date [#5], '
                     || 'i_end_date [#6]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_masking_card
      , i_env_param4 => i_date_type
      , i_env_param5 => to_char(i_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param6 => to_char(i_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );
    
    l_container_id      := prc_api_session_pkg.get_container_id;
    l_process_id        := prc_api_session_pkg.get_process_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and f.process_id   = l_process_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    set_ui_value_pkg.get_inst_by_param_n(
        i_param_name        => 'CBS_SETTLEMENT_FLAG'
      , o_inst_id           => g_inst_flag_tab
    );

    trc_log_pkg.debug(
        i_text       => 'l_file_type [#1], '
                     || 'l_start_date [#2], '
                     || 'l_end_date [#3] '
      , i_env_param1 => l_file_type
      , i_env_param2 => to_char(l_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param3 => to_char(l_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_oper_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null) and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_oper_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_operations_1_5: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_1_5;

procedure process_1_6(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_date_type           in     com_api_type_pkg.t_dict_value    default com_api_const_pkg.DATE_PURPOSE_PROCESSING
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_OPER_EXPORT_PKG.PROCESS';

    -- Defult bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := DEFAULT_BULK_LIMIT;
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_long_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_sysdate               date := get_sysdate;
    l_start_date            date;
    l_end_date              date;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with acc_entries_tab as (
            select column_value as id from table(cast(l_object_id_tab as num_tab_tpt))
        )
        select
            xmlelement(
                "operations"
              , xmlattributes('http://sv.bpc.in/SVXP/Operations' as "xmlns")
              , xmlelement("file_id", to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_id",   g.oper_id)
                      , xmlelement("inst_id",   g.acq_inst_id)
                      , xmlelement("agent_id",  g.agent_id)
                      , xmlelement("oper_type", g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
                      , xmlelement("status",    g.status)
                      , xmlforest(g.resp_code as "resp_code")
                      , xmlelement("oper_date", to_char(g.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("host_date", to_char(g.host_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("oper_amount"
                          , xmlelement("amount_value", g.oper_amount)
                          , xmlelement("currency", g.oper_currency)
                        )
                      , (select xmlagg(
                                    xmlelement("sttl_amount"
                                      , xmlelement("amount_value", g.sttl_amount)
                                      , xmlelement("currency", g.sttl_currency)
                                    )
                                )
                           from dual
                          where g.sttl_amount is not null
                            and g.sttl_currency is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_request_amount"
                                      , xmlelement("amount_value", g.oper_request_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_request_amount is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_surcharge_amount"
                                      , xmlelement("amount_value", g.oper_surcharge_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_surcharge_amount is not null
                        )
                      , xmlforest(
                            g.originator_refnum  as "originator_refnum"
                          , g.network_refnum     as "network_refnum"
                          , g.is_reversal        as "is_reversal"
                          , g.original_id        as "original_id"
                          , g.merchant_number    as "merchant_number"
                          , g.mcc                as "mcc"
                          , g.merchant_name      as "merchant_name"
                          , g.merchant_street    as "merchant_street"
                          , g.merchant_city      as "merchant_city"
                          , g.merchant_region    as "merchant_region"
                          , g.merchant_country   as "merchant_country"
                          , g.merchant_postcode  as "merchant_postcode"
                          , g.terminal_type      as "terminal_type"
                          , g.terminal_number    as "terminal_number"
                          , g.merchant_id        as "merchant_id"
                          , g.terminal_id        as "terminal_id"
                          , g.card_number        as "card_number"
                          , g.card_network_id    as "card_network_id"
                          , g.card_type_id       as "card_type_id"
                          , g.card_country       as "card_country"
                          , g.euro_zone          as "euro_zone"
                          , g.product_id         as "product_id"
                          , g.brand              as "brand"
                          , g.card_bin_category  as "card_bin_category"
                          , g.external_auth_id   as "external_auth_id"
                        )
                      , (select xmlagg(
                                    xmlelement(
                                        "entry"
                                      , xmlelement("entry_id",         xa.id)
                                      , xmlelement("transaction_type", xa.transaction_type)
                                      , xmlelement("posting_date",     to_char(xa.posting_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("sttl_date",        to_char(xa.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("balance_impact",   xa.balance_impact)
                                      , xmlforest(xm.amount_purpose as "amount_purpose")
                                      , xmlelement(
                                            "account"
                                          , xmlattributes(zz.id as "account_id")
                                          , xmlelement("account_number", zz.account_number)
                                          , xmlelement("currency", zz.currency)
                                        )
                                      , xmlelement(
                                            "amount"
                                          , xmlelement("amount_value", xa.amount)
                                          , xmlelement("currency", xa.currency)
                                        )
                                      , xmlforest(case check_inst_id(i_inst_id  => zz.inst_id)
                                                      when com_api_const_pkg.TRUE then xa.is_settled
                                                      else null
                                                   end as "is_settled")
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                              , acc_account zz
                              , acc_entries_tab e
                          where xa.macros_id   = xm.id
                            and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and xm.object_id   = g.oper_id
                            and xa.account_id  = zz.id
                            and xa.id          = e.id
                        ) entry
                      , xmlelement("auth_code",   g.auth_code)
                      , (select xmlagg(
                                    xmlelement("flexible_data"
                                      , xmlelement("field_name",  ff.name)
                                      , xmlelement(
                                            "field_value"
                                           , case when ff.data_type = com_api_const_pkg.DATA_TYPE_CHAR
                                                       then fd.field_value
                                                  when ff.data_type = com_api_const_pkg.DATA_TYPE_NUMBER
                                                       then case 
                                                            when instr(fd.field_value, '.0000') <> 0
                                                                 then to_char(to_number(fd.field_value, com_api_const_pkg.NUMBER_FORMAT))
                                                                 else fd.field_value
                                                            end
                                                  when ff.data_type = com_api_const_pkg.DATA_TYPE_DATE
                                                       then to_char(
                                                                to_date(fd.field_value, ff.data_format)
                                                              , com_api_const_pkg.XML_DATETIME_FORMAT
                                                            )
                                             end
                                        )
                                    )
                                )
                           from com_flexible_data  fd
                              , com_flexible_field ff
                          where ff.id = fd.field_id
                            and fd.object_id = g.oper_id
                        ) flexible_data
                    )
                )
            ).getclobval()
          , count(*)
        from (select
                oo.id as oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.status
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
              , oo.oper_request_amount
              , oo.oper_surcharge_amount
              , oo.originator_refnum
              , oo.network_refnum
              , oo.status_reason as response_code
              , oo.merchant_number
              , oo.mcc
              , oo.merchant_name
              , oo.merchant_street
              , oo.merchant_city
              , oo.merchant_country
              , oo.merchant_postcode
              , oo.merchant_region
              , oo.terminal_type
              , oo.terminal_number
              , oo.clearing_sequence_num
              , oo.clearing_sequence_count
              , oo.is_reversal
              , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                    then
                        coalesce(
                            b.card_mask
                          , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                        )
                    when l_is_token_enabled = com_api_const_pkg.FALSE then
                        c.card_number
                    else
                        iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                end as card_number
              , b.card_id
              , b.card_instance_id
              , b.card_seq_number
              , b.card_expir_date
              , b.card_country
              , b.card_network_id
              , b.inst_id    as iss_inst_id
              , b.network_id as iss_network_id
              , b.auth_code
              , a.inst_id    acq_inst_id
              , a.network_id acq_network_id
              , a.auth_code  acq_auth_code
              , a.account_number
              , a.account_amount
              , a.account_currency
              , a.terminal_id
              , a.merchant_id
              , t.resp_code
              , ic.card_type_id
              , ct.agent_id
              , cc.mastercard_eurozone as euro_zone
              , bi.product_id
              , bi.brand
              , bi.account_funding_source as card_bin_category
              , oo.original_id
              , t.external_auth_id
            from (
                    select distinct o.id as oper_id
                      from opr_operation o
                         , acc_entry f
                         , acc_macros m
                         , acc_entries_tab e
                     where f.id = e.id
                       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and m.id = f.macros_id
                       and m.object_id = o.id
                 ) x
               , opr_operation oo
               , opr_participant b
               , opr_card c
               , opr_participant a
               , aut_auth t
               , iss_card ic
               , acq_merchant m
               , prd_contract ct
               , com_country cc
               , opr_bin_info bi
            where x.oper_id = oo.id
              and oo.id = b.oper_id(+)
              and b.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
              and c.oper_id(+) = oo.id 
              and oo.id = a.oper_id(+)
              and a.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
              and t.id(+) = oo.id
              and ic.id(+) = b.card_id
              and m.id(+) = a.merchant_id
              and ct.id(+) = m.contract_id
              and cc.code(+) = b.card_country
              and bi.oper_id(+) = b.oper_id
              and bi.participant_type(+) = b.participant_type
            order by oo.id
          ) g;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all records those are processed...');
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get objects by events using dates and ignoring status
            open o_cursor for
                select e.id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where o.procedure_name = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date      between l_start_date and l_end_date
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date, null) between l_start_date and l_end_date
                   and e.macros_id     = m.id
                 order by m.object_id;
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , e.id as entity_id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and e.macros_id     = m.id
                 order by m.object_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_operations_1_6: START with ' 
                     || 'l_full_export [#1], ' 
                     || 'i_inst_id [#2], '
                     || 'i_masking_card [#3], '
                     || 'i_date_type [#4], '
                     || 'i_start_date [#5], '
                     || 'i_end_date [#6]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_masking_card
      , i_env_param4 => i_date_type
      , i_env_param5 => to_char(i_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param6 => to_char(i_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );
    
    l_container_id      := prc_api_session_pkg.get_container_id;
    l_process_id        := prc_api_session_pkg.get_process_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and f.process_id   = l_process_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    set_ui_value_pkg.get_inst_by_param_n(
        i_param_name        => 'CBS_SETTLEMENT_FLAG'
      , o_inst_id           => g_inst_flag_tab
    );

    trc_log_pkg.debug(
        i_text       => 'l_file_type [#1], '
                     || 'l_start_date [#2], '
                     || 'l_end_date [#3], '
      , i_env_param1 => l_file_type
      , i_env_param2 => to_char(l_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param3 => to_char(l_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_oper_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null) and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_oper_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_operations_1_6: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_1_6;

procedure process_1_7(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_date_type           in     com_api_type_pkg.t_dict_value    default com_api_const_pkg.DATE_PURPOSE_PROCESSING
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_OPER_EXPORT_PKG.PROCESS';

    -- Defult bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := DEFAULT_BULK_LIMIT;
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_long_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_sysdate               date := get_sysdate;
    l_start_date            date;
    l_end_date              date;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with acc_entries_tab as (
            select column_value as id from table(cast(l_object_id_tab as num_tab_tpt))
        )
        select
            xmlelement(
                "operations"
              , xmlattributes('http://sv.bpc.in/SVXP/Operations' as "xmlns")
              , xmlelement("file_id", to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_id",   g.oper_id)
                      , xmlelement("inst_id",   g.acq_inst_id)
                      , xmlelement("agent_id",  g.agent_id)
                      , xmlelement("oper_type", g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
                      , xmlelement("status",    g.status)
                      , xmlforest(g.resp_code as "resp_code")
                      , xmlelement("oper_date", to_char(g.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("host_date", to_char(g.host_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                      , xmlelement("oper_amount"
                          , xmlelement("amount_value", g.oper_amount)
                          , xmlelement("currency", g.oper_currency)
                        )
                      , (select xmlagg(
                                    xmlelement("sttl_amount"
                                      , xmlelement("amount_value", g.sttl_amount)
                                      , xmlelement("currency", g.sttl_currency)
                                    )
                                )
                           from dual
                          where g.sttl_amount is not null
                            and g.sttl_currency is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_request_amount"
                                      , xmlelement("amount_value", g.oper_request_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_request_amount is not null
                        )
                      , (select xmlagg(
                                    xmlelement("oper_surcharge_amount"
                                      , xmlelement("amount_value", g.oper_surcharge_amount)
                                      , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_surcharge_amount is not null
                        )
                      , xmlforest(
                            g.originator_refnum  as "originator_refnum"
                          , g.network_refnum     as "network_refnum"
                          , g.is_reversal        as "is_reversal"
                          , g.original_id        as "original_id"
                          , g.merchant_number    as "merchant_number"
                          , g.mcc                as "mcc"
                          , g.merchant_name      as "merchant_name"
                          , g.merchant_street    as "merchant_street"
                          , g.merchant_city      as "merchant_city"
                          , g.merchant_region    as "merchant_region"
                          , g.merchant_country   as "merchant_country"
                          , g.merchant_postcode  as "merchant_postcode"
                          , g.terminal_type      as "terminal_type"
                          , g.terminal_number    as "terminal_number"
                          , g.merchant_id        as "merchant_id"
                          , g.terminal_id        as "terminal_id"
                          , g.card_number        as "card_number"
                          , g.card_network_id    as "card_network_id"
                          , g.card_type_id       as "card_type_id"
                          , g.card_country       as "card_country"
                          , g.euro_zone          as "euro_zone"
                          , g.product_id         as "product_id"
                          , g.brand              as "brand"
                          , g.card_bin_category  as "card_bin_category"
                          , g.external_auth_id   as "external_auth_id"
                          , g.iss_inst_id        as "iss_inst_id"
                        )
                      , (select xmlagg(
                                    xmlelement(
                                        "entry"
                                      , xmlelement("entry_id",         xa.id)
                                      , xmlelement("transaction_type", xa.transaction_type)
                                      , xmlelement("posting_date",     to_char(xa.posting_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("sttl_date",        to_char(xa.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , xmlelement("balance_impact",   xa.balance_impact)
                                      , xmlforest(xm.amount_purpose as "amount_purpose")
                                      , xmlelement(
                                            "account"
                                          , xmlattributes(zz.id as "account_id")
                                          , xmlelement("account_number", zz.account_number)
                                          , xmlelement("currency", zz.currency)
                                        )
                                      , xmlelement(
                                            "amount"
                                          , xmlelement("amount_value", xa.amount)
                                          , xmlelement("currency", xa.currency)
                                        )
                                      , xmlforest(case check_inst_id(i_inst_id  => zz.inst_id)
                                                      when com_api_const_pkg.TRUE then xa.is_settled
                                                      else null
                                                   end as "is_settled")
                                      , xmlforest(case check_inst_id(i_inst_id  => zz.inst_id)
                                                      when com_api_const_pkg.TRUE then to_char(xa.sttl_flag_date, com_api_const_pkg.XML_DATETIME_FORMAT)
                                                      else null
                                                   end as "sttl_flag_date")
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                              , acc_account zz
                              , acc_entries_tab e
                          where xa.macros_id   = xm.id
                            and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and xm.object_id   = g.oper_id
                            and xa.account_id  = zz.id
                            and xa.id          = e.id
                        ) entry
                      , xmlelement("auth_code",   g.auth_code)
                      , (select xmlagg(
                                    xmlelement("flexible_data"
                                      , xmlelement("field_name",  ff.name)
                                      , xmlelement(
                                            "field_value"
                                           , case when ff.data_type = com_api_const_pkg.DATA_TYPE_CHAR
                                                       then fd.field_value
                                                  when ff.data_type = com_api_const_pkg.DATA_TYPE_NUMBER
                                                       then case
                                                            when instr(fd.field_value, '.0000') <> 0
                                                                 then to_char(to_number(fd.field_value, com_api_const_pkg.NUMBER_FORMAT))
                                                                 else fd.field_value
                                                            end
                                                  when ff.data_type = com_api_const_pkg.DATA_TYPE_DATE
                                                       then to_char(
                                                                to_date(fd.field_value, ff.data_format)
                                                              , com_api_const_pkg.XML_DATETIME_FORMAT
                                                            )
                                             end
                                        )
                                    )
                                )
                           from com_flexible_data  fd
                              , com_flexible_field ff
                          where ff.id = fd.field_id
                            and fd.object_id = g.oper_id
                        ) flexible_data
                    )
                )
            ).getclobval()
          , count(*)
        from (select
                oo.id as oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.status
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
              , oo.oper_request_amount
              , oo.oper_surcharge_amount
              , oo.originator_refnum
              , oo.network_refnum
              , oo.status_reason as response_code
              , oo.merchant_number
              , oo.mcc
              , oo.merchant_name
              , oo.merchant_street
              , oo.merchant_city
              , oo.merchant_country
              , oo.merchant_postcode
              , oo.merchant_region
              , oo.terminal_type
              , oo.terminal_number
              , oo.clearing_sequence_num
              , oo.clearing_sequence_count
              , oo.is_reversal
              , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                    then
                        coalesce(
                            b.card_mask
                          , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                        )
                    when l_is_token_enabled = com_api_const_pkg.FALSE then
                        c.card_number
                    else
                        iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                end as card_number
              , b.card_id
              , b.card_instance_id
              , b.card_seq_number
              , b.card_expir_date
              , b.card_country
              , b.card_network_id
              , b.inst_id    as iss_inst_id
              , b.network_id as iss_network_id
              , b.auth_code
              , a.inst_id    acq_inst_id
              , a.network_id acq_network_id
              , a.auth_code  acq_auth_code
              , a.account_number
              , a.account_amount
              , a.account_currency
              , a.terminal_id
              , a.merchant_id
              , t.resp_code
              , ic.card_type_id
              , ct.agent_id
              , cc.mastercard_eurozone as euro_zone
              , bi.product_id
              , bi.brand
              , bi.account_funding_source as card_bin_category
              , oo.original_id
              , t.external_auth_id
            from (
                    select distinct o.id as oper_id
                      from opr_operation o
                         , acc_entry f
                         , acc_macros m
                         , acc_entries_tab e
                     where f.id = e.id
                       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and m.id = f.macros_id
                       and m.object_id = o.id
                 ) x
               , opr_operation oo
               , opr_participant b
               , opr_card c
               , opr_participant a
               , aut_auth t
               , iss_card ic
               , acq_merchant m
               , prd_contract ct
               , com_country cc
               , opr_bin_info bi
            where x.oper_id = oo.id
              and oo.id = b.oper_id(+)
              and b.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
              and c.oper_id(+) = oo.id
              and oo.id = a.oper_id(+)
              and a.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
              and t.id(+) = oo.id
              and ic.id(+) = b.card_id
              and m.id(+) = a.merchant_id
              and ct.id(+) = m.contract_id
              and cc.code(+) = b.card_country
              and bi.oper_id(+) = b.oper_id
              and bi.participant_type(+) = b.participant_type
            order by oo.id
          ) g;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_long_id;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');

            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');

            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );

            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;

            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;

    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all records those are processed...');
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get objects by events using dates and ignoring status
            open o_cursor for
                select e.id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where o.procedure_name = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date      between l_start_date and l_end_date
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, e.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       e.sttl_date, null) between l_start_date and l_end_date
                   and e.macros_id     = m.id
                 order by m.object_id;
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , e.id as entity_id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and e.macros_id     = m.id
                 order by m.object_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_operations_1_7: START with '
                     || 'l_full_export [#1], '
                     || 'i_inst_id [#2], '
                     || 'i_masking_card [#3], '
                     || 'i_date_type [#4], '
                     || 'i_start_date [#5], '
                     || 'i_end_date [#6]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_masking_card
      , i_env_param4 => i_date_type
      , i_env_param5 => to_char(i_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param6 => to_char(i_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );

    l_container_id      := prc_api_session_pkg.get_container_id;
    l_process_id        := prc_api_session_pkg.get_process_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and f.process_id   = l_process_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    set_ui_value_pkg.get_inst_by_param_n(
        i_param_name        => 'CBS_SETTLEMENT_FLAG'
      , o_inst_id           => g_inst_flag_tab
    );

    trc_log_pkg.debug(
        i_text       => 'l_file_type [#1], '
                     || 'l_start_date [#2], '
                     || 'l_end_date [#3], '
      , i_env_param1 => l_file_type
      , i_env_param2 => to_char(l_start_date, com_api_const_pkg.XML_DATETIME_FORMAT)
      , i_env_param3 => to_char(l_end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_oper_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null) and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);

                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;

                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_oper_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_operations_1_7: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_1_7;

procedure process(
    i_mpt_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_date_type           in     com_api_type_pkg.t_dict_value    default com_api_const_pkg.DATE_PURPOSE_PROCESSING
) as
    l_date_type           com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text        => 'i_mpt_version=' || i_mpt_version
    );

    l_date_type := nvl(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING);

    if i_mpt_version = '1.2' then
        process_1_2(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_masking_card     => i_masking_card
          , i_date_type        => l_date_type
        );
    elsif i_mpt_version between '1.3' and '1.4' then
        process_1_3(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_masking_card     => i_masking_card
          , i_date_type        => l_date_type
        );
    elsif i_mpt_version = '1.5' then
        process_1_5(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_masking_card     => i_masking_card
          , i_date_type        => l_date_type
        );
    elsif i_mpt_version = '1.6' then
        process_1_6(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_masking_card     => i_masking_card
          , i_date_type        => l_date_type
        );
    elsif i_mpt_version = '1.7' then
        process_1_7(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_masking_card     => i_masking_card
          , i_date_type        => l_date_type
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_mpt_version
        );
    end if;
end;

end;
/
