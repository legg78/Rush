create or replace package body bgn_api_fin_pkg as

    g_column_list       constant com_api_type_pkg.t_text :=
       '  f.id'
    || ', f.file_id'
    || ', f.status'
    || ', f.is_reversal'
    || ', f.dispute_id'
    || ', f.inst_id'
    || ', f.host_inst_id'
    || ', f.network_id'
    || ', f.is_incoming'
    || ', f.package_id'
    || ', f.record_type'
    || ', f.record_number'
    || ', f.transaction_date'
    || ', f.transaction_type'
    || ', f.is_reject'
    || ', f.is_finance'
    || ', c.id'
    || ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
    || ', f.card_mask'
    || ', f.card_seq_number'
    || ', f.card_expire_date'
    || ', f.card_type'
    || ', f.acquirer_amount'
    || ', f.acquirer_currency'
    || ', f.network_amount'
    || ', f.network_currency'
    || ', f.card_amount'
    || ', f.card_currency'
    || ', f.auth_code'
    || ', f.trace_number'
    || ', f.retrieval_refnum'
    || ', f.merchant_number'
    || ', f.merchant_name'
    || ', f.merchant_city'
    || ', f.mcc'
    || ', f.terminal_number'
    || ', f.pos_entry_mode'
    || ', f.ain'
    || ', f.auth_indicator'
    || ', f.transaction_number'
    || ', f.validation_code'
    || ', f.market_data_id'
    || ', f.add_response_data'
    || ', f.reject_code'
    || ', f.response_code'
    || ', f.reject_text'
    || ', f.is_offline'
    || ', f.pos_text'
    || ', f.result_code'
    || ', f.terminal_cap'
    || ', f.terminal_result'
    || ', f.unpred_number'
    || ', f.terminal_seq_number'
    || ', f.derivation_key_index'
    || ', f.crypto_version'
    || ', f.card_result'
    || ', f.app_crypto'
    || ', f.app_trans_counter'
    || ', f.app_interchange_profile'
    || ', f.iss_script1_result'
    || ', f.iss_script2_result'
    || ', f.terminal_country'
    || ', f.terminal_date'
    || ', f.auth_response_code'
    || ', f.other_amount'
    || ', f.trans_type_1'
    || ', f.terminal_type'
    || ', f.trans_category'
    || ', f.trans_seq_counter'
    || ', f.crypto_info_data'
    || ', f.dedicated_filename'
    || ', f.iss_app_data'
    || ', f.cvm_result'
    || ', f.terminal_app_version'
    || ', f.sttl_date'
    || ', f.network_data'
    || ', f.cashback_acq_amount'
    || ', f.cashback_acq_currency'
    || ', f.cashback_net_amount'
    || ', f.cashback_net_currency'
    || ', f.cashback_card_amount'
    || ', f.cashback_card_currency'
    || ', f.term_type'
    || ', f.terminal_subtype'
    || ', f.trans_type_2'
    || ', f.cashm_refnum'
    || ', f.sttl_amount'
    || ', f.interbank_fee_amount'
    || ', f.bank_card_id'
    || ', f.ecommerce'
    || ', f.transaction_amount'
    || ', f.transaction_currency'
    || ', f.original_trans_number'
    || ', f.account_number'
    || ', f.report_period'
    || ', f.withdrawal_number'
    || ', f.period_amount'
    || ', f.card_subtype'
    || ', f.issuer_code'
    || ', f.card_acc_number'
    || ', f.add_acc_number'
    || ', f.atm_bank_code'
    || ', f.deposit_number'
    || ', f.loaded_amount_atm'
    || ', f.is_fullload'
    || ', f.total_amount_atm'
    || ', f.total_amount_tandem'
    || ', f.withdrawal_count'
    || ', f.receipt_count'
    || ', f.message_type'
    || ', f.stan'
    || ', f.incident_cause'
    || ', f.file_record_number'
    || ', f.is_invalid'
    || ', f.oper_id'
    ;

function put_message (
    i_fin_rec      in       bgn_api_type_pkg.t_bgn_fin_rec
) return com_api_type_pkg.t_long_id is
    l_id                    com_api_type_pkg.t_long_id;
