create or replace package vis_api_type_pkg as

    type            t_visa_file_rec is record (
        id                   com_api_type_pkg.t_long_id
        , is_incoming        com_api_type_pkg.t_boolean
        , network_id         com_api_type_pkg.t_tiny_id
        , proc_bin           varchar2(6)
        , proc_date          date
        , sttl_date          date
        , release_number     varchar2(3)
        , test_option        varchar2(4)
        , security_code      varchar2(8)
        , visa_file_id       varchar2(3)
        , trans_total        com_api_type_pkg.t_short_id
        , batch_total        com_api_type_pkg.t_short_id
        , tcr_total          com_api_type_pkg.t_short_id
        , monetary_total     com_api_type_pkg.t_short_id
        , src_amount         com_api_type_pkg.t_money
        , dst_amount         com_api_type_pkg.t_money
        , inst_id            com_api_type_pkg.t_inst_id
        , session_file_id    com_api_type_pkg.t_long_id
    );

    type            t_visa_batch_rec is record (
        id                   com_api_type_pkg.t_long_id
        , file_id            com_api_type_pkg.t_long_id
        , proc_bin           varchar2(6)
        , proc_date          date
        , batch_number       varchar2(6)
        , center_batch_id    varchar2(8)
        , monetary_total     com_api_type_pkg.t_short_id
        , tcr_total          com_api_type_pkg.t_short_id
        , trans_total        com_api_type_pkg.t_short_id
        , src_amount         com_api_type_pkg.t_money
        , dst_amount         com_api_type_pkg.t_money
    );

    type            t_visa_fin_mes_rec is record (
        id                         com_api_type_pkg.t_long_id
      , status                   com_api_type_pkg.t_dict_value
      , is_reversal              com_api_type_pkg.t_boolean
      , is_incoming              com_api_type_pkg.t_boolean
      , is_returned              com_api_type_pkg.t_boolean
      , is_invalid               com_api_type_pkg.t_boolean
      , inst_id                  com_api_type_pkg.t_inst_id
      , network_id               com_api_type_pkg.t_tiny_id
      , trans_code               com_api_type_pkg.t_byte_char
      , trans_code_qualifier     varchar2(1)
      , card_id                  com_api_type_pkg.t_medium_id
      , card_hash                com_api_type_pkg.t_medium_id
      , card_mask                com_api_type_pkg.t_card_number
      , oper_amount              com_api_type_pkg.t_money
      , oper_currency            com_api_type_pkg.t_curr_code
      , oper_date                date
      , sttl_amount              com_api_type_pkg.t_money
      , sttl_currency            com_api_type_pkg.t_curr_code
      , arn                      varchar2(23)
      , acq_business_id          com_api_type_pkg.t_dict_value
      , merchant_name            varchar2(25)
      , merchant_city            varchar2(13)
      , merchant_country         com_api_type_pkg.t_country_code
      , merchant_postal_code     com_api_type_pkg.t_postal_code
      , merchant_region          com_api_type_pkg.t_module_code
      , mcc                      com_api_type_pkg.t_mcc
      , req_pay_service          com_api_type_pkg.t_dict_value
      , usage_code               varchar2(1)
      , reason_code              com_api_type_pkg.t_byte_char
      , settlement_flag          varchar2(1)
      , auth_char_ind            com_api_type_pkg.t_dict_value
      , auth_code                com_api_type_pkg.t_auth_code
      , pos_terminal_cap         com_api_type_pkg.t_dict_value
      , inter_fee_ind            varchar2(1)
      , crdh_id_method           varchar2(1)
      , collect_only_flag        varchar2(1)
      , pos_entry_mode           com_api_type_pkg.t_byte_char
      , central_proc_date        com_api_type_pkg.t_mcc
      , reimburst_attr           varchar2(1)
      , iss_workst_bin           com_api_type_pkg.t_auth_code
      , acq_workst_bin           com_api_type_pkg.t_auth_code
      , chargeback_ref_num       com_api_type_pkg.t_auth_code
      , docum_ind                varchar2(1)
      , member_msg_text          varchar2(50)
      , spec_cond_ind            com_api_type_pkg.t_byte_char
      , fee_program_ind          com_api_type_pkg.t_module_code
      , issuer_charge            varchar2(1)
      , merchant_number          com_api_type_pkg.t_merchant_number
      , terminal_number          com_api_type_pkg.t_terminal_number
      , national_reimb_fee       com_api_type_pkg.t_cmid
      , electr_comm_ind          varchar2(1)
      , spec_chargeback_ind      varchar2(1)
      , interface_trace_num      com_api_type_pkg.t_auth_code
      , unatt_accept_term_ind    varchar2(1)
      , prepaid_card_ind         varchar2(1)
      , service_development      varchar2(1)
      , avs_resp_code            varchar2(1)
      , auth_source_code         varchar2(1)
      , purch_id_format          varchar2(1)
      , account_selection        varchar2(1)
      , installment_pay_count    com_api_type_pkg.t_byte_char
      , purch_id                 varchar2(25)
      , cashback                 varchar2(9)
      , chip_cond_code           varchar2(1)
      , transaction_id           com_api_type_pkg.t_merchant_number
      , pos_environment          varchar2(1)
      , transaction_type         com_api_type_pkg.t_byte_char
      , card_seq_number          com_api_type_pkg.t_module_code
      , terminal_profile         com_api_type_pkg.t_auth_code
      , unpredict_number         com_api_type_pkg.t_dict_value
      , appl_trans_counter       com_api_type_pkg.t_mcc
      , appl_interch_profile     com_api_type_pkg.t_mcc
      , cryptogram               varchar2(16)
      , term_verif_result        com_api_type_pkg.t_postal_code
      , cryptogram_amount        com_api_type_pkg.t_cmid
      , card_expir_date          com_api_type_pkg.t_mcc
      , cryptogram_version       com_api_type_pkg.t_byte_char
      , cvv2_result_code         varchar2(1)
      , auth_resp_code           com_api_type_pkg.t_byte_char
      , card_verif_result        com_api_type_pkg.t_dict_value
      , floor_limit_ind          varchar2(1)
      , exept_file_ind           varchar2(1)
      , pcas_ind                 varchar2(1)
      , issuer_appl_data         varchar2(64)
      , issuer_script_result     com_api_type_pkg.t_postal_code
      , network_amount           com_api_type_pkg.t_money
      , network_currency         com_api_type_pkg.t_curr_code
      , dispute_id               com_api_type_pkg.t_long_id
      , file_id                  com_api_type_pkg.t_long_id
      , batch_id                 com_api_type_pkg.t_medium_id
      , record_number            com_api_type_pkg.t_short_id
      , rrn                      com_api_type_pkg.t_rrn
      , acquirer_bin             com_api_type_pkg.t_cmid
      , merchant_street          com_api_type_pkg.t_name
      , cryptogram_info_data     com_api_type_pkg.t_byte_char
      , card_number              com_api_type_pkg.t_card_number -- for local processing only, not for inserting in VIS_FIN_MESSAGE
      , merchant_verif_value     com_api_type_pkg.t_postal_code
      , host_inst_id             com_api_type_pkg.t_inst_id
      , proc_bin                 com_api_type_pkg.t_auth_code
      , chargeback_reason_code   com_api_type_pkg.t_mcc
      , destination_channel      varchar2(1)
      , source_channel           varchar2(1)
      , acq_inst_bin             com_api_type_pkg.t_rrn
      , spend_qualified_ind      varchar2(1)
      , clearing_sequence_num    number(2)
      , clearing_sequence_count  number(2)
      , service_code             com_api_type_pkg.t_curr_code
      , business_format_code     varchar2(1)
      , token_assurance_level    com_api_type_pkg.t_byte_char
      , pan_token                com_api_type_pkg.t_long_id
      , validation_code          com_api_type_pkg.t_mcc
      , payment_forms_num        com_api_type_pkg.t_byte_char
      , business_format_code_e   com_api_type_pkg.t_byte_char
      , agent_unique_id          varchar2(5)
      , additional_auth_method   com_api_type_pkg.t_byte_char
      , additional_reason_code   com_api_type_pkg.t_byte_char
      , product_id               com_api_type_pkg.t_byte_char
      , auth_amount              com_api_type_pkg.t_money
      , auth_currency            com_api_type_pkg.t_curr_code
      , form_factor_indicator    com_api_type_pkg.t_dict_value

      , fast_funds_indicator     varchar2(1)
      , business_format_code_3   com_api_type_pkg.t_byte_char
      , business_application_id  com_api_type_pkg.t_byte_char
      , source_of_funds          varchar2(1)
      , payment_reversal_code    com_api_type_pkg.t_byte_char
      , sender_reference_number  com_api_type_pkg.t_terminal_number        
      , sender_account_number    varchar2(34)
      , sender_name              com_api_type_pkg.t_attr_name
      , sender_address           varchar2(35)
      , sender_city              varchar2(25)
      , sender_state             com_api_type_pkg.t_byte_char
      , sender_country           com_api_type_pkg.t_country_code
      , network_code             com_api_type_pkg.t_inst_id
      , interchange_fee_amount   com_api_type_pkg.t_money
      , interchange_fee_sign     com_api_type_pkg.t_sign
      , program_id               com_api_type_pkg.t_auth_code
      , dcc_indicator            com_api_type_pkg.t_byte_char        
      , message_reason_code      com_api_type_pkg.t_dict_value
      , dispute_condition        com_api_type_pkg.t_curr_code
      , vrol_financial_id        com_api_type_pkg.t_region_code
      , vrol_case_number         com_api_type_pkg.t_postal_code
      , vrol_bundle_number       com_api_type_pkg.t_postal_code
      , client_case_number       com_api_type_pkg.t_attr_name
      , dispute_status           com_api_type_pkg.t_byte_char
      , payment_acc_ref          com_api_type_pkg.t_attr_name
      , token_requestor_id       com_api_type_pkg.t_region_code
      , terminal_country         com_api_type_pkg.t_country_code
        
      -- TCR3
      , trans_comp_number_tcr3       varchar2(1)
      , business_application_id_tcr3 com_api_type_pkg.t_byte_char
      , business_format_code_tcr3    com_api_type_pkg.t_byte_char
      , passenger_name               varchar2(20)
      , departure_date               date
      , orig_city_airport_code       varchar2(3)
      , carrier_code_1               com_api_type_pkg.t_byte_char
      , service_class_code_1         varchar2(1)
      , stop_over_code_1             varchar2(1)
      , dest_city_airport_code_1     varchar2(3)
      , carrier_code_2               com_api_type_pkg.t_byte_char
      , service_class_code_2         varchar2(1)
      , stop_over_code_2             varchar2(1)
      , dest_city_airport_code_2     varchar2(3)
      , carrier_code_3               com_api_type_pkg.t_byte_char
      , service_class_code_3         varchar2(1)
      , stop_over_code_3             varchar2(1)
      , dest_city_airport_code_3     varchar2(3)
      , carrier_code_4               com_api_type_pkg.t_byte_char
      , service_class_code_4         varchar2(1)
      , stop_over_code_4             varchar2(1)
      , dest_city_airport_code_4     varchar2(3)
      , travel_agency_code           varchar2(8)
      , travel_agency_name           varchar2(25)
      , restrict_ticket_indicator    varchar2(1)
      , fare_basis_code_1            com_api_type_pkg.t_tag
      , fare_basis_code_2            com_api_type_pkg.t_tag
      , fare_basis_code_3            com_api_type_pkg.t_tag
      , fare_basis_code_4            com_api_type_pkg.t_tag
      , comp_reserv_system           varchar2(4)
      , flight_number_1              varchar2(5)
      , flight_number_2              varchar2(5)
      , flight_number_3              varchar2(5)
      , flight_number_4              varchar2(5)
      , credit_reason_indicator      varchar2(1)
      , ticket_change_indicator      varchar2(1)
      , recipient_name               com_api_type_pkg.t_attr_name
      
      , dispute_amount               com_api_type_pkg.t_money
      , dispute_currency             com_api_type_pkg.t_curr_code
      , terminal_trans_date          date
      -- TCR 4
      , business_format_code_4       com_api_type_pkg.t_byte_char
      , surcharge_amount             varchar2(8)
      , surcharge_sign               varchar2(2)
      , conv_date                    varchar2(4)
  );
    type            t_visa_fin_mes_tab is table of t_visa_fin_mes_rec index by binary_integer;
    type            t_visa_fin_cur is ref cursor return t_visa_fin_mes_rec;

    type            t_retrieval_rec is record (
        id                         com_api_type_pkg.t_long_id
        , file_id                  com_api_type_pkg.t_long_id
        , req_id                   com_api_type_pkg.t_long_id
        , purchase_date            date
        , source_amount            com_api_type_pkg.t_medium_id
        , source_currency          com_api_type_pkg.t_curr_code
        , reason_code              com_api_type_pkg.t_byte_char
        , national_reimb_fee       com_api_type_pkg.t_medium_id
        , atm_account_sel          com_api_type_pkg.t_dict_value
        , reimb_flag               varchar2(1)
        , fax_number               com_api_type_pkg.t_auth_long_id
        , req_fulfill_method       varchar2(1)
        , used_fulfill_method      varchar2(1)
        , iss_rfc_bin              com_api_type_pkg.t_auth_code
        , iss_rfc_subaddr          varchar2(7)
        , iss_billing_currency     varchar2(3)
        , iss_billing_amount       number(12)
        , transaction_id           com_api_type_pkg.t_merchant_number
        , excluded_trans_id_reason varchar2(1)
        , crs_code                 varchar2(1)
        , multiple_clearing_seqn   varchar2(2)
        , product_code             com_api_type_pkg.t_mcc
        , contact_info             varchar2(25)
        , iss_inst_id              com_api_type_pkg.t_inst_id
        , acq_inst_id              com_api_type_pkg.t_inst_id
    );

    type            t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;

    type            t_visa_fin_mes_fraud_rec is record (
        id                         com_api_type_pkg.t_long_id
      , status                   com_api_type_pkg.t_dict_value
      , is_reversal              com_api_type_pkg.t_boolean
      , is_incoming              com_api_type_pkg.t_boolean
      , is_returned              com_api_type_pkg.t_boolean
      , is_invalid               com_api_type_pkg.t_boolean
      , inst_id                  com_api_type_pkg.t_inst_id
      , network_id               com_api_type_pkg.t_tiny_id
      --, trans_code             com_api_type_pkg.t_byte_char   --move below
      , trans_code_qualifier     varchar2(1)
      , card_id                  com_api_type_pkg.t_medium_id
      , card_hash                com_api_type_pkg.t_medium_id
      , card_mask                com_api_type_pkg.t_card_number
      , oper_amount              com_api_type_pkg.t_money
      , oper_currency            com_api_type_pkg.t_curr_code
      , oper_date                date
      , host_date                date
      , sttl_amount              com_api_type_pkg.t_money
      , sttl_currency            com_api_type_pkg.t_curr_code
      , arn                      varchar2(23)
      , acq_business_id          com_api_type_pkg.t_dict_value
      , merchant_name            varchar2(25)
      , merchant_city            varchar2(13)
      , merchant_country         com_api_type_pkg.t_country_code
      , merchant_postal_code     com_api_type_pkg.t_postal_code
      , merchant_region          com_api_type_pkg.t_module_code
      , mcc                      com_api_type_pkg.t_mcc
      , req_pay_service          com_api_type_pkg.t_dict_value
      , usage_code               varchar2(1)
      , reason_code              com_api_type_pkg.t_byte_char
      , settlement_flag          varchar2(1)
      , auth_char_ind            com_api_type_pkg.t_dict_value
      , auth_code                com_api_type_pkg.t_auth_code
      , pos_terminal_cap         com_api_type_pkg.t_dict_value
      , inter_fee_ind            varchar2(1)
      , crdh_id_method           varchar2(1)
      , collect_only_flag        varchar2(1)
      , pos_entry_mode           com_api_type_pkg.t_byte_char
      , central_proc_date        com_api_type_pkg.t_mcc
      , reimburst_attr           varchar2(1)
      , iss_workst_bin           com_api_type_pkg.t_auth_code
      , acq_workst_bin           com_api_type_pkg.t_auth_code
      , chargeback_ref_num       com_api_type_pkg.t_auth_code
      , docum_ind                varchar2(1)
      , member_msg_text          varchar2(50)
      , spec_cond_ind            com_api_type_pkg.t_byte_char
      , fee_program_ind          com_api_type_pkg.t_module_code
      , issuer_charge            varchar2(1)
      , merchant_number          com_api_type_pkg.t_merchant_number
      , terminal_number          com_api_type_pkg.t_terminal_number
      , national_reimb_fee       com_api_type_pkg.t_cmid
      , electr_comm_ind          varchar2(1)
      , spec_chargeback_ind      varchar2(1)
      , interface_trace_num      com_api_type_pkg.t_auth_code
      , unatt_accept_term_ind    varchar2(1)
      , prepaid_card_ind         varchar2(1)
      , service_development      varchar2(1)
      , avs_resp_code            varchar2(1)
      , auth_source_code         varchar2(1)
      , purch_id_format          varchar2(1)
      , account_selection        varchar2(1)
      , installment_pay_count    com_api_type_pkg.t_byte_char
      , purch_id                 varchar2(25)
      , cashback                 varchar2(9)
      , chip_cond_code           varchar2(1)
      , transaction_id           com_api_type_pkg.t_merchant_number
      , pos_environment          varchar2(1)
      , transaction_type         com_api_type_pkg.t_byte_char
      , card_seq_number          com_api_type_pkg.t_module_code
      , terminal_profile         com_api_type_pkg.t_auth_code
      , unpredict_number         com_api_type_pkg.t_dict_value
      , appl_trans_counter       com_api_type_pkg.t_mcc
      , appl_interch_profile     com_api_type_pkg.t_mcc
      , cryptogram               com_api_type_pkg.t_pin_block
      , term_verif_result        com_api_type_pkg.t_postal_code
      , cryptogram_amount        com_api_type_pkg.t_cmid
      , card_expir_date          com_api_type_pkg.t_mcc
      , cryptogram_version       com_api_type_pkg.t_byte_char
      , cvv2_result_code         varchar2(1)
      , auth_resp_code           com_api_type_pkg.t_byte_char
      , card_verif_result        com_api_type_pkg.t_dict_value
      , floor_limit_ind          varchar2(1)
      , exept_file_ind           varchar2(1)
      , pcas_ind                 varchar2(1)
      , issuer_appl_data         varchar2(64)
      , issuer_script_result     com_api_type_pkg.t_postal_code
      , network_amount           com_api_type_pkg.t_money
      , network_currency         com_api_type_pkg.t_curr_code
      , dispute_id               com_api_type_pkg.t_long_id
      , file_id                  com_api_type_pkg.t_long_id
      , batch_id                 com_api_type_pkg.t_medium_id
      , record_number            com_api_type_pkg.t_short_id
      , rrn                      com_api_type_pkg.t_rrn
      , acquirer_bin             com_api_type_pkg.t_cmid
      , merchant_street          com_api_type_pkg.t_name
      , cryptogram_info_data     com_api_type_pkg.t_byte_char
      , merchant_verif_value     com_api_type_pkg.t_postal_code
      , host_inst_id             com_api_type_pkg.t_inst_id
      , proc_bin                 com_api_type_pkg.t_auth_code
      , chargeback_reason_code   com_api_type_pkg.t_mcc
      , destination_channel      varchar2(1)
      , source_channel           varchar2(1)
      , acq_inst_bin             com_api_type_pkg.t_rrn
      , spend_qualified_ind      varchar2(1)
      , clearing_sequence_num    number(2)
      , clearing_sequence_count  number(2)
      , service_code             com_api_type_pkg.t_curr_code
      , business_format_code     varchar2(1)
      , token_assurance_level    com_api_type_pkg.t_byte_char
      , pan_token                com_api_type_pkg.t_long_id
      , validation_code          com_api_type_pkg.t_mcc
      , payment_forms_num        com_api_type_pkg.t_byte_char
      , business_format_code_e   com_api_type_pkg.t_byte_char
      , agent_unique_id          varchar2(5)
      , additional_auth_method   com_api_type_pkg.t_byte_char
      , additional_reason_code   com_api_type_pkg.t_byte_char
      , product_id               com_api_type_pkg.t_byte_char
      , auth_amount              com_api_type_pkg.t_money
      , auth_currency            com_api_type_pkg.t_curr_code
      , form_factor_indicator    com_api_type_pkg.t_dict_value

      , fast_funds_indicator     varchar2(1)
      , business_format_code_3   com_api_type_pkg.t_byte_char
      , business_application_id  com_api_type_pkg.t_byte_char
      , source_of_funds          varchar2(1)
      , payment_reversal_code    com_api_type_pkg.t_byte_char
      , sender_reference_number  com_api_type_pkg.t_terminal_number
      , sender_account_number    varchar2(34)
      , sender_name              com_api_type_pkg.t_attr_name
      , sender_address           varchar2(35)
      , sender_city              varchar2(25)
      , sender_state             com_api_type_pkg.t_byte_char
      , sender_country           com_api_type_pkg.t_country_code
      , network_code             com_api_type_pkg.t_inst_id
      , surcharge_amount         varchar2(8) --com_api_type_pkg.t_money
      , surcharge_sign           varchar2(2)
      , oper_request_amount      com_api_type_pkg.t_money
      , dcc_indicator            com_api_type_pkg.t_byte_char        
      , message_reason_code      com_api_type_pkg.t_dict_value
      , dispute_condition        com_api_type_pkg.t_curr_code
      , vrol_financial_id        com_api_type_pkg.t_region_code
      , vrol_case_number         com_api_type_pkg.t_postal_code
      , vrol_bundle_number       com_api_type_pkg.t_postal_code
      , client_case_number       com_api_type_pkg.t_attr_name
      , dispute_status           com_api_type_pkg.t_byte_char
      , payment_acc_ref          com_api_type_pkg.t_attr_name
      , token_requestor_id       com_api_type_pkg.t_region_code
      , terminal_country         com_api_type_pkg.t_country_code
       -- TCR3
      , trans_comp_number_tcr3       varchar2(1)
      , business_application_id_tcr3 com_api_type_pkg.t_byte_char
      , business_format_code_tcr3    com_api_type_pkg.t_byte_char
      , passenger_name               varchar2(20)
      , departure_date               date
      , orig_city_airport_code       varchar2(3)
      , carrier_code_1               com_api_type_pkg.t_byte_char
      , service_class_code_1         varchar2(1)
      , stop_over_code_1             varchar2(1)
      , dest_city_airport_code_1     varchar2(3)
      , carrier_code_2               com_api_type_pkg.t_byte_char
      , service_class_code_2         varchar2(1)
      , stop_over_code_2             varchar2(1)
      , dest_city_airport_code_2     varchar2(3)
      , carrier_code_3               com_api_type_pkg.t_byte_char
      , service_class_code_3         varchar2(1)
      , stop_over_code_3             varchar2(1)
      , dest_city_airport_code_3     varchar2(3)
      , carrier_code_4               com_api_type_pkg.t_byte_char
      , service_class_code_4         varchar2(1)
      , stop_over_code_4             varchar2(1)
      , dest_city_airport_code_4     varchar2(3)
      , travel_agency_code           varchar2(8)
      , travel_agency_name           varchar2(25)
      , restrict_ticket_indicator    varchar2(1)
      , fare_basis_code_1            com_api_type_pkg.t_tag
      , fare_basis_code_2            com_api_type_pkg.t_tag
      , fare_basis_code_3            com_api_type_pkg.t_tag
      , fare_basis_code_4            com_api_type_pkg.t_tag
      , comp_reserv_system           varchar2(4)
      , flight_number_1              varchar2(5)
      , flight_number_2              varchar2(5)
      , flight_number_3              varchar2(5)
      , flight_number_4              varchar2(5)
      , credit_reason_indicator      varchar2(1)
      , ticket_change_indicator      varchar2(1)
      , recipient_name               com_api_type_pkg.t_attr_name

      , trans_code                   com_api_type_pkg.t_byte_char
      , card_number                  com_api_type_pkg.t_card_number -- for local processing only, not for inserting in VIS_FIN_MESSAGE
      -- fraud fields
      , dest_bin                     com_api_type_pkg.t_auth_code
      , source_bin                   com_api_type_pkg.t_auth_code
      , account_number               com_api_type_pkg.t_account_number
      , fraud_amount                 com_api_type_pkg.t_medium_id
      , fraud_currency               com_api_type_pkg.t_curr_code
      , vic_processing_date          date
      , iss_gen_auth                 com_api_type_pkg.t_dict_value
      , notification_code            com_api_type_pkg.t_dict_value
      , account_seq_number           com_api_type_pkg.t_mcc
      , reserved                     varchar2(1)
      , fraud_type                   com_api_type_pkg.t_dict_value
      , fraud_inv_status             com_api_type_pkg.t_byte_char
      , addendum_present             com_api_type_pkg.t_boolean
      , excluded_trans_id_reason     varchar2(1)
      , multiple_clearing_seqn       com_api_type_pkg.t_byte_char
      , travel_agency_id             com_api_type_pkg.t_dict_value
      , cashback_ind                 varchar2(1)
      , card_capability              varchar2(1)
      , crdh_activated_term_ind      varchar2(1)
      , fraud_id                     com_api_type_pkg.t_long_id
      , fraud_payment_account_ref    com_api_type_pkg.t_account_number
      , fraud_network_id             com_api_type_pkg.t_network_id
      , fraud_host_inst_id           com_api_type_pkg.t_inst_id
      , fraud_proc_bin               com_api_type_pkg.t_dict_value
      , row_num                      com_api_type_pkg.t_long_id
    );
    type            t_visa_fin_mes_fraud_tab is table of t_visa_fin_mes_fraud_rec index by binary_integer;
    type            t_visa_fin_fraud_cur is ref cursor return t_visa_fin_mes_fraud_rec;

    subtype  t_visa_fraud_rec is vis_fraud%rowtype;

    type            t_fee_rec is record (
        id                         com_api_type_pkg.t_long_id
        , file_id                  com_api_type_pkg.t_long_id
        , pay_fee                  com_api_type_pkg.t_medium_id
        , dst_bin                  com_api_type_pkg.t_bin
        , src_bin                  com_api_type_pkg.t_bin
        , reason_code              varchar2(4)
        , country_code             com_api_type_pkg.t_country_code
        , event_date               date
        , pay_amount               com_api_type_pkg.t_money
        , pay_currency             com_api_type_pkg.t_curr_code
        , src_amount               com_api_type_pkg.t_money
        , src_currency             com_api_type_pkg.t_curr_code
        , message_text             com_api_type_pkg.t_name
        , trans_id                 com_api_type_pkg.t_auth_long_id
        , reimb_attr               varchar2(1)
        , dst_inst_id              com_api_type_pkg.t_inst_id
        , src_inst_id              com_api_type_pkg.t_inst_id
        , funding_source           varchar2(1)
    );
    
    type            t_visa_multipurpose_rec is record (
        id                         com_api_type_pkg.t_long_id
        , file_id                  com_api_type_pkg.t_long_id
        , record_number            com_api_type_pkg.t_short_id
        , status                   com_api_type_pkg.t_dict_value 
        , iss_acq                  varchar2(1)
        , mvv_code                 varchar2(10)
        , remote_terminal          varchar2(1)
        , charge_ind               varchar2(1)
        , account_prod_id          varchar2(2)
        , bus_app_ind              varchar2(2)
        , funds_source             varchar2(1)
        , affiliate_bin            varchar2(10)
        , sttl_date                date
        , trxn_ind                 varchar2(15)
        , val_code                 varchar2(4)
        , refnum                   varchar2(12)
        , trace_num                varchar2(6)
        , batch_num                varchar2(4)
        , req_msg_type             number(4)
        , resp_code                com_api_type_pkg.t_byte_char
        , proc_code                varchar2(6)
        , card_number              com_api_type_pkg.t_card_number
        , trxn_amount              number(12)
        , currency_code            com_api_type_pkg.t_curr_code
        , match_auth_id            com_api_type_pkg.t_long_id
        , inst_id                  com_api_type_pkg.t_inst_id 
    );    

    -- Record type for storing data of TC46 (settlement data)
    type            t_settlement_data_rec is record (
        dst_bin                    com_api_type_pkg.t_bin
      , src_bin                    com_api_type_pkg.t_bin
      , sre_id                     varchar2(10)                     -- identifier for the SRE being reported on 
      , up_sre_id                  varchar2(10)                     -- rollup to SRE identifier 
      , funds_id                   varchar2(10)                     -- funds transfer SRE Identifier
      , sttl_service               com_api_type_pkg.t_tiny_id       -- settlement service identifier
      , sttl_currency              com_api_type_pkg.t_curr_code
      , clear_currency             com_api_type_pkg.t_curr_code
      , bus_mode                   varchar2(1)                      -- business mode
      , no_data                    varchar2(1)                      -- no data indicator, Y or space (that means No)
      , report_group               varchar2(1)
      , report_subgroup            varchar2(1)
      , rep_id_num                 varchar2(3)                      -- report identification number
      , rep_id_sfx                 varchar2(2)                      -- report identification suffix
      , sttl_date                  date 
      , report_date                date                             -- report creation date 
      , date_from                  date                             -- starting range for report
      , date_to                    date                             -- ending range for report
      , charge_type                varchar2(3)                      -- charge type code
      , bus_tr_type                varchar2(3)                      -- business transaction type 
      , bus_tr_cycle               varchar2(1)                      -- business transaction cycle 
      , revers_ind                 varchar2(1)                      -- reversal indicator (Y or N)
      , return_ind                 varchar2(1)                      -- return indicator (Y or N)
      , jurisdict                  varchar2(2)                      -- jurisdiction code
      , routing                    varchar2(1)                      -- inter-regional routing indicator (Y or N)
      , src_country                com_api_type_pkg.t_country_code
      , dst_country                com_api_type_pkg.t_country_code
      , src_region                 varchar2(2)
      , dst_region                 varchar2(2)
      , fee_level                  varchar2(16)                     -- fee level descriptor
      , cr_db_net                  varchar2(1)                      -- credit/debit/net_line indicator 
      , summary_level              varchar2(2)                      -- level of summarization contained in TC 46 record
      , currency_table_date        date                             -- CCYYDDD, where CC - century, YY - year, DDD - Julian day 
      , first_count                number                           -- alphanumeric, length 15
      , second_count               number                           -- alphanumeric, length 15
      , first_amount               number                           -- alphanumeric, length 15
      , second_amount              number                           -- alphanumeric, length 15
      , third_amount               number                           -- alphanumeric, length 15
      , fourth_amount              number                           -- alphanumeric, length 15
      , fifth_amount               number                           -- alphanumeric, length 15
    );

    type t_vcr_advice_rec is record(
        id                       com_api_type_pkg.t_long_id
      , file_id                  com_api_type_pkg.t_long_id
      , record_number            com_api_type_pkg.t_short_id
      , status                   com_api_type_pkg.t_dict_value 
      , inst_id                  com_api_type_pkg.t_inst_id
      , trans_code               com_api_type_pkg.t_byte_char
      , trans_code_qualifier     varchar2(1)
      , trans_component_seq      varchar2(1)
      , dest_bin                 com_api_type_pkg.t_bin
      , source_bin               com_api_type_pkg.t_bin
      , vcr_record_id            varchar2(3)
      , dispute_status           com_api_type_pkg.t_byte_char
      , dispute_trans_code       com_api_type_pkg.t_byte_char
      , pos_condition_code       com_api_type_pkg.t_byte_char
      , dispute_tc_qualifier     varchar2(1)
      , orig_recipient_ind       varchar2(1)
      , card_number              varchar2(16)
      , card_number_ext          varchar2(3)
      , acq_inst_code            varchar2(11)
      , rrn                      varchar2(12)
      , acq_ref_number           varchar2(23)
      , purchase_date            varchar2(4)
      , source_amount            number(22,4)
      , source_curr_code         varchar2(3)
      , merchant_name            varchar2(25)
      , merchant_city            varchar2(14)
      , merchant_country         varchar2(3)
      , mcc                      varchar2(4)
      , merchant_region_code     varchar2(3)
      , merchant_postal_code     varchar2(10)
      , req_payment_service      varchar2(1)
      , auth_code                varchar2(6)
      , pos_entry_mode           varchar2(2)
      , central_proc_date        varchar2(4)
      , card_acceptor_id         varchar2(16)
      , reimbursement            varchar2(1)
      , network_code             varchar2(4)
      , dispute_condition        varchar2(3)
      , vrol_fin_id              varchar2(11)
      , vrol_case_number         varchar2(10)
      , vrol_bundle_case_num     varchar2(10)
      , client_case_number       varchar2(20)
      , clearing_seq_number      varchar2(2)
      , clearing_seq_count       varchar2(2)
      , product_id               varchar2(2)
      , spend_qualified_ind      varchar2(1)
      
      , dsp_fin_reason_code      varchar2(2)
      , processing_code          varchar2(2) -- ?
      , settlement_flag          varchar2(1)
      , usage_code               varchar2(1)
      , trans_identifier         varchar2(15)
      , acq_business_id          varchar2(8)
      , orig_trans_amount        number(22,4)
      , orig_trans_curr_code     varchar2(3)
      , spec_chargeback_ind      varchar2(1)
      , message_reason_code      number(4)
      , dest_amount              number(22,4)
      , dest_curr_code           varchar2(3)
      , src_sttl_amount_sign     varchar2(1)
    );

    type t_visa_sms1_rec is record(
        id                  com_api_type_pkg.t_long_id --Primary key
      , file_id             com_api_type_pkg.t_long_id
      , record_number       varchar2(6)
      , status              varchar2(8)
      , record_type         varchar2(6)                    -- Record Type (V23200)
      , iss_acq             varchar2(1)                    -- Issuer-Acquirer Indicator
      , isa_ind             varchar2(1)                    -- ISA Indicator. Field 63.21
      , giv_flag            varchar2(1)                    -- GIV Flag. Header Field 9
      , affiliate_bin       varchar2(10)                   -- Affiliate BIN
      , sttl_date           date                           -- Settlement Date
      , val_code            varchar2(4)                    -- Validation Code. Field 62.3
      , refnum              varchar2(12)                   -- Retrieval Reference Number. Field 37
      , trace_num           varchar2(6)                    -- Trace Number. Field 11
      , req_msg_type        varchar2(4)                    -- Request Message Type
      , resp_code           varchar2(2)                    -- Response Code. Field 39
      , proc_code           varchar2(6)                    -- Processing Code. Field 3
      , msg_reason_code     varchar2(4)                    -- Message Reason Code. Field 63.3
      , card_number         com_api_type_pkg.t_card_number -- Card Number. Field 2
      , trxn_ind            varchar2(15)                   -- Transaction Identifier.  Field 62.2
      , sttl_curr_code      com_api_type_pkg.t_curr_code   -- Currency Code Settlement Amount. Field 50
      , sttl_amount         com_api_type_pkg.t_money       -- Settlement Amount. Field 5
      , sttl_sign           varchar2(1)                    -- Settlement Amount Debit/Credit Indicator
      , reserved            varchar2(7)                    -- Reserved. This field was moved to V23210. 
      , spend_qualified_ind varchar2(1)                    -- Spend Qualified Indicator
      , surcharge_amount    com_api_type_pkg.t_money       -- Surcharge_amount
      , surcharge_sign      varchar2(1)                    -- Surcharge Debit/Credit Indicator
      , inst_id             com_api_type_pkg.t_inst_id
    );

    type            t_ammf_rec is record (
        id                         com_api_type_pkg.t_long_id
        , file_id                  com_api_type_pkg.t_long_id
        , req_id                   com_api_type_pkg.t_long_id
        , purchase_date            date
        , source_amount            com_api_type_pkg.t_medium_id
        , source_currency          com_api_type_pkg.t_curr_code
        , reason_code              com_api_type_pkg.t_byte_char
        , national_reimb_fee       com_api_type_pkg.t_medium_id
        , atm_account_sel          com_api_type_pkg.t_dict_value
        , reimb_flag               varchar2(1)
        , fax_number               com_api_type_pkg.t_auth_long_id
        , req_fulfill_method       varchar2(1)
        , used_fulfill_method      varchar2(1)
        , iss_rfc_bin              com_api_type_pkg.t_auth_code
        , iss_rfc_subaddr          varchar2(7)
        , iss_billing_currency     varchar2(3)
        , iss_billing_amount       number(12)
        , transaction_id           com_api_type_pkg.t_merchant_number
        , excluded_trans_id_reason varchar2(1)
        , crs_code                 varchar2(1)
        , multiple_clearing_seqn   varchar2(2)
        , product_code             com_api_type_pkg.t_mcc
        , contact_info             varchar2(25)
        , iss_inst_id              com_api_type_pkg.t_inst_id
        , acq_inst_id              com_api_type_pkg.t_inst_id
    );

    function get_clearing_file_ack_status (
        i_file_id      in com_api_type_pkg.t_long_id    -- vis_file.id
      , i_is_incoming  in com_api_type_pkg.t_boolean    -- vis_file.is_incoming
      , i_is_rejected  in com_api_type_pkg.t_boolean    -- vis_file.is_returned
      , i_status       in com_api_type_pkg.t_dict_value -- prc_session_file.status
    ) return com_api_type_pkg.t_dict_value;

end;
/
