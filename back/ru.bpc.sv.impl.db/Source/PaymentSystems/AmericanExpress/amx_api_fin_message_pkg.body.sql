create or replace package body amx_api_fin_message_pkg as

g_column_list           com_api_type_pkg.t_text :=
    'f.id'                             
||  ', f.split_hash'                 
||  ', f.status'                     
||  ', f.inst_id'                      
||  ', f.network_id'                    
||  ', f.file_id'                      
||  ', f.is_invalid'                 
||  ', f.is_incoming'                
||  ', f.is_reversal'     
||  ', is_collection_only'           
||  ', f.is_rejected'                
||  ', f.reject_id'                  
||  ', f.dispute_id'                 
||  ', f.impact'                     
||  ', f.mtid'                       
||  ', f.func_code'                  
||  ', length(iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)) as card_number_length'                 
||  ', f.card_mask'                  
||  ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'                
||  ', f.card_hash'                  
||  ', f.proc_code'                  
||  ', f.trans_amount'               
||  ', f.trans_date'                 
||  ', f.card_expir_date'            
||  ', f.capture_date'               
||  ', f.mcc'  
||  ', f.pdc_1'                    
||  ', f.pdc_2'                    
||  ', f.pdc_3'                    
||  ', f.pdc_4'                    
||  ', f.pdc_5'                    
||  ', f.pdc_6'                    
||  ', f.pdc_7'                    
||  ', f.pdc_8'                    
||  ', f.pdc_9'                    
||  ', f.pdc_10'                   
||  ', f.pdc_11'                   
||  ', f.pdc_12'                   
||  ', f.reason_code'                
||  ', f.approval_code_length'       
||  ', f.iss_sttl_date'              
||  ', f.eci'                        
||  ', f.fp_trans_amount'      
||  ', f.ain'                        
||  ', f.apn'                      
||  ', f.arn'                      
||  ', f.approval_code'            
||  ', f.terminal_number'          
||  ', f.merchant_number'          
||  ', f.merchant_name'            
||  ', f.merchant_addr1'           
||  ', f.merchant_addr2'           
||  ', f.merchant_city'            
||  ', f.merchant_postal_code'     
||  ', f.merchant_country'       
||  ', f.merchant_region'        
||  ', f.iss_gross_sttl_amount'  
||  ', f.iss_rate_amount'        
||  ', f.matching_key_type'      
||  ', f.matching_key'           
||  ', f.iss_net_sttl_amount'    
||  ', f.iss_sttl_currency'      
||  ', f.iss_sttl_decimalization'
||  ', f.fp_trans_currency'      
||  ', f.trans_decimalization'   
||  ', f.fp_trans_decimalization'
||  ', f.fp_pres_amount'  
||  ', f.fp_pres_conversion_rate'
||  ', f.fp_pres_currency'
||  ', f.fp_pres_decimalization'    
||  ', f.merchant_multinational'    
||  ', f.trans_currency'            
||  ', f.add_acc_eff_type1'         
||  ', f.add_amount1'               
||  ', f.add_amount_type1'          
||  ', f.add_acc_eff_type2'         
||  ', f.add_amount2'               
||  ', f.add_amount_type2'          
||  ', f.add_acc_eff_type3'         
||  ', f.add_amount3'               
||  ', f.add_amount_type3'          
||  ', f.add_acc_eff_type4'         
||  ', f.add_amount4'               
||  ', f.add_amount_type4'          
||  ', f.add_acc_eff_type5'         
||  ', f.add_amount5'               
||  ', f.add_amount_type5'          
||  ', f.alt_merchant_number_length'
||  ', f.alt_merchant_number'    
||  ', f.fp_trans_date'          
||  ', f.icc_pin_indicator'      
||  ', f.card_capability'        
||  ', f.network_proc_date'      
||  ', f.program_indicator'      
||  ', f.tax_reason_code'        
||  ', f.fp_network_proc_date'   
||  ', f.format_code'            
||  ', f.iin'                    
||  ', f.media_code'             
||  ', f.message_seq_number'     
||  ', f.merchant_location_text' 
||  ', f.itemized_doc_code'      
||  ', f.itemized_doc_ref_number'
||  ', f.transaction_id'         
||  ', f.ext_payment_data'       
||  ', f.message_number'         
||  ', f.ipn'                    
||  ', f.invoice_number'         
||  ', f.reject_reason_code'     
||  ', f.chbck_reason_text'    
||  ', f.chbck_reason_code'    
||  ', f.valid_bill_unit_code' 
||  ', f.sttl_date'            
||  ', f.forw_inst_code'       
||  ', f.fee_reason_text'      
||  ', f.fee_type_code'        
||  ', f.receiving_inst_code'  
||  ', f.send_inst_code'       
||  ', f.send_proc_code'       
||  ', f.receiving_proc_code'
||  ', f.merchant_discount_rate'
; 
  
function get_format_code (
    i_mcc                   in     com_api_type_pkg.t_mcc  
  , i_message_seq_number    in     com_api_type_pkg.t_count
  , i_network_id            in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_byte_char
is 
    l_format_code   com_api_type_pkg.t_byte_char;
    l_curr_standard_version com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text => 'get_format_code: for ' || i_mcc || ' i_network_id=' || i_network_id
    );
    l_curr_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id => nvl(i_network_id, amx_api_const_pkg.TARGET_NETWORK)
        );
    trc_log_pkg.debug(
        i_text         => 'amx_api_fin_message_pkg.get_format_code standard version [#1]'
      , i_env_param1   => l_curr_standard_version
    );

    if i_mcc in ('4511', '4582', '5962')
            or (l_curr_standard_version >= amx_api_const_pkg.STANDARD_VERSION_ID_19Q2
                    and i_mcc between '3000' and '3301')
    then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_AIRLINE;

    elsif i_mcc in ('5310', '5311', '5965') then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_RETAIL;

    elsif i_mcc in ('6300') then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_INSURANCE;

    elsif i_mcc in ('4121', '7512', '7513', '7519')
            or (l_curr_standard_version >= amx_api_const_pkg.STANDARD_VERSION_ID_19Q2
                    and i_mcc between '3351' and '3441')
    then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_RENTAL;

    elsif i_mcc in ('4011, 4111, 4112')  then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_RAIL;
        
    elsif i_mcc in ('7011', '7012', '7032', '7033')
            or (l_curr_standard_version >= amx_api_const_pkg.STANDARD_VERSION_ID_19Q2
                    and i_mcc between '3501' and '3836')
    then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_LODGING;
        
    elsif i_mcc in ('5811', '5812', '5813', '5814') then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_RESTAURANT;
        
    elsif i_mcc in ('4812', '4814', '4815', '4816', '4821', '4899') then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_COMM_SRV;
        
    elsif i_mcc in ('4131', '4411', '4722') then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_TRAVEL;
        
    elsif i_mcc between '7800' and '7999' then
        l_format_code := amx_api_const_pkg.FORMAT_CODE_TICKETING;
    else
        l_format_code := amx_api_const_pkg.FORMAT_CODE_GENERAL; 
    end if;
    
    return l_format_code;

end;
   
procedure find_original_fin(
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
) is
    l_fin_cur               sys_refcursor;
    l_original_id           com_api_type_pkg.t_long_id;
    l_statement             com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text          => 'amx_api_fin_message_pkg.find_original_fin start'
    );
    
    l_original_id := get_original_id(i_fin_rec => i_fin_rec);

    trc_log_pkg.debug (
        i_text         => 'original_id [' || l_original_id || '], arn [' || i_fin_rec.arn || '], transaction_id [' || i_fin_rec.transaction_id || ']'
    );

    l_statement := 'select ' || g_column_list 
                 || ' from amx_fin_message f, amx_card c'
                 || ' where f.id = c.id(+)'
                 || ' and (f.id = :i_id or f.arn = :i_arn or f.transaction_id = :i_transaction_id)'
                 || ' order by f.id desc, f.dispute_id nulls last'
                 || ' for update';

    open l_fin_cur for l_statement
    using
        l_original_id
      , i_fin_rec.arn
      , i_fin_rec.transaction_id;

    amx_api_dispute_pkg.fetch_dispute_id (
        i_fin_cur    => l_fin_cur
        , o_fin_rec  => o_fin_rec
    );

    close l_fin_cur;
    
    trc_log_pkg.debug (
        i_text          => 'amx_api_fin_message_pkg.find_original_fin end'
    );
    
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        raise;
end;