begin
    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);
    
    insert into bgn_fin (    
        id                     
      , file_id      
      , status
      , is_reversal
      , dispute_id
      , inst_id
      , host_inst_id
      , network_id
      , is_incoming
      , package_id             
      , record_type            
      , record_number          
      , transaction_date       
      , transaction_type       
      , is_reject              
      , is_finance             
      , card_mask              
      , card_seq_number        
      , card_expire_date       
      , card_type              
      , acquirer_amount        
      , acquirer_currency      
      , network_amount         
      , network_currency       
      , card_amount            
      , card_currency          
      , auth_code              
      , trace_number           
      , retrieval_refnum       
      , merchant_number        
      , merchant_name          
      , merchant_city          
      , mcc                    
      , terminal_number        
      , pos_entry_mode         
      , ain                    
      , auth_indicator         
      , transaction_number     
      , validation_code        
      , market_data_id         
      , add_response_data      
      , reject_code            
      , response_code          
      , reject_text            
      , is_offline             
      , pos_text               
      , result_code            
      , terminal_cap           
      , terminal_result        
      , unpred_number          
      , terminal_seq_number    
      , derivation_key_index   
      , crypto_version         
      , card_result            
      , app_crypto             
      , app_trans_counter      
      , app_interchange_profile
      , iss_script1_result     
      , iss_script2_result     
      , terminal_country       
      , terminal_date          
      , auth_response_code     
      , other_amount           
      , trans_type_1           
      , terminal_type          
      , trans_category         
      , trans_seq_counter      
      , crypto_info_data       
      , dedicated_filename     
      , iss_app_data           
      , cvm_result             
      , terminal_app_version   
      , sttl_date              
      , network_data           
      , cashback_acq_amount    
      , cashback_acq_currency  
      , cashback_net_amount    
      , cashback_net_currency  
      , cashback_card_amount   
      , cashback_card_currency 
      , term_type              
      , terminal_subtype       
      , trans_type_2           
      , cashm_refnum           
      , sttl_amount            
      , interbank_fee_amount   
      , bank_card_id           
      , ecommerce              
      , transaction_amount     
      , transaction_currency   
      , original_trans_number  
      , account_number         
      , report_period          
      , withdrawal_number      
      , period_amount          
      , card_subtype           
      , issuer_code            
      , card_acc_number        
      , add_acc_number         
      , atm_bank_code          
      , deposit_number         
      , loaded_amount_atm      
      , is_fullload            
      , total_amount_atm       
      , total_amount_tandem    
      , withdrawal_count       
      , receipt_count          
      , message_type           
      , stan                   
      , incident_cause
      , file_record_number
      , is_invalid
      , oper_id
    ) values (
        l_id                     
      , i_fin_rec.file_id  
      , i_fin_rec.status
      , i_fin_rec.is_reversal
      , i_fin_rec.dispute_id
      , i_fin_rec.inst_id
      , i_fin_rec.host_inst_id
      , i_fin_rec.network_id
      , i_fin_rec.is_incoming              
      , i_fin_rec.package_id             
      , i_fin_rec.record_type            
      , i_fin_rec.record_number          
      , i_fin_rec.transaction_date       
      , i_fin_rec.transaction_type       
      , i_fin_rec.is_reject              
      , i_fin_rec.is_finance             
      , nvl(i_fin_rec.card_mask, iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.card_number))              
      , i_fin_rec.card_seq_number        
      , i_fin_rec.card_expire_date       
      , i_fin_rec.card_type              
      , i_fin_rec.acquirer_amount        
      , i_fin_rec.acquirer_currency      
      , i_fin_rec.network_amount         
      , i_fin_rec.network_currency       
      , i_fin_rec.card_amount            
      , i_fin_rec.card_currency          
      , i_fin_rec.auth_code              
      , i_fin_rec.trace_number           
      , i_fin_rec.retrieval_refnum       
      , i_fin_rec.merchant_number        
      , i_fin_rec.merchant_name          
      , i_fin_rec.merchant_city          
      , i_fin_rec.mcc                    
      , i_fin_rec.terminal_number        
      , i_fin_rec.pos_entry_mode         
      , i_fin_rec.ain                    
      , i_fin_rec.auth_indicator         
      , i_fin_rec.transaction_number     
      , i_fin_rec.validation_code        
      , i_fin_rec.market_data_id         
      , i_fin_rec.add_response_data      
      , i_fin_rec.reject_code            
      , i_fin_rec.response_code          
      , i_fin_rec.reject_text            
      , i_fin_rec.is_offline             
      , i_fin_rec.pos_text               
      , i_fin_rec.result_code            
      , i_fin_rec.terminal_cap           
      , i_fin_rec.terminal_result        
      , i_fin_rec.unpred_number          
      , i_fin_rec.terminal_seq_number    
      , i_fin_rec.derivation_key_index   
      , i_fin_rec.crypto_version         
      , i_fin_rec.card_result            
      , i_fin_rec.app_crypto             
      , i_fin_rec.app_trans_counter      
      , i_fin_rec.app_interchange_profile
      , i_fin_rec.iss_script1_result     
      , i_fin_rec.iss_script2_result     
      , i_fin_rec.terminal_country       
      , i_fin_rec.terminal_date          
      , i_fin_rec.auth_response_code     
      , i_fin_rec.other_amount           
      , i_fin_rec.trans_type_1           
      , i_fin_rec.terminal_type          
      , i_fin_rec.trans_category         
      , i_fin_rec.trans_seq_counter      
      , i_fin_rec.crypto_info_data       
      , i_fin_rec.dedicated_filename     
      , i_fin_rec.iss_app_data           
      , i_fin_rec.cvm_result             
      , i_fin_rec.terminal_app_version   
      , i_fin_rec.sttl_date              
      , i_fin_rec.network_data           
      , i_fin_rec.cashback_acq_amount    
      , i_fin_rec.cashback_acq_currency  
      , i_fin_rec.cashback_net_amount    
      , i_fin_rec.cashback_net_currency  
      , i_fin_rec.cashback_card_amount   
      , i_fin_rec.cashback_card_currency 
      , i_fin_rec.term_type              
      , i_fin_rec.terminal_subtype       
      , i_fin_rec.trans_type_2           
      , i_fin_rec.cashm_refnum           
      , i_fin_rec.sttl_amount            
      , i_fin_rec.interbank_fee_amount   
      , i_fin_rec.bank_card_id           
      , i_fin_rec.ecommerce              
      , i_fin_rec.transaction_amount     
      , i_fin_rec.transaction_currency   
      , i_fin_rec.original_trans_number  
      , i_fin_rec.account_number         
      , i_fin_rec.report_period          
      , i_fin_rec.withdrawal_number      
      , i_fin_rec.period_amount          
      , i_fin_rec.card_subtype           
      , i_fin_rec.issuer_code            
      , i_fin_rec.card_acc_number        
      , i_fin_rec.add_acc_number         
      , i_fin_rec.atm_bank_code          
      , i_fin_rec.deposit_number         
      , i_fin_rec.loaded_amount_atm      
      , i_fin_rec.is_fullload            
      , i_fin_rec.total_amount_atm       
      , i_fin_rec.total_amount_tandem    
      , i_fin_rec.withdrawal_count       
      , i_fin_rec.receipt_count          
      , i_fin_rec.message_type           
      , i_fin_rec.stan                   
      , i_fin_rec.incident_cause
      , i_fin_rec.file_record_number
      , nvl(i_fin_rec.is_invalid, com_api_const_pkg.FALSE)
      , i_fin_rec.oper_id
    );

    if i_fin_rec.card_number is not null then    
        insert into bgn_card (
            id
          , card_number
        ) values (
            l_id
          , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
        );
        
    end if;
    
    trc_log_pkg.debug(
        i_text          => 'BORICA fin message generated [#1]'
      , i_env_param1    => l_id  
    );
    
    return l_id;    
    
end; 

procedure put_file_rec(
    i_file_rec      in      bgn_api_type_pkg.t_bgn_file_rec             
) is
begin
    insert into bgn_file (
        id                 
      , file_type          
      , file_label         
      , sender_code        
      , receiver_code      
      , file_number        
      , test_option        
      , creation_date      
      , gmt_offset         
      , bgn_sttl_type      
      , sttl_currency      
      , interface_version  
      , journal_period     
      , debit_total        
      , credit_total       
      , debit_amount       
      , credit_amount      
      , debit_fee_amount   
      , credit_fee_amount  
      , net_amount         
      , sttl_date          
      , package_total      
      , control_amount     
      , is_incoming
      , error_total
      , inst_id
      , network_id
      , borica_sttl_date
    ) values (
        i_file_rec.id                 
      , i_file_rec.file_type          
      , i_file_rec.file_label         
      , i_file_rec.sender_code        
      , i_file_rec.receiver_code      
      , i_file_rec.file_number        
      , i_file_rec.test_option        
      , i_file_rec.creation_date      
      , i_file_rec.gmt_offset         
      , i_file_rec.bgn_sttl_type      
      , i_file_rec.sttl_currency      
      , i_file_rec.interface_version  
      , i_file_rec.journal_period     
      , i_file_rec.debit_total        
      , i_file_rec.credit_total       
      , i_file_rec.debit_amount       
      , i_file_rec.credit_amount      
      , i_file_rec.debit_fee_amount   
      , i_file_rec.credit_fee_amount  
      , i_file_rec.net_amount         
      , i_file_rec.sttl_date          
      , i_file_rec.package_total      
      , i_file_rec.control_amount
      , i_file_rec.is_incoming
      , i_file_rec.error_total     
      , i_file_rec.inst_id
      , i_file_rec.network_id
      , i_file_rec.borica_sttl_date
    );
    
end;

