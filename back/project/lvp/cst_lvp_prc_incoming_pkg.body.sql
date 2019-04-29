create or replace package body cst_lvp_prc_incoming_pkg as

procedure process_record(
    i_rec                  in com_api_type_pkg.t_text
  , i_row_number           in com_api_type_pkg.t_count
  , i_incom_sess_file_id   in com_api_type_pkg.t_long_id
)
is
    l_sysdate              date;
    
    l_card_number          com_api_type_pkg.t_card_number;
    l_cardholder_name      com_api_type_pkg.t_name;
    l_transaction_desc     com_api_type_pkg.t_name;
    l_currency_name        com_api_type_pkg.t_curr_name;
    l_amount_str           com_api_type_pkg.t_original_data;
    l_transaction_type     com_api_type_pkg.t_byte_char;
    l_transaction_date     date;
    l_suppl_card_number    com_api_type_pkg.t_name;
    l_reason_code          com_api_type_pkg.t_dict_value;
    l_payment_type         com_api_type_pkg.t_byte_char;
    
    l_currency_code        com_api_type_pkg.t_curr_code;
    l_currency_exponent    com_api_type_pkg.t_tiny_id;
    l_amount               com_api_type_pkg.t_money;

    l_oper_id              com_api_type_pkg.t_long_id;
    l_status               com_api_type_pkg.t_dict_value;
    l_oper_type            com_api_type_pkg.t_dict_value;
    l_iss_inst_id          com_api_type_pkg.t_inst_id;
    l_card_inst_id         com_api_type_pkg.t_inst_id;
    l_iss_network_id       com_api_type_pkg.t_tiny_id;
    l_card_network_id      com_api_type_pkg.t_tiny_id;
    l_card_type_id         com_api_type_pkg.t_tiny_id;
    l_card_country         com_api_type_pkg.t_country_code;
    l_bin_currency         com_api_type_pkg.t_curr_code;
    l_sttl_currency        com_api_type_pkg.t_curr_code;
    l_is_reversal          com_api_type_pkg.t_boolean;
    l_note_id              com_api_type_pkg.t_long_id;
    
    l_card                 iss_api_type_pkg.t_card_rec;
