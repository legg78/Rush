create or replace package body rcn_prc_export_pkg as
/********************************************************* 
 *  Process for export reconciliation message to XML file <br /> 
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 03.05.2018 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: rcn_prc_export_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
BULK_LIMIT                  constant com_api_type_pkg.t_tiny_id := 1000;

procedure process_srvp(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_service_provider_id   in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id   default null
  , i_count                 in     com_api_type_pkg.t_short_id   default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.process_srvp: ';
    l_bulk_limit                com_api_type_pkg.t_count        := nvl(i_count, BULK_LIMIT);
    l_estimated_count           com_api_type_pkg.t_count        := 0;
    l_srvp_msg_id_tab           num_tab_tpt                     := num_tab_tpt();
    l_incr_srvp_msg_id_tab      num_tab_tpt                     := num_tab_tpt();
    l_file                      clob;
    l_total_count               com_api_type_pkg.t_count        := 0;
    l_counter                   com_api_type_pkg.t_count        := 0;
    l_srvp_msg_id               com_api_type_pkg.t_long_id;
    l_file_type                 com_api_type_pkg.t_dict_value   := rcn_api_const_pkg.RECON_FILE_TYPE_SRVP;
    l_recon_type                com_api_type_pkg.t_dict_value   := rcn_api_const_pkg.RECON_TYPE_SRVP;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_container_id              com_api_type_pkg.t_long_id;
    l_process_id                com_api_type_pkg.t_short_id;
    l_session_id                com_api_type_pkg.t_long_id;

    cursor cu_rcn_srvp_msg is
        select m.id
          from rcn_srvp_msg m
         where m.recon_status = rcn_api_const_pkg.RECON_STATUS_REQ_RECON
           and m.inst_id = i_inst_id
           and (m.provider_id = i_service_provider_id or i_service_provider_id is null)
           and (m.purpose_id = i_purpose_id or i_purpose_id is null);

    cursor cur_xml is
        select
            xmlelement("reconciliation"
              , xmlattributes('http://sv.bpc.in/SVXP/reconciliation' as "xmlns")
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlelement("start_date", to_char(min(t.msg_date), com_api_const_pkg.XML_DATE_FORMAT))
              , xmlelement("end_date", to_char(max(t.msg_date), com_api_const_pkg.XML_DATE_FORMAT))
              , xmlelement("recon_type", l_recon_type)
              , xmlagg(
                    xmlelement("payment_order"
                      , xmlelement("order_id",   t.order_id)
                      , xmlelement("payment_order_number", t.payment_order_number)
                      , xmlelement("order_date",  to_char(t.order_date, com_api_const_pkg.XML_DATE_FORMAT))
                      , xmlelement("order_amount"
                          , xmlelement("amount_value", to_char(t.order_amount, com_api_const_pkg.XML_NUMBER_FORMAT))
                          , xmlelement("currency", t.order_currency)
                        )
                      , xmlelement("customer_number", t.customer_number)
                      , xmlelement("purpose_number", t.purpose_number)
                      , xmlelement("purpose_id", t.purpose_id)
                      , xmlelement("provider_number", t.provider_number)
                      , xmlelement("order_status", t.order_status)
                      , t.elem
                    )
                )
            ).getclobval()
            , count(1) as row_count
            from (
        select m.id
             , m.part_key
             , m.recon_type
             , m.msg_source
             , m.recon_status
             , m.msg_date
             , m.recon_date
             , m.inst_id
             , m.split_hash
             , m.order_id
             , m.recon_msg_id
             , m.payment_order_number
             , m.order_date
             , m.order_amount
             , m.order_currency
             , m.customer_id
             , m.customer_number
             , m.purpose_id
             , m.purpose_number
             , m.provider_id
             , m.provider_number
             , m.order_status
             , par.elem
          from rcn_srvp_msg m
             , (
                select xmlelement("parameter"
                        , xmlelement("param_name", pp.param_name)
                        , xmlelement("param_value"
                             , decode(
                               pp.param_name
                             , 'CARD_NUMBER'
                             , iss_api_token_pkg.decode_card_number(
                                   i_card_number =>
                                       iss_api_card_pkg.get_card_number(
                                           i_card_id => to_number(p.param_value, com_api_const_pkg.NUMBER_FORMAT)
                                       )
                               )
                             , 'INVOICE_MAD'
                             , to_char(to_number(p.param_value, com_api_const_pkg.NUMBER_FORMAT), com_api_const_pkg.XML_NUMBER_FORMAT)
                             , 'INVOICE_DUE_DATE'
                             , to_char(to_date(p.param_value, com_api_const_pkg.DATE_FORMAT), com_api_const_pkg.XML_DATETIME_FORMAT)
                             , p.param_value
                               )
                          )
                      ) elem
                     , p.msg_id
                  from rcn_srvp_data p
                     , pmo_parameter pp
                 where p.param_id = pp.id
                   and p.msg_id in (select column_value from table(cast(l_srvp_msg_id_tab as num_tab_tpt)))
               ) par
         where par.msg_id = m.id
           and m.id in (select column_value from table(cast(l_srvp_msg_id_tab as num_tab_tpt)))
        ) t;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count     := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name      := chr(13) || chr(10);
    begin
        if l_srvp_msg_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            l_estimated_count := l_estimated_count + l_srvp_msg_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');

            rul_api_param_pkg.set_param(
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;

            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

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
        else
            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
        end if;
    end;

    procedure update_export_status
    is
    begin
        forall i in 1 .. l_srvp_msg_id_tab.count save exceptions
            update rcn_srvp_msg m
               set m.recon_status = rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL
             where m.id = l_srvp_msg_id_tab(i);
    exception
       when com_api_error_pkg.e_dml_errors then
           for i in 1 .. sql%bulk_exceptions.count loop
                trc_log_pkg.debug(i_text =>
                    sql%bulk_exceptions (i).error_index || ': ' ||
                    sql%bulk_exceptions (i).error_code);
             end loop;
       when others then
             raise;
    end update_export_status;

begin

    l_container_id          := prc_api_session_pkg.get_container_id;
    l_process_id            := prc_api_session_pkg.get_process_id;
    l_session_id            := prc_api_session_pkg.get_session_id;

    trc_log_pkg.debug(LOG_PREFIX ||
        'Started, i_inst_id [' || i_inst_id ||
        '], i_service_provider_id [' || i_service_provider_id ||
        '], i_purpose_id [' || i_purpose_id ||
        '], i_count [' || i_count ||
        '], l_container_id [' || l_container_id ||
        '], l_process_id [' || l_process_id ||
        '], l_session_id [' || l_session_id ||
        ']'
    );

    prc_api_stat_pkg.log_start;

    open cu_rcn_srvp_msg;

    loop
        begin
            savepoint sp_srvp_msg_export;

            if i_count is null then
                fetch cu_rcn_srvp_msg
                 bulk collect into
                      l_srvp_msg_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || l_srvp_msg_id_tab.count || ']');

                if l_srvp_msg_id_tab.count > 0 then
                    generate_xml;
                    update_export_status;
                end if;
            else
                fetch cu_rcn_srvp_msg
                 bulk collect into l_incr_srvp_msg_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || l_incr_srvp_msg_id_tab.count || ']');

                for i in 1 .. l_incr_srvp_msg_id_tab.count loop
                    if (l_incr_srvp_msg_id_tab(i) != l_srvp_msg_id or l_srvp_msg_id is null)
                       and l_incr_srvp_msg_id_tab(i) is not null
                    then
                        l_srvp_msg_id := l_incr_srvp_msg_id_tab(i);

                        l_srvp_msg_id_tab.extend;

                        l_srvp_msg_id_tab(l_srvp_msg_id_tab.count) := l_incr_srvp_msg_id_tab(i);

                        if i = l_incr_srvp_msg_id_tab.count and l_srvp_msg_id_tab.count > 0 then
                            generate_xml;
                            update_export_status;
                            l_srvp_msg_id_tab.delete;
                        end if;
                    end if;
                end loop;
            end if;
        exception
            when others then
                rollback to sp_srvp_msg_export;
                raise;
        end;
        exit when cu_rcn_srvp_msg%notfound;
    end loop;
    close cu_rcn_srvp_msg;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
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
end process_srvp;

procedure process_host(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_count                 in     com_api_type_pkg.t_short_id   default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.process_host: ';
    l_bulk_limit                com_api_type_pkg.t_count        := nvl(i_count, BULK_LIMIT);
    l_host_msg_id_tab           num_tab_tpt                     := num_tab_tpt();
    l_incr_host_msg_id_tab      num_tab_tpt                     := num_tab_tpt();
    l_file                      clob;
    l_excepted_total            com_api_type_pkg.t_long_id      := 0;
    l_rejected_total            com_api_type_pkg.t_long_id      := 0;
    l_total_count               com_api_type_pkg.t_long_id      := 0;
    l_counter                   com_api_type_pkg.t_long_id      := 0;
    l_host_msg_id               com_api_type_pkg.t_long_id;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_container_id              com_api_type_pkg.t_long_id;
    l_process_id                com_api_type_pkg.t_short_id;
    l_session_id                com_api_type_pkg.t_long_id;
    l_fetched_count             com_api_type_pkg.t_long_id      := 0;
    l_params                    com_api_type_pkg.t_param_tab;
    l_iss_inst_id               com_api_type_pkg.t_inst_id;
    l_iss_host_id               com_api_type_pkg.t_tiny_id;
    l_iss_standard_id           com_api_type_pkg.t_tiny_id;
    l_iss_network_id            com_api_type_pkg.t_network_id;
    l_forw_inst_code            com_api_type_pkg.t_cmid;
    l_receiv_inst_code          com_api_type_pkg.t_cmid;
    l_forw_inst_code_tab        com_api_type_pkg.t_cmid_tab;
    l_rn_tab                    com_api_type_pkg.t_number_tab;

    cursor cu_rcn_host_msg(
        i_inst_id             in  com_api_type_pkg.t_inst_id
      , i_forw_inst_code      in  com_api_type_pkg.t_cmid
      , i_receiv_inst_code    in  com_api_type_pkg.t_cmid
    ) is
        select m.id
             , m.forw_inst_code
             , row_number() over(order by m.id) rn
          from rcn_host_msg m
         where m.receiv_inst_code   = i_receiv_inst_code
           and m.recon_status       = rcn_api_const_pkg.RECON_STATUS_REQ_RECON;

    cursor cu_host_xml(
        i_fin_msg_id_tab      in  num_tab_tpt
      , i_file_id             in  com_api_type_pkg.t_long_id
      , i_forw_inst_code      in  com_api_type_pkg.t_cmid
      , i_receiv_inst_code    in  com_api_type_pkg.t_cmid
    ) is
        select
            com_api_const_pkg.XML_HEADER ||
            xmlelement("reconciliation"
              , xmlattributes('http://bpc.ru/sv/SVXP/reconciliation' as "xmlns")
              , xmlelement("file_type",         rcn_api_const_pkg.RECON_FILE_TYPE_HOST)
              , xmlelement("file_date",         to_char(com_api_sttl_day_pkg.get_sysdate, com_api_const_pkg.XML_DATE_FORMAT))
              , xmlelement("forw_inst_id",      i_forw_inst_code)
              , xmlelement("receiv_inst_id",    i_receiv_inst_code)
              , xmlelement("file_id",           i_file_id)
              , xmlagg(
                    xmlconcat(
                        xmlsequencetype(
                            xmlelement("operation"
                              , xmlelement("oper_type",         fm.oper_type)
                              , xmlelement("msg_type",          fm.msg_type)
                              , xmlelement("oper_date",         fm.oper_date)
                              , xmlelement("oper_amount"
                                  , xmlelement("amount_value",  fm.oper_amount)
                                  , xmlelement("currency",      fm.oper_currency)
                                )
                              , nvl2(
                                    to_char(fm.oper_surcharge_amount)
                                  , xmlelement("oper_surcharge_amount"
                                      , xmlelement("amount_value",  fm.oper_surcharge_amount)
                                      , xmlelement("currency",      fm.oper_surcharge_currency)
                                    )
                                  , null
                                )
                              , nvl2(
                                    to_char(fm.oper_cashback_amount)
                                  , xmlelement("oper_cashback_amount"
                                      , xmlelement("amount_value",  fm.oper_cashback_amount)
                                      , xmlelement("currency",      fm.oper_cashback_currency)
                                    )
                                  , null
                                )
                              , xmlelement("is_reversal",       fm.is_reversal)
                              , xmlelement("merchant_number",   fm.merchant_number)
                              , xmlelement("mcc",               fm.mcc)
                              , xmlelement("merchant_name",     fm.merchant_name)
                              , nvl2(
                                    to_char(fm.terminal_number)
                                  , xmlelement("terminal_number",   fm.terminal_number)
                                  , null
                                )
                              , xmlelement("card_number",       fm.card_mask)
                              , xmlelement("approval_code",     fm.approval_code)
                              , xmlelement("rrn",               fm.rrn)
                              , xmlelement("trn",               fm.trn)
                              , xmlelement("oper_id",           fm.oper_id)
                              , xmlelement("original_id",       fm.original_id)
                              , xmlelement("emv_data"
                                  , nvl2(fm.emv_5f2a, xmlelement("tag_5f2a", fm.emv_5f2a), null)
                                  , nvl2(fm.emv_5f34, xmlelement("tag_5f34", fm.emv_5f34), null)
                                  , nvl2(fm.emv_71,   xmlelement("tag_71",   fm.emv_71),   null)
                                  , nvl2(fm.emv_72,   xmlelement("tag_72",   fm.emv_72),   null)
                                  , nvl2(fm.emv_82,   xmlelement("tag_82",   fm.emv_82),   null)
                                  , nvl2(fm.emv_84,   xmlelement("tag_84",   fm.emv_84),   null)
                                  , nvl2(fm.emv_8a,   xmlelement("tag_8a",   fm.emv_8a),   null)
                                  , nvl2(fm.emv_91,   xmlelement("tag_91",   fm.emv_91),   null)
                                  , nvl2(fm.emv_95,   xmlelement("tag_95",   fm.emv_95),   null)
                                  , nvl2(fm.emv_9a,   xmlelement("tag_9a",   fm.emv_9a),   null)
                                  , nvl2(fm.emv_9c,   xmlelement("tag_9c",   fm.emv_9c),   null)
                                  , nvl2(fm.emv_9f02, xmlelement("tag_9f02", fm.emv_9f02), null)
                                  , nvl2(fm.emv_9f03, xmlelement("tag_9f03", fm.emv_9f03), null)
                                  , nvl2(fm.emv_9f06, xmlelement("tag_9f06", fm.emv_9f06), null)
                                  , nvl2(fm.emv_9f09, xmlelement("tag_9f09", fm.emv_9f09), null)
                                  , nvl2(fm.emv_9f10, xmlelement("tag_9f10", fm.emv_9f10), null)
                                  , nvl2(fm.emv_9f18, xmlelement("tag_9f18", fm.emv_9f18), null)
                                  , nvl2(fm.emv_9f1a, xmlelement("tag_9f1a", fm.emv_9f1a), null)
                                  , nvl2(fm.emv_9f1e, xmlelement("tag_9f1e", fm.emv_9f1e), null)
                                  , nvl2(fm.emv_9f26, xmlelement("tag_9f26", fm.emv_9f26), null)
                                  , nvl2(fm.emv_9f27, xmlelement("tag_9f27", fm.emv_9f27), null)
                                  , nvl2(fm.emv_9f28, xmlelement("tag_9f28", fm.emv_9f28), null)
                                  , nvl2(fm.emv_9f29, xmlelement("tag_9f29", fm.emv_9f29), null)
                                  , nvl2(fm.emv_9f33, xmlelement("tag_9f33", fm.emv_9f33), null)
                                  , nvl2(fm.emv_9f34, xmlelement("tag_9f34", fm.emv_9f34), null)
                                  , nvl2(fm.emv_9f35, xmlelement("tag_9f35", fm.emv_9f35), null)
                                  , nvl2(fm.emv_9f36, xmlelement("tag_9f36", fm.emv_9f36), null)
                                  , nvl2(fm.emv_9f37, xmlelement("tag_9f37", fm.emv_9f37), null)
                                  , nvl2(fm.emv_9f41, xmlelement("tag_9f41", fm.emv_9f41), null)
                                  , nvl2(fm.emv_9f53, xmlelement("tag_9f53", fm.emv_9f53), null)
                                )
                              , xmlelement("pdc"
                                  , xmlelement("pdc_1",  substr(fm.pdc_1,  -1, 1))
                                  , xmlelement("pdc_2",  substr(fm.pdc_2,  -1, 1))
                                  , xmlelement("pdc_3",  substr(fm.pdc_3,  -1, 1))
                                  , xmlelement("pdc_4",  substr(fm.pdc_4,  -1, 1))
                                  , xmlelement("pdc_5",  substr(fm.pdc_5,  -1, 1))
                                  , xmlelement("pdc_6",  substr(fm.pdc_6,  -1, 1))
                                  , xmlelement("pdc_7",  substr(fm.pdc_7,  -1, 1))
                                  , xmlelement("pdc_8",  substr(fm.pdc_8,  -1, 1))
                                  , xmlelement("pdc_9",  substr(fm.pdc_9,  -1, 1))
                                  , xmlelement("pdc_10", substr(fm.pdc_10, -1, 1))
                                  , xmlelement("pdc_11", substr(fm.pdc_11, -1, 1))
                                  , xmlelement("pdc_12", substr(fm.pdc_12, -1, 1))
                                )
                            )
                        )
                    )
                )
            ).getclobval()
        from rcn_host_msg fm
        where fm.id in (select column_value from table(cast(i_fin_msg_id_tab as num_tab_tpt)));

    procedure generate_xml is
    begin
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_fetched_count
        );
        trc_log_pkg.debug('Estimated count of records is [' || l_fetched_count || ']');

        if l_host_msg_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');

            rul_api_param_pkg.set_param(
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );

            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => rcn_api_const_pkg.RECON_FILE_TYPE_HOST
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            open cu_host_xml(
                i_fin_msg_id_tab        => l_host_msg_id_tab
              , i_file_id               => l_session_file_id
              , i_forw_inst_code        => l_forw_inst_code
              , i_receiv_inst_code      => l_receiv_inst_code
            );

            fetch cu_host_xml into l_file;
            close cu_host_xml;

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

procedure update_host_msg_status(
    i_msg_id_tab           in num_tab_tpt
  , i_status                    in com_api_type_pkg.t_dict_value    default null
) is
begin
    trc_log_pkg.debug(i_text => 'Update status: records count = ' || i_msg_id_tab.count || ', status = ' || i_status);

    forall i in 1 .. i_msg_id_tab.count save exceptions
        update rcn_host_msg m
           set m.recon_status = nvl(i_status, rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL)
         where m.id = i_msg_id_tab(i);

exception
    when com_api_error_pkg.e_dml_errors then
        for i in 1 .. sql%bulk_exceptions.count loop
            trc_log_pkg.debug(
                i_text => sql%bulk_exceptions (i).error_index || ': ' || sql%bulk_exceptions (i).error_code
            );
        end loop;
    when others then
        raise;
end update_host_msg_status;

begin
    prc_api_stat_pkg.log_start;

    l_container_id          := prc_api_session_pkg.get_container_id;
    l_process_id            := prc_api_session_pkg.get_process_id;
    l_session_id            := prc_api_session_pkg.get_session_id;

    trc_log_pkg.debug(
        LOG_PREFIX ||
        'Started, i_inst_id [' || i_inst_id ||
        '], l_container_id [' || l_container_id ||
        '], l_process_id [' || l_process_id ||
        '], l_session_id [' || l_session_id ||
        ']'
    );

    if      i_inst_id = ost_api_const_pkg.DEFAULT_INST 
        or  i_inst_id = ost_api_const_pkg.UNIDENTIFIED_INST
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INSTITUTION_IS_NOT_DEFINED'
          , i_env_param1 => i_inst_id
        );
    end if;

    l_iss_inst_id   := i_inst_id;

    l_iss_network_id :=
        ost_api_institution_pkg.get_inst_network(
            i_inst_id   => l_iss_inst_id
        );

    l_iss_host_id           :=
        net_api_network_pkg.get_host_id(
            i_inst_id       => l_iss_inst_id
          , i_network_id    => l_iss_network_id
        );

    l_iss_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id       => l_iss_host_id
        );

    l_receiv_inst_code :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_iss_inst_id
          , i_standard_id   => l_iss_standard_id
          , i_object_id     => l_iss_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => h2h_api_const_pkg.H2H_INST_CODE
          , i_param_tab     => l_params
        );

    if l_receiv_inst_code is null then
        com_api_error_pkg.raise_error(
            i_error         => 'STANDARD_PARAM_NOT_FOUND'
          , i_env_param1    => h2h_api_const_pkg.H2H_INST_CODE
          , i_env_param2    => l_iss_inst_id
          , i_env_param3    => l_iss_standard_id
          , i_env_param4    => l_iss_host_id
        );
    end if;

    trc_log_pkg.debug(
        LOG_PREFIX ||
        'l_iss_inst_id [' || l_iss_inst_id ||
        '], l_network_id [' || l_iss_network_id ||
        '], l_host_id [' || l_iss_host_id ||
        '], l_standard_id [' || l_iss_standard_id ||
        '], l_receiv_inst_code [' || l_receiv_inst_code ||
        ']'
    );

    open cu_rcn_host_msg(
        i_inst_id             => null
      , i_forw_inst_code      => null
      , i_receiv_inst_code    => l_receiv_inst_code
    );

    loop
        begin
            savepoint sp_host_msg_export;

            if i_count is null then
                fetch cu_rcn_host_msg
                 bulk collect into
                    l_host_msg_id_tab
                  , l_forw_inst_code_tab
                  , l_rn_tab
                limit l_bulk_limit;

                if l_rn_tab.exists(1) and l_rn_tab(1) = 1 then
                    l_forw_inst_code := l_forw_inst_code_tab(1);

                    trc_log_pkg.debug(
                        i_text          => LOG_PREFIX || 'Outgoing forward inst code [#1], receiver inst code [#2]'
                      , i_env_param1    => l_forw_inst_code
                      , i_env_param2    => l_receiv_inst_code
                    );
                end if;

                l_fetched_count := l_host_msg_id_tab.count;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || l_fetched_count || ']');

                if l_host_msg_id_tab.count > 0 then
                    generate_xml;

                    update_host_msg_status(
                        i_msg_id_tab    => l_host_msg_id_tab
                      , i_status        => rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL
                    );

                end if;
            else
                l_forw_inst_code_tab.delete;
                l_rn_tab.delete;

                fetch cu_rcn_host_msg
                 bulk collect into
                    l_incr_host_msg_id_tab
                  , l_forw_inst_code_tab
                  , l_rn_tab
                limit l_bulk_limit;

                if l_rn_tab.exists(1) and l_rn_tab(1) = 1 then
                    l_forw_inst_code := l_forw_inst_code_tab(1);

                    trc_log_pkg.debug(
                        i_text          => LOG_PREFIX || 'Outgoing forward inst code [#1], receiver inst code [#2]'
                      , i_env_param1    => l_forw_inst_code
                      , i_env_param2    => l_receiv_inst_code
                    );
                end if;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || l_incr_host_msg_id_tab.count || ']');

                for i in 1 .. l_incr_host_msg_id_tab.count loop
                    if (l_incr_host_msg_id_tab(i) != l_host_msg_id or l_host_msg_id is null)
                       and l_incr_host_msg_id_tab(i) is not null
                    then
                        l_host_msg_id := l_incr_host_msg_id_tab(i);

                        l_host_msg_id_tab.extend;

                        l_host_msg_id_tab(l_host_msg_id_tab.count) := l_incr_host_msg_id_tab(i);

                        if i = l_incr_host_msg_id_tab.count and l_host_msg_id_tab.count > 0 then

                            l_fetched_count := l_host_msg_id_tab.count;

                            generate_xml;

                            update_host_msg_status(
                                i_msg_id_tab    => l_host_msg_id_tab
                              , i_status        => rcn_api_const_pkg.RECON_STATUS_SUCCESSFULL
                            );

                            l_host_msg_id_tab.delete;
                        end if;
                    end if;
                end loop;
            end if;
        exception
            when others then
                rollback to sp_host_msg_export;
                raise;
        end;
        exit when cu_rcn_host_msg%notfound;
    end loop;

    close cu_rcn_host_msg;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_total_count
      , i_excepted_total    => l_excepted_total
      , i_rejected_total    => l_rejected_total
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_processed_total   => l_total_count
          , i_excepted_total    => l_excepted_total
          , i_rejected_total    => l_rejected_total
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
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
end process_host;

end rcn_prc_export_pkg;
/
