create or replace package vis_api_dispute_pkg is

procedure gen_message_draft (
    o_fin_id                           out com_api_type_pkg.t_long_id
    , i_select_item                 in     binary_integer
    , i_oper_amount                 in     com_api_type_pkg.t_money         default null
    , i_oper_currency               in     com_api_type_pkg.t_curr_code     default null
    , i_member_msg_text             in     com_api_type_pkg.t_name          default null
    , i_docum_ind                   in     com_api_type_pkg.t_name          default null
    , i_usage_code                  in     com_api_type_pkg.t_name          default null
    , i_spec_chargeback_ind         in     com_api_type_pkg.t_name          default null
    , i_reason_code                 in     com_api_type_pkg.t_name          default null
    , i_original_fin_id             in     com_api_type_pkg.t_long_id
    , i_message_reason_code         in     com_api_type_pkg.t_dict_value    default null
    , i_dispute_condition           in     com_api_type_pkg.t_dict_value    default null
    , i_vrol_financial_id           in     com_api_type_pkg.t_region_code   default null
    , i_vrol_case_number            in     com_api_type_pkg.t_postal_code   default null
    , i_vrol_bundle_number          in     com_api_type_pkg.t_postal_code   default null
    , i_client_case_number          in     com_api_type_pkg.t_attr_name     default null
    , i_dispute_status              in     com_api_type_pkg.t_dict_value    default null
);

procedure gen_message_retrieval_request (
    o_fin_id                           out com_api_type_pkg.t_long_id
    , i_trans_code                  in     com_api_type_pkg.t_byte_char
    , i_billing_amount              in     com_api_type_pkg.t_money
    , i_billing_currency            in     com_api_type_pkg.t_curr_code
    , i_reason_code                 in     com_api_type_pkg.t_name
    , i_iss_rfc_bin                 in     com_api_type_pkg.t_name
    , i_iss_rfc_subaddr             in     com_api_type_pkg.t_name
    , i_req_fulfill_method          in     com_api_type_pkg.t_boolean
    , i_used_fulfill_method         in     com_api_type_pkg.t_boolean
    , i_fax_number                  in     com_api_type_pkg.t_name          default null
    , i_contact_info                in     com_api_type_pkg.t_name          default null
    , i_original_fin_id             in     com_api_type_pkg.t_long_id
);