begin
    l_card_number          := trim(substr(i_rec, 2, 25));
    l_cardholder_name      := trim(substr(i_rec, 27, 30));
    l_transaction_desc     := trim(substr(i_rec, 57, 30));
    l_currency_name        := trim(substr(i_rec, 87, 3));
    l_amount_str           := trim(substr(i_rec, 90, 12));
    l_transaction_type     := trim(substr(i_rec, 102, 1));
    l_transaction_date     := to_date(substr(i_rec, 103, 8), 'YYYYMMDD');
    l_suppl_card_number    := trim(substr(i_rec, 111, 25));
    l_reason_code          := trim(substr(i_rec, 136, 4));
    l_payment_type         := trim(substr(i_rec, 140, 1));
    begin
        l_currency_code := com_api_currency_pkg.get_currency_code(i_curr_name => l_currency_name);
    exception 
        when com_api_error_pkg.e_application_error then
            l_currency_code := '000'; 
    end;
    
    l_currency_exponent :=
        com_api_currency_pkg.get_currency_exponent(
            i_curr_code => l_currency_code
        );
    l_amount := to_number(l_amount_str, 'FM999999999999999990');
    l_amount := l_amount * power(10, l_currency_exponent);
    

    l_oper_id     := opr_api_create_pkg.get_id;
    l_status      := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;
    iss_api_bin_pkg.get_bin_info(
        i_card_number      => l_card_number
      , o_iss_inst_id      => l_iss_inst_id
      , o_iss_network_id   => l_iss_network_id
      , o_card_inst_id     => l_card_inst_id
      , o_card_network_id  => l_card_network_id
      , o_card_type        => l_card_type_id
      , o_card_country     => l_card_country
      , o_bin_currency     => l_bin_currency
      , o_sttl_currency    => l_sttl_currency
    );

    l_card := iss_api_card_pkg.get_card (
                  i_card_number     => l_card_number
                , i_mask_error      => com_api_const_pkg.TRUE
              );

    if l_transaction_type in ('R', 'D') then
        l_oper_type := opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST;
    elsif l_transaction_type in ('P', 'C') then
        l_oper_type := opr_api_const_pkg.OPERATION_TYPE_PAYMENT;
    else
        l_oper_type := opr_api_const_pkg.OPERATION_TYPE_UNKNOWN;
    end if;
    
    if l_transaction_type in ('R') then
        l_is_reversal := com_api_const_pkg.TRUE;
    else
        l_is_reversal := com_api_const_pkg.FALSE;
    end if;

    opr_api_create_pkg.create_operation(
        io_oper_id              => l_oper_id
      , i_session_id            => prc_api_session_pkg.get_session_id
      , i_status                => l_status
      , i_status_reason         => null
      , i_sttl_type             => opr_api_const_pkg.SETTLEMENT_INTERNAL
      , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type             => l_oper_type
      , i_oper_reason           => 'PMRSMADP'
      , i_is_reversal           => l_is_reversal
      , i_original_id           => null
      , i_oper_amount           => l_amount
      , i_oper_currency         => l_currency_code
      , i_oper_cashback_amount  => null
      , i_sttl_amount           => null
      , i_sttl_currency         => null
      , i_oper_date             => l_sysdate
      , i_host_date             => null
      , i_terminal_type         => null 
      , i_mcc                   => null
      , i_originator_refnum     => null
      , i_network_refnum        => null
      , i_dispute_id            => null
      , i_match_status          => opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH
      , i_proc_mode             => null
      , i_incom_sess_file_id    => i_incom_sess_file_id
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type         => l_oper_type
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date         => null
      , i_inst_id           => l_iss_inst_id
      , i_network_id        => l_iss_network_id
      , i_customer_id       => l_card.customer_id
      , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
      , i_client_id_value   => l_card_number
      , i_card_id           => l_card.id
      , i_card_type_id      => l_card.card_type_id
      , i_card_expir_date   => null
      , i_card_seq_number   => null
      , i_card_number       => l_card_number
      , i_card_mask         => l_card.card_mask
      , i_card_hash         => l_card.card_hash
      , i_card_country      => l_card.country
      , i_card_inst_id      => l_card.inst_id
      , i_card_network_id   => l_card_network_id
      , i_account_id        => null
      , i_account_number    => null
      , i_account_amount    => null
      , i_account_currency  => null
      , i_auth_code         => null
      , i_split_hash        => l_card.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );
    
    ntb_ui_note_pkg.add(
        o_id                => l_note_id
      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id         => l_oper_id
      , i_note_type         => ntb_api_const_pkg.NOTE_TYPE_COMMENT
      , i_lang              => com_api_const_pkg.DEFAULT_LANGUAGE
      , i_header            => 'Reference'
      , i_text              => l_transaction_desc
      , i_start_date        => null
      , i_end_date          => null
    );
end process_record;

procedure process_import_rgts
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_import_rgts: ';
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );

    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) 
    loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id 
                   || '], record_count [' || p.record_count 
                   || '], file_name [' || p.file_name || ']'
        );
        
        begin
            savepoint sp_lvp_rtcs_file;
            
            for r in (
                select record_number
                     , raw_data
                     , substr(raw_data, 1, 1) tc
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            loop
                l_record_number := r.record_number;
                l_rec := r.raw_data;
                if r.rn_desc > 1 and r.tc = '1' then
                    process_record(
                        i_rec                => r.raw_data
                      , i_row_number         => r.rn
                      , i_incom_sess_file_id => p.session_file_id
                    );
                end if;
                
                
                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + r.rn
                      , i_excepted_count => 0
                    );
                end if;
                
                if r.rn_desc = 1 then
                    l_record_count := l_record_count + r.cnt;
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => 0
                    );
                end if;
            end loop;
            
            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_lvp_rtcs_file;

                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => 0
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_record_count
      , i_excepted_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]' 
              , i_env_param1 => l_record_number
              , i_env_param2 => l_rec
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_import_rgts;

end;
/
