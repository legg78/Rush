create or replace package opr_api_type_pkg as

    type t_oper_rec is record(
        id                                  com_api_type_pkg.t_long_id
        , proc_stage                        com_api_type_pkg.t_dict_value
        , exec_order                        com_api_type_pkg.t_tiny_id
        , session_id                        com_api_type_pkg.t_long_id
        , is_reversal                       com_api_type_pkg.t_boolean
        , original_id                       com_api_type_pkg.t_long_id
        , oper_type                         com_api_type_pkg.t_dict_value
        , oper_reason                       com_api_type_pkg.t_dict_value
        , msg_type                          com_api_type_pkg.t_dict_value
        , status                            com_api_type_pkg.t_dict_value
        , status_reason                     com_api_type_pkg.t_dict_value
        , sttl_type                         com_api_type_pkg.t_dict_value
        , terminal_type                     com_api_type_pkg.t_dict_value
        , acq_inst_bin                      com_api_type_pkg.t_rrn
        , forw_inst_bin                     com_api_type_pkg.t_rrn
        , merchant_number                   com_api_type_pkg.t_merchant_number
        , terminal_number                   com_api_type_pkg.t_terminal_number
        , merchant_name                     com_api_type_pkg.t_name
        , merchant_street                   com_api_type_pkg.t_name
        , merchant_city                     com_api_type_pkg.t_name
        , merchant_region                   com_api_type_pkg.t_name
        , merchant_country                  com_api_type_pkg.t_curr_code
        , merchant_postcode                 com_api_type_pkg.t_name
        , mcc                               com_api_type_pkg.t_mcc
        , originator_refnum                 com_api_type_pkg.t_rrn
        , network_refnum                    com_api_type_pkg.t_rrn
        , oper_count                        com_api_type_pkg.t_long_id
        , oper_request_amount               com_api_type_pkg.t_money
        , oper_amount_algorithm             com_api_type_pkg.t_dict_value
        , oper_amount                       com_api_type_pkg.t_money
        , oper_currency                     com_api_type_pkg.t_curr_code
        , oper_cashback_amount              com_api_type_pkg.t_money
        , oper_replacement_amount           com_api_type_pkg.t_money
        , oper_surcharge_amount             com_api_type_pkg.t_money
        , oper_date                         date
        , host_date                         date
        , unhold_date                       date
        , match_status                      com_api_type_pkg.t_dict_value
        , sttl_amount                       com_api_type_pkg.t_money
        , sttl_currency                     com_api_type_pkg.t_curr_code
        , dispute_id                        com_api_type_pkg.t_long_id
        , payment_order_id                  com_api_type_pkg.t_long_id
        , payment_host_id                   com_api_type_pkg.t_tiny_id
        , forced_processing                 com_api_type_pkg.t_boolean
        , match_id                          com_api_type_pkg.t_long_id
        , proc_mode                         com_api_type_pkg.t_dict_value
        , clearing_sequence_num             com_api_type_pkg.t_tiny_id
        , clearing_sequence_count           com_api_type_pkg.t_tiny_id
        , incom_sess_file_id                com_api_type_pkg.t_long_id
        , sttl_date                         date
        , acq_sttl_date                     date
    );
    type t_oper_tab is table of t_oper_rec index by binary_integer;
    
    type t_oper_part_rec is record(
          oper_id                       com_api_type_pkg.t_long_id
        , participant_type              com_api_type_pkg.t_dict_value
        , client_id_type                com_api_type_pkg.t_dict_value
        , client_id_value               com_api_type_pkg.t_name
        , inst_id                       com_api_type_pkg.t_inst_id
        , network_id                    com_api_type_pkg.t_network_id
        , card_inst_id                  com_api_type_pkg.t_inst_id
        , card_network_id               com_api_type_pkg.t_network_id
        , card_id                       com_api_type_pkg.t_medium_id
        , card_instance_id              com_api_type_pkg.t_medium_id
        , card_type_id                  com_api_type_pkg.t_tiny_id
        , card_number                   com_api_type_pkg.t_card_number
        , card_mask                     com_api_type_pkg.t_card_number
        , card_hash                     com_api_type_pkg.t_medium_id
        , card_seq_number               com_api_type_pkg.t_tiny_id
        , card_expir_date               date
        , card_service_code             com_api_type_pkg.t_country_code
        , card_country                  com_api_type_pkg.t_country_code
        , customer_id                   com_api_type_pkg.t_medium_id
        , contract_id                   com_api_type_pkg.t_medium_id
        , account_id                    com_api_type_pkg.t_account_id
        , account_type                  com_api_type_pkg.t_dict_value
        , account_number                com_api_type_pkg.t_account_number
        , account_amount                com_api_type_pkg.t_money
        , account_currency              com_api_type_pkg.t_curr_code
        , auth_code                     com_api_type_pkg.t_auth_code
        , merchant_id                   com_api_type_pkg.t_short_id
        , terminal_id                   com_api_type_pkg.t_short_id
        , split_hash                    com_api_type_pkg.t_tiny_id
        , acq_inst_id                   com_api_type_pkg.t_inst_id
        , acq_network_id                com_api_type_pkg.t_network_id
        , iss_inst_id                   com_api_type_pkg.t_inst_id
        , iss_network_id                com_api_type_pkg.t_network_id
    );
    type t_oper_part_tab is table of t_oper_part_rec index by binary_integer;
    type t_oper_part_by_type_tab is table of t_oper_part_rec index by com_api_type_pkg.t_dict_value;
    type t_oper_external_rec is record(
         oper_num                           com_api_type_pkg.t_short_id
       , oper_id                            com_api_type_pkg.t_long_id
       , oper_type                          com_api_type_pkg.t_dict_value
       , oper_reason                        com_api_type_pkg.t_dict_value
       , is_reversal                        com_api_type_pkg.t_boolean
       , original_id                        com_api_type_pkg.t_long_id
       , msg_type                           com_api_type_pkg.t_dict_value
       , sttl_type                          com_api_type_pkg.t_dict_value
       , oper_amount                        com_api_type_pkg.t_money
       , oper_currency                      com_api_type_pkg.t_curr_code
       , oper_date                          date
       , host_date                          date
       , unhold_date                        date
       , oper_sttl_date                     date
       , oper_status                        com_api_type_pkg.t_dict_value
       , oper_status_reason                 com_api_type_pkg.t_dict_value
       , terminal_type                      com_api_type_pkg.t_dict_value
       , acq_inst_bin                       com_api_type_pkg.t_bin
       , forw_inst_bin                      com_api_type_pkg.t_bin
       , merchant_number                    com_api_type_pkg.t_merchant_number
       , terminal_number                    com_api_type_pkg.t_terminal_number
       , merchant_name                      com_api_type_pkg.t_name
       , merchant_street                    com_api_type_pkg.t_name
       , merchant_city                      com_api_type_pkg.t_name
       , merchant_region                    com_api_type_pkg.t_region_code
       , merchant_country                   com_api_type_pkg.t_country_code
       , merchant_postcode                  com_api_type_pkg.t_postal_code
       , mcc                                com_api_type_pkg.t_mcc
       , originator_refnum                  com_api_type_pkg.t_name
       , network_refnum                     com_api_type_pkg.t_name
       , match_status                       com_api_type_pkg.t_dict_value
       , dispute_id                         com_api_type_pkg.t_long_id
       , payment_order_id                   com_api_type_pkg.t_long_id
       , payment_host_id                    com_api_type_pkg.t_tiny_id
       , fee_amount                         com_api_type_pkg.t_money
       , fee_currency                       com_api_type_pkg.t_curr_code
       , resp_code                          com_api_type_pkg.t_dict_value
       , proc_type                          com_api_type_pkg.t_dict_value
       , proc_mode                          com_api_type_pkg.t_dict_value
       , bin_amount                         com_api_type_pkg.t_money
       , bin_currency                       com_api_type_pkg.t_curr_code
       , bin_cnvt_rate                      com_api_type_pkg.t_money
       , network_amount                     com_api_type_pkg.t_money
       , network_currency                   com_api_type_pkg.t_curr_code
       , network_cnvt_date                  date
       , network_cnvt_rate                  com_api_type_pkg.t_money
       , account_cnvt_rate                  com_api_type_pkg.t_money
       , transaction_id                     com_api_type_pkg.t_name
       , system_trace_audit_number          com_api_type_pkg.t_auth_code
       , external_auth_id                   com_api_type_pkg.t_attr_name
       , external_orig_id                   com_api_type_pkg.t_attr_name
       , agent_unique_id                    com_api_type_pkg.t_attr_name
       , trace_number                       com_api_type_pkg.t_attr_name
       , orig_msg_type                      com_api_type_pkg.t_dict_value
       , orig_sttl_type                     com_api_type_pkg.t_dict_value
       , orig_oper_amount                   com_api_type_pkg.t_money
       , orig_oper_currency                 com_api_type_pkg.t_curr_code
       , orig_oper_date                     date
       , orig_host_date                     date
       , orig_unhold_date                   date
       , orig_terminal_type                 com_api_type_pkg.t_dict_value
       , orig_acq_inst_bin                  com_api_type_pkg.t_bin
       , orig_forw_inst_bin                 com_api_type_pkg.t_bin
       , orig_originator_refnum             com_api_type_pkg.t_name
       , orig_network_refnum                com_api_type_pkg.t_name
       , orig_bin_amount                    com_api_type_pkg.t_money
       , orig_bin_currency                  com_api_type_pkg.t_curr_code
       , orig_bin_cnvt_rate                 com_api_type_pkg.t_money
       , orig_network_amount                com_api_type_pkg.t_money
       , orig_network_currency              com_api_type_pkg.t_curr_code
       , orig_network_cnvt_date             date
       , orig_network_cnvt_rate             com_api_type_pkg.t_money
       , orig_account_cnvt_rate             com_api_type_pkg.t_money
       , orig_transaction_id                com_api_type_pkg.t_name
       , orig_system_trace_audit_number     com_api_type_pkg.t_auth_code
       , orig_external_auth_id              com_api_type_pkg.t_attr_name
       , orig_external_orig_id              com_api_type_pkg.t_attr_name
       , orig_agent_unique_id               com_api_type_pkg.t_attr_name
       , orig_trace_number                  com_api_type_pkg.t_attr_name
    );
    type t_oper_external_part_rec is record(
         oper_id                        com_api_type_pkg.t_long_id
       , participant_type               com_api_type_pkg.t_dict_value
       , client_id_type                 com_api_type_pkg.t_dict_value
       , client_id_value                com_api_type_pkg.t_name
       , inst_id                        com_api_type_pkg.t_inst_id
       , network_id                     com_api_type_pkg.t_tiny_id
       , card_inst_id                   com_api_type_pkg.t_tiny_id
       , card_network_id                com_api_type_pkg.t_tiny_id
       , card_id                        com_api_type_pkg.t_medium_id
       , card_instance_id               com_api_type_pkg.t_medium_id
       , card_type_id                   com_api_type_pkg.t_tiny_id
       , card_number                    com_api_type_pkg.t_card_number
       , card_mask                      com_api_type_pkg.t_card_number
       , card_hash                      com_api_type_pkg.t_medium_id
       , card_seq_number                com_api_type_pkg.t_tiny_id
       , card_expir_date                date
       , card_service_code              com_api_type_pkg.t_country_code
       , card_country                   com_api_type_pkg.t_country_code
       , customer_id                    com_api_type_pkg.t_medium_id
       , account_id                     com_api_type_pkg.t_medium_id
       , account_type                   com_api_type_pkg.t_dict_value
       , account_number                 com_api_type_pkg.t_account_number
       , account_amount                 com_api_type_pkg.t_money
       , account_currency               com_api_type_pkg.t_curr_code
       , auth_code                      com_api_type_pkg.t_auth_code
       , merchant_id                    com_api_type_pkg.t_short_id
       , terminal_id                    com_api_type_pkg.t_short_id
       , split_hash                     com_api_type_pkg.t_tiny_id
       , debit_entry_impact             com_api_type_pkg.t_sign
       , credit_entry_impact            com_api_type_pkg.t_sign
    );
    type t_oper_external_aggr_rec is record(
         oper_type                      com_api_type_pkg.t_dict_value
       , participant_type               com_api_type_pkg.t_dict_value
       , terminal_type                  com_api_type_pkg.t_dict_value
       , balance_impact                 com_api_type_pkg.t_sign
       , entry_currency                 com_api_type_pkg.t_curr_code
       , amount                         com_api_type_pkg.t_money
    );
    type t_oper_detail_rec is record(
        id           com_api_type_pkg.t_long_id
      , oper_id      com_api_type_pkg.t_long_id
      , entity_type  com_api_type_pkg.t_dict_value
      , object_id    com_api_type_pkg.t_long_id
    );

    type t_oper_external_tab is table of t_oper_external_rec index by binary_integer;
    type t_oper_external_part_tab is table of t_oper_external_part_rec index by binary_integer;
    type t_oper_ext_part_by_type_tab is table of t_oper_external_part_rec index by com_api_type_pkg.t_dict_value;
    type t_oper_external_aggr_tab is table of t_oper_external_aggr_rec index by binary_integer;
    type t_oper_detail_tab is table of t_oper_detail_rec index by binary_integer;
    
end;
/