procedure get_fin (
    i_id                    in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean         := com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statement             com_api_type_pkg.t_text;
begin

    l_statement := 'select ' || g_column_list 
                 || ' from amx_fin_message f, amx_card c'
                 || ' where f.id = :i_id and f.id = c.id(+)';

    open l_fin_cur for l_statement using i_id;
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

procedure get_fin (
    i_mtid                  in     com_api_type_pkg.t_mcc
  , i_func_code             in     com_api_type_pkg.t_curr_code
  , i_is_reversal           in     com_api_type_pkg.t_boolean
  , i_dispute_id            in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean
) is
    l_fin_cur               sys_refcursor;
    l_statement             com_api_type_pkg.t_text;
begin
    l_statement := 'select ' || g_column_list 
                 || ' from amx_fin_message f, amx_card c'
                 || ' where f.mtid = :i_mtid'
                 || ' and f.func_code = :i_func_code'
                 || ' and f.is_reversal = :i_is_reversal'
                 || ' and f.dispute_id = :i_dispute_id'
                 || ' and f.id = c.id(+)';

    open l_fin_cur for l_statement using i_mtid, i_func_code, i_is_reversal, i_dispute_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param2  => i_mtid
                , i_env_param3  => i_func_code
                , i_env_param4  => i_is_reversal
                , i_env_param5  => i_dispute_id
            );
        else
            trc_log_pkg.error (
                i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => null
                , i_env_param2  => i_mtid
                , i_env_param3  => i_func_code
                , i_env_param4  => i_is_reversal
                , i_env_param5  => i_dispute_id
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

function put_message (
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
) return com_api_type_pkg.t_long_id
is    
    l_id                    com_api_type_pkg.t_long_id;
    l_split_hash            com_api_type_pkg.t_tiny_id; 

begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_fin_message_pkg.put_message start'
    );

    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);
    l_split_hash := nvl(i_fin_rec.split_hash, com_api_hash_pkg.get_split_hash(i_fin_rec.card_number));

    insert into amx_fin_message (
        id                  
        , split_hash      
        , status          
        , inst_id            
        , network_id         
        , file_id           
        , is_invalid      
        , is_incoming     
        , is_reversal   
        , is_collection_only  
        , is_rejected     
        , reject_id       
        , dispute_id      
        , impact          
        , mtid            
        , func_code       
        , pan_length      
        , card_mask       
        , card_hash       
        , proc_code                  
        , trans_amount               
        , trans_date                 
        , card_expir_date            
        , capture_date               
        , mcc       
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
        , reason_code                
        , approval_code_length       
        , iss_sttl_date              
        , eci                        
        , fp_trans_amount      
        , ain                        
        , apn                        
        , arn                        
        , approval_code              
        , terminal_number            
        , merchant_number            
        , merchant_name              
        , merchant_addr1             
        , merchant_addr2             
        , merchant_city              
        , merchant_postal_code       
        , merchant_country           
        , merchant_region            
        , iss_gross_sttl_amount      
        , iss_rate_amount            
        , matching_key_type          
        , matching_key               
        , iss_net_sttl_amount        
        , iss_sttl_currency          
        , iss_sttl_decimalization    
        , fp_trans_currency          
        , trans_decimalization       
        , fp_trans_decimalization       
        , fp_pres_amount      
        , fp_pres_conversion_rate    
        , fp_pres_currency    
        , fp_pres_decimalization     
        , merchant_multinational     
        , trans_currency             
        , add_acc_eff_type1          
        , add_amount1                
        , add_amount_type1           
        , add_acc_eff_type2          
        , add_amount2                
        , add_amount_type2           
        , add_acc_eff_type3          
        , add_amount3                
        , add_amount_type3           
        , add_acc_eff_type4          
        , add_amount4                
        , add_amount_type4           
        , add_acc_eff_type5          
        , add_amount5                
        , add_amount_type5           
        , alt_merchant_number_length 
        , alt_merchant_number        
        , fp_trans_date              
        , icc_pin_indicator          
        , card_capability            
        , network_proc_date          
        , program_indicator          
        , tax_reason_code            
        , fp_network_proc_date       
        , format_code                
        , iin                        
        , media_code                 
        , message_seq_number         
        , merchant_location_text     
        , itemized_doc_code          
        , itemized_doc_ref_number    
        , transaction_id             
        , ext_payment_data           
        , message_number             
        , ipn                        
        , invoice_number             
        , reject_reason_code         
        , chbck_reason_text          
        , chbck_reason_code          
        , valid_bill_unit_code       
        , sttl_date                  
        , forw_inst_code             
        , fee_reason_text            
        , fee_type_code              
        , receiving_inst_code        
        , send_inst_code             
        , send_proc_code             
        , receiving_proc_code
        , merchant_discount_rate
    ) values (
        l_id
        , l_split_hash     
        , i_fin_rec.status          
        , i_fin_rec.inst_id            
        , i_fin_rec.network_id         
        , i_fin_rec.file_id           
        , i_fin_rec.is_invalid      
        , i_fin_rec.is_incoming     
        , i_fin_rec.is_reversal    
        , nvl(i_fin_rec.is_collection_only, com_api_type_pkg.FALSE) 
        , i_fin_rec.is_rejected     
        , i_fin_rec.reject_id       
        , i_fin_rec.dispute_id      
        , i_fin_rec.impact          
        , i_fin_rec.mtid            
        , i_fin_rec.func_code       
        , i_fin_rec.pan_length      
        , i_fin_rec.card_mask       
        , i_fin_rec.card_hash       
        , i_fin_rec.proc_code                  
        , i_fin_rec.trans_amount               
        , i_fin_rec.trans_date                 
        , i_fin_rec.card_expir_date            
        , i_fin_rec.capture_date               
        , i_fin_rec.mcc    
        , i_fin_rec.pdc_1                    
        , i_fin_rec.pdc_2                    
        , i_fin_rec.pdc_3                    
        , i_fin_rec.pdc_4                    
        , i_fin_rec.pdc_5                    
        , i_fin_rec.pdc_6                    
        , i_fin_rec.pdc_7                    
        , i_fin_rec.pdc_8                    
        , i_fin_rec.pdc_9                    
        , i_fin_rec.pdc_10                   
        , i_fin_rec.pdc_11                   
        , i_fin_rec.pdc_12                   
        , i_fin_rec.reason_code                
        , i_fin_rec.approval_code_length       
        , i_fin_rec.iss_sttl_date              
        , i_fin_rec.eci                        
        , i_fin_rec.fp_trans_amount      
        , i_fin_rec.ain                        
        , i_fin_rec.apn                        
        , i_fin_rec.arn                        
        , i_fin_rec.approval_code              
        , i_fin_rec.terminal_number            
        , i_fin_rec.merchant_number            
        , i_fin_rec.merchant_name              
        , i_fin_rec.merchant_addr1             
        , i_fin_rec.merchant_addr2             
        , i_fin_rec.merchant_city              
        , i_fin_rec.merchant_postal_code       
        , i_fin_rec.merchant_country           
        , i_fin_rec.merchant_region            
        , i_fin_rec.iss_gross_sttl_amount      
        , i_fin_rec.iss_rate_amount            
        , i_fin_rec.matching_key_type          
        , i_fin_rec.matching_key               
        , i_fin_rec.iss_net_sttl_amount        
        , i_fin_rec.iss_sttl_currency          
        , i_fin_rec.iss_sttl_decimalization    
        , i_fin_rec.fp_trans_currency          
        , i_fin_rec.trans_decimalization       
        , i_fin_rec.fp_trans_decimalization
        , i_fin_rec.fp_pres_amount      
        , i_fin_rec.fp_pres_conversion_rate    
        , i_fin_rec.fp_pres_currency    
        , i_fin_rec.fp_pres_decimalization     
        , i_fin_rec.merchant_multinational     
        , i_fin_rec.trans_currency             
        , i_fin_rec.add_acc_eff_type1          
        , i_fin_rec.add_amount1                
        , i_fin_rec.add_amount_type1           
        , i_fin_rec.add_acc_eff_type2          
        , i_fin_rec.add_amount2                
        , i_fin_rec.add_amount_type2           
        , i_fin_rec.add_acc_eff_type3          
        , i_fin_rec.add_amount3                
        , i_fin_rec.add_amount_type3           
        , i_fin_rec.add_acc_eff_type4          
        , i_fin_rec.add_amount4                
        , i_fin_rec.add_amount_type4           
        , i_fin_rec.add_acc_eff_type5          
        , i_fin_rec.add_amount5                
        , i_fin_rec.add_amount_type5           
        , i_fin_rec.alt_merchant_number_length 
        , i_fin_rec.alt_merchant_number        
        , i_fin_rec.fp_trans_date              
        , i_fin_rec.icc_pin_indicator          
        , i_fin_rec.card_capability            
        , i_fin_rec.network_proc_date          
        , i_fin_rec.program_indicator          
        , i_fin_rec.tax_reason_code            
        , i_fin_rec.fp_network_proc_date       
        , i_fin_rec.format_code                
        , i_fin_rec.iin                        
        , i_fin_rec.media_code                 
        , i_fin_rec.message_seq_number         
        , i_fin_rec.merchant_location_text     
        , i_fin_rec.itemized_doc_code          
        , i_fin_rec.itemized_doc_ref_number    
        , i_fin_rec.transaction_id             
        , i_fin_rec.ext_payment_data           
        , i_fin_rec.message_number             
        , i_fin_rec.ipn                        
        , i_fin_rec.invoice_number             
        , i_fin_rec.reject_reason_code         
        , i_fin_rec.chbck_reason_text          
        , i_fin_rec.chbck_reason_code          
        , i_fin_rec.valid_bill_unit_code       
        , i_fin_rec.sttl_date                  
        , i_fin_rec.forw_inst_code             
        , i_fin_rec.fee_reason_text            
        , i_fin_rec.fee_type_code              
        , i_fin_rec.receiving_inst_code        
        , i_fin_rec.send_inst_code             
        , i_fin_rec.send_proc_code             
        , i_fin_rec.receiving_proc_code
        , i_fin_rec.merchant_discount_rate
    );
    
    insert into amx_card (
        id
        , card_number
    ) values (
        l_id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );
    
    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] AMX fin messages'
        , i_env_param1  => l_id
    );

    return l_id;
end;

function get_original_id (
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
) return com_api_type_pkg.t_long_id is
    l_original_id           com_api_type_pkg.t_long_id;
    l_mtid                  com_api_type_pkg.t_mcc;
    l_func_code             com_api_type_pkg.t_curr_code;
    l_split_hash            com_api_type_pkg.t_inst_id;
    l_is_reversal           com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug (
        i_text          => 'amx_api_fin_message_pkg.get_original_id start'
    );
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.card_number);
    
    if i_fin_rec.mtid = amx_api_const_pkg.MTID_PRESENTMENT
       and i_fin_rec.func_code in (amx_api_const_pkg.FUNC_CODE_FIRST_PRES, amx_api_const_pkg.FUNC_CODE_SECOND_PRES)
       and i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.dispute_id is not null
    then -- reversal
        l_mtid := i_fin_rec.mtid;

        select min(id)
          into l_original_id
          from amx_fin_message
         where split_hash  = l_split_hash
           and mtid        = l_mtid
           and func_code   = i_fin_rec.func_code
           and is_reversal = com_api_type_pkg.FALSE
           and dispute_id  = i_fin_rec.dispute_id;

    else
        if i_fin_rec.mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST
        then
            l_mtid      := amx_api_const_pkg.MTID_PRESENTMENT;
            l_func_code := amx_api_const_pkg.FUNC_CODE_FIRST_PRES;

        elsif i_fin_rec.mtid = amx_api_const_pkg.MTID_FULFILLMENT
        then
            l_mtid      := amx_api_const_pkg.MTID_RETRIEVAL_REQUEST;
            l_func_code := i_fin_rec.func_code;

        elsif i_fin_rec.mtid = amx_api_const_pkg.MTID_CHARGEBACK
            and i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_CHARGEBACK
            or
            i_fin_rec.mtid = amx_api_const_pkg.MTID_FEE_COLLECTION
            or
            i_fin_rec.mtid = amx_api_const_pkg.MTID_ISS_ATM_FEE
            or
            i_fin_rec.mtid = amx_api_const_pkg.MTID_ACQ_ATM_FEE
        then
            if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then
                l_is_reversal := com_api_type_pkg.FALSE;
                l_mtid        := i_fin_rec.mtid;
                l_func_code   := i_fin_rec.func_code;
            else
                l_mtid        := amx_api_const_pkg.MTID_PRESENTMENT;
                l_func_code   := amx_api_const_pkg.FUNC_CODE_FIRST_PRES;
            end if;

        elsif i_fin_rec.mtid = amx_api_const_pkg.MTID_PRESENTMENT
            and i_fin_rec.func_code =  amx_api_const_pkg.FUNC_CODE_SECOND_PRES
        then
            if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then
            
                l_is_reversal := com_api_type_pkg.FALSE;
                l_mtid        := i_fin_rec.mtid;
                l_func_code   := i_fin_rec.func_code;
            else
                l_mtid        := amx_api_const_pkg.MTID_CHARGEBACK;
                l_func_code   := amx_api_const_pkg.FUNC_CODE_FIRST_CHARGEBACK;
            end if;

        elsif i_fin_rec.mtid = amx_api_const_pkg.MTID_CHARGEBACK
            and i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FINAL_CHARGEBACK
        then
            if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then

                l_is_reversal := com_api_type_pkg.FALSE;
                l_mtid        := i_fin_rec.mtid;
                l_func_code   := i_fin_rec.func_code;

            else
                l_mtid        := amx_api_const_pkg.MTID_PRESENTMENT;
                l_func_code   := amx_api_const_pkg.FUNC_CODE_SECOND_PRES;
            end if;

        end if;

        if l_mtid is not null then
            select min(id)
              into l_original_id
              from amx_fin_message
             where split_hash   = l_split_hash
               and mtid         = l_mtid
               and func_code    = l_func_code
               and (arn         = i_fin_rec.arn or transaction_id = i_fin_rec.transaction_id)
               and (is_reversal = l_is_reversal or l_is_reversal is null);
        end if;
    end if;

    trc_log_pkg.debug (
        i_text          => 'amx_api_fin_message_pkg.get_original_id end. l_original_id [' || l_original_id || ']'
    );

    return l_original_id;
