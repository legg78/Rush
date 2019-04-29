create or replace package body rcn_prc_import_pkg as

BULK_LIMIT          constant    pls_integer := 1000;

procedure process_cbs_batch (
    i_oper_tab          in rcn_recon_msg_tpt
  , i_param_tab         in com_param_map_tpt
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_cbs_batch: ';
    l_estimated_count           com_api_type_pkg.t_long_id    := 0;
    l_processed_count           com_api_type_pkg.t_long_id    := 0;
    l_excepted_count            com_api_type_pkg.t_long_id    := 0;
    l_rejected_count            com_api_type_pkg.t_long_id    := 0;
    l_msg_date                  date;
    l_msg_id                    com_api_type_pkg.t_long_id;
    l_result_code               com_api_type_pkg.t_dict_value;
    l_name                      com_api_type_pkg.t_name;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_session_id                com_api_type_pkg.t_long_id;
    l_thread_number             com_api_type_pkg.t_tiny_id;

begin
    savepoint process_start;

    trc_log_pkg.info(
        i_text          => 'CBS Reconciliation batch upload started'
    );

    l_session_id       := prc_api_session_pkg.get_session_id;
    l_thread_number    := prc_api_session_pkg.get_thread_number;

    begin
        select nvl(estimated_count, 0)
             , nvl(processed_total, 0)
             , nvl(excepted_total,  0)
             , nvl(rejected_total,  0)
          into l_estimated_count
             , l_processed_count
             , l_excepted_count
             , l_rejected_count
          from prc_stat
         where session_id    = l_session_id
           and thread_number = l_thread_number;

    exception when no_data_found then
        prc_api_stat_pkg.log_start;
    end;

    trc_log_pkg.debug(
        i_text          => 'Previous values: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
      , i_env_param1    => l_estimated_count
      , i_env_param2    => l_processed_count
      , i_env_param3    => l_excepted_count
      , i_env_param4    => l_rejected_count
    );

    l_estimated_count := nvl(i_oper_tab.count,0) + l_estimated_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text       => 'l_estimated_count [#1], i_oper_tab.count [#2]'
      , i_env_param1 => l_estimated_count
      , i_env_param2 => i_oper_tab.count
    );

    l_msg_date := com_api_sttl_day_pkg.get_sysdate;

    if nvl(i_oper_tab.count, 0) > 0 then

        utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

        -- Read case attributes
        if i_param_tab is not null then
            for i in 1 .. i_param_tab.count loop
                l_name := upper(i_param_tab(i).name);

                if l_name in ('INST_ID')
                   and i_param_tab(i).number_value is null
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
                      , i_env_param1 => l_name
                    );
                end if;

                if l_name = 'INST_ID' then
                    l_inst_id := i_param_tab(i).number_value;
                end if;
            end loop;
        end if;

        for i in 1 .. i_oper_tab.count loop

            l_msg_id := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);

            begin
                insert into rcn_cbs_msg(
                    id
                  , recon_type
                  , msg_source
                  , msg_date
                  , oper_id
                  , recon_msg_id
                  , recon_status
                  , recon_date
                  , recon_inst_id
                  , oper_type
                  , msg_type
                  , sttl_type
                  , oper_date
                  , oper_amount
                  , oper_currency
                  , oper_request_amount
                  , oper_request_currency
                  , oper_surcharge_amount
                  , oper_surcharge_currency
                  , originator_refnum
                  , network_refnum
                  , acq_inst_bin
                  , status
                  , is_reversal
                  , merchant_number
                  , mcc
                  , merchant_name
                  , merchant_street
                  , merchant_city
                  , merchant_region
                  , merchant_country
                  , merchant_postcode
                  , terminal_type
                  , terminal_number
                  , acq_inst_id
                  , card_mask
                  , card_seq_number
                  , card_expir_date
                  , card_country
                  , iss_inst_id
                  , auth_code
                ) values (
                    l_msg_id
                  , rcn_api_const_pkg.RECON_TYPE_COMMON
                  , rcn_api_const_pkg.RECON_MSG_SOURCE_CBS
                  , l_msg_date
                  , null
                  , null
                  , rcn_api_const_pkg.RECON_STATUS_REQ_RECON -- RNST0200 – Require reconciliation
                  , null
                  , l_inst_id
                  , i_oper_tab(i).oper_type
                  , i_oper_tab(i).msg_type
                  , i_oper_tab(i).sttl_type
                  , i_oper_tab(i).oper_date --2017-06-30T10:10:00
                  , i_oper_tab(i).oper_amount
                  , i_oper_tab(i).oper_currency
                  , i_oper_tab(i).oper_request_amount
                  , i_oper_tab(i).oper_request_currency
                  , i_oper_tab(i).oper_surcharge_amount
                  , i_oper_tab(i).oper_surcharge_currency
                  , i_oper_tab(i).originator_refnum
                  , i_oper_tab(i).network_refnum
                  , i_oper_tab(i).acq_inst_bin
                  , i_oper_tab(i).status
                  , i_oper_tab(i).is_reversal
                  , i_oper_tab(i).merchant_number
                  , i_oper_tab(i).mcc
                  , i_oper_tab(i).merchant_name
                  , i_oper_tab(i).merchant_street
                  , i_oper_tab(i).merchant_city
                  , i_oper_tab(i).merchant_region
                  , i_oper_tab(i).merchant_country
                  , i_oper_tab(i).merchant_postcode
                  , i_oper_tab(i).terminal_type
                  , i_oper_tab(i).terminal_number
                  , i_oper_tab(i).acq_inst_id
                  , iss_api_card_pkg.get_card_mask(i_oper_tab(i).card_number)
                  , i_oper_tab(i).card_seq_number
                  , i_oper_tab(i).card_expir_date
                  , i_oper_tab(i).card_country
                  , i_oper_tab(i).iss_inst_id
                  , i_oper_tab(i).auth_code
                );
                
                insert into rcn_card (
                    id
                  , card_number
                ) values (
                    l_msg_id
                  , iss_api_token_pkg.encode_card_number(i_card_number => i_oper_tab(i).card_number)
                );

                if i_oper_tab(i).additional_amount is not null and i_oper_tab(i).additional_amount.count > 0 then

                    for j in 1..i_oper_tab(i).additional_amount.count
                    loop
                        if i_oper_tab(i).additional_amount(j).amount_type like com_api_const_pkg.AMOUNT_PURPOSE_DICTIONARY || '%'
                           and i_oper_tab(i).additional_amount(j).amount_type not in (com_api_const_pkg.AMOUNT_PURPOSE_DESTINATION, com_api_const_pkg.AMOUNT_PURPOSE_SOURCE)
                           and i_oper_tab(i).additional_amount(j).amount_value is not null
                        then
                            begin
                                insert into rcn_additional_amount(
                                    rcn_id
                                  , rcn_type
                                  , amount_type
                                  , currency
                                  , amount
                                ) values (
                                    l_msg_id
                                  , rcn_api_const_pkg.RECON_TYPE_COMMON
                                  , i_oper_tab(i).additional_amount(j).amount_type
                                  , i_oper_tab(i).additional_amount(j).currency
                                  , i_oper_tab(i).additional_amount(j).amount_value
                                );
                            exception
                                when dup_val_on_index then
                                    l_excepted_count := l_excepted_count + 1;
                                    trc_log_pkg.debug(
                                        i_text       => LOG_PREFIX || 'Message parameter with rcn_id [#1], rcn_type [#2], amount_type [#3], '
                                                     || 'currency [#4], amount_value [#5] already exists in reconciliation additional amount table'
                                      , i_env_param1 => l_msg_id
                                      , i_env_param2 => rcn_api_const_pkg.RECON_TYPE_COMMON
                                      , i_env_param3 => i_oper_tab(i).additional_amount(j).amount_type
                                      , i_env_param4 => i_oper_tab(i).additional_amount(j).currency
                                      , i_env_param5 => i_oper_tab(i).additional_amount(j).amount_value
                                    );
                            end;
                        end if;
                    end loop;

                end if;

                l_processed_count := l_processed_count + 1;

            exception
                when dup_val_on_index then
                    l_excepted_count := l_excepted_count + 1;
                    trc_log_pkg.debug(
                        i_text       => 'Message with auth_code [#1], recon_inst_id [#2], originator_refnum [#3], ' 
                                     || 'msg_type [#4], oper_type [#5], oper_date [#6], merchant_number [' || i_oper_tab(i).merchant_number
                                     || '], terminal_number [' || i_oper_tab(i).terminal_number
                                     || '], already exists in reconciliation table'
                      , i_env_param1 => i_oper_tab(i).auth_code
                      , i_env_param2 => l_inst_id
                      , i_env_param3 => i_oper_tab(i).originator_refnum
                      , i_env_param4 => i_oper_tab(i).msg_type
                      , i_env_param5 => i_oper_tab(i).oper_type
                      , i_env_param6 => i_oper_tab(i).oper_date
                    );
            end;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;
        
    end if;  -- if l_estimated_count > 0

    if (l_rejected_count > 0 or l_excepted_count > 0) then
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_REJECTED;
    else
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_SUCCESS;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => l_result_code
    );

    com_api_sttl_day_pkg.unset_sysdate;

    trc_log_pkg.info(
        i_text  => 'CBS Reconciliation upload finished'
    );

