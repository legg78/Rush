create or replace force view amx_ui_fin_vw as
select 
    n.id                        
    , n.split_hash              
    , n.status  
    , get_article_text(
           i_article => n.status
         , i_lang    => l.lang
       ) as status_desc
    , n.inst_id    
    , get_text(
           i_table_name  => 'ost_institution'
         , i_column_name => 'name'
         , i_object_id   => n.inst_id
         , i_lang        => l.lang
       ) as inst_name                 
    , n.network_id 
    , get_text(
           i_table_name  => 'net_network'
         , i_column_name => 'name'
         , i_object_id   => n.network_id
         , i_lang        => l.lang
       ) as network_name
    , n.file_id                 
    , n.is_invalid              
    , n.is_incoming             
    , n.is_reversal             
    , n.is_collection_only      
    , n.is_rejected             
    , n.reject_id               
    , n.dispute_id                  
    , n.impact                  
    , n.mtid                    
    , n.func_code               
    , n.pan_length                               
    , n.card_hash     
    , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
    , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as card_mask
    , n.proc_code               
    , n.trans_amount            
    , n.trans_date              
    , n.card_expir_date         
    , n.capture_date            
    , n.mcc                     
    , n.pdc_1                   
    , n.pdc_2                   
    , n.pdc_3                   
    , n.pdc_4                   
    , n.pdc_5                   
    , n.pdc_6                   
    , n.pdc_7                   
    , n.pdc_8                   
    , n.pdc_9                   
    , n.pdc_10                  
    , n.pdc_11                  
    , n.pdc_12                  
    , n.reason_code             
    , n.approval_code_length    
    , n.iss_sttl_date           
    , n.eci                     
    , n.fp_trans_amount         
    , n.ain                     
    , n.apn                     
    , n.arn                     
    , n.approval_code           
    , n.terminal_number         
    , n.merchant_number         
    , n.merchant_name           
    , n.merchant_addr1          
    , n.merchant_addr2          
    , n.merchant_city           
    , n.merchant_postal_code    
    , n.merchant_country        
    , n.merchant_region         
    , n.iss_gross_sttl_amount   
    , n.iss_rate_amount         
    , n.matching_key_type       
    , n.matching_key            
    , n.iss_net_sttl_amount     
    , n.iss_sttl_currency       
    , n.iss_sttl_decimalization 
    , n.fp_trans_currency       
    , n.trans_decimalization    
    , n.fp_trans_decimalization 
    , n.fp_pres_amount          
    , n.fp_pres_conversion_rate 
    , n.fp_pres_currency        
    , n.fp_pres_decimalization  
    , n.merchant_multinational  
    , n.trans_currency          
    , n.add_acc_eff_type1       
    , n.add_amount1             
    , n.add_amount_type1        
    , n.add_acc_eff_type2       
    , n.add_amount2             
    , n.add_amount_type2        
    , n.add_acc_eff_type3       
    , n.add_amount3             
    , n.add_amount_type3        
    , n.add_acc_eff_type4       
    , n.add_amount4             
    , n.add_amount_type4        
    , n.add_acc_eff_type5       
    , n.add_amount5             
    , n.add_amount_type5        
    , n.alt_merchant_number_length
    , n.alt_merchant_number       
    , n.fp_trans_date             
    , n.icc_pin_indicator         
    , n.card_capability           
    , n.network_proc_date         
    , n.program_indicator         
    , n.tax_reason_code           
    , n.fp_network_proc_date      
    , n.format_code               
    , n.iin                       
    , n.media_code                
    , n.message_seq_number        
    , n.merchant_location_text    
    , n.itemized_doc_code         
    , n.itemized_doc_ref_number   
    , n.transaction_id            
    , n.ext_payment_data          
    , n.message_number            
    , n.ipn                       
    , n.invoice_number            
    , n.reject_reason_code        
    , n.chbck_reason_text         
    , n.chbck_reason_code             
    , n.valid_bill_unit_code      
    , n.sttl_date                 
    , n.forw_inst_code            
    , n.fee_reason_text           
    , n.fee_type_code              
    , n.receiving_inst_code       
    , n.send_inst_code            
    , n.send_proc_code            
    , n.receiving_proc_code       
    , n.merchant_discount_rate
    , l.lang
  from amx_fin_message n
     , amx_card c
     , com_language_vw l
 where n.id = c.id(+)
/
