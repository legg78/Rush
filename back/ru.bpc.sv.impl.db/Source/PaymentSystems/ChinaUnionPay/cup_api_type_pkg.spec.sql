create or replace package cup_api_type_pkg as

    type            t_cup_file_rec is record (
        id                      com_api_type_pkg.t_long_id
        , is_incoming           com_api_type_pkg.t_boolean
        , is_rejected           com_api_type_pkg.t_boolean
        , network_id            com_api_type_pkg.t_tiny_id
        , trans_date            date
        , inst_id               com_api_type_pkg.t_inst_id
        , inst_name             com_api_type_pkg.t_name 
        , action_code           com_api_type_pkg.t_boolean     
        , file_number           com_api_type_pkg.t_tiny_id    
        , pack_no               com_api_type_pkg.t_postal_code    
        , version               com_api_type_pkg.t_postal_code    
        , crc                   com_api_type_pkg.t_money
        , encoding              com_api_type_pkg.t_auth_code
        , file_type             com_api_type_pkg.t_postal_code
        , session_file_id       com_api_type_pkg.t_long_id
    );
    type            t_cup_file_cur is ref cursor return t_cup_file_rec;
    type            t_cup_file_tab is table of t_cup_file_rec index by binary_integer;
    
    type            t_cup_fin_mes_rec is record (
        row_id                         rowid
        , id                           com_api_type_pkg.t_long_id
        , status                       com_api_type_pkg.t_dict_value
        , is_reversal                  com_api_type_pkg.t_boolean
        , is_incoming                  com_api_type_pkg.t_boolean
        , is_rejected                  com_api_type_pkg.t_boolean
        , is_invalid                   com_api_type_pkg.t_boolean
        , inst_id                      com_api_type_pkg.t_inst_id
        , network_id                   com_api_type_pkg.t_tiny_id
        , host_inst_id                 com_api_type_pkg.t_inst_id
        , rrn                          com_api_type_pkg.t_name
        , merchant_number              com_api_type_pkg.t_name
        , acquirer_iin                 com_api_type_pkg.t_name
        , trans_amount                 com_api_type_pkg.t_money
        , app_version_no               com_api_type_pkg.t_name
        , appl_charact                 com_api_type_pkg.t_name
        , appl_crypt                   com_api_type_pkg.t_name
        , auth_amount                  com_api_type_pkg.t_money
        , auth_method                  com_api_type_pkg.t_name
        , auth_resp_code               com_api_type_pkg.t_name
        , terminal_capab               com_api_type_pkg.t_name
        , card_serial_num              com_api_type_pkg.t_medium_id
        , cipher_text_inf_data         com_api_type_pkg.t_name
        , auth_currency                com_api_type_pkg.t_medium_id
        , terminal_country             com_api_type_pkg.t_name
        , dedic_doc_name               com_api_type_pkg.t_name
        , ic_card_cond_code            com_api_type_pkg.t_name
        , interface_serial             com_api_type_pkg.t_name
        , iss_bank_app_data            com_api_type_pkg.t_name
        , local                        com_api_type_pkg.t_boolean
        , mcc                          com_api_type_pkg.t_medium_id
        , merchant_name                com_api_type_pkg.t_name
        , other_amount                 com_api_type_pkg.t_money
        , card_number                  com_api_type_pkg.t_name
        , point                        com_api_type_pkg.t_name
        , proc_func_code               com_api_type_pkg.t_name
        , terminal_entry_capab         com_api_type_pkg.t_name
        , terminal_verif_result        com_api_type_pkg.t_name
        , script_result_of_card_issuer com_api_type_pkg.t_name
        , forwarding_iin               com_api_type_pkg.t_name
        , pos_entry_mode               com_api_type_pkg.t_medium_id
        , sys_trace_num                com_api_type_pkg.t_long_id
        , terminal_category            com_api_type_pkg.t_name
        , terminal_number              com_api_type_pkg.t_name
        , trans_currency               com_api_type_pkg.t_name
        , trans_init_channel           com_api_type_pkg.t_medium_id
        , trans_category               com_api_type_pkg.t_medium_id
        , trans_counter                com_api_type_pkg.t_name
        , trans_date                   com_api_type_pkg.t_name
        , trans_resp_code              com_api_type_pkg.t_name
        , trans_serial_counter         com_api_type_pkg.t_name
        , trans_code                   com_api_type_pkg.t_tiny_id
        , transmission_date_time       timestamp(6)
        , unpred_num                   com_api_type_pkg.t_name
        , collect_only_flag            com_api_type_pkg.t_byte_char
        , original_id                  com_api_type_pkg.t_long_id
        , merchant_country             com_api_type_pkg.t_country_code
        , pos_cond_code                com_api_type_pkg.t_tag
        , terminal_auth_date           timestamp(6)
        , orig_trans_code              com_api_type_pkg.t_tiny_id
        , orig_transmission_date_time  date
        , orig_sys_trace_num           com_api_type_pkg.t_long_id
        , orig_trans_date              date
        , file_id                      com_api_type_pkg.t_long_id
        , reason_code                  com_api_type_pkg.t_name
        , double_message_id            com_api_type_pkg.t_boolean
        , cups_ref_num                 com_api_type_pkg.t_name
        , receiving_iin                com_api_type_pkg.t_name
        , issuer_iin                   com_api_type_pkg.t_name
        , cups_notice                  com_api_type_pkg.t_medium_id
        , trans_features_id            com_api_type_pkg.t_name
        , payment_service_type         com_api_type_pkg.t_name
        , settlement_exch_rate         com_api_type_pkg.t_long_id
        , cardholder_bill_amount       com_api_type_pkg.t_money
        , cardholder_acc_currency      com_api_type_pkg.t_name
        , cardholder_exch_rate         com_api_type_pkg.t_long_id
        , service_fee_amount           com_api_type_pkg.t_name
        , sttl_amount                  com_api_type_pkg.t_money
        , sttl_currency                com_api_type_pkg.t_curr_code
        , message_type                 com_api_type_pkg.t_tiny_id
        , receivable_fee               com_api_type_pkg.t_medium_id
        , payable_fee                  com_api_type_pkg.t_medium_id
        , interchange_fee              com_api_type_pkg.t_cmid
        , transaction_fee              com_api_type_pkg.t_cmid
        , reserved                     com_api_type_pkg.t_name
        , dispute_id                   com_api_type_pkg.t_long_id
        , b2b_business_type            com_api_type_pkg.t_byte_char
        , b2b_payment_medium           com_api_type_pkg.t_one_char
        , qrc_voucher_number           varchar2(20)
        , payment_facilitator_id       com_api_type_pkg.t_dict_value
    );
    type            t_cup_fin_mes_tab is table of t_cup_fin_mes_rec index by binary_integer;
    type            t_cup_fin_cur is ref cursor return t_cup_fin_mes_rec;

    type            t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;

    type            t_cup_fee_rec is record (
        id                             com_api_type_pkg.t_long_id
        , fee_type                     com_api_type_pkg.t_curr_code
        , acquirer_iin                 com_api_type_pkg.t_name
        , forwarding_iin               com_api_type_pkg.t_name
        , sys_trace_num                com_api_type_pkg.t_auth_code
        , transmission_date_time       timestamp(6)
        , card_number                  com_api_type_pkg.t_card_number
        , merchant_number              com_api_type_pkg.t_name
        , auth_resp_code               com_api_type_pkg.t_name
        , is_reversal                  com_api_type_pkg.t_boolean
        , trans_type_id                com_api_type_pkg.t_sign
        , receiving_iin                com_api_type_pkg.t_name
        , issuer_iin                   com_api_type_pkg.t_name
        , sttl_currency                com_api_type_pkg.t_curr_code
        , sttl_sign                    com_api_type_pkg.t_sign
        , sttl_amount                  com_api_type_pkg.t_money
        , interchange_fee_sign         com_api_type_pkg.t_sign
        , interchange_fee_amount       com_api_type_pkg.t_money
        , reimbursement_fee_sign       com_api_type_pkg.t_sign
        , reimbursement_fee_amount     com_api_type_pkg.t_money
        , service_fee_sign             com_api_type_pkg.t_sign
        , service_fee_amount           com_api_type_pkg.t_money
        , file_id                      com_api_type_pkg.t_long_id
        , fin_msg_id                   com_api_type_pkg.t_long_id
        , match_status                 com_api_type_pkg.t_dict_value
        , inst_id                      com_api_type_pkg.t_inst_id
        , reason_code                  com_api_type_pkg.t_tiny_id
        , sender_iin_level1            com_api_type_pkg.t_region_code
        , sender_iin_level2            com_api_type_pkg.t_region_code
        , receiving_iin_level2         com_api_type_pkg.t_region_code
    );
    type            t_cup_fee_cur is ref cursor return t_cup_fee_rec;
    type            t_cup_fee_tab is table of t_cup_fee_rec index by binary_integer;

    type            t_cup_audit_rec is record (
        id                           com_api_type_pkg.t_long_id
        , acquirer_iin               com_api_type_pkg.t_region_code
        , forwarding_iin             com_api_type_pkg.t_region_code
        , sys_trace_num              com_api_type_pkg.t_auth_code
        , transmission_date_time     timestamp(6)
        , card_number                com_api_type_pkg.t_card_number
        , trans_amount               com_api_type_pkg.t_money
        , message_type               com_api_type_pkg.t_mcc
        , proc_func_code             com_api_type_pkg.t_auth_code
        , mcc                        com_api_type_pkg.t_mcc
        , terminal_number            com_api_type_pkg.t_terminal_number
        , merchant_number            com_api_type_pkg.t_merchant_number
        , merchant_name              com_api_type_pkg.t_name
        , rrn                        com_api_type_pkg.t_rrn
        , pos_cond_code              com_api_type_pkg.t_byte_char
        , auth_resp_code             com_api_type_pkg.t_auth_code
        , receiving_iin              com_api_type_pkg.t_region_code
        , orig_sys_trace_num         com_api_type_pkg.t_auth_code
        , trans_resp_code            com_api_type_pkg.t_byte_char
        , trans_currency             com_api_type_pkg.t_curr_code
        , pos_entry_mode             com_api_type_pkg.t_module_code
        , sttl_currency              com_api_type_pkg.t_curr_code
        , sttl_amount                com_api_type_pkg.t_money
        , sttl_exch_rate             com_api_type_pkg.t_dict_value
        , sttl_date                  date
        , exchange_date              date
        , cardholder_acc_currency    com_api_type_pkg.t_curr_code
        , cardholder_bill_amount     com_api_type_pkg.t_money
        , cardholder_exch_rate       com_api_type_pkg.t_dict_value
        , receivable_fee             com_api_type_pkg.t_money
        , payable_fee                com_api_type_pkg.t_money
        , billing_currency           com_api_type_pkg.t_curr_code
        , billing_exch_rate          com_api_type_pkg.t_dict_value
        , file_id                    com_api_type_pkg.t_long_id
        , inst_id                    com_api_type_pkg.t_inst_id
        , match_status               com_api_type_pkg.t_dict_value
        , fin_msg_id                 com_api_type_pkg.t_long_id
        , reserved                   com_api_type_pkg.t_name
        , interchange_fee            com_api_type_pkg.t_auth_amount
        , interchange_currency       com_api_type_pkg.t_curr_code
        , interchange_exch_rate      com_api_type_pkg.t_dict_value
        , transaction_fee            com_api_type_pkg.t_auth_amount
    );
    type            t_cup_audit_cur is ref cursor return t_cup_audit_rec;
    type            t_cup_audit_tab is table of t_cup_audit_rec index by binary_integer;

end;
/
