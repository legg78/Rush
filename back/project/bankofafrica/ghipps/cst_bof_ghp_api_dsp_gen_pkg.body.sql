create or replace package body cst_bof_ghp_api_dsp_gen_pkg is

procedure first_chargeback
is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_docum_ind               com_api_type_pkg.t_tiny_id;
    l_usage_code              com_api_type_pkg.t_tiny_id;
    l_spec_chargeback_ind     com_api_type_pkg.t_tiny_id;
    l_reason_code             com_api_type_pkg.t_name;
begin
    l_oper_id :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPERATION_ID'
        );
    l_oper_amount :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_oper_currency :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_CURRENCY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_member_msg_text :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'MEMBER_MESSAGE_TEXT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_docum_ind :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'DOCUMENTATION_INDICATOR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_usage_code :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'USAGE_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_spec_chargeback_ind :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'SPECIAL_CHARGEBACK_INDICATOR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_reason_code :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'REASON_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    cst_bof_ghp_api_dispute_pkg.generate_message_draft(
        o_fin_id               => l_fin_id
      , i_original_fin_id      => l_oper_id
      , i_select_item          => cst_bof_ghp_api_const_pkg.DSP_ITEM_FIRST_CHARGEBACK
      , i_oper_amount          => l_oper_amount
      , i_oper_currency        => l_oper_currency
      , i_member_msg_text      => l_member_msg_text
      , i_docum_ind            => l_docum_ind
      , i_usage_code           => l_usage_code
      , i_spec_chargeback_ind  => l_spec_chargeback_ind
      , i_reason_code          => l_reason_code
    );
end first_chargeback;

-- Presentment Chargeback Reversal
-- Second Presentment Chargeback Reversal
procedure pres_chargeback_reversal
is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    cst_bof_ghp_api_dispute_pkg.generate_message_draft(
        o_fin_id               => l_fin_id
      , i_original_fin_id      => l_oper_id
      , i_select_item          => cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK
    );
end;

procedure second_presentment
is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_docum_ind               com_api_type_pkg.t_tiny_id;
begin
    l_oper_id :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPERATION_ID'
        );
    l_oper_amount :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_oper_currency :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_CURRENCY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_member_msg_text :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'MEMBER_MESSAGE_TEXT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_docum_ind :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'DOCUMENTATION_INDICATOR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    cst_bof_ghp_api_dispute_pkg.generate_message_draft(
        o_fin_id               => l_fin_id
      , i_original_fin_id      => l_oper_id
      , i_select_item          => cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRESENTMENT
      , i_oper_amount          => l_oper_amount
      , i_oper_currency        => l_oper_currency
      , i_member_msg_text      => l_member_msg_text
      , i_docum_ind            => l_docum_ind
    );
end second_presentment;

procedure second_chargeback
is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_docum_ind               com_api_type_pkg.t_tiny_id;
    l_usage_code              com_api_type_pkg.t_tiny_id;
    l_spec_chargeback_ind     com_api_type_pkg.t_tiny_id;
    l_reason_code             com_api_type_pkg.t_name;
begin
    l_oper_id :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPERATION_ID'
        );
    l_oper_amount :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_oper_currency :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_CURRENCY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_member_msg_text :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'MEMBER_MESSAGE_TEXT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_docum_ind :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'DOCUMENTATION_INDICATOR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_usage_code :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'USAGE_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_spec_chargeback_ind :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'SPECIAL_CHARGEBACK_INDICATOR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_reason_code :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'REASON_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    cst_bof_ghp_api_dispute_pkg.generate_message_draft(
        o_fin_id               => l_fin_id
      , i_original_fin_id      => l_oper_id
      , i_select_item          => cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRES_CHRGBCK
      , i_oper_amount          => l_oper_amount
      , i_oper_currency        => l_oper_currency
      , i_member_msg_text      => l_member_msg_text
      , i_docum_ind            => l_docum_ind
      , i_usage_code           => l_usage_code
      , i_spec_chargeback_ind  => l_spec_chargeback_ind
      , i_reason_code          => l_reason_code
    );
end second_chargeback;

-- Reversal for second_presentment and second_chargeback
procedure second_presentment_reversal
is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPERATION_ID'
        );
    l_oper_amount :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_oper_currency :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_CURRENCY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_member_msg_text :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'MEMBER_MESSAGE_TEXT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    cst_bof_ghp_api_dispute_pkg.generate_message_draft(
        o_fin_id               => l_fin_id
      , i_original_fin_id      => l_oper_id
      , i_select_item          => cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES
      , i_oper_amount          => l_oper_amount
      , i_oper_currency        => l_oper_currency
      , i_member_msg_text      => l_member_msg_text
    );
end second_presentment_reversal;

