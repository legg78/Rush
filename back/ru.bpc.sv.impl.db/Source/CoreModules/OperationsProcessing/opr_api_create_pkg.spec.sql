create or replace package opr_api_create_pkg is
/************************************************************
 * Provides an API for creating operation. <br />
 * Created by Khougaev A.(khougaev@bpcsv.com)  at 19.03.2010 <br />
 * Module: OPR_API_CREATE_PKG <br />
 * @headcom
 *************************************************************/

function get_id(
    i_host_date                 in      date                                default null
) return com_api_type_pkg.t_long_id;

function get_id(
    i_shift in com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_long_id;

procedure create_operation(
    io_oper_id                  in out  com_api_type_pkg.t_long_id
  , i_session_id                in      com_api_type_pkg.t_long_id          default null
  , i_is_reversal               in      com_api_type_pkg.t_boolean
  , i_original_id               in      com_api_type_pkg.t_long_id          default null
  , i_oper_type                 in      com_api_type_pkg.t_dict_value
  , i_oper_reason               in      com_api_type_pkg.t_dict_value       default null
  , i_msg_type                  in      com_api_type_pkg.t_dict_value
  , i_status                    in      com_api_type_pkg.t_dict_value
  , i_status_reason             in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_type                 in      com_api_type_pkg.t_dict_value
  , i_terminal_type             in      com_api_type_pkg.t_dict_value       default null
  , i_acq_inst_bin              in      com_api_type_pkg.t_rrn              default null
  , i_forw_inst_bin             in      com_api_type_pkg.t_rrn              default null
  , i_merchant_number           in      com_api_type_pkg.t_merchant_number  default null
  , i_terminal_number           in      com_api_type_pkg.t_terminal_number  default null
  , i_merchant_name             in      com_api_type_pkg.t_name             default null
  , i_merchant_street           in      com_api_type_pkg.t_name             default null
  , i_merchant_city             in      com_api_type_pkg.t_name             default null
  , i_merchant_region           in      com_api_type_pkg.t_name             default null
  , i_merchant_country          in      com_api_type_pkg.t_curr_code        default null
  , i_merchant_postcode         in      com_api_type_pkg.t_name             default null
  , i_mcc                       in      com_api_type_pkg.t_mcc              default null
  , i_originator_refnum         in      com_api_type_pkg.t_rrn              default null
  , i_network_refnum            in      com_api_type_pkg.t_rrn              default null
  , i_oper_count                in      com_api_type_pkg.t_long_id          default null
  , i_oper_request_amount       in      com_api_type_pkg.t_money            default null
  , i_oper_amount_algorithm     in      com_api_type_pkg.t_dict_value       default null
  , i_oper_amount               in      com_api_type_pkg.t_money            default null
  , i_oper_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_oper_cashback_amount      in      com_api_type_pkg.t_money            default null
  , i_oper_replacement_amount   in      com_api_type_pkg.t_money            default null
  , i_oper_surcharge_amount     in      com_api_type_pkg.t_money            default null
  , i_oper_date                 in      date                                default null
  , i_host_date                 in      date                                default null
  , i_match_status              in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_amount               in      com_api_type_pkg.t_money            default null
  , i_sttl_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_dispute_id                in      com_api_type_pkg.t_long_id          default null
  , i_payment_order_id          in      com_api_type_pkg.t_long_id          default null
  , i_payment_host_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_forced_processing         in      com_api_type_pkg.t_boolean          default null
  , i_proc_mode                 in      com_api_type_pkg.t_dict_value       default null
  , i_incom_sess_file_id        in      com_api_type_pkg.t_long_id          default null
  , io_participants             in out  nocopy opr_api_type_pkg.t_oper_part_by_type_tab
  , i_sttl_date                 in      date                                default null
  , i_acq_sttl_date             in      date                                default null
);

procedure create_operation (
    io_oper_id                  in out  com_api_type_pkg.t_long_id
  , i_session_id                in      com_api_type_pkg.t_long_id          default null
  , i_is_reversal               in      com_api_type_pkg.t_boolean
  , i_original_id               in      com_api_type_pkg.t_long_id          default null
  , i_oper_type                 in      com_api_type_pkg.t_dict_value
  , i_oper_reason               in      com_api_type_pkg.t_dict_value       default null
  , i_msg_type                  in      com_api_type_pkg.t_dict_value
  , i_status                    in      com_api_type_pkg.t_dict_value
  , i_status_reason             in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_type                 in      com_api_type_pkg.t_dict_value
  , i_terminal_type             in      com_api_type_pkg.t_dict_value       default null
  , i_acq_inst_bin              in      com_api_type_pkg.t_rrn              default null
  , i_forw_inst_bin             in      com_api_type_pkg.t_rrn              default null
  , i_merchant_number           in      com_api_type_pkg.t_merchant_number  default null
  , i_terminal_number           in      com_api_type_pkg.t_terminal_number  default null
  , i_merchant_name             in      com_api_type_pkg.t_name             default null
  , i_merchant_street           in      com_api_type_pkg.t_name             default null
  , i_merchant_city             in      com_api_type_pkg.t_name             default null
  , i_merchant_region           in      com_api_type_pkg.t_name             default null
  , i_merchant_country          in      com_api_type_pkg.t_curr_code        default null
  , i_merchant_postcode         in      com_api_type_pkg.t_name             default null
  , i_mcc                       in      com_api_type_pkg.t_mcc              default null
  , i_originator_refnum         in      com_api_type_pkg.t_rrn              default null
  , i_network_refnum            in      com_api_type_pkg.t_rrn              default null
  , i_oper_count                in      com_api_type_pkg.t_long_id          default null
  , i_oper_request_amount       in      com_api_type_pkg.t_money            default null
  , i_oper_amount_algorithm     in      com_api_type_pkg.t_dict_value       default null
  , i_oper_amount               in      com_api_type_pkg.t_money            default null
  , i_oper_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_oper_cashback_amount      in      com_api_type_pkg.t_money            default null
  , i_oper_replacement_amount   in      com_api_type_pkg.t_money            default null
  , i_oper_surcharge_amount     in      com_api_type_pkg.t_money            default null
  , i_oper_date                 in      date                                default null
  , i_host_date                 in      date                                default null
  , i_match_status              in      com_api_type_pkg.t_dict_value       default null
  , i_sttl_amount               in      com_api_type_pkg.t_money            default null
  , i_sttl_currency             in      com_api_type_pkg.t_curr_code        default null
  , i_dispute_id                in      com_api_type_pkg.t_long_id          default null
  , i_payment_order_id          in      com_api_type_pkg.t_long_id          default null
  , i_payment_host_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_forced_processing         in      com_api_type_pkg.t_boolean          default null
  , i_proc_mode                 in      com_api_type_pkg.t_dict_value       default null
  , i_clearing_sequence_num     in      com_api_type_pkg.t_tiny_id          default null
  , i_clearing_sequence_count   in      com_api_type_pkg.t_tiny_id          default null
  , i_incom_sess_file_id        in      com_api_type_pkg.t_long_id          default null
  , i_fee_amount                in      com_api_type_pkg.t_money            default null
  , i_fee_currency              in      com_api_type_pkg.t_curr_code        default null
  , i_sttl_date                 in      date                                default null
  , i_acq_sttl_date             in      date                                default null
  , i_match_id                  in      com_api_type_pkg.t_long_id          default null
);

procedure add_participant(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value           default null
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date                                    default null
  , i_client_id_type        in      com_api_type_pkg.t_dict_value           default null
  , i_client_id_value       in      com_api_type_pkg.t_name                 default null
  , io_inst_id              in out  com_api_type_pkg.t_inst_id
  , io_network_id           in out  com_api_type_pkg.t_network_id
  , o_host_id                  out  com_api_type_pkg.t_tiny_id
  , io_card_inst_id         in out  com_api_type_pkg.t_inst_id
  , io_card_network_id      in out  com_api_type_pkg.t_network_id
  , io_card_id              in out  com_api_type_pkg.t_medium_id
  , o_card_instance_id         out  com_api_type_pkg.t_medium_id
  , io_card_type_id         in out  com_api_type_pkg.t_tiny_id
  , i_card_number           in      com_api_type_pkg.t_card_number          default null
  , io_card_mask            in out  com_api_type_pkg.t_card_number
  , io_card_hash            in out  com_api_type_pkg.t_medium_id
  , io_card_seq_number      in out  com_api_type_pkg.t_tiny_id
  , io_card_expir_date      in out  date
  , io_card_service_code    in out  com_api_type_pkg.t_country_code
  , io_card_country         in out  com_api_type_pkg.t_country_code
  , io_customer_id          in out  com_api_type_pkg.t_medium_id
  , io_account_id           in out  com_api_type_pkg.t_account_id
  , i_account_type          in      com_api_type_pkg.t_dict_value           default null
  , i_account_number        in      com_api_type_pkg.t_account_number       default null
  , i_account_amount        in      com_api_type_pkg.t_money                default null
  , i_account_currency      in      com_api_type_pkg.t_curr_code            default null
  , i_auth_code             in      com_api_type_pkg.t_auth_code            default null
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number      default null
  , io_merchant_id          in out  com_api_type_pkg.t_short_id
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number      default null
  , io_terminal_id          in out  com_api_type_pkg.t_short_id
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , i_without_checks        in      com_api_type_pkg.t_boolean              default null
  , io_payment_host_id      in out  com_api_type_pkg.t_tiny_id
  , i_payment_order_id      in      com_api_type_pkg.t_long_id              default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id              default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id           default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code            default null
  , i_terminal_type         in      com_api_type_pkg.t_dict_value           default null
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name            default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name            default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name            default null
  , i_mask_error            in      com_api_type_pkg.t_boolean              default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean              default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn                  default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id              default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id           default null
  , i_sttl_type             in      com_api_type_pkg.t_dict_value           default null
  , i_fast_oper_stage       in      com_api_type_pkg.t_boolean              default com_api_type_pkg.FALSE
  , i_oper_date             in      date                                default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn              default null
);

procedure add_participant(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value           default null
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date                                    default null
  , i_client_id_type        in      com_api_type_pkg.t_dict_value           default null
  , i_client_id_value       in      com_api_type_pkg.t_name                 default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id              default null
  , i_network_id            in      com_api_type_pkg.t_network_id           default null
  , i_card_inst_id          in      com_api_type_pkg.t_inst_id              default null
  , i_card_network_id       in      com_api_type_pkg.t_network_id           default null
  , i_card_id               in      com_api_type_pkg.t_medium_id            default null
  , i_card_instance_id      in      com_api_type_pkg.t_medium_id            default null
  , i_card_type_id          in      com_api_type_pkg.t_tiny_id              default null
  , i_card_number           in      com_api_type_pkg.t_card_number          default null
  , i_card_mask             in      com_api_type_pkg.t_card_number          default null
  , i_card_hash             in      com_api_type_pkg.t_medium_id            default null
  , i_card_seq_number       in      com_api_type_pkg.t_tiny_id              default null
  , i_card_expir_date       in      date                                    default null
  , i_card_service_code     in      com_api_type_pkg.t_country_code         default null
  , i_card_country          in      com_api_type_pkg.t_country_code         default null
  , i_customer_id           in      com_api_type_pkg.t_medium_id            default null
  , i_account_id            in      com_api_type_pkg.t_account_id           default null
  , i_account_type          in      com_api_type_pkg.t_dict_value           default null
  , i_account_number        in      com_api_type_pkg.t_account_number       default null
  , i_account_amount        in      com_api_type_pkg.t_money                default null
  , i_account_currency      in      com_api_type_pkg.t_curr_code            default null
  , i_auth_code             in      com_api_type_pkg.t_auth_code            default null
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number      default null
  , i_merchant_id           in      com_api_type_pkg.t_short_id             default null
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number      default null
  , i_terminal_id           in      com_api_type_pkg.t_short_id             default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id              default null
  , i_without_checks        in      com_api_type_pkg.t_boolean              default null
  , i_payment_host_id       in      com_api_type_pkg.t_tiny_id              default null
  , i_payment_order_id      in      com_api_type_pkg.t_long_id              default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id              default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id           default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code            default null
  , i_terminal_type         in      com_api_type_pkg.t_dict_value           default null
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name            default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name            default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name            default null
  , i_mask_error            in      com_api_type_pkg.t_boolean              default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean              default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn                  default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id              default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id           default null
  , i_oper_date             in      date                                default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn              default null
);

procedure perform_checks(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value
  , i_party_type            in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date
  , io_network_id           in out  com_api_type_pkg.t_tiny_id
  , io_inst_id              in out  com_api_type_pkg.t_inst_id
  , io_client_id_type       in out  com_api_type_pkg.t_dict_value
  , io_client_id_value      in out  com_api_type_pkg.t_name
  , io_card_number          in out  com_api_type_pkg.t_card_number
  , io_card_inst_id         in out  com_api_type_pkg.t_inst_id
  , io_card_network_id      in out  com_api_type_pkg.t_network_id
  , o_card_id                  out  com_api_type_pkg.t_medium_id
  , o_card_instance_id         out  com_api_type_pkg.t_medium_id
  , io_card_type_id         in out  com_api_type_pkg.t_tiny_id
  , io_card_mask            in out  com_api_type_pkg.t_card_number
  , io_card_hash            in out  com_api_type_pkg.t_medium_id
  , io_card_seq_number      in out  com_api_type_pkg.t_tiny_id
  , io_card_expir_date      in out  date
  , io_card_service_code    in out  com_api_type_pkg.t_country_code
  , io_card_country         in out  com_api_type_pkg.t_country_code
  , i_account_number        in      com_api_type_pkg.t_account_number
  , io_account_id           in out  com_api_type_pkg.t_medium_id
  , io_customer_id          in out  com_api_type_pkg.t_medium_id
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , io_merchant_id          in out  com_api_type_pkg.t_short_id
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , io_terminal_id          in out  com_api_type_pkg.t_short_id
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name            default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name            default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name            default null
  , i_mask_error            in      com_api_type_pkg.t_boolean              default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean              default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id              default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id           default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code            default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn                  default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id              default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id           default null
  , i_oper_date             in      date                                    default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn                  default null
);

procedure create_operation (
    i_oper                  in      opr_api_type_pkg.t_oper_rec
  , i_iss_part              in      opr_api_type_pkg.t_oper_part_rec
  , i_acq_part              in      opr_api_type_pkg.t_oper_part_rec
);

procedure add_participant(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value       default null
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_host_date             in      date                                default null
  , i_client_id_type        in      com_api_type_pkg.t_dict_value       default null
  , i_client_id_value       in      com_api_type_pkg.t_name             default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id          default null
  , i_network_id            in      com_api_type_pkg.t_network_id       default null
  , i_card_inst_id          in      com_api_type_pkg.t_inst_id          default null
  , i_card_network_id       in      com_api_type_pkg.t_network_id       default null
  , i_card_id               in      com_api_type_pkg.t_medium_id        default null
  , i_card_instance_id      in      com_api_type_pkg.t_medium_id        default null
  , i_card_type_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_card_number           in      com_api_type_pkg.t_card_number      default null
  , i_card_mask             in      com_api_type_pkg.t_card_number      default null
  , i_card_hash             in      com_api_type_pkg.t_medium_id        default null
  , i_card_seq_number       in      com_api_type_pkg.t_tiny_id          default null
  , i_card_expir_date       in      date                                default null
  , i_card_service_code     in      com_api_type_pkg.t_country_code     default null
  , i_card_country          in      com_api_type_pkg.t_country_code     default null
  , i_customer_id           in      com_api_type_pkg.t_medium_id        default null
  , i_account_id            in      com_api_type_pkg.t_account_id       default null
  , i_account_type          in      com_api_type_pkg.t_dict_value       default null
  , i_account_number        in      com_api_type_pkg.t_account_number   default null
  , i_account_amount        in      com_api_type_pkg.t_money            default null
  , i_account_currency      in      com_api_type_pkg.t_curr_code        default null
  , i_auth_code             in      com_api_type_pkg.t_auth_code        default null
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number  default null
  , i_merchant_id           in      com_api_type_pkg.t_short_id         default null
  , i_terminal_number       in      com_api_type_pkg.t_terminal_number  default null
  , i_terminal_id           in      com_api_type_pkg.t_short_id         default null
  , o_split_hash            out     com_api_type_pkg.t_tiny_id
  , i_without_checks        in      com_api_type_pkg.t_boolean          default null
  , i_payment_host_id       in      com_api_type_pkg.t_tiny_id          default null
  , i_payment_order_id      in      com_api_type_pkg.t_long_id          default null
  , i_acq_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_acq_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_currency         in      com_api_type_pkg.t_curr_code        default null
  , i_terminal_type         in      com_api_type_pkg.t_dict_value       default null
  , i_external_auth_id      in      com_api_type_pkg.t_attr_name        default null
  , i_external_orig_id      in      com_api_type_pkg.t_attr_name        default null
  , i_trace_number          in      com_api_type_pkg.t_attr_name        default null
  , i_mask_error            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_is_reversal           in      com_api_type_pkg.t_boolean          default null
  , i_acq_inst_bin          in      com_api_type_pkg.t_rrn              default null
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_iss_network_id        in      com_api_type_pkg.t_network_id       default null
  , i_oper_date             in      date                                default null
  , i_originator_refnum     in      com_api_type_pkg.t_rrn              default null
);

procedure set_oper_stage(
    i_oper_id               in      com_api_type_pkg.t_long_id      default null
  , i_external_auth_id      in      com_api_type_pkg.t_name         default null
  , i_is_reversal           in      com_api_type_pkg.t_boolean      default null
  , i_command               in      com_api_type_pkg.t_dict_value
);

function participant_needed(
    i_oper_type             in      com_api_type_pkg.t_dict_value
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_oper_reason           in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

end opr_api_create_pkg;
/