end;

function get_merchant_amex (
    i_inst_id                 in    com_api_type_pkg.t_inst_id
  , i_merchant_number         in    com_api_type_pkg.t_merchant_number
) return com_api_type_pkg.t_merchant_number is
    l_result                  com_api_type_pkg.t_merchant_number;
begin
    select com_api_flexible_data_pkg.get_flexible_value(
              i_field_name   => 'AMX_MERCHANT_ID'
            , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
            , i_object_id    => m.id
           )
      into l_result
      from acq_merchant m
     where m.inst_id         = i_inst_id
       and m.merchant_number = i_merchant_number;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_merchant_sv (
    i_inst_id                 in    com_api_type_pkg.t_inst_id
  , i_merchant_number         in    com_api_type_pkg.t_merchant_number
) return com_api_type_pkg.t_merchant_number is
    l_result                  com_api_type_pkg.t_merchant_number;
begin

    if i_merchant_number is null then
        return null;
    end if;

    select m.merchant_number
      into l_result
      from acq_merchant m
     where m.inst_id         = i_inst_id
       and m.merchant_number = i_merchant_number;

    return l_result;

exception
    when no_data_found then
        begin
            -- Amex SE to SV merchant number
            select m.merchant_number
              into l_result
              from com_flexible_field f
                 , com_flexible_data d
                 , acq_merchant m
             where d.field_id      = f.id
               and d.object_id     = m.id
               and f.name          = 'AMX_MERCHANT_ID'
               and f.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               and m.inst_id       = i_inst_id
               and m.merchant_type = acq_api_const_pkg.CURRENT_MERCHANT
               and d.field_value   = i_merchant_number;

            return l_result;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error             => 'Merchant is not found by Amex SE value [#1][#2]'
                  , i_env_param1        => i_merchant_number
                  , i_env_param2        => i_inst_id
                );
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error             => 'Too many merchants use the same Amex SE value [#1][#2]'
                  , i_env_param1        => i_merchant_number
                  , i_env_param2        => i_inst_id
                );
        end;
end;

procedure create_operation(
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_auth                  in     aut_api_type_pkg.t_auth_rec        := null
  , i_status                in     com_api_type_pkg.t_dict_value      := null
  , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id         := null
  , i_host_id               in     com_api_type_pkg.t_tiny_id         default null
)is
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_original_id                   com_api_type_pkg.t_long_id;
    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_iss_part                      opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                      opr_api_type_pkg.t_oper_part_rec;

    l_msg_type                      com_api_type_pkg.t_dict_value;
    l_sttl_type                     com_api_type_pkg.t_dict_value;
    l_oper_type                     com_api_type_pkg.t_dict_value;

    l_status                        com_api_type_pkg.t_dict_value;
    l_terminal_type                 com_api_type_pkg.t_dict_value;

    l_iss_inst_id                   com_api_type_pkg.t_inst_id;
    l_iss_network_id                com_api_type_pkg.t_tiny_id;
    l_card_inst_id                  com_api_type_pkg.t_inst_id;
    l_card_network_id               com_api_type_pkg.t_tiny_id;
    l_card_type_id                  com_api_type_pkg.t_tiny_id;
    l_card_country                  com_api_type_pkg.t_country_code;
    l_bin_currency                  com_api_type_pkg.t_curr_code;
    l_sttl_currency                 com_api_type_pkg.t_curr_code;
    l_acq_inst_id                   com_api_type_pkg.t_inst_id;
    l_acq_network_id                com_api_type_pkg.t_tiny_id;
    l_sttl_amount                   com_api_type_pkg.t_money;  
    l_card_exp_date                 date;
    l_card_seq_number               com_api_type_pkg.t_tiny_id;

    l_match_status                  com_api_type_pkg.t_dict_value;
    l_merchant_number               com_api_type_pkg.t_merchant_number;
    l_terminal_number               com_api_type_pkg.t_terminal_number;

begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_fin_message_pkg.create_operation start'
    );
    l_oper_id     := i_fin_rec.id;
    l_original_id := get_original_id(i_fin_rec => i_fin_rec);
    l_status      := nvl(i_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);

    opr_api_operation_pkg.get_operation(
        i_oper_id    => l_original_id
      , o_operation  => l_operation
    );

    if i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.is_incoming = com_api_type_pkg.FALSE
    then
        l_sttl_type := l_operation.sttl_type;
        l_oper_type := l_operation.oper_type;
        l_msg_type  := l_operation.msg_type;

        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_original_id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant        => l_participant
        );

        l_iss_inst_id         := l_participant.inst_id;
        l_iss_network_id      := l_participant.network_id;
        l_iss_part.split_hash := l_participant.split_hash;
        l_card_type_id        := l_participant.card_type_id;
        l_card_country        := l_participant.card_country;
        l_card_inst_id        := l_participant.card_inst_id;
        l_card_network_id     := l_participant.card_network_id;

        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_original_id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant        => l_participant
        );

        l_acq_inst_id          := l_participant.inst_id;
        l_acq_network_id       := l_participant.network_id;
        l_acq_part.split_hash  := l_participant.split_hash;
        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_terminal_type        := l_operation.terminal_type;

    --fee collection is incoming only. It comes from Network. Fin message have no PAN
    elsif i_fin_rec.mtid = amx_api_const_pkg.MTID_FEE_COLLECTION
          or
          i_fin_rec.mtid = amx_api_const_pkg.MTID_ISS_ATM_FEE
          or
          i_fin_rec.mtid = amx_api_const_pkg.MTID_ACQ_ATM_FEE
    then
        
        l_iss_inst_id       := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);
        l_iss_network_id    := i_fin_rec.network_id;
        l_acq_inst_id       := i_fin_rec.inst_id;
        l_acq_network_id    := ost_api_institution_pkg.get_inst_network(i_fin_rec.inst_id);
        l_card_inst_id      := l_iss_inst_id;
        l_card_network_id   := l_iss_network_id;
        
        if l_oper_type is null then
            l_oper_type := net_api_map_pkg.get_oper_type(
                               i_network_oper_type => i_fin_rec.mtid || i_fin_rec.proc_code || nvl(i_fin_rec.mcc, '____')
                             , i_standard_id       => i_standard_id
                             , i_mask_error        => com_api_type_pkg.FALSE
                           );
        end if;
                
        if l_operation.id is not null then

            opr_api_operation_pkg.get_participant(
                i_oper_id            => l_operation.id
              , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_participant        => l_participant
            );

            l_iss_part.split_hash := l_participant.split_hash;
            l_card_inst_id        := nvl(l_card_inst_id, l_participant.card_inst_id);
            l_card_network_id     := nvl(l_card_network_id, l_participant.card_network_id);
            l_card_exp_date       := l_participant.card_expir_date;
            l_card_seq_number     := l_participant.card_seq_number;

            opr_api_operation_pkg.get_participant(
                i_oper_id            => l_operation.id
              , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
              , o_participant        => l_participant
            );

            l_acq_part.split_hash  := l_participant.split_hash;
            l_acq_part.merchant_id := l_participant.merchant_id;
            l_acq_part.terminal_id := l_participant.terminal_id;
            l_merchant_number      := l_operation.merchant_number;
            l_terminal_number      := l_operation.terminal_number;
            l_terminal_type        := l_operation.terminal_type;

        else

            l_iss_part.split_hash :=
                com_api_hash_pkg.get_split_hash(
                    i_value             => l_oper_id
                );
            l_acq_part.split_hash := l_iss_part.split_hash;

        end if;

        begin
            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => nvl(i_fin_rec.ain, i_fin_rec.forw_inst_code)
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper_type
            );
        exception
            when others then
            
                trc_log_pkg.error(
                    i_text          => sqlerrm
                );

                l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

                update amx_fin_message
                   set status = amx_api_const_pkg.MSG_STATUS_INVALID
                 where id = i_fin_rec.id;

                trc_log_pkg.debug(
                    i_text          => 'Set message status is invalid and save operation'
                );
        end;        
        
    elsif i_auth.id is null then
    
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => i_fin_rec.card_number
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_card_country
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );

        if l_iss_inst_id is null or l_iss_network_id is null then

            if l_operation.id is not null then

                opr_api_operation_pkg.get_participant(
                    i_oper_id            => l_operation.id
                  , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                  , o_participant        => l_participant
                );

                l_iss_inst_id       := l_participant.inst_id;
                l_iss_network_id    := l_participant.network_id;
            else
                l_iss_inst_id    := i_fin_rec.inst_id;
                l_iss_network_id := ost_api_institution_pkg.get_inst_network(i_fin_rec.inst_id);
            end if;
        end if;

        if l_acq_inst_id is null or l_acq_network_id is null then

            if l_operation.id is not null then

                opr_api_operation_pkg.get_participant(
                    i_oper_id            => l_operation.id
                  , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
                  , o_participant        => l_participant
                );

                l_acq_inst_id       := l_participant.inst_id;
                l_acq_network_id    := l_participant.network_id;
            else
                l_acq_inst_id       := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);
                l_acq_network_id := i_fin_rec.network_id;
            end if;

        end if;

        if l_card_inst_id is null or l_card_network_id is null then

            if l_operation.id is not null then

                opr_api_operation_pkg.get_participant(
                    i_oper_id            => l_operation.id
                  , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                  , o_participant        => l_participant
                );

                l_card_inst_id        := l_participant.card_inst_id;
                l_card_network_id     := l_participant.card_network_id;
            else
                l_card_inst_id        := l_iss_inst_id;
                l_card_network_id     := l_iss_network_id;
            end if;
        end if;

        begin
            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => nvl(i_fin_rec.ain, i_fin_rec.apn)
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper_type
            );
            
            trc_log_pkg.debug (
                i_text         => 'l_iss_inst_id [' || l_iss_inst_id || '], l_acq_inst_id [' || l_acq_inst_id || '], l_sttl_type [' || l_sttl_type || ']'
            );
            
        exception
            when others then
            
                trc_log_pkg.error(
                    i_text          => sqlerrm
                );

                l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

                update amx_fin_message
                   set status = amx_api_const_pkg.MSG_STATUS_INVALID
                 where id = i_fin_rec.id;

                trc_log_pkg.debug(
                    i_text          => 'Set message status is invalid and save operation'
                );
        end;
        
    else
        l_sttl_type       := i_auth.sttl_type;
        l_iss_inst_id     := i_auth.iss_inst_id;
        l_iss_network_id  := i_auth.iss_network_id;
        l_acq_inst_id     := i_auth.acq_inst_id;
        l_acq_network_id  := i_auth.acq_network_id;
        l_match_status    := i_auth.match_status;

        l_card_type_id    := i_auth.card_type_id;
        l_card_country    := i_auth.card_country;
        l_card_inst_id    := i_auth.card_inst_id;
        l_card_network_id := i_auth.card_network_id;
        l_terminal_type   := l_operation.terminal_type;
    end if;

    -- Operation type and message type are not defined by a financial message in case of reversal operation,
    -- fields' values of an original operation are used instead of this
    if l_msg_type is null then
        l_msg_type := net_api_map_pkg.get_msg_type(
                          i_network_msg_type   => i_fin_rec.mtid || i_fin_rec.func_code
                        , i_standard_id        => i_standard_id
                        , i_mask_error         => com_api_type_pkg.FALSE
                      );
    end if;

    if l_oper_type is null then
        l_oper_type := net_api_map_pkg.get_oper_type(
                           i_network_oper_type => i_fin_rec.mtid || i_fin_rec.proc_code || nvl(i_fin_rec.mcc, '____') 
                         , i_standard_id       => i_standard_id
                         , i_mask_error        => com_api_type_pkg.FALSE
                       );
    end if;

    if l_terminal_type is null then 
        l_terminal_type      :=  case i_fin_rec.mcc
                                          when '6011' then acq_api_const_pkg.TERMINAL_TYPE_ATM
                                          else acq_api_const_pkg.TERMINAL_TYPE_POS
                                      end;
    end if;

    trc_log_pkg.debug (
        i_text         => 'l_oper_type [' || l_oper_type || '], l_msg_type [' || l_msg_type || '], l_terminal_type [' || l_terminal_type || ']'
    );
    
    -- Amex sends incorrect merchant and terminal numbers for transaction types listed below,
    -- so there is a need to replace them by the original values
    if i_fin_rec.mtid = amx_api_const_pkg.MTID_PRESENTMENT 
      and i_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_SECOND_PRES
    or
       i_fin_rec.mtid = amx_api_const_pkg.MTID_CHARGEBACK 
      and i_fin_rec.func_code in (amx_api_const_pkg.FUNC_CODE_FIRST_CHARGEBACK, amx_api_const_pkg.FUNC_CODE_FINAL_CHARGEBACK)
    or
       i_fin_rec.mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST
    or
       i_fin_rec.mtid = amx_api_const_pkg.MTID_FULFILLMENT
    then
        opr_api_operation_pkg.get_operation(
            i_oper_id             => l_original_id
          , o_operation           => l_operation
        );
        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant        => l_participant
        );

        l_iss_part.split_hash := l_participant.split_hash;
        l_card_inst_id        := nvl(l_card_inst_id, l_participant.card_inst_id);
        l_card_network_id     := nvl(l_card_network_id, l_participant.card_network_id);
        l_card_exp_date       := l_participant.card_expir_date;
        l_card_seq_number     := l_participant.card_seq_number;

        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant        => l_participant
        );

        l_acq_part.split_hash  := l_participant.split_hash;
        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_merchant_number      := l_operation.merchant_number;
        l_terminal_number      := l_operation.terminal_number;
        l_terminal_type        := l_operation.terminal_type;

    end if;

    l_merchant_number := nvl(l_merchant_number, i_fin_rec.merchant_number);
    l_merchant_number := nvl(get_merchant_sv(i_inst_id => i_fin_rec.inst_id, i_merchant_number => l_merchant_number), l_merchant_number);
    l_terminal_number := nvl(l_terminal_number, i_fin_rec.terminal_number);

    if l_acq_part.merchant_id is null then
        acq_api_merchant_pkg.get_merchant(
            i_inst_id         => i_fin_rec.inst_id
          , i_merchant_number => l_merchant_number
          , o_merchant_id     => l_acq_part.merchant_id
          , o_split_hash      => l_acq_part.split_hash
        );
    end if;

    if l_acq_part.terminal_id is null then
        acq_api_terminal_pkg.get_terminal(
            i_merchant_id     => l_acq_part.merchant_id
          , i_terminal_number => l_terminal_number
          , o_terminal_id     => l_acq_part.terminal_id
        );

        if l_acq_part.terminal_id is null then
            acq_api_terminal_pkg.get_terminal(
                i_merchant_id     => acq_api_merchant_pkg.get_root_merchant_id(i_merchant_id => l_acq_part.merchant_id)
              , i_terminal_number => l_terminal_number
              , o_terminal_id     => l_acq_part.terminal_id
            );
        end if;
    end if;

    trc_log_pkg.debug (
        i_text     => 'i_fin_rec.card_number [' || iss_api_card_pkg.get_card_mask(i_fin_rec.card_number)
                    || '], l_merchant_number [' || l_merchant_number || '], i_fin_rec.merchant_number [' || i_fin_rec.merchant_number
                    || '], l_terminal_number [' || l_terminal_number || '], i_fin_rec.terminal_number [' || i_fin_rec.terminal_number
                    || ']'
    );

    opr_api_create_pkg.create_operation(
        io_oper_id              => l_oper_id
      , i_session_id            => get_session_id
      , i_status                => l_status
      , i_status_reason         => null
      , i_sttl_type             => l_sttl_type
      , i_msg_type              => l_msg_type
      , i_oper_type             => l_oper_type
      , i_oper_reason           => null
      , i_is_reversal           => i_fin_rec.is_reversal
      , i_original_id           => l_original_id
      , i_oper_amount           => i_fin_rec.trans_amount
      , i_oper_currency         => i_fin_rec.trans_currency
      , i_sttl_amount           => nvl(i_fin_rec.iss_net_sttl_amount, i_fin_rec.iss_gross_sttl_amount)
      , i_sttl_currency         => i_fin_rec.iss_sttl_currency
      , i_oper_date             => i_fin_rec.trans_date      
      , i_host_date             => null
      , i_terminal_type         => l_terminal_type
      , i_mcc                   => i_fin_rec.mcc
      , i_originator_refnum     => i_fin_rec.transaction_id
      , i_network_refnum        => i_fin_rec.arn
      , i_acq_inst_bin          => nvl(i_fin_rec.ain, i_fin_rec.apn)
      , i_merchant_number       => l_merchant_number
      , i_terminal_number       => l_terminal_number
      , i_merchant_name         => i_fin_rec.merchant_name
      , i_merchant_street       => i_fin_rec.merchant_addr1
      , i_merchant_city         => i_fin_rec.merchant_city
      , i_merchant_region       => i_fin_rec.merchant_region
      , i_merchant_country      => i_fin_rec.merchant_country
      , i_merchant_postcode     => i_fin_rec.merchant_postal_code
      , i_dispute_id            => i_fin_rec.dispute_id
      , i_match_status          => l_match_status
      , i_incom_sess_file_id    => i_incom_sess_file_id
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => l_msg_type
      , i_oper_type         => l_oper_type
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date         => null
      , i_inst_id           => l_iss_inst_id
      , i_network_id        => l_iss_network_id
      , i_customer_id       => iss_api_card_pkg.get_customer_id(i_fin_rec.card_number)
      , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
      , i_client_id_value   => i_fin_rec.card_number
      , i_card_id           => iss_api_card_pkg.get_card_id(i_fin_rec.card_number)
      , i_card_type_id      => l_card_type_id
      , i_card_expir_date   => l_card_exp_date
      , i_card_seq_number   => l_card_seq_number
      , i_card_number       => i_fin_rec.card_number
      , i_card_mask         => iss_api_card_pkg.get_card_mask(i_fin_rec.card_number)
      , i_card_hash         => com_api_hash_pkg.get_card_hash(i_fin_rec.card_number)
      , i_card_country      => l_card_country
      , i_card_inst_id      => l_card_inst_id
      , i_card_network_id   => l_card_network_id
      , i_account_id        => null
      , i_account_number    => null
      , i_account_amount    => null
      , i_account_currency  => null
      , i_auth_code         => i_fin_rec.approval_code
      , i_split_hash        => l_iss_part.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => l_msg_type
      , i_oper_type         => l_oper_type
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_host_date         => null
      , i_inst_id           => l_acq_inst_id
      , i_network_id        => l_acq_network_id
      , i_merchant_id       => l_acq_part.merchant_id
      , i_terminal_id       => l_acq_part.terminal_id
      , i_merchant_number   => l_merchant_number
      , i_terminal_number   => l_terminal_number
      , i_split_hash        => l_acq_part.split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );

    trc_log_pkg.debug (
        i_text         => 'amx_api_fin_message_pkg.create_operation end'
    );
    
end;

procedure load_fin_message(
    i_fin_id                in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean         default com_api_type_pkg.FALSE
) is
    l_stmt                  com_api_type_pkg.t_text;
    l_fin_cur               sys_refcursor;
begin
    l_stmt :=
        'select '||g_column_list
     ||  ' from amx_fin_message f'
     ||     ' , amx_card c'
     || ' where f.id = :i_id'
     ||   ' and f.id = c.id(+)';
        
    open l_fin_cur for l_stmt using i_fin_id;

    if l_fin_cur%isopen then
        fetch l_fin_cur into o_fin_rec;
        close l_fin_cur;
    end if;
    
    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_fin_id
            );
        else
            trc_log_pkg.error (
                i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_fin_id
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

function assign_proc_code(
    i_oper_type             in     com_api_type_pkg.t_dict_value
  , i_auth_mcc              in     com_api_type_pkg.t_mcc
  , i_is_reversal           in     com_api_type_pkg.t_boolean 
) return com_api_type_pkg.t_auth_code is
    l_proc_code         com_api_type_pkg.t_auth_code;
    l_auth_action_code  number(1);
begin
    if i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                          , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                          , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                          , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                          , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                          , opr_api_const_pkg.OPERATION_TYPE_UNIQUE) 
    then
        l_auth_action_code := -1; -- Debit
        
    elsif i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                             , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                             , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT) 
    then
        l_auth_action_code := 1; -- Credit
    end if;
    
    if l_auth_action_code = -1 and i_is_reversal = 0
    or l_auth_action_code = 1 and i_is_reversal = 1 
    then
        if i_auth_mcc = '6010' then
        
            l_proc_code := amx_api_const_pkg.PROC_CODE_CASH_DISB_DB;
        elsif i_auth_mcc = '6011' then    
        
            l_proc_code := amx_api_const_pkg.PROC_CODE_ATM_CASH;
        else    
            l_proc_code := amx_api_const_pkg.PROC_CODE_DEBIT;
        end if; 
           
    elsif l_auth_action_code = 1 and i_is_reversal = 0
    or l_auth_action_code = -1 and i_is_reversal = 1
    then
        if i_auth_mcc = '6010' then
        
            l_proc_code := amx_api_const_pkg.PROC_CODE_CASH_DISB_CR;
        else
            l_proc_code := amx_api_const_pkg.PROC_CODE_CREDIT;
        end if;
            
    end if;
    
    return l_proc_code;
