create or replace package cst_tie_api_type_pkg authid definer is

-- Purpose : KONTS Financial message types

subtype t_clearing_data is varchar2(4000);

type t_mes_file_header_rec is record(
    FormatVersion            varchar2(11)
  , FileOriginator           varchar2(11)
  , FileDestination          varchar2(11)
  , FileId                   varchar2(32)
  , FileDateTime             date
  , FileInfoType             number(11)
  , OrigFileId               varchar2(32)
);

type t_mes_fin_rec is record(
    AccntTypeFrom            varchar2(2)
  , Pan                      number(19)
--...
);

type t_file_row_buffer is table of varchar2(4000);

type t_file_rec is record(
    id                  com_api_type_pkg.t_long_id
  , is_incoming         number(1)
  , network_id          number(4)
  , file_name           varchar2(32)
  , file_version        varchar2(4)
  , ext_file_id         number(16)
  , inst_id             number(4)
  , records_count       number(8)
  , session_file_id     number(16)
  , file_date_time      date
  -- for bulk messages update
  , rowid_tab           com_api_type_pkg.t_rowid_tab
  , id_tab              com_api_type_pkg.t_number_tab
  -- for bulk file generation
  , raw_data            com_api_type_pkg.t_raw_tab
  , record_number       com_api_type_pkg.t_integer_tab
);

