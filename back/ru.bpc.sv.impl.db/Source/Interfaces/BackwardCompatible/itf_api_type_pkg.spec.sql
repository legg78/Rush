create or replace package itf_api_type_pkg as

    type t_file_header is record (
        record_type         com_api_type_pkg.t_tag     
        , record_number     com_api_type_pkg.t_medium_id
        , file_id           com_api_type_pkg.t_rate
        , file_type         com_api_type_pkg.t_dict_value
        , file_dt           date
        , inst_id           com_api_type_pkg.t_cmid
        , agent_inst_id     com_api_type_pkg.t_cmid
        , fe_sett_dt        date
        , bo_sett_dt        date
        , bo_sett_day       com_api_type_pkg.t_short_id
        , fh_length         com_api_type_pkg.t_tiny_id
    );

    type t_ocp_batch_rec is record (
        record_type         com_api_type_pkg.t_tag     
        , record_number     com_api_type_pkg.t_medium_id
        , account_number    com_api_type_pkg.t_account_number
        , bo_account_type   com_api_type_pkg.t_dict_value
        , amount            com_api_type_pkg.t_medium_id
        , dc_indicator      com_api_type_pkg.t_byte_char
        , currency_code     com_api_type_pkg.t_curr_code
        , effect_date       date
        , trans_id          com_api_type_pkg.t_long_id
        , bo_trans_type     com_api_type_pkg.t_dict_value
        , user_id           com_api_type_pkg.t_module_code
        , cor_account       com_api_type_pkg.t_account_number
        , fe_trans_type     com_api_type_pkg.t_dict_value
        , customs_office    com_api_type_pkg.t_name
        , customs_address   com_api_type_pkg.t_name
        , trans_date        date
        , card_number       com_api_type_pkg.t_card_number
        , receipt_number    com_api_type_pkg.t_mcc
        , approval_code     com_api_type_pkg.t_tag
        , payer_inn         com_api_type_pkg.t_cmid
        , payer_kpp         com_api_type_pkg.t_postal_code
        , payer_okpo        com_api_type_pkg.t_postal_code
        , declarant_inn     com_api_type_pkg.t_cmid
        , declarant_kpp     com_api_type_pkg.t_postal_code
        , declarant_okpo    com_api_type_pkg.t_postal_code
        , customs_code      com_api_type_pkg.t_postal_code
        , pay_doc_type      com_api_type_pkg.t_postal_code
        , pay_doc_id        com_api_type_pkg.t_postal_code
        , pay_doc_date      com_api_type_pkg.t_postal_code
        , pay_kind          com_api_type_pkg.t_mcc
        , cbc               com_api_type_pkg.t_semaphore_name
        , pay_status        com_api_type_pkg.t_byte_char
        , receiver_kpp      com_api_type_pkg.t_postal_code
        , receiver_okato    com_api_type_pkg.t_cmid
        , pay_type          com_api_type_pkg.t_postal_code
        , pay_details       com_api_type_pkg.t_param_value
        , r_length          com_api_type_pkg.t_tiny_id
    );

    type t_ibi_batch_rec is record (
        record_type         com_api_type_pkg.t_tag     
        , record_number     com_api_type_pkg.t_medium_id
        , account_number    com_api_type_pkg.t_account_number
        , account_type      com_api_type_pkg.t_dict_value
        , amount            com_api_type_pkg.t_long_id
        , dc_indicator      com_api_type_pkg.t_byte_char
        , currency_code     com_api_type_pkg.t_curr_code
        , pay_date          date
        , effect_date       date
        , trans_type        com_api_type_pkg.t_dict_value
        , user_id           com_api_type_pkg.t_module_code
        , pay_id            com_api_type_pkg.t_long_id
        , trans_decr        com_api_type_pkg.t_original_data
        , acc_stat_new      com_api_type_pkg.t_dict_value
        , acc_stat_prev     com_api_type_pkg.t_dict_value
        , acc_stat_chan_res com_api_type_pkg.t_dict_value
        , change_date       date
        , r_length          com_api_type_pkg.t_tiny_id
    );

    type t_r_ibi_batch_rec is record (
        record_type             com_api_type_pkg.t_tag     
        , record_number         com_api_type_pkg.t_medium_id
        , file_id               com_api_type_pkg.t_rate
        , rejected_mess_number  com_api_type_pkg.t_medium_id
        , reject_reason         com_api_type_pkg.t_dict_value
        , reason_descr          com_api_type_pkg.t_name
        , pay_id                com_api_type_pkg.t_long_id
        , r_length              com_api_type_pkg.t_tiny_id
    );

    type t_file_trailer is record (
        record_type         com_api_type_pkg.t_tag     
        , record_number     com_api_type_pkg.t_medium_id
        , last_record_flag  com_api_type_pkg.t_byte_char
        , crc               com_api_type_pkg.t_dict_value
        , ft_length         com_api_type_pkg.t_tiny_id
    );
    type t_buffer is table of com_api_type_pkg.t_raw_data index by binary_integer;


    type tag_value_rec is record
    (   
        tag                 com_api_type_pkg.t_postal_code
        , value             com_api_type_pkg.t_param_value 
        , parent_id         integer
        , applique          integer
    );
    type tag_value_tab is table of tag_value_rec index by binary_integer; 
    
    type t_auth_rec is record (
        event_object_id              com_api_type_pkg.t_long_id
        , auth_id                    com_api_type_pkg.t_long_id
        , resp_code                  com_api_type_pkg.t_dict_value
        , proc_type                  com_api_type_pkg.t_dict_value
        , auth_proc_mode             com_api_type_pkg.t_dict_value            
        , is_advice                  com_api_type_pkg.t_boolean
        , is_repeat                  com_api_type_pkg.t_boolean
        , bin_amount                 com_api_type_pkg.t_money
        , bin_currency               com_api_type_pkg.t_curr_code
        , bin_cnvt_rate              com_api_type_pkg.t_money
        , network_amount             com_api_type_pkg.t_money
        , network_currency           com_api_type_pkg.t_curr_code
        , network_cnvt_date          date
        , network_cnvt_rate          com_api_type_pkg.t_money
        , account_cnvt_rate          com_api_type_pkg.t_money
        , parent_id                  com_api_type_pkg.t_long_id
        , addr_verif_result          com_api_type_pkg.t_dict_value
        , iss_network_device_id      com_api_type_pkg.t_short_id
        , acq_device_id              com_api_type_pkg.t_short_id
        , acq_resp_code              com_api_type_pkg.t_dict_value
        , acq_device_proc_result     com_api_type_pkg.t_dict_value
        , cat_level                  com_api_type_pkg.t_dict_value
        , card_data_input_cap        com_api_type_pkg.t_dict_value
        , crdh_auth_cap              com_api_type_pkg.t_dict_value
        , card_capture_cap           com_api_type_pkg.t_dict_value
        , terminal_operating_env     com_api_type_pkg.t_dict_value
        , crdh_presence              com_api_type_pkg.t_dict_value
        , card_presence              com_api_type_pkg.t_dict_value
        , card_data_input_mode       com_api_type_pkg.t_dict_value
        , crdh_auth_method           com_api_type_pkg.t_dict_value
        , crdh_auth_entity           com_api_type_pkg.t_dict_value
        , card_data_output_cap       com_api_type_pkg.t_dict_value
        , terminal_output_cap        com_api_type_pkg.t_dict_value
        , pin_capture_cap            com_api_type_pkg.t_dict_value
        , pin_presence               com_api_type_pkg.t_dict_value
        , cvv2_presence              com_api_type_pkg.t_dict_value
        , cvc_indicator              com_api_type_pkg.t_dict_value
        , pos_entry_mode             varchar2(3)
        , pos_cond_code              varchar2(2)
        , emv_data                   com_api_type_pkg.t_full_desc
        , atc                        com_api_type_pkg.t_dict_value
        , tvr                        com_api_type_pkg.t_name
        , cvr                        com_api_type_pkg.t_name
        , addl_data                  com_api_type_pkg.t_full_desc
        , service_code               com_api_type_pkg.t_curr_code
        , device_date                date
        , cvv2_result                com_api_type_pkg.t_dict_value
        , certificate_method         com_api_type_pkg.t_dict_value
        , certificate_type           com_api_type_pkg.t_dict_value
        , merchant_certif            com_api_type_pkg.t_name
        , cardholder_certif          com_api_type_pkg.t_name
        , ucaf_indicator             com_api_type_pkg.t_dict_value
        , is_early_emv               com_api_type_pkg.t_boolean
        , is_completed               com_api_type_pkg.t_dict_value
        , amounts                    com_api_type_pkg.t_raw_data
        , cavv_presence              com_api_type_pkg.t_dict_value
        , aav_presence               com_api_type_pkg.t_dict_value
        , transaction_id             com_api_type_pkg.t_auth_long_id
        --opr_operation             
        , session_id                 com_api_type_pkg.t_long_id 
        , is_reversal                com_api_type_pkg.t_boolean
        , original_id                com_api_type_pkg.t_long_id
        , oper_type                  com_api_type_pkg.t_dict_value
        , oper_reason                com_api_type_pkg.t_dict_value
        , msg_type                   com_api_type_pkg.t_dict_value
        , oper_status                com_api_type_pkg.t_dict_value
        , status_reason              com_api_type_pkg.t_dict_value
        , sttl_type                  com_api_type_pkg.t_dict_value
        , terminal_type              com_api_type_pkg.t_dict_value
        , acq_inst_bin               com_api_type_pkg.t_rrn
        , forw_inst_bin              com_api_type_pkg.t_rrn
        , merchant_number            com_api_type_pkg.t_merchant_number
        , terminal_number            com_api_type_pkg.t_terminal_number
        , merchant_name              com_api_type_pkg.t_name
        , merchant_street            com_api_type_pkg.t_name
        , merchant_city              com_api_type_pkg.t_name
        , merchant_region            com_api_type_pkg.t_name
        , merchant_country           com_api_type_pkg.t_curr_code
        , merchant_postcode          com_api_type_pkg.t_name
        , mcc                        com_api_type_pkg.t_mcc
        , originator_refnum          com_api_type_pkg.t_rrn
        , network_refnum             com_api_type_pkg.t_rrn
        , oper_count                 com_api_type_pkg.t_long_id
        , oper_request_amount        com_api_type_pkg.t_money
        , oper_amount_algorithm      com_api_type_pkg.t_dict_value
        , oper_amount                com_api_type_pkg.t_money
        , oper_currency              com_api_type_pkg.t_curr_code
        , oper_cashback_amount       com_api_type_pkg.t_money
        , oper_replacement_amount    com_api_type_pkg.t_money
        , oper_surcharge_amount      com_api_type_pkg.t_money
        , oper_date                  date
        , host_date                  date
        , unhold_date                date
        , match_status               com_api_type_pkg.t_dict_value
        , sttl_amount                com_api_type_pkg.t_money
        , sttl_currency              com_api_type_pkg.t_curr_code
        , dispute_id                 com_api_type_pkg.t_long_id
        , payment_order_id           com_api_type_pkg.t_long_id
        , payment_host_id            com_api_type_pkg.t_tiny_id
        , forced_processing          com_api_type_pkg.t_boolean
        , match_id                   com_api_type_pkg.t_long_id
        , oper_proc_mode             com_api_type_pkg.t_dict_value
        , clearing_sequence_num      com_api_type_pkg.t_tiny_id
        , clearing_sequence_count    com_api_type_pkg.t_tiny_id
        , incom_sess_file_id         com_api_type_pkg.t_long_id
        --opr_participant iss        
        , iss_participant_type       com_api_type_pkg.t_dict_value
        , iss_inst_id                com_api_type_pkg.t_inst_id
        , iss_network_id             com_api_type_pkg.t_network_id
        , iss_split_hash             com_api_type_pkg.t_tiny_id
        , iss_client_id_type         com_api_type_pkg.t_dict_value
        , iss_client_id_value        com_api_type_pkg.t_name
        , iss_customer_id            com_api_type_pkg.t_medium_id
        , iss_auth_code              com_api_type_pkg.t_auth_code
        , iss_card_id                com_api_type_pkg.t_medium_id
        , iss_card_instance_id       com_api_type_pkg.t_medium_id
        , iss_card_type_id           com_api_type_pkg.t_tiny_id
        , iss_card_mask              com_api_type_pkg.t_card_number
        , iss_card_hash              com_api_type_pkg.t_medium_id
        , iss_card_seq_number        com_api_type_pkg.t_tiny_id
        , iss_card_expir_date        date
        , iss_card_service_code      com_api_type_pkg.t_country_code
        , iss_card_country           com_api_type_pkg.t_country_code
        , iss_card_network_id        com_api_type_pkg.t_network_id
        , iss_card_inst_id           com_api_type_pkg.t_inst_id
        , iss_account_id             com_api_type_pkg.t_account_id
        , iss_account_type           com_api_type_pkg.t_dict_value
        , iss_account_number         com_api_type_pkg.t_account_number
        , iss_account_amount         com_api_type_pkg.t_money
        , iss_account_currency       com_api_type_pkg.t_curr_code
        , iss_merchant_id            com_api_type_pkg.t_short_id
        , iss_terminal_id            com_api_type_pkg.t_short_id

        -- opr_participant acq
        , acq_participant_type       com_api_type_pkg.t_dict_value
        , acq_inst_id                com_api_type_pkg.t_inst_id
        , acq_network_id             com_api_type_pkg.t_network_id
        , acq_split_hash             com_api_type_pkg.t_tiny_id
        , acq_client_id_type         com_api_type_pkg.t_dict_value
        , acq_client_id_value        com_api_type_pkg.t_name
        , acq_customer_id            com_api_type_pkg.t_medium_id
        , acq_auth_code              com_api_type_pkg.t_auth_code
        , acq_card_id                com_api_type_pkg.t_medium_id
        , acq_card_instance_id       com_api_type_pkg.t_medium_id
        , acq_card_type_id           com_api_type_pkg.t_tiny_id
        , acq_card_mask              com_api_type_pkg.t_card_number
        , acq_card_hash              com_api_type_pkg.t_medium_id
        , acq_card_seq_number        com_api_type_pkg.t_tiny_id
        , acq_card_expir_date        date
        , acq_card_service_code      com_api_type_pkg.t_country_code
        , acq_card_country           com_api_type_pkg.t_country_code
        , acq_card_network_id        com_api_type_pkg.t_network_id
        , acq_card_inst_id           com_api_type_pkg.t_inst_id
        , acq_account_id             com_api_type_pkg.t_account_id
        , acq_account_type           com_api_type_pkg.t_dict_value
        , acq_account_number         com_api_type_pkg.t_account_number
        , acq_account_amount         com_api_type_pkg.t_money
        , acq_account_currency       com_api_type_pkg.t_curr_code
        , acq_merchant_id            com_api_type_pkg.t_short_id
        , acq_terminal_id            com_api_type_pkg.t_short_id

        -- opr_participant dst
        , dst_participant_type       com_api_type_pkg.t_dict_value
        , dst_inst_id                com_api_type_pkg.t_inst_id
        , dst_network_id             com_api_type_pkg.t_network_id
        , dst_split_hash             com_api_type_pkg.t_tiny_id
        , dst_client_id_type         com_api_type_pkg.t_dict_value
        , dst_client_id_value        com_api_type_pkg.t_name
        , dst_customer_id            com_api_type_pkg.t_medium_id
        , dst_auth_code              com_api_type_pkg.t_auth_code
        , dst_card_id                com_api_type_pkg.t_medium_id
        , dst_card_instance_id       com_api_type_pkg.t_medium_id
        , dst_card_type_id           com_api_type_pkg.t_tiny_id
        , dst_card_mask              com_api_type_pkg.t_card_number
        , dst_card_hash              com_api_type_pkg.t_medium_id
        , dst_card_seq_number        com_api_type_pkg.t_tiny_id
        , dst_card_expir_date        date
        , dst_card_service_code      com_api_type_pkg.t_country_code
        , dst_card_country           com_api_type_pkg.t_country_code
        , dst_card_network_id        com_api_type_pkg.t_network_id
        , dst_card_inst_id           com_api_type_pkg.t_inst_id
        , dst_account_id             com_api_type_pkg.t_account_id
        , dst_account_type           com_api_type_pkg.t_dict_value
        , dst_account_number         com_api_type_pkg.t_account_number
        , dst_account_amount         com_api_type_pkg.t_money
        , dst_account_currency       com_api_type_pkg.t_curr_code
        , dst_merchant_id            com_api_type_pkg.t_short_id
        , dst_terminal_id            com_api_type_pkg.t_short_id
    );
    type t_auth_rec_tab is table of t_auth_rec index by binary_integer;
    
    function pad_number (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2;
          
    function pad_char (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2;
    
end;
/
