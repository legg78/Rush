create or replace package body cst_bmed_prc_outgoing_pkg as

CRLF                     constant  com_api_type_pkg.t_name       := chr(13)||chr(10);
ISSUING_RATE_TYPE        constant  com_api_type_pkg.t_dict_value := 'RTTPISS';

function format_exchange_rate(
    i_rate                 in      number
) return com_api_type_pkg.t_exponent
is
    l_str                          com_api_type_pkg.t_exponent;
    l_index                        com_api_type_pkg.t_tiny_id;
    l_result                       com_api_type_pkg.t_exponent;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.format_exchange_rate(#1, #2)'
      , i_env_param1 => i_rate
    );

    l_str   := substr(trim(to_char(i_rate, '9999999.0000000', 'NLS_NUMERIC_CHARACTERS = ''.,''')), 1, 8);
    l_index := instr(com_api_type_pkg.reverse_value(i_value => l_str), '.') - 1;

    -- Convert number to specific string representation. Example: 1557.286 => 31557286
    l_result := to_char(l_index) || substr(l_str, 1, instr(l_str, '.') - 1) || substr(l_str, instr(l_str, '.') + 1);

    return l_result;
end;

function check_order(
    i_order_id              in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
begin
    for tab in (
        select o.id
             , o.attempt_count as order_attempt_count
             , t.attempt_limit as template_attempt_count
          from pmo_order o
          join pmo_schedule t
            on t.order_id = o.template_id
           and o.attempt_count >= t.attempt_limit
         where o.id = i_order_id
    )
    loop
        trc_log_pkg.debug('cst_bmed_prc_outgoing_pkg.check_order: order attempt ' || tab.order_attempt_count || ' while template attempts ' || tab.template_attempt_count || ' are allowed');
        return com_api_const_pkg.FALSE;
    end loop;
    return com_api_const_pkg.TRUE;
end;

procedure process_export_cbs(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
) is
    l_sysdate                      date;
    l_order_count                  com_api_type_pkg.t_long_id;
    l_order_list_tab               cst_bmed_type_pkg.t_order_evt_list_tab;
    l_order_list_cur               cst_bmed_type_pkg.t_order_evt_list_cur;
    l_order_parameters_cur         cst_bmed_type_pkg.t_order_parameters_cur;
    l_order_parameters_tab         cst_bmed_type_pkg.t_order_parameters_tab;
    l_invoice_rec                  crd_api_type_pkg.t_invoice_rec;
    l_order_amount                 com_api_type_pkg.t_amount_rec;

    l_record                       com_api_type_pkg.t_text;
    l_param_tab                    com_api_type_pkg.t_param_tab;

    l_session_file_id              com_api_type_pkg.t_long_id;
    l_is_insert_record             com_api_type_pkg.t_boolean;
    l_currency_name                com_api_type_pkg.t_curr_name;
    l_currency_exponent            com_api_type_pkg.t_tiny_id;
    l_iban                         com_api_type_pkg.t_name;
    l_card_number                  com_api_type_pkg.t_card_number;
    l_cardholder_name              com_api_type_pkg.t_name;
    l_account_number               com_api_type_pkg.t_account_number;
    l_agent_number                 com_api_type_pkg.t_name;
    l_card_id                      com_api_type_pkg.t_medium_id;
    l_cardholder_id                com_api_type_pkg.t_medium_id;

    l_processed_count              com_api_type_pkg.t_count := 0;
    l_excepted_count               com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug('cst_bmed_prc_outgoing_pkg.process_export_cbs - started.');

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    prc_api_stat_pkg.log_start;

    pmo_api_order_pkg.get_order_evt_list_count(
        i_inst_id               => i_inst_id
      , i_subscriber_name       => 'CST_BMED_PRC_OUTGOING_PKG.PROCESS_EXPORT_CBS'
      , i_event_type            => pmo_api_const_pkg.EVENT_TYPE_PAY_ORDER_CREATE
      , i_purpose_id            => i_purpose_id
      , o_order_evt_list_count  => l_order_count
    );

    if l_order_count > 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params       => l_param_tab
        );
        pmo_api_order_pkg.get_order_evt_list(
            i_inst_id               => i_inst_id
          , i_subscriber_name       => 'CST_BMED_PRC_OUTGOING_PKG.PROCESS_EXPORT_CBS'
          , i_event_type            => pmo_api_const_pkg.EVENT_TYPE_PAY_ORDER_CREATE
          , i_purpose_id            => i_purpose_id
          , o_order_evt_list        => l_order_list_cur
        );

        fetch l_order_list_cur bulk collect into l_order_list_tab;

        for i in 1..l_order_list_tab.count loop
            trc_log_pkg.debug('cst_bmed_prc_outgoing_pkg.process_export_cbs [' || l_order_list_tab(i).attempt_count || '] attempts for ' || l_order_list_tab(i).order_id);
            if check_order(l_order_list_tab(i).order_id) = com_api_const_pkg.TRUE then

                l_invoice_rec := crd_invoice_pkg.get_last_invoice(
                                     i_entity_type       => l_order_list_tab(i).entity_type
                                   , i_object_id         => l_order_list_tab(i).object_id
                                   , i_split_hash        => l_order_list_tab(i).split_hash
                                   , i_mask_error        => com_api_const_pkg.TRUE
                                 );
                pmo_api_order_pkg.get_order_parameters(
                    i_order_id              => l_order_list_tab(i).order_id
                  , o_order_parameters      => l_order_parameters_cur
                );
                l_iban := null;
                fetch l_order_parameters_cur bulk collect into l_order_parameters_tab;
                if l_order_parameters_tab.count > 0 then
                    for p in 1..l_order_parameters_tab.count loop
                        if l_order_parameters_tab(p).param_name = 'BMED_IBAN' then
                            l_iban := l_order_parameters_tab(p).param_value;
                            exit;
                        end if;
                    end loop;
                end if;

                if l_order_list_tab(i).attempt_count = 0 then
                    pmo_api_order_pkg.set_attempt_count(
                        i_order_id              => l_order_list_tab(i).order_id
                      , i_attempt_count         => 1
                    );
                    l_is_insert_record := com_api_const_pkg.TRUE;
                else
                    pmo_api_order_pkg.calc_order_amount(
                        i_amount_algorithm      => l_order_list_tab(i).amount_algorithm
                      , i_entity_type           => l_order_list_tab(i).entity_type
                      , i_object_id             => l_order_list_tab(i).object_id
                      , i_eff_date              => l_sysdate
                      , i_template_id           => l_order_list_tab(i).template_id
                      , i_split_hash            => l_order_list_tab(i).split_hash
                      , i_order_id              => l_order_list_tab(i).order_id
                      , io_amount               => l_order_amount
                    );
                    if l_order_amount.amount = 0 then
                        pmo_api_order_pkg.set_order_status(
                            i_order_id              => l_order_list_tab(i).order_id
                          , i_status                => pmo_api_const_pkg.PMO_STATUS_PROCESSED
                        );
                        evt_api_event_pkg.process_event_object(
                            i_event_object_id       => l_order_list_tab(i).id
                        );
                        l_is_insert_record           := com_api_const_pkg.FALSE;
                    else
                        pmo_api_order_pkg.set_attempt_count(
                            i_order_id              => l_order_list_tab(i).order_id
                          , i_attempt_count         => l_order_list_tab(i).attempt_count + 1
                        );
                        pmo_api_order_pkg.set_order_amount(
                            i_order_id              => l_order_list_tab(i).order_id
                          , i_amount_rec            => l_order_amount
                        );
                        l_order_list_tab(i).amount   := l_order_amount.amount;
                        l_order_list_tab(i).currency := l_order_amount.currency;
                        l_is_insert_record           := com_api_const_pkg.TRUE;
                    end if;
                end if;

                if l_is_insert_record = com_api_const_pkg.TRUE then
                    begin
                        select name
                             , exponent
                          into l_currency_name
                             , l_currency_exponent
                          from com_currency
                         where code = l_order_list_tab(i).currency;
                    exception
                        when no_data_found then
                            l_currency_name := 'UNK';
                            l_currency_exponent := 0;
                    end;

                    begin
                        select card_id
                             , cardholder_id
                             , account_number
                             , agent_number
                          into l_card_id
                             , l_cardholder_id
                             , l_account_number
                             , l_agent_number
                          from (
                              select c.id as card_id
                                   , c.cardholder_id
                                   , a.account_number
                                   , ag.agent_number
                                from iss_card           c
                                   , iss_card_instance  i
                                   , acc_account_object o
                                   , acc_account        a
                                   , ost_agent          ag
                               where a.id          = l_invoice_rec.account_id
                                 and ag.id         = a.agent_id
                                 and o.account_id  = a.id
                                 and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                 and c.id          = o.object_id
                                 and i.card_id     = c.id
                                 and i.state       = iss_api_const_pkg.CARD_STATE_ACTIVE
                               order by decode(c.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1)
                          )
                         where rownum = 1;
                    exception
                        when no_data_found then
                            l_card_number     := ' ';
                            l_cardholder_name := ' ';
                            l_account_number  := ' ';
                            l_agent_number    := ' ';
                    end;

                    l_record := rpad(iss_api_card_pkg.get_card_number(l_card_id), 25);
                    l_record := l_record || rpad(iss_api_cardholder_pkg.get_cardholder_name(l_cardholder_id), 30);
                    l_record := l_record || rpad(l_agent_number,   21);
                    l_record := l_record || rpad(l_account_number, 20);
                    l_record := l_record || 'DB';
                    l_record := l_record || l_currency_name;
                    l_record := l_record || lpad(to_char(l_order_list_tab(i).amount, com_api_const_pkg.XML_NUMBER_FORMAT), 12, '0');
                    l_record := l_record || to_char(l_currency_exponent, 'FM0');
                    l_record := l_record || to_char(l_order_list_tab(i).event_date, 'yyyymmdd');
                    l_record := l_record || rpad(l_card_number, 25);
                    l_record := l_record || rpad(substr(to_char(l_invoice_rec.id), 1, 10), 10);
                    l_record := l_record || rpad(' ', 20);
                    l_record := l_record || rpad(l_iban, 34);
                    l_record := l_record || rpad(l_account_number, 25);
                    l_record := l_record || rpad(' ', 2);

                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_record
                      , i_sess_file_id  => l_session_file_id
                    );
                    prc_api_file_pkg.put_file(
                        i_sess_file_id   => l_session_file_id
                      , i_clob_content   => l_record || CRLF
                      , i_add_to         => com_api_const_pkg.TRUE
                    );
                    l_processed_count := l_processed_count + 1;
                else
                    l_excepted_count  := l_excepted_count + 1;
                end if;

                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_processed_count
                      , i_excepted_count => l_excepted_count
                    );
                end if;
            else
                trc_log_pkg.debug('cst_bmed_prc_outgoing_pkg.process_export_cbs order ' || l_order_list_tab(i).order_id || ' is eceeded attemps and marked and not paid');
                -- validation is failed, mark order as cancelled and mark event object as processed
                evt_api_event_pkg.process_event_object(
                    i_event_object_id       => l_order_list_tab(i).id
                );
                pmo_api_order_pkg.set_order_status(
                    i_order_id              => l_order_list_tab(i).order_id
                  , i_status                => pmo_api_const_pkg.PMO_STATUS_NOT_PAID
                );
            end if;
        end loop;
        prc_api_file_pkg.close_file(
            i_sess_file_id      => l_session_file_id
          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count   => l_processed_count + l_excepted_count
    );
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('cst_bmed_prc_outgoing_pkg.process_export_cbs - end.');
end process_export_cbs;

