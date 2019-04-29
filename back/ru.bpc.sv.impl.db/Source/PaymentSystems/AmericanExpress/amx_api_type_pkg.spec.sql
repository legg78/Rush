create or replace package amx_api_type_pkg is

    type t_amx_file_rec is record (
        id                              com_api_type_pkg.t_long_id
      , is_incoming                     com_api_type_pkg.t_boolean   
      , is_rejected                     com_api_type_pkg.t_boolean       
      , network_id                      com_api_type_pkg.t_tiny_id        
      , transmittal_date                date    
      , inst_id                         com_api_type_pkg.t_inst_id       
      , forw_inst_code                  com_api_type_pkg.t_cmid       
      , receiv_inst_code                com_api_type_pkg.t_cmid       
      , action_code                     com_api_type_pkg.t_curr_code         
      , file_number                     com_api_type_pkg.t_auth_code     
      , reject_code                     com_api_type_pkg.t_original_data     
      , msg_total                       com_api_type_pkg.t_short_id    
      , credit_count                    com_api_type_pkg.t_short_id 
      , debit_count                     com_api_type_pkg.t_short_id
      , credit_amount                   com_api_type_pkg.t_money    
      , debit_amount                    com_api_type_pkg.t_money    
      , total_amount                    com_api_type_pkg.t_money         
      , receipt_file_id                 com_api_type_pkg.t_long_id   
      , reject_msg_id                   com_api_type_pkg.t_long_id
      , session_file_id                 com_api_type_pkg.t_long_id
      , hash_total_amount               com_api_type_pkg.t_money
      , func_code                       com_api_type_pkg.t_curr_code
      , org_identifier                  com_api_type_pkg.t_cmid
    );
    type t_amx_file_cur is ref cursor return t_amx_file_rec;
    type t_amx_file_tab is table of t_amx_file_rec index by binary_integer;

    type t_amx_fin_mes_rec is record (
        id                              com_api_type_pkg.t_long_id  
      , split_hash                      com_api_type_pkg.t_short_id
      , status                          com_api_type_pkg.t_dict_value
      , inst_id                         com_api_type_pkg.t_inst_id   
      , network_id                      com_api_type_pkg.t_tiny_id   
      , file_id                         com_api_type_pkg.t_long_id  
      , is_invalid                      com_api_type_pkg.t_boolean
      , is_incoming                     com_api_type_pkg.t_boolean
      , is_reversal                     com_api_type_pkg.t_boolean
      , is_collection_only              com_api_type_pkg.t_boolean
      , is_rejected                     com_api_type_pkg.t_boolean
      , reject_id                       com_api_type_pkg.t_long_id
      , dispute_id                      com_api_type_pkg.t_long_id
      , impact                          com_api_type_pkg.t_sign
      , mtid                            com_api_type_pkg.t_mcc
      , func_code                       com_api_type_pkg.t_curr_code
      , pan_length                      com_api_type_pkg.t_byte_char
      , card_mask                       com_api_type_pkg.t_card_number
      , card_number                     com_api_type_pkg.t_card_number
      , card_hash                       com_api_type_pkg.t_medium_id
      , proc_code                       com_api_type_pkg.t_auth_code
      , trans_amount                    com_api_type_pkg.t_money
      , trans_date                      date
      , card_expir_date                 com_api_type_pkg.t_mcc
      , capture_date                    date
      , mcc                             com_api_type_pkg.t_mcc
      , pdc_1                           com_api_type_pkg.t_one_char
      , pdc_2                           com_api_type_pkg.t_one_char
      , pdc_3                           com_api_type_pkg.t_one_char
      , pdc_4                           com_api_type_pkg.t_one_char
      , pdc_5                           com_api_type_pkg.t_one_char
      , pdc_6                           com_api_type_pkg.t_one_char
      , pdc_7                           com_api_type_pkg.t_one_char
      , pdc_8                           com_api_type_pkg.t_one_char
      , pdc_9                           com_api_type_pkg.t_one_char
      , pdc_10                          com_api_type_pkg.t_one_char
      , pdc_11                          com_api_type_pkg.t_one_char
      , pdc_12                          com_api_type_pkg.t_one_char
      , reason_code                     com_api_type_pkg.t_mcc
      , approval_code_length            com_api_type_pkg.t_sign
      , iss_sttl_date                   date
      , eci                             com_api_type_pkg.t_byte_char
      , fp_trans_amount                 com_api_type_pkg.t_money
      , ain                             com_api_type_pkg.t_cmid
      , apn                             com_api_type_pkg.t_cmid
      , arn                             com_api_type_pkg.t_auth_amount
      , approval_code                   com_api_type_pkg.t_auth_code
      , terminal_number                 com_api_type_pkg.t_dict_value
      , merchant_number                 com_api_type_pkg.t_merchant_number
      , merchant_name                   com_api_type_pkg.t_original_data
      , merchant_addr1                  com_api_type_pkg.t_original_data
      , merchant_addr2                  com_api_type_pkg.t_original_data
      , merchant_city                   com_api_type_pkg.t_arn 
      , merchant_postal_code            com_api_type_pkg.t_merchant_number
      , merchant_country                com_api_type_pkg.t_curr_code
      , merchant_region                 com_api_type_pkg.t_curr_code
      , iss_gross_sttl_amount           com_api_type_pkg.t_money
      , iss_rate_amount                 com_api_type_pkg.t_money
      , matching_key_type               com_api_type_pkg.t_byte_char
      , matching_key                    com_api_type_pkg.t_arn 
      , iss_net_sttl_amount             com_api_type_pkg.t_money
      , iss_sttl_currency               com_api_type_pkg.t_curr_code
      , iss_sttl_decimalization         com_api_type_pkg.t_sign
      , fp_trans_currency               com_api_type_pkg.t_curr_code
      , trans_decimalization            com_api_type_pkg.t_sign
      , fp_trans_decimalization         com_api_type_pkg.t_sign
      , fp_pres_amount                  com_api_type_pkg.t_money
      , fp_pres_conversion_rate         com_api_type_pkg.t_money
      , fp_pres_currency                com_api_type_pkg.t_curr_code
      , fp_pres_decimalization          com_api_type_pkg.t_sign
      , merchant_multinational          com_api_type_pkg.t_one_char
      , trans_currency                  com_api_type_pkg.t_curr_code
      , add_acc_eff_type1               com_api_type_pkg.t_one_char
      , add_amount1                     com_api_type_pkg.t_money
      , add_amount_type1                com_api_type_pkg.t_curr_code
      , add_acc_eff_type2               com_api_type_pkg.t_one_char
      , add_amount2                     com_api_type_pkg.t_money
      , add_amount_type2                com_api_type_pkg.t_curr_code
      , add_acc_eff_type3               com_api_type_pkg.t_one_char
      , add_amount3                     com_api_type_pkg.t_money
      , add_amount_type3                com_api_type_pkg.t_curr_code
      , add_acc_eff_type4               com_api_type_pkg.t_one_char
      , add_amount4                     com_api_type_pkg.t_money
      , add_amount_type4                com_api_type_pkg.t_curr_code
      , add_acc_eff_type5               com_api_type_pkg.t_one_char
      , add_amount5                     com_api_type_pkg.t_money
      , add_amount_type5                com_api_type_pkg.t_curr_code
      , alt_merchant_number_length      com_api_type_pkg.t_byte_char
      , alt_merchant_number             com_api_type_pkg.t_merchant_number
      , fp_trans_date                   date
      , icc_pin_indicator               com_api_type_pkg.t_byte_char
      , card_capability                 com_api_type_pkg.t_one_char
      , network_proc_date               date
      , program_indicator               com_api_type_pkg.t_byte_char
      , tax_reason_code                 com_api_type_pkg.t_byte_char
      , fp_network_proc_date            date
      , format_code                     com_api_type_pkg.t_byte_char
      , iin                             com_api_type_pkg.t_cmid
      , media_code                      com_api_type_pkg.t_byte_char
      , message_seq_number              com_api_type_pkg.t_byte_id
      , merchant_location_text          com_api_type_pkg.t_original_data
      , itemized_doc_code               com_api_type_pkg.t_byte_char
      , itemized_doc_ref_number         com_api_type_pkg.t_arn
      , transaction_id                  com_api_type_pkg.t_merchant_number
      , ext_payment_data                com_api_type_pkg.t_byte_char
      , message_number                  com_api_type_pkg.t_short_id
      , ipn                             com_api_type_pkg.t_cmid
      , invoice_number                  com_api_type_pkg.t_attr_name
      , reject_reason_code              com_api_type_pkg.t_original_data
      , chbck_reason_text               com_api_type_pkg.t_name
      , chbck_reason_code               com_api_type_pkg.t_mcc
      , valid_bill_unit_code            com_api_type_pkg.t_curr_code
      , sttl_date                       date
      , forw_inst_code                  com_api_type_pkg.t_cmid
      , fee_reason_text                 com_api_type_pkg.t_name
      , fee_type_code                   com_api_type_pkg.t_byte_char
      , receiving_inst_code             com_api_type_pkg.t_cmid
      , send_inst_code                  com_api_type_pkg.t_cmid
      , send_proc_code                  com_api_type_pkg.t_cmid
      , receiving_proc_code             com_api_type_pkg.t_cmid
      , merchant_discount_rate          com_api_type_pkg.t_merchant_number
    );
    type t_amx_fin_mes_tab is table of t_amx_fin_mes_rec index by binary_integer;
    type t_amx_fin_cur is ref cursor return t_amx_fin_mes_rec;

    type t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;    

    type t_amx_add_rec is record (
        id                              com_api_type_pkg.t_long_id
      , fin_id                          com_api_type_pkg.t_long_id
      , file_id                         com_api_type_pkg.t_long_id
      , is_incoming                     com_api_type_pkg.t_boolean
      , mtid                            com_api_type_pkg.t_mcc
      , addenda_type                    com_api_type_pkg.t_byte_char
      , format_code                     com_api_type_pkg.t_byte_char
      , message_seq_number              com_api_type_pkg.t_byte_id
      , transaction_id                  com_api_type_pkg.t_merchant_number
      , message_number                  com_api_type_pkg.t_short_id
      , reject_reason_code              com_api_type_pkg.t_original_data
      , reject_id                       com_api_type_pkg.t_long_id
    );
    type t_amx_add_cur is ref cursor return t_amx_add_rec;
    type t_amx_add_tab is table of t_amx_add_rec index by binary_integer;

    type t_amx_add_chip_rec is record (
        id                              com_api_type_pkg.t_long_id
      , fin_id                          com_api_type_pkg.t_long_id
      , file_id                         com_api_type_pkg.t_long_id
      , icc_data                        com_api_type_pkg.t_full_desc
      , icc_version_name                com_api_type_pkg.t_dict_value
      , icc_version_number              com_api_type_pkg.t_mcc
      , emv_9f26                        com_api_type_pkg.t_terminal_number
      , emv_9f10                        com_api_type_pkg.t_name
      , emv_9f37                        com_api_type_pkg.t_dict_value
      , emv_9f36                        com_api_type_pkg.t_mcc
      , emv_95                          com_api_type_pkg.t_postal_code
      , emv_9a                          date
      , emv_9c                          com_api_type_pkg.t_byte_id
      , emv_9f02                        com_api_type_pkg.t_medium_id
      , emv_5f2a                        com_api_type_pkg.t_tiny_id
      , emv_9f1a                        com_api_type_pkg.t_tiny_id
      , emv_82                          com_api_type_pkg.t_mcc
      , emv_9f03                        com_api_type_pkg.t_medium_id
      , emv_5f34                        com_api_type_pkg.t_byte_id
      , emv_9f27                        com_api_type_pkg.t_byte_char        
      , message_seq_number              com_api_type_pkg.t_byte_id
      , transaction_id                  com_api_type_pkg.t_merchant_number
      , message_number                  com_api_type_pkg.t_short_id
    );
    type t_amx_add_chip_cur is ref cursor return t_amx_add_chip_rec;
    type t_amx_add_chip_tab is table of t_amx_add_chip_rec index by binary_integer;

    type t_merchant_rec is record(
        message_number                  com_api_type_pkg.t_short_id
      , function_code                   com_api_type_pkg.t_byte_id
      , se_id_code                      com_api_type_pkg.t_merchant_number
      , se_name                         com_api_type_pkg.t_name
      , se_street                       com_api_type_pkg.t_name
      , se_house                        com_api_type_pkg.t_name
      , se_apartment                    com_api_type_pkg.t_name
      , se_city                         com_api_type_pkg.t_name
      , se_postal_code                  com_api_type_pkg.t_postal_code
      , se_region                       com_api_type_pkg.t_country_code
      , se_country                      com_api_type_pkg.t_country_code
      , active_eff_date                 date
      , cancel_eff_date                 date
      , status_reason_code              com_api_type_pkg.t_byte_char
      , se_mcc                          com_api_type_pkg.t_mcc
      , se_full_recourse_status         com_api_type_pkg.t_one_char
      , se_high_risk_indicator          com_api_type_pkg.t_one_char
      , phone_number                    com_api_type_pkg.t_attr_name
    );

    type t_merchant_tab is table of t_merchant_rec index by binary_integer;

    type t_amx_atm_rcn_rec is record (
        id                              com_api_type_pkg.t_long_id
      , status                          com_api_type_pkg.t_dict_value
      , is_invalid                      com_api_type_pkg.t_boolean
      , file_id                         com_api_type_pkg.t_long_id
      , inst_id                         com_api_type_pkg.t_inst_id
      , record_type                     com_api_type_pkg.t_one_char
      , msg_seq_number                  com_api_type_pkg.t_tag
      , trans_date                      date
      , system_date                     date
      , sttl_date                       date
      , terminal_number                 com_api_type_pkg.t_dict_value
      , system_trace_audit_number       com_api_type_pkg.t_tag
      , dispensed_currency              com_api_type_pkg.t_curr_code
      , amount_requested                com_api_type_pkg.t_auth_long_id
      , amount_ind                      com_api_type_pkg.t_auth_long_id
      , sttl_rate                       com_api_type_pkg.t_auth_medium_id
      , sttl_currency                   com_api_type_pkg.t_curr_code
      , sttl_amount_requested           com_api_type_pkg.t_auth_long_id
      , sttl_amount_approved            com_api_type_pkg.t_auth_long_id
      , sttl_amount_dispensed           com_api_type_pkg.t_auth_long_id
      , sttl_network_fee                com_api_type_pkg.t_region_code
      , sttl_other_fee                  com_api_type_pkg.t_region_code
      , terminal_country_code           com_api_type_pkg.t_byte_char
      , merchant_country_code           com_api_type_pkg.t_byte_char
      , card_billing_country_code       com_api_type_pkg.t_byte_char
      , terminal_location               com_api_type_pkg.t_original_data
      , auth_status                     com_api_type_pkg.t_one_char
      , trans_indicator                 com_api_type_pkg.t_one_char
      , orig_action_code                com_api_type_pkg.t_module_code
      , approval_code                   com_api_type_pkg.t_tag
      , add_ref_number                  com_api_type_pkg.t_dict_value
      , trans_id                        com_api_type_pkg.t_auth_long_id
      , card_number                     com_api_type_pkg.t_card_number
    );

end amx_api_type_pkg;
/

