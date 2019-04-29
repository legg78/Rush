create or replace package body mcw_prc_migs_pkg is
/**********************************************************
 * Process load DCF for MasterCard Internet Gateway System <br />
 * This gateway supported not only cards of the MasterCard IPS <br />
 * but cards of others IPS such as Visa, JCB, Amex, etc <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 21.12.2016 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: MCW_PRC_MIGS_PKG
 * @headcom
 **********************************************************/

CRLF                           constant com_api_type_pkg.t_name := chr(13) || chr(10);

procedure register_auth_data(
    i_auth_data    in aut_api_type_pkg.t_auth_rec
)
is

    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_auth_data: ';
    
begin
    
    trc_log_pkg.debug(i_text => LOG_PREFIX || 'START for oper_id[' || i_auth_data.id || ']');
    
    insert into aut_auth (
        id
      , resp_code
      , proc_type
      , proc_mode
      , is_advice
      , is_repeat
      , bin_amount
      , bin_currency
      , bin_cnvt_rate
      , network_amount
      , network_currency
      , network_cnvt_date
      , network_cnvt_rate
      , account_cnvt_rate
      , parent_id
      , addr_verif_result
      , iss_network_device_id
      , acq_device_id
      , acq_resp_code
      , acq_device_proc_result
      , cat_level
      , card_data_input_cap
      , crdh_auth_cap
      , card_capture_cap
      , terminal_operating_env
      , crdh_presence
      , card_presence
      , card_data_input_mode
      , crdh_auth_method
      , crdh_auth_entity
      , card_data_output_cap
      , terminal_output_cap
      , pin_capture_cap
      , pin_presence
      , cvv2_presence
      , cvc_indicator
      , pos_entry_mode
      , pos_cond_code
      , emv_data
      , atc
      , tvr
      , cvr
      , addl_data
      , service_code
      , device_date
      , cvv2_result
      , certificate_method
      , certificate_type
      , merchant_certif
      , cardholder_certif
      , ucaf_indicator
      , is_early_emv
      , is_completed
      , amounts
      , cavv_presence
      , aav_presence
      , system_trace_audit_number
      , transaction_id
      , external_auth_id
      , external_orig_id
      , agent_unique_id
      , native_resp_code
      , trace_number
      , auth_purpose_id
     ) values (
        i_auth_data.id
      , i_auth_data.resp_code
      , i_auth_data.proc_type
      , i_auth_data.proc_mode
      , i_auth_data.is_advice
      , i_auth_data.is_repeat
      , i_auth_data.bin_amount
      , i_auth_data.bin_currency
      , i_auth_data.bin_cnvt_rate
      , i_auth_data.network_amount
      , i_auth_data.network_currency
      , i_auth_data.network_cnvt_date
      , i_auth_data.network_cnvt_rate
      , i_auth_data.account_cnvt_rate
      , i_auth_data.parent_id
      , i_auth_data.addr_verif_result
      , i_auth_data.iss_network_device_id
      , i_auth_data.acq_device_id
      , i_auth_data.acq_resp_code
      , i_auth_data.acq_device_proc_result
      , i_auth_data.cat_level
      , i_auth_data.card_data_input_cap
      , i_auth_data.crdh_auth_cap
      , i_auth_data.card_capture_cap
      , i_auth_data.terminal_operating_env
      , i_auth_data.crdh_presence
      , i_auth_data.card_presence
      , i_auth_data.card_data_input_mode
      , i_auth_data.crdh_auth_method
      , i_auth_data.crdh_auth_entity
      , i_auth_data.card_data_output_cap
      , i_auth_data.terminal_output_cap
      , i_auth_data.pin_capture_cap
      , i_auth_data.pin_presence
      , i_auth_data.cvv2_presence
      , i_auth_data.cvc_indicator
      , i_auth_data.pos_entry_mode
      , i_auth_data.pos_cond_code
      , i_auth_data.emv_data
      , i_auth_data.atc
      , i_auth_data.tvr
      , i_auth_data.cvr
      , i_auth_data.addl_data
      , i_auth_data.service_code
      , i_auth_data.device_date
      , i_auth_data.cvv2_result
      , i_auth_data.certificate_method
      , i_auth_data.certificate_type
      , i_auth_data.merchant_certif
      , i_auth_data.cardholder_certif
      , i_auth_data.ucaf_indicator
      , i_auth_data.is_early_emv
      , i_auth_data.is_completed
      , i_auth_data.amounts
      , i_auth_data.cavv_presence
      , i_auth_data.aav_presence
      , i_auth_data.system_trace_audit_number
      , i_auth_data.transaction_id
      , i_auth_data.external_auth_id
      , i_auth_data.external_orig_id
      , i_auth_data.agent_unique_id
      , i_auth_data.native_resp_code
      , i_auth_data.trace_number
      , i_auth_data.auth_purpose_id
    );
    
    trc_log_pkg.debug(i_text => LOG_PREFIX || 'FINISH for oper_id[' || i_auth_data.id || ']');
    