procedure process_export_rtgs(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
) is
    l_sysdate                      date;
    l_order_count                  com_api_type_pkg.t_long_id;
    l_order_list_tab               cst_bmed_type_pkg.t_order_list_tab;
    l_order_list_cur               cst_bmed_type_pkg.t_order_list_cur;
    l_order_parameters_cur         cst_bmed_type_pkg.t_order_parameters_cur;
    l_order_parameters_tab         cst_bmed_type_pkg.t_order_parameters_tab;

    l_record                       com_api_type_pkg.t_text;
    l_param_tab                    com_api_type_pkg.t_param_tab;

    l_session_file_id              com_api_type_pkg.t_long_id;
    l_iban                         com_api_type_pkg.t_name;
    l_cardholder_name              com_api_type_pkg.t_name;
    l_account_number               com_api_type_pkg.t_account_number;
    l_processed_count              com_api_type_pkg.t_long_id    := 0;
    l_excepted_count               com_api_type_pkg.t_long_id    := 0;
begin
    trc_log_pkg.debug('cst_bmed_prc_outgoing_pkg.process_export_rtgs - started.');

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    prc_api_stat_pkg.log_start;

    pmo_api_order_pkg.get_order_list_count(
        i_inst_id               => i_inst_id
      , i_purpose_id            => i_purpose_id
      , i_status                => pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
      , o_order_list_count      => l_order_count
    );

    if l_order_count > 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params       => l_param_tab
        );
        pmo_api_order_pkg.get_order_list(
            i_inst_id               => i_inst_id
          , i_purpose_id            => i_purpose_id
          , i_status                => pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
          , o_order_list            => l_order_list_cur
        );

        fetch l_order_list_cur bulk collect into l_order_list_tab;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count       => l_order_list_tab.count
        );

        for i in 1..l_order_list_tab.count loop
            pmo_api_order_pkg.get_order_parameters(
                i_order_id              => l_order_list_tab(i).id
              , o_order_parameters      => l_order_parameters_cur
            );
            l_iban := null;
            fetch l_order_parameters_cur bulk collect into l_order_parameters_tab;
            if l_order_parameters_tab.count > 0 then
                for p in 1..l_order_parameters_tab.count loop
                    if l_order_parameters_tab(p).param_name = 'BMED_IBAN' then
                        l_iban := l_order_parameters_tab(p).param_value;
                        exit;
                    end if;
                end loop;
            end if;

            l_record := rpad(' ', 3);
            l_record := l_record || rpad(l_account_number, 13);
            l_record := l_record || ' 28 +';
            l_record := l_record || lpad(to_char(l_order_list_tab(i).amount, com_api_const_pkg.XML_NUMBER_FORMAT), 15, '0');
            l_record := l_record || ' ';
            l_record := l_record || to_char(l_order_list_tab(i).event_date, 'ddmmyyyy');
            l_record := l_record || ' ';
            l_record := l_record || to_char(l_order_list_tab(i).event_date, 'ddmmyyyy');
            l_record := l_record || ' +000000000000000 0EDCCOLL01 ';
            l_record := l_record || rpad(l_cardholder_name, 26);
            l_record := l_record || ' ';
            l_record := l_record || rpad(l_iban, 28);
            l_record := l_record || ' OTHER BANKS ';
            l_record := l_record || to_char(l_order_list_tab(i).event_date, 'ddmmyyyy');
            l_record := l_record || ' 0';

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id   => l_session_file_id
              , i_clob_content   => l_record || CRLF
              , i_add_to         => com_api_const_pkg.TRUE
            );
            pmo_api_order_pkg.set_order_status(
                i_order_id              => l_order_list_tab(i).id
              , i_status                => pmo_api_const_pkg.PMO_STATUS_PROCESSED
            );
            for eo in (select a.id
                         from evt_event_object a
                            , pmo_order        o
                        where decode(a.status, 'EVST0001', a.procedure_name, null) = 'CST_BMED_PRC_OUTGOING_PKG.PROCESS_EXPORT_RTGS'
                          and o.id              = l_order_list_tab(i).id
                          and a.object_id       = o.id
                          and a.entity_type     = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                          and a.eff_date       <= l_sysdate)
            loop
                evt_api_event_pkg.process_event_object(
                    i_event_object_id       => eo.id
                );
            end loop;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count  => l_processed_count
                  , i_excepted_count => l_excepted_count
                );
            end if;
        end loop;
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('cst_bmed_prc_outgoing_pkg.process_export_rtgs - end.');
end process_export_rtgs;

