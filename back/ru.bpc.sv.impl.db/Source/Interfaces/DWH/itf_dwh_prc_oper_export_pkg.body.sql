create or replace package body itf_dwh_prc_oper_export_pkg is

procedure process_1_0(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_DWH_PRC_OPER_EXPORT_PKG.PROCESS';

    -- Defult bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
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
                      , xmlelement("oper_type", g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
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
                      , xmlforest(
                            g.originator_refnum as "originator_refnum"
                          , g.network_refnum    as "network_refnum"
                        )
                      , xmlforest(
                            g.is_reversal        as "is_reversal"
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
                        )
                      , (xmlforest(
                             xmlforest(
                                   g.iss_inst_id      as "inst_id"
                                 , g.iss_network_id   as "network_id"
                                 , g.card_number      as "card_number"     
                                 , g.card_id          as "card_id"
                                 , g.card_instance_id as "card_instance_id"
                                 , g.card_seq_number  as "card_seq_number"
                                 , g.card_expir_date  as "card_expir_date"
                                 , g.card_country     as "card_country"
                                 , g.card_network_id  as "card_network_id"
                                 , g.auth_code        as "auth_code"
                             ) as "issuer"
                         )
                        ) as issuer
                      , (xmlforest(
                             xmlforest(
                                   g.acq_inst_id         as "inst_id"
                                 , g.acq_network_id      as "network_id"
                                 , g.acq_auth_code       as "auth_code"       
                                 , g.merchant_id         as "merchant_id"
                                 , g.terminal_id         as "terminal_id"
                                 , g.account_number      as "account_number"
                                 , g.account_amount      as "account_amount"  
                                 , g.account_currency    as "account_currency"
                             ) as "acquirer"
                         )
                        ) as acquirer

                      , (select xmlagg(
                                    xmlelement(
                                        "transaction"
                                      , xmlelement("transaction_id", xa.transaction_id)
                                      , xmlelement("transaction_type", xa.transaction_type)
                                      , xmlelement("posting_date", to_char(min(xa.posting_date), com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "debit_entry"
                                                      , xmlelement("entry_id",      z.id)
                                                      , xmlelement(
                                                            "account"
                                                          , xmlattributes(zz.id as "account_id")
                                                          , xmlelement("account_number", zz.account_number)
                                                          , xmlelement("currency",       zz.currency)
                                                        )
                                                      , xmlelement(
                                                            "amount"
                                                          , xmlelement("amount_value", z.amount)
                                                          , xmlelement("currency",     z.currency)
                                                        )
                                                    )
                                                )
                                           from acc_entry z
                                              , acc_account zz
                                              , acc_entries_tab e
                                          where z.transaction_id = xa.transaction_id
                                            and z.account_id     = zz.id
                                            and z.id             = e.id
                                            and z.balance_impact = com_api_const_pkg.DEBIT
                                        )
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "credit_entry"
                                                      , xmlelement("entry_id", z.id)
                                                      , xmlelement(
                                                            "account"
                                                          , xmlattributes(zz.id as "account_id")
                                                          , xmlelement("account_number", zz.account_number)
                                                          , xmlelement("currency", zz.currency)
                                                        )
                                                      , xmlelement(
                                                            "amount"
                                                          , xmlelement("amount_value", z.amount)
                                                          , xmlelement("currency", z.currency)
                                                        )
                                                    )
                                                )
                                           from acc_entry z
                                              , acc_account zz
                                              , acc_entries_tab e
                                          where z.transaction_id = xa.transaction_id
                                            and z.account_id     = zz.id
                                            and z.id             = e.id
                                            and z.balance_impact = com_api_const_pkg.CREDIT
                                        )
                                      , xmlforest(
                                            xm.conversion_rate as "conversion_rate"
                                          , xm.amount_purpose  as "amount_purpose"
                                        )
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                              , acc_entries_tab e
                          where xa.macros_id   = xm.id
                            and xa.id          = e.id
                            and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and xm.object_id   = g.oper_id
                          group by xa.transaction_id
                                 , xa.transaction_type
                                 , xm.amount_purpose
                                 , xm.conversion_rate
                        ) transactions
                    )
                )
            ).getclobval()
          , count(*)
        from (select
                (select min(x.purpose_id) from pmo_order x where x.id = oo.payment_order_id) purpose_id
              , oo.payment_order_id
              , x.oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
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
              , iss_api_card_pkg.get_card_agent_number(
                    i_card_id     => b.card_id
                ) agent_number
              , a.inst_id    acq_inst_id
              , a.network_id acq_network_id
              , a.auth_code  acq_auth_code
              , a.account_number
              , a.account_amount
              , a.account_currency
              , a.terminal_id
              , a.merchant_id
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
            where x.oper_id = oo.id
              and x.oper_id = b.oper_id(+)
              and b.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
              and c.oper_id(+) = oo.id 
              and x.oper_id = a.oper_id(+)
              and a.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
            order by x.oper_id
          ) g;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
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
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all reconrs those are processed...');
        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get objects by events using dates and ignoring status
            open o_cursor for
                select e.id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where o.procedure_name = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date      between i_start_date and i_end_date
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and e.macros_id     = m.id
                 order by m.object_id
                        , e.id;
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
                 order by m.object_id
                        , e.id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_operations_1_0: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;
    
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
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
            savepoint sp_dwh_oper_export;

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
                rollback to sp_dwh_oper_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_operations_1_0: FINISH');
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