procedure put_package_rec (
    io_package_rec  in out nocopy   bgn_api_type_pkg.t_bgn_package_rec
) is
begin
    io_package_rec.id := nvl(io_package_rec.id, bgn_package_seq.nextval());    

    insert into bgn_package (
        id         
      , file_id      
      , sender_code    
      , receiver_code  
      , creation_date  
      , package_type   
      , record_total   
      , control_amount 
      , package_number
    ) values (
        io_package_rec.id
      , io_package_rec.file_id               
      , io_package_rec.sender_code    
      , io_package_rec.receiver_code  
      , io_package_rec.creation_date  
      , io_package_rec.package_type   
      , io_package_rec.record_total   
      , io_package_rec.control_amount
      , io_package_rec.package_number
    );

end;

procedure put_retrieval_rec (
    io_retrieval_rec in out nocopy  bgn_api_type_pkg.t_bgn_retrieval_rec
) is
begin
    io_retrieval_rec.id := nvl(io_retrieval_rec.id, bgn_retrieval_seq.nextval());    
    
    insert into bgn_retrieval (
        id                      
      , file_id                 
      , record_type             
      , record_number           
      , sender_code             
      , receiver_code
      , file_number           
      , test_option
      , creation_date           
      , original_file_id        
      , transaction_number      
      , original_fin_id         
      , sttl_amount             
      , interbank_fee_amount    
      , bank_card_id            
      , error_code  
      , is_invalid            
    ) values (
        io_retrieval_rec.id                      
      , io_retrieval_rec.file_id                 
      , io_retrieval_rec.record_type             
      , io_retrieval_rec.record_number           
      , io_retrieval_rec.sender_code             
      , io_retrieval_rec.receiver_code
      , io_retrieval_rec.file_number           
      , io_retrieval_rec.test_option             
      , io_retrieval_rec.creation_date           
      , io_retrieval_rec.original_file_id        
      , io_retrieval_rec.transaction_number      
      , io_retrieval_rec.original_fin_id         
      , io_retrieval_rec.sttl_amount             
      , io_retrieval_rec.interbank_fee_amount    
      , io_retrieval_rec.bank_card_id            
      , io_retrieval_rec.error_code  
      , io_retrieval_rec.is_invalid
    );  
   
end;

function get_original_file_id (
    i_retrieval_rec in              bgn_api_type_pkg.t_bgn_retrieval_rec
  , i_file_type     in              com_api_type_pkg.t_dict_value  
  , i_mask_error    in              com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_long_id is
    l_file_id       com_api_type_pkg.t_long_id;
    
begin
    select id
      into l_file_id
      from bgn_file
     where file_type = i_file_type
       and file_number = i_retrieval_rec.file_number
       and creation_date = i_retrieval_rec.creation_date
       and test_option = i_retrieval_rec.test_option
       and sender_code = i_retrieval_rec.receiver_code
       and receiver_code = i_retrieval_rec.sender_code
       and is_incoming = com_api_const_pkg.FALSE;
    
    return l_file_id;
    
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error         => 'BGN_FILE_RECORD_NOT_FOUNT'
              , i_env_param1    => i_file_type
              , i_env_param2    => i_retrieval_rec.file_number
              , i_env_param3    => trunc(i_retrieval_rec.creation_date)
              , i_env_param4    => i_retrieval_rec.test_option
              , i_env_param5    => i_retrieval_rec.sender_code
              , i_env_param6    => i_retrieval_rec.receiver_code
            );
        else
            trc_log_pkg.warn(
                i_text          => 'Original file record not found: file type [#1], file number [#2], creation date [#3], test option [#4], sender [#5], receiver [#6]'
              , i_env_param1    => i_file_type
              , i_env_param2    => i_retrieval_rec.file_number
              , i_env_param3    => trunc(i_retrieval_rec.creation_date)
              , i_env_param4    => i_retrieval_rec.test_option
              , i_env_param5    => i_retrieval_rec.sender_code
              , i_env_param6    => i_retrieval_rec.receiver_code
            );
        end if;
        return null;
            
end;

function get_original_fin_id (
    i_retrieval_rec in              bgn_api_type_pkg.t_bgn_retrieval_rec
  , i_mask_error    in              com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_long_id is
    l_fin_id        com_api_type_pkg.t_long_id;

begin
    select id
      into l_fin_id
      from bgn_fin
     where (file_id = i_retrieval_rec.original_file_id or i_retrieval_rec.original_file_id is null)
       and transaction_number = i_retrieval_rec.transaction_number
       and is_incoming = com_api_const_pkg.FALSE;
       
    return l_fin_id;       
       
exception
    when no_data_found or too_many_rows then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error             => 'BGN_FIN_RECORD_NOT_FOUNT'
              , i_env_param1        => i_retrieval_rec.transaction_number
              , i_env_param2        => i_retrieval_rec.original_file_id
            );
        else
            trc_log_pkg.warn(
                i_text             => 'Finance message with transaction number [#1] not found, file id [#2]'
              , i_env_param1        => i_retrieval_rec.transaction_number
              , i_env_param2        => i_retrieval_rec.original_file_id
            );
        end if;    
        return null;
                 
end;

procedure find_original_id (
    io_retrieval_rec    in out nocopy   bgn_api_type_pkg.t_bgn_retrieval_rec
  , i_mask_error        in              com_api_type_pkg.t_boolean  
) is
begin
    select id
         , file_id
      into io_retrieval_rec.original_fin_id
         , io_retrieval_rec.original_file_id
      from bgn_fin
     where id = to_number(io_retrieval_rec.transaction_number)
       and is_incoming = com_api_const_pkg.FALSE;
       
exception
    when no_data_found or too_many_rows then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error             => 'BGN_FIN_RECORD_NOT_FOUNT'
              , i_env_param1        => io_retrieval_rec.transaction_number
              , i_env_param2        => io_retrieval_rec.original_file_id
            );
        else
            trc_log_pkg.warn(
                i_text             => 'Finance message with transaction number [#1] not found, file id [#2]'
              , i_env_param1        => io_retrieval_rec.transaction_number
              , i_env_param2        => io_retrieval_rec.original_file_id
            );
        end if;    
end;

procedure get_fin (
    i_id            in com_api_type_pkg.t_long_id
  , i_oper_id       in com_api_type_pkg.t_long_id := null
  , i_is_incoming   in com_api_type_pkg.t_boolean
  , o_fin_rec       out bgn_api_type_pkg.t_bgn_fin_rec
  , i_mask_error    in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
) is
    l_fin_cur       sys_refcursor;
    l_ref_source    com_api_type_pkg.t_text;
begin
    l_ref_source := '
