create or replace package body cst_lvp_prc_outgoing_pkg as

CRLF                     constant  com_api_type_pkg.t_name := chr(13)||chr(10);

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
    l_order_list_tab               cst_lvp_type_pkg.t_order_evt_list_tab;
    l_order_list_cur               cst_lvp_type_pkg.t_order_evt_list_cur;
    l_order_parameters_cur         cst_lvp_type_pkg.t_order_parameters_cur;
    l_order_parameters_tab         cst_lvp_type_pkg.t_order_parameters_tab;
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

    l_processed_count              com_api_type_pkg.t_count := 0;
    l_excepted_count               com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug('cst_lvp_prc_outgoing_pkg.process_export_cbs - started.');

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    prc_api_stat_pkg.log_start;

    pmo_api_order_pkg.get_order_evt_list_count(
        i_inst_id               => i_inst_id
      , i_subscriber_name       => 'CST_LVP_PRC_OUTGOING_PKG.PROCESS_EXPORT_CBS'
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
          , i_subscriber_name       => 'CST_LVP_PRC_OUTGOING_PKG.PROCESS_EXPORT_CBS'
          , i_event_type            => pmo_api_const_pkg.EVENT_TYPE_PAY_ORDER_CREATE
          , i_purpose_id            => i_purpose_id
          , o_order_evt_list        => l_order_list_cur
        );
        
        fetch l_order_list_cur bulk collect into l_order_list_tab;

        for i in 1..l_order_list_tab.count loop
            trc_log_pkg.debug('cst_lvp_prc_outgoing_pkg.process_export_cbs [' || l_order_list_tab(i).attempt_count || '] attempts for ' || l_order_list_tab(i).order_id);
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
                        if l_order_parameters_tab(p).param_name = 'LVP_IBAN' then
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
                        select iss_api_card_pkg.get_card_number(c.id) as card_number
                             , iss_api_cardholder_pkg.get_cardholder_name(c.cardholder_id) as cardholder_name
                             , a.account_number
                             , ag.agent_number
                          into l_card_number
                             , l_cardholder_name
                             , l_account_number
                             , l_agent_number
                          from iss_card c
                             , iss_card_instance i
                             , acc_account_object o
                             , acc_account a
                             , ost_agent ag 
                         where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and o.account_id = l_invoice_rec.account_id
                           and o.account_id = a.id
                           and o.object_id = c.id
                           and c.category = iss_api_const_pkg.CARD_CATEGORY_PRIMARY
                           and i.card_id = c.id
                           and i.state = iss_api_const_pkg.CARD_STATE_ACTIVE
                           and a.agent_id = ag.id
                           and rownum < 2;
                    exception
                        when no_data_found then
                            l_card_number := ' ';
                            l_cardholder_name := ' ';
                            l_account_number := ' ';
                            l_agent_number := ' ';
                    end;
                       
                    l_record := rpad(l_card_number, 25);
                    l_record := l_record || rpad(l_cardholder_name, 30);
                    l_record := l_record || rpad(l_agent_number, 21);
                    l_record := l_record || rpad(l_account_number, 20);
                    l_record := l_record || 'DB';
                    l_record := l_record || l_currency_name;
                    l_record := l_record || lpad(to_char(l_order_list_tab(i).amount, com_api_const_pkg.XML_NUMBER_FORMAT), 12, '0');
                    l_record := l_record || to_char(l_currency_exponent, 'FM0');
                    l_record := l_record || to_char(l_order_list_tab(i).event_date, 'yyyymmdd');
                    l_record := l_record || rpad(l_card_number, 25);
                    l_record := l_record || rpad(substr(to_char(l_invoice_rec.id), 1, 10), 10);
                    l_record := l_record || rpad(' ', 20);
                    l_record := l_record || rpad(nvl(l_iban, ' '), 34);
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
                trc_log_pkg.debug('cst_lvp_prc_outgoing_pkg.process_export_cbs order ' || l_order_list_tab(i).order_id || ' is eceeded attemps and marked and not paid');
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
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('cst_lvp_prc_outgoing_pkg.process_export_cbs - end.');
end process_export_cbs;

procedure process_export_rtgs(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
) is
    l_sysdate                      date;
    l_order_count                  com_api_type_pkg.t_long_id;
    l_order_list_tab               cst_lvp_type_pkg.t_order_list_tab;
    l_order_list_cur               cst_lvp_type_pkg.t_order_list_cur;
    l_order_parameters_cur         cst_lvp_type_pkg.t_order_parameters_cur;
    l_order_parameters_tab         cst_lvp_type_pkg.t_order_parameters_tab;
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
    l_estimated_count              com_api_type_pkg.t_long_id    := 0;
    l_processed_count              com_api_type_pkg.t_long_id    := 0;
    l_excepted_count               com_api_type_pkg.t_long_id    := 0;
begin
    trc_log_pkg.debug('cst_lvp_prc_outgoing_pkg.process_export_rtgs - started.');

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
        l_estimated_count := l_order_list_tab.count;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count       => l_estimated_count
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
                    if l_order_parameters_tab(p).param_name = 'LVP_IBAN' then
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
            l_record := l_record || rpad(nvl(l_iban, ' '), 28);
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
            l_processed_count := l_processed_count + 1;
            for eo in (select a.id
                         from evt_event_object a
                            , pmo_order        o
                        where decode(a.status, 'EVST0001', a.procedure_name, null) = 'CST_LVP_PRC_OUTGOING_PKG.PROCESS_EXPORT_RTGS'
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
      , i_excepted_total    => l_estimated_count - l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('cst_lvp_prc_outgoing_pkg.process_export_rtgs - end.');
end process_export_rtgs;

end;
/