exception
    when others then
        rollback to savepoint process_start;
        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text          => 'Error: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
          , i_env_param1    => l_estimated_count
          , i_env_param2    => l_processed_count
          , i_env_param3    => l_excepted_count
          , i_env_param4    => l_rejected_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end process_cbs_batch;

procedure process_atm_batch(
    i_oper_tab   in     rcn_atm_recon_msg_tpt
  , i_param_tab  in     com_param_map_tpt
) is
    l_estimated_count   com_api_type_pkg.t_long_id    := 0;
    l_processed_count   com_api_type_pkg.t_long_id    := 0;
    l_excepted_count    com_api_type_pkg.t_long_id    := 0;
    l_rejected_count    com_api_type_pkg.t_long_id    := 0;
    l_msg_date          date;
    l_msg_id            com_api_type_pkg.t_long_id;
    l_result_code       com_api_type_pkg.t_dict_value;
    l_name              com_api_type_pkg.t_name;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_session_id        com_api_type_pkg.t_long_id;
    l_thread_number     com_api_type_pkg.t_tiny_id;
begin
    savepoint process_start;

    trc_log_pkg.info(
        i_text          => 'ATM Reconciliation batch upload started'
    );

    l_session_id       := prc_api_session_pkg.get_session_id;
    l_thread_number    := prc_api_session_pkg.get_thread_number;

    begin
        select nvl(estimated_count, 0)
             , nvl(processed_total, 0)
             , nvl(excepted_total,  0)
             , nvl(rejected_total,  0)
          into l_estimated_count
             , l_processed_count
             , l_excepted_count
             , l_rejected_count
          from prc_stat
         where session_id    = l_session_id
           and thread_number = l_thread_number;

    exception when no_data_found then
        prc_api_stat_pkg.log_start;
    end;

    trc_log_pkg.debug(
        i_text          => 'Previous values: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
      , i_env_param1    => l_estimated_count
      , i_env_param2    => l_processed_count
      , i_env_param3    => l_excepted_count
      , i_env_param4    => l_rejected_count
    );

    l_estimated_count := l_estimated_count + nvl(i_oper_tab.count, 0);

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text       => 'l_estimated_count [#1], i_oper_tab.count [#2]'
      , i_env_param1 => l_estimated_count
      , i_env_param2 => i_oper_tab.count
    );
    
    l_msg_date := com_api_sttl_day_pkg.get_sysdate;

    if nvl(i_oper_tab.count, 0) > 0 then

        utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

        -- Read case attributes
        if i_param_tab is not null then
            for i in 1 .. i_param_tab.count loop
                l_name := upper(i_param_tab(i).name);

                if l_name in ('INST_ID')
                   and i_param_tab(i).number_value is null
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
                      , i_env_param1 => l_name
                    );
                end if;

                if l_name = 'INST_ID' then
                    l_inst_id := i_param_tab(i).number_value;
                end if;
            end loop;
        end if;

        for i in 1 .. i_oper_tab.count loop

            l_msg_id := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);
            
            begin
                insert into rcn_atm_msg (
                    id
                  , msg_source
                  , msg_date
                  , operation_id
                  , recon_msg_ref
                  , recon_status
                  , recon_last_date
                  , recon_inst_id
                  , oper_type
                  , oper_date
                  , oper_amount
                  , oper_currency
                  , trace_number
                  , acq_inst_id
                  , card_mask
                  , auth_code
                  , is_reversal
                  , terminal_type
                  , terminal_number
                  , iss_fee
                  , acc_from
                  , acc_to
                ) values (
                    l_msg_id
                  , rcn_api_const_pkg.RECON_MSG_SOURCE_ATM_EJOURNAL
                  , l_msg_date
                  , null
                  , null
                  , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
                  , null
                  , (select min(t.inst_id) from acq_terminal t where t.terminal_number = i_oper_tab(i).terminal_number)
                  , i_oper_tab(i).oper_type
                  , i_oper_tab(i).oper_date
                  , i_oper_tab(i).oper_amount
                  , i_oper_tab(i).oper_currency
                  , i_oper_tab(i).trace_number
                  , i_oper_tab(i).acq_inst_id
                  , iss_api_card_pkg.get_card_mask(i_oper_tab(i).card_number)
                  , i_oper_tab(i).auth_code
                  , i_oper_tab(i).is_reversal
                  , i_oper_tab(i).terminal_type
                  , i_oper_tab(i).terminal_number
                  , i_oper_tab(i).iss_fee
                  , i_oper_tab(i).acc_from
                  , i_oper_tab(i).acc_to
                );
                
                insert into rcn_card (
                    id
                  , card_number
                ) values (
                    l_msg_id
                  , iss_api_token_pkg.encode_card_number(i_card_number => i_oper_tab(i).card_number)
                );
                l_processed_count := l_processed_count + 1;
            exception
                when dup_val_on_index then
                    l_excepted_count := l_excepted_count + 1;
                    trc_log_pkg.debug(
                        i_text       => 'Message with auth_code [#1], recon_inst_id [#2], oper_type [#3], oper_date [#4], ' 
                                     || 'terminal_number [#5], card_mask [#6]' 
                                     || ' already exists in ATM reconciliation table'
                      , i_env_param1 => i_oper_tab(i).auth_code
                      , i_env_param2 => l_inst_id
                      , i_env_param3 => i_oper_tab(i).oper_type
                      , i_env_param4 => i_oper_tab(i).oper_date
                      , i_env_param5 => i_oper_tab(i).terminal_number
                      , i_env_param6 => iss_api_card_pkg.get_card_mask(i_oper_tab(i).card_number)
                    );
            end;
            
            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;
        
    end if;  -- if l_estimated_count > 0

    if (l_rejected_count > 0 or l_excepted_count > 0) then
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_REJECTED;
    else
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_SUCCESS;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => l_result_code
    );

    com_api_sttl_day_pkg.unset_sysdate;

    trc_log_pkg.info(
        i_text  => 'ATM Reconciliation batch upload finished'
    );