select
'||g_column_list||'
from
bgn_fin f
, bgn_card c
, (select :id id, :oper_id oper_id, :is_incoming is_incoming from dual) x
where f.id = c.id(+)';

    if i_id is not null then
        l_ref_source := l_ref_source || ' and f.id = x.id';
    else
        l_ref_source := l_ref_source || ' and f.oper_id = x.oper_id';
    end if;
    l_ref_source := l_ref_source || ' and f.is_incoming = x.is_incoming';
    
    open l_fin_cur for l_ref_source using i_id, i_oper_id, i_is_incoming;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        else
            trc_log_pkg.error (
                i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        end if;
    end if;
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end;

procedure fin_to_oper(
    io_fin_rec          in out nocopy   bgn_api_type_pkg.t_bgn_fin_rec
  , io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , io_iss_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , io_acq_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , i_session_file_id   in              com_api_type_pkg.t_long_id
  , i_record_number     in              com_api_type_pkg.t_short_id 
  , i_file_code         in              com_api_type_pkg.t_dict_value   
) is
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code; 
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_network_id            com_api_type_pkg.t_network_id;
    l_merchant_id           com_api_type_pkg.t_short_id;
    l_params                com_api_type_pkg.t_param_tab;
    
    l_addr_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_api_fin_pkg.fin_to_oper'
    );
    
    io_fin_rec.id       := nvl(io_fin_rec.id, opr_api_create_pkg.get_id);
    io_fin_rec.oper_id  := io_fin_rec.id;
    
    io_oper.id      := io_fin_rec.id;
    io_oper.status  := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;

    io_oper.oper_type        := net_api_map_pkg.get_oper_type(
        i_network_oper_type     => i_file_code || io_fin_rec.transaction_type
      , i_standard_id           => bgn_api_const_pkg.BGN_CLEARING_STANDARD
    );   
    
    if io_oper.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE then
        begin
            select opr_api_const_pkg.OPERATION_TYPE_UNIQUE
              into io_oper.oper_type
              from com_mcc
             where mcc = lpad(io_fin_rec.mcc, 4, '0')
               and mastercard_cab_type = mcw_api_const_pkg.CAB_TYPE_UNIQUE;
               
        exception
            when no_data_found then
                null;       
        end;   

    end if;
    
    io_oper.msg_type         := net_api_map_pkg.get_msg_type (
        i_network_msg_type      => i_file_code || io_fin_rec.transaction_type
      , i_standard_id           => bgn_api_const_pkg.BGN_CLEARING_STANDARD
    );
        
    io_acq_part.oper_id          := io_fin_rec.id;
    io_acq_part.participant_type := com_api_const_pkg.PARTICIPANT_ACQUIRER;

    io_acq_part.inst_id := 
        bgn_cst_borica_pkg.define_acquirer_inst(
            i_fin_rec       => io_fin_rec
          , i_file_code     => i_file_code  
        );
    
    io_acq_part.network_id   := ost_api_institution_pkg.get_inst_network(io_acq_part.inst_id);
    
    --merchant info
    io_oper.merchant_number     := io_fin_rec.merchant_number;
    io_oper.terminal_number     := io_fin_rec.terminal_number;
    io_oper.merchant_country    := io_fin_rec.terminal_country;
    io_oper.acq_inst_bin        := io_fin_rec.ain;
    io_oper.merchant_name       := io_fin_rec.merchant_name;
    io_oper.merchant_city       := io_fin_rec.merchant_city;
    io_oper.mcc                 := io_fin_rec.mcc;