procedure process_1_1(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_DWH_PRC_OPER_EXPORT_PKG.PROCESS';

    -- Defult bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
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
                      , xmlelement("oper_type", g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
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
                      , xmlforest(
                            g.originator_refnum as "originator_refnum"
                          , g.network_refnum    as "network_refnum"
                        )
                      , xmlforest(
                            g.is_reversal        as "is_reversal"
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
                        )
                      , (xmlforest(
                             xmlforest(
                                   g.iss_inst_id      as "inst_id"
                                 , g.iss_network_id   as "network_id"
                                 , g.card_number      as "card_number"     
                                 , g.card_id          as "card_id"
                                 , g.card_instance_id as "card_instance_id"
                                 , g.card_seq_number  as "card_seq_number"
                                 , g.card_expir_date  as "card_expir_date"
                                 , g.card_country     as "card_country"
                                 , g.card_network_id  as "card_network_id"
                                 , g.auth_code        as "auth_code"
                             ) as "issuer"
                         )
                        ) as issuer
                      , (xmlforest(
                             xmlforest(
                                   g.acq_inst_id         as "inst_id"
                                 , g.acq_network_id      as "network_id"
                                 , g.acq_auth_code       as "auth_code"       
                                 , g.merchant_id         as "merchant_id"
                                 , g.terminal_id         as "terminal_id"
                                 , g.account_number      as "account_number"
                                 , g.account_amount      as "account_amount"  
                                 , g.account_currency    as "account_currency"
                             ) as "acquirer"
                         )
                        ) as acquirer

                      , (select xmlagg(
                                    xmlelement(
                                        "transaction"
                                      , xmlelement("transaction_id", xa.transaction_id)
                                      , xmlelement("transaction_type", xa.transaction_type)
                                      , xmlelement("posting_date", to_char(min(xa.posting_date), com_api_const_pkg.XML_DATETIME_FORMAT))
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "debit_entry"
                                                      , xmlelement("entry_id",      z.id)
                                                      , xmlelement(
                                                            "account"
                                                          , xmlattributes(zz.id as "account_id")
                                                          , xmlelement("account_number", zz.account_number)
                                                          , xmlelement("currency",       zz.currency)
                                                        )
                                                      , xmlelement(
                                                            "amount"
                                                          , xmlelement("amount_value", z.amount)
                                                          , xmlelement("currency",     z.currency)
                                                        )
                                                    )
                                                )
                                           from acc_entry z
                                              , acc_account zz
                                              , acc_entries_tab e
                                          where z.transaction_id = xa.transaction_id
                                            and z.account_id     = zz.id
                                            and z.id             = e.id
                                            and z.balance_impact = com_api_const_pkg.DEBIT
                                        )
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "credit_entry"
                                                      , xmlelement("entry_id", z.id)
                                                      , xmlelement(
                                                            "account"
                                                          , xmlattributes(zz.id as "account_id")
                                                          , xmlelement("account_number", zz.account_number)
                                                          , xmlelement("currency", zz.currency)
                                                        )
                                                      , xmlelement(
                                                            "amount"
                                                          , xmlelement("amount_value", z.amount)
                                                          , xmlelement("currency", z.currency)
                                                        )
                                                    )
                                                )
                                           from acc_entry z
                                              , acc_account zz
                                              , acc_entries_tab e
                                          where z.transaction_id = xa.transaction_id
                                            and z.account_id     = zz.id
                                            and z.id             = e.id
                                            and z.balance_impact = com_api_const_pkg.CREDIT
                                        )
                                      , xmlforest(
                                            xm.conversion_rate as "conversion_rate"
                                          , xm.amount_purpose  as "amount_purpose"
                                        )
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                              , acc_entries_tab e
                          where xa.macros_id   = xm.id
                            and xa.id          = e.id
                            and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and xm.object_id   = g.oper_id
                          group by xa.transaction_id
                                 , xa.transaction_type
                                 , xm.amount_purpose
                                 , xm.conversion_rate
                        ) transactions
                    )
                )
            ).getclobval()
          , count(*)
        from (select
                (select min(x.purpose_id) from pmo_order x where x.id = oo.payment_order_id) purpose_id
              , oo.payment_order_id
              , x.oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
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
              , iss_api_card_pkg.get_card_agent_number(
                    i_card_id     => b.card_id
                ) agent_number
              , a.inst_id    acq_inst_id
              , a.network_id acq_network_id
              , a.auth_code  acq_auth_code
              , a.account_number
              , a.account_amount
              , a.account_currency
              , a.terminal_id
              , a.merchant_id
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
            where x.oper_id = oo.id
              and x.oper_id = b.oper_id(+)
              and b.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
              and c.oper_id(+) = oo.id 
              and x.oper_id = a.oper_id(+)
              and a.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
            order by x.oper_id
          ) g;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
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
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all reconrs those are processed...');
        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get objects by events using dates and ignoring status
            open o_cursor for
                select e.id
                  from evt_event_object o
                     , acc_entry e
                     , acc_macros m
                 where o.procedure_name = i_subscriber_name
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date      between i_start_date and i_end_date
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                   and o.object_id     = e.id
                   and e.macros_id     = m.id
                 order by m.object_id
                        , e.id;
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
                 order by m.object_id
                        , e.id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_operations_1_1: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;
    
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
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
            savepoint sp_dwh_oper_export;

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
                rollback to sp_dwh_oper_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_operations_1_1: FINISH');
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

procedure process(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) as
begin
    trc_log_pkg.debug(
        i_text        => 'i_dwh_version=' || i_dwh_version
    );
    
    if i_dwh_version = '1.0' then
        process_1_0(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_count            => i_count
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_masking_card     => i_masking_card
        );
    elsif i_dwh_version = '1.1' then
        process_1_1(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_count            => i_count
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_masking_card     => i_masking_card
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_dwh_version
        );
    end if;
end;

end;
/