procedure generate_posinp_file(
    i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_national_merchant_only  in     com_api_type_pkg.t_boolean
  , i_posinp_array_id         in     com_api_type_pkg.t_short_id
) as
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_posinp_file: ';
    LEBANON_CODE                     com_api_type_pkg.t_country_code := '422';

    l_national_merchant_only         com_api_type_pkg.t_boolean      := nvl(i_national_merchant_only, com_api_const_pkg.TRUE);
    l_estimated_count                com_api_type_pkg.t_long_id      := 0;
    l_processed_count                com_api_type_pkg.t_long_id      := 0;
    l_excepted_count                 com_api_type_pkg.t_long_id      := 0;
    l_params                         com_api_type_pkg.t_param_tab;
    l_session_file_id                com_api_type_pkg.t_long_id;
    l_line                           com_api_type_pkg.t_text;
    l_trans_type                     com_api_type_pkg.t_name;
    l_rate                           com_api_type_pkg.t_rate;
    l_amount                         com_api_type_pkg.t_money;
    l_elements                       com_api_type_pkg.t_array_element_tab;
    l_dict_elements                  com_dict_tpt := com_dict_tpt();

    l_account_amount                 com_api_type_pkg.t_money;
    l_account_currency               com_api_type_pkg.t_curr_code;
    l_oper_amount                    com_api_type_pkg.t_money;
    l_oper_currency                  com_api_type_pkg.t_curr_code;
    l_currency                       com_api_type_pkg.t_curr_code;
    l_card_number                    com_api_type_pkg.t_card_number;
    l_sttl_amount                    com_api_type_pkg.t_money;
    l_fee_amount                     com_api_type_pkg.t_money;
    l_fee_currency                   com_api_type_pkg.t_curr_code;