--    io_acq_part.account_number   := io_fin_rec.account_number;
    
    acq_api_merchant_pkg.get_merchant(
        i_inst_id           => io_acq_part.inst_id
      , i_merchant_number   => io_oper.merchant_number
      , o_merchant_id       => io_acq_part.merchant_id
      , o_split_hash        => io_acq_part.split_hash  
    );
    
    begin
        select t.id
             , t.merchant_id
             , nvl(io_fin_rec.merchant_number, m.merchant_number)
             , m.split_hash
             , c.id
             , c.customer_id
             , nvl(io_oper.terminal_type, t.terminal_type)
          into io_acq_part.terminal_id  
             , l_merchant_id 
             , io_oper.merchant_number
             , io_acq_part.split_hash
             , io_acq_part.contract_id
             , io_acq_part.customer_id
             , io_oper.terminal_type
          from acq_terminal t
             , acq_merchant m
             , prd_contract c
         where reverse(t.terminal_number) like reverse('%'||substr(io_oper.terminal_number, 1, 8))
           and t.inst_id         = io_acq_part.inst_id
           and m.id              = t.merchant_id
           and m.contract_id     = c.id;
    exception
        when too_many_rows then
            trc_log_pkg.error(
                i_text          => 'TOO_MANY_TERMINALS'
              , i_env_param1    => substr(io_oper.terminal_number, 1, 8)
            );
        when no_data_found then
            l_merchant_id           := null;
    end;       
    
    if io_acq_part.merchant_id is not null and l_merchant_id is not null
       and io_acq_part.merchant_id != l_merchant_id then
        trc_log_pkg.error(
            i_text          => 'BGN_INCONSISTENT_MERCHANTS'
          , i_env_param1    => io_acq_part.merchant_id
          , i_env_param2    => io_acq_part.terminal_id
          , i_env_param3    => l_merchant_id  
        );
        
        io_fin_rec.is_invalid   := com_api_const_pkg.TRUE; 
        io_oper.status          := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        
    else
        io_acq_part.merchant_id := nvl(io_acq_part.merchant_id, l_merchant_id);

    end if;
    
    if io_oper.merchant_country is null then
        if io_acq_part.merchant_id is not null then
            l_addr_id   :=
                acq_api_merchant_pkg.get_merchant_address_id(
                    i_merchant_id   => io_acq_part.merchant_id
                );
                
            if l_addr_id is not null then
                select country
                  into io_oper.merchant_country
                  from com_address
                 where id = l_addr_id; 
                 
            else
                io_oper.merchant_country    := bgn_api_const_pkg.BGN_DEFAULT_COUNTRY;
                 
            end if;    
            
        end if;
        
    else    
        io_oper.merchant_country    := bgn_api_const_pkg.BGN_DEFAULT_COUNTRY;
        
    end if;

    io_iss_part.oper_id          := io_fin_rec.id;
    io_iss_part.participant_type := com_api_const_pkg.PARTICIPANT_ISSUER;
    io_iss_part.card_number  := io_fin_rec.card_number;
    io_iss_part.card_mask    :=  iss_api_card_pkg.get_card_mask(
                                    i_card_number   => io_iss_part.card_number
                                );
    io_iss_part.card_hash    :=  com_api_hash_pkg.get_card_hash(
                                    i_card_number   => io_iss_part.card_number
                                );
    begin                                
        io_iss_part.card_expir_date  := to_date(io_fin_rec.card_expire_date, 'yymm');
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'BGN_WRONG_EXPIR_DATE'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(io_fin_rec.card_number)
              , i_env_param2    => io_fin_rec.card_expire_date
              , i_env_param3    => io_fin_rec.file_record_number  
            );
            io_iss_part.card_expir_date := null;   
            io_fin_rec.is_invalid   := com_api_const_pkg.TRUE; 
            io_oper.status          := opr_api_const_pkg.OPERATION_STATUS_MANUAL;   
    end;                                

    iss_api_bin_pkg.get_bin_info (
        i_card_number       => io_iss_part.card_number
      , o_iss_inst_id       => io_iss_part.inst_id
      , o_iss_network_id    => io_iss_part.network_id
      , o_card_inst_id      => io_iss_part.card_inst_id
      , o_card_network_id   => io_iss_part.card_network_id
      , o_card_type         => io_iss_part.card_type_id
      , o_card_country      => io_iss_part.card_country
      , o_bin_currency      => l_bin_currency
      , o_sttl_currency     => l_sttl_currency
      , i_raise_error       => com_api_const_pkg.FALSE
    );
    
    if io_iss_part.inst_id is null then
        trc_log_pkg.debug(
            i_text          => 'search foreign card: [#1]'
          , i_env_param1    => io_iss_part.card_mask
        );
        
        begin
            net_api_bin_pkg.get_bin_info (
                i_card_number           => io_iss_part.card_number
              , i_oper_type             => io_oper.oper_type
              , i_terminal_type         => io_oper.terminal_type
              , i_acq_inst_id           => io_acq_part.inst_id
              , i_acq_network_id        => io_acq_part.network_id
              , i_msg_type              => io_oper.msg_type
              , i_oper_reason           => io_oper.oper_reason
              , i_oper_currency         => io_oper.oper_currency
              , i_merchant_id           => io_acq_part.merchant_id
              , i_terminal_id           => io_acq_part.terminal_id
              , o_iss_network_id        => io_iss_part.network_id
              , o_iss_inst_id           => io_iss_part.inst_id
              , o_iss_host_id           => l_iss_host_id
              , o_card_type_id          => io_iss_part.card_type_id
              , o_card_country          => io_iss_part.card_country
              , o_card_inst_id          => io_iss_part.card_inst_id
              , o_card_network_id       => io_iss_part.card_network_id
              , o_pan_length            => l_pan_length
              , i_raise_error           => com_api_type_pkg.FALSE
            );
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                  , i_entity_type   => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
                  , i_object_id     => i_session_file_id
                  , i_env_param1    => iss_api_card_pkg.get_card_mask(io_fin_rec.card_number)
                  , i_env_param2    => i_record_number  
                );    
                io_fin_rec.is_invalid   := com_api_const_pkg.TRUE; 
                io_oper.status  := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
                return;       
        end;
        
    else
        --card and issuer info                         
        io_iss_part.card_id     
            := iss_api_card_pkg.get_card_id(
                    i_card_number   => io_iss_part.card_number
               );
                                    
        io_iss_part.card_seq_number  := io_fin_rec.card_seq_number;

        if io_iss_part.card_id is not null then                                    
            io_iss_part.card_instance_id := 
                iss_api_card_instance_pkg.get_card_instance_id (
                    i_card_id       => io_iss_part.card_id
                  , i_seq_number    => io_fin_rec.card_seq_number
                  , i_expir_date    => io_iss_part.card_expir_date
                );
            
            select c.customer_id
                 , c.contract_id
                 , c.country 
                 , c.split_hash
              into io_iss_part.customer_id
                 , io_iss_part.contract_id
                 , io_iss_part.card_country 
                 , io_iss_part.split_hash
              from iss_card c
             where c.id = io_iss_part.card_id; 
                    
        end if;    
        
        if io_iss_part.card_id is null or io_iss_part.card_instance_id is null then
            io_fin_rec.is_invalid   := com_api_const_pkg.TRUE; 
            io_oper.status  := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
            
        else
            select seq_number
              into io_iss_part.card_seq_number
              from iss_card_instance
             where id = io_iss_part.card_instance_id;     
            
        end if;

    end if;
    
    io_iss_part.auth_code    := io_fin_rec.auth_code;

    io_oper.is_reversal      := io_fin_rec.is_reversal;          
    io_oper.oper_date        := io_fin_rec.transaction_date; 

    io_iss_part.client_id_type   := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;

    begin
        select c.customer_id
             , c.split_hash
          into io_acq_part.customer_id
             , io_acq_part.split_hash
          from acq_merchant m
             , prd_contract c
         where m.contract_id = c.id
           and m.inst_id = io_acq_part.inst_id
           and m.id = io_acq_part.merchant_id;
           
    exception
        when no_data_found then
            null;
    end;   
    
    io_oper.msg_type    :=
        net_api_map_pkg.get_msg_type(
            i_network_msg_type  => nvl(io_fin_rec.message_type, ' ')
          , i_standard_id       => bgn_api_const_pkg.BGN_CLEARING_STANDARD
        );
    
    if io_oper.msg_type is null then
        trc_log_pkg.error(
            i_text          => 'NETWORK_MESSAGE_TYPE_EXCEPT'
          , i_env_param1    => io_fin_rec.message_type
          , i_env_param2    => bgn_api_const_pkg.BGN_CLEARING_STANDARD  
        );
        
        io_fin_rec.is_invalid   := com_api_const_pkg.TRUE; 
        io_oper.status  := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        
    end if;
    
    opr_cst_shared_data_pkg.collect_oper_params(
        i_oper      => io_oper
      , i_iss_part  => io_iss_part 
      , i_acq_part  => io_acq_part 
      , io_params   => l_params    
    );
     
    net_api_sttl_pkg.get_sttl_type (
        i_iss_inst_id       => io_iss_part.inst_id
      , i_acq_inst_id       => io_acq_part.inst_id
      , i_card_inst_id      => io_iss_part.card_inst_id
      , i_iss_network_id    => io_iss_part.network_id
      , i_acq_network_id    => io_acq_part.network_id
      , i_card_network_id   => io_iss_part.card_network_id
      , i_acq_inst_bin      => io_fin_rec.ain
      , o_sttl_type         => io_oper.sttl_type
      , o_match_status      => io_oper.match_status
      , i_params            => l_params
      , i_mask_error        => com_api_const_pkg.TRUE
      , i_oper_type         => io_oper.oper_type
    );
    
    bgn_cst_borica_pkg.sttl_postprocess(
        io_fin_rec          => io_fin_rec
      , io_oper             => io_oper
      , io_iss_part         => io_iss_part
      , io_acq_part         => io_acq_part
    );
    
    bgn_cst_borica_pkg.oper_status_postprocess(
        io_fin_rec          => io_fin_rec
      , io_oper             => io_oper
      , io_iss_part         => io_iss_part
      , io_acq_part         => io_acq_part
      , i_file_code         => i_file_code
    );
    
    if io_oper.sttl_type is null then
        trc_log_pkg.error(
            i_text          => 'BGN_SETTLMENT_TYPE_NOT_DEFINED'
          , i_env_param1    => io_oper.id  
        );
        io_fin_rec.is_invalid   := com_api_const_pkg.TRUE;
        io_oper.status  := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
         
    elsif io_oper.sttl_type in (
        opr_api_const_pkg.SETTLEMENT_INTERNAL
      , opr_api_const_pkg.SETTLEMENT_INTERNAL_INTERINST
      , opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
      , opr_api_const_pkg.SETTLEMENT_USONUS
      , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST
      , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST
    ) and (io_acq_part.merchant_id is null or io_iss_part.card_id is null) 
    then
        if io_acq_part.merchant_id is null then
            trc_log_pkg.error(
                i_text          => 'UNKNOWN_TERMINAL'
              , i_env_param1    => io_acq_part.inst_id
              , i_env_param2    => io_oper.merchant_number
              , i_env_param3    => io_acq_part.merchant_id
              , i_env_param4    => io_oper.terminal_number
              , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id     => io_oper.id
            );
        else
            trc_log_pkg.error(
                i_text          => 'CARD_NOT_FOUND'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(io_fin_rec.card_number)
              , i_env_param2    => io_iss_part.inst_id
              , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id     => io_oper.id
            );
        end if;
        
        io_fin_rec.is_invalid   := com_api_const_pkg.TRUE;
        io_oper.status  := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        
    elsif io_oper.sttl_type not in (
        opr_api_const_pkg.SETTLEMENT_THEMONTHEM
    ) and (io_acq_part.merchant_id is null and io_iss_part.card_id is null) then
        if io_acq_part.inst_id = io_fin_rec.inst_id then
            trc_log_pkg.error(
                i_text          => 'UNKNOWN_MERCHANT'
              , i_env_param1    => io_oper.merchant_number
              , i_env_param2    => io_acq_part.inst_id
              , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id     => io_oper.id
            );
        else
            trc_log_pkg.error(
                i_text          => 'CARD_NOT_FOUND'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(io_fin_rec.card_number)
              , i_env_param2    => io_iss_part.inst_id
              , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id     => io_oper.id
            );
        end if;
        
        io_fin_rec.is_invalid   := com_api_const_pkg.TRUE;
        io_oper.status  := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        
    end if;
    
    trc_log_pkg.debug(
        i_text          => 'bgn_api_fin_pkg.fin_to_oper finished'
    );
    