exception
    when others then
        rollback to savepoint process_start;
        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text          => 'Error: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
          , i_env_param1    => l_estimated_count
          , i_env_param2    => l_processed_count
          , i_env_param3    => l_excepted_count
          , i_env_param4    => l_rejected_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end;

procedure process_host_batch(
    i_oper_tab   in     rcn_host_recon_msg_tpt
  , i_param_tab  in     com_param_map_tpt
) is
    l_excepted_count    com_api_type_pkg.t_count    := 0;
    l_processed_count   com_api_type_pkg.t_count    := 0;
    l_rejected_count    com_api_type_pkg.t_count    := 0;
    l_estimated_count   com_api_type_pkg.t_count    := 0;
    l_msg_date          date                        := com_api_sttl_day_pkg.get_sysdate();
    l_msg_id            com_api_type_pkg.t_long_id;
    l_msg_source        com_api_type_pkg.t_dict_value;
    l_recon_inst_id     com_api_type_pkg.t_inst_id;
    l_result_code       com_api_type_pkg.t_dict_value;
    l_name              com_api_type_pkg.t_name;
    l_recon_type        com_api_type_pkg.t_dict_value;
    l_session_id        com_api_type_pkg.t_long_id;
    l_thread_number     com_api_type_pkg.t_tiny_id;
begin
    savepoint process_start;

    trc_log_pkg.info(
        i_text          => 'HOST Reconciliation batch upload started'
    );

    l_session_id       := prc_api_session_pkg.get_session_id;
    l_thread_number    := prc_api_session_pkg.get_thread_number;

    begin
        select nvl(estimated_count, 0)
             , nvl(processed_total, 0)
             , nvl(excepted_total,  0)
             , nvl(rejected_total,  0)
          into l_estimated_count
             , l_processed_count
             , l_excepted_count
             , l_rejected_count
          from prc_stat
         where session_id    = l_session_id
           and thread_number = l_thread_number;

    exception when no_data_found then
        prc_api_stat_pkg.log_start;
    end;

    trc_log_pkg.debug(
        i_text          => 'Previous values: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
      , i_env_param1    => l_estimated_count
      , i_env_param2    => l_processed_count
      , i_env_param3    => l_excepted_count
      , i_env_param4    => l_rejected_count
    );

    l_estimated_count := l_estimated_count + nvl(i_oper_tab.count, 0);

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text       => 'l_estimated_count [#1], i_oper_tab.count [#2]'
      , i_env_param1 => l_estimated_count
      , i_env_param2 => i_oper_tab.count
    );
    
    if nvl(i_oper_tab.count, 0) > 0 then
        utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

        -- Read case attributes
        if i_param_tab is not null then
            for i in 1 .. i_param_tab.count loop
                l_name := upper(i_param_tab(i).name);

                if l_name = 'INST_ID' then
                    l_recon_inst_id := i_param_tab(i).number_value;
                end if;

                if l_name = 'RECON_TYPE' then
                    l_recon_type := i_param_tab(i).char_value;
                end if;

                if l_name = 'MSG_SOURCE' then
                    l_msg_source := i_param_tab(i).char_value;
                end if;
            end loop;
        end if;

        l_msg_source := nvl(l_msg_source, rcn_api_const_pkg.RECON_MSG_SOURCE_HOST);

        if l_recon_inst_id is null then
            com_api_error_pkg.raise_error(
                i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
              , i_env_param1 => 'INST_ID'
            );
        end if;

        for i in 1 .. i_oper_tab.count loop

            l_msg_id := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);

            begin
                insert into rcn_host_msg(
                    id
                  , recon_type
                  , msg_source
                  , msg_date
                  , oper_id
                  , recon_msg_id
                  , recon_status
                  , recon_date
                  , recon_inst_id
                  , oper_type
                  , msg_type
                  , host_date
                  , oper_date
                  , oper_amount
                  , oper_currency
                  , oper_surcharge_amount
                  , oper_surcharge_currency
                  , status
                  , is_reversal
                  , merchant_number
                  , mcc
                  , merchant_name
                  , merchant_street
                  , merchant_city
                  , merchant_region
                  , merchant_country
                  , merchant_postcode
                  , terminal_type
                  , terminal_number
                  , acq_inst_id
                  , card_mask
                  , card_seq_number
                  , card_expir_date
                  , oper_cashback_amount
                  , oper_cashback_currency
                  , service_code
                  , approval_code
                  , rrn
                  , trn
                  , original_id
                  , emv_5f2a
                  , emv_5f34
                  , emv_71
                  , emv_72
                  , emv_82
                  , emv_84
                  , emv_8a
                  , emv_91
                  , emv_95
                  , emv_9a
                  , emv_9c
                  , emv_9f02
                  , emv_9f03
                  , emv_9f06
                  , emv_9f09
                  , emv_9f10
                  , emv_9f18
                  , emv_9f1a
                  , emv_9f1e
                  , emv_9f26
                  , emv_9f27
                  , emv_9f28
                  , emv_9f29
                  , emv_9f33
                  , emv_9f34
                  , emv_9f35
                  , emv_9f36
                  , emv_9f37
                  , emv_9f41
                  , emv_9f53
                  , pdc_1
                  , pdc_2
                  , pdc_3
                  , pdc_4
                  , pdc_5
                  , pdc_6
                  , pdc_7
                  , pdc_8
                  , pdc_9
                  , pdc_10
                  , pdc_11
                  , pdc_12
                  , forw_inst_code
                  , receiv_inst_code
                  , sttl_date
                  , oper_reason
                  , arn
                ) values (
                    l_msg_id
                  , nvl(l_recon_type, rcn_api_const_pkg.RECON_TYPE_HOST)
                  , l_msg_source
                  , l_msg_date
                  , null --i_oper_tab(i).oper_id
                  , null --i_oper_tab(i).recon_msg_id
                  , rcn_api_const_pkg.RECON_STATUS_REQ_RECON -- RNST0200 – Require reconciliation
                  , l_msg_date
                  , l_recon_inst_id
                  , i_oper_tab(i).oper_type
                  , i_oper_tab(i).msg_type
                  , i_oper_tab(i).host_date
                  , i_oper_tab(i).oper_date
                  , i_oper_tab(i).oper_amount
                  , i_oper_tab(i).oper_currency
                  , i_oper_tab(i).oper_surcharge_amount
                  , i_oper_tab(i).oper_surcharge_currency
                  , i_oper_tab(i).status
                  , i_oper_tab(i).is_reversal
                  , i_oper_tab(i).merchant_number
                  , i_oper_tab(i).mcc
                  , i_oper_tab(i).merchant_name
                  , i_oper_tab(i).merchant_street
                  , i_oper_tab(i).merchant_city
                  , i_oper_tab(i).merchant_region
                  , i_oper_tab(i).merchant_country
                  , i_oper_tab(i).merchant_postcode
                  , i_oper_tab(i).terminal_type
                  , i_oper_tab(i).terminal_number
                  , i_oper_tab(i).acq_inst_id
                  , iss_api_card_pkg.get_card_mask(i_oper_tab(i).card_number)
                  , i_oper_tab(i).card_seq_number
                  , i_oper_tab(i).card_expir_date
                  , i_oper_tab(i).oper_cashback_amount
                  , i_oper_tab(i).oper_cashback_currency
                  , i_oper_tab(i).service_code
                  , i_oper_tab(i).approval_code
                  , i_oper_tab(i).rrn
                  , i_oper_tab(i).trn
                  , i_oper_tab(i).original_id
                  , i_oper_tab(i).emv_5f2a
                  , i_oper_tab(i).emv_5f34
                  , i_oper_tab(i).emv_71
                  , i_oper_tab(i).emv_72
                  , i_oper_tab(i).emv_82
                  , i_oper_tab(i).emv_84
                  , i_oper_tab(i).emv_8a
                  , i_oper_tab(i).emv_91
                  , i_oper_tab(i).emv_95
                  , i_oper_tab(i).emv_9a
                  , i_oper_tab(i).emv_9c
                  , i_oper_tab(i).emv_9f02
                  , i_oper_tab(i).emv_9f03
                  , i_oper_tab(i).emv_9f06
                  , i_oper_tab(i).emv_9f09
                  , i_oper_tab(i).emv_9f10
                  , i_oper_tab(i).emv_9f18
                  , i_oper_tab(i).emv_9f1a
                  , i_oper_tab(i).emv_9f1e
                  , i_oper_tab(i).emv_9f26
                  , i_oper_tab(i).emv_9f27
                  , i_oper_tab(i).emv_9f28
                  , i_oper_tab(i).emv_9f29
                  , i_oper_tab(i).emv_9f33
                  , i_oper_tab(i).emv_9f34
                  , i_oper_tab(i).emv_9f35
                  , i_oper_tab(i).emv_9f36
                  , i_oper_tab(i).emv_9f37
                  , i_oper_tab(i).emv_9f41
                  , i_oper_tab(i).emv_9f53
                  , i_oper_tab(i).pdc_1
                  , i_oper_tab(i).pdc_2
                  , i_oper_tab(i).pdc_3
                  , i_oper_tab(i).pdc_4
                  , i_oper_tab(i).pdc_5
                  , i_oper_tab(i).pdc_6
                  , i_oper_tab(i).pdc_7
                  , i_oper_tab(i).pdc_8
                  , i_oper_tab(i).pdc_9
                  , i_oper_tab(i).pdc_10
                  , i_oper_tab(i).pdc_11
                  , i_oper_tab(i).pdc_12
                  , i_oper_tab(i).forw_inst_code
                  , i_oper_tab(i).receiv_inst_code
                  , i_oper_tab(i).sttl_date
                  , i_oper_tab(i).oper_reason
                  , i_oper_tab(i).arn
                );

                insert into rcn_card(
                    id
                  , card_number
                ) values (
                    l_msg_id
                  , iss_api_token_pkg.encode_card_number(i_card_number => i_oper_tab(i).card_number)
                );
                l_processed_count := l_processed_count + 1;
            exception
                when dup_val_on_index then
                    l_excepted_count := l_excepted_count + 1;
                    trc_log_pkg.debug(
                        i_text       => 'Message with approval_code [#1], recon_inst_id [#2], oper_type [#3], oper_date [#4], ' 
                                     || 'terminal_number [#5], card_mask [#6]' 
                                     || ' already exists in HOST reconciliation table'
                      , i_env_param1 => i_oper_tab(i).approval_code
                      , i_env_param2 => l_recon_inst_id
                      , i_env_param3 => i_oper_tab(i).oper_type
                      , i_env_param4 => i_oper_tab(i).oper_date
                      , i_env_param5 => i_oper_tab(i).terminal_number
                      , i_env_param6 => iss_api_card_pkg.get_card_mask(i_oper_tab(i).card_number)
                    );
            end;
            
            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;
        
    end if;

    if l_rejected_count > 0 or l_excepted_count > 0 then
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_REJECTED;
    else
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_SUCCESS;
    end if;

    trc_log_pkg.debug(
        i_text          => 'upload finished: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
      , i_env_param1    => l_estimated_count
      , i_env_param2    => l_processed_count
      , i_env_param3    => l_excepted_count
      , i_env_param4    => l_rejected_count
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => l_result_code
    );

