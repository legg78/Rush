create or replace package body vis_api_dsp_generate_pkg is

procedure gen_first_chargeback is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_docum_ind               com_api_type_pkg.t_name;
    l_usage_code              com_api_type_pkg.t_tiny_id;
    l_spec_chargeback_ind     com_api_type_pkg.t_tiny_id;
    l_reason_code             com_api_type_pkg.t_name;
begin
    l_oper_id             := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount         := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency       := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text     := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
    l_docum_ind           := dsp_api_shared_data_pkg.get_masked_param_char('DOCUMENTATION_INDICATOR');
    l_usage_code          := dsp_api_shared_data_pkg.get_masked_param_num ('USAGE_CODE');
    l_spec_chargeback_ind := dsp_api_shared_data_pkg.get_masked_param_num ('SPECIAL_CHARGEBACK_INDICATOR');
    l_reason_code         := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 2
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
          , i_usage_code           => l_usage_code
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_reason_code          => l_reason_code
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        vis_api_dispute_pkg.modify_first_chargeback(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
          , i_usage_code           => l_usage_code
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_reason_code          => l_reason_code
        );
    end if;

end gen_first_chargeback;

procedure gen_second_chargeback is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_docum_ind               com_api_type_pkg.t_name;
    l_usage_code              com_api_type_pkg.t_tiny_id;
    l_spec_chargeback_ind     com_api_type_pkg.t_tiny_id;
    l_reason_code             com_api_type_pkg.t_name;
begin
    l_oper_id             := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount         := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency       := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text     := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
    l_docum_ind           := dsp_api_shared_data_pkg.get_masked_param_char('DOCUMENTATION_INDICATOR');
    l_usage_code          := dsp_api_shared_data_pkg.get_masked_param_num ('USAGE_CODE');
    l_spec_chargeback_ind := dsp_api_shared_data_pkg.get_masked_param_num ('SPECIAL_CHARGEBACK_INDICATOR');
    l_reason_code         := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 6
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
          , i_usage_code           => l_usage_code
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_reason_code          => l_reason_code
        );

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_second_chargeback(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
          , i_usage_code           => l_usage_code
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_reason_code          => l_reason_code
        );
    end if;

end gen_second_chargeback;