end;

function get_original_for_reversal(
    io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , i_refnum            in  com_api_type_pkg.t_rrn  
  , i_card_number       in  com_api_type_pkg.t_card_number  
  , i_mask_error        in  com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_long_id is
    l_original_id       com_api_type_pkg.t_long_id;
begin
    -- Try to find original operation for a reversal
    trc_log_pkg.debug(
        i_text       => 'search original operation for reversal: originator_refnum [#1], card_mask [#2], oper_date [#3]'
      , i_env_param1 => i_refnum
      , i_env_param2 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
      , i_env_param3 => io_oper.oper_date
    );

    begin
        select o.id
          into l_original_id
          from opr_operation o
             , opr_participant op
             , opr_card cn
         where nvl(o.is_reversal, 0) = 0
           and o.originator_refnum = i_refnum
           and (io_oper.oper_date - o.oper_date) <= 30
           and op.oper_id = o.id 
           and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and cn.oper_id = o.id
           and cn.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => i_card_number))
           and not exists (select null from opr_operation r where r.original_id = o.id and r.is_reversal = com_api_const_pkg.TRUE)
           and o.msg_type = io_oper.msg_type;
    exception
        when no_data_found or too_many_rows then
            if i_mask_error = com_api_const_pkg.TRUE then
                trc_log_pkg.error(
                    i_text       => 'Original operation for the reversal is not found: originator refnum [#2]; oper id [#1], card [#3], oper_date [#4]'
                  , i_env_param1 => io_oper.id
                  , i_env_param2 => i_refnum
                  , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                  , i_env_param4 => io_oper.oper_date
                );
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
                  , i_env_param1 => io_oper.id
                  , i_env_param2 => i_refnum
                  , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                  , i_env_param4 => io_oper.oper_date
                );
            end if;    
    end;

    trc_log_pkg.debug(i_text => 'searching result: l_original_id [' || l_original_id || ']');

    return l_original_id;
    
end;

procedure match_usonus(
    io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , io_iss_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , io_acq_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
) is
begin
    if io_oper.match_status = opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH and 
       io_oper.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS
    then
        for r in (
            select o.id
              from opr_operation o
                 , opr_participant a
                 , opr_participant i
             where a.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and a.oper_id          = o.id
               and i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and i.oper_id          = o.id
               and i.card_id          = io_iss_part.card_id
               and i.auth_code        = io_iss_part.auth_code
               and a.terminal_id      = io_acq_part.terminal_id
               and o.match_status     in (opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH, opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH)
               and o.id              != io_oper.id
        ) loop
            update opr_operation o
               set o.match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED
                 , o.match_id     = decode(o.id, io_oper.id, r.id, io_oper.id)
             where o.id           in (r.id, io_oper.id);
             
            exit;  
        end loop;
    
    end if;
end;