--- table types
subtype t_accnt_type_from               is cst_tie_fin.accnt_type_from               %type;
subtype t_accnt_type_to                 is cst_tie_fin.accnt_type_to                 %type;
subtype t_appr_code                     is cst_tie_fin.appr_code                     %type;
subtype t_acq_id                        is cst_tie_fin.acq_id                        %type;
subtype t_arn                           is cst_tie_fin.arn                           %type;
subtype t_batch_nr                      is cst_tie_fin.batch_nr                      %type;
subtype t_bill_amnt                     is cst_tie_fin.bill_amnt                     %type;
subtype t_bill_ccy                      is cst_tie_fin.bill_ccy                      %type;
subtype t_business_application_id       is cst_tie_fin.business_application_id       %type;
subtype t_card_capture_cap              is cst_tie_fin.card_capture_cap              %type;
subtype t_card_data_input_cap           is cst_tie_fin.card_data_input_cap           %type;
subtype t_card_data_input_mode          is cst_tie_fin.card_data_input_mode          %type;
subtype t_card_data_output_cap          is cst_tie_fin.card_data_output_cap          %type;
subtype t_card_presence                 is cst_tie_fin.card_presence                 %type;
subtype t_card_seq_nr                   is cst_tie_fin.card_seq_nr                   %type;
subtype t_cashback_amnt                 is cst_tie_fin.cashback_amnt                 %type;
subtype t_cat_level                     is cst_tie_fin.cat_level                     %type;
subtype t_chb_ref_data                  is cst_tie_fin.chb_ref_data                  %type;
subtype t_crdh_auth_cap                 is cst_tie_fin.crdh_auth_cap                 %type;
subtype t_crdh_auth_entity              is cst_tie_fin.crdh_auth_entity              %type;
subtype t_crdh_auth_method              is cst_tie_fin.crdh_auth_method              %type;
subtype t_crdh_presence                 is cst_tie_fin.crdh_presence                 %type;
subtype t_cvv2_result                   is cst_tie_fin.cvv2_result                   %type;
subtype t_card_exp_date                 is cst_tie_fin.card_exp_date                 %type;
subtype t_doc_ind                       is cst_tie_fin.doc_ind                       %type;
subtype t_ecomm_sec_level               is cst_tie_fin.ecomm_sec_level               %type;
subtype t_fwd_inst_id                   is cst_tie_fin.fwd_inst_id                   %type;
subtype t_mcc                           is cst_tie_fin.mcc                           %type;
subtype t_merchant_id                   is cst_tie_fin.merchant_id                   %type;
subtype t_merchant_name                 is cst_tie_fin.merchant_name                 %type;
subtype t_merchant_addr                 is cst_tie_fin.merchant_addr                 %type;
subtype t_merchant_country              is cst_tie_fin.merchant_country              %type;
subtype t_merchant_city                 is cst_tie_fin.merchant_city                 %type;
subtype t_merchant_postal_code          is cst_tie_fin.merchant_postal_code          %type;
subtype t_msg_funct_code                is cst_tie_fin.msg_funct_code                %type;
subtype t_msg_reason_code               is cst_tie_fin.msg_reason_code               %type;
subtype t_mti                           is cst_tie_fin.mti                           %type;
subtype t_oper_env                      is cst_tie_fin.oper_env                      %type;
subtype t_orig_reason_code              is cst_tie_fin.orig_reason_code              %type;
subtype t_pan                           is cst_tie_card.card_number                  %type;
subtype t_pin_capture_cap               is cst_tie_fin.pin_capture_cap               %type;
subtype t_proc_date                     is cst_tie_fin.proc_date                     %type;
subtype t_receiver_an                   is cst_tie_fin.receiver_an                   %type;
subtype t_receiver_an_type_id           is cst_tie_fin.receiver_an_type_id           %type;
subtype t_receiver_inst_code            is cst_tie_fin.receiver_inst_code            %type;
subtype t_resp_code                     is cst_tie_fin.resp_code                     %type;
subtype t_rrn                           is cst_tie_fin.rrn                           %type;
subtype t_sender_rn                     is cst_tie_fin.sender_rn                     %type;
subtype t_sender_an                     is cst_tie_fin.sender_an                     %type;
subtype t_sender_an_type_id             is cst_tie_fin.sender_an_type_id             %type;
subtype t_sender_name                   is cst_tie_fin.sender_name                   %type;
subtype t_sender_addr                   is cst_tie_fin.sender_addr                   %type;
subtype t_sender_city                   is cst_tie_fin.sender_city                   %type;
subtype t_sender_inst_code              is cst_tie_fin.sender_inst_code              %type;
subtype t_sender_state                  is cst_tie_fin.sender_state                  %type;
subtype t_sender_country                is cst_tie_fin.sender_country                %type;
subtype t_settl_amnt                    is cst_tie_fin.settl_amnt                    %type;
subtype t_settl_ccy                     is cst_tie_fin.settl_ccy                     %type;
subtype t_settl_date                    is cst_tie_fin.settl_date                    %type;
subtype t_stan                          is cst_tie_fin.stan                          %type;
subtype t_card_svc_code                 is cst_tie_fin.card_svc_code                 %type;
subtype t_term_data_output_cap          is cst_tie_fin.term_data_output_cap          %type;
subtype t_term_id                       is cst_tie_fin.term_id                       %type;
subtype t_tran_amnt                     is cst_tie_fin.tran_amnt                     %type;
subtype t_tran_ccy                      is cst_tie_fin.tran_ccy                      %type;
subtype t_tran_date_time                is cst_tie_fin.tran_date_time                %type;
subtype t_tran_originator               is cst_tie_fin.tran_originator               %type;
subtype t_tran_destination              is cst_tie_fin.tran_destination              %type;
subtype t_tran_type                     is cst_tie_fin.tran_type                     %type;
subtype t_tid                           is cst_tie_fin.tid                           %type;
subtype t_tid_originator                is cst_tie_fin.tid_originator                %type;
subtype t_multiple_clearing_rec         is cst_tie_fin.multiple_clearing_rec         %type;
subtype t_validation_code               is cst_tie_fin.validation_code               %type;
subtype t_wallet_id                     is cst_tie_fin.wallet_id                     %type;
subtype t_ptti                          is cst_tie_fin.ptti                          %type;
subtype t_payment_facilitator_id        is cst_tie_fin.payment_facilitator_id        %type;
subtype t_independent_sales_org_id      is cst_tie_fin.independent_sales_org_id      %type;
subtype t_additional_merchant_info      is cst_tie_fin.additional_merchant_info      %type;
subtype t_emv5f2a                       is cst_tie_fin.emv5f2a                       %type;
subtype t_emv5f34                       is cst_tie_fin.emv5f34                       %type;
subtype t_emv71                         is cst_tie_fin.emv71                         %type;
subtype t_emv72                         is cst_tie_fin.emv72                         %type;
subtype t_emv82                         is cst_tie_fin.emv82                         %type;
subtype t_emv84                         is cst_tie_fin.emv84                         %type;
subtype t_emv91                         is cst_tie_fin.emv91                         %type;
subtype t_emv95                         is cst_tie_fin.emv95                         %type;
subtype t_emv9a                         is cst_tie_fin.emv9a                         %type;
subtype t_emv9c                         is cst_tie_fin.emv9c                         %type;
subtype t_emv9f02                       is cst_tie_fin.emv9f02                       %type;
subtype t_emv9f03                       is cst_tie_fin.emv9f03                       %type;
subtype t_emv9f09                       is cst_tie_fin.emv9f09                       %type;
subtype t_emv9f10                       is cst_tie_fin.emv9f10                       %type;
subtype t_emv9f1a                       is cst_tie_fin.emv9f1a                       %type;
subtype t_emv9f1e                       is cst_tie_fin.emv9f1e                       %type;
subtype t_emv9f26                       is cst_tie_fin.emv9f26                       %type;
subtype t_emv9f27                       is cst_tie_fin.emv9f27                       %type;
subtype t_emv9f33                       is cst_tie_fin.emv9f33                       %type;
subtype t_emv9f34                       is cst_tie_fin.emv9f34                       %type;
subtype t_emv9f35                       is cst_tie_fin.emv9f35                       %type;
subtype t_emv9f36                       is cst_tie_fin.emv9f36                       %type;
subtype t_emv9f37                       is cst_tie_fin.emv9f37                       %type;
subtype t_emv9f41                       is cst_tie_fin.emv9f41                       %type;
subtype t_emv9f53                       is cst_tie_fin.emv9f53                       %type;
subtype t_emv9f6e                       is cst_tie_fin.emv9f6e                       %type;
subtype t_msg_nr                        is cst_tie_fin.msg_nr                        %type;
subtype t_payment_narrative             is cst_tie_fin.payment_narrative             %type;