procedure gen_first_pres_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 1
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_first_pres_reversal(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_first_pres_reversal;

procedure gen_second_pres_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
                     
        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 4
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_second_pres_reversal(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
    end if;        
end gen_second_pres_reversal;

procedure gen_second_presentment is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_docum_ind               com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
    l_docum_ind       := dsp_api_shared_data_pkg.get_masked_param_char('DOCUMENTATION_INDICATOR');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 3
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_second_presentment(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
        );
    end if;
end gen_second_presentment;

-- Presentment Chargeback Reversal
-- Second Presentment Chargeback Reversal
procedure gen_pres_chargeback_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
begin
    l_oper_id := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 5
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else
        null;
    end if;
end gen_pres_chargeback_reversal;

procedure gen_retrieval_request is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
        
    l_billing_amount          com_api_type_pkg.t_money;
    l_billing_currency        com_api_type_pkg.t_curr_code;
    l_reason_code             com_api_type_pkg.t_name;
    l_iss_rfc_bin             com_api_type_pkg.t_name;
    l_iss_rfc_subaddr         com_api_type_pkg.t_name;
    l_req_fulfill_method      com_api_type_pkg.t_boolean;
    l_used_fulfill_method     com_api_type_pkg.t_boolean;
    l_fax_number              com_api_type_pkg.t_name;
    l_contact_info            com_api_type_pkg.t_name;
begin
    l_oper_id             := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_billing_amount      := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_billing_currency    := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_reason_code         := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_iss_rfc_bin         := dsp_api_shared_data_pkg.get_masked_param_char('ISSUER_RFC_BIN');
    l_iss_rfc_subaddr     := dsp_api_shared_data_pkg.get_masked_param_char('ISSUER_RFC_SUBADDRESS');
    l_req_fulfill_method  := to_number(dsp_api_shared_data_pkg.get_masked_param_num('REQUESTED_FULFILLMENT_METHOD'));
    l_used_fulfill_method := to_number(dsp_api_shared_data_pkg.get_masked_param_num('ESTABLISHED_FULFILLMENT_METHOD'));
    l_fax_number          := dsp_api_shared_data_pkg.get_masked_param_char('FAX_NUMBER');
    l_contact_info        := dsp_api_shared_data_pkg.get_masked_param_char('CONTACT_FOR_INFORMATION');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_retrieval_request(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_trans_code           => vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
          , i_billing_amount       => l_billing_amount
          , i_billing_currency     => l_billing_currency
          , i_reason_code          => l_reason_code
          , i_iss_rfc_bin          => l_iss_rfc_bin
          , i_iss_rfc_subaddr      => l_iss_rfc_subaddr
          , i_req_fulfill_method   => l_req_fulfill_method
          , i_used_fulfill_method  => l_used_fulfill_method
          , i_fax_number           => l_fax_number
          , i_contact_info         => l_contact_info
        );

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_retrieval_request(
            i_fin_id               => l_oper_id
          , i_billing_amount       => l_billing_amount
          , i_billing_currency     => l_billing_currency
          , i_reason_code          => l_reason_code
          , i_iss_rfc_bin          => l_iss_rfc_bin
          , i_iss_rfc_subaddr      => l_iss_rfc_subaddr
          , i_req_fulfill_method   => l_req_fulfill_method
          , i_used_fulfill_method  => l_used_fulfill_method
          , i_fax_number           => l_fax_number
          , i_contact_info         => l_contact_info
        );
    end if;
end gen_retrieval_request;

procedure gen_fee_collection is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_network_id              com_api_type_pkg.t_tiny_id;
    l_destin_bin              com_api_type_pkg.t_name;
    l_source_bin              com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_event_date              date;
    l_card_number             com_api_type_pkg.t_name;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_curr_code;
    l_country_code            com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
    l_inst_id         := dsp_api_shared_data_pkg.get_masked_param_num ('INST_ID');
    l_network_id      := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_reason_code     := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_event_date      := dsp_api_shared_data_pkg.get_masked_param_date('EVENT_DATE');
    l_card_number     := dsp_api_shared_data_pkg.get_masked_param_char('CARD_NUMBER');
    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_country_code    := dsp_api_shared_data_pkg.get_masked_param_char('COUNTRY');
    l_destin_bin      := dsp_api_shared_data_pkg.get_masked_param_char('DESTIN_BIN');
    l_source_bin      := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_fee(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_trans_code           => vis_api_const_pkg.TC_FEE_COLLECTION
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_fee_collection(
            i_fin_id               => l_oper_id
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_fee_collection;

procedure gen_funds_disbursement is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_network_id              com_api_type_pkg.t_tiny_id;
    l_destin_bin              com_api_type_pkg.t_name;
    l_source_bin              com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_event_date              date;
    l_card_number             com_api_type_pkg.t_name;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_curr_code;
    l_country_code            com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
    l_inst_id         := dsp_api_shared_data_pkg.get_masked_param_num ('INST_ID');
    l_network_id      := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_reason_code     := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_event_date      := dsp_api_shared_data_pkg.get_masked_param_date('EVENT_DATE');
    l_card_number     := dsp_api_shared_data_pkg.get_masked_param_char('CARD_NUMBER');
    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_country_code    := dsp_api_shared_data_pkg.get_masked_param_char('COUNTRY');
    l_destin_bin      := dsp_api_shared_data_pkg.get_masked_param_char('DESTIN_BIN');
    l_source_bin      := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_fee(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_trans_code           => vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_funds_disbursement(
            i_fin_id               => l_oper_id
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_funds_disbursement;

procedure gen_transmit_monetary_credits is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_network_id              com_api_type_pkg.t_tiny_id;
    l_destin_bin              com_api_type_pkg.t_name;
    l_source_bin              com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_event_date              date;
    l_card_number             com_api_type_pkg.t_name;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_curr_code;
    l_country_code            com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_inst_id         := dsp_api_shared_data_pkg.get_masked_param_num ('INST_ID');
    l_network_id      := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_reason_code     := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_event_date      := dsp_api_shared_data_pkg.get_masked_param_date('EVENT_DATE');
    l_card_number     := dsp_api_shared_data_pkg.get_masked_param_char('CARD_NUMBER');
    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_country_code    := dsp_api_shared_data_pkg.get_masked_param_char('COUNTRY');
    l_destin_bin      := dsp_api_shared_data_pkg.get_masked_param_char('DESTIN_BIN');
    l_source_bin      := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_fee(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => null
          , i_trans_code           => vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_transmit_monetary_cred(
            i_fin_id               => l_oper_id
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_transmit_monetary_credits;

procedure gen_fraud_reporting is
    l_fin_id                   com_api_type_pkg.t_long_id;
    l_oper_id                  com_api_type_pkg.t_long_id;
    l_source_bin               com_api_type_pkg.t_name;
    l_oper_amount              com_api_type_pkg.t_money;
    l_oper_currency            com_api_type_pkg.t_name;
    l_notification_code        com_api_type_pkg.t_dict_value;
    l_iss_gen_auth             com_api_type_pkg.t_dict_value;
    l_account_seq_number       com_api_type_pkg.t_name; 
    l_expir_date               date;
    l_fraud_type               com_api_type_pkg.t_name;
    l_fraud_inv_status         com_api_type_pkg.t_name;
    l_excluded_trans_id_reason com_api_type_pkg.t_name;
begin
    l_oper_id                  := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_source_bin               := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_oper_amount              := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency            := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_notification_code        := dsp_api_shared_data_pkg.get_masked_param_char('NOTIFICATION_CODE');
    l_iss_gen_auth             := dsp_api_shared_data_pkg.get_masked_param_char('ISS_GEN_AUTH');
    l_account_seq_number       := dsp_api_shared_data_pkg.get_masked_param_char('ACCOUNT_SEQ_NUMBER');
    l_expir_date               := dsp_api_shared_data_pkg.get_masked_param_date('EXPIR_DATE');
    l_fraud_type               := dsp_api_shared_data_pkg.get_masked_param_char('FRAUD_TYPE');
    l_fraud_inv_status         := dsp_api_shared_data_pkg.get_masked_param_char('FRAUD_INV_STATUS');
    l_excluded_trans_id_reason := dsp_api_shared_data_pkg.get_masked_param_char('EXCLUDED_TRANS_ID_REASON');

    l_excluded_trans_id_reason := substr(l_excluded_trans_id_reason, -1);

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_fraud(
            o_fin_id                   => l_fin_id
          , i_original_fin_id          => l_oper_id
          , i_source_bin               => l_source_bin 
          , i_oper_amount              => l_oper_amount
          , i_oper_currency            => l_oper_currency
          , i_notification_code        => l_notification_code 
          , i_iss_gen_auth             => l_iss_gen_auth
          , i_account_seq_number       => l_account_seq_number
          --, i_expir_date             => l_expir_date
          , i_expir_date               => to_char(l_expir_date, 'yymm')
          , i_fraud_type               => l_fraud_type
          , i_fraud_inv_status         => l_fraud_inv_status
          , i_excluded_trans_id_reason => l_excluded_trans_id_reason
        );

        dsp_ui_process_pkg.set_operation_id(
            i_oper_id                  => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_fraud_reporting(
            i_fin_id                   => l_oper_id
          , i_source_bin               => l_source_bin 
          , i_oper_amount              => l_oper_amount
          , i_oper_currency            => l_oper_currency
          , i_notification_code        => l_notification_code 
          , i_iss_gen_auth             => l_iss_gen_auth
          , i_account_seq_number       => l_account_seq_number
          --, i_expir_date             => l_expir_date
          , i_expir_date               => to_char(l_expir_date, 'yymm')
          , i_fraud_type               => l_fraud_type
          , i_fraud_inv_status         => l_fraud_inv_status
          , i_excluded_trans_id_reason => l_excluded_trans_id_reason
        );
    end if;
end gen_fraud_reporting;

procedure gen_vcr_disp_resp_financial is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_spec_chargeback_ind     com_api_type_pkg.t_tiny_id;
    l_dispute_status          com_api_type_pkg.t_name;
begin
    -- Generate second presentment (Generate dispute response financial)
    l_oper_id             := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount         := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency       := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text     := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
    l_spec_chargeback_ind := dsp_api_shared_data_pkg.get_masked_param_num('SPECIAL_CHARGEBACK_INDICATOR');
    l_dispute_status      := dsp_api_shared_data_pkg.get_masked_param_char('DISPUTE_STATUS');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 11
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_dispute_status       => l_dispute_status
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_vcr_disp_resp_financial(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_dispute_status       => l_dispute_status
        );
    end if;
end gen_vcr_disp_resp_financial;

procedure gen_vcr_disp_financial is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
    l_spec_chargeback_ind     com_api_type_pkg.t_tiny_id;
    l_message_reason_code     com_api_type_pkg.t_dict_value;
    l_dispute_condition       com_api_type_pkg.t_dict_value;
    l_vrol_financial_id       com_api_type_pkg.t_region_code;
    l_vrol_case_number        com_api_type_pkg.t_postal_code;
    l_vrol_bundle_number      com_api_type_pkg.t_postal_code;
    l_client_case_number      com_api_type_pkg.t_attr_name;
begin
    l_oper_id             := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount         := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency       := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text     := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
    l_spec_chargeback_ind := dsp_api_shared_data_pkg.get_masked_param_num ('SPECIAL_CHARGEBACK_INDICATOR');
    l_message_reason_code := dsp_api_shared_data_pkg.get_masked_param_char('MESSAGE_REASON');
    l_dispute_condition   := dsp_api_shared_data_pkg.get_masked_param_char('DISPUTE_CONDITION');
    l_vrol_financial_id   := dsp_api_shared_data_pkg.get_masked_param_char('VROL_FINANCIAL_ID');
    l_vrol_case_number    := dsp_api_shared_data_pkg.get_masked_param_char('VROL_CASE_NUMBER');
    l_vrol_bundle_number  := dsp_api_shared_data_pkg.get_masked_param_char('VROL_BUNDLE_NUMBER');
    l_client_case_number  := dsp_api_shared_data_pkg.get_masked_param_char('CLIENT_CASE_NUMBER');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 12
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_usage_code           => '9'
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_message_reason_code  => l_message_reason_code
          , i_dispute_condition    => l_dispute_condition
          , i_vrol_financial_id    => l_vrol_financial_id
          , i_vrol_case_number     => l_vrol_case_number
          , i_vrol_bundle_number   => l_vrol_bundle_number
          , i_client_case_number   => l_client_case_number
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_vcr_disp_financial(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_usage_code           => '9'
          , i_spec_chargeback_ind  => l_spec_chargeback_ind
          , i_message_reason_code  => l_message_reason_code
          , i_dispute_condition    => l_dispute_condition
          , i_vrol_financial_id    => l_vrol_financial_id
          , i_vrol_case_number     => l_vrol_case_number
          , i_vrol_bundle_number   => l_vrol_bundle_number
          , i_client_case_number   => l_client_case_number
        );
    end if;
end gen_vcr_disp_financial;

procedure gen_vcr_disp_resp_fin_revers is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 13
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_vcr_disp_resp_fin_rev(
            i_fin_id               => l_oper_id
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_vcr_disp_resp_fin_revers;

procedure gen_vcr_disp_fin_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 14
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_vcr_disp_fin_reversal(
            i_fin_id               => l_oper_id
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_vcr_disp_fin_reversal;

procedure gen_sms_debit_adjustment is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_network_id              com_api_type_pkg.t_tiny_id;
    l_destin_bin              com_api_type_pkg.t_name;
    l_source_bin              com_api_type_pkg.t_name;
    l_reason_code             com_api_type_pkg.t_name;
    l_event_date              date;
    l_card_number             com_api_type_pkg.t_name;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_curr_code;
    l_country_code            com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
    l_inst_id         := dsp_api_shared_data_pkg.get_masked_param_num ('INST_ID');
    l_network_id      := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_reason_code     := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_event_date      := dsp_api_shared_data_pkg.get_masked_param_date('EVENT_DATE');
    l_card_number     := dsp_api_shared_data_pkg.get_masked_param_char('CARD_NUMBER');
    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_country_code    := dsp_api_shared_data_pkg.get_masked_param_char('COUNTRY');
    l_destin_bin      := dsp_api_shared_data_pkg.get_masked_param_char('DESTIN_BIN');
    l_source_bin      := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_adjustment(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
          , i_oper_type            => OPR_API_CONST_PKG.OPERATION_TYPE_DEBIT_ADJUST
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_sms_debit_adjustment(
            i_fin_id               => l_oper_id
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
          , i_oper_type            => OPR_API_CONST_PKG.OPERATION_TYPE_DEBIT_ADJUST
        );
    end if;

    evt_api_event_pkg.register_event (
        i_event_type    =>  vis_api_const_pkg.EVENT_TYPE_SMS_DISPUTE_CREATED --EVNT2010
      , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   =>  opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     =>  l_fin_id
      , i_inst_id       =>  ost_api_const_pkg.DEFAULT_INST
      , i_split_hash    =>  com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, l_fin_id)
    );

end gen_sms_debit_adjustment;

procedure gen_sms_credit_adjustment is
    l_fin_id           com_api_type_pkg.t_long_id;
    l_oper_id          com_api_type_pkg.t_long_id;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_network_id       com_api_type_pkg.t_tiny_id;
    l_destin_bin       com_api_type_pkg.t_name;
    l_source_bin       com_api_type_pkg.t_name;
    l_reason_code      com_api_type_pkg.t_name;
    l_event_date       date;
    l_card_number      com_api_type_pkg.t_name;
    l_oper_amount      com_api_type_pkg.t_money;
    l_oper_currency    com_api_type_pkg.t_curr_code;
    l_country_code     com_api_type_pkg.t_name;
    l_member_msg_text  com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
    l_inst_id         := dsp_api_shared_data_pkg.get_masked_param_num ('INST_ID');
    l_network_id      := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_reason_code     := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_event_date      := dsp_api_shared_data_pkg.get_masked_param_date('EVENT_DATE');
    l_card_number     := dsp_api_shared_data_pkg.get_masked_param_char('CARD_NUMBER');
    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_country_code    := dsp_api_shared_data_pkg.get_masked_param_char('COUNTRY');
    l_destin_bin      := dsp_api_shared_data_pkg.get_masked_param_char('DESTIN_BIN');
    l_source_bin      := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_adjustment(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
          , i_oper_type            => OPR_API_CONST_PKG.OPERATION_TYPE_CREDIT_ADJUST
        );
   
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_sms_credit_adjustment(
            i_fin_id               => l_oper_id
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
          , i_oper_type            => OPR_API_CONST_PKG.OPERATION_TYPE_CREDIT_ADJUST
        );
    end if;

    evt_api_event_pkg.register_event (
        i_event_type    =>  vis_api_const_pkg.EVENT_TYPE_SMS_DISPUTE_CREATED --EVNT2010
      , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   =>  opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     =>  l_fin_id
      , i_inst_id       =>  ost_api_const_pkg.DEFAULT_INST
      , i_split_hash    =>  com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, l_fin_id)
    );
end gen_sms_credit_adjustment;

procedure gen_sms_first_pres_reversal is 
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 1
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_sms_first_pres_reversal(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_sms_first_pres_reversal;
    
procedure gen_sms_second_pres_reversal is
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_oper_id                 com_api_type_pkg.t_long_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_name;
    l_member_msg_text         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 4
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_sms_second_pres_revers(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
end gen_sms_second_pres_reversal;

procedure gen_sms_second_presentment is
    l_fin_id            com_api_type_pkg.t_long_id;
    l_oper_id           com_api_type_pkg.t_long_id;
    l_oper_amount       com_api_type_pkg.t_money;
    l_oper_currency     com_api_type_pkg.t_name;
    l_member_msg_text   com_api_type_pkg.t_name;
    l_docum_ind         com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');

    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
    l_docum_ind       := dsp_api_shared_data_pkg.get_masked_param_char('DOCUMENTATION_INDICATOR');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then

        vis_api_dispute_pkg.gen_message_draft(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_select_item          => 3
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_sms_second_presentment(
            i_fin_id               => l_oper_id
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_member_msg_text      => l_member_msg_text
          , i_docum_ind            => l_docum_ind
        );
    end if;
        
    evt_api_event_pkg.register_event (
        i_event_type    =>  vis_api_const_pkg.EVENT_TYPE_SMS_DISPUTE_CREATED --EVNT2010
      , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   =>  opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     =>  l_fin_id
      , i_inst_id       =>  ost_api_const_pkg.DEFAULT_INST
      , i_split_hash    =>  com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, l_fin_id)
    );
end gen_sms_second_presentment;

procedure gen_sms_fee_collection is
    l_fin_id           com_api_type_pkg.t_long_id;
    l_oper_id          com_api_type_pkg.t_long_id;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_network_id       com_api_type_pkg.t_tiny_id;
    l_destin_bin       com_api_type_pkg.t_name;
    l_source_bin       com_api_type_pkg.t_name;
    l_reason_code      com_api_type_pkg.t_name;
    l_event_date       date;
    l_card_number      com_api_type_pkg.t_name;
    l_oper_amount      com_api_type_pkg.t_money;
    l_oper_currency    com_api_type_pkg.t_curr_code;
    l_country_code     com_api_type_pkg.t_name;
    l_member_msg_text  com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
    l_inst_id         := dsp_api_shared_data_pkg.get_masked_param_num ('INST_ID');
    l_network_id      := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_reason_code     := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_event_date      := dsp_api_shared_data_pkg.get_masked_param_date('EVENT_DATE');
    l_card_number     := dsp_api_shared_data_pkg.get_masked_param_char('CARD_NUMBER');
    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_country_code    := dsp_api_shared_data_pkg.get_masked_param_char('COUNTRY');
    l_destin_bin      := dsp_api_shared_data_pkg.get_masked_param_char('DESTIN_BIN');
    l_source_bin      := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');
        
    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_fee(
            o_fin_id               => l_fin_id
          , i_original_fin_id      => l_oper_id
          , i_trans_code           => vis_api_const_pkg.TC_FEE_COLLECTION
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
            
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id              => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_sms_fee_collection(
            i_fin_id               => l_oper_id
          , i_trans_code           => vis_api_const_pkg.TC_FEE_COLLECTION
          , i_inst_id              => l_inst_id
          , i_network_id           => l_network_id
          , i_destin_bin           => l_destin_bin
          , i_source_bin           => l_source_bin
          , i_reason_code          => l_reason_code
          , i_event_date           => l_event_date
          , i_card_number          => l_card_number
          , i_oper_amount          => l_oper_amount
          , i_oper_currency        => l_oper_currency
          , i_country_code         => l_country_code
          , i_member_msg_text      => l_member_msg_text
        );
    end if;
            
    evt_api_event_pkg.register_event(
        i_event_type    =>  vis_api_const_pkg.EVENT_TYPE_SMS_DISPUTE_CREATED --EVNT2010
      , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   =>  opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     =>  l_fin_id
      , i_inst_id       =>  ost_api_const_pkg.DEFAULT_INST
      , i_split_hash    =>  com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, l_fin_id)
    );
end gen_sms_fee_collection;
    
procedure gen_sms_funds_disbursement is
    l_fin_id           com_api_type_pkg.t_long_id;
    l_oper_id          com_api_type_pkg.t_long_id;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_network_id       com_api_type_pkg.t_tiny_id;
    l_destin_bin       com_api_type_pkg.t_name;
    l_source_bin       com_api_type_pkg.t_name;
    l_reason_code      com_api_type_pkg.t_name;
    l_event_date       date;
    l_card_number      com_api_type_pkg.t_name;
    l_oper_amount      com_api_type_pkg.t_money;
    l_oper_currency    com_api_type_pkg.t_curr_code;
    l_country_code     com_api_type_pkg.t_name;
    l_member_msg_text  com_api_type_pkg.t_name;
begin
    l_oper_id         := dsp_api_shared_data_pkg.get_param_num('OPERATION_ID');
        
    l_inst_id         := dsp_api_shared_data_pkg.get_masked_param_num ('INST_ID');
    l_network_id      := dsp_api_shared_data_pkg.get_masked_param_num ('NETWORK_ID');
    l_reason_code     := dsp_api_shared_data_pkg.get_masked_param_char('REASON_CODE');
    l_event_date      := dsp_api_shared_data_pkg.get_masked_param_date('EVENT_DATE');
    l_card_number     := dsp_api_shared_data_pkg.get_masked_param_char('CARD_NUMBER');
    l_oper_amount     := dsp_api_shared_data_pkg.get_masked_param_num ('OPER_AMOUNT');
    l_oper_currency   := dsp_api_shared_data_pkg.get_masked_param_char('OPER_CURRENCY');
    l_country_code    := dsp_api_shared_data_pkg.get_masked_param_char('COUNTRY');
    l_destin_bin      := dsp_api_shared_data_pkg.get_masked_param_char('DESTIN_BIN');
    l_source_bin      := dsp_api_shared_data_pkg.get_masked_param_char('SOURCE_BIN');
    l_member_msg_text := dsp_api_shared_data_pkg.get_masked_param_char('MEMBER_MESSAGE_TEXT');

    if dsp_ui_process_pkg.is_editing = com_api_type_pkg.FALSE then
        
        vis_api_dispute_pkg.gen_message_fee(
            o_fin_id           => l_fin_id
          , i_original_fin_id  => l_oper_id
          , i_trans_code       => vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
          , i_inst_id          => l_inst_id
          , i_network_id       => l_network_id
          , i_destin_bin       => l_destin_bin
          , i_source_bin       => l_source_bin
          , i_reason_code      => l_reason_code
          , i_event_date       => l_event_date
          , i_card_number      => l_card_number
          , i_oper_amount      => l_oper_amount
          , i_oper_currency    => l_oper_currency
          , i_country_code     => l_country_code
          , i_member_msg_text  => l_member_msg_text
        );
        
        dsp_ui_process_pkg.set_operation_id(
            i_oper_id          => l_fin_id
        );        
    else        
        vis_api_dispute_pkg.modify_sms_funds_disbursement(
            i_fin_id           => l_oper_id
          , i_trans_code       => vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
          , i_inst_id          => l_inst_id
          , i_network_id       => l_network_id
          , i_destin_bin       => l_destin_bin
          , i_source_bin       => l_source_bin
          , i_reason_code      => l_reason_code
          , i_event_date       => l_event_date
          , i_card_number      => l_card_number
          , i_oper_amount      => l_oper_amount
          , i_oper_currency    => l_oper_currency
          , i_country_code     => l_country_code
          , i_member_msg_text  => l_member_msg_text
        );
    end if;

    evt_api_event_pkg.register_event (
        i_event_type    =>  vis_api_const_pkg.EVENT_TYPE_SMS_DISPUTE_CREATED --EVNT2010
      , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   =>  opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     =>  l_fin_id
      , i_inst_id       =>  ost_api_const_pkg.DEFAULT_INST
      , i_split_hash    =>  com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, l_fin_id)
    );
end gen_sms_funds_disbursement;

end vis_api_dsp_generate_pkg;
/