end;

procedure process_auth (
    i_auth_rec              in     aut_api_type_pkg.t_auth_rec
  , i_id                    in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id         := null
  , i_network_id            in     com_api_type_pkg.t_tiny_id         := null
  , i_status                in     com_api_type_pkg.t_dict_value      := null
  , i_collection_only       in     com_api_type_pkg.t_boolean         := null
)is
    l_fin_rec               amx_api_type_pkg.t_amx_fin_mes_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_cmid_name             com_api_type_pkg.t_name;
    l_trans_decimalization  com_api_type_pkg.t_curr_code;
    l_param_tab             com_api_type_pkg.t_param_tab := opr_api_shared_data_pkg.g_params;
    l_terminal_type         com_api_type_pkg.t_dict_value;
    l_collection_only       com_api_type_pkg.t_boolean;
    l_stage                 varchar2(100);
    l_pdc_1                 com_api_type_pkg.t_dict_value;
    l_pdc_2                 com_api_type_pkg.t_dict_value;
    l_pdc_3                 com_api_type_pkg.t_dict_value;
    l_pdc_4                 com_api_type_pkg.t_dict_value;
    l_pdc_5                 com_api_type_pkg.t_dict_value;
    l_pdc_6                 com_api_type_pkg.t_dict_value;
    l_pdc_7                 com_api_type_pkg.t_dict_value;
    l_pdc_8                 com_api_type_pkg.t_dict_value;
    l_pdc_9                 com_api_type_pkg.t_dict_value;
    l_pdc_10                com_api_type_pkg.t_dict_value;
    l_pdc_11                com_api_type_pkg.t_dict_value;
    l_pdc_12                com_api_type_pkg.t_dict_value;
    l_message_seq_number    pls_integer := 0;
    l_merchant_id           com_api_type_pkg.t_short_id;
    l_merch_discount_fee_id com_api_type_pkg.t_short_id;
    l_merchant_discount     com_api_type_pkg.t_merchant_number;
    l_merchant_split_hash   com_api_type_pkg.t_tiny_id;

    procedure generate_pos_data_code is
    begin
        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM 
        then
            if l_pdc_7 in ('F227000C', 'F227000F', 'F227000M', 'F227000N', 'F227000R', 'F227000P', 'F227000A') then  -- chip or contactless A, P - ?
                --'510201510141' - chip
                l_fin_rec.pdc_1 :=  '5';
                l_fin_rec.pdc_2 :=  '1';
                l_fin_rec.pdc_3 :=  '0';
                l_fin_rec.pdc_4 :=  '2';
                l_fin_rec.pdc_5 :=  '0';
                l_fin_rec.pdc_6 :=  '1';
                l_fin_rec.pdc_7 :=  '5';
                l_fin_rec.pdc_8 :=  '1';
                l_fin_rec.pdc_9 :=  '0';
                l_fin_rec.pdc_10 := '1';
                l_fin_rec.pdc_11 := '4';
                l_fin_rec.pdc_12 := '1';                
            else
                --'210201210141' - non chip
                l_fin_rec.pdc_1 :=  '2';
                l_fin_rec.pdc_2 :=  '1';
                l_fin_rec.pdc_3 :=  '0';
                l_fin_rec.pdc_4 :=  '2';
                l_fin_rec.pdc_5 :=  '0';
                l_fin_rec.pdc_6 :=  '1';
                l_fin_rec.pdc_7 :=  '2';
                l_fin_rec.pdc_8 :=  '1';
                l_fin_rec.pdc_9 :=  '0';
                l_fin_rec.pdc_10 := '1';
                l_fin_rec.pdc_11 := '4';
                l_fin_rec.pdc_12 := '1';                
            end if;    
        else   
            l_fin_rec.pdc_1 :=
                case l_pdc_1
                    when 'F2210000' then '0'
                    when 'F2210001' then '1'
                    when 'F2210002' then '2'
                    when 'F221000A' then '2'
                    when 'F221000B' then '2'
                    when 'F2210003' then '3'
                    when 'F2210004' then '4'
                    when 'F2210005' then '5'
                    when 'F221000C' then '5'
                    when 'F221000D' then '5'
                    when 'F221000E' then '5'
                    when 'F221000M' then '5'
                    when 'F2210006' then '6'
                    else null
                end;

            l_fin_rec.pdc_2 :=
                case l_pdc_2
                    when 'F2220000' then '0'
                    when 'F2220001' then '1'
                    when 'F2220008' then '1'
                    when 'F2220002' then '2'
                    when 'F2220005' then '5'
                    when 'F2220006' then '6'
                    else null
                end;
                
            l_fin_rec.pdc_3 :=
                case l_pdc_3
                    when 'F2230000' then '0'
                    when 'F2230001' then '1'
                    else null
                end;

            l_fin_rec.pdc_4 :=
                case l_pdc_4
                    when 'F2240000' then '0'
                    when 'F2240001' then '1'
                    when 'F2240002' then '2'
                    when 'F2240003' then '3'
                    when 'F2240004' then '4'
                    when 'F2240005' then '5'
                    when 'F2240006' then '5' -- A, B - not mapped
                    else null
                end;
                
            if l_pdc_5 = 'F2250000' and l_fin_rec.mcc = '6010' then
                l_fin_rec.pdc_5 := 'T';
            else
                l_fin_rec.pdc_5 := 
                    case l_pdc_5
                        when 'F2250000' then '0'
                        when 'F2250001' then '1'
                        when 'F2250002' then '2'
                        when 'F2250003' then '3'
                        when 'F2250004' then '4'
                        when 'F2250005' then 'S'
                        when 'F2250006' then '5'
                        else null
                    end;
            end if;
            
            if l_pdc_7 in ('F227000A', 'F227000N', 'F227000P', 'F227000M') then
            
                l_fin_rec.pdc_6 := 'X'; -- contactless
            else                
                l_fin_rec.pdc_6 :=
                    case l_pdc_6
                        when 'F2260000' then '1'
                        when 'F2260001' then '0'
                        else null
                    end;
            end if;

            --Amex V and W not mapped
            if l_pdc_7 in ('F2270002', 'F227000B') then
                l_fin_rec.pdc_7 := '2'; --magnetic stripe
                
            elsif l_pdc_7 in ('F227000C', 'F227000F', 'F227000M', 'F227000N', 'F227000R', 'F227000P', 'F227000A') then  -- chip or contactless A, P - ?
                l_fin_rec.pdc_7 := '5';

            elsif l_pdc_7 in ('F2270005', 'F2270007', 'F2270009') then  -- E-commerce
                l_fin_rec.pdc_7 := 'S';
                            
            else
                l_fin_rec.pdc_7 :=
                    case l_pdc_7
                        when 'F2270000' then '0'
                        when 'F2270001' then '1'
                        when 'F2270003' then '3'
                        when 'F2270006' then '6'
                        when 'F227000W' then 'W'
                        when 'F227000E' then '0'
                        else null
                    end;
            end if;
            
            l_fin_rec.pdc_8 :=
                case l_pdc_8
                    when 'F2280000' then '0'
                    when 'F2280001' then '1'
                    when 'F2280002' then '2'
                    when 'F2280005' then '5'
                    when 'F2280006' then '6'
                    when 'F228000S' then 'S'
                    when 'F228000W' then '6'
                    when 'F228000X' then '6'
                    else null
                end;

            l_fin_rec.pdc_9 :=
                case l_pdc_9
                    when 'F2290000' then '0'
                    when 'F2290001' then '1'
                    when 'F2290002' then '2'
                    when 'F2290003' then '3'
                    when 'F2290004' then '4'
                    when 'F2290005' then '5'
                    when 'F2290006' then '5'
                    else null
                end;

            l_fin_rec.pdc_10 :=
                case l_pdc_10
                    when 'F22A0000' then '0'
                    when 'F22A0001' then '1'
                    when 'F22A0002' then '2'
                    when 'F22A0003' then '3'
                    else null
                end;

            l_fin_rec.pdc_11 :=
                case l_pdc_11
                    when 'F22B0000' then '0'
                    when 'F22B0001' then '1'
                    when 'F22B0002' then '2'
                    when 'F22B0003' then '3'
                    when 'F22B0004' then '4'
                    else null
                end;

            l_fin_rec.pdc_12 :=
                case l_pdc_12
                    when 'F22C0000' then '0'
                    when 'F22C0001' then '1'
                    when 'F22C0003' then '3'
                    when 'F22C0004' then '4'
                    when 'F22C0005' then '5'
                    when 'F22C0006' then '6'
                    when 'F22C0007' then '7'
                    when 'F22C0008' then '8'
                    when 'F22C0009' then '9'
                    when 'F22C000A' then 'A'
                    when 'F22C000B' then 'B'
                    when 'F22C000C' then 'C'
                    else null
                end;        
        end if;  
          
    end;
    
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_fin_message_pkg.process_auth start'
    );
    l_stage := 'start';

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then

        get_fin (
            i_id            => i_auth_rec.original_id
            , o_fin_rec     => l_fin_rec
        );

        l_stage := 'update original';
        update amx_fin_message
           set status = case
                            when status = net_api_const_pkg.CLEARING_MSG_STATUS_READY
                                 and trans_amount = i_auth_rec.oper_amount
                            then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                            else status
                        end
         where id = i_auth_rec.original_id
         returning case
                       when status = net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                            or i_auth_rec.oper_amount = 0
                       then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                       else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                   end
          into l_fin_rec.status;

        l_stage := 'init record';
        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := com_api_type_pkg.TRUE;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_collection_only := nvl(i_collection_only, com_api_type_pkg.FALSE);         
        
        l_stage := 'proc_code';
        l_fin_rec.proc_code       := assign_proc_code(
                                        i_oper_type   => i_auth_rec.oper_type
                                      , i_auth_mcc    => i_auth_rec.mcc
                                      , i_is_reversal => i_auth_rec.is_reversal 
                                    );
        trc_log_pkg.debug (
            i_text         => 'proc_code [' || l_fin_rec.proc_code || ']'
        );
                                    
        l_stage := 'impact';
        l_fin_rec.impact := 
            amx_prc_incoming_pkg.get_message_impact(   
                i_mtid            => l_fin_rec.mtid
                , i_func_code     => l_fin_rec.func_code
                , i_proc_code     => l_fin_rec.proc_code
                , i_incoming      => l_fin_rec.is_incoming
                , i_raise_error   => com_api_type_pkg.TRUE
            );
            
        trc_log_pkg.debug (
            i_text         => 'impact [' || l_fin_rec.impact || ']'
        );

        l_stage := 'amounts';
        l_fin_rec.trans_amount    := i_auth_rec.oper_amount;
        l_fin_rec.trans_currency  := i_auth_rec.oper_currency;
        l_trans_decimalization    := com_api_currency_pkg.get_currency_exponent(i_auth_rec.oper_currency);
        l_fin_rec.trans_decimalization  := l_trans_decimalization;
        
        if l_fin_rec.is_collection_only = com_api_type_pkg.TRUE then
        
            l_fin_rec.fp_trans_amount          := i_auth_rec.oper_amount;
            l_fin_rec.fp_trans_decimalization  := l_trans_decimalization;
            l_fin_rec.fp_trans_currency        := i_auth_rec.oper_currency;
        end if;    

        l_fin_rec.fp_pres_amount          := i_auth_rec.oper_amount;
        l_fin_rec.fp_pres_conversion_rate := 1;
        l_fin_rec.fp_pres_currency        := i_auth_rec.oper_currency;
        l_fin_rec.fp_pres_decimalization  := l_trans_decimalization;
        
        l_fin_rec.id                      := i_id;
        
        l_stage := 'put addendum message';
        create_addendums(
            i_fin_rec                => l_fin_rec
            , i_auth_rec             => i_auth_rec
            , i_collection_only      => l_fin_rec.is_collection_only
            , io_message_seq_number  => l_message_seq_number
        );

        l_stage := 'put';
        l_fin_rec.id := 
            put_message (
                i_fin_rec   => l_fin_rec
            );

        l_stage := 'done';
        
    else
        l_stage := 'init record';
        l_fin_rec.id              := i_id;
        l_fin_rec.status          := nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
        l_fin_rec.inst_id         := nvl(i_inst_id, i_auth_rec.acq_inst_id);
        l_fin_rec.network_id      := nvl(i_network_id, i_auth_rec.iss_network_id);
        l_fin_rec.is_invalid      := com_api_type_pkg.FALSE;
        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := i_auth_rec.is_reversal;
        l_fin_rec.is_collection_only := nvl(i_collection_only, com_api_type_pkg.FALSE);         
        l_terminal_type           := i_auth_rec.terminal_type;
        l_collection_only         := l_fin_rec.is_collection_only;
        
        -- get network communication standard
        l_stage := 'host';
        l_host_id                 := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
        l_standard_id             := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);

        trc_log_pkg.debug (
            i_text         => 'l_host_id [' || l_host_id || '], l_standard_id [' || l_standard_id || ']'
        );
        
        l_stage := 'mtid';
        if l_collection_only = com_api_type_pkg.FALSE then
        
            l_fin_rec.mtid        := amx_api_const_pkg.MTID_PRESENTMENT;
        else
            l_fin_rec.mtid        := amx_api_const_pkg.MTID_ONUS_MESSAGE;
        end if;
        l_fin_rec.func_code       := amx_api_const_pkg.FUNC_CODE_FIRST_PRES;

        l_stage := 'pan';
        l_fin_rec.card_number     := i_auth_rec.card_number;
        l_fin_rec.pan_length      := length(i_auth_rec.card_number);
        l_fin_rec.card_mask       := iss_api_card_pkg.get_card_mask(l_fin_rec.card_number);
        l_fin_rec.card_hash       := com_api_hash_pkg.get_card_hash(l_fin_rec.card_number);
        
        l_stage := 'proc_code';
        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
        
            l_fin_rec.proc_code := amx_api_const_pkg.PROC_CODE_ATM_ACQ_STTL; --'170808'
        else
            l_fin_rec.proc_code := assign_proc_code(
                                    i_oper_type   => i_auth_rec.oper_type
                                  , i_auth_mcc    => i_auth_rec.mcc
                                  , i_is_reversal => i_auth_rec.is_reversal 
                                );
        end if;                            
        trc_log_pkg.debug (
            i_text         => 'proc_code [' || l_fin_rec.proc_code || ']'
        );
        
        l_stage := 'pos_data_code read';
        l_pdc_1  := i_auth_rec.card_data_input_cap;
        l_pdc_2  := i_auth_rec.crdh_auth_cap;
        l_pdc_3  := i_auth_rec.card_capture_cap;
        l_pdc_4  := i_auth_rec.terminal_operating_env;
        l_pdc_5  := i_auth_rec.crdh_presence;
        l_pdc_6  := i_auth_rec.card_presence;
        l_pdc_7  := i_auth_rec.card_data_input_mode;
        l_pdc_8  := i_auth_rec.crdh_auth_method;
        l_pdc_9  := i_auth_rec.crdh_auth_entity;
        l_pdc_10 := i_auth_rec.card_data_output_cap;
        l_pdc_11 := i_auth_rec.terminal_output_cap;
        l_pdc_12 := i_auth_rec.pin_capture_cap;
                                    
        --Calculate ECI only for 1240 POS.
        l_stage := 'eci';
        if l_terminal_type != acq_api_const_pkg.TERMINAL_TYPE_ATM 
            and l_collection_only = com_api_type_pkg.FALSE
        then
            l_fin_rec.eci :=
                case 
                    when l_pdc_7 = 'F2270007' and l_pdc_8 = 'F2280000'
                        then '07'
                    when l_pdc_7 = 'F2270007' and l_pdc_8 in ('F2280009', 'F228000W', 'F228000X')
                        then '06'
                    when l_pdc_7 = 'F2270007' and l_pdc_8 = 'F228000S'
                        then '05'
                    else
                        ' '    
                end;
        end if;

        trc_log_pkg.debug (
            i_text         => 'eci [' || l_fin_rec.eci || ']'
        );
        
        l_stage := 'trans_amount';
        l_fin_rec.trans_amount    := i_auth_rec.oper_amount;
        l_fin_rec.trans_date      := i_auth_rec.oper_date;

        l_stage := 'card_expir_date';
        if l_collection_only = com_api_type_pkg.TRUE then
        
            l_fin_rec.card_expir_date := null;
        else
            l_fin_rec.card_expir_date := to_char(i_auth_rec.card_expir_date, 'mmyy');
        end if;    

        l_fin_rec.capture_date    := com_api_sttl_day_pkg.get_sysdate;
        l_fin_rec.mcc             := i_auth_rec.mcc;
        
        l_stage := 'pos_data_code';
        generate_pos_data_code;

        trc_log_pkg.debug (
            i_text         => 'pos_data_code: pdc_1 ['|| l_fin_rec.pdc_1 
                                       || '], pdc_2 ['|| l_fin_rec.pdc_2 
                                       || '], pdc_3 ['|| l_fin_rec.pdc_3 
                                       || '], pdc_4 ['|| l_fin_rec.pdc_4 
                                       || '], pdc_5 ['|| l_fin_rec.pdc_5 
                                       || '], pdc_6 ['|| l_fin_rec.pdc_6 
                                       || '], pdc_7 ['|| l_fin_rec.pdc_7 
                                       || '], pdc_8 ['|| l_fin_rec.pdc_8 
                                       || '], pdc_9 ['|| l_fin_rec.pdc_9 
                                       || '], pdc_10 ['|| l_fin_rec.pdc_10 
                                       || '], pdc_11 ['|| l_fin_rec.pdc_11 
                                       || '], pdc_12 ['|| l_fin_rec.pdc_12 || ']'
        );
                
        l_fin_rec.approval_code_length := length(i_auth_rec.auth_code);
        l_fin_rec.approval_code   := i_auth_rec.auth_code;
        
        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
        then
            l_fin_rec.iss_sttl_date   := trunc(i_auth_rec.network_cnvt_date);
        end if;
                
        if l_collection_only = com_api_type_pkg.TRUE then
        
            l_fin_rec.fp_trans_amount          := i_auth_rec.oper_amount;
            l_fin_rec.fp_trans_decimalization  := l_trans_decimalization;
            l_fin_rec.fp_trans_currency        := i_auth_rec.oper_currency;
        else
            l_fin_rec.fp_trans_amount := null;
        end if;    
                 
        l_stage := 'arn';
        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
        then
            l_cmid_name := amx_api_const_pkg.CMID_ACQUIRING;
        else
            l_cmid_name := amx_api_const_pkg.CMID_ACQUIRING_SINGLE;
        end if;  
          
        l_fin_rec.ain := 
            nvl(cmn_api_standard_pkg.get_varchar_value(
                 i_inst_id       => l_fin_rec.inst_id
               , i_standard_id   => l_standard_id
               , i_object_id     => l_host_id
               , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
               , i_param_name    => l_cmid_name 
               , i_param_tab     => l_param_tab
             )
             , amx_api_const_pkg.GLOBAL_INST_ID
        );

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM 
            and l_collection_only = com_api_type_pkg.FALSE
        then
            l_fin_rec.arn := i_auth_rec.terminal_number
                || substr(coalesce(i_auth_rec.system_trace_audit_number, i_auth_rec.network_refnum, i_auth_rec.originator_refnum), 1, 6);
        else    
            l_fin_rec.arn := 
                acq_api_merchant_pkg.get_arn(
                    i_acquirer_bin => l_fin_rec.ain
                );    
        end if;
        
        l_fin_rec.apn := 
            nvl(cmn_api_standard_pkg.get_varchar_value(
                 i_inst_id       => l_fin_rec.inst_id
               , i_standard_id   => l_standard_id
               , i_object_id     => l_host_id
               , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
               , i_param_name    => amx_api_const_pkg.CMID_ACQ_PROCESSOR 
               , i_param_tab     => l_param_tab
             )
             , amx_api_const_pkg.GLOBAL_INST_ID
        );

        trc_log_pkg.debug (
            i_text         => 'ain [' || l_fin_rec.ain || '], apn [' || l_fin_rec.apn || '], arn [' || l_fin_rec.arn || ']'
        );
        
        l_stage := 'merchant';
        l_fin_rec.terminal_number    := i_auth_rec.terminal_number;
        l_fin_rec.merchant_number    := coalesce( aup_api_tag_pkg.get_tag_value(i_auth_id => l_fin_rec.id, i_tag_id => aup_api_const_pkg.TAG_AMX_MERCH_ID)
                                                , get_merchant_amex(i_inst_id => l_fin_rec.inst_id, i_merchant_number => i_auth_rec.merchant_number)
                                                , i_auth_rec.merchant_number );
        l_fin_rec.merchant_name      := i_auth_rec.merchant_name;
        l_fin_rec.merchant_addr1     := substr(nvl(i_auth_rec.merchant_street, 'unknown'), 1, 38);
        l_fin_rec.merchant_city      := substr(i_auth_rec.merchant_city, 1, 21);
        l_fin_rec.merchant_postal_code := substr(nvl(i_auth_rec.merchant_postcode, 'unknown'), 1, 15);
        l_fin_rec.merchant_country   := i_auth_rec.merchant_country;
        l_fin_rec.merchant_region    := null; -- Region code is not supported
        l_fin_rec.matching_key_type  := null;
        l_fin_rec.matching_key       := null;
        
        l_stage := 'fp_amounts';
        l_trans_decimalization       := com_api_currency_pkg.get_currency_exponent(i_auth_rec.oper_currency);

        --Issuer Authorized Amount
        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM 
            and l_collection_only = com_api_type_pkg.FALSE
        then
            l_fin_rec.iss_net_sttl_amount     := i_auth_rec.oper_amount;
            l_fin_rec.iss_gross_sttl_amount   := i_auth_rec.oper_amount;
            l_fin_rec.iss_sttl_currency       := i_auth_rec.oper_currency;
            l_fin_rec.iss_sttl_decimalization := l_trans_decimalization;
            
        end if;    
        
        l_fin_rec.trans_decimalization    := l_trans_decimalization;
        l_fin_rec.fp_pres_amount          := i_auth_rec.oper_amount;
        l_fin_rec.fp_pres_conversion_rate := 1;
        l_fin_rec.fp_pres_currency        := i_auth_rec.oper_currency;
        l_fin_rec.fp_pres_decimalization  := l_trans_decimalization;
        
        l_fin_rec.merchant_multinational  := null;
        
        l_fin_rec.trans_currency          := i_auth_rec.oper_currency;

        l_stage := 'fp_trans_date';
        l_fin_rec.alt_merchant_number_length := null;
        l_fin_rec.alt_merchant_number        := null;
        
        if l_collection_only = com_api_type_pkg.TRUE then

            l_fin_rec.fp_trans_date       := i_auth_rec.oper_date;
            
        end if; 

        l_stage := 'icc_pin_indicator';
        if l_terminal_type != acq_api_const_pkg.TERMINAL_TYPE_ATM 
            and l_collection_only = com_api_type_pkg.TRUE
        then
            if l_pdc_7 in ('F227000C', 'F227000F', 'F227000M', 'F227000N', 'F227000R', 'F227000P', 'F227000A') then  -- chip or contactless A, P - ?
            
                if l_pdc_8 = 'F2280000' then
                    l_fin_rec.icc_pin_indicator := 'YN'; --chip only
                    
                elsif l_pdc_8 = 'F2280001' then
                    l_fin_rec.icc_pin_indicator := 'YY'; --chip and pin                    
                else
                    l_fin_rec.icc_pin_indicator := 'NN'; --not Chip or PIN
                end if;
            end if;    
        end if;

        trc_log_pkg.debug (
            i_text         => 'icc_pin_indicator [' || l_fin_rec.icc_pin_indicator || ']'
        );
            
        l_fin_rec.card_capability         := null;
        l_fin_rec.program_indicator       := null;
        l_fin_rec.tax_reason_code         := null;
        l_fin_rec.network_proc_date       := null;

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
        then
            l_stage := 'get merchant discount rate';
        
            acq_api_merchant_pkg.get_merchant(
                        i_inst_id       => l_fin_rec.inst_id
              , i_merchant_number => l_fin_rec.merchant_number
              , o_merchant_id     => l_merchant_id
              , o_split_hash      => l_merchant_split_hash
                );
            cmn_api_standard_pkg.get_prd_attr_value_number(
                        i_inst_id       => l_fin_rec.inst_id
              , i_host_id           => l_host_id
                      , i_standard_id   => l_standard_id
              , i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id         => l_merchant_id
              , i_param_name        => amx_api_const_pkg.MERCH_DISCOUNT_RATE
              , i_eff_date          => l_fin_rec.trans_date
                      , i_param_tab     => l_param_tab
              , i_mask_error        => com_api_const_pkg.TRUE
              , o_param_value       => l_merch_discount_fee_id
                );
                
            select min(ft.percent_rate) 
              into l_merchant_discount 
              from fcl_fee_tier ft
             where ft.fee_id = l_merch_discount_fee_id;

            if l_merchant_discount is not null then
                l_fin_rec.merchant_discount_rate := '0000000' || replace(to_char(l_merchant_discount, 'FM00.000000'), '.', '');
            end if;
        end if;

        l_stage := 'iin&ipn';
        l_fin_rec.iin := 
            nvl(cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id       => l_fin_rec.inst_id
                  , i_standard_id   => l_standard_id
                  , i_object_id     => l_host_id
                  , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name    => amx_api_const_pkg.CMID_ISSUING
                  , i_param_tab     => l_param_tab
                )
              , amx_api_const_pkg.GLOBAL_INST_ID
            );

        l_fin_rec.ipn := 
            nvl(cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id       => l_fin_rec.inst_id
                  , i_standard_id   => l_standard_id
                  , i_object_id     => l_host_id
                  , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name    => amx_api_const_pkg.CMID_ISS_PROCESSOR 
                  , i_param_tab     => l_param_tab
                )
              , amx_api_const_pkg.GLOBAL_INST_ID
            );
                
        trc_log_pkg.debug (
            i_text         => 'iin [' || l_fin_rec.iin || '], ipn [' || l_fin_rec.ipn || ']'
        );

        l_stage := 'media_code';
        if l_pdc_8 in ('F2280002', 'F2280005') then
            l_fin_rec.media_code := amx_api_const_pkg.MEDIA_CODE_SIGNATURE;   
                     
        elsif l_pdc_5 = 'F2250003' then
            l_fin_rec.media_code := amx_api_const_pkg.MEDIA_CODE_PHONE_ORDER;
            
        elsif l_pdc_5 = 'F2250002' then
            l_fin_rec.media_code := amx_api_const_pkg.MEDIA_CODE_MAIL_ORDER; 
               
        elsif l_pdc_5 = 'F2250005' then
            l_fin_rec.media_code := amx_api_const_pkg.MEDIA_CODE_ELECTRONIC_ORDER;  
              
        elsif i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then        
            l_fin_rec.media_code := amx_api_const_pkg.MEDIA_CODE_ATM;
            
        elsif i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS then        
            l_fin_rec.media_code := amx_api_const_pkg.MEDIA_CODE_POS;
            
        else 
            l_fin_rec.media_code := amx_api_const_pkg.MEDIA_CODE_IPOS;
        end if;

        trc_log_pkg.debug (
            i_text         => 'media_code [' || l_fin_rec.media_code || ']'
        );
        
        l_fin_rec.message_seq_number      := 1;
        l_fin_rec.merchant_location_text  := null;
        
        l_stage := 'transaction_id';
        l_fin_rec.transaction_id          := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);
        
        trc_log_pkg.debug (
            i_text         => 'transaction_id [' || l_fin_rec.transaction_id || ']'
        );

        if l_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM 
        then
            l_fin_rec.ext_payment_data        := null;
        else    
            l_fin_rec.ext_payment_data        := '01';        
        end if;
        
        l_fin_rec.invoice_number          := null;
        l_fin_rec.reject_reason_code      := null;

        l_stage := 'impact';
        l_fin_rec.impact := 
            amx_prc_incoming_pkg.get_message_impact(   
                i_mtid            => l_fin_rec.mtid
                , i_func_code     => l_fin_rec.func_code
                , i_proc_code     => l_fin_rec.proc_code
                , i_incoming      => l_fin_rec.is_incoming
                , i_raise_error   => com_api_type_pkg.TRUE
            );
            
        trc_log_pkg.debug (
            i_text         => 'impact [' || l_fin_rec.impact || ']'
        );

        l_stage := 'put addendum message';
        create_addendums(
            i_fin_rec              => l_fin_rec
          , i_auth_rec             => i_auth_rec
          , i_collection_only      => l_collection_only   
          , io_message_seq_number  => l_message_seq_number
        );

        l_fin_rec.format_code   := get_format_code(
            i_mcc                  => l_fin_rec.mcc
          , i_message_seq_number   => l_message_seq_number
		  , i_network_id           => null
        );    
        
        l_stage := 'custom';
        amx_cst_fin_message_pkg.process_auth(
            io_fin_rec             => l_fin_rec
            , i_auth_rec           => i_auth_rec
            , i_id                 => i_id
            , i_inst_id            => i_inst_id
            , i_network_id         => i_network_id
            , i_status             => i_status
            , i_collection_only    => i_collection_only
        );
        
        l_stage := 'put message';
        l_fin_rec.id := 
            put_message (
                i_fin_rec   => l_fin_rec
            );
    end if;

    trc_log_pkg.debug (
        i_text         => 'amx_api_fin_message_pkg.process_auth end'
    );
    
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating AMX presentment on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end;