begin
    savepoint sp_posinp_file;

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'Start'
    );

    prc_api_stat_pkg.log_start;

    l_elements   := com_api_array_pkg.get_elements(i_array_id => cst_bmed_api_const_pkg.POSINP_OPER_ARRAY_ID);

    if l_elements.count > 0 then
        for i in 1..l_elements.count loop
            l_dict_elements.extend;
            l_dict_elements(l_dict_elements.count) := l_elements(i).element_value;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text        => ' l_elements.count = ' || l_elements.count
    );

    select count(*)
      into l_estimated_count
      from evt_event_object eo
         , opr_operation o
         , vis_fin_message m
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_BMED_PRC_OUTGOING_PKG.GENERATE_POSINP_FILE'
       and eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and o.id           = eo.object_id
       and o.oper_type in (select column_value from table(cast(l_dict_elements as com_dict_tpt)))
       and (
               (l_national_merchant_only = com_api_const_pkg.TRUE  and o.merchant_country  = LEBANON_CODE)
               or
               (l_national_merchant_only = com_api_const_pkg.FALSE and o.merchant_country != LEBANON_CODE)
           )
       and m.id           = o.id + 0
       and m.is_invalid   = com_api_const_pkg.FALSE
       and m.status       = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
       and m.inst_id      = i_inst_id;

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'l_estimated_count [#1]'
      , i_env_param1      => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    for r in (
        select eo.id as eo_id
             , m.id
             , m.collect_only_flag
             , m.is_reversal
             , c.card_number  -- will be decode in begin of loop cycle
             , (select a.host_date from opr_operation a where a.id = o.match_id) as host_date
             , o.oper_date
             , o.oper_type
             , o.oper_amount
             , o.oper_currency
             , o.merchant_country
             , o.merchant_name
             , o.merchant_city
             , o.merchant_number
             , o.terminal_number
             , p.account_number
             , p.account_currency
             , p.account_amount
             , p.auth_code
             , o.acq_inst_bin
             , (select a.external_auth_id from aut_auth a where a.id = o.match_id) as external_auth_id
             , o.mcc
             , o.sttl_amount
             , o.sttl_currency
          from vis_fin_message m
             , vis_card c
             , opr_operation o
             , opr_participant p
             , evt_event_object eo
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_BMED_PRC_OUTGOING_PKG.GENERATE_POSINP_FILE'
           and eo.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.id               = eo.object_id
           and o.oper_type in (select column_value from table(cast(l_dict_elements as com_dict_tpt)))
           and (
                   (l_national_merchant_only = com_api_const_pkg.TRUE  and o.merchant_country  = LEBANON_CODE)
                   or
                   (l_national_merchant_only = com_api_const_pkg.FALSE and o.merchant_country != LEBANON_CODE)
               )
           and m.id               = o.id + 0
           and m.is_invalid       = com_api_const_pkg.FALSE
           and m.status           = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
           and m.inst_id          = i_inst_id
           and p.oper_id          = m.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and c.id               = p.oper_id
    )
    loop
        if l_session_file_id is null then
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_session_file_id
              , io_params       => l_params
            );
        end if;

        l_trans_type :=
            com_api_array_pkg.conv_array_elem_v(
                i_array_type_id  => cst_bmed_api_const_pkg.POSINP_OPER_ARRAY_TYPE_ID
              , i_array_id       => cst_bmed_api_const_pkg.POSINP_OPER_ARRAY_ID
              , i_elem_value     => r.oper_type
              , i_mask_error     => com_api_type_pkg.FALSE
            );

        l_card_number := iss_api_token_pkg.decode_card_number(i_card_number => r.card_number);
        l_card_number := case when length(l_card_number) < 19 
                              then rpad(substr(l_card_number, 7, 10), 13, '0')
                              else substr(l_card_number, 7, 13)
                         end;

        opr_api_additional_amount_pkg.get_amount(
            i_oper_id     => r.id
          , i_amount_type => com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT
          , o_amount      => l_account_amount
          , o_currency    => l_account_currency
        );
        if l_account_currency = cst_bmed_csc_const_pkg.CURRENCY_CODE_LEBANESE_POUND then
            l_account_amount := round(l_account_amount / power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => l_account_currency)), 0);
        else
            l_account_amount := round(l_account_amount, 0);
        end if;
        
        -- Getting fee amount
        select sum(m.amount)
             , max(m.currency)
          into l_fee_amount
             , l_fee_currency
          from acc_macros m
         where m.object_id                    = r.id
           and m.entity_type                  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and substr(m.amount_purpose, 1, 4) = fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
           and com_api_array_pkg.is_element_in_array(
                   i_array_id            => i_posinp_array_id
                 , i_elem_value          => m.amount_purpose  
               ) = com_api_const_pkg.TRUE;

        trc_log_pkg.debug(
            i_text        => ' fee_amount = ' || round(nvl(l_fee_amount, 0), 0) || ' fee_currency = ' || l_fee_currency
        );
           
        if l_fee_currency is not null and l_fee_currency = cst_bmed_csc_const_pkg.CURRENCY_CODE_LEBANESE_POUND then
            l_fee_amount := round(l_fee_amount / power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => l_fee_currency)), 0);
        else
            l_fee_amount := round(nvl(l_fee_amount, 0), 0);
        end if;

        opr_api_additional_amount_pkg.get_amount(
            i_oper_id     => r.id
          , i_amount_type => com_api_const_pkg.AMOUNT_PURPOSE_OPER_ACTUAL
          , o_amount      => l_oper_amount
          , o_currency    => l_oper_currency
        );
        if l_oper_currency = cst_bmed_csc_const_pkg.CURRENCY_CODE_LEBANESE_POUND then
            l_oper_amount := round(l_oper_amount / power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => l_oper_currency)), 0);
        else
            l_oper_amount := round(l_oper_amount, 0);
        end if;

        opr_api_additional_amount_pkg.get_amount(
            i_oper_id     => r.id
          , i_amount_type => com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT
          , o_amount      => l_amount
          , o_currency    => l_currency
        );

        l_amount :=
            round(
                com_api_rate_pkg.convert_amount(
                    i_src_amount      => l_amount
                  , i_src_currency    => l_currency
                  , i_dst_currency    => cst_bmed_csc_const_pkg.CURRENCY_CODE_LEBANESE_POUND
                  , i_rate_type       => ISSUING_RATE_TYPE
                  , i_inst_id         => i_inst_id
                  , i_eff_date        => nvl(r.host_date, r.oper_date)
                )
            );
        l_amount := round(l_amount / power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => l_currency)), 0);

        if r.sttl_amount is not null then
            if r.sttl_currency = cst_bmed_csc_const_pkg.CURRENCY_CODE_LEBANESE_POUND then
                l_sttl_amount := round(r.sttl_amount / power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => r.sttl_currency)), 0);
            else
                l_sttl_amount := round(r.sttl_amount, 0);
            end if;
        else
            l_sttl_amount := null;
        end if;

        if l_sttl_amount is not null then
            l_rate := l_sttl_amount / l_oper_amount;
        else
            com_api_error_pkg.raise_error(
                i_error       => 'CST_STTL_AMOUNT_IS_EMPTY'
              , i_env_param1  => l_sttl_amount
            );
        end if;

        l_line := '';
        l_line := l_line || '0';                                                         -- dest_mailbox; pos 1 - 1  
        l_line := l_line || '678901';                                                    -- src_imd; pos 2 - 7  
        l_line := l_line || lpad(nvl(r.merchant_country, ' '), 3);                       -- src_country_code ; pos 8 - 10  
        l_line := l_line || '0001';                                                      -- src_branch_code ; pos 11 - 14  
        l_line := l_line || '0000';                                                      -- device_id; pos 15 - 18  
        l_line := l_line || lpad(nvl(substr(r.external_auth_id, -4), ' '), 4);           -- trx_seq_nbr; pos 19 - 22  
        l_line := l_line || case when r.is_reversal = com_api_const_pkg.FALSE then 6 else 7 end;    -- msg_type; pos 23 - 23  
        l_line := l_line || lpad(nvl(l_trans_type, ' '), 2);                                        -- trx_type; pos 24 - 25  
        l_line := l_line || '5';                                                                    -- force_post; pos 26 - 26  
        l_line := l_line || lpad(nvl(to_char(nvl(r.host_date, r.oper_date) ,'YYMMDD'), ' '), 6);    -- date; pos 27 - 32  
        l_line := l_line || lpad(nvl(to_char(nvl(r.host_date, r.oper_date) ,'HH24MISS'), ' '), 6);  -- time; pos 33 - 38  
        l_line := l_line || '0';                                                         -- src_mailbox; pos 39 - 39  
        l_line := l_line || '422';                                                       -- dest_country code ; pos 40 - 42  
        l_line := l_line || '504908';                                                    -- dest_imd; pos 43 - 48  
        l_line := l_line || '0001';                                                      -- dest_branch_code ; pos 49 - 52  
        l_line := l_line || l_card_number;                                               -- card_nbr; pos 53 - 65  
        l_line := l_line || '0';                                                         -- card_seq_nbr; pos 66 - 66  
        l_line := l_line || '0';                                                         -- auth_flag; pos 67 - 67  
        l_line := l_line || lpad(nvl(substr(r.account_number, 1, 13), ' '), 13);         -- src_account_nbr ; pos 68 - 80  
        l_line := l_line || '00';                                                        -- src_account_desc ; pos 81 - 82  
        l_line := l_line || lpad(nvl(l_account_currency, ' '), 3);                       -- src_account_cur; pos 83 - 85  
        l_line := l_line || '+';                                                         -- amount1sign; pos 86 - 86  
        l_line := l_line || lpad(nvl(to_char(l_account_amount + l_fee_amount), '0'), 14, '0');      -- amount1; pos 87 - 100  
        l_line := l_line || '+';                                                         -- amount2sign; pos 101 - 101  
        l_line := l_line || lpad(nvl(to_char(l_oper_amount), '0'), 14, '0');             -- amount2; pos 102 - 115  
        l_line := l_line || lpad(nvl(to_char(l_oper_currency), ' '), 3);                 -- dest_cur_code; pos 116 - 118  
        l_line := l_line || '00000000000000000000';                                      -- Constant "00000000000000000000" ; pos 119 - 138  
        l_line := l_line || '00';                                                        -- Constant "00"; pos 139 - 140  
        l_line := l_line || '0';                                                         -- sub_index; pos 141 - 141  
        l_line := l_line || '0';                                                         -- action_code; pos 142 - 142  
        l_line := l_line || '422';                                                       -- local curr code ; pos 143 - 145  
        l_line := l_line || '+';                                                         -- am ount3sign; pos 146 - 146  
        l_line := l_line || lpad(nvl(to_char(l_amount), '0'), 14, '0');                  -- amount3; pos 147 - 160  
        l_line := l_line || '+00000000000000';                                           -- amount4; pos 161 - 175  
        l_line := l_line || 'E';                                                         -- var_data type ; pos 176 - 176  
        l_line := l_line || '01';                                                        -- iso_ext_version ; pos 177 - 178  
        l_line := l_line || case when r.merchant_country = LEBANON_CODE then 'LNA' else 'ENA' end;  -- ext net id; pos 179 - 181  
        l_line := l_line || lpad(nvl(r.auth_code, ' '), 6);                                         -- auth_code; pos 182 - 187  
        l_line := l_line || lpad(nvl(rpad(substr(r.acq_inst_bin, 1, 11), 11, ' '), ' '), 11);       -- acq_ins_tid; pos 188 - 198  
        l_line := l_line || '00000000000';                                               -- fwd_ins_tid; pos 199 - 209  
        l_line := l_line || lpad(nvl(r.mcc, ' '), 4);                                    -- merch_cat_code ; pos 210 - 213  
        l_line := l_line || lpad(nvl(rpad(r.terminal_number, 16, ' '), ' '), 16);        -- card_acc temid ; pos 214 - 229  
        l_line := l_line || lpad(nvl(rpad(r.merchant_number, 15, ' '), ' '), 15);        -- card_acc_id; pos 230 - 244  
        l_line := l_line || lpad(nvl(rpad(r.merchant_name, 25, ' ') || rpad(r.merchant_city, 15, ' '), ' '), 40);  -- card_acc_name_location ; pos 245 - 284  
        l_line := l_line || lpad(nvl(r.sttl_currency, ' '), 3);                          -- billing_curr_code; pos 285 - 287  
        l_line := l_line || '+';                                                         -- billing_trx_amt_sign ; pos 288 - 288  
        l_line := l_line || lpad(nvl(l_sttl_amount, '0'), 14, '0');                      -- billing_trx_amt ; pos 289 - 302  
        l_line := l_line || lpad(nvl(
                                     format_exchange_rate(
                                         i_rate         => l_rate
                                     )
                                   , '0'
                                 )
                               , 8
                            );                                                           -- billing_conv_rate ; pos 303 - 310
        l_line := l_line || '+00000000000000';                                           -- cashback_amt_billing; pos 311 - 325
        l_line := l_line || '+00000000000000';                                           -- cashback_amt_dev ; pos 326 - 340
        l_line := l_line || '+00000000000000';                                           -- cashback_amt_account; pos 341 - 355
        l_line := l_line || '000';                                                       -- sett_curr; pos 356 - 358
        l_line := l_line || '000000000000000';                                           -- setti_amt; pos 359 - 373
        l_line := l_line || '00000000';                                                  -- settconv_rate ; pos 374 - 381
        l_line := l_line || '000000000000000';                                           -- actual_balance ; pos 382 - 396
        l_line := l_line || '000000000000000';                                           -- available_balance; pos 397 - 411

        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => l_session_file_id
        );

        l_processed_count := l_processed_count + 1;

        if mod(l_processed_count, 100) = 0 then
            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => l_excepted_count
            );
        end if;

        evt_api_event_pkg.process_event_object(
            i_event_object_id => r.eo_id
        );

    end loop;

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'Finish'
    );
exception
    when others then
        rollback to savepoint sp_posinp_file;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;

        raise;
end generate_posinp_file;

end cst_bmed_prc_outgoing_pkg;
/