end register_auth_data;

procedure load
is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load: ';
    
    l_record_count      com_api_type_pkg.t_long_id := 0;
    l_estimated_count   com_api_type_pkg.t_long_id := 0;
    l_excepted_count    com_api_type_pkg.t_long_id := 0;
    l_processed_count   com_api_type_pkg.t_long_id := 0;
    l_errors_count      com_api_type_pkg.t_long_id := 0;
    
    l_record_type       mcw_api_migs_type_pkg.t_dcf_record_type;
    l_count             com_api_type_pkg.t_long_id := 0;
    
    l_oper_rec          opr_api_type_pkg.t_oper_rec;
    l_iss_participant   opr_api_type_pkg.t_oper_part_rec;
    l_acq_participant   opr_api_type_pkg.t_oper_part_rec;
    l_auth_data         aut_api_type_pkg.t_auth_rec;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    
    trc_log_pkg.debug(i_text => LOG_PREFIX || 'START');
    
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;
    
    trc_log_pkg.debug(i_text => LOG_PREFIX || 'FOUND ' || l_record_count || ' IN FILE');

    for p in (
        select id session_file_id
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
    
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id
                   || ']'
        );
        
        l_errors_count := 0;
        
        l_count := 0;
        
        begin
            for r in (
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number asc
            ) loop
            
                l_record_type := mcw_api_migs_pkg.get_record_type(
                                     i_record_str => r.raw_data
                                 );
                                 
                mcw_api_migs_pkg.parse_dcf_record_exec(
                    i_record_number      => r.record_number
                  , i_record_type        => l_record_type
                  , i_record_str         => r.raw_data
                  , i_incom_sess_file_id => p.session_file_id
                );
                
                l_count := r.record_number;
                
            end loop;
            
            trc_log_pkg.debug(
                i_text => 'Processing session_file_id [' || p.session_file_id
                       || '] finished, record_count [' || l_count || ']'
            );

            prc_api_file_pkg.close_file(
                i_sess_file_id => p.session_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count => l_count
            );
            
        exception
            when others then

                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                  , i_record_count => l_count
                );

                raise;
        end;
        
    end loop;
    
    if l_record_count > 0 then
        for i in 1 .. mcw_api_migs_pkg.g_dcf_fin_messages.last
        loop
            
            if mcw_api_migs_pkg.g_dcf_fin_messages(i).fin_message_detail.exists(1) then
                
                l_estimated_count := l_estimated_count + mcw_api_migs_pkg.g_dcf_fin_messages(i).fin_message_detail.last;
                
            end if;
            
        end loop;
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );
        
        for i in 1 .. mcw_api_migs_pkg.g_dcf_fin_messages.last
        loop
            
            for j in 1 .. mcw_api_migs_pkg.g_dcf_fin_messages(i).fin_message_detail.last
            loop
                
                begin
                    
                    savepoint sp_create_operation;
                    
                    mcw_api_migs_pkg.fin_message_operate_mapping(
                        i_header_index => i
                      , i_detail_index => j
                      , o_operate      => l_oper_rec
                      , o_iss_part     => l_iss_participant
                      , o_acq_part     => l_acq_participant
                      , o_auth_data    => l_auth_data
                    );
                    
                    mcw_api_migs_pkg.check_duplication_operation(
                        i_operate      => l_oper_rec
                    );
                    
                    opr_api_create_pkg.create_operation(
                        i_oper         => l_oper_rec
                      , i_iss_part     => l_iss_participant
                      , i_acq_part     => l_acq_participant
                    );
                    
                    l_auth_data.id    := l_oper_rec.id;
                    
                    register_auth_data(
                        i_auth_data    => l_auth_data
                    );
                    
                    mcw_api_migs_pkg.internal_matching(
                        i_operation_id => l_oper_rec.id
                    );
                    
                    l_processed_count := l_processed_count + 1;
                    
                exception
                    when others then
                        
                        rollback to sp_create_operation;
                        l_excepted_count := l_excepted_count + 1;
                        trc_log_pkg.debug(LOG_PREFIX || ' ERROR CREATING OPERATION: ' || SQLERRM || CRLF
                                                     || ' main_index   - ' || i || CRLF
                                                     || ' detail_index - ' || j
                        );
                end;
            
            end loop;
            
        end loop;
        
    else
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => 0
        );
        
    end if;
    
    if l_estimated_count > 0
        and l_processed_count = 0
    then

        com_api_error_pkg.raise_error(
            i_error         => 'NOT_CREATED_ANY_ONE_OPERATION'
        );
        
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
        if cu_records_count%isopen then
            
            close cu_records_count;
            
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total => l_processed_count
          , i_excepted_total  => l_excepted_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            
            raise;
            
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            
            raise;
            
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
            
        end if;
        
end load;

end mcw_prc_migs_pkg;
/