function estimate_messages_for_upload (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_collection_only       in     com_api_type_pkg.t_boolean 
  , i_start_date            in     date                               default null
  , i_end_date              in     date                               default null
  , i_include_affiliate     in     com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_apn                   in     com_api_type_pkg.t_cmid            default null
) return number is
    l_result                number;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
begin
    if i_include_affiliate = com_api_const_pkg.TRUE then
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id => l_host_id
                         );

        select /*+ INDEX(f, amx_fin_message_CLMS0010_ndx)*/
              count(f.id)
         into l_result
         from amx_fin_message f
            , opr_operation o
            , (select distinct v.param_value cmid
                      from cmn_parameter p
                         , net_api_interface_param_val_vw v
                         , net_member m
                         , net_interface i
                     where p.name           = amx_api_const_pkg.CMID_ACQUIRING
                       and p.standard_id    = l_standard_id
                       and p.id             = v.param_id
                       and m.id             = v.consumer_member_id
                       and v.host_member_id = l_host_id
                       and m.id             = i.consumer_member_id
                       and v.interface_id   = i.id
                       and (i.msp_member_id in (select id
                                                  from net_member
                                                 where network_id = i_network_id
                                                   and inst_id    = i_inst_id
                                               )
                            or m.inst_id = i_inst_id
                           )
              ) cmid
        where decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
          and decode(f.status, 'CLMS0010', f.apn, null) = cmid.cmid
          and f.id = o.id
          and f.is_incoming = 0
          and f.network_id = i_network_id
          and f.is_collection_only = i_collection_only
          and (
               i_start_date is null and i_end_date is null
               or
               f.trans_date between nvl(i_start_date, trunc(f.trans_date)) and nvl(i_end_date, trunc(f.trans_date)) + 1 - com_api_const_pkg.ONE_SECOND
                   and f.is_reversal = com_api_const_pkg.FALSE
               or
               o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                   and f.is_reversal = com_api_const_pkg.TRUE
          );
    else
        select /*+ INDEX(f, amx_fin_message_CLMS0010_ndx)*/
              count(f.id)
         into l_result
         from amx_fin_message f
            , opr_operation o
        where decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
          and f.id = o.id
          and f.is_incoming = 0
          and f.network_id = i_network_id
          and f.inst_id = i_inst_id
          and f.is_collection_only = i_collection_only
          and (
               i_start_date is null and i_end_date is null
               or
               f.trans_date between nvl(i_start_date, trunc(f.trans_date)) and nvl(i_end_date, trunc(f.trans_date)) + 1 - com_api_const_pkg.ONE_SECOND
                   and f.is_reversal = com_api_const_pkg.FALSE
               or
               o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                   and f.is_reversal = com_api_const_pkg.TRUE
              )
          and (
               i_apn is null
            or i_apn = f.apn
            or exists (select 1
                        from amx_fin_message m
                       where m.dispute_id = f.dispute_id
                         and m.apn = i_apn)
          );
    end if;

    return l_result;