procedure create_from_oper (
    i_oper_rec          in opr_api_type_pkg.t_oper_rec
  , i_iss_rec           in opr_api_type_pkg.t_oper_part_rec
  , i_asq_rec           in opr_api_type_pkg.t_oper_part_rec 
  , i_id                in com_api_type_pkg.t_long_id
  , i_inst_id           in com_api_type_pkg.t_inst_id := null
  , i_network_id        in com_api_type_pkg.t_tiny_id := null
) is
    l_fin_rec           bgn_api_type_pkg.t_bgn_fin_rec;
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_api_fin_pkg.create_from_oper: id [#1], inst_id [#2], network_id [#3]'
      , i_env_param1    => i_id
      , i_env_param2    => i_inst_id
      , i_env_param3    => i_network_id  
    );
    
    l_fin_rec.is_reversal   := i_oper_rec.is_reversal;
    
    if l_fin_rec.is_reversal = com_api_const_pkg.TRUE then
        l_fin_rec.is_reject := 'R';
        begin
            select originator_refnum
              into l_fin_rec.original_trans_number
              from opr_operation
             where id = i_oper_rec.original_id;
             
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'BGN_ORIGINAL_TRANSACTION_NOT_FOUND'
                  , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION  
                  , i_object_id     => i_oper_rec.id
                  , i_env_param1    => i_oper_rec.original_id
                );     
        end; 
         
    else
        l_fin_rec.is_reject := 'N';
        
    end if;
        
    l_fin_rec.id                    := nvl(i_id, opr_api_create_pkg.get_id);
    l_fin_rec.oper_id               := i_oper_rec.id;
    l_fin_rec.is_incoming           := com_api_const_pkg.FALSE;
    l_fin_rec.transaction_number    := l_fin_rec.id;
    l_fin_rec.transaction_date      := i_oper_rec.oper_date;
    l_fin_rec.auth_code             := i_iss_rec.auth_code;
    
    l_fin_rec.transaction_type  :=
        bgn_cst_borica_pkg.outgoing_oper_type(
            io_fin_rec          => l_fin_rec
          , i_oper_id           => i_oper_rec.id
          , i_oper_type         => i_oper_rec.oper_type  
        );
    
    if l_fin_rec.transaction_type is null then
        case i_oper_rec.oper_type
        when opr_api_const_pkg.OPERATION_TYPE_POS_CASH then
            l_fin_rec.transaction_type := 13;
            
        when opr_api_const_pkg.OPERATION_TYPE_CASHBACK then
            l_fin_rec.transaction_type := 14;

        when opr_api_const_pkg.OPERATION_TYPE_PURCHASE then
            l_fin_rec.transaction_type := 11;
            
        when opr_api_const_pkg.OPERATION_TYPE_INSTITUTION_FEE then
            l_fin_rec.transaction_type := 21;
            
        when opr_api_const_pkg.OPERATION_TYPE_UNIQUE then
            l_fin_rec.transaction_type := 11;
            
        when opr_api_const_pkg.OPERATION_TYPE_CASHIN then
            l_fin_rec.transaction_type := 12;
            
        when opr_api_const_pkg.OPERATION_TYPE_REFUND then
            l_fin_rec.transaction_type := 12;
          
        else       
            trc_log_pkg.warn(
                i_text          => 'Unknown operation type [#1] [#2]'
              , i_env_param1    => i_oper_rec.id
              , i_env_param2    => i_oper_rec.oper_type  
            );
                 
        end case;
        
    end if;    

    l_fin_rec.card_number       := i_iss_rec.card_number;
    l_fin_rec.card_expire_date  := to_char(i_iss_rec.card_expir_date, 'yymm');
    l_fin_rec.card_seq_number   := i_iss_rec.card_seq_number;
    l_fin_rec.auth_code         := i_iss_rec.auth_code;
    
    l_fin_rec.host_inst_id      := i_iss_rec.inst_id;
    l_fin_rec.inst_id           := i_inst_id;
    l_fin_rec.network_id        := i_iss_rec.network_id;
    
    l_fin_rec.merchant_number   := i_oper_rec.merchant_number;
    l_fin_rec.merchant_name     := i_oper_rec.merchant_name;
    l_fin_rec.merchant_city     := i_oper_rec.merchant_city;
    l_fin_rec.mcc               := i_oper_rec.mcc;   
    
    l_fin_rec.terminal_number := 
        case when length(i_oper_rec.terminal_number) >= 8 
            then substr(i_oper_rec.terminal_number, -8) 
            else i_oper_rec.terminal_number
        end;
    l_fin_rec.ain               := 
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => i_inst_id
          , i_standard_id   => bgn_api_const_pkg.BGN_CLEARING_STANDARD
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id     => net_api_network_pkg.get_default_host(
                                    i_network_id    => l_fin_rec.network_id
                                )
          , i_param_name    => bgn_api_const_pkg.CMN_PARAMETER_ACQ_BIN
          , i_param_tab     => l_param_tab
        );
    
    l_fin_rec.cashback_acq_amount   := i_oper_rec.oper_cashback_amount;
    l_fin_rec.transaction_amount    := i_oper_rec.oper_amount;
    l_fin_rec.transaction_currency  := i_oper_rec.oper_currency;
    
    l_fin_rec.status            := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    
    begin
        select to_number(pos_entry_mode||'0')
          into l_fin_rec.pos_entry_mode
          from aut_auth
         where id = l_fin_rec.oper_id;
         
    exception
        when no_data_found then
            l_fin_rec.pos_entry_mode    := null;
    end; 
    
    if l_fin_rec.pos_entry_mode is null then
        begin
            select pos_entry_mode
              into l_fin_rec.pos_entry_mode
              from bgn_fin
             where id = l_fin_rec.oper_id;
             
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'AUTH_NOT_FOUND'
                  , i_env_param1    => l_fin_rec.oper_id
                );
        end;
    end if;
     
    if substr(lpad(l_fin_rec.pos_entry_mode, 4, '0'), 1, 2) = '01' then         
        l_fin_rec.transaction_type := 1;    
    end if;
     
    for r in (
        select
            trace
        from (
            select
                v.trace
                , v.iso_msg_type
            from
                aup_visa_basei v
            where
                v.auth_id = l_fin_rec.oper_id
        )
        order by
            iso_msg_type

    ) loop
        l_fin_rec.trace_number := trim(r.trace);
        exit;
    end loop;
    
    if l_fin_rec.trace_number is null then
        begin
            select nvl(trace_number, stan)
              into l_fin_rec.trace_number
              from bgn_fin
             where oper_id      = l_fin_rec.oper_id
               and is_incoming  = com_api_const_pkg.TRUE
               and rownum = 1;
               
        exception
            when no_data_found then
                null;
        end;   
           
    end if;
    
    if l_fin_rec.trace_number is null and l_fin_rec.transaction_type = 15 then
        begin
            select headx_retl_batch_num||authx_batch_seq_num
              into l_fin_rec.trace_number
              from aci_pos_fin
             where id      = l_fin_rec.oper_id;
               
        exception
            when no_data_found then
                null;
        end;   
           
    end if;
    
    
    begin
        select ecommerce
             , terminal_type
          into l_fin_rec.ecommerce
             , l_fin_rec.terminal_type
          from bgn_fin
         where oper_id = i_oper_rec.id
           and is_incoming = com_api_const_pkg.TRUE;
           
    exception
        when no_data_found then
            null;       
    end;
    
    if l_fin_rec.ecommerce is null then
        l_fin_rec.ecommerce := aup_api_mastercard_pkg.get_mastercard(i_auth_id => i_oper_rec.id).eci;
    end if;
    
    if l_fin_rec.ecommerce is null then
        begin
             select v.ecommerce_indicator
               into l_fin_rec.ecommerce
               from aup_visa_basei v
              where v.auth_id = i_oper_rec.id;
        
        exception
            when no_data_found then
                null;       
        end;  
    end if;
    
    l_fin_rec.stan  := l_fin_rec.trace_number;
     
    l_fin_rec.id    := put_message(
        i_fin_rec           => l_fin_rec
    );
    
end;

procedure create_operation (
    i_oper                  in opr_api_type_pkg.t_oper_rec
    , i_iss_part            in opr_api_type_pkg.t_oper_part_rec
    , i_acq_part            in opr_api_type_pkg.t_oper_part_rec
) is
    l_oper_id               com_api_type_pkg.t_long_id := i_oper.id;