exception
    when others then
        rollback to savepoint process_start;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text          => 'Error: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
          , i_env_param1    => l_estimated_count
          , i_env_param2    => l_processed_count
          , i_env_param3    => l_excepted_count
          , i_env_param4    => l_rejected_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end process_host_batch;

procedure posting_not_recon_host_oper(
    i_recon_event_type in     com_api_type_pkg.t_dict_value
  , i_oper_status      in     com_api_type_pkg.t_dict_value
) is
    l_oper_id          com_api_type_pkg.t_long_id;
    l_session_id       com_api_type_pkg.t_long_id   :=  get_session_id;
    l_acq_participant  opr_api_type_pkg.t_oper_part_rec;
    l_iss_account      acc_api_type_pkg.t_account_rec;
    l_acq_account      acc_api_type_pkg.t_account_rec;
    l_card             iss_api_type_pkg.t_card_rec;
    l_excepted_count   com_api_type_pkg.t_count    := 0;
    l_processed_count  com_api_type_pkg.t_count    := 0;
    l_rejected_count   com_api_type_pkg.t_count    := 0;
    l_estimated_count  com_api_type_pkg.t_count    := 0;
    l_emv_tag_tab      com_api_type_pkg.t_tag_value_tab;
    l_emv_data         com_api_type_pkg.t_full_desc;
    l_auth_rec         aut_api_type_pkg.t_auth_rec;
    l_original_id      com_api_type_pkg.t_long_id;
    l_operation        opr_api_type_pkg.t_oper_rec;

    cursor cu_not_recon_host_oper(
        i_recon_event_type  in  com_api_type_pkg.t_dict_value
    ) is
        select o.id as event_object_id
             , m.id as host_msg_id
             , m.is_reversal
             , m.recon_inst_id
             , m.oper_type
             , m.oper_date
             , m.oper_amount
             , m.oper_currency
             , m.mcc
             , m.terminal_type
             , m.terminal_number
             , m.originator_refnum
             , m.merchant_number
             , m.merchant_name
             , m.merchant_street
             , m.merchant_city
             , m.merchant_region
             , m.merchant_country
             , m.merchant_postcode
             , m.oper_surcharge_amount
             , m.host_date
             , opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT   as msg_type
             , m.acq_inst_id
             , m.auth_code
             , m.card_mask
             , m.card_seq_number
             , m.card_expir_date
             , c.card_number
             , m.oper_id
             , m.oper_cashback_amount
             , m.oper_cashback_currency
             , m.service_code
             , m.approval_code
             , m.rrn
             , m.trn
             , m.original_id
             , m.emv_5f2a
             , m.emv_5f34
             , m.emv_71
             , m.emv_72
             , m.emv_82
             , m.emv_84
             , m.emv_8a
             , m.emv_91
             , m.emv_95
             , m.emv_9a
             , m.emv_9c
             , m.emv_9f02
             , m.emv_9f03
             , m.emv_9f06
             , m.emv_9f09
             , m.emv_9f10
             , m.emv_9f18
             , m.emv_9f1a
             , m.emv_9f1e
             , m.emv_9f26
             , m.emv_9f27
             , m.emv_9f28
             , m.emv_9f29
             , m.emv_9f33
             , m.emv_9f34
             , m.emv_9f35
             , m.emv_9f36
             , m.emv_9f37
             , m.emv_9f41
             , m.emv_9f53
             , m.pdc_1
             , m.pdc_2
             , m.pdc_3
             , m.pdc_4
             , m.pdc_5
             , m.pdc_6
             , m.pdc_7
             , m.pdc_8
             , m.pdc_9
             , m.pdc_10
             , m.pdc_11
             , m.pdc_12
             , m.forw_inst_code
             , m.receiv_inst_code
             , m.sttl_date
             , m.oper_reason
          from evt_event_object o
             , evt_event e
             , rcn_host_msg m
             , rcn_card c
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'RCN_PRC_IMPORT_PKG.POSTING_NOT_RECON_HOST_OPER'
           and o.event_id     = e.id
           and e.event_type   = i_recon_event_type
           and m.id           = o.object_id
           and o.entity_type  = rcn_api_const_pkg.ENTITY_TYPE_HOST_RECON
           and m.msg_source   = rcn_api_const_pkg.RECON_MSG_SOURCE_HOST
           and m.recon_status = rcn_api_const_pkg.RECON_STATUS_FAILED
           and c.id(+) = m.id
      order by o.id;

    type t_host_tab     is table of cu_not_recon_host_oper%rowtype index by binary_integer;
    l_host_tab          t_host_tab;

