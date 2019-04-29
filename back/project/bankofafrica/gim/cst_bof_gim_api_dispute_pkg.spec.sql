create or replace package cst_bof_gim_api_dispute_pkg is

procedure generate_message_draft(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_select_item                   in     binary_integer
  , i_oper_amount                   in     com_api_type_pkg.t_money         default null
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code     default null
  , i_member_msg_text               in     com_api_type_pkg.t_name          default null
  , i_docum_ind                     in     com_api_type_pkg.t_name          default null
  , i_usage_code                    in     com_api_type_pkg.t_name          default null
  , i_spec_chargeback_ind           in     com_api_type_pkg.t_name          default null
  , i_reason_code                   in     com_api_type_pkg.t_name          default null
  , i_message_reason_code           in     com_api_type_pkg.t_dict_value    default null
  , i_dispute_condition             in     com_api_type_pkg.t_curr_code     default null
  , i_vrol_financial_id             in     com_api_type_pkg.t_region_code   default null
  , i_vrol_case_number              in     com_api_type_pkg.t_postal_code   default null
  , i_vrol_bundle_number            in     com_api_type_pkg.t_postal_code   default null
  , i_client_case_number            in     com_api_type_pkg.t_attr_name     default null
);

procedure generate_retrieval_request(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_trans_code                    in     com_api_type_pkg.t_byte_char
  , i_billing_amount                in     com_api_type_pkg.t_money
  , i_billing_currency              in     com_api_type_pkg.t_curr_code
  , i_reason_code                   in     com_api_type_pkg.t_name
  , i_document_type                 in     com_api_type_pkg.t_byte_char
  , i_card_iss_ref_num              in     com_api_type_pkg.t_name
  , i_cancellation_ind              in     com_api_type_pkg.t_byte_char
  , i_response_type                 in     com_api_type_pkg.t_byte_char
);

procedure generate_fee_debit_credit(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_trans_code                    in     com_api_type_pkg.t_byte_char
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
  , i_network_id                    in     com_api_type_pkg.t_network_id
  , i_reason_code                   in     com_api_type_pkg.t_name
  , i_event_date                    in     date
  , i_oper_amount                   in     com_api_type_pkg.t_money
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code
  , i_country_code                  in     com_api_type_pkg.t_name
  , i_member_msg_text               in     com_api_type_pkg.t_name
);

procedure generate_message_fraud(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_oper_amount                   in     com_api_type_pkg.t_money
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code
  , i_notification_code             in     com_api_type_pkg.t_dict_value
  , i_account_seq_number            in     com_api_type_pkg.t_name
  , i_insurance_year                in     com_api_type_pkg.t_name
  , i_fraud_type                    in     com_api_type_pkg.t_dict_value
  , i_expir_date                    in     date
  , i_debit_credit_indicator        in     com_api_type_pkg.t_byte_char
  , i_trans_generation_method       in     com_api_type_pkg.t_byte_char
);

end;
/