procedure retrieval_request
is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_billing_amount          com_api_type_pkg.t_money;
    l_billing_currency        com_api_type_pkg.t_curr_code;
    l_reason_code             com_api_type_pkg.t_name;
    l_document_type           com_api_type_pkg.t_byte_char;
    l_card_iss_ref_num        com_api_type_pkg.t_name;
    l_cancellation_ind        com_api_type_pkg.t_byte_char;
    l_response_type           com_api_type_pkg.t_tiny_id;
begin
    l_oper_id :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPERATION_ID'
        );
    l_billing_amount :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_billing_currency :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_CURRENCY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_reason_code :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'REASON_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_document_type :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'GHP_DOCUMENT_TYPE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_card_iss_ref_num :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'GHP_CARD_ISSUER_REF_NUM'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_cancellation_ind :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'GHP_CANCELLATION_INDICATOR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_response_type :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'GHP_RESPONSE_TYPE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    cst_bof_ghp_api_dispute_pkg.generate_retrieval_request(
        o_fin_id               => l_fin_id
      , i_original_fin_id      => l_oper_id
      , i_trans_code           => cst_bof_ghp_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
      , i_billing_amount       => l_billing_amount
      , i_billing_currency     => l_billing_currency
      , i_reason_code          => l_reason_code
      , i_card_iss_ref_num     => l_card_iss_ref_num
      , i_document_type        => l_document_type
      , i_cancellation_ind     => l_cancellation_ind
      , i_response_type        => l_response_type
    );
end retrieval_request;

procedure fee_debit_credit
is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_trans_code              com_api_type_pkg.t_byte_char;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_network_id              com_api_type_pkg.t_tiny_id;
    l_reason_code             com_api_type_pkg.t_name;
    l_event_date              date;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_curr_code;
    l_country_code            com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_trans_code :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'TRANSACTION_CODE'
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    l_inst_id :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'INST_ID'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_network_id :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'NETWORK_ID'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_reason_code :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'REASON_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_event_date :=
        dsp_api_shared_data_pkg.get_param_date(
            i_name        => 'EVENT_DATE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_oper_amount :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_oper_currency :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_CURRENCY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_country_code :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'COUNTRY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_member_msg_text :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'MEMBER_MESSAGE_TEXT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    cst_bof_ghp_api_dispute_pkg.generate_fee_debit_credit(
        o_fin_id           => l_fin_id
      , i_original_fin_id  => l_oper_id
      , i_trans_code       => l_trans_code
      , i_inst_id          => l_inst_id
      , i_network_id       => l_network_id
      , i_reason_code      => l_reason_code
      , i_event_date       => l_event_date
      , i_oper_amount      => l_oper_amount
      , i_oper_currency    => l_oper_currency
      , i_country_code     => l_country_code
      , i_member_msg_text  => l_member_msg_text
    );
end fee_debit_credit;

procedure fraud_reporting
is
    l_fin_id                   com_api_type_pkg.t_long_id;
    l_oper_id                  com_api_type_pkg.t_long_id;
    l_oper_amount              com_api_type_pkg.t_money;
    l_oper_currency            com_api_type_pkg.t_name;
    l_notification_code        com_api_type_pkg.t_dict_value;
    l_account_seq_number       com_api_type_pkg.t_name;
    l_insurance_year           com_api_type_pkg.t_name;
    l_expir_date               date;
    l_fraud_type               com_api_type_pkg.t_dict_value;
    l_debit_credit_indicator   com_api_type_pkg.t_name;
    l_trans_generation_method  com_api_type_pkg.t_name;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount :=
        dsp_api_shared_data_pkg.get_param_num(
            i_name        => 'OPER_AMOUNT'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_oper_currency :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'OPER_CURRENCY'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_notification_code :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'NOTIFICATION_CODE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_account_seq_number :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'GHP_ACCOUNT_SEQ_NUMBER'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_insurance_year :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'GHP_INSURANCE_YEAR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_fraud_type :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'FRAUD_TYPE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_expir_date :=
        dsp_api_shared_data_pkg.get_param_date(
            i_name        => 'EXPIR_DATE'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_debit_credit_indicator :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'GHP_DEBIT_CREDIT_INDICATOR'
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    l_trans_generation_method :=
        dsp_api_shared_data_pkg.get_param_char(
            i_name        => 'GHP_TRANS_GENERATION_METHOD'
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    cst_bof_ghp_api_dispute_pkg.genetate_message_fraud(
        o_fin_id                   => l_fin_id
      , i_original_fin_id          => l_oper_id
      , i_oper_amount              => l_oper_amount
      , i_oper_currency            => l_oper_currency
      , i_notification_code        => l_notification_code
      , i_account_seq_number       => l_account_seq_number
      , i_insurance_year           => l_insurance_year
      , i_fraud_type               => l_fraud_type
      , i_expir_date               => l_expir_date
      , i_debit_credit_indicator   => l_debit_credit_indicator
      , i_trans_generation_method  => l_trans_generation_method
    );
end fraud_reporting;

end;
/