type t_fin_rec is record(
    row_id                rowid
  , id                    com_api_type_pkg.t_long_id
  , status                com_api_type_pkg.t_dict_value
  , inst_id               com_api_type_pkg.t_inst_id
  , network_id            com_api_type_pkg.t_tiny_id
  , file_id               com_api_type_pkg.t_long_id
  , is_incoming           com_api_type_pkg.t_boolean
  , is_reversal           com_api_type_pkg.t_boolean
  , is_invalid            com_api_type_pkg.t_boolean
  , is_rejected           com_api_type_pkg.t_boolean
  , dispute_id            com_api_type_pkg.t_long_id
  , impact                com_api_type_pkg.t_sign
  ---
  , accnt_type_from               t_accnt_type_from               
  , accnt_type_to                 t_accnt_type_to                 
  , appr_code                     t_appr_code                     
  , acq_id                        t_acq_id                        
  , arn                           t_arn                           
  , batch_nr                      t_batch_nr                      
  , bill_amnt                     t_bill_amnt                     
  , bill_ccy                      t_bill_ccy                      
  , business_application_id       t_business_application_id       
  , card_capture_cap              t_card_capture_cap              
  , card_data_input_cap           t_card_data_input_cap           
  , card_data_input_mode          t_card_data_input_mode          
  , card_data_output_cap          t_card_data_output_cap          
  , card_presence                 t_card_presence                 
  , card_seq_nr                   t_card_seq_nr                   
  , cashback_amnt                 t_cashback_amnt                 
  , cat_level                     t_cat_level                     
  , chb_ref_data                  t_chb_ref_data                  
  , crdh_auth_cap                 t_crdh_auth_cap                 
  , crdh_auth_entity              t_crdh_auth_entity              
  , crdh_auth_method              t_crdh_auth_method              
  , crdh_presence                 t_crdh_presence                 
  , cvv2_result                   t_cvv2_result                   
  , card_exp_date                 t_card_exp_date                 
  , doc_ind                       t_doc_ind                       
  , ecomm_sec_level               t_ecomm_sec_level               
  , fwd_inst_id                   t_fwd_inst_id                   
  , mcc                           t_mcc                           
  , merchant_id                   t_merchant_id                   
  , merchant_name                 t_merchant_name                 
  , merchant_addr                 t_merchant_addr                 
  , merchant_country              t_merchant_country              
  , merchant_city                 t_merchant_city                 
  , merchant_postal_code          t_merchant_postal_code          
  , msg_funct_code                t_msg_funct_code                
  , msg_reason_code               t_msg_reason_code               
  , mti                           t_mti                           
  , oper_env                      t_oper_env                      
  , orig_reason_code              t_orig_reason_code              
  , pan                           t_pan                           
  , pin_capture_cap               t_pin_capture_cap               
  , proc_date                     t_proc_date                     
  , receiver_an                   t_receiver_an                   
  , receiver_an_type_id           t_receiver_an_type_id           
  , receiver_inst_code            t_receiver_inst_code            
  , resp_code                     t_resp_code                     
  , rrn                           t_rrn                           
  , sender_rn                     t_sender_rn                     
  , sender_an                     t_sender_an                     
  , sender_an_type_id             t_sender_an_type_id             
  , sender_name                   t_sender_name                   
  , sender_addr                   t_sender_addr                   
  , sender_city                   t_sender_city                   
  , sender_inst_code              t_sender_inst_code              
  , sender_state                  t_sender_state                  
  , sender_country                t_sender_country                
  , settl_amnt                    t_settl_amnt                    
  , settl_ccy                     t_settl_ccy                     
  , settl_date                    t_settl_date                    
  , stan                          t_stan                          
  , card_svc_code                 t_card_svc_code                 
  , term_data_output_cap          t_term_data_output_cap          
  , term_id                       t_term_id                       
  , tran_amnt                     t_tran_amnt                     
  , tran_ccy                      t_tran_ccy                      
  , tran_date_time                t_tran_date_time                
  , tran_originator               t_tran_originator               
  , tran_destination              t_tran_destination              
  , tran_type                     t_tran_type                     
  , tid                           t_tid                           
  , tid_originator                t_tid_originator                
  , multiple_clearing_rec         t_multiple_clearing_rec         
  , validation_code               t_validation_code               
  , wallet_id                     t_wallet_id                     
  , ptti                          t_ptti                          
  , payment_facilitator_id        t_payment_facilitator_id        
  , independent_sales_org_id      t_independent_sales_org_id      
  , additional_merchant_info      t_additional_merchant_info      
  , emv5f2a                       t_emv5f2a                       
  , emv5f34                       t_emv5f34                       
  , emv71                         t_emv71                         
  , emv72                         t_emv72                         
  , emv82                         t_emv82                         
  , emv84                         t_emv84                         
  , emv91                         t_emv91                         
  , emv95                         t_emv95                         
  , emv9a                         t_emv9a                         
  , emv9c                         t_emv9c                         
  , emv9f02                       t_emv9f02                       
  , emv9f03                       t_emv9f03                       
  , emv9f09                       t_emv9f09                       
  , emv9f10                       t_emv9f10                       
  , emv9f1a                       t_emv9f1a                       
  , emv9f1e                       t_emv9f1e                       
  , emv9f26                       t_emv9f26                       
  , emv9f27                       t_emv9f27                       
  , emv9f33                       t_emv9f33                       
  , emv9f34                       t_emv9f34                       
  , emv9f35                       t_emv9f35                       
  , emv9f36                       t_emv9f36                       
  , emv9f37                       t_emv9f37                       
  , emv9f41                       t_emv9f41                       
  , emv9f53                       t_emv9f53                       
  , emv9f6e                       t_emv9f6e                       
  , msg_nr                        t_msg_nr                        
  , payment_narrative             t_payment_narrative             
);

type t_fin_cur is ref cursor return t_fin_rec;
type t_fin_tab is table of t_fin_rec;

end cst_tie_api_type_pkg;
/
