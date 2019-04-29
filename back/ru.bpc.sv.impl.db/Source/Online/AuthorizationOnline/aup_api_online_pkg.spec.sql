create or replace package aup_api_online_pkg is
/************************************************************
* Authorization Online API <br />
* Created by Khougaev A.(khougaev@bpc.ru)  at 08.10.2010  <br />
* Module: AUP_API_ONLINE_PKG <br />
* @headcom
************************************************************/

procedure get_member_info(
    i_originator_inst_id        in     com_api_type_pkg.t_inst_id
  , i_destination_network_id    in     com_api_type_pkg.t_tiny_id
  , i_destination_inst_id       in     com_api_type_pkg.t_inst_id
  , i_participant_type          in     com_api_type_pkg.t_dict_value default null
  , o_originator_member_id         out com_api_type_pkg.t_tiny_id
  , o_destination_member_id        out com_api_type_pkg.t_tiny_id
);

function put_auth (
    i_id                        in     com_api_type_pkg.t_long_id
    , o_scenario_id                out com_api_type_pkg.t_tiny_id
    , o_split_hash                 out com_api_type_pkg.t_tiny_id
    , i_is_reversal             in     com_api_type_pkg.t_boolean := null
    , i_original_id             in     com_api_type_pkg.t_long_id := null
    , i_parent_id               in     com_api_type_pkg.t_long_id := null
    , i_msg_type                in     com_api_type_pkg.t_dict_value := null
    , i_oper_type               in     com_api_type_pkg.t_dict_value := null
    , o_sttl_type                  out com_api_type_pkg.t_dict_value
    , i_is_advice               in     com_api_type_pkg.t_boolean := null
    , i_is_repeat               in     com_api_type_pkg.t_boolean := null
    , i_host_date               in     date := null
    , i_oper_date               in     date := null
    , i_oper_count              in     com_api_type_pkg.t_short_id := null
    , i_oper_request_amount     in     com_api_type_pkg.t_money := null
    , i_oper_amount_algorithm   in     com_api_type_pkg.t_dict_value := null
    , i_oper_amount             in     com_api_type_pkg.t_money := null
    , i_oper_currency           in     com_api_type_pkg.t_curr_code := null
    , i_oper_cashback_amount    in     com_api_type_pkg.t_money := null
    , i_oper_replacement_amount in     com_api_type_pkg.t_money := null
    , i_oper_surcharge_amount   in     com_api_type_pkg.t_money := null
    , i_client_id_type          in     com_api_type_pkg.t_dict_value := null
    , i_client_id_value         in     com_api_type_pkg.t_name := null
    , o_iss_inst_id                out com_api_type_pkg.t_inst_id
    , o_iss_network_id             out com_api_type_pkg.t_network_id
    , o_iss_host_id                out com_api_type_pkg.t_tiny_id
    , i_iss_network_device_id   in     com_api_type_pkg.t_short_id := null
    , o_split_hash_iss             out com_api_type_pkg.t_tiny_id
    , o_card_inst_id               out com_api_type_pkg.t_inst_id
    , o_card_network_id            out com_api_type_pkg.t_network_id
    , i_card_number             in     com_api_type_pkg.t_card_number := null
    , o_card_id                    out com_api_type_pkg.t_medium_id
    , o_card_instance_id           out com_api_type_pkg.t_medium_id
    , o_card_type_id               out com_api_type_pkg.t_tiny_id
    , o_card_mask                  out com_api_type_pkg.t_card_number
    , o_card_hash                  out com_api_type_pkg.t_medium_id
    , io_card_seq_number        in out com_api_type_pkg.t_tiny_id
    , io_card_expir_date        in out date
    , io_card_service_code      in out com_api_type_pkg.t_curr_code
    , o_card_country               out com_api_type_pkg.t_country_code
    , o_pan_length                 out com_api_type_pkg.t_tiny_id
    , o_pvv_tab                    out com_api_type_pkg.t_number_tab
    , o_pin_verify_method          out com_api_type_pkg.t_dict_value
    , o_pvk_index_tab              out com_api_type_pkg.t_number_tab
    , o_customer_id                out com_api_type_pkg.t_medium_id
    , o_account_id                 out com_api_type_pkg.t_medium_id
    , i_account_type            in     com_api_type_pkg.t_dict_value := null
    , i_account_number          in     com_api_type_pkg.t_account_number := null
    , i_account_amount          in     com_api_type_pkg.t_money := null
    , i_account_currency        in     com_api_type_pkg.t_curr_code := null
    , i_account_cnvt_rate       in     com_api_type_pkg.t_money := null
    , i_bin_amount              in     com_api_type_pkg.t_money := null
    , i_bin_currency            in     com_api_type_pkg.t_curr_code := null
    , i_bin_cnvt_rate           in     com_api_type_pkg.t_money := null
    , i_network_amount          in     com_api_type_pkg.t_money := null
    , i_network_currency        in     com_api_type_pkg.t_curr_code := null
    , i_network_cnvt_date       in     date := null
    , i_network_cnvt_rate       in     com_api_type_pkg.t_money := null
    , i_addr_verif_result       in     com_api_type_pkg.t_dict_value := null
    , o_address_verify_algo        out com_api_type_pkg.t_dict_value
    , o_address_verify_string      out com_api_type_pkg.t_name
    , o_address_verify_zip         out com_api_type_pkg.t_postal_code
    , i_auth_code               in     com_api_type_pkg.t_auth_code := null
    , i_dst_client_id_type      in     com_api_type_pkg.t_dict_value := null
    , i_dst_client_id_value     in     com_api_type_pkg.t_name := null
    , o_dst_inst_id                out com_api_type_pkg.t_inst_id
    , o_dst_network_id             out com_api_type_pkg.t_network_id
    , o_dst_card_inst_id           out com_api_type_pkg.t_inst_id
    , o_dst_card_network_id        out com_api_type_pkg.t_network_id
    , i_dst_card_number         in     com_api_type_pkg.t_card_number := null
    , o_dst_card_id                out com_api_type_pkg.t_medium_id
    , o_dst_card_instance_id       out com_api_type_pkg.t_medium_id
    , o_dst_card_type_id           out com_api_type_pkg.t_tiny_id
    , o_dst_card_mask              out com_api_type_pkg.t_card_number
    , o_dst_card_hash              out com_api_type_pkg.t_medium_id
    , io_dst_card_seq_number    in out com_api_type_pkg.t_tiny_id
    , io_dst_card_expir_date    in out date
    , io_dst_card_service_code  in out com_api_type_pkg.t_curr_code
    , o_dst_card_country           out com_api_type_pkg.t_country_code
    , o_dst_customer_id            out com_api_type_pkg.t_medium_id
    , o_dst_account_id             out com_api_type_pkg.t_medium_id
    , i_dst_account_type        in     com_api_type_pkg.t_dict_value := null
    , i_dst_account_number      in     com_api_type_pkg.t_account_number := null
    , i_dst_account_amount      in     com_api_type_pkg.t_money := null
    , i_dst_account_currency    in     com_api_type_pkg.t_curr_code := null
    , i_dst_auth_code           in     com_api_type_pkg.t_auth_code := null
    , i_acq_device_id           in     com_api_type_pkg.t_short_id := null
    , i_acq_resp_code           in     com_api_type_pkg.t_dict_value := null
    , i_acq_device_proc_result  in     com_api_type_pkg.t_dict_value := null
    , i_acq_inst_bin            in     com_api_type_pkg.t_cmid := null
    , i_forw_inst_bin           in     com_api_type_pkg.t_cmid := null
    , i_acq_inst_id             in     com_api_type_pkg.t_inst_id := null
    , io_acq_network_id         in out com_api_type_pkg.t_network_id
    , o_split_hash_acq             out com_api_type_pkg.t_tiny_id
    , o_acq_member_id              out com_api_type_pkg.t_short_id
    , io_merchant_id            in out com_api_type_pkg.t_short_id
    , i_merchant_number         in     com_api_type_pkg.t_merchant_number := null
    , i_terminal_type           in     com_api_type_pkg.t_dict_value := null
    , i_terminal_number         in     com_api_type_pkg.t_terminal_number := null
    , io_terminal_id            in out com_api_type_pkg.t_short_id
    , i_merchant_name           in     com_api_type_pkg.t_name := null
    , i_merchant_street         in     com_api_type_pkg.t_name := null
    , i_merchant_city           in     com_api_type_pkg.t_name := null
    , i_merchant_region         in     com_api_type_pkg.t_module_code := null
    , i_merchant_country        in     com_api_type_pkg.t_country_code := null
    , i_merchant_postcode       in     com_api_type_pkg.t_postal_code := null
    , i_cat_level               in     com_api_type_pkg.t_dict_value := null
    , i_mcc                     in     com_api_type_pkg.t_mcc := null
    , i_originator_refnum       in     com_api_type_pkg.t_rrn := null
    , i_network_refnum          in     com_api_type_pkg.t_rrn := null
    , i_card_data_input_cap     in     com_api_type_pkg.t_dict_value := null
    , i_crdh_auth_cap           in     com_api_type_pkg.t_dict_value := null
    , i_card_capture_cap        in     com_api_type_pkg.t_dict_value := null
    , i_terminal_operating_env  in     com_api_type_pkg.t_dict_value := null
    , i_crdh_presence           in     com_api_type_pkg.t_dict_value := null
    , i_card_presence           in     com_api_type_pkg.t_dict_value := null
    , i_card_data_input_mode    in     com_api_type_pkg.t_dict_value := null
    , i_crdh_auth_method        in     com_api_type_pkg.t_dict_value := null
    , i_crdh_auth_entity        in     com_api_type_pkg.t_dict_value := null
    , i_card_data_output_cap    in     com_api_type_pkg.t_dict_value := null
    , i_terminal_output_cap     in     com_api_type_pkg.t_dict_value := null
    , i_pin_capture_cap         in     com_api_type_pkg.t_dict_value := null
    , i_pin_presence            in     com_api_type_pkg.t_dict_value := null
    , i_cvv2_presence           in     com_api_type_pkg.t_dict_value := null
    , i_cvc_indicator           in     com_api_type_pkg.t_dict_value := null
    , i_pos_entry_mode          in     com_api_type_pkg.t_module_code := null
    , i_pos_cond_code           in     com_api_type_pkg.t_module_code := null
    , i_emv_data                in     com_api_type_pkg.t_param_value := null
    , io_atc                    in out com_api_type_pkg.t_dict_value
    , i_tvr                     in     com_api_type_pkg.t_param_value := null
    , i_cvr                     in     com_api_type_pkg.t_param_value := null
    , i_addl_data               in     com_api_type_pkg.t_param_value := null
    , i_service_code            in     com_api_type_pkg.t_dict_value := null
    , i_device_date             in     date := null
    , i_certificate_method      in     com_api_type_pkg.t_dict_value := null
    , i_certificate_type        in     com_api_type_pkg.t_dict_value := null
    , i_merchant_certif         in     com_api_type_pkg.t_name := null
    , i_cardholder_certif       in     com_api_type_pkg.t_name := null
    , i_ucaf_indicator          in     com_api_type_pkg.t_dict_value := null
    , i_is_early_emv            in     com_api_type_pkg.t_boolean := null
    , i_payment_order_id        in     com_api_type_pkg.t_long_id := null
    , i_payment_host_id         in     com_api_type_pkg.t_tiny_id := null
    , i_payment_purpose_id      in     com_api_type_pkg.t_short_id := null
    , i_discr_data              in     com_api_type_pkg.t_name := null
    , o_cvv                        out com_api_type_pkg.t_module_code
    , o_emv_scheme_id              out com_api_type_pkg.t_dict_value
    , i_oper_reason             in     com_api_type_pkg.t_dict_value := null
    , i_tags                    in     aup_api_type_pkg.t_aup_tag_tab
    , o_cvv2_date_format           out com_api_type_pkg.t_dict_value
    , i_amounts                 in     com_api_type_pkg.t_raw_data := null
    , i_cavv_presence           in     com_api_type_pkg.t_dict_value := null
    , i_aav_presence            in     com_api_type_pkg.t_dict_value := null
    , i_transaction_id          in     com_api_type_pkg.t_auth_long_id default null
    , i_discr_type              in     com_api_type_pkg.t_short_id := null
    , o_un_placeholder             out com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value;

function update_auth (
    i_id                      in     com_api_type_pkg.t_long_id
  , i_network_refnum          in     com_api_type_pkg.t_rrn := null
  , i_payment_order_id        in     com_api_type_pkg.t_long_id := null
  , i_payment_host_id         in     com_api_type_pkg.t_tiny_id := null
  , i_auth_code               in     com_api_type_pkg.t_auth_code := null
  , i_oper_request_amount     in     com_api_type_pkg.t_money := null
  , i_oper_amount             in     com_api_type_pkg.t_money := null
  , i_oper_currency           in     com_api_type_pkg.t_curr_code := null
  , i_account_number          in     com_api_type_pkg.t_account_number := null
  , i_account_amount          in     com_api_type_pkg.t_money := null
  , i_account_currency        in     com_api_type_pkg.t_curr_code := null
  , i_network_amount          in     com_api_type_pkg.t_money := null
  , i_network_currency        in     com_api_type_pkg.t_curr_code := null
  , i_network_cnvt_date       in     date := null
  , i_addr_verif_result       in     com_api_type_pkg.t_dict_value := null
  , i_acq_device_proc_result  in     com_api_type_pkg.t_dict_value := null
  , i_acq_resp_code           in     com_api_type_pkg.t_dict_value := null
  , i_dst_card_number         in     com_api_type_pkg.t_card_number := null
  , i_dst_card_expir_date     in     date := null
  , i_dst_account_type        in     com_api_type_pkg.t_dict_value := null
  , i_dst_account_number      in     com_api_type_pkg.t_account_number := null
  , i_dst_client_id_type      in     com_api_type_pkg.t_dict_value := null
  , i_dst_client_id_value     in     com_api_type_pkg.t_name := null
  , i_dst_auth_code           in     com_api_type_pkg.t_auth_code := null
  , i_emv_script_status       in     com_api_type_pkg.t_dict_value := null
  , i_tags                    in     aup_api_type_pkg.t_aup_tag_tab
  , i_mcc                     in     com_api_type_pkg.t_mcc := null
  , i_merchant_name           in     com_api_type_pkg.t_name := null
  , i_amounts                 in     com_api_type_pkg.t_raw_data := null
  , i_cvr                     in     com_api_type_pkg.t_param_value := null
  , i_resp_code               in     com_api_type_pkg.t_dict_value := null
  , i_transaction_id          in     com_api_type_pkg.t_auth_long_id default null
) return com_api_type_pkg.t_dict_value;

procedure get_card_keys (
    i_card_instance_id          in com_api_type_pkg.t_medium_id
    , o_des_keys                out com_api_type_pkg.t_des_key_tab
    , o_hmac_keys               out com_api_type_pkg.t_hmac_key_tab
);

procedure get_card_auths (
    i_id                        in com_api_type_pkg.t_long_id default null
    , i_card_id                 in com_api_type_pkg.t_medium_id
    , i_limit                   in com_api_type_pkg.t_tiny_id
    , i_null_amounts            in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
    , o_auth_tab                out aup_api_type_pkg.t_auth_stmt_tab
);

procedure get_account_auths (
  i_id                        in com_api_type_pkg.t_long_id default null
  , i_account_id            in      com_api_type_pkg.t_account_id
  , i_limit                 in      com_api_type_pkg.t_tiny_id
  , i_null_amounts          in      com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
  , o_auth_tab              out     aup_api_type_pkg.t_auth_stmt_tab
);

function finalize (
    i_id                 in     com_api_type_pkg.t_long_id
  , i_oper_type          in     com_api_type_pkg.t_dict_value
  , i_msg_type           in     com_api_type_pkg.t_dict_value
  , i_is_reversal        in     com_api_type_pkg.t_boolean
  , i_resp_code          in     com_api_type_pkg.t_dict_value
  , i_is_completed       in     com_api_type_pkg.t_dict_value
  , i_auth_code          in     com_api_type_pkg.t_auth_code
  , i_payment_order_id   in     com_api_type_pkg.t_long_id    default null
  , i_payment_host_id    in     com_api_type_pkg.t_tiny_id    default null
  , i_cvv2_result        in     com_api_type_pkg.t_dict_value default null
  , i_sttl_type          in     com_api_type_pkg.t_dict_value default null
  , i_oper_reason        in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_dict_value;

function find_auth (
    i_parent_id                 in com_api_type_pkg.t_long_id
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , o_id                      out com_api_type_pkg.t_long_id
    , o_split_hash              out com_api_type_pkg.t_tiny_id
    , o_is_reversal             out com_api_type_pkg.t_boolean
    , o_original_id             out com_api_type_pkg.t_long_id
    , o_msg_type                out com_api_type_pkg.t_dict_value
    , o_sttl_type               out com_api_type_pkg.t_dict_value
    , o_is_advice               out com_api_type_pkg.t_boolean
    , o_is_repeat               out com_api_type_pkg.t_boolean
    , o_host_date               out date
    , o_oper_date               out date
    , o_oper_count              out com_api_type_pkg.t_short_id
    , o_oper_request_amount     out com_api_type_pkg.t_money
    , o_oper_amount_algorithm   out com_api_type_pkg.t_dict_value
    , o_oper_amount             out com_api_type_pkg.t_money
    , o_oper_currency           out com_api_type_pkg.t_curr_code
    , o_oper_cashback_amount    out com_api_type_pkg.t_money
    , o_oper_replacement_amount out com_api_type_pkg.t_money
    , o_oper_surcharge_amount   out com_api_type_pkg.t_money
    , o_client_id_type          out com_api_type_pkg.t_dict_value
    , o_client_id_value         out com_api_type_pkg.t_name
    , o_iss_inst_id             out com_api_type_pkg.t_inst_id
    , o_iss_network_id          out com_api_type_pkg.t_network_id
    , o_iss_host_id             out com_api_type_pkg.t_tiny_id
    , o_iss_network_device_id   out com_api_type_pkg.t_short_id
    , o_split_hash_iss          out com_api_type_pkg.t_tiny_id
    , o_card_inst_id            out com_api_type_pkg.t_inst_id
    , o_card_network_id         out com_api_type_pkg.t_network_id
    , o_card_number             out com_api_type_pkg.t_card_number
    , o_card_id                 out com_api_type_pkg.t_medium_id
    , o_card_instance_id        out com_api_type_pkg.t_medium_id
    , o_card_type_id            out com_api_type_pkg.t_tiny_id
    , o_card_mask               out com_api_type_pkg.t_card_number
    , o_card_hash               out com_api_type_pkg.t_medium_id
    , o_card_seq_number         out com_api_type_pkg.t_tiny_id
    , o_card_expir_date         out date
    , o_card_service_code       out com_api_type_pkg.t_curr_code
    , o_card_country            out com_api_type_pkg.t_country_code
    , o_customer_id             out com_api_type_pkg.t_medium_id
    , o_account_id              out com_api_type_pkg.t_medium_id
    , o_account_type            out com_api_type_pkg.t_dict_value
    , o_account_number          out com_api_type_pkg.t_account_number
    , o_account_amount          out com_api_type_pkg.t_money
    , o_account_currency        out com_api_type_pkg.t_curr_code
    , o_account_cnvt_rate       out com_api_type_pkg.t_money
    , o_bin_amount              out com_api_type_pkg.t_money
    , o_bin_currency            out com_api_type_pkg.t_curr_code
    , o_bin_cnvt_rate           out com_api_type_pkg.t_money
    , o_network_amount          out com_api_type_pkg.t_money
    , o_network_currency        out com_api_type_pkg.t_curr_code
    , o_network_cnvt_date       out date
    , o_network_cnvt_rate       out com_api_type_pkg.t_money
    , o_addr_verif_result       out com_api_type_pkg.t_dict_value
    , o_auth_code               out com_api_type_pkg.t_auth_code
    , o_dst_client_id_type      out com_api_type_pkg.t_dict_value
    , o_dst_client_id_value     out com_api_type_pkg.t_name
    , o_dst_inst_id             out com_api_type_pkg.t_inst_id
    , o_dst_network_id          out com_api_type_pkg.t_network_id
    , o_dst_card_inst_id        out com_api_type_pkg.t_inst_id
    , o_dst_card_network_id     out com_api_type_pkg.t_network_id
    , o_dst_card_number         out com_api_type_pkg.t_card_number
    , o_dst_card_id             out com_api_type_pkg.t_medium_id
    , o_dst_card_instance_id    out com_api_type_pkg.t_medium_id
    , o_dst_card_type_id        out com_api_type_pkg.t_tiny_id
    , o_dst_card_mask           out com_api_type_pkg.t_card_number
    , o_dst_card_hash           out com_api_type_pkg.t_medium_id
    , o_dst_card_seq_number     out com_api_type_pkg.t_tiny_id
    , o_dst_card_expir_date     out date
    , o_dst_card_service_code   out com_api_type_pkg.t_curr_code
    , o_dst_card_country        out com_api_type_pkg.t_country_code
    , o_dst_customer_id         out com_api_type_pkg.t_medium_id
    , o_dst_account_id          out com_api_type_pkg.t_medium_id
    , o_dst_account_type        out com_api_type_pkg.t_dict_value
    , o_dst_account_number      out com_api_type_pkg.t_account_number
    , o_dst_account_amount      out com_api_type_pkg.t_money
    , o_dst_account_currency    out com_api_type_pkg.t_curr_code
    , o_dst_auth_code           out com_api_type_pkg.t_auth_code
    , o_acq_device_id           out com_api_type_pkg.t_short_id
    , o_acq_resp_code           out com_api_type_pkg.t_dict_value
    , o_acq_device_proc_result  out com_api_type_pkg.t_dict_value
    , o_acq_inst_bin            out com_api_type_pkg.t_cmid
    , o_forw_inst_bin           out com_api_type_pkg.t_cmid
    , o_acq_inst_id             out com_api_type_pkg.t_inst_id
    , o_acq_network_id          out com_api_type_pkg.t_network_id
    , o_split_hash_acq          out com_api_type_pkg.t_tiny_id
    , o_merchant_id             out com_api_type_pkg.t_short_id
    , o_merchant_number         out com_api_type_pkg.t_merchant_number
    , o_terminal_type           out com_api_type_pkg.t_dict_value
    , o_terminal_number         out com_api_type_pkg.t_terminal_number
    , o_terminal_id             out com_api_type_pkg.t_short_id
    , o_merchant_name           out com_api_type_pkg.t_name
    , o_merchant_street         out com_api_type_pkg.t_name
    , o_merchant_city           out com_api_type_pkg.t_name
    , o_merchant_region         out com_api_type_pkg.t_module_code
    , o_merchant_country        out com_api_type_pkg.t_country_code
    , o_merchant_postcode       out com_api_type_pkg.t_postal_code
    , o_cat_level               out com_api_type_pkg.t_dict_value
    , o_mcc                     out com_api_type_pkg.t_mcc
    , o_originator_refnum       out com_api_type_pkg.t_rrn
    , o_network_refnum          out com_api_type_pkg.t_rrn
    , o_card_data_input_cap     out com_api_type_pkg.t_dict_value
    , o_crdh_auth_cap           out com_api_type_pkg.t_dict_value
    , o_card_capture_cap        out com_api_type_pkg.t_dict_value
    , o_terminal_operating_env  out com_api_type_pkg.t_dict_value
    , o_crdh_presence           out com_api_type_pkg.t_dict_value
    , o_card_presence           out com_api_type_pkg.t_dict_value
    , o_card_data_input_mode    out com_api_type_pkg.t_dict_value
    , o_crdh_auth_method        out com_api_type_pkg.t_dict_value
    , o_crdh_auth_entity        out com_api_type_pkg.t_dict_value
    , o_card_data_output_cap    out com_api_type_pkg.t_dict_value
    , o_terminal_output_cap     out com_api_type_pkg.t_dict_value
    , o_pin_capture_cap         out com_api_type_pkg.t_dict_value
    , o_pin_presence            out com_api_type_pkg.t_dict_value
    , o_cvv2_presence           out com_api_type_pkg.t_dict_value
    , o_cvc_indicator           out com_api_type_pkg.t_dict_value
    , o_pos_entry_mode          out com_api_type_pkg.t_module_code
    , o_pos_cond_code           out com_api_type_pkg.t_module_code
    , o_emv_data                out com_api_type_pkg.t_param_value
    , o_atc                     out com_api_type_pkg.t_dict_value
    , o_tvr                     out com_api_type_pkg.t_param_value
    , o_cvr                     out com_api_type_pkg.t_param_value
    , o_addl_data               out com_api_type_pkg.t_param_value
    , o_amounts                 out com_api_type_pkg.t_raw_data
    , o_resp_code               out com_api_type_pkg.t_dict_value
    , o_cavv_presence           out com_api_type_pkg.t_dict_value
    , o_aav_presence            out com_api_type_pkg.t_dict_value
    , o_transaction_id          out com_api_type_pkg.t_auth_long_id 
) return com_api_type_pkg.t_dict_value;

function get_auth (
    i_id                        in com_api_type_pkg.t_long_id
    , o_split_hash              out com_api_type_pkg.t_tiny_id
    , o_is_reversal             out com_api_type_pkg.t_boolean
    , o_original_id             out com_api_type_pkg.t_long_id
    , o_parent_id               out com_api_type_pkg.t_long_id
    , o_msg_type                out com_api_type_pkg.t_dict_value
    , o_oper_type               out com_api_type_pkg.t_dict_value
    , o_sttl_type               out com_api_type_pkg.t_dict_value
    , o_is_advice               out com_api_type_pkg.t_boolean
    , o_is_repeat               out com_api_type_pkg.t_boolean
    , o_host_date               out date
    , o_oper_date               out date
    , o_oper_count              out com_api_type_pkg.t_short_id
    , o_oper_request_amount     out com_api_type_pkg.t_money
    , o_oper_amount_algorithm   out com_api_type_pkg.t_dict_value
    , o_oper_amount             out com_api_type_pkg.t_money
    , o_oper_currency           out com_api_type_pkg.t_curr_code
    , o_oper_cashback_amount    out com_api_type_pkg.t_money
    , o_oper_replacement_amount out com_api_type_pkg.t_money
    , o_oper_surcharge_amount   out com_api_type_pkg.t_money
    , o_client_id_type          out com_api_type_pkg.t_dict_value
    , o_client_id_value         out com_api_type_pkg.t_name
    , o_iss_inst_id             out com_api_type_pkg.t_inst_id
    , o_iss_network_id          out com_api_type_pkg.t_network_id
    , o_iss_host_id             out com_api_type_pkg.t_tiny_id
    , o_iss_network_device_id   out com_api_type_pkg.t_short_id
    , o_split_hash_iss          out com_api_type_pkg.t_tiny_id
    , o_card_inst_id            out com_api_type_pkg.t_inst_id
    , o_card_network_id         out com_api_type_pkg.t_network_id
    , o_card_number             out com_api_type_pkg.t_card_number
    , o_card_id                 out com_api_type_pkg.t_medium_id
    , o_card_instance_id        out com_api_type_pkg.t_medium_id
    , o_card_type_id            out com_api_type_pkg.t_tiny_id
    , o_card_mask               out com_api_type_pkg.t_card_number
    , o_card_hash               out com_api_type_pkg.t_medium_id
    , o_card_seq_number         out com_api_type_pkg.t_tiny_id
    , o_card_expir_date         out date
    , o_card_service_code       out com_api_type_pkg.t_curr_code
    , o_card_country            out com_api_type_pkg.t_country_code
    , o_customer_id             out com_api_type_pkg.t_medium_id
    , o_account_id              out com_api_type_pkg.t_medium_id
    , o_account_type            out com_api_type_pkg.t_dict_value
    , o_account_number          out com_api_type_pkg.t_account_number
    , o_account_amount          out com_api_type_pkg.t_money
    , o_account_currency        out com_api_type_pkg.t_curr_code
    , o_account_cnvt_rate       out com_api_type_pkg.t_money
    , o_bin_amount              out com_api_type_pkg.t_money
    , o_bin_currency            out com_api_type_pkg.t_curr_code
    , o_bin_cnvt_rate           out com_api_type_pkg.t_money
    , o_network_amount          out com_api_type_pkg.t_money
    , o_network_currency        out com_api_type_pkg.t_curr_code
    , o_network_cnvt_date       out date
    , o_network_cnvt_rate       out com_api_type_pkg.t_money
    , o_addr_verif_result       out com_api_type_pkg.t_dict_value
    , o_auth_code               out com_api_type_pkg.t_auth_code
    , o_dst_client_id_type      out com_api_type_pkg.t_dict_value
    , o_dst_client_id_value     out com_api_type_pkg.t_name
    , o_dst_inst_id             out com_api_type_pkg.t_inst_id
    , o_dst_network_id          out com_api_type_pkg.t_network_id
    , o_dst_card_inst_id        out com_api_type_pkg.t_inst_id
    , o_dst_card_network_id     out com_api_type_pkg.t_network_id
    , o_dst_card_number         out com_api_type_pkg.t_card_number
    , o_dst_card_id             out com_api_type_pkg.t_medium_id
    , o_dst_card_instance_id    out com_api_type_pkg.t_medium_id
    , o_dst_card_type_id        out com_api_type_pkg.t_tiny_id
    , o_dst_card_mask           out com_api_type_pkg.t_card_number
    , o_dst_card_hash           out com_api_type_pkg.t_medium_id
    , o_dst_card_seq_number     out com_api_type_pkg.t_tiny_id
    , o_dst_card_expir_date     out date
    , o_dst_card_service_code   out com_api_type_pkg.t_curr_code
    , o_dst_card_country        out com_api_type_pkg.t_country_code
    , o_dst_customer_id         out com_api_type_pkg.t_medium_id
    , o_dst_account_id          out com_api_type_pkg.t_medium_id
    , o_dst_account_type        out com_api_type_pkg.t_dict_value
    , o_dst_account_number      out com_api_type_pkg.t_account_number
    , o_dst_account_amount      out com_api_type_pkg.t_money
    , o_dst_account_currency    out com_api_type_pkg.t_curr_code
    , o_dst_auth_code           out com_api_type_pkg.t_auth_code
    , o_acq_device_id           out com_api_type_pkg.t_short_id
    , o_acq_resp_code           out com_api_type_pkg.t_dict_value
    , o_acq_device_proc_result  out com_api_type_pkg.t_dict_value
    , o_acq_inst_bin            out com_api_type_pkg.t_cmid
    , o_forw_inst_bin           out com_api_type_pkg.t_cmid
    , o_acq_inst_id             out com_api_type_pkg.t_inst_id
    , o_acq_network_id          out com_api_type_pkg.t_network_id
    , o_split_hash_acq          out com_api_type_pkg.t_tiny_id
    , o_merchant_id             out com_api_type_pkg.t_short_id
    , o_merchant_number         out com_api_type_pkg.t_merchant_number
    , o_terminal_type           out com_api_type_pkg.t_dict_value
    , o_terminal_number         out com_api_type_pkg.t_terminal_number
    , o_terminal_id             out com_api_type_pkg.t_short_id
    , o_merchant_name           out com_api_type_pkg.t_name
    , o_merchant_street         out com_api_type_pkg.t_name
    , o_merchant_city           out com_api_type_pkg.t_name
    , o_merchant_region         out com_api_type_pkg.t_module_code
    , o_merchant_country        out com_api_type_pkg.t_country_code
    , o_merchant_postcode       out com_api_type_pkg.t_postal_code
    , o_cat_level               out com_api_type_pkg.t_dict_value
    , o_mcc                     out com_api_type_pkg.t_mcc
    , o_originator_refnum       out com_api_type_pkg.t_rrn
    , o_network_refnum          out com_api_type_pkg.t_rrn
    , o_card_data_input_cap     out com_api_type_pkg.t_dict_value
    , o_crdh_auth_cap           out com_api_type_pkg.t_dict_value
    , o_card_capture_cap        out com_api_type_pkg.t_dict_value
    , o_terminal_operating_env  out com_api_type_pkg.t_dict_value
    , o_crdh_presence           out com_api_type_pkg.t_dict_value
    , o_card_presence           out com_api_type_pkg.t_dict_value
    , o_card_data_input_mode    out com_api_type_pkg.t_dict_value
    , o_crdh_auth_method        out com_api_type_pkg.t_dict_value
    , o_crdh_auth_entity        out com_api_type_pkg.t_dict_value
    , o_card_data_output_cap    out com_api_type_pkg.t_dict_value
    , o_terminal_output_cap     out com_api_type_pkg.t_dict_value
    , o_pin_capture_cap         out com_api_type_pkg.t_dict_value
    , o_pin_presence            out com_api_type_pkg.t_dict_value
    , o_cvv2_presence           out com_api_type_pkg.t_dict_value
    , o_cvc_indicator           out com_api_type_pkg.t_dict_value
    , o_pos_entry_mode          out com_api_type_pkg.t_module_code
    , o_pos_cond_code           out com_api_type_pkg.t_module_code
    , o_emv_data                out com_api_type_pkg.t_param_value
    , o_atc                     out com_api_type_pkg.t_dict_value
    , o_tvr                     out com_api_type_pkg.t_param_value
    , o_cvr                     out com_api_type_pkg.t_param_value
    , o_addl_data               out com_api_type_pkg.t_param_value
    , o_amounts                 out com_api_type_pkg.t_raw_data
    , o_purpose_id              out com_api_type_pkg.t_short_id
    , o_resp_code               out com_api_type_pkg.t_dict_value
    , o_cavv_presence           out com_api_type_pkg.t_dict_value
    , o_aav_presence            out com_api_type_pkg.t_dict_value
    , o_transaction_id          out com_api_type_pkg.t_auth_long_id 
) return com_api_type_pkg.t_dict_value;

procedure get_entry_info(
    i_oper_id             in     com_api_type_pkg.t_long_id
  , o_entry_tab              out acc_api_type_pkg.t_entry_tab
);

end;
/
