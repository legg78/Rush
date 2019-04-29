create or replace package itf_prc_import_pkg as
/*********************************************************
*  Import posting file from SVFE <br />
*  Created by Gerbeev I.(gerbeev@bpc.ru) at 26.09.2018 <br />
*  Module: itf_prc_import_pkg <br />
*  @headcom
**********************************************************/

type t_oper_clearing_rec is record (
    oper_id                           com_api_type_pkg.t_long_id
  , default_inst_id                   com_api_type_pkg.t_inst_id
  , oper_type                         com_api_type_pkg.t_dict_value
  , msg_type                          com_api_type_pkg.t_dict_value
  , sttl_type                         com_api_type_pkg.t_dict_value
  , original_id                       com_api_type_pkg.t_long_id
  , recon_type                        com_api_type_pkg.t_dict_value
  , oper_date                         date
  , host_date                         date
  , oper_count                        com_api_type_pkg.t_long_id
  , oper_amount_value                 com_api_type_pkg.t_money
  , oper_amount_currency              com_api_type_pkg.t_curr_code
  , oper_request_amount_value         com_api_type_pkg.t_money
  , oper_request_amount_currency      com_api_type_pkg.t_curr_code
  , oper_surcharge_amount_value       com_api_type_pkg.t_money
  , oper_surcharge_amount_currency    com_api_type_pkg.t_curr_code
  , oper_cashback_amount_value        com_api_type_pkg.t_money
  , oper_cashback_amount_currency     com_api_type_pkg.t_curr_code
  , sttl_amount_value                 com_api_type_pkg.t_money
  , sttl_amount_currency              com_api_type_pkg.t_curr_code
  , interchange_fee_value             com_api_type_pkg.t_money
  , interchange_fee_currency          com_api_type_pkg.t_curr_code
  , originator_refnum                 com_api_type_pkg.t_rrn
  , network_refnum                    com_api_type_pkg.t_rrn
  , acq_inst_bin                      com_api_type_pkg.t_rrn
  , forw_inst_bin                     com_api_type_pkg.t_rrn
  , oper_reason                       com_api_type_pkg.t_dict_value
  , status                            com_api_type_pkg.t_dict_value
  , status_reason                     com_api_type_pkg.t_dict_value
  , is_reversal                       com_api_type_pkg.t_boolean
  , merchant_number                   com_api_type_pkg.t_merchant_number
  , mcc                               com_api_type_pkg.t_mcc
  , merchant_name                     com_api_type_pkg.t_name
  , merchant_street                   com_api_type_pkg.t_name
  , merchant_city                     com_api_type_pkg.t_name
  , merchant_region                   com_api_type_pkg.t_country_code
  , merchant_country                  com_api_type_pkg.t_country_code
  , merchant_postcode                 com_api_type_pkg.t_postal_code
  , terminal_type                     com_api_type_pkg.t_dict_value
  , terminal_number                   com_api_type_pkg.t_terminal_number
  , sttl_date                         date
  , acq_sttl_date                     date
  , match_status                      com_api_type_pkg.t_dict_value

  , external_auth_id                  com_api_type_pkg.t_attr_name
  , external_orig_id                  com_api_type_pkg.t_attr_name
  , trace_number                      com_api_type_pkg.t_attr_name
  , dispute_id                        com_api_type_pkg.t_long_id

  , payment_order_id                  com_api_type_pkg.t_long_id
  , payment_order_status              com_api_type_pkg.t_dict_value
  , payment_order_number              com_api_type_pkg.t_name
  , purpose_id                        com_api_type_pkg.t_short_id
  , purpose_number                    com_api_type_pkg.t_name
  , payment_order_amount              com_api_type_pkg.t_money
  , payment_order_currency            com_api_type_pkg.t_curr_code
  , payment_date                      date
  , payment_parameters                xmltype
  , payment_order_prty_type           com_api_type_pkg.t_dict_value

  , issuer_prty_type                  com_api_type_pkg.t_dict_value
  , issuer_client_id_type             com_api_type_pkg.t_dict_value
  , issuer_client_id_value            com_api_type_pkg.t_name
  , issuer_card_number                com_api_type_pkg.t_card_number
  , issuer_card_id                    com_api_type_pkg.t_medium_id
  , issuer_card_instance_id           com_api_type_pkg.t_medium_id
  , issuer_card_seq_number            com_api_type_pkg.t_tiny_id
  , issuer_card_expir_date            date
  , issuer_inst_id                    com_api_type_pkg.t_inst_id
  , issuer_network_id                 com_api_type_pkg.t_network_id
  , issuer_auth_code                  com_api_type_pkg.t_auth_code
  , issuer_account_amount             com_api_type_pkg.t_money
  , issuer_account_currency           com_api_type_pkg.t_curr_code
  , issuer_account_number             com_api_type_pkg.t_account_number

  , acquirer_prty_type                com_api_type_pkg.t_dict_value
  , acquirer_client_id_type           com_api_type_pkg.t_dict_value
  , acquirer_client_id_value          com_api_type_pkg.t_name
  , acquirer_card_number              com_api_type_pkg.t_card_number
  , acquirer_card_id                  com_api_type_pkg.t_medium_id
  , acquirer_card_instance_id         com_api_type_pkg.t_medium_id
  , acquirer_card_seq_number          com_api_type_pkg.t_tiny_id
  , acquirer_card_expir_date          date
  , acquirer_inst_id                  com_api_type_pkg.t_inst_id
  , acquirer_network_id               com_api_type_pkg.t_network_id
  , acquirer_auth_code                com_api_type_pkg.t_auth_code
  , acquirer_account_amount           com_api_type_pkg.t_money
  , acquirer_account_currency         com_api_type_pkg.t_curr_code
  , acquirer_account_number           com_api_type_pkg.t_account_number

  , destination_prty_type             com_api_type_pkg.t_dict_value
  , destination_client_id_type        com_api_type_pkg.t_dict_value
  , destination_client_id_value       com_api_type_pkg.t_name
  , destination_card_number           com_api_type_pkg.t_card_number
  , destination_card_id               com_api_type_pkg.t_medium_id
  , destination_card_instance_id      com_api_type_pkg.t_medium_id
  , destination_card_seq_number       com_api_type_pkg.t_tiny_id
  , destination_card_expir_date       date
  , destination_inst_id               com_api_type_pkg.t_inst_id
  , destination_network_id            com_api_type_pkg.t_network_id
  , destination_auth_code             com_api_type_pkg.t_auth_code
  , destination_account_amount        com_api_type_pkg.t_money
  , destination_account_currency      com_api_type_pkg.t_curr_code
  , destination_account_number        com_api_type_pkg.t_account_number

  , aggregator_prty_type              com_api_type_pkg.t_dict_value
  , aggregator_client_id_type         com_api_type_pkg.t_dict_value
  , aggregator_client_id_value        com_api_type_pkg.t_name
  , aggregator_card_number            com_api_type_pkg.t_card_number
  , aggregator_card_id                com_api_type_pkg.t_medium_id
  , aggregator_card_instance_id       com_api_type_pkg.t_medium_id
  , aggregator_card_seq_number        com_api_type_pkg.t_tiny_id
  , aggregator_card_expir_date        date
  , aggregator_inst_id                com_api_type_pkg.t_inst_id
  , aggregator_network_id             com_api_type_pkg.t_network_id
  , aggregator_auth_code              com_api_type_pkg.t_auth_code
  , aggregator_account_amount         com_api_type_pkg.t_money
  , aggregator_account_currency       com_api_type_pkg.t_curr_code
  , aggregator_account_number         com_api_type_pkg.t_account_number

  , srvp_prty_type                    com_api_type_pkg.t_dict_value
  , srvp_client_id_type               com_api_type_pkg.t_dict_value
  , srvp_client_id_value              com_api_type_pkg.t_name
  , srvp_card_number                  com_api_type_pkg.t_card_number
  , srvp_card_id                      com_api_type_pkg.t_medium_id
  , srvp_card_instance_id             com_api_type_pkg.t_medium_id
  , srvp_card_seq_number              com_api_type_pkg.t_tiny_id
  , srvp_card_expir_date              date
  , srvp_inst_id                      com_api_type_pkg.t_inst_id
  , srvp_network_id                   com_api_type_pkg.t_network_id
  , srvp_auth_code                    com_api_type_pkg.t_auth_code
  , srvp_account_amount               com_api_type_pkg.t_money
  , srvp_account_currency             com_api_type_pkg.t_curr_code
  , srvp_account_number               com_api_type_pkg.t_account_number

  , participant                       xmltype

  , payment_order_exists              com_api_type_pkg.t_boolean
  , issuer_exists                     com_api_type_pkg.t_boolean
  , acquirer_exists                   com_api_type_pkg.t_boolean
  , destination_exists                com_api_type_pkg.t_boolean
  , aggregator_exists                 com_api_type_pkg.t_boolean
  , service_provider_exists           com_api_type_pkg.t_boolean
  , incom_sess_file_id                com_api_type_pkg.t_long_id
  , auth_data                         xmltype
  , additional_amount                 xmltype
  , processing_stage                  xmltype
  , flexible_data                     xmltype
);