end estimate_messages_for_upload;

procedure enum_messages_for_upload (
    o_fin_cur                  out sys_refcursor
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_collection_only       in     com_api_type_pkg.t_boolean 
  , i_start_date            in     date                               default null
  , i_end_date              in     date                               default null
  , i_include_affiliate     in     com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_apn                   in     com_api_type_pkg.t_cmid            default null
) is
    l_stmt                  com_api_type_pkg.t_text;
    DATE_PLACEHOLDER        constant com_api_type_pkg.t_name := '##DATE##';
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
begin
    if i_include_affiliate = com_api_const_pkg.TRUE then

        l_host_id     := net_api_network_pkg.get_default_host(
                             i_network_id => i_network_id
                         );
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id    => l_host_id
                         );

        l_stmt := '
select /*+ INDEX(f, amx_fin_message_CLMS0010_ndx)*/
    ' || g_column_list || '
from amx_fin_message f
   , amx_card c
   , opr_operation o
   , (select distinct v.param_value cmid
             from cmn_parameter p
                , net_api_interface_param_val_vw v
                , net_member m
                , net_interface i
            where p.name           = :l_param_name
              and p.standard_id    = :l_standard_id
              and p.id             = v.param_id
              and m.id             = v.consumer_member_id
              and v.host_member_id = :l_host_id
              and m.id             = i.consumer_member_id
              and v.interface_id   = i.id
              and (i.msp_member_id in (select id
                                         from net_member
                                        where network_id = :i_network_id
                                          and inst_id    = :i_inst_id
                                      )
                   or m.inst_id = :i_inst_id
                  )
     ) cmid