begin
    savepoint process_start;

    trc_log_pkg.info(i_text => 'Posting not reconciled hosts operations started' );
    prc_api_stat_pkg.log_start;

    if i_recon_event_type is not null and i_oper_status is not null then

        open cu_not_recon_host_oper(
            i_recon_event_type  => i_recon_event_type
        );

        loop
            fetch cu_not_recon_host_oper bulk collect
             into l_host_tab
            limit BULK_LIMIT;

            l_estimated_count := l_host_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count       => l_estimated_count
            );

            trc_log_pkg.debug(
                i_text       => 'l_estimated_count [#1]'
              , i_env_param1 => l_estimated_count
            );

            for i in 1 .. l_host_tab.count loop
                begin
                    l_oper_id := null;

                    l_original_id   := l_host_tab(i).oper_id;

                    opr_api_operation_pkg.get_operation(
                        i_oper_id    => l_original_id
                      , o_operation  => l_operation
                    );

                    opr_api_create_pkg.create_operation(
                        io_oper_id                => l_oper_id
                      , i_session_id              => l_session_id
                      , i_is_reversal             => l_host_tab(i).is_reversal
                      , i_original_id             => null
                      , i_oper_type               => l_host_tab(i).oper_type
                      , i_oper_reason             => null
                      , i_msg_type                => l_host_tab(i).msg_type
                      , i_status                  => i_oper_status
                      , i_status_reason           => null
                      , i_sttl_type               => l_operation.sttl_type
                      , i_terminal_type           => 'TRMT' || lpad(l_host_tab(i).terminal_type, 4, '0')
                      , i_acq_inst_bin            => l_operation.acq_inst_bin
                      , i_forw_inst_bin           => l_operation.forw_inst_bin
                      , i_merchant_number         => l_host_tab(i).merchant_number
                      , i_terminal_number         => l_host_tab(i).terminal_number
                      , i_merchant_name           => l_host_tab(i).merchant_name
                      , i_merchant_street         => l_host_tab(i).merchant_street
                      , i_merchant_city           => l_host_tab(i).merchant_city
                      , i_merchant_region         => l_host_tab(i).merchant_region
                      , i_merchant_country        => l_host_tab(i).merchant_country
                      , i_merchant_postcode       => l_host_tab(i).merchant_postcode
                      , i_mcc                     => l_host_tab(i).mcc
                      , i_originator_refnum       => l_host_tab(i).rrn
                      , i_network_refnum          => l_operation.network_refnum
                      , i_oper_count              => 1
                      , i_oper_request_amount     => null
                      , i_oper_amount_algorithm   => null
                      , i_oper_amount             => l_host_tab(i).oper_amount
                      , i_oper_currency           => l_host_tab(i).oper_currency
                      , i_oper_cashback_amount    => l_host_tab(i).oper_cashback_amount
                      , i_oper_replacement_amount => null
                      , i_oper_surcharge_amount   => l_host_tab(i).oper_surcharge_amount
                      , i_oper_date               => l_host_tab(i).oper_date
                      , i_host_date               => l_host_tab(i).host_date
                      , i_match_status            => null
                      , i_sttl_amount             => null
                      , i_sttl_currency           => null
                      , i_dispute_id              => null
                      , i_payment_order_id        => null
                      , i_payment_host_id         => null
                      , i_forced_processing       => com_api_const_pkg.FALSE
                      , i_proc_mode               => null
                      , i_incom_sess_file_id      => null
                      , i_sttl_date               => null
                    );

                    if      l_host_tab(i).pdc_1 is not null
                        or  l_host_tab(i).pdc_2 is not null
                        or  l_host_tab(i).pdc_3 is not null
                        or  l_host_tab(i).pdc_4 is not null
                        or  l_host_tab(i).pdc_5 is not null
                        or  l_host_tab(i).pdc_6 is not null
                        or  l_host_tab(i).pdc_7 is not null
                        or  l_host_tab(i).pdc_8 is not null
                        or  l_host_tab(i).pdc_9 is not null
                        or  l_host_tab(i).pdc_10 is not null
                        or  l_host_tab(i).pdc_11 is not null
                        or  l_host_tab(i).pdc_12 is not null
                    then
                        l_host_tab(i).msg_type   := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;

                        l_emv_tag_tab('5F2A')   := l_host_tab(i).emv_5f2a;
                        l_emv_tag_tab('5F34')   := l_host_tab(i).emv_5f34;
                        l_emv_tag_tab('71')     := l_host_tab(i).emv_71;
                        l_emv_tag_tab('72')     := l_host_tab(i).emv_72;
                        l_emv_tag_tab('82')     := l_host_tab(i).emv_82;
                        l_emv_tag_tab('84')     := l_host_tab(i).emv_84;
                        l_emv_tag_tab('8A')     := l_host_tab(i).emv_8a;
                        l_emv_tag_tab('91')     := l_host_tab(i).emv_91;
                        l_emv_tag_tab('95')     := l_host_tab(i).emv_95;
                        l_emv_tag_tab('9A')     := l_host_tab(i).emv_9a;
                        l_emv_tag_tab('9C')     := l_host_tab(i).emv_9c;
                        l_emv_tag_tab('9F02')   := l_host_tab(i).emv_9f02;
                        l_emv_tag_tab('9F03')   := l_host_tab(i).emv_9f03;
                        l_emv_tag_tab('9F06')   := l_host_tab(i).emv_9f06;
                        l_emv_tag_tab('9F09')   := l_host_tab(i).emv_9f09;
                        l_emv_tag_tab('9F10')   := l_host_tab(i).emv_9f10;
                        l_emv_tag_tab('9F18')   := l_host_tab(i).emv_9f18;
                        l_emv_tag_tab('9F1A')   := l_host_tab(i).emv_9f1a;
                        l_emv_tag_tab('9F1E')   := l_host_tab(i).emv_9f1e;
                        l_emv_tag_tab('9F26')   := l_host_tab(i).emv_9f26;
                        l_emv_tag_tab('9F27')   := l_host_tab(i).emv_9f27;
                        l_emv_tag_tab('9F28')   := l_host_tab(i).emv_9f28;
                        l_emv_tag_tab('9F29')   := l_host_tab(i).emv_9f29;
                        l_emv_tag_tab('9F33')   := l_host_tab(i).emv_9f33;
                        l_emv_tag_tab('9F34')   := l_host_tab(i).emv_9f34;
                        l_emv_tag_tab('9F35')   := l_host_tab(i).emv_9f35;
                        l_emv_tag_tab('9F36')   := l_host_tab(i).emv_9f36;
                        l_emv_tag_tab('9F37')   := l_host_tab(i).emv_9f37;
                        l_emv_tag_tab('9F41')   := l_host_tab(i).emv_9f41;
                        l_emv_tag_tab('9F53')   := l_host_tab(i).emv_9f53;

                        if l_emv_tag_tab.count > 0 then
                            l_emv_data :=
                                hextoraw(
                                    emv_api_tag_pkg.format_emv_data(
                                        io_emv_tag_tab    => l_emv_tag_tab
                                      , i_tag_type_tab    => rcn_api_const_pkg.EMV_TAGS_LIST_FOR_HOSTS
                                    )
                                );
                        end if;

                        l_auth_rec.id                          := l_oper_id;
                        l_auth_rec.resp_code                   := aup_api_const_pkg.RESP_CODE_OK;
                        l_auth_rec.proc_type                   := aut_api_const_pkg.AUTH_PROC_TYPE_LOAD;
                        l_auth_rec.proc_mode                   := aut_api_const_pkg.AUTH_PROC_MODE_NORMAL;
                        l_auth_rec.is_advice                   := com_api_const_pkg.FALSE;
                        l_auth_rec.is_repeat                   := com_api_const_pkg.FALSE;
                        l_auth_rec.bin_amount                  := null;
                        l_auth_rec.bin_currency                := null;
                        l_auth_rec.bin_cnvt_rate               := null;
                        l_auth_rec.network_amount              := null;
                        l_auth_rec.network_currency            := null;
                        l_auth_rec.network_cnvt_date           := null;
                        l_auth_rec.network_cnvt_rate           := null;
                        l_auth_rec.account_cnvt_rate           := null;
                        l_auth_rec.parent_id                   := null;
                        l_auth_rec.addr_verif_result           := null;
                        l_auth_rec.iss_network_device_id       := null;
                        l_auth_rec.acq_device_id               := null;
                        l_auth_rec.acq_resp_code               := null;
                        l_auth_rec.acq_device_proc_result      := null;
                        l_auth_rec.cat_level                   := null;

                        l_auth_rec.card_data_input_cap         := 'F221' || lpad(l_host_tab(i).pdc_1, 4, '0');
                        l_auth_rec.crdh_auth_cap               := 'F222' || lpad(l_host_tab(i).pdc_2, 4, '0');
                        l_auth_rec.card_capture_cap            := 'F223' || lpad(l_host_tab(i).pdc_3, 4, '0');
                        l_auth_rec.terminal_operating_env      := 'F224' || lpad(l_host_tab(i).pdc_4, 4, '0');
                        l_auth_rec.crdh_presence               := 'F225' || lpad(l_host_tab(i).pdc_5, 4, '0');
                        l_auth_rec.card_presence               := 'F226' || lpad(l_host_tab(i).pdc_6, 4, '0');
                        l_auth_rec.card_data_input_mode        := 'F227' || lpad(l_host_tab(i).pdc_7, 4, '0');
                        l_auth_rec.crdh_auth_method            := 'F228' || lpad(l_host_tab(i).pdc_8, 4, '0');
                        l_auth_rec.crdh_auth_entity            := 'F229' || lpad(l_host_tab(i).pdc_9, 4, '0');
                        l_auth_rec.card_data_output_cap        := 'F22A' || lpad(l_host_tab(i).pdc_10, 4, '0');
                        l_auth_rec.terminal_output_cap         := 'F22B' || lpad(l_host_tab(i).pdc_11, 4, '0');
                        l_auth_rec.pin_capture_cap             := 'F22C' || lpad(l_host_tab(i).pdc_12, 4, '0');

                        l_auth_rec.pin_presence                := null;
                        l_auth_rec.cvv2_presence               := null;
                        l_auth_rec.cvc_indicator               := null;
                        l_auth_rec.pos_entry_mode              := null;
                        l_auth_rec.pos_cond_code               := null;
                        l_auth_rec.emv_data                    := l_emv_data;
                        l_auth_rec.atc                         := null;
                        l_auth_rec.tvr                         := null;
                        l_auth_rec.cvr                         := null;
                        l_auth_rec.addl_data                   := null;
                        l_auth_rec.service_code                := null;
                        l_auth_rec.device_date                 := null;
                        l_auth_rec.cvv2_result                 := null;
                        l_auth_rec.certificate_method          := null;
                        l_auth_rec.certificate_type            := null;
                        l_auth_rec.merchant_certif             := null;
                        l_auth_rec.cardholder_certif           := null;
                        l_auth_rec.ucaf_indicator              := null;
                        l_auth_rec.is_early_emv                := null;
                        l_auth_rec.is_completed                := null;
                        l_auth_rec.amounts                     := null;
                        l_auth_rec.cavv_presence               := null;
                        l_auth_rec.aav_presence                := null;
                        l_auth_rec.system_trace_audit_number   := null;
                        l_auth_rec.transaction_id              := null;
                        l_auth_rec.external_auth_id            := null;
                        l_auth_rec.external_orig_id            := null;
                        l_auth_rec.agent_unique_id             := null;
                        l_auth_rec.native_resp_code            := null;
                        l_auth_rec.trace_number                := null;
                        l_auth_rec.auth_purpose_id             := null;

                        aut_api_auth_pkg.save_auth(i_auth => l_auth_rec);
                    end if;

                    begin
                        -- our device
                        acq_api_terminal_pkg.get_terminal(
                            i_inst_id          => l_host_tab(i).recon_inst_id
                          , i_merchant_number  => l_host_tab(i).merchant_number
                          , i_terminal_number  => l_host_tab(i).terminal_number
                          , o_merchant_id      => l_acq_participant.merchant_id
                          , o_terminal_id      => l_acq_participant.terminal_id
                        );
                    exception
                        when others then
                            null;
                    end;

                    l_acq_account :=
                        acc_api_account_pkg.get_account(
                            i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                          , i_object_id    => l_acq_participant.terminal_id
                          , i_account_type => acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
                          , i_currency     => l_host_tab(i).oper_currency
                        );

                    -- our card
                    l_card :=
                        iss_api_card_pkg.get_card(
                            i_card_number  => l_host_tab(i).card_number
                          , i_inst_id      => l_host_tab(i).recon_inst_id
                          , i_mask_error   => com_api_const_pkg.TRUE
                        );

                    l_iss_account :=
                        acc_api_account_pkg.get_account(
                            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
                          , i_object_id     => l_card.id
                          , i_account_type  => acc_api_const_pkg.ACCOUNT_TYPE_CARD
                          , i_currency      => l_host_tab(i).oper_currency
                        ); 

                    opr_api_create_pkg.add_participant(
                        i_oper_id           => l_oper_id
                      , i_msg_type          => l_host_tab(i).msg_type
                      , i_oper_type         => l_host_tab(i).oper_type
                      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
                      , i_host_date         => l_host_tab(i).host_date
                      , i_inst_id           => l_host_tab(i).acq_inst_id
                      , i_network_id        => null
                      , i_account_type      => l_acq_account.account_type
                      , i_account_number    => l_acq_account.account_number
                      , i_merchant_id       => l_acq_participant.merchant_id
                      , i_merchant_number   => l_host_tab(i).merchant_number
                      , i_terminal_id       => l_acq_participant.terminal_id
                      , i_terminal_number   => l_host_tab(i).terminal_number
                      , i_split_hash        => l_acq_account.split_hash
                      , i_without_checks    => com_api_const_pkg.FALSE
                      , i_mask_error        => com_api_type_pkg.TRUE
                    );

                    opr_api_create_pkg.add_participant(
                        i_oper_id           => l_oper_id
                      , i_msg_type          => l_host_tab(i).msg_type
                      , i_oper_type         => l_host_tab(i).oper_type
                      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                      , i_host_date         => l_host_tab(i).host_date
                      , i_inst_id           => l_iss_account.inst_id
                      , i_network_id        => null --l_iss_part.network_id
                      , i_customer_id       => l_card.customer_id --l_iss_part.customer_id
                      , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID
                      , i_client_id_value   => l_card.id
                      , i_card_id           => l_card.id
                      , i_card_type_id      => l_card.card_type_id
                      , i_card_expir_date   => l_host_tab(i).card_expir_date
                      , i_card_seq_number   => l_host_tab(i).card_seq_number
                      , i_card_service_code => null --l_iss_part.card_service_code
                      , i_card_number       => l_host_tab(i).card_number
                      , i_card_mask         => l_host_tab(i).card_mask
                      , i_card_hash         => l_card.card_hash
                      , i_card_country      => null
                      , i_card_inst_id      => l_card.inst_id
                      , i_card_network_id   => null --l_iss_part.card_network_id
                      , i_account_id        => l_iss_account.account_id
                      , i_account_number    => l_iss_account.account_number
                      , i_account_type      => l_iss_account.account_type
                      , i_account_amount    => null
                      , i_account_currency  => l_iss_account.currency
                      , i_auth_code         => l_host_tab(i).auth_code
                      , i_split_hash        => l_card.split_hash
                      , i_without_checks    => com_api_const_pkg.FALSE
                      , i_mask_error        => com_api_type_pkg.TRUE
                    );

                    evt_api_event_pkg.process_event_object(
                        i_event_object_id => l_host_tab(i).event_object_id
                    );

                    l_processed_count := l_processed_count + 1;

                    if mod(l_processed_count, 100) = 0 then
                        prc_api_stat_pkg.log_current(
                            i_current_count    => l_processed_count
                          , i_excepted_count   => l_excepted_count
                        );
                end if;
                exception
                    when com_api_error_pkg.e_application_error then
                        evt_api_event_pkg.process_event_object(
                            i_event_object_id => l_host_tab(i).event_object_id
                        );

                        trc_log_pkg.error('error creating operation for rcn_host_msg.id=' || l_host_tab(i).host_msg_id || ': ' || sqlerrm);
                        l_excepted_count := l_excepted_count + 1;
                end;
            end loop;
            exit when cu_not_recon_host_oper%notfound;
        end loop;
   end if;

   prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    trc_log_pkg.info(i_text => 'Posting not reconciled hosts operations finished');