type t_oper_clearing_tab is table of t_oper_clearing_rec index by binary_integer;

procedure register_operation_batch(
    i_oper_tab              in          oper_clearing_tpt
  , i_auth_data_tab         in          auth_data_tpt
  , i_auth_tag_tab          in          auth_tag_tpt
  , i_import_clear_pan      in          com_api_type_pkg.t_boolean
  , i_oper_status           in          com_api_type_pkg.t_dict_value  default opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
  , i_sttl_date             in          date
  , i_without_checks        in          com_api_type_pkg.t_boolean     default null
  , i_inst_id               in          com_api_type_pkg.t_tiny_id     default null
);

/*
 * Process for loading operations (posting).
 * @param i_import_clear_pan  – if it is FALSE then process expects encoded
 *     PANs (tokens) in incoming file(s) when tokenization is enabled
 *     (this case may take place when Message Bus is capable to handle tokens).
 */
procedure load_operations(
    i_oper_status           in     com_api_type_pkg.t_dict_value       default null
  , i_import_clear_pan      in     com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_splitted_files        in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_merge_reversal        in     com_api_type_pkg.t_dict_value       default aut_api_const_pkg.MERGE_REVERSAL_NO_MERGE
  , i_merge_sttl_type_id    in     com_api_type_pkg.t_short_id         default null
);

/*
 * Process for loading operations (posting) with additional incoming parameters.
 * @param i_import_clear_pan  – if it is FALSE then process expects encoded
 *     PANs (tokens) in incoming file(s) when tokenization is enabled
 *     (this case may take place when Message Bus is capable to handle tokens).
 */
procedure load_operations_extend(
    i_start_date            in     date
  , i_inst_id               in     com_api_type_pkg.t_tiny_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_oper_status           in     com_api_type_pkg.t_dict_value       default null
  , i_import_clear_pan      in     com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_svfe_network          in     com_api_type_pkg.t_tiny_id          default null
  , i_splitted_files        in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
);

procedure before_register_batch(
    i_session_id            in     com_api_type_pkg.t_long_id
  , i_thread_number         in     com_api_type_pkg.t_tiny_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_process_id            in     com_api_type_pkg.t_short_id
  , i_oracle_trace_level    in     com_api_type_pkg.t_tiny_id
  , i_trace_thread_number   in     com_api_type_pkg.t_tiny_id
);

procedure after_register_batch(
    i_session_id            in     com_api_type_pkg.t_long_id
  , i_thread_number         in     com_api_type_pkg.t_tiny_id
);

end itf_prc_import_pkg;
/