where
    decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
             || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
    || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
    and decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', f.apn, null) = cmid.cmid
    and f.id = o.id
    and f.is_incoming = :is_incoming
    and f.network_id = :i_network_id
    and f.is_collection_only = :i_collection_only
    and c.id(+) = f.id ' || DATE_PLACEHOLDER || '
  order by
      f.mtid
    , f.id';

        l_stmt := replace (
            l_stmt
          , DATE_PLACEHOLDER
          , case
                when i_start_date is not null or i_end_date is not null then '
                    and (f.trans_date between nvl(:i_start_date, trunc(f.trans_date)) and nvl(:i_end_date, trunc(f.trans_date)) + 1 - 1/86400
                    and f.is_reversal = ' || com_api_type_pkg.FALSE || '
                    or
                    o.host_date between nvl(:i_start_date, trunc(o.host_date)) and nvl(:i_end_date, trunc(o.host_date)) + 1 - 1/86400
                    and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
                else
                    ' '
            end
        );

        if i_start_date is not null or i_end_date is not null then
            open o_fin_cur for l_stmt
            using amx_api_const_pkg.CMID_ACQUIRING
                , l_standard_id
                , l_host_id
                , i_network_id
                , i_inst_id
                , i_inst_id
                , com_api_type_pkg.FALSE
                , i_network_id
                , i_collection_only
                , i_start_date
                , i_end_date
                , i_start_date
                , i_end_date;
        else
            open o_fin_cur for l_stmt
            using amx_api_const_pkg.CMID_ACQUIRING
                , l_standard_id
                , l_host_id
                , i_network_id
                , i_inst_id
                , i_inst_id
                , com_api_type_pkg.FALSE
                , i_network_id
                , i_collection_only;
        end if;
    else
        l_stmt := '
select /*+ INDEX(f, amx_fin_message_CLMS0010_ndx)*/
    ' || g_column_list || '
from amx_fin_message f
   , amx_card c
   , opr_operation o
where
    decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
             || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
    || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
    and f.id = o.id
    and f.is_incoming = :is_incoming
    and f.network_id = :i_network_id
    and f.inst_id = :i_inst_id
    and f.is_collection_only = :i_collection_only
    and ( f.apn = nvl(:i_apn, f.apn)
       or exists (select 1
                   from amx_fin_message m
                  where m.dispute_id = f.dispute_id
                    and m.apn = :i_apn) )
    and c.id(+) = f.id ' || DATE_PLACEHOLDER || '
  order by
      f.mtid
    , f.id';

        l_stmt := replace (
            l_stmt
          , DATE_PLACEHOLDER
          , case
                when i_start_date is not null or i_end_date is not null then '
                    and (f.trans_date between nvl(:i_start_date, trunc(f.trans_date)) and nvl(:i_end_date, trunc(f.trans_date)) + 1 - 1/86400
                    and f.is_reversal = ' || com_api_type_pkg.FALSE || '
                    or
                    o.host_date between nvl(:i_start_date, trunc(o.host_date)) and nvl(:i_end_date, trunc(o.host_date)) + 1 - 1/86400
                    and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
                else
                    ' '
            end
        );

        if i_start_date is not null or i_end_date is not null then
            open o_fin_cur for l_stmt
            using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_collection_only, i_apn, i_apn, i_start_date, i_end_date, i_start_date, i_end_date;
        else
            open o_fin_cur for l_stmt
            using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_collection_only, i_apn, i_apn;
        end if;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT)  || '.enum_messages_for_upload >> FAILED with l_stmt:'
                   || chr(13) || chr(10)   || l_stmt
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
end enum_messages_for_upload;

procedure check_dispute_status(
    i_id                    in     com_api_type_pkg.t_long_id
) is
    l_status    com_api_type_pkg.t_dict_value;
begin
    if i_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'NO_DISPUTE_FOUND'
        );
    end if;
        
    select status
      into l_status
      from amx_fin_message
     where id = i_id;
         
    if l_status != net_api_const_pkg.CLEARING_MSG_STATUS_READY then
        com_api_error_pkg.raise_error(
            i_error         => 'FIN_MSG_ALREADY_SEND'
          , i_env_param1    => i_id
        );
    end if;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'NO_DISPUTE_FOUND'
        );
end;

function is_amex (
    i_id                    in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result com_api_type_pkg.t_boolean;
begin
    select count(1)
      into l_result
      from amx_fin_message
     where id = i_id
       and rownum <= 1;

    return l_result;
end;

function is_editable(
    i_id                    in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
begin
    for tab in (
        select id from amx_fin_message
         where id = i_id
           and is_incoming = com_api_const_pkg.FALSE
           and status = net_api_const_pkg.CLEARING_MSG_STATUS_READY)
    loop
        return com_api_const_pkg.TRUE;
    end loop;
    return com_api_const_pkg.FALSE;
end;

procedure remove_message(
    i_id                    in     com_api_type_pkg.t_long_id
) is
begin
    delete 
      from amx_fin_message
     where id = i_id;

    delete 
      from dsp_fin_message
     where id = i_id;
     
    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'Remove mcw message: [#1] is not found'
          , i_env_param1 => i_id
        );
    else
        opr_api_operation_pkg.remove_operation(
            i_oper_id => i_id
        );
    end if;
end;

procedure put_atm_rcn_message(
    i_atm_rcn_rec           in     amx_api_type_pkg.t_amx_atm_rcn_rec
)
is    
    l_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text         => 'amx_api_fin_message_pkg.put_atm_rcn_message start'
    );

    l_id := nvl(i_atm_rcn_rec.id, opr_api_create_pkg.get_id);
    
    insert into amx_atm_rcn_fin(
         id
       , status
       , is_invalid
       , file_id
       , inst_id
       , record_type
       , msg_seq_number
       , trans_date
       , system_date
       , sttl_date
       , terminal_number
       , system_trace_audit_number
       , dispensed_currency
       , amount_requested
       , amount_ind
       , sttl_rate
       , sttl_currency
       , sttl_amount_requested
       , sttl_amount_approved
       , sttl_amount_dispensed
       , sttl_network_fee
       , sttl_other_fee
       , terminal_country_code
       , merchant_country_code
       , card_billing_country_code
       , terminal_location
       , auth_status
       , trans_indicator
       , orig_action_code
       , approval_code
       , add_ref_number
       , trans_id
    )
    values(
        l_id
      , i_atm_rcn_rec.status
      , i_atm_rcn_rec.is_invalid
      , i_atm_rcn_rec.file_id
      , i_atm_rcn_rec.inst_id
      , i_atm_rcn_rec.record_type
      , i_atm_rcn_rec.msg_seq_number
      , i_atm_rcn_rec.trans_date
      , i_atm_rcn_rec.system_date
      , i_atm_rcn_rec.sttl_date
      , i_atm_rcn_rec.terminal_number
      , i_atm_rcn_rec.system_trace_audit_number
      , i_atm_rcn_rec.dispensed_currency
      , i_atm_rcn_rec.amount_requested
      , i_atm_rcn_rec.amount_ind
      , i_atm_rcn_rec.sttl_rate
      , i_atm_rcn_rec.sttl_currency
      , i_atm_rcn_rec.sttl_amount_requested
      , i_atm_rcn_rec.sttl_amount_approved
      , i_atm_rcn_rec.sttl_amount_dispensed
      , i_atm_rcn_rec.sttl_network_fee
      , i_atm_rcn_rec.sttl_other_fee
      , i_atm_rcn_rec.terminal_country_code
      , i_atm_rcn_rec.merchant_country_code
      , i_atm_rcn_rec.card_billing_country_code
      , i_atm_rcn_rec.terminal_location
      , i_atm_rcn_rec.auth_status
      , i_atm_rcn_rec.trans_indicator
      , i_atm_rcn_rec.orig_action_code
      , i_atm_rcn_rec.approval_code
      , i_atm_rcn_rec.add_ref_number
      , i_atm_rcn_rec.trans_id
    );

    insert into amx_card(
        id
      , card_number
    )
    values(
        l_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_atm_rcn_rec.card_number)
    );
    
    trc_log_pkg.debug(
        i_text        => 'put_atm_rcn_message: ATM rcn record added [#1]'
      , i_env_param1  => l_id
    );
end;

procedure create_addendums (
    i_fin_rec                 in     amx_api_type_pkg.t_amx_fin_mes_rec
    , i_auth_rec              in     aut_api_type_pkg.t_auth_rec
    , i_collection_only       in     com_api_type_pkg.t_boolean
    , io_message_seq_number   in out com_api_type_pkg.t_tiny_id
)is
    l_pdc_1                   com_api_type_pkg.t_dict_value;
    l_pdc_7                   com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text => 'Create addendums start'
    );

    l_pdc_1  := i_auth_rec.card_data_input_cap;
    l_pdc_7  := i_auth_rec.card_data_input_mode;

    --chip addenda
    if  l_pdc_1 in ('F2210005', 'F221000C', 'F221000D', 'F221000E', 'F221000M')
        and
        l_pdc_7 in ('F227000C', 'F227000F', 'F227000M', 'F227000N', 'F227000R', 'F227000P', 'F227000A')  -- chip or contactless A, P - ?
        and
        i_collection_only = com_api_type_pkg.FALSE
    then
        io_message_seq_number := case io_message_seq_number
                                     when 0 then 2
                                     else 3
                                 end;

        amx_api_add_pkg.create_outgoing_addenda (
            i_fin_rec              => i_fin_rec
            , i_auth_rec           => i_auth_rec
            , i_addenda_type       => amx_api_const_pkg.ADDENDA_TYPE_CHIP
            , i_collection_only    => i_collection_only
            , i_message_seq_number => io_message_seq_number
        );
    end if;

    trc_log_pkg.debug(
        i_text => 'Create addendums end'
    );
end;

end;
/