begin
    trc_log_pkg.debug (
        i_text         => 'bgn_api_fin_pkg.create_operation start'
    );
    
    trc_log_pkg.debug(
        i_text          => 'oper_status [#1]'
      , i_env_param1    => i_oper.status  
    );

    opr_api_create_pkg.create_operation (
        io_oper_id                  => l_oper_id        
      , i_session_id                => get_session_id             
      , i_is_reversal               => i_oper.is_reversal            
      , i_original_id               => i_oper.original_id            
      , i_oper_type                 => i_oper.oper_type              
      , i_oper_reason               => i_oper.oper_reason            
      , i_msg_type                  => i_oper.msg_type               
      , i_status                    => i_oper.status                 
      , i_status_reason             => i_oper.status_reason          
      , i_sttl_type                 => i_oper.sttl_type              
      , i_terminal_type             => i_oper.terminal_type          
      , i_acq_inst_bin              => i_oper.acq_inst_bin           
      , i_forw_inst_bin             => i_oper.forw_inst_bin          
      , i_merchant_number           => i_oper.merchant_number        
      , i_terminal_number           => i_oper.terminal_number        
      , i_merchant_name             => i_oper.merchant_name          
      , i_merchant_street           => i_oper.merchant_street        
      , i_merchant_city             => i_oper.merchant_city          
      , i_merchant_region           => i_oper.merchant_region        
      , i_merchant_country          => i_oper.merchant_country       
      , i_merchant_postcode         => i_oper.merchant_postcode      
      , i_mcc                       => i_oper.mcc                    
      , i_originator_refnum         => i_oper.originator_refnum      
      , i_network_refnum            => i_oper.network_refnum         
      , i_oper_count                => i_oper.oper_count             
      , i_oper_request_amount       => i_oper.oper_request_amount    
      , i_oper_amount_algorithm     => i_oper.oper_amount_algorithm  
      , i_oper_amount               => i_oper.oper_amount            
      , i_oper_currency             => i_oper.oper_currency          
      , i_oper_cashback_amount      => i_oper.oper_cashback_amount   
      , i_oper_replacement_amount   => i_oper.oper_replacement_amount
      , i_oper_surcharge_amount     => i_oper.oper_surcharge_amount  
      , i_oper_date                 => i_oper.oper_date              
      , i_host_date                 => i_oper.host_date              
      , i_match_status              => i_oper.match_status           
      , i_sttl_amount               => i_oper.sttl_amount            
      , i_sttl_currency             => i_oper.sttl_currency          
      , i_dispute_id                => i_oper.dispute_id             
      , i_payment_order_id          => i_oper.payment_order_id       
      , i_payment_host_id           => i_oper.payment_host_id        
      , i_forced_processing         => i_oper.forced_processing      
      , i_proc_mode                 => i_oper.proc_mode              
      , i_clearing_sequence_num     => i_oper.clearing_sequence_num  
      , i_clearing_sequence_count   => i_oper.clearing_sequence_count
      , i_incom_sess_file_id        => i_oper.incom_sess_file_id
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => i_oper.msg_type
        , i_oper_type         => i_oper.oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
        , i_host_date         => i_oper.host_date
        , i_inst_id           => i_iss_part.inst_id
        , i_network_id        => i_iss_part.network_id
        , i_oper_reason       => i_oper.oper_reason
        , i_oper_currency     => i_oper.oper_currency
        , i_customer_id       => i_iss_part.customer_id
        , i_client_id_type    => i_iss_part.client_id_type
        , i_client_id_value   => i_iss_part.client_id_value
        , i_card_id           => i_iss_part.card_id
        , i_card_instance_id  => i_iss_part.card_instance_id
        , i_card_type_id      => i_iss_part.card_type_id
        , i_card_expir_date   => i_iss_part.card_expir_date
        , i_card_seq_number   => i_iss_part.card_seq_number
        , i_card_number       => i_iss_part.card_number
        , i_card_mask         => i_iss_part.card_mask
        , i_card_hash         => i_iss_part.card_hash
        , i_card_country      => i_iss_part.card_country
        , i_card_service_code => i_iss_part.card_service_code
        , i_card_inst_id      => i_iss_part.card_inst_id
        , i_card_network_id   => i_iss_part.card_network_id
        , i_account_id        => i_iss_part.account_id
        , i_account_type      => i_iss_part.account_type
        , i_account_number    => i_iss_part.account_number
        , i_account_amount    => i_iss_part.account_amount
        , i_account_currency  => i_iss_part.account_currency
        , i_auth_code         => i_iss_part.auth_code
        , i_split_hash        => i_iss_part.split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
    );

    update opr_participant
       set card_instance_id = i_iss_part.card_instance_id
     where participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and oper_id = l_oper_id;  

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => i_oper.msg_type
        , i_oper_type         => i_oper.oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
        , i_host_date         => i_oper.host_date
        , i_inst_id           => i_acq_part.inst_id
        , i_oper_reason       => i_oper.oper_reason
        , i_oper_currency     => i_oper.oper_currency
        , i_customer_id       => i_acq_part.customer_id
        , i_client_id_type    => i_acq_part.client_id_type
        , i_client_id_value   => i_acq_part.client_id_value
        , i_network_id        => i_acq_part.network_id
        , i_account_id        => i_acq_part.account_id
        , i_account_type      => i_acq_part.account_type
        , i_account_number    => i_acq_part.account_number
        , i_account_amount    => i_acq_part.account_amount
        , i_account_currency  => i_acq_part.account_currency
        , i_merchant_id       => i_acq_part.merchant_id
        , i_terminal_id       => i_acq_part.terminal_id
        , i_terminal_type     => i_oper.terminal_type
        , i_terminal_number   => i_oper.terminal_number
        , i_merchant_number   => i_oper.merchant_number
        , i_split_hash        => i_acq_part.split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
        , i_auth_code         => i_acq_part.auth_code
    );
    trc_log_pkg.debug (
        i_text         => 'bgn_api_fin_pkg.create_operation end'
    );
    
end create_operation;

procedure enum_messages_for_upload (
    o_fin_cur                  out  sys_refcursor
  , i_network_id            in      com_api_type_pkg.t_network_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_host_inst_id          in      com_api_type_pkg.t_inst_id
) is
    l_stmt                  com_api_type_pkg.t_text;
begin
    l_stmt := '
        select /*+ INDEX(f, bgn_fin_CLMS0010_ndx)*/
            '||g_column_list||'
        from bgn_fin f
           , bgn_card c
        where
            decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
            and f.is_incoming   = :is_incoming
            and f.network_id    = :i_network_id
            and f.inst_id       = :i_inst_id
            and f.host_inst_id  = :i_host_inst_id
            and c.id(+) = f.id
        order by f.id';

    open o_fin_cur for l_stmt using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;
end;

function estimate_messages_for_upload (
    i_network_id            in      com_api_type_pkg.t_network_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_host_inst_id          in      com_api_type_pkg.t_inst_id
) return number is
    l_result            number;
    
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_api_fin_pkg.estimate_messages_for_upload i_network_id [#1]. i_inst_id [#2], i_host_inst_id [#3]'
      , i_env_param1    => i_network_id  
      , i_env_param2    => i_inst_id
      , i_env_param3    => i_host_inst_id
    );
    
    select  /*+ INDEX(f, bgn_fin_CLMS0010_ndx)*/
           count(f.id)
      into l_result
      from bgn_fin f
     where
        decode(f.status, net_api_const_pkg.CLEARING_MSG_STATUS_READY, net_api_const_pkg.CLEARING_MSG_STATUS_READY, null) = net_api_const_pkg.CLEARING_MSG_STATUS_READY
        and f.is_incoming   = com_api_const_pkg.FALSE
        and f.network_id    = i_network_id
        and f.inst_id       = i_inst_id
        and f.host_inst_id  = i_host_inst_id;

    return l_result;
    
end;

function get_borica_code (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_network_id            in      com_api_type_pkg.t_network_id   default bgn_api_const_pkg.BORICA_NETWORK_ID
) return com_api_type_pkg.t_dict_value is
    l_result        com_api_type_pkg.t_dict_value;
    l_param_tab     com_api_type_pkg.t_param_tab;
begin
    if i_inst_id = bgn_api_const_pkg.BORICA_INST_ID then
        l_result := bgn_api_const_pkg.BORICA_OWN_CODE;
        
    else
        l_result := cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => i_inst_id
          , i_standard_id   => bgn_api_const_pkg.BGN_CLEARING_STANDARD
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id     => net_api_network_pkg.get_default_host(
                                    i_network_id    => i_network_id
                                )
          , i_param_name    => bgn_api_const_pkg.CMN_PARAMETER_BANK_CODE
          , i_param_tab     => l_param_tab
        );
        
    end if;
    
    return l_result;
    
end;

end bgn_api_fin_pkg;
/