procedure gen_message_fee (
    o_fin_id                           out com_api_type_pkg.t_long_id
    , i_original_fin_id             in     com_api_type_pkg.t_long_id       := null
    , i_trans_code                  in     com_api_type_pkg.t_byte_char
    , i_inst_id                     in     com_api_type_pkg.t_inst_id
    , i_network_id                  in     com_api_type_pkg.t_tiny_id
    , i_destin_bin                  in     com_api_type_pkg.t_name
    , i_source_bin                  in     com_api_type_pkg.t_name
    , i_reason_code                 in     com_api_type_pkg.t_name
    , i_event_date                  in     date
    , i_card_number                 in     com_api_type_pkg.t_name
    , i_oper_amount                 in     com_api_type_pkg.t_money
    , i_oper_currency               in     com_api_type_pkg.t_curr_code
    , i_country_code                in     com_api_type_pkg.t_name
    , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure gen_message_fraud (
    o_fin_id                           out com_api_type_pkg.t_long_id
    , i_original_fin_id             in     com_api_type_pkg.t_long_id
    , i_source_bin                  in     com_api_type_pkg.t_name          default null
    , i_oper_amount                 in     com_api_type_pkg.t_money         default null
    , i_oper_currency               in     com_api_type_pkg.t_curr_code     default null
    , i_notification_code           in     com_api_type_pkg.t_name          default null
    , i_iss_gen_auth                in     com_api_type_pkg.t_name          default null
    , i_account_seq_number          in     com_api_type_pkg.t_name          default null
    , i_expir_date                  in     com_api_type_pkg.t_name          default null
    , i_fraud_type                  in     com_api_type_pkg.t_dict_value    default null
    , i_fraud_inv_status            in     com_api_type_pkg.t_name          default null
    , i_excluded_trans_id_reason    in     com_api_type_pkg.t_name          default null
);

/*
 * Try to calculate dispute due date by the reference table DSP_DUE_DATE_LIMIT
 * and set value of application element DUE_DATE and a new cycle counter (for notification).
 */
procedure update_due_date(
    i_dispute_id                    in     com_api_type_pkg.t_long_id
  , i_standard_id                   in     com_api_type_pkg.t_tiny_id
  , i_trans_code                    in     com_api_type_pkg.t_byte_char
  , i_usage_code                    in     com_api_type_pkg.t_byte_char
  , i_msg_type                      in     com_api_type_pkg.t_dict_value    default null
  , i_eff_date                      in     date
  , i_action                        in     com_api_type_pkg.t_name
  , i_reason_code                   in     com_api_type_pkg.t_dict_value    default null
);

procedure gen_message_adjustment (
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id       default null
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
  , i_network_id                    in     com_api_type_pkg.t_tiny_id
  , i_destin_bin                    in     com_api_type_pkg.t_name
  , i_source_bin                    in     com_api_type_pkg.t_name
  , i_reason_code                   in     com_api_type_pkg.t_name
  , i_event_date                    in     date
  , i_card_number                   in     com_api_type_pkg.t_name
  , i_oper_amount                   in     com_api_type_pkg.t_money
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code
  , i_country_code                  in     com_api_type_pkg.t_name
  , i_member_msg_text               in     com_api_type_pkg.t_name
  , i_oper_type                     in     com_api_type_pkg.t_dict_value
);
    
procedure change_case_status(
    i_dispute_id                    in     com_api_type_pkg.t_long_id
  , i_usage_code                    in     com_api_type_pkg.t_byte_char
  , i_trans_code                    in     com_api_type_pkg.t_byte_char
  , i_reason_code                   in     com_api_type_pkg.t_dict_value
  , i_msg_status                    in     com_api_type_pkg.t_dict_value
  , i_dispute_condition             in     com_api_type_pkg.t_curr_code
  , i_msg_type                      in     com_api_type_pkg.t_dict_value
  , i_is_reversal                   in     com_api_type_pkg.t_boolean
);

procedure modify_first_chargeback (
    i_fin_id                        in     com_api_type_pkg.t_long_id
  , i_oper_amount                   in     com_api_type_pkg.t_money
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code
  , i_member_msg_text               in     com_api_type_pkg.t_name
  , i_docum_ind                     in     com_api_type_pkg.t_name
  , i_usage_code                    in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind           in     com_api_type_pkg.t_name
  , i_reason_code                   in     com_api_type_pkg.t_name
);

procedure modify_second_chargeback(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_docum_ind                   in     com_api_type_pkg.t_name
  , i_usage_code                  in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
);

procedure  modify_first_pres_reversal(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_second_pres_reversal (
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_second_presentment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_docum_ind                   in     com_api_type_pkg.t_name
);

procedure modify_retrieval_request (
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_billing_amount              in     com_api_type_pkg.t_money
  , i_billing_currency            in     com_api_type_pkg.t_curr_code
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_iss_rfc_bin                 in     com_api_type_pkg.t_name
  , i_iss_rfc_subaddr             in     com_api_type_pkg.t_name
  , i_req_fulfill_method          in     com_api_type_pkg.t_boolean
  , i_used_fulfill_method         in     com_api_type_pkg.t_boolean
  , i_fax_number                  in     com_api_type_pkg.t_name
  , i_contact_info                in     com_api_type_pkg.t_name
);

procedure modify_fee_collection(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_funds_disbursement(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_transmit_monetary_cred(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_fraud_reporting(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_notification_code           in     com_api_type_pkg.t_dict_value
  , i_iss_gen_auth                in     com_api_type_pkg.t_dict_value
  , i_account_seq_number          in     com_api_type_pkg.t_name
  , i_expir_date                  in     date
  , i_fraud_type                  in     com_api_type_pkg.t_name
  , i_fraud_inv_status            in     com_api_type_pkg.t_name
  , i_excluded_trans_id_reason    in     com_api_type_pkg.t_name
);

procedure modify_vcr_disp_resp_financial(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_name
  , i_dispute_status              in     com_api_type_pkg.t_dict_value
);

procedure modify_vcr_disp_financial(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_usage_code                  in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_tiny_id
  , i_message_reason_code         in     com_api_type_pkg.t_dict_value
  , i_dispute_condition           in     com_api_type_pkg.t_dict_value
  , i_vrol_financial_id           in     com_api_type_pkg.t_region_code
  , i_vrol_case_number            in     com_api_type_pkg.t_postal_code
  , i_vrol_bundle_number          in     com_api_type_pkg.t_postal_code
  , i_client_case_number          in     com_api_type_pkg.t_attr_name
);

procedure modify_vcr_disp_resp_fin_rev(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_vcr_disp_fin_reversal(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_sms_debit_adjustment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_oper_type                   in     com_api_type_pkg.t_dict_value
);

procedure modify_sms_credit_adjustment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_oper_type                   in     com_api_type_pkg.t_dict_value
);

procedure modify_sms_first_pres_reversal(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_sms_second_pres_revers(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_sms_second_presentment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_docum_ind                   in     com_api_type_pkg.t_name
);

procedure modify_sms_fee_collection(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_trans_code                  in     com_api_type_pkg.t_byte_char
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

procedure modify_sms_funds_disbursement(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_trans_code                  in     com_api_type_pkg.t_byte_char
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
);

function has_dispute_msg(
    i_id                      in com_api_type_pkg.t_long_id
  , i_tc                      in com_api_type_pkg.t_byte_char
  , i_reversal                in com_api_type_pkg.t_boolean   default null
  , i_is_uploaded             in com_api_type_pkg.t_boolean   default null
) return com_api_type_pkg.t_boolean;

end vis_api_dispute_pkg;
/