exception
    when others then
        rollback to savepoint process_start;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text          => 'Error: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
          , i_env_param1    => l_estimated_count
          , i_env_param2    => l_processed_count
          , i_env_param3    => l_excepted_count
          , i_env_param4    => l_rejected_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end posting_not_recon_host_oper;

procedure process_srvp_batch(
    i_order_tab         in      rcn_srvp_msg_tpt
  , i_param_tab         in      com_param_map_tpt
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_srvp_batch: ';
    l_estimated_count           com_api_type_pkg.t_long_id    := 0;
    l_processed_count           com_api_type_pkg.t_long_id    := 0;
    l_excepted_count            com_api_type_pkg.t_long_id    := 0;
    l_rejected_count            com_api_type_pkg.t_long_id    := 0;
    l_msg_date                  date;
    l_result_code               com_api_type_pkg.t_dict_value;
    l_name                      com_api_type_pkg.t_name;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_session_id                com_api_type_pkg.t_long_id;
    l_thread_number             com_api_type_pkg.t_tiny_id;

    l_proc_order_tab            rcn_srvp_msg_tpt              := rcn_srvp_msg_tpt();
    l_srvp_msg_id               com_api_type_pkg.t_long_id;
    l_srvp_data_id              com_api_type_pkg.t_long_id;
    l_pmo_param_id              com_api_type_pkg.t_short_id;
    l_param_value               com_api_type_pkg.t_param_value;
begin
    savepoint process_srvp_start;

    trc_log_pkg.info(
        i_text          => LOG_PREFIX || 'Service provider reconciliation batch upload started'
    );

    l_session_id       := prc_api_session_pkg.get_session_id;
    l_thread_number    := prc_api_session_pkg.get_thread_number;

    begin
        select nvl(estimated_count, 0)
             , nvl(processed_total, 0)
             , nvl(excepted_total,  0)
             , nvl(rejected_total,  0)
          into l_estimated_count
             , l_processed_count
             , l_excepted_count
             , l_rejected_count
          from prc_stat
         where session_id    = l_session_id
           and thread_number = l_thread_number;
    exception when no_data_found then
        prc_api_stat_pkg.log_start;
    end;

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Previous values: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
      , i_env_param1    => l_estimated_count
      , i_env_param2    => l_processed_count
      , i_env_param3    => l_excepted_count
      , i_env_param4    => l_rejected_count
    );

    l_estimated_count := nvl(i_order_tab.count,0) + l_estimated_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_estimated_count [#1], i_oper_tab.count [#2]'
      , i_env_param1 => l_estimated_count
      , i_env_param2 => i_order_tab.count
    );

    l_msg_date := com_api_sttl_day_pkg.get_sysdate;

    if nvl(i_order_tab.count, 0) > 0 then

        utl_data_pkg.print_table(i_param_tab => i_param_tab);

        if i_param_tab is not null then
            for i in 1 .. i_param_tab.count loop
                l_name := upper(i_param_tab(i).name);

                if l_name in ('INST_ID')
                   and i_param_tab(i).number_value is null
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
                      , i_env_param1 => l_name
                    );
                end if;

                if l_name = 'INST_ID' then
                    l_inst_id := i_param_tab(i).number_value;
                end if;

            end loop;
        end if;

        for i in 1 .. i_order_tab.count loop

            l_proc_order_tab.extend;
            l_proc_order_tab(i) := i_order_tab(i);

            if i_order_tab(i).customer_number is not null then
                l_proc_order_tab(i).customer_id :=
                    prd_api_customer_pkg.get_customer_id(
                        i_customer_number   => i_order_tab(i).customer_number
                      , i_inst_id           => l_inst_id
                      , i_mask_error        => com_api_const_pkg.TRUE
                    );
                if l_proc_order_tab(i).customer_id is null then
                    l_excepted_count := l_excepted_count + 1;
                    trc_log_pkg.debug(
                        i_text       => 'Cannot find customer_id by customer_number [#2] for payment_order_id [#3]. Error [#1]'
                      , i_env_param1 => sqlerrm
                      , i_env_param2 => i_order_tab(i).customer_number
                      , i_env_param3 => i_order_tab(i).order_id
                    );
                end if;
            else
                l_excepted_count := l_excepted_count + 1;
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'Message with order_id [#1], recon_inst_id [#2], customer_id [#3], ' 
                                 || 'purpose_id [#4], provider_id [#5] already exists in reconciliation table'
                  , i_env_param1 => l_proc_order_tab(i).order_id
                  , i_env_param2 => l_inst_id
                  , i_env_param3 => l_proc_order_tab(i).customer_id
                  , i_env_param4 => l_proc_order_tab(i).purpose_id
                  , i_env_param5 => l_proc_order_tab(i).provider_id
                );
            end if;

            if i_order_tab(i).provider_number is not null then
                l_proc_order_tab(i).provider_id :=
                    pmo_api_provider_pkg.get_provider_id(
                        i_provider_number   => i_order_tab(i).provider_number
                      , i_inst_id           => l_inst_id
                      , i_mask_error        => com_api_const_pkg.TRUE
                    );
                if l_proc_order_tab(i).provider_id is null then
                    l_excepted_count := l_excepted_count + 1;
                    trc_log_pkg.debug(
                        i_text       => 'Cannot find provider_id by provider_number [#2] for payment_order_id [#3]. Error [#1]'
                      , i_env_param1 => sqlerrm
                      , i_env_param2 => i_order_tab(i).provider_number
                      , i_env_param3 => i_order_tab(i).order_id
                    );
                end if;
            else
                l_excepted_count := l_excepted_count + 1;
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'Message with order_id [#1], recon_inst_id [#2], customer_id [#3], ' 
                                 || 'purpose_id [#4], provider_id [#5] already exists in reconciliation table'
                  , i_env_param1 => l_proc_order_tab(i).order_id
                  , i_env_param2 => l_inst_id
                  , i_env_param3 => l_proc_order_tab(i).customer_id
                  , i_env_param4 => l_proc_order_tab(i).purpose_id
                  , i_env_param5 => l_proc_order_tab(i).provider_id
                );
            end if;

            if i_order_tab(i).purpose_number is not null then
                l_proc_order_tab(i).purpose_id :=
                    pmo_api_provider_pkg.get_purpose_id(
                        i_purpose_number    => i_order_tab(i).purpose_number
                      , i_inst_id           => l_inst_id
                      , i_mask_error        => com_api_const_pkg.TRUE
                    );

                l_proc_order_tab(i).split_hash := com_api_hash_pkg.get_split_hash(l_proc_order_tab(i).purpose_id);

                if l_proc_order_tab(i).purpose_id is null then
                    l_excepted_count := l_excepted_count + 1;
                    trc_log_pkg.debug(
                        i_text       => 'Cannot find purpose_id by purpose_number [#2] for payment_order_id [#3]. Error [#1]'
                      , i_env_param1 => sqlerrm
                      , i_env_param2 => i_order_tab(i).purpose_number
                      , i_env_param3 => i_order_tab(i).order_id
                    );
                end if;
            else
                l_excepted_count := l_excepted_count + 1;

                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'Message with order_id [#1], recon_inst_id [#2], customer_id [#3], '
                                 || 'purpose_id [#4], provider_id [#5] already exists in reconciliation table'
                  , i_env_param1 => l_proc_order_tab(i).order_id
                  , i_env_param2 => l_inst_id
                  , i_env_param3 => l_proc_order_tab(i).customer_id
                  , i_env_param4 => l_proc_order_tab(i).purpose_id
                  , i_env_param5 => l_proc_order_tab(i).provider_id
                );
            end if;

            begin
                l_srvp_msg_id := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);

                insert into rcn_srvp_msg(
                    id
                  , recon_type
                  , msg_source
                  , recon_status
                  , msg_date
                  , recon_date
                  , inst_id
                  , split_hash
                  , order_id
                  , recon_msg_id
                  , payment_order_number
                  , order_date
                  , order_amount
                  , order_currency
                  , customer_id
                  , customer_number
                  , purpose_id
                  , purpose_number
                  , provider_id
                  , provider_number
                  , order_status
                ) values (
                    l_srvp_msg_id
                  , rcn_api_const_pkg.RECON_TYPE_SRVP
                  , rcn_api_const_pkg.RECON_MSG_SOURCE_SRVP
                  , rcn_api_const_pkg.RECON_STATUS_REQ_RECON
                  , l_msg_date
                  , null
                  , l_inst_id
                  , l_proc_order_tab(i).split_hash
                  , l_proc_order_tab(i).order_id
                  , null
                  , l_proc_order_tab(i).payment_order_number
                  , l_proc_order_tab(i).order_date
                  , l_proc_order_tab(i).order_amount
                  , l_proc_order_tab(i).order_currency
                  , l_proc_order_tab(i).customer_id
                  , l_proc_order_tab(i).customer_number
                  , l_proc_order_tab(i).purpose_id
                  , l_proc_order_tab(i).purpose_number
                  , l_proc_order_tab(i).provider_id
                  , l_proc_order_tab(i).provider_number
                  , l_proc_order_tab(i).order_status
                );

                for j in 1..l_proc_order_tab(i).params.count loop

                    l_srvp_data_id  := com_api_id_pkg.get_id(rcn_msg_seq.nextval, l_msg_date);

                    l_pmo_param_id  :=
                        pmo_api_parameter_pkg.get_pmo_parameter_id(
                            i_param_name => l_proc_order_tab(i).params(j).name
                          , i_mask_error => com_api_const_pkg.FALSE
                        );

                    if l_proc_order_tab(i).params(j).char_value is not null then
                        l_param_value := l_proc_order_tab(i).params(j).char_value;
                    elsif l_proc_order_tab(i).params(j).number_value is not null then
                        l_param_value := to_char(l_proc_order_tab(i).params(j).number_value, com_api_const_pkg.NUMBER_FORMAT);
                    elsif l_proc_order_tab(i).params(j).date_value is not null then
                        l_param_value := to_char(l_proc_order_tab(i).params(j).date_value, com_api_const_pkg.DATE_FORMAT);
                    else
                        l_param_value := null;
                    end if;

                    begin
                        insert into rcn_srvp_data(
                            id
                          , msg_id
                          , purpose_id
                          , param_id
                          , param_value
                        ) values (
                            l_srvp_data_id
                          , l_srvp_msg_id
                          , l_proc_order_tab(i).purpose_id
                          , l_pmo_param_id
                          , l_param_value
                        );
                    exception
                        when dup_val_on_index then
                            l_excepted_count := l_excepted_count + 1;
                            trc_log_pkg.debug(
                                i_text       => LOG_PREFIX || 'Message parameter with order_id [#1], l_inst_id [#2], purpose_id [#3], '
                                             || 'l_param_id [#4], l_param_value [#5] already exists in reconciliation table'
                              , i_env_param1 => l_proc_order_tab(i).order_id
                              , i_env_param2 => l_inst_id
                              , i_env_param3 => l_proc_order_tab(i).purpose_id
                              , i_env_param4 => l_pmo_param_id
                              , i_env_param5 => l_param_value
                            );
                    end;
                end loop;

                l_processed_count := l_processed_count + 1;
            exception
                when dup_val_on_index then
                    l_excepted_count := l_excepted_count + 1;
                    trc_log_pkg.debug(
                        i_text       => LOG_PREFIX || 'Message with order_id [#1], recon_inst_id [#2], customer_id [#3], ' 
                                     || 'purpose_id [#4], provider_id [#5] already exists in reconciliation table'
                      , i_env_param1 => l_proc_order_tab(i).order_id
                      , i_env_param2 => l_inst_id
                      , i_env_param3 => l_proc_order_tab(i).customer_id
                      , i_env_param4 => l_proc_order_tab(i).purpose_id
                      , i_env_param5 => l_proc_order_tab(i).provider_id
                    );
            end;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;

    end if;

    if (l_rejected_count > 0 or l_excepted_count > 0) then
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_REJECTED;
    else
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_SUCCESS;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => l_result_code
    );

    com_api_sttl_day_pkg.unset_sysdate;

    trc_log_pkg.info(
        i_text  => 'Service provider reconciliation upload finished'
    );

exception
    when others then
        rollback to savepoint process_srvp_start;
        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text          => LOG_PREFIX || 'Error: estimated_count [#1] processed_count [#2] excepted_count [#3] rejected_count [#4]'
          , i_env_param1    => l_estimated_count
          , i_env_param2    => l_processed_count
          , i_env_param3    => l_excepted_count
          , i_env_param4    => l_rejected_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end process_srvp_batch;

end;
/
