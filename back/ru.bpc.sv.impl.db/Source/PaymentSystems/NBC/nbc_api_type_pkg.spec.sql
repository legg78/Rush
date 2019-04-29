create or replace package nbc_api_type_pkg as

    type            t_nbc_file_rec is record (
        id                     com_api_type_pkg.t_long_id
        , file_type            com_api_type_pkg.t_byte_char
        , is_incoming          com_api_type_pkg.t_boolean
        , inst_id              com_api_type_pkg.t_inst_id
        , network_id           com_api_type_pkg.t_tiny_id
        , bin_number           com_api_type_pkg.t_port
        , sttl_date            date
        , proc_date            date
        , file_number          com_api_type_pkg.t_byte_id
        , participant_type     com_api_type_pkg.t_curr_code
        , session_file_id      com_api_type_pkg.t_long_id
        , records_total        com_api_type_pkg.t_long_id        
        , md5                  com_api_type_pkg.t_md5
    );

    type            t_nbc_fin_mes_rec is record (
        id                     com_api_type_pkg.t_long_id
        , split_hash           com_api_type_pkg.t_tiny_id
        , status               com_api_type_pkg.t_dict_value
        , mti                  com_api_type_pkg.t_mcc
        , file_id              com_api_type_pkg.t_long_id
        , record_number        com_api_type_pkg.t_short_id
        , is_reversal          com_api_type_pkg.t_boolean
        , is_incoming          com_api_type_pkg.t_boolean
        , is_invalid           com_api_type_pkg.t_boolean
        , original_id          com_api_type_pkg.t_long_id
        , dispute_id           com_api_type_pkg.t_long_id
        , inst_id              com_api_type_pkg.t_inst_id
        , network_id           com_api_type_pkg.t_tiny_id
        , msg_file_type        com_api_type_pkg.t_byte_char
        , participant_type     com_api_type_pkg.t_curr_code
        , record_type          com_api_type_pkg.t_mcc
        , card_mask            com_api_type_pkg.t_card_number
        , card_hash            com_api_type_pkg.t_medium_id
        , proc_code            com_api_type_pkg.t_auth_code
        , nbc_resp_code        com_api_type_pkg.t_byte_char
        , acq_resp_code        com_api_type_pkg.t_byte_char
        , iss_resp_code        com_api_type_pkg.t_byte_char
        , bnb_resp_code        com_api_type_pkg.t_byte_char
        , dispute_trans_result com_api_type_pkg.t_byte_char      
        , trans_amount         com_api_type_pkg.t_money
        , sttl_amount          com_api_type_pkg.t_money
        , crdh_bill_amount     com_api_type_pkg.t_money
        , crdh_bill_fee        com_api_type_pkg.t_money
        , settl_rate           com_api_type_pkg.t_money
        , crdh_bill_rate       com_api_type_pkg.t_money
        , system_trace_number  com_api_type_pkg.t_auth_code
        , local_trans_time     com_api_type_pkg.t_auth_code
        , local_trans_date     date
        , settlement_date      date
        , merchant_type        com_api_type_pkg.t_mcc
        , trans_fee_amount     com_api_type_pkg.t_money
        , acq_inst_code        com_api_type_pkg.t_port
        , iss_inst_code        com_api_type_pkg.t_port
        , bnb_inst_code        com_api_type_pkg.t_port
        , rrn                  com_api_type_pkg.t_cmid
        , auth_number          com_api_type_pkg.t_auth_code
        , resp_code            com_api_type_pkg.t_byte_char      
        , terminal_id          com_api_type_pkg.t_dict_value
        , trans_currency       com_api_type_pkg.t_curr_code
        , settl_currency       com_api_type_pkg.t_curr_code
        , crdh_bill_currency   com_api_type_pkg.t_curr_code
        , from_account_id      com_api_type_pkg.t_attr_name
        , to_account_id        com_api_type_pkg.t_attr_name
        , nbc_fee              com_api_type_pkg.t_money
        , acq_fee              com_api_type_pkg.t_money
        , iss_fee              com_api_type_pkg.t_money
        , bnb_fee              com_api_type_pkg.t_money
        , card_number          com_api_type_pkg.t_card_number
        , add_party_type       com_api_type_pkg.t_curr_code
    );
    type            t_nbc_fin_mes_tab is table of t_nbc_fin_mes_rec index by binary_integer;
    type            t_nbc_fin_cur is ref cursor return t_nbc_fin_mes_rec;
    
    type            t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;    
end;
/
