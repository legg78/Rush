create or replace package body vis_api_fin_message_pkg as
/*********************************************************
 *  API for VISA financial message <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Module: VIS_API_FIN_MESSAGE_PKG   <br />
 *  @headcom
 **********************************************************/

-- fin. message
G_COLUMN_LIST               constant com_api_type_pkg.t_text :=
   ' f.id'
|| ', f.status'
|| ', f.is_reversal'
|| ', f.is_incoming'
|| ', f.is_returned'
|| ', f.is_invalid'
|| ', f.inst_id'
|| ', f.network_id'
|| ', f.trans_code'
|| ', f.trans_code_qualifier'
|| ', f.card_id'
|| ', f.card_hash'
|| ', f.card_mask'
|| ', f.oper_amount'
|| ', f.oper_currency'
|| ', f.oper_date'
|| ', f.sttl_amount'
|| ', f.sttl_currency'
|| ', f.arn'
|| ', f.acq_business_id'
|| ', f.merchant_name'
|| ', f.merchant_city'
|| ', f.merchant_country'
|| ', f.merchant_postal_code'
|| ', f.merchant_region'
|| ', f.mcc'
|| ', f.req_pay_service'
|| ', f.usage_code'
|| ', f.reason_code'
|| ', f.settlement_flag'
|| ', f.auth_char_ind'
|| ', f.auth_code'
|| ', f.pos_terminal_cap'
|| ', f.inter_fee_ind'
|| ', f.crdh_id_method'
|| ', f.collect_only_flag'
|| ', f.pos_entry_mode'
|| ', f.central_proc_date'
|| ', f.reimburst_attr'
|| ', f.iss_workst_bin'
|| ', f.acq_workst_bin'
|| ', f.chargeback_ref_num'
|| ', f.docum_ind'
|| ', f.member_msg_text'
|| ', f.spec_cond_ind'
|| ', f.fee_program_ind'
|| ', f.issuer_charge'
|| ', f.merchant_number'
|| ', f.terminal_number'
|| ', f.national_reimb_fee'
|| ', f.electr_comm_ind'
|| ', f.spec_chargeback_ind'
|| ', f.interface_trace_num'
|| ', f.unatt_accept_term_ind'
|| ', f.prepaid_card_ind'
|| ', f.service_development'
|| ', f.avs_resp_code'
|| ', f.auth_source_code'
|| ', f.purch_id_format'
|| ', f.account_selection'
|| ', f.installment_pay_count'
|| ', f.purch_id'
|| ', f.cashback'
|| ', f.chip_cond_code'
|| ', f.transaction_id'
|| ', f.pos_environment'
|| ', f.transaction_type'
|| ', f.card_seq_number'
|| ', f.terminal_profile'
|| ', f.unpredict_number'
|| ', f.appl_trans_counter'
|| ', f.appl_interch_profile'
|| ', f.cryptogram'
|| ', f.term_verif_result'
|| ', f.cryptogram_amount'
|| ', f.card_expir_date'
|| ', f.cryptogram_version'
|| ', f.cvv2_result_code'
|| ', f.auth_resp_code'
|| ', f.card_verif_result'
|| ', f.floor_limit_ind'
|| ', f.exept_file_ind'
|| ', f.pcas_ind'
|| ', f.issuer_appl_data'
|| ', f.issuer_script_result'
|| ', f.network_amount'
|| ', f.network_currency'
|| ', f.dispute_id'
|| ', f.file_id'
|| ', f.batch_id'
|| ', f.record_number'
|| ', f.rrn'
|| ', f.acquirer_bin'
|| ', f.merchant_street'
|| ', f.cryptogram_info_data'
|| ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
|| ', f.merchant_verif_value'
|| ', f.host_inst_id'
|| ', f.proc_bin'
|| ', f.chargeback_reason_code'
|| ', f.destination_channel'
|| ', f.source_channel'
|| ', f.acq_inst_bin'
|| ', f.spend_qualified_ind'
|| ', f.clearing_sequence_num'
|| ', f.clearing_sequence_count'
|| ', f.service_code'
|| ', f.business_format_code'
|| ', f.token_assurance_level'
|| ', f.pan_token'
|| ', f.validation_code'
|| ', f.payment_forms_num'
|| ', f.business_format_code_e'
|| ', f.agent_unique_id'
|| ', f.additional_auth_method'
|| ', f.additional_reason_code'
|| ', f.product_id'
|| ', f.auth_amount'
|| ', f.auth_currency'
|| ', f.form_factor_indicator'

|| ', fast_funds_indicator'
|| ', business_format_code_3'
|| ', business_application_id'
|| ', source_of_funds'
|| ', payment_reversal_code'
|| ', sender_reference_number'
|| ', sender_account_number'
|| ', sender_name'
|| ', sender_address'
|| ', sender_city'
|| ', sender_state'
|| ', sender_country'
|| ', network_code'
|| ', fee_interchange_amount'
|| ', fee_interchange_sign'
|| ', program_id'
|| ', dcc_indicator'
|| ', message_reason_code'
|| ', dispute_condition'
|| ', vrol_financial_id'
|| ', vrol_case_number'
|| ', vrol_bundle_number'
|| ', client_case_number'
|| ', dispute_status'
|| ', payment_acc_ref'
|| ', token_requestor_id'
|| ', f.terminal_country'

|| ', f.trans_comp_number_tcr3'
|| ', f.business_application_id_tcr3'
|| ', f.business_format_code_tcr3'
|| ', f.passenger_name'
|| ', f.departure_date'
|| ', f.orig_city_airport_code'
|| ', f.carrier_code_1'
|| ', f.service_class_code_1'
|| ', f.stop_over_code_1'
|| ', f.dest_city_airport_code_1'
|| ', f.carrier_code_2'
|| ', f.service_class_code_2'
|| ', f.stop_over_code_2'
|| ', f.dest_city_airport_code_2'
|| ', f.carrier_code_3'
|| ', f.service_class_code_3'
|| ', f.stop_over_code_3'
|| ', f.dest_city_airport_code_3'
|| ', f.carrier_code_4'
|| ', f.service_class_code_4'
|| ', f.stop_over_code_4'
|| ', f.dest_city_airport_code_4'
|| ', f.travel_agency_code'
|| ', f.travel_agency_name'
|| ', f.restrict_ticket_indicator'
|| ', f.fare_basis_code_1'
|| ', f.fare_basis_code_2'
|| ', f.fare_basis_code_3'
|| ', f.fare_basis_code_4'
|| ', f.comp_reserv_system'
|| ', f.flight_number_1'
|| ', f.flight_number_2'
|| ', f.flight_number_3'
|| ', f.flight_number_4'
|| ', f.credit_reason_indicator'
|| ', f.ticket_change_indicator'
|| ', f.recipient_name'
|| ', null dispute_amount'
|| ', null dispute_currency'
|| ', f.terminal_trans_date'
|| ', f.business_format_code_4'
|| ', f.surcharge_amount'
|| ', f.surcharge_sign'
|| ', f.conv_date'
;

-- fin
G_COLUMN_LIST_FIN_FR        constant com_api_type_pkg.t_text :=
   ' f.id'
|| ', f.status'
|| ', f.is_reversal'
|| ', f.is_incoming'
|| ', f.is_returned'
|| ', f.is_invalid'
|| ', f.inst_id'
|| ', f.network_id'
--|| ', f.trans_code'  --move
|| ', f.trans_code_qualifier'
|| ', f.card_id'
|| ', f.card_hash'
|| ', f.card_mask'
|| ', f.oper_amount'
|| ', f.oper_currency'
|| ', f.oper_date'
|| ', o.host_date'
|| ', f.sttl_amount'
|| ', f.sttl_currency'
|| ', f.arn'
|| ', f.acq_business_id'
|| ', f.merchant_name'
|| ', f.merchant_city'
|| ', f.merchant_country'
|| ', f.merchant_postal_code'
|| ', f.merchant_region'
|| ', f.mcc'
|| ', f.req_pay_service'
|| ', f.usage_code'
|| ', f.reason_code'
|| ', f.settlement_flag'
|| ', f.auth_char_ind'
|| ', f.auth_code'
|| ', f.pos_terminal_cap'
|| ', f.inter_fee_ind'
|| ', f.crdh_id_method'
|| ', f.collect_only_flag'
|| ', f.pos_entry_mode'
|| ', f.central_proc_date'
|| ', f.reimburst_attr'
|| ', f.iss_workst_bin'
|| ', f.acq_workst_bin'
|| ', f.chargeback_ref_num'
|| ', f.docum_ind'
|| ', f.member_msg_text'
|| ', f.spec_cond_ind'
|| ', f.fee_program_ind'
|| ', f.issuer_charge'
|| ', f.merchant_number'
|| ', f.terminal_number'
|| ', f.national_reimb_fee'
|| ', f.electr_comm_ind'
|| ', f.spec_chargeback_ind'
|| ', f.interface_trace_num'
|| ', f.unatt_accept_term_ind'
|| ', f.prepaid_card_ind'
|| ', f.service_development'
|| ', f.avs_resp_code'
|| ', f.auth_source_code'
|| ', f.purch_id_format'
|| ', f.account_selection'
|| ', f.installment_pay_count'
|| ', f.purch_id'
|| ', f.cashback'
|| ', f.chip_cond_code'
|| ', f.transaction_id'
|| ', f.pos_environment'
|| ', f.transaction_type'
|| ', f.card_seq_number'
|| ', f.terminal_profile'
|| ', f.unpredict_number'
|| ', f.appl_trans_counter'
|| ', f.appl_interch_profile'
|| ', f.cryptogram'
|| ', f.term_verif_result'
|| ', f.cryptogram_amount'
|| ', f.card_expir_date'
|| ', f.cryptogram_version'
|| ', f.cvv2_result_code'
|| ', f.auth_resp_code'
|| ', f.card_verif_result'
|| ', f.floor_limit_ind'
|| ', f.exept_file_ind'
|| ', f.pcas_ind'
|| ', f.issuer_appl_data'
|| ', f.issuer_script_result'
|| ', f.network_amount'
|| ', f.network_currency'
|| ', f.dispute_id'
|| ', f.file_id'
|| ', f.batch_id'
|| ', f.record_number'
|| ', f.rrn'
|| ', f.acquirer_bin'
|| ', f.merchant_street'
|| ', f.cryptogram_info_data'
|| ', f.merchant_verif_value'
|| ', f.host_inst_id'
|| ', f.proc_bin'
|| ', f.chargeback_reason_code'
|| ', f.destination_channel'
|| ', f.source_channel'
|| ', f.acq_inst_bin'
|| ', f.spend_qualified_ind'
|| ', f.clearing_sequence_num'
|| ', f.clearing_sequence_count'
|| ', f.service_code'
|| ', f.business_format_code'
|| ', f.token_assurance_level'
|| ', f.pan_token'
|| ', f.validation_code'
|| ', f.payment_forms_num'
|| ', f.business_format_code_e'
|| ', f.agent_unique_id'
|| ', f.additional_auth_method'
|| ', f.additional_reason_code'
|| ', f.product_id'
|| ', f.auth_amount'
|| ', f.auth_currency'
|| ', f.form_factor_indicator'

|| ', fast_funds_indicator'
|| ', business_format_code_3'
|| ', business_application_id'
|| ', source_of_funds'
|| ', payment_reversal_code'
|| ', sender_reference_number'
|| ', sender_account_number'
|| ', sender_name'
|| ', sender_address'
|| ', sender_city'
|| ', sender_state'
|| ', sender_country'
|| ', f.network_code'
|| ', surcharge_amount'
|| ', surcharge_sign'
|| ', o.oper_request_amount'
|| ', dcc_indicator'
|| ', message_reason_code'
|| ', dispute_condition'
|| ', vrol_financial_id'
|| ', vrol_case_number'
|| ', vrol_bundle_number'
|| ', client_case_number'
|| ', dispute_status'
|| ', payment_acc_ref'
|| ', token_requestor_id'
|| ', f.terminal_country'

|| ', f.trans_comp_number_tcr3'
|| ', f.business_application_id_tcr3'
|| ', f.business_format_code_tcr3'
|| ', f.passenger_name'
|| ', f.departure_date'
|| ', f.orig_city_airport_code'
|| ', f.carrier_code_1'
|| ', f.service_class_code_1'
|| ', f.stop_over_code_1'
|| ', f.dest_city_airport_code_1'
|| ', f.carrier_code_2'
|| ', f.service_class_code_2'
|| ', f.stop_over_code_2'
|| ', f.dest_city_airport_code_2'
|| ', f.carrier_code_3'
|| ', f.service_class_code_3'
|| ', f.stop_over_code_3'
|| ', f.dest_city_airport_code_3'
|| ', f.carrier_code_4'
|| ', f.service_class_code_4'
|| ', f.stop_over_code_4'
|| ', f.dest_city_airport_code_4'
|| ', f.travel_agency_code'
|| ', f.travel_agency_name'
|| ', f.restrict_ticket_indicator'
|| ', f.fare_basis_code_1'
|| ', f.fare_basis_code_2'
|| ', f.fare_basis_code_3'
|| ', f.fare_basis_code_4'
|| ', f.comp_reserv_system'
|| ', f.flight_number_1'
|| ', f.flight_number_2'
|| ', f.flight_number_3'
|| ', f.flight_number_4'
|| ', f.credit_reason_indicator'
|| ', f.ticket_change_indicator'
|| ', f.recipient_name'
;

-- fraud fields
G_COLUMN_LIST_FRAUD_NULL    constant com_api_type_pkg.t_text :=
   ',null dest_bin'
|| ',null source_bin'
|| ',null account_number'
|| ',null fraud_amount'
|| ',null fraud_currency'
|| ',null vic_processing_date'
|| ',null iss_gen_auth'
|| ',null notification_code'
|| ',null account_seq_number'
|| ',null reserved'
|| ',null fraud_type'
|| ',null fraud_inv_status'
|| ',null addendum_present'
|| ',null excluded_trans_id_reason'
|| ',null multiple_clearing_seqn'
|| ',null travel_agency_id'
|| ',null cashback_ind'
|| ',null card_capability'
|| ',null crdh_activated_term_ind'
|| ',null fraud_id'
|| ',null payment_account_ref'
|| ',null fraud_network_id'
|| ',null fraud_host_inst_id'
|| ',null fraud_proc_bin'
|| ',null row_num'
;

-- fraud fields
G_COLUMN_LIST_FRAUD        constant com_api_type_pkg.t_text :=
   ', fr.dest_bin'
|| ', fr.source_bin'
|| ', fr.account_number'
|| ', fr.fraud_amount'
|| ', fr.fraud_currency'
|| ', fr.vic_processing_date'
|| ', fr.iss_gen_auth'
|| ', fr.notification_code'
|| ', fr.account_seq_number'
|| ', fr.reserved'
|| ', fr.fraud_type'
|| ', fr.fraud_inv_status'
|| ', fr.addendum_present'
|| ', fr.excluded_trans_id_reason'
|| ', fr.multiple_clearing_seqn'
|| ', fr.travel_agency_id'
|| ', fr.cashback_ind'
|| ', fr.card_capability'
|| ', fr.crdh_activated_term_ind'
|| ', fr.id as fraud_id'
|| ', fr.payment_account_ref'
|| ', fr.network_id as fraud_network_id'
|| ', fr.host_inst_id as fraud_host_inst_id'
|| ', fr.proc_bin as fraud_proc_bin'
|| ', row_number() over (partition by fr.dispute_id order by fr.id) row_num'
;

function get_ecommerce_indicator(
    i_auth_rec       in     aut_api_type_pkg.t_auth_rec
  , i_pre_auth       in     aut_api_type_pkg.t_auth_rec             default null
  , i_fin_rec        in     vis_api_type_pkg.t_visa_fin_mes_rec     default null
  , i_visa_dialect   in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_byte_char is
    l_electr_comm_ind       com_api_type_pkg.t_byte_char;
    l_sub_add_data          com_api_type_pkg.t_mcc;
    l_ucaf                  com_api_type_pkg.t_mcc;
begin

    l_electr_comm_ind := substr(
        trim(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR
            )
        )
      , -1
    );

    if l_electr_comm_ind is null then
        for r in (
            select ecommerce_indicator
              from (
                select v.ecommerce_indicator
                     , v.iso_msg_type
                  from aup_visa_basei v
                 where v.auth_id = i_auth_rec.id
                   and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT, vis_api_const_pkg.VISA_DIALECT_TIETO)
            )
             order by iso_msg_type
        ) loop
            return r.ecommerce_indicator;
        end loop;

        if i_auth_rec.pos_cond_code = '08' then
            l_electr_comm_ind := '1';
        elsif i_auth_rec.crdh_presence = 'F2250004'
          and com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.merchant_country) = vis_api_const_pkg.VISA_REGION_USA then
            -- recurring payments indicator for USA
            l_electr_comm_ind := '2';
        elsif i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS then
            l_electr_comm_ind :=
                case
                    when substr(i_pre_auth.certificate_method, -1) = '1' and
                         substr(i_pre_auth.certificate_type, -1) = '1'
                    then '9'
                    when substr(i_pre_auth.certificate_method, -1) = '1' and
                         substr(i_pre_auth.certificate_type, -1) = '2'
                    then '5'
                    when substr(i_pre_auth.certificate_method, -1) = '1' then
                        case substr(i_pre_auth.ucaf_indicator, -1)
                            when '0' then '7'
                            when '1' then '6'
                            when '2' then '5'
                        end
                    when substr(i_pre_auth.certificate_method, -1) = '3' and
                         substr(i_pre_auth.certificate_type, -1) = '1'
                    then '6'
                    when substr(i_pre_auth.certificate_method, -1) = '3' and
                         substr(i_pre_auth.certificate_type, -1) = '2'
                    then '5'
                    when substr(i_pre_auth.certificate_method, -1) = '9'
                    then '8'
                end;

            if l_electr_comm_ind is null then
                l_electr_comm_ind :=
                    case 
                        when i_auth_rec.card_data_input_mode  = 'F227000S'
                             and i_auth_rec.crdh_auth_method is null 
                        then '8'
                        when i_auth_rec.card_data_input_mode in ('F2270007', 'F227000E', 'F2270001')
                             and i_auth_rec.crdh_auth_method  = 'F2280000'
                        then '7'
                        when i_auth_rec.card_data_input_mode  = 'F2270007'
                             and i_auth_rec.crdh_auth_method in ('F2280009', 'F228000W', 'F228000X')
                        then '6'
                        when i_auth_rec.card_data_input_mode in ('F2270007', 'F227000E', 'F2270001')
                             and i_auth_rec.crdh_auth_method  = 'F228000S'
                        then '5'
                    end;
            end if;

            if l_electr_comm_ind is null then

                l_sub_add_data  := substr(i_auth_rec.addl_data, 1, 2);
                l_ucaf          := substr(i_auth_rec.addl_data, 203, 1);

                if l_sub_add_data = '11' then
                    l_electr_comm_ind := '9';

                elsif l_sub_add_data = '12' then
                    l_electr_comm_ind := '5';

                elsif l_sub_add_data in ('21', '22') then
                    if l_ucaf = '0' then
                        l_electr_comm_ind := '7';
                    elsif l_ucaf = '1' then
                        l_electr_comm_ind := '6';
                    elsif l_ucaf = '2' then
                        l_electr_comm_ind := '5';
                    end if;

                elsif l_sub_add_data = '31' then
                    l_electr_comm_ind := '6';

                elsif l_sub_add_data = '32' then
                    l_electr_comm_ind := '5';

                elsif l_sub_add_data = '90' then
                    l_electr_comm_ind := '8';

                elsif l_sub_add_data = '01' then
                    if l_ucaf = '1' then
                       l_electr_comm_ind := '6';
                    elsif l_ucaf = '2' then
                       l_electr_comm_ind := '5';
                    elsif l_ucaf = '3' then
                       l_electr_comm_ind := '9';
                    else
                       l_electr_comm_ind := '7';
                    end if;

                elsif l_sub_add_data = '02' then
                    l_electr_comm_ind := '8';

                elsif l_sub_add_data = '03' then
                    l_electr_comm_ind := '9';
                end if;
            end if;
        elsif i_auth_rec.mcc in (5960, 5962, 5964, 5965, 5966, 5967, 5968, 5969) then
            l_electr_comm_ind := '1';
        end if;
    end if;

    return l_electr_comm_ind;
end get_ecommerce_indicator;

procedure get_fin_mes(
    i_id                       in     com_api_type_pkg.t_long_id
  , o_fin_rec                     out vis_api_type_pkg.t_visa_fin_mes_rec
  , i_mask_error               in     com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statement             com_api_type_pkg.t_sql_statement;
begin
    l_statement :=
        'select ' || G_COLUMN_LIST
        || ' from'
        ||   ' vis_fin_message_vw f'
        || ' , vis_card c'
        || ' where'
        || ' f.id = :i_id'
        || ' and f.id = c.id(+)';

    open l_fin_cur for l_statement using i_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        else
            trc_log_pkg.error (
                i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        end if;
    end if;
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end get_fin_mes;

procedure get_fin_message(
    i_id                       in     com_api_type_pkg.t_long_id
  , o_fin_fields                  out com_api_type_pkg.t_param_tab
  , i_mask_error               in     com_api_type_pkg.t_boolean
) is
begin
    begin
        select f.id
             , f.status
             , f.file_id
             , f.batch_id
             , f.record_number
             , f.is_reversal
             , f.is_incoming
             , f.is_returned
             , f.is_invalid
             , f.dispute_id
             , f.rrn
             , f.inst_id
             , f.network_id
             , f.trans_code
             , f.trans_code_qualifier
             , f.card_id
             , f.card_mask
             , f.card_hash
             , f.oper_amount
             , f.oper_currency
             , f.oper_date
             , f.sttl_amount
             , f.sttl_currency
             , f.network_amount
             , f.network_currency
             , f.floor_limit_ind
             , f.exept_file_ind
             , f.pcas_ind
             , f.arn
             , f.acquirer_bin
             , f.acq_business_id
             , f.merchant_name
             , f.merchant_city
             , f.merchant_country
             , f.merchant_postal_code
             , f.merchant_region
             , f.merchant_street
             , f.mcc
             , f.req_pay_service
             , f.usage_code
             , f.reason_code
             , f.settlement_flag
             , f.auth_char_ind
             , f.auth_code
             , f.pos_terminal_cap
             , f.inter_fee_ind
             , f.crdh_id_method
             , f.collect_only_flag
             , f.pos_entry_mode
             , f.central_proc_date
             , f.reimburst_attr
             , f.iss_workst_bin
             , f.acq_workst_bin
             , f.chargeback_ref_num
             , f.docum_ind
             , f.member_msg_text
             , f.spec_cond_ind
             , f.fee_program_ind
             , f.issuer_charge
             , f.merchant_number
             , f.terminal_number
             , f.national_reimb_fee
             , f.electr_comm_ind
             , f.spec_chargeback_ind
             , f.interface_trace_num
             , f.unatt_accept_term_ind
             , f.prepaid_card_ind
             , f.service_development
             , f.avs_resp_code
             , f.auth_source_code
             , f.purch_id_format
             , f.account_selection
             , f.installment_pay_count
             , f.purch_id
             , f.cashback
             , f.chip_cond_code
             , f.pos_environment
             , f.transaction_type
             , f.card_seq_number
             , f.terminal_profile
             , f.unpredict_number
             , f.appl_trans_counter
             , f.appl_interch_profile
             , f.cryptogram
             , f.term_verif_result
             , f.cryptogram_amount
             , f.card_verif_result
             , f.issuer_appl_data
             , f.issuer_script_result
             , f.card_expir_date
             , f.cryptogram_version
             , f.cvv2_result_code
             , f.auth_resp_code
             , f.cryptogram_info_data
             , f.transaction_id
             , f.merchant_verif_value
             , f.host_inst_id
             , f.proc_bin
             , f.chargeback_reason_code
             , f.destination_channel
             , f.source_channel
             , f.acq_inst_bin
             , f.spend_qualified_ind
             , f.clearing_sequence_num
             , f.clearing_sequence_count
             , f.service_code
             , f.business_format_code
             , f.token_assurance_level
             , f.pan_token
             , f.validation_code
             , f.payment_forms_num
             , f.business_format_code_e
             , f.agent_unique_id
             , f.additional_auth_method
             , f.additional_reason_code
             , f.product_id
             , f.auth_amount
             , f.auth_currency
             , f.form_factor_indicator
             , f.fast_funds_indicator
             , f.business_format_code_3
             , f.business_application_id
             , f.source_of_funds
             , f.payment_reversal_code
             , f.sender_reference_number
             , f.sender_account_number
             , f.sender_name
             , f.sender_address
             , f.sender_city
             , f.sender_state
             , f.sender_country
             , f.network_code
             , f.fee_interchange_amount
             , f.fee_interchange_sign
             , f.program_id
             , f.dcc_indicator
             , f.is_rejected
             , f.trans_comp_number
             , f.business_format_code_4
             , f.contact_information
             , f.adjustment_indicator
             , f.message_reason_code
             , f.dispute_condition
             , f.vrol_financial_id
             , f.vrol_case_number
             , f.vrol_bundle_number
             , f.client_case_number
             , f.dispute_status
             , f.surcharge_amount
             , f.surcharge_sign
             , f.payment_acc_ref
             , f.token_requestor_id
             , f.terminal_country
             , f.trans_comp_number_tcr3
             , f.business_application_id_tcr3
             , f.business_format_code_tcr3
             , f.passenger_name
             , f.departure_date
             , f.orig_city_airport_code
             , f.carrier_code_1
             , f.service_class_code_1
             , f.stop_over_code_1
             , f.dest_city_airport_code_1
             , f.carrier_code_2
             , f.service_class_code_2
             , f.stop_over_code_2
             , f.dest_city_airport_code_2
             , f.carrier_code_3
             , f.service_class_code_3
             , f.stop_over_code_3
             , f.dest_city_airport_code_3
             , f.carrier_code_4
             , f.service_class_code_4
             , f.stop_over_code_4
             , f.dest_city_airport_code_4
             , f.travel_agency_code
             , f.travel_agency_name
             , f.restrict_ticket_indicator
             , f.fare_basis_code_1
             , f.fare_basis_code_2
             , f.fare_basis_code_3
             , f.fare_basis_code_4
             , f.comp_reserv_system
             , f.flight_number_1
             , f.flight_number_2
             , f.flight_number_3
             , f.flight_number_4
             , f.credit_reason_indicator
             , f.ticket_change_indicator
             , f.recipient_name
             , f.terminal_trans_date
             , f.conv_date
             , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
          into o_fin_fields('id')
             , o_fin_fields('status')
             , o_fin_fields('file_id')
             , o_fin_fields('batch_id')
             , o_fin_fields('record_number')
             , o_fin_fields('is_reversal')
             , o_fin_fields('is_incoming')
             , o_fin_fields('is_returned')
             , o_fin_fields('is_invalid')
             , o_fin_fields('dispute_id')
             , o_fin_fields('rrn')
             , o_fin_fields('inst_id')
             , o_fin_fields('network_id')
             , o_fin_fields('trans_code')
             , o_fin_fields('trans_code_qualifier')
             , o_fin_fields('card_id')
             , o_fin_fields('card_mask')
             , o_fin_fields('card_hash')
             , o_fin_fields('oper_amount')
             , o_fin_fields('oper_currency')
             , o_fin_fields('oper_date')
             , o_fin_fields('sttl_amount')
             , o_fin_fields('sttl_currency')
             , o_fin_fields('network_amount')
             , o_fin_fields('network_currency')
             , o_fin_fields('floor_limit_ind')
             , o_fin_fields('exept_file_ind')
             , o_fin_fields('pcas_ind')
             , o_fin_fields('arn')
             , o_fin_fields('acquirer_bin')
             , o_fin_fields('acq_business_id')
             , o_fin_fields('merchant_name')
             , o_fin_fields('merchant_city')
             , o_fin_fields('merchant_country')
             , o_fin_fields('merchant_postal_code')
             , o_fin_fields('merchant_region')
             , o_fin_fields('merchant_street')
             , o_fin_fields('mcc')
             , o_fin_fields('req_pay_service')
             , o_fin_fields('usage_code')
             , o_fin_fields('reason_code')
             , o_fin_fields('settlement_flag')
             , o_fin_fields('auth_char_ind')
             , o_fin_fields('auth_code')
             , o_fin_fields('pos_terminal_cap')
             , o_fin_fields('inter_fee_ind')
             , o_fin_fields('crdh_id_method')
             , o_fin_fields('collect_only_flag')
             , o_fin_fields('pos_entry_mode')
             , o_fin_fields('central_proc_date')
             , o_fin_fields('reimburst_attr')
             , o_fin_fields('iss_workst_bin')
             , o_fin_fields('acq_workst_bin')
             , o_fin_fields('chargeback_ref_num')
             , o_fin_fields('docum_ind')
             , o_fin_fields('member_msg_text')
             , o_fin_fields('spec_cond_ind')
             , o_fin_fields('fee_program_ind')
             , o_fin_fields('issuer_charge')
             , o_fin_fields('merchant_number')
             , o_fin_fields('terminal_number')
             , o_fin_fields('national_reimb_fee')
             , o_fin_fields('electr_comm_ind')
             , o_fin_fields('spec_chargeback_ind')
             , o_fin_fields('interface_trace_num')
             , o_fin_fields('unatt_accept_term_ind')
             , o_fin_fields('prepaid_card_ind')
             , o_fin_fields('service_development')
             , o_fin_fields('avs_resp_code')
             , o_fin_fields('auth_source_code')
             , o_fin_fields('purch_id_format')
             , o_fin_fields('account_selection')
             , o_fin_fields('installment_pay_count')
             , o_fin_fields('purch_id')
             , o_fin_fields('cashback')
             , o_fin_fields('chip_cond_code')
             , o_fin_fields('pos_environment')
             , o_fin_fields('transaction_type')
             , o_fin_fields('card_seq_number')
             , o_fin_fields('terminal_profile')
             , o_fin_fields('unpredict_number')
             , o_fin_fields('appl_trans_counter')
             , o_fin_fields('appl_interch_profile')
             , o_fin_fields('cryptogram')
             , o_fin_fields('term_verif_result')
             , o_fin_fields('cryptogram_amount')
             , o_fin_fields('card_verif_result')
             , o_fin_fields('issuer_appl_data')
             , o_fin_fields('issuer_script_result')
             , o_fin_fields('card_expir_date')
             , o_fin_fields('cryptogram_version')
             , o_fin_fields('cvv2_result_code')
             , o_fin_fields('auth_resp_code')
             , o_fin_fields('cryptogram_info_data')
             , o_fin_fields('transaction_id')
             , o_fin_fields('merchant_verif_value')
             , o_fin_fields('host_inst_id')
             , o_fin_fields('proc_bin')
             , o_fin_fields('chargeback_reason_code')
             , o_fin_fields('destination_channel')
             , o_fin_fields('source_channel')
             , o_fin_fields('acq_inst_bin')
             , o_fin_fields('spend_qualified_ind')
             , o_fin_fields('clearing_sequence_num')
             , o_fin_fields('clearing_sequence_count')
             , o_fin_fields('service_code')
             , o_fin_fields('business_format_code')
             , o_fin_fields('token_assurance_level')
             , o_fin_fields('pan_token')
             , o_fin_fields('validation_code')
             , o_fin_fields('payment_forms_num')
             , o_fin_fields('business_format_code_e')
             , o_fin_fields('agent_unique_id')
             , o_fin_fields('additional_auth_method')
             , o_fin_fields('additional_reason_code')
             , o_fin_fields('product_id')
             , o_fin_fields('auth_amount')
             , o_fin_fields('auth_currency')
             , o_fin_fields('form_factor_indicator')
             , o_fin_fields('fast_funds_indicator')
             , o_fin_fields('business_format_code_3')
             , o_fin_fields('business_application_id')
             , o_fin_fields('source_of_funds')
             , o_fin_fields('payment_reversal_code')
             , o_fin_fields('sender_reference_number')
             , o_fin_fields('sender_account_number')
             , o_fin_fields('sender_name')
             , o_fin_fields('sender_address')
             , o_fin_fields('sender_city')
             , o_fin_fields('sender_state')
             , o_fin_fields('sender_country')
             , o_fin_fields('network_code')
             , o_fin_fields('fee_interchange_amount')
             , o_fin_fields('fee_interchange_sign')
             , o_fin_fields('program_id')
             , o_fin_fields('dcc_indicator')
             , o_fin_fields('is_rejected')
             , o_fin_fields('trans_comp_number')
             , o_fin_fields('business_format_code_4')
             , o_fin_fields('contact_information')
             , o_fin_fields('adjustment_indicator')
             , o_fin_fields('message_reason_code')
             , o_fin_fields('dispute_condition')
             , o_fin_fields('vrol_financial_id')
             , o_fin_fields('vrol_case_number')
             , o_fin_fields('vrol_bundle_number')
             , o_fin_fields('client_case_number')
             , o_fin_fields('dispute_status')
             , o_fin_fields('surcharge_amount')
             , o_fin_fields('surcharge_sign')
             , o_fin_fields('payment_acc_ref')
             , o_fin_fields('token_requestor_id')
             , o_fin_fields('terminal_country')
             , o_fin_fields('trans_comp_number_tcr3')
             , o_fin_fields('business_application_id_tcr3')
             , o_fin_fields('business_format_code_tcr3')
             , o_fin_fields('passenger_name')
             , o_fin_fields('departure_date')
             , o_fin_fields('orig_city_airport_code')
             , o_fin_fields('carrier_code_1')
             , o_fin_fields('service_class_code_1')
             , o_fin_fields('stop_over_code_1')
             , o_fin_fields('dest_city_airport_code_1')
             , o_fin_fields('carrier_code_2')
             , o_fin_fields('service_class_code_2')
             , o_fin_fields('stop_over_code_2')
             , o_fin_fields('dest_city_airport_code_2')
             , o_fin_fields('carrier_code_3')
             , o_fin_fields('service_class_code_3')
             , o_fin_fields('stop_over_code_3')
             , o_fin_fields('dest_city_airport_code_3')
             , o_fin_fields('carrier_code_4')
             , o_fin_fields('service_class_code_4')
             , o_fin_fields('stop_over_code_4')
             , o_fin_fields('dest_city_airport_code_4')
             , o_fin_fields('travel_agency_code')
             , o_fin_fields('travel_agency_name')
             , o_fin_fields('restrict_ticket_indicator')
             , o_fin_fields('fare_basis_code_1')
             , o_fin_fields('fare_basis_code_2')
             , o_fin_fields('fare_basis_code_3')
             , o_fin_fields('fare_basis_code_4')
             , o_fin_fields('comp_reserv_system')
             , o_fin_fields('flight_number_1')
             , o_fin_fields('flight_number_2')
             , o_fin_fields('flight_number_3')
             , o_fin_fields('flight_number_4')
             , o_fin_fields('credit_reason_indicator')
             , o_fin_fields('ticket_change_indicator')
             , o_fin_fields('recipient_name')
             , o_fin_fields('terminal_trans_date')
             , o_fin_fields('conv_date')
             , o_fin_fields('card_number')
          from      vis_fin_message_vw f
          left join vis_card           c    on f.id = c.id
         where f.id = i_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_id
              , i_mask_error  => i_mask_error
            );
    end;
exception
    when com_api_error_pkg.e_application_error then
        null;
end get_fin_message;

function estimate_messages_for_upload(
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) return number is
    l_result                number;
begin
    select /*+ INDEX(f, vis_fin_message_CLMS0010_ndx)*/
           count(f.id)
      into l_result
      from vis_fin_message f
         , opr_operation o
     where decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
       and f.is_incoming = 0
       and f.id = o.id
       and f.network_id = i_network_id
       and f.inst_id = i_inst_id
       and f.host_inst_id = i_host_inst_id
       and (
            (i_start_date is null and i_end_date is null)
            or
            (f.oper_date between nvl(i_start_date, trunc(f.oper_date)) and nvl(i_end_date, trunc(f.oper_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_const_pkg.FALSE
            )
            or
            (o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_const_pkg.TRUE
            )
           );

    return l_result;
end estimate_messages_for_upload;

function estimate_fin_fraud_for_upload(
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) return number is
    l_result                number;
begin
  select sum(cnt)
    into l_result
    from ( select /*+ INDEX(f, vis_fin_message_CLMS0010_ndx)*/
                  count(f.id) cnt
             from vis_fin_message f
                , opr_operation o
            where decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
              and f.is_incoming  = com_api_const_pkg.FALSE
              and f.id           = o.id
              and f.network_id   = i_network_id
              and f.inst_id      = i_inst_id
              and f.host_inst_id = i_host_inst_id
              and (
                   (i_start_date is null and i_end_date is null)
                   or
                   (f.oper_date between nvl(i_start_date, trunc(f.oper_date)) and nvl(i_end_date, trunc(f.oper_date)) + 1 - com_api_const_pkg.ONE_SECOND
                       and f.is_reversal = com_api_const_pkg.FALSE
                   )
                   or
                   (o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                       and f.is_reversal = com_api_const_pkg.TRUE
                   )
                  )
           union all
           select count(fr.id)
             from vis_fraud fr
            where decode(fr.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
              and fr.network_id   = i_network_id
              and fr.inst_id      = i_inst_id
              and fr.host_inst_id = i_host_inst_id
              and exists (select 1
                            from opr_operation o
                               , vis_fin_message f
                           where o.dispute_id   = fr.dispute_id
                             and f.id           = o.id
                             and f.is_incoming  = com_api_const_pkg.TRUE
                             and (
                                  (i_start_date is null and i_end_date is null)
                                  or
                                  (f.oper_date between nvl(i_start_date, trunc(f.oper_date)) and nvl(i_end_date, trunc(f.oper_date)) + 1 - com_api_const_pkg.ONE_SECOND
                                      and f.is_reversal = com_api_const_pkg.FALSE
                                  )
                                  or
                                  (o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                                      and f.is_reversal = com_api_const_pkg.TRUE
                                  )
                                 )
                         )
         );

    return l_result;
end estimate_fin_fraud_for_upload;

procedure enum_messages_for_upload(
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) is
    DATE_PLACEHOLDER        constant com_api_type_pkg.t_name := '##DATE##';
    l_stmt                  com_api_type_pkg.t_sql_statement;
begin
    l_stmt := '
select /*+ INDEX(f, vis_fin_message_CLMS0010_ndx)*/
    ' || G_COLUMN_LIST || '
from
    vis_fin_message_vw f
  , vis_card c
  , opr_operation o
where
    decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
             || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
    || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
    and f.is_incoming = :is_incoming
    and f.id = o.id
    and f.network_id = :i_network_id
    and f.inst_id = :i_inst_id
    and f.host_inst_id = :i_host_inst_id
    and c.id(+) = f.id ' || DATE_PLACEHOLDER || '
order by
    f.proc_bin
  , f.trans_code';

    l_stmt := replace (
        l_stmt
      , DATE_PLACEHOLDER
      , case
            when i_start_date is not null or i_end_date is not null then '
    and (f.oper_date between nvl(:i_start_date, trunc(f.oper_date))
                         and nvl(:i_end_date, trunc(f.oper_date)) + 1 - 1/86400
         and f.is_reversal = ' || com_api_type_pkg.FALSE || '
         or
         o.host_date between nvl(:i_start_date, trunc(o.host_date))
                         and nvl(:i_end_date, trunc(o.host_date)) + 1 - 1/86400
         and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
            else
                ' '
        end
    );

    if i_start_date is not null or i_end_date is not null then
        open o_fin_cur for l_stmt
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id
            , i_start_date, i_end_date, i_start_date, i_end_date;
    else
        open o_fin_cur for l_stmt
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT)  || '.enum_messages_for_upload >> FAILED with l_stmt:'
                   || chr(13) || chr(10)   || l_stmt
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end enum_messages_for_upload;

procedure enum_fin_msg_fraud_for_upload(
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) is
    DATE_PLACEHOLDER        constant com_api_type_pkg.t_name := '##DATE##';
    l_stmt                  com_api_type_pkg.t_sql_statement;
begin
    l_stmt := '
select * from
(
    select /*+ INDEX(f, vis_fin_message_CLMS0010_ndx)*/
        ' || G_COLUMN_LIST_FIN_FR || ', f.trans_code, ' ||
        'iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
          || G_COLUMN_LIST_FRAUD_NULL || '
    from
        vis_fin_message_vw f
      , vis_card c
      , opr_operation o
    where
        decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
                 || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
        || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
        and f.is_incoming = :is_incoming_0
        and f.id = o.id
        and f.network_id = :i_network_id
        and f.inst_id = :i_inst_id
        and f.host_inst_id = :i_host_inst_id
        and c.id(+) = f.id ' || DATE_PLACEHOLDER || '
    union
    select * from
    ( select
        ' || G_COLUMN_LIST_FIN_FR || ',''40'' as trans_code, null' || G_COLUMN_LIST_FRAUD || '
      from
        vis_fraud fr
        , opr_operation o
        , vis_fin_message_vw f
      where
        decode(fr.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
        and o.dispute_id = fr.dispute_id
        and f.id = o.id
        and f.is_incoming = :is_incoming_1
        and fr.network_id = :i_network_id
        and fr.inst_id = :i_inst_id
        and fr.host_inst_id = :i_host_inst_id ' || DATE_PLACEHOLDER || '
    )
    where
        nvl(row_num, 1) = 1
)
order by
    decode(is_incoming, ' || com_api_type_pkg.FALSE || ', proc_bin, fraud_proc_bin)
  , trans_code';

    l_stmt := replace (
        l_stmt
      , DATE_PLACEHOLDER
      , case
            when i_start_date is not null or i_end_date is not null then '
    and (f.oper_date between nvl(:i_start_date, trunc(f.oper_date))
                         and nvl(:i_end_date, trunc(f.oper_date)) + 1 - 1/86400
         and f.is_reversal = ' || com_api_type_pkg.FALSE || '
         or
         o.host_date between nvl(:i_start_date, trunc(o.host_date))
                         and nvl(:i_end_date, trunc(o.host_date)) + 1 - 1/86400
         and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
            else
                ' '
        end
    );

    if i_start_date is not null or i_end_date is not null then
        open o_fin_cur for l_stmt
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id, i_start_date, i_end_date, i_start_date, i_end_date
            , com_api_type_pkg.TRUE,  i_network_id, i_inst_id, i_host_inst_id, i_start_date, i_end_date, i_start_date, i_end_date;
    else
        open o_fin_cur for l_stmt
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id
            , com_api_type_pkg.TRUE,  i_network_id, i_inst_id, i_host_inst_id;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT)  || '.enum_fin_msg_fraud_for_upload >> FAILED with l_stmt:'
                   || chr(13) || chr(10)   || l_stmt
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end enum_fin_msg_fraud_for_upload;

function get_original_id(
    i_fin_rec               in vis_api_type_pkg.t_visa_fin_mes_rec
  , i_fee_rec               in vis_api_type_pkg.t_fee_rec          default null
) return com_api_type_pkg.t_long_id
is
    l_need_original_id         com_api_type_pkg.t_boolean;
begin
    return get_original_id (
               i_fin_rec          =>  i_fin_rec
             , i_fee_rec          =>  i_fee_rec
             , o_need_original_id => l_need_original_id
           );
end get_original_id;

function get_original_id(
    i_fin_rec               in vis_api_type_pkg.t_visa_fin_mes_rec
  , i_fee_rec               in vis_api_type_pkg.t_fee_rec          default null
  , o_need_original_id     out com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_long_id
is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_original_id: ';
    l_original_id              com_api_type_pkg.t_long_id;
    l_usage_code               com_api_type_pkg.t_curr_code;
    l_tc1                      com_api_type_pkg.t_curr_code;
    l_tc2                      com_api_type_pkg.t_curr_code;
    l_tc3                      com_api_type_pkg.t_curr_code;
    l_tc4                      com_api_type_pkg.t_curr_code;
    l_tc5                      com_api_type_pkg.t_curr_code;
    l_tc6                      com_api_type_pkg.t_curr_code;
    l_tc7                      com_api_type_pkg.t_curr_code;
    l_fee_code                 com_api_type_pkg.t_curr_code;
begin
    o_need_original_id := com_api_const_pkg.FALSE;

    if i_fin_rec.usage_code in ('9') then
        case
              -- representment
            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES
                                        , vis_api_const_pkg.TC_VOUCHER
                                        , vis_api_const_pkg.TC_CASH)
              -- chargeback reversal
              or i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                        , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV)
            then
                l_usage_code := '9';
                l_tc1 := vis_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc3 := vis_api_const_pkg.TC_CASH_CHARGEBACK;
            
            -- chargeback
            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK
                                        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                                        , vis_api_const_pkg.TC_CASH_CHARGEBACK)
            then
                l_usage_code := '1';
                l_tc1 := vis_api_const_pkg.TC_SALES;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER;
                l_tc3 := vis_api_const_pkg.TC_CASH;
            
            -- representment reversal
            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES_REVERSAL
                                        , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                                        , vis_api_const_pkg.TC_CASH_REVERSAL)
            then
                l_usage_code := '9';
                l_tc1 := vis_api_const_pkg.TC_SALES;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER;
                l_tc3 := vis_api_const_pkg.TC_CASH;

            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
                                        , vis_api_const_pkg.TC_FEE_COLLECTION)
            then
                l_usage_code := '9';
                l_tc1 := vis_api_const_pkg.TC_FEE_COLLECTION;
                l_tc2 := vis_api_const_pkg.TC_FUNDS_DISBURSEMENT;
                
            -- VCR advice
            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE)
            then
                l_usage_code := '1';
                l_tc1 := vis_api_const_pkg.TC_SALES;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER;
                l_tc3 := vis_api_const_pkg.TC_CASH;
            else
                l_usage_code := '1';
                l_tc1 := vis_api_const_pkg.TC_SALES;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER;
                l_tc3 := vis_api_const_pkg.TC_CASH;
        end case;
        
    elsif i_fin_rec.usage_code in ('1') then
        l_usage_code := '1';
        case
            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES
                                        , vis_api_const_pkg.TC_VOUCHER
                                        , vis_api_const_pkg.TC_CASH)
            then
                return null;

            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                        , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV)
            then
                l_tc1 := vis_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc3 := vis_api_const_pkg.TC_CASH_CHARGEBACK;

            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_FUNDS_DISBURSEMENT
                                        , vis_api_const_pkg.TC_FEE_COLLECTION)
            then
                l_tc1 := vis_api_const_pkg.TC_FEE_COLLECTION;
                l_tc2 := vis_api_const_pkg.TC_SALES;
                l_tc3 := vis_api_const_pkg.TC_VOUCHER;
                l_tc4 := vis_api_const_pkg.TC_CASH;
                l_tc5 := vis_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc6 := vis_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc7 := vis_api_const_pkg.TC_CASH_CHARGEBACK;
            
            else
                l_tc1 := vis_api_const_pkg.TC_SALES;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER;
                l_tc3 := vis_api_const_pkg.TC_CASH;
        end case;

    elsif i_fin_rec.trans_code in (vis_api_const_pkg.TC_FEE_COLLECTION
                                 , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT)
      and i_fee_rec.id is not null
    then
        l_fee_code := '1';
        l_tc1 := vis_api_const_pkg.TC_FEE_COLLECTION;
        l_tc2 := vis_api_const_pkg.TC_FUNDS_DISBURSEMENT;

    else
        l_usage_code := '2';
        case
            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                        , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV) then
                l_tc1 := vis_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc3 := vis_api_const_pkg.TC_CASH_CHARGEBACK;
            when i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES
                                        , vis_api_const_pkg.TC_VOUCHER
                                        , vis_api_const_pkg.TC_CASH) then
                l_usage_code := '1';
                l_tc1 := vis_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc3 := vis_api_const_pkg.TC_CASH_CHARGEBACK;
            else
                l_tc1 := vis_api_const_pkg.TC_SALES;
                l_tc2 := vis_api_const_pkg.TC_VOUCHER;
                l_tc3 := vis_api_const_pkg.TC_CASH;
        end case;
    end if;

    if l_usage_code is not null then
        select
            min(f.id)
        into
            l_original_id
        from
            vis_fin_message f
          , vis_card c
        where
            f.trans_code in (l_tc1, l_tc2, l_tc3, l_tc4, l_tc5, l_tc6, l_tc7)
            and f.usage_code = l_usage_code
            --and f.is_incoming = com_api_type_pkg.TRUE
            and c.card_number = iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
            and f.id = c.id
            and f.arn = i_fin_rec.arn
            and f.id != i_fin_rec.id;

    elsif l_fee_code is not null then
        -- Search by vis_fee
        select min(f.id)
          into l_original_id
          from vis_fee f
          join vis_fin_message fm on fm.id = f.id
          join vis_card        c  on  c.id = fm.id
         where fm.trans_code in (l_tc1, l_tc2, l_tc3)
           and c.card_number = iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
           and f.trans_id    = i_fee_rec.trans_id;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX
               || 'l_original_id [' || l_original_id
               || '] was found by i_fin_rec = {trans_code [' || i_fin_rec.trans_code
               || '], arn [' || i_fin_rec.arn || ']}'
               || ', i_fee_rec {trans_id [' || i_fee_rec.trans_id || ']}'
    );

    if l_original_id is null and (l_usage_code is not null or l_fee_code is not null) then
        o_need_original_id := com_api_const_pkg.TRUE;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'The required original id is not found'
        );
    end if;

    return l_original_id;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX
                         || 'FAILED with i_fee_rec.trans_id [#6]'
                         || ', i_fin_rec = {id [#5], usage_code [#1], trans_code [#2], card_number [#3], arn [#4]}'
          , i_env_param1 => i_fin_rec.usage_code
          , i_env_param2 => i_fin_rec.trans_code
          , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.card_number)
          , i_env_param4 => i_fin_rec.arn
          , i_env_param5 => i_fin_rec.id
          , i_env_param6 => i_fee_rec.trans_id
        );
        raise;
end get_original_id;

procedure get_fee(
    i_id                    in com_api_type_pkg.t_long_id
    , o_fee_rec             out vis_api_type_pkg.t_fee_rec
) is
    l_fee_cur               sys_refcursor;
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
    f.id
    , f.file_id
    , f.pay_fee
    , f.dst_bin
    , f.src_bin
    , f.reason_code
    , f.country_code
    , f.event_date
    , f.pay_amount
    , f.pay_currency
    , f.src_amount
    , f.src_currency
    , f.message_text
    , f.trans_id
    , f.reimb_attr
    , f.dst_inst_id
    , f.src_inst_id
    , f.funding_source
from
    vis_fee f
where
    f.id = :i_id';

    open l_fee_cur for l_statement using i_id;
    fetch l_fee_cur into o_fee_rec;
    close l_fee_cur;

exception
    when others then
        if l_fee_cur%isopen then
            close l_fee_cur;
        end if;
        raise;
end get_fee;

procedure get_retrieval(
    i_id                    in com_api_type_pkg.t_long_id
    , o_retrieval_rec       out vis_api_type_pkg.t_retrieval_rec
) is
    l_retrieval_cur         sys_refcursor;
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
    f.id
    , f.file_id
    , f.req_id
    , f.purchase_date
    , f.source_amount
    , f.source_currency
    , f.reason_code
    , f.national_reimb_fee
    , f.atm_account_sel
    , f.reimb_flag
    , f.fax_number
    , f.req_fulfill_method
    , f.used_fulfill_method
    , f.iss_rfc_bin
    , f.iss_rfc_subaddr
    , f.iss_billing_currency
    , f.iss_billing_amount
    , f.trans_id
    , f.excluded_trans_id_reason
    , f.crs_code
    , f.multiple_clearing_seqn
    , f.product_code
    , f.contact_info
    , f.iss_inst_id
    , f.acq_inst_id
from
    vis_retrieval f
where
    f.id = :i_id';

    open l_retrieval_cur for l_statement using i_id;
    fetch l_retrieval_cur into o_retrieval_rec;
    close l_retrieval_cur;

exception
    when others then
        if l_retrieval_cur%isopen then
            close l_retrieval_cur;
        end if;
        raise;
end get_retrieval;

procedure process_auth_tcr3_ai(
    io_fin_rec          in out  vis_api_type_pkg.t_visa_fin_mes_rec
  , i_auth_rec          in      aut_api_type_pkg.t_auth_rec
) is
begin
    -- AI
    if io_fin_rec.business_format_code_3 = vis_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER then
        io_fin_rec.trans_comp_number_tcr3 := '3';
        io_fin_rec.orig_city_airport_code := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id

          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_ORIG_CITY_AIR
        );
        io_fin_rec.carrier_code_1 := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE1
        );
        io_fin_rec.business_application_id_tcr3 := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_BUSINESS_APPLICATION_ID
        );
        io_fin_rec.passenger_name               := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_PASSENGER_NAME
        );
        io_fin_rec.departure_date               := to_date(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEPARTURE_DATE
            )
          , 'MMDDYY'
        );
        io_fin_rec.service_class_code_1         := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS1
        );
        io_fin_rec.stop_over_code_1             := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE1
        );
        io_fin_rec.dest_city_airport_code_1     := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR1
        );
        io_fin_rec.carrier_code_2               := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE2
        );
        io_fin_rec.service_class_code_2         := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS2
        );
        io_fin_rec.stop_over_code_2             := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE2
        );
        io_fin_rec.dest_city_airport_code_2     := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR2
        );
        io_fin_rec.carrier_code_3               := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE3
        );
        io_fin_rec.service_class_code_3         := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS3
        );
        io_fin_rec.stop_over_code_3             := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE3
        );
        io_fin_rec.dest_city_airport_code_3     := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR3
        );
        io_fin_rec.carrier_code_4               := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE4
        );
        io_fin_rec.service_class_code_4         := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS4
        );
        io_fin_rec.stop_over_code_4             := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE4
        );
        io_fin_rec.dest_city_airport_code_4     := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR4
        );
        io_fin_rec.travel_agency_code           := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_TRAV_AGEN_CODE
        );
        io_fin_rec.travel_agency_name           := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_TRAV_AGEN_NAME
        );
        io_fin_rec.restrict_ticket_indicator    := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_R_TICKET_INDIC
        );
        io_fin_rec.fare_basis_code_1            := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE1
        );
        io_fin_rec.fare_basis_code_2            := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE2
        );
        io_fin_rec.fare_basis_code_3            := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE3
        );
        io_fin_rec.fare_basis_code_4            := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE4
        );
        io_fin_rec.comp_reserv_system           := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_COMP_RESRV_SYS
        );
        io_fin_rec.flight_number_1              := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER1
        );
        io_fin_rec.flight_number_2              := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER2
        );
        io_fin_rec.flight_number_3              := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER3
        );
        io_fin_rec.flight_number_4              := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER4
        );
        io_fin_rec.credit_reason_indicator      := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CRD_RSN_INDIC
        );
        io_fin_rec.ticket_change_indicator      := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_TIC_CHN_INDIC
        );
    end if;
end process_auth_tcr3_ai;

procedure process_auth_tcr3_cr(
    io_fin_rec          in out  vis_api_type_pkg.t_visa_fin_mes_rec
  , i_auth_rec          in      aut_api_type_pkg.t_auth_rec
) is
    l_tag_id                com_api_type_pkg.t_short_id;
begin
    -- CR
    if io_fin_rec.trans_code in (vis_api_const_pkg.TC_VOUCHER, vis_api_const_pkg.TC_VOUCHER_REVERSAL)
       and io_fin_rec.business_format_code_3 <> vis_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER
       and io_fin_rec.trans_code_qualifier = '2'
       and i_auth_rec.mcc in (vis_api_const_pkg.MCC_WIRE_TRANSFER_MONEY
                            , vis_api_const_pkg.MCC_FIN_INSTITUTIONS
                            , vis_api_const_pkg.MCC_BETTING_CASINO_GAMBLING)
       or
       io_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_SALES_REVERSAL)
       and io_fin_rec.trans_code_qualifier = '1'
    then
        io_fin_rec.fast_funds_indicator    := null;
        io_fin_rec.business_format_code_3  := vis_api_const_pkg.INDUSTRY_SPEC_DATA_CREDIT_FUND;

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A32');
        io_fin_rec.source_of_funds         := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        io_fin_rec.payment_reversal_code   := null;

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8608');  -- SENDER_ACCOUNT
        io_fin_rec.sender_account_number   := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
                
        if io_fin_rec.business_application_id in ('AA', 'PP') and io_fin_rec.sender_account_number is null then
            io_fin_rec.sender_reference_number := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);
        end if;

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('CUSTOMER_NAME');  -- SENDER_NAME
        io_fin_rec.sender_name             := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('SENDER_STREET');
        io_fin_rec.sender_address          := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('SENDER_CITY');
        io_fin_rec.sender_city             := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        io_fin_rec.sender_state            := null;

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('SENDER_COUNTRY');
        io_fin_rec.sender_country          := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
    else
        io_fin_rec.business_format_code_3  := null;
        io_fin_rec.business_application_id := null;
    end if;
end process_auth_tcr3_cr;

procedure process_auth_tcr3(
    io_fin_rec          in out  vis_api_type_pkg.t_visa_fin_mes_rec
  , i_auth_rec          in      aut_api_type_pkg.t_auth_rec
) is
begin
    if  io_fin_rec.trans_code in (vis_api_const_pkg.TC_VOUCHER
                               , vis_api_const_pkg.TC_SALES
                               , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                               , vis_api_const_pkg.TC_SALES_REVERSAL)
    then
        io_fin_rec.business_format_code_3 :=
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => io_fin_rec.id
              , i_tag_id  => aup_api_const_pkg.TAG_BUSINESS_FORMAT_CODE
            );

        process_auth_tcr3_ai(
            io_fin_rec      => io_fin_rec
          , i_auth_rec      => i_auth_rec
        );

        process_auth_tcr3_cr(
            io_fin_rec      => io_fin_rec
          , i_auth_rec      => i_auth_rec
        );

    else
        io_fin_rec.business_application_id := null;
    end if;
end;

procedure process_auth(
    i_auth_rec        in      aut_api_type_pkg.t_auth_rec
  , i_inst_id         in      com_api_type_pkg.t_inst_id     default null
  , i_network_id      in      com_api_type_pkg.t_tiny_id     default null
  , i_collect_only    in      varchar2                       default null
  , i_status          in      com_api_type_pkg.t_dict_value  default null
  , io_fin_mess_id    in out  com_api_type_pkg.t_long_id
) is
    l_standard_id               com_api_type_pkg.t_tiny_id;
    l_host_id                   com_api_type_pkg.t_tiny_id;
    l_cps_retail_flag           com_api_type_pkg.t_boolean;
    l_cps_atm_flag              com_api_type_pkg.t_boolean;
    l_tcc                       com_api_type_pkg.t_mcc;
    l_diners_code               com_api_type_pkg.t_mcc;
    l_cab_type                  com_api_type_pkg.t_mcc;
    l_emv_tag_tab               com_api_type_pkg.t_tag_value_tab;
    l_pre_auth                  aut_api_type_pkg.t_auth_rec;
    l_fin_rec                   vis_api_type_pkg.t_visa_fin_mes_rec;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_visa_dialect              com_api_type_pkg.t_dict_value;
    l_tag_id                    com_api_type_pkg.t_short_id;
    l_msg_proc_bin              com_api_type_pkg.t_auth_code;
    l_parent_network_id         com_api_type_pkg.t_tiny_id;
    l_is_binary                 com_api_type_pkg.t_boolean;
    l_param_value               com_api_type_pkg.t_param_value;
    l_sub_merchant_id           com_api_type_pkg.t_name;
    l_facilitator_id            com_api_type_pkg.t_name;

    l_sender_reference_number   com_api_type_pkg.t_terminal_number;
    l_sender_account_number     com_api_type_pkg.t_original_data;
    l_sender_address            com_api_type_pkg.t_name;
    l_sender_city               com_api_type_pkg.t_name;
    l_sender_country            com_api_type_pkg.t_country_code;
    l_dispute_inst_id           com_api_type_pkg.t_inst_id;
    l_current_standard_version  com_api_type_pkg.t_tiny_id;
    l_merchant_postal_code      com_api_type_pkg.t_postal_code;

    function get_acquirer_bin(
        i_auth_id        in      com_api_type_pkg.t_long_id
      , i_visa_dialect   in      com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_rrn is
    begin
        for r in (
            select acq_inst_bin
              from (
                  select acq_inst_bin
                       , iso_msg_type
                    from aup_way4
                   where auth_id = i_auth_id
                     and i_visa_dialect = vis_api_const_pkg.VISA_DIALECT_OPENWAY
                  union all
                  select acq_inst_bin
                       , iso_msg_type
                    from aup_visa_basei
                   where auth_id = i_auth_id
                     and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT
                                          , vis_api_const_pkg.VISA_DIALECT_TIETO)
              )
             order by iso_msg_type
        ) loop
            return r.acq_inst_bin;
        end loop;
        return null;
    end get_acquirer_bin;

    function get_validation_code(
        i_auth_id        in      com_api_type_pkg.t_long_id
      , i_visa_dialect   in      com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_mcc is
    begin
        for r in (
            select validation_code
              from (select v.validation_code
                         , v.iso_msg_type
                      from aup_visa_basei v
                     where v.auth_id = i_auth_id
                       and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT, vis_api_const_pkg.VISA_DIALECT_TIETO))
            order by iso_msg_type
        ) loop
            return r.validation_code;
        end loop;
        return null;
    end get_validation_code;

    function get_srv_indicator(
        i_auth_id       in       com_api_type_pkg.t_long_id
      , i_visa_dialect  in       com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_byte_char is
    begin
        for r in (
            select srv_indicator
              from (select v.srv_indicator
                         , v.iso_msg_type
                      from aup_visa_basei v
                     where v.auth_id = i_auth_id
                       and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT, vis_api_const_pkg.VISA_DIALECT_TIETO)
           ) order by iso_msg_type
        ) loop
            return r.srv_indicator;
        end loop;
        return null;
    end get_srv_indicator;

    function get_resp_code(
        i_auth_id        in       com_api_type_pkg.t_long_id
      , i_visa_dialect   in       com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_byte_char is
    begin
        for r in (
            select resp_code
              from (select v.resp_code
                         , v.iso_msg_type
                      from aup_visa_basei v
                     where v.auth_id = i_auth_id
                       and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT, vis_api_const_pkg.VISA_DIALECT_TIETO)
            )
            order by iso_msg_type
                    ) loop
            return r.resp_code;
        end loop;
        return null;
    end get_resp_code;

    function get_network_code (
        i_auth_id        in      com_api_type_pkg.t_long_id
      , i_visa_dialect   in      com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_rrn is
    begin
        for r in (
                select network_id
                  from aup_visa_basei
                 where auth_id = i_auth_id
                   and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT, vis_api_const_pkg.VISA_DIALECT_TIETO)
        ) loop
            return r.network_id;
        end loop;
        return null;
    end get_network_code;

    function get_msg_proc_bin(
        i_parent_network_id       com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_auth_code is
        l_new_standard_id       com_api_type_pkg.t_tiny_id;
        l_new_host_id           com_api_type_pkg.t_tiny_id;
        l_result                com_api_type_pkg.t_auth_code;
    begin
        trc_log_pkg.debug (
            i_text          => 'get_msg_proc_bin: Read msg_proc_bin'
        );

        l_new_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_parent_network_id);
        l_new_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => i_parent_network_id);

        l_result :=
            cmn_api_standard_pkg.get_varchar_value(
                i_inst_id       => l_dispute_inst_id
              , i_standard_id   => l_new_standard_id
              , i_object_id     => l_new_host_id
              , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name    => vis_api_const_pkg.CMID
              , i_param_tab     => l_param_tab
            );

        trc_log_pkg.debug (
            i_text          => 'get_msg_proc_bin: cmid = ' || l_result
        );

        if l_result is null then
            com_api_error_pkg.raise_error (
                i_error         => 'VISA_ACQ_PROC_BIN_NOT_DEFINED'
              , i_env_param1    => l_dispute_inst_id
              , i_env_param2    => l_new_standard_id
              , i_env_param3    => l_new_host_id
            );
        end if;

        return l_result;
    end get_msg_proc_bin;

    function get_trans_code_qualifier(
        i_oper_type             in  com_api_type_pkg.t_dict_value
      , i_mcc                   in  com_api_type_pkg.t_mcc
      , i_bus_appl_id           in  com_api_type_pkg.t_byte_char
    ) return com_api_type_pkg.t_byte_char is
    begin
        return
            case
                when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT)
                then vis_api_const_pkg.TCQ_AFT
                when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
                then vis_api_const_pkg.TCQ_OCT
                when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_PAYMENT)
                     and i_mcc   in (vis_api_const_pkg.MCC_WIRE_TRANSFER_MONEY
                                      , vis_api_const_pkg.MCC_FIN_INSTITUTIONS
                                      , vis_api_const_pkg.MCC_BETTING_CASINO_GAMBLING)
                then vis_api_const_pkg.TCQ_OCT
                when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE)
                     and i_bus_appl_id in ('WT')
                then vis_api_const_pkg.TCQ_AFT
                else vis_api_const_pkg.TCQ_DEFAULT
            end;
    end get_trans_code_qualifier;

    function get_spec_cond_ind(
        i_oper_type             in  com_api_type_pkg.t_dict_value
      , i_mcc                   in  com_api_type_pkg.t_mcc
      , i_inst_id               in  com_api_type_pkg.t_inst_id
    ) return com_api_type_pkg.t_byte_char is
    begin
        return
            case
                when    i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                    and i_mcc in (vis_api_const_pkg.MCC_BETTING_CASINO_GAMBLING)
                then
                    '8'
                when    i_mcc in (vis_api_const_pkg.MCC_FIN_INSTITUTIONS
                                , vis_api_const_pkg.MCC_NON_FIN_INSTITUTIONS)
                    and i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                    and set_ui_value_pkg.get_inst_param_n(
                            i_param_name => 'DEBT_REPAYMENT_PROGRAM'
                          , i_inst_id    => i_inst_id
                        ) = com_api_const_pkg.TRUE
                then
                    '9'
                else
                    null
            end;
    end get_spec_cond_ind;

    function get_unatt_accept_term_ind(
        i_terminal_type             in  com_api_type_pkg.t_dict_value
      , i_terminal_operating_env    in  com_api_type_pkg.t_dict_value
      , i_crdh_auth_method          in  com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_byte_char is
    begin
        return
            case
                when i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                then '3'
                when i_terminal_operating_env in ('F2240002','F2240004','F2240005')
                then
                    case
                        when i_auth_rec.crdh_auth_method = 'F2280001'
                        then '2'
                        else '3'
                    end
                else ''
            end;
    end get_unatt_accept_term_ind;

    function get_account_selection(
        i_account_type          in  com_api_type_pkg.t_dict_value
      , i_mcc                   in  com_api_type_pkg.t_mcc
    ) return com_api_type_pkg.t_byte_char is
    begin
        return
            case i_auth_rec.mcc 
                when vis_api_const_pkg.MCC_ATM then
                    case i_auth_rec.account_type
                        when 'ACCT0010' then '1'
                        when 'ACCT0020' then '2'
                        when 'ACCT0030' then '3'
                        else '0'
                    end
                else ' '
                end;
    end get_account_selection;

    function get_cvv2_result_code(
        i_cvv2_result           in  com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_byte_char is
    begin
        return
            case substr(i_cvv2_result, -1)
                when '1' then 'M'
                when '2' then 'N'
                when '3' then 'P'
                when '4' then 'S'
                when '5' then 'U'
                else null
            end;
    end get_cvv2_result_code;

begin
    if io_fin_mess_id is null then
        io_fin_mess_id    := opr_api_create_pkg.get_id;
    end if;

    l_fin_rec.id          := io_fin_mess_id;
    l_fin_rec.status      := nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
    l_fin_rec.is_reversal := i_auth_rec.is_reversal;
    l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
    l_fin_rec.is_returned := com_api_type_pkg.FALSE;
    l_fin_rec.is_invalid  := com_api_type_pkg.FALSE;
    l_fin_rec.inst_id     := nvl(i_inst_id, i_auth_rec.acq_inst_id);
    l_fin_rec.network_id  := nvl(i_network_id, i_auth_rec.iss_network_id);
    l_dispute_inst_id     := case l_fin_rec.inst_id 
                                 when vis_api_const_pkg.INSTITUTION_VISA_SMS 
                                 then vis_api_const_pkg.INSTITUTION_VISA
                                 else l_fin_rec.inst_id 
                             end;

    -- get network communication standard
    l_host_id             := net_api_network_pkg.get_default_host(
                                 i_network_id => l_fin_rec.network_id
                             );
    l_standard_id         := net_api_network_pkg.get_offline_standard(
                                 i_network_id => l_fin_rec.network_id
                             );

    trc_log_pkg.debug (
        i_text          => 'process_auth: inst_id[#1] network_id[#2] host_id[#3] standard_id[#4]'
      , i_env_param1    => l_dispute_inst_id
      , i_env_param2    => l_fin_rec.network_id
      , i_env_param3    => l_host_id
      , i_env_param4    => l_standard_id
    );

    rul_api_shared_data_pkg.load_oper_params(
        i_oper_id       => i_auth_rec.id
      , io_params       => l_param_tab
    );

    l_sub_merchant_id := aup_api_tag_pkg.get_tag_value(
                             i_auth_id => l_fin_rec.id
                           , i_tag_id  => aup_api_const_pkg.TAG_SUB_MERCHANT_ID
                         );

    rul_api_param_pkg.set_param(
        i_name    => 'SUB_MERCHANT_ID'
      , i_value   => l_sub_merchant_id
      , io_params => l_param_tab
    );
  
    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => l_dispute_inst_id
      , i_standard_id   => l_standard_id
      , i_object_id     => l_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => vis_api_const_pkg.VISA_BASEII_DIALECT
      , i_param_tab     => l_param_tab
      , o_param_value   => l_visa_dialect
    );

    -- get VISA Retail CPS Participation Flag
    l_cps_retail_flag :=
        cmn_api_standard_pkg.get_number_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'VISA_RETAIL_CPS_PARTICIPATION_FLAG'
          , i_param_tab     => l_param_tab
        );

    -- get VISA ATM CPS Participation Flag
    l_cps_atm_flag :=
        cmn_api_standard_pkg.get_number_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'VISA_ATM_CPS_PARTICIPATION_FLAG'
          , i_param_tab     => l_param_tab
        );

    l_current_standard_version := 
        cmn_api_standard_pkg.get_current_version(
            i_standard_id  => l_standard_id 
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => l_host_id
          , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
        );

    l_fin_rec.dispute_id     := null;
    l_fin_rec.file_id        := null;
    l_fin_rec.batch_id       := null;
    l_fin_rec.record_number  := null;
    l_fin_rec.rrn            := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);

    -- converting reversal flag and operation type into VISA transaction code
    l_fin_rec.trans_code :=
        case
            when i_auth_rec.is_reversal = com_api_type_pkg.FALSE then
                case
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                        then vis_api_const_pkg.TC_CASH
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_UNIQUE, opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT, opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
                        then vis_api_const_pkg.TC_SALES
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND, opr_api_const_pkg.OPERATION_TYPE_PAYMENT, opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT, opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                        then vis_api_const_pkg.TC_VOUCHER
                    else
                        null
                end
            when i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
                case
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                        then vis_api_const_pkg.TC_CASH_REVERSAL
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_UNIQUE, opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT, opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
                        then vis_api_const_pkg.TC_SALES_REVERSAL
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND, opr_api_const_pkg.OPERATION_TYPE_PAYMENT, opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT, opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                        then vis_api_const_pkg.TC_VOUCHER_REVERSAL
                    else
                        null
                end
            end;
    if l_fin_rec.trans_code is null then
        trc_log_pkg.error(
            i_text          => 'UNABLE_DETERMINE_VISA_TRANSACTION_CODE'
          , i_env_param1    => l_fin_rec.id
        );
    end if;

    -- define original authorization for completion
    if  i_auth_rec.msg_type = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
        or l_fin_rec.trans_code = vis_api_const_pkg.TC_VOUCHER
    then
        opr_api_shared_data_pkg.load_auth(
            i_id            => i_auth_rec.original_id
          , io_auth         => l_pre_auth
        );
    end if;

    l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A24');  -- VISA_BAI
    l_fin_rec.business_application_id := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

    l_fin_rec.trans_code_qualifier :=
        get_trans_code_qualifier(
            i_oper_type     => i_auth_rec.oper_type
          , i_mcc           => i_auth_rec.mcc
          , i_bus_appl_id   => l_fin_rec.business_application_id
        );

    trc_log_pkg.debug('process_auth: TC='||l_fin_rec.trans_code||', TCQ='||l_fin_rec.trans_code_qualifier);

    trc_log_pkg.debug('process_auth: g_trans_code(l_count)='||l_fin_rec.trans_code||', i_auth_rec.original_id='||i_auth_rec.original_id);
    trc_log_pkg.debug('process_auth: l_pre_auth.originator_refnum='||l_pre_auth.network_refnum||', g_rrn(l_count)='||l_fin_rec.rrn);

    l_fin_rec.rrn              := nvl(l_fin_rec.rrn, l_pre_auth.network_refnum);
    l_fin_rec.card_id          := i_auth_rec.card_id;
    l_fin_rec.card_hash        := com_api_hash_pkg.get_card_hash(i_auth_rec.card_number);
    l_fin_rec.card_mask        := iss_api_card_pkg.get_card_mask(i_auth_rec.card_number);
    l_fin_rec.card_number      := i_auth_rec.card_number;
    l_fin_rec.floor_limit_ind  := null;
    l_fin_rec.exept_file_ind   := null;
    l_fin_rec.pcas_ind         := null;
    l_fin_rec.oper_amount      :=
        case when l_current_standard_version >= vis_api_const_pkg.STANDARD_VERSION_ID_19Q2 then
            coalesce(
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => i_auth_rec.id
                  , i_tag_id  => aup_api_const_pkg.TAG_PARTIAL_AUTH_AMOUNT
                )
              , i_auth_rec.oper_amount
            )
        else
            i_auth_rec.oper_amount
        end;

    l_fin_rec.oper_currency    := i_auth_rec.oper_currency;
    l_fin_rec.oper_date        := nvl(l_pre_auth.oper_date, i_auth_rec.oper_date);
    l_fin_rec.sttl_amount      := null;
    l_fin_rec.sttl_currency    := null;
    l_fin_rec.network_amount   := null;
    l_fin_rec.network_currency := null;
    l_fin_rec.network_code     := get_network_code(
        i_auth_id       => i_auth_rec.id
      , i_visa_dialect  => l_visa_dialect
    );

    l_fin_rec.acquirer_bin := get_acquirer_bin (
        i_auth_id       => i_auth_rec.id
      , i_visa_dialect  => l_visa_dialect
    );
    l_fin_rec.acquirer_bin := nvl(l_fin_rec.acquirer_bin, i_auth_rec.acq_inst_bin);

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        begin
            select arn
                 , acq_business_id
                 , proc_bin
              into l_fin_rec.arn
                 , l_fin_rec.acq_business_id
                 , l_fin_rec.proc_bin
              from vis_fin_message
             where id = i_auth_rec.original_id;
        exception
             when no_data_found then
                 com_api_error_pkg.raise_error (
                     i_error      => 'FINANCIAL_MESSAGE_NOT_FOUND'
                   , i_env_param1 => i_auth_rec.original_id
                 );
        end;
    else
        -- get VISA Acquirer Business ID
        l_fin_rec.acq_business_id :=
            cmn_api_standard_pkg.get_varchar_value(
                i_inst_id       => l_dispute_inst_id
              , i_standard_id   => l_standard_id
              , i_object_id     => l_host_id
              , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name    => vis_api_const_pkg.ACQ_BUSINESS_ID
              , i_param_tab     => l_param_tab
            );

        trc_log_pkg.debug('process_auth: cps_retail_flag='||l_cps_retail_flag||', cps_atm_flag='||l_cps_atm_flag||', acq_business_id='||l_fin_rec.acq_business_id);

        if l_fin_rec.acq_business_id is null then
            com_api_error_pkg.raise_error (
                i_error        => 'VISA_ACQ_BUSINESS_ID_NOT_FOUND'
              , i_env_param1   => l_dispute_inst_id
              , i_env_param2   => l_standard_id
              , i_env_param3   => l_host_id
            );
        end if;

        -- get VISA Acquirer Processing BIN
        l_fin_rec.proc_bin :=
            cmn_api_standard_pkg.get_varchar_value(
                i_inst_id       => l_dispute_inst_id
              , i_standard_id   => l_standard_id
              , i_object_id     => l_host_id
              , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name    => vis_api_const_pkg.CMID
              , i_param_tab     => l_param_tab
            );

        trc_log_pkg.debug('process_auth: proc_bin='||l_fin_rec.proc_bin);

        if l_fin_rec.proc_bin is null then
            com_api_error_pkg.raise_error (
                i_error       => 'VISA_ACQ_PROC_BIN_NOT_DEFINED'
              , i_env_param1  => l_dispute_inst_id
              , i_env_param2  => l_standard_id
              , i_env_param3  => l_host_id
            );
        end if;

        -- check proc_bin NSPK
        l_parent_network_id :=
            cmn_api_standard_pkg.get_number_value(
                i_inst_id       => l_dispute_inst_id
              , i_standard_id   => l_standard_id
              , i_object_id     => l_host_id
              , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name    => vis_api_const_pkg.VISA_PARENT_NETWORK
              , i_param_tab     => l_param_tab
            );

        trc_log_pkg.debug (
            i_text        => 'process_auth: l_parent_network_id[#1]'
          , i_env_param1  => l_parent_network_id
        );

        if l_parent_network_id is not null then
            l_msg_proc_bin := get_msg_proc_bin(i_parent_network_id  => l_parent_network_id);
        else
            l_msg_proc_bin := l_fin_rec.proc_bin;
        end if;

        l_fin_rec.arn :=
            acq_api_merchant_pkg.get_arn(
                i_acquirer_bin => nvl(l_msg_proc_bin, l_fin_rec.proc_bin)
              , i_proc_date    => i_auth_rec.oper_date
            );

    end if;

    trc_log_pkg.debug (
        i_text        => 'process_auth: l_fin_rec.arn[#1]'
      , i_env_param1  => l_fin_rec.arn
    );

    begin
        l_merchant_postal_code := to_number(i_auth_rec.merchant_postcode);
        l_merchant_postal_code := i_auth_rec.merchant_postcode;
    exception
        when others then
            l_merchant_postal_code := '00000';
    end;

    l_fin_rec.merchant_name        := substrb(i_auth_rec.merchant_name, 1, 25);
    l_fin_rec.merchant_city        := substrb(i_auth_rec.merchant_city, 1, 13);
    l_fin_rec.merchant_country     := i_auth_rec.merchant_country;
    l_fin_rec.merchant_postal_code := l_merchant_postal_code;
    if i_auth_rec.merchant_country in ('840', '124') then
        l_fin_rec.merchant_region  := i_auth_rec.merchant_region;
    end if;
    l_fin_rec.merchant_street      := i_auth_rec.merchant_street;
    l_fin_rec.mcc                  := i_auth_rec.mcc;

    l_fin_rec.req_pay_service :=
        case when i_auth_rec.mcc = '6011' and l_cps_atm_flag = com_api_type_pkg.TRUE then '9'
             when i_auth_rec.mcc not in ('6010', '6011') and l_cps_retail_flag = com_api_type_pkg.TRUE then 'A'
             else null
        end;
    l_fin_rec.auth_char_ind := get_srv_indicator (
        i_auth_id       => i_auth_rec.id
      , i_visa_dialect  => l_visa_dialect
    );
    if nvl(l_fin_rec.auth_char_ind, '0') = '0' then
        l_fin_rec.auth_char_ind :=
        case when i_auth_rec.mcc = '6011' and l_cps_atm_flag = com_api_type_pkg.TRUE then 'E'
             when i_auth_rec.mcc not in ('6010', '6011') and l_cps_retail_flag = com_api_type_pkg.TRUE then 'A'
             else 'N'
        end;
    end if;

    l_fin_rec.usage_code          := '1';
    l_fin_rec.reason_code         := '00';
    l_fin_rec.settlement_flag     := '9';
    l_fin_rec.auth_code           := i_auth_rec.auth_code;
    
    l_fin_rec.pos_terminal_cap :=
        case i_auth_rec.card_data_input_mode
            when  'F2270000' then '0'                                  -- Unknown; data not available.
            else
                case i_auth_rec.card_data_input_cap
                    when 'F2210001' then '1'                           -- Manual; no terminal.
                    when 'F2210002' then '2'                           -- Magnetic stripe reader capability.
                    when 'F2210003' then '3'                           -- Barcode read capability
                    when 'F221000A' then '2'
                    when 'F221000B' then '2'
                    when 'F2210005' then '5'                           -- Integrated circuit card (ICC) capability.
                    when 'F221000C' then '5'
                    when 'F221000D' then '5'
                    when 'F221000E' then '5'
                    when 'F2210006' then '9'                           -- Key entry-only capability.
                    when 'F221000M' then '5'                           -- PAN auto-entry via contactless M/Chip.
                    else null
                end
        end;

    l_fin_rec.inter_fee_ind  := null;
    l_fin_rec.crdh_id_method :=
        case
            when i_auth_rec.card_data_input_mode in ('F2270006', 'F2270005', 'F2270007', 'F2270009', 'F227000S') 
                 or (
                        i_auth_rec.card_data_input_mode in ('F227000E', 'F2270001')
                        and i_auth_rec.crdh_auth_method  = 'F228000S'
                    )
            then '4'                                                                   -- Mail/Telephone or  Electronic Commerce
            when i_auth_rec.crdh_auth_method in ('F2280001')             then '2'      -- PIN
            when i_auth_rec.crdh_auth_method in ('F2280002', 'F2280005') then '1'      -- Signature
            when i_auth_rec.cat_level        in ('F22D0003')             then '3'      -- Unattended terminal; no PIN pad
            else null                                                                  -- Not specified
        end;

    if i_collect_only = com_api_type_pkg.TRUE then
        l_fin_rec.collect_only_flag := 'C';
        l_fin_rec.sttl_amount       := 0;
        l_fin_rec.sttl_currency     := null;
    end if;

    l_fin_rec.pos_entry_mode := get_pos_entry_mode(i_card_data_input_mode => i_auth_rec.card_data_input_mode);

    l_fin_rec.central_proc_date := to_char(com_api_sttl_day_pkg.get_sysdate, 'YDDD');

    com_api_mcc_pkg.get_mcc_info(
        i_mcc          => i_auth_rec.mcc
      , o_tcc          => l_tcc
      , o_diners_code  => l_diners_code
      , o_mc_cab_type  => l_cab_type
    );

    l_fin_rec.reimburst_attr :=
        case
            when i_auth_rec.terminal_type  = acq_api_const_pkg.TERMINAL_TYPE_EPOS      and i_auth_rec.mcc  = '6010'  then '0'
            when (i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM       and i_auth_rec.mcc != '6011')
              or (i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS       and i_auth_rec.mcc != '6010')
              or i_auth_rec.terminal_type  = acq_api_const_pkg.TERMINAL_TYPE_EPOS                                    then 'B'
            when i_auth_rec.terminal_type  = acq_api_const_pkg.TERMINAL_TYPE_ATM       and i_auth_rec.mcc  = '6011'  then '2'
            when i_auth_rec.terminal_type  = acq_api_const_pkg.TERMINAL_TYPE_POS       and i_auth_rec.mcc  = '6010'  then '0'
            when i_auth_rec.terminal_type  = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and i_auth_rec.mcc  = '6010'  then '6'
            when i_auth_rec.terminal_type  = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and i_auth_rec.mcc != '6010'
                 and i_auth_rec.crdh_auth_method = 'F2280001'                                                        then '8'
            else '0'
        end;

    l_fin_rec.iss_workst_bin     := null;
    l_fin_rec.acq_workst_bin     := null;
    l_fin_rec.chargeback_ref_num := '000000';
    l_fin_rec.docum_ind          := null;

    if    i_auth_rec.is_reversal = com_api_type_pkg.FALSE
      and (i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PAYMENT) and i_auth_rec.mcc in (vis_api_const_pkg.MCC_WIRE_TRANSFER_MONEY, vis_api_const_pkg.MCC_FIN_INSTITUTIONS)
        or i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
          )
    then
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(vis_api_const_pkg.TAG_REF_SENDER_ACCOUNT);
        l_sender_account_number := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
        if l_sender_account_number is null then
            l_sender_reference_number := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);
        end if;
        
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(vis_api_const_pkg.TAG_REF_SENDER_STREET);
        l_sender_address := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(vis_api_const_pkg.TAG_REF_SENDER_CITY);
        l_sender_city := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(vis_api_const_pkg.TAG_REF_SENDER_COUNTRY);
        l_sender_country := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
        
        l_fin_rec.member_msg_text :=
            nvl(l_sender_account_number, l_sender_reference_number) || ' '
         || l_sender_country  || ' '
         || l_sender_city  || ' '
         || l_sender_address;
    else
        l_fin_rec.member_msg_text := null;
    end if;

    l_fin_rec.spec_cond_ind :=
        get_spec_cond_ind(
            i_oper_type     => i_auth_rec.oper_type
          , i_mcc           => i_auth_rec.mcc
          , i_inst_id       => l_fin_rec.inst_id
        );

    l_fin_rec.fee_program_ind     := null;
    l_fin_rec.issuer_charge       := null;
    l_fin_rec.merchant_number     := i_auth_rec.merchant_number;
    l_fin_rec.terminal_number     := 
        case when length(i_auth_rec.terminal_number) >= 8
           then substr(i_auth_rec.terminal_number, -8)
           else i_auth_rec.terminal_number
        end;
    l_fin_rec.national_reimb_fee  := 0;

    l_pre_auth.certificate_method := nvl(l_pre_auth.certificate_method, i_auth_rec.certificate_method);
    l_pre_auth.certificate_type   := nvl(l_pre_auth.certificate_type, i_auth_rec.certificate_type);
    l_pre_auth.ucaf_indicator     := nvl(l_pre_auth.ucaf_indicator, i_auth_rec.ucaf_indicator);

    l_fin_rec.electr_comm_ind := get_ecommerce_indicator(
        i_auth_rec      => i_auth_rec
      , i_fin_rec       => l_fin_rec
      , i_pre_auth      => l_pre_auth
      , i_visa_dialect  => l_visa_dialect
    );

    trc_log_pkg.debug(
        i_text        => 'process_auth: i_auth_rec.terminal_type[#1], l_fin_rec.electr_comm_ind[#2], i_auth_rec.card_data_input_mode[#3], i_auth_rec.crdh_auth_method[#4]'
      , i_env_param1  => i_auth_rec.terminal_type
      , i_env_param2  => l_fin_rec.electr_comm_ind
      , i_env_param3  => i_auth_rec.card_data_input_mode
      , i_env_param4  => i_auth_rec.crdh_auth_method
    );

    if l_fin_rec.crdh_id_method = '4' then
        if com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.merchant_country) = vis_api_const_pkg.VISA_REGION_EUROPE
           and com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.card_country) = vis_api_const_pkg.VISA_REGION_EUROPE
        then
            l_fin_rec.reimburst_attr := '5';
        else
            if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE then
                l_fin_rec.reimburst_attr := '0';
            end if;
        end if;
    elsif l_fin_rec.electr_comm_ind in ('5', '6') then
        l_fin_rec.reimburst_attr     := '5';
    elsif l_fin_rec.electr_comm_ind in ('1', '3', '4', '7') then
        if com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.merchant_country) = vis_api_const_pkg.VISA_REGION_ASIA_PACIFIC
           and com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.card_country) = vis_api_const_pkg.VISA_REGION_ASIA_PACIFIC
        then
            l_fin_rec.reimburst_attr    := '1';
        else
            l_fin_rec.reimburst_attr    := '7';
        end if;
    end if;
    if i_auth_rec.msg_type = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
       and substr(i_auth_rec.pos_entry_mode, 1, 2) in ('01')
    then
        l_fin_rec.reimburst_attr     := '0';
        l_fin_rec.crdh_id_method     := '1';
        l_fin_rec.auth_source_code   := ' ';
    end if;
    -- Change Reimbursement attribute for MCC Airline
    if l_cab_type = 'A'
       and l_fin_rec.pos_entry_mode in ('01', '02', '03', '04', '05', '06', '07', '84', '90', '91', '95') then
        l_fin_rec.reimburst_attr     := 'C';
    end if;

    l_fin_rec.spec_chargeback_ind    := null;
    l_fin_rec.interface_trace_num    := null;
    l_fin_rec.unatt_accept_term_ind  :=
        get_unatt_accept_term_ind(
            i_terminal_type             => i_auth_rec.terminal_type
          , i_terminal_operating_env    => i_auth_rec.terminal_operating_env
          , i_crdh_auth_method          => i_auth_rec.crdh_auth_method
        );

    l_fin_rec.prepaid_card_ind       := null;
    l_fin_rec.service_development    := case
                                            when l_fin_rec.electr_comm_ind is null
                                            then '0'
                                            else '1'
                                        end;

    l_fin_rec.avs_resp_code          := aup_api_tag_pkg.get_tag_value(
                                            i_auth_id   => i_auth_rec.id
                                          , i_tag_id    => aup_api_tag_pkg.find_tag_by_reference('DF8A2C')
                                        );

    if l_fin_rec.auth_source_code is null then
        l_fin_rec.auth_source_code   := case i_auth_rec.is_advice
                                            when com_api_type_pkg.TRUE
                                            then nvl(aup_api_tag_pkg.get_tag_value(
                                                     i_auth_id   => i_auth_rec.id
                                                   , i_tag_id    => aup_api_tag_pkg.find_tag_by_reference('DF8A09'))
                                                 , ' '
                                                 )
                                            else ' '
                                        end;
    end if;

    l_fin_rec.purch_id_format        := '0';

    l_fin_rec.account_selection :=
        get_account_selection(
            i_account_type  => i_auth_rec.account_type
          , i_mcc           => i_auth_rec.mcc
        );

    l_fin_rec.installment_pay_count  := null;
    l_fin_rec.purch_id               := null;
    l_fin_rec.cashback               := i_auth_rec.oper_cashback_amount;

    if l_current_standard_version >= vis_api_const_pkg.STANDARD_VERSION_ID_19Q2 then
        l_fin_rec.surcharge_amount  := i_auth_rec.oper_surcharge_amount;
        l_fin_rec.surcharge_sign    :=
            case
                when i_auth_rec.oper_request_amount > i_auth_rec.oper_amount - i_auth_rec.oper_surcharge_amount then
                    'CR'
                else
                    'DB'
            end;
    end if;

    if i_auth_rec.card_data_input_mode in ('F2270002', 'F227000B')   -- read card via magstripe
       and substr(i_auth_rec.card_service_code, 1, 1) in ('2','6')   -- chip card
       and i_auth_rec.card_data_input_cap in ('F2210005', 'F221000C', 'F221000D', 'F221000E', 'F221000M')  -- chip-capable terminal
    then
        l_fin_rec.chip_cond_code := '1';
    else
        l_fin_rec.chip_cond_code := '0';
    end if;

    l_fin_rec.validation_code := get_validation_code(
        i_auth_id       => i_auth_rec.id
      , i_visa_dialect  => l_visa_dialect
    );
    if l_fin_rec.validation_code is null then
        l_fin_rec.validation_code := get_validation_code(
            i_auth_id       => l_pre_auth.id
          , i_visa_dialect  => l_visa_dialect
        );
    end if;

    if l_fin_rec.validation_code is null then
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF860E');
        l_fin_rec.validation_code := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
    end if;

    l_fin_rec.transaction_id := nvl(i_auth_rec.transaction_id, l_pre_auth.transaction_id);

    l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A21');
    l_fin_rec.merchant_verif_value := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

    l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8800');
    l_fin_rec.payment_acc_ref := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

    -- EMV data for chip transaction
    if  l_fin_rec.pos_entry_mode = '05' and i_auth_rec.is_early_emv = com_api_const_pkg.TRUE
        or
        l_fin_rec.pos_entry_mode = '02' and l_fin_rec.reimburst_attr = 'B'
    then
        l_fin_rec.pos_entry_mode := '90';
    end if;

    if  l_fin_rec.pos_entry_mode in ('05', '07')
        and l_fin_rec.is_reversal = com_api_type_pkg.FALSE
    then
        l_is_binary := nvl(
                           set_ui_value_pkg.get_system_param_n(i_param_name => 'EMV_TAGS_IS_BINARY')
                         , com_api_type_pkg.FALSE
                       );
        emv_api_tag_pkg.parse_emv_data(
            i_emv_data    => i_auth_rec.emv_data
          , o_emv_tag_tab => l_emv_tag_tab
          , i_is_binary   => l_is_binary
        );

        l_fin_rec.issuer_appl_data := emv_api_tag_pkg.get_tag_value('9F10', l_emv_tag_tab, com_api_const_pkg.TRUE);

        l_fin_rec.pos_environment      := null;
        l_fin_rec.transaction_type     := emv_api_tag_pkg.get_tag_value('9C',   l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_fin_rec.card_seq_number      := i_auth_rec.card_seq_number;
        l_fin_rec.terminal_profile     := emv_api_tag_pkg.get_tag_value('9F33', l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_param_value                  := emv_api_tag_pkg.get_tag_value('9F1A', l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_fin_rec.terminal_country     := 
            case 
                when l_is_binary = com_api_const_pkg.TRUE 
                then 
                    case
                        when length(l_param_value) > 3 
                        then substr(l_param_value, -3) 
                        else l_param_value 
                    end
                else l_param_value 
            end;
        l_fin_rec.unpredict_number     := emv_api_tag_pkg.get_tag_value('9F37', l_emv_tag_tab);
        l_fin_rec.appl_trans_counter   := emv_api_tag_pkg.get_tag_value('9F36', l_emv_tag_tab);
        l_fin_rec.appl_interch_profile := emv_api_tag_pkg.get_tag_value('82',   l_emv_tag_tab);
        l_fin_rec.cryptogram           := emv_api_tag_pkg.get_tag_value('9F26', l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_fin_rec.term_verif_result    := emv_api_tag_pkg.get_tag_value('95',   l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_fin_rec.cryptogram_amount    := emv_api_tag_pkg.get_tag_value('9F02', l_emv_tag_tab);
        l_fin_rec.card_expir_date      := to_char(i_auth_rec.card_expir_date, 'YYMM');
        l_fin_rec.cryptogram_version   := substr(l_fin_rec.issuer_appl_data, 5, 2);
        l_fin_rec.card_verif_result    := substr(l_fin_rec.issuer_appl_data, 7, 8);

        l_fin_rec.auth_resp_code       := emv_api_tag_pkg.get_tag_value(
                                              i_tag         => '8A'
                                            , i_emv_tag_tab => l_emv_tag_tab
                                            , i_mask_error  => com_api_const_pkg.TRUE
                                          );
        if l_is_binary = com_api_const_pkg.TRUE then
            l_fin_rec.auth_resp_code   := prs_api_util_pkg.hex2bin(
                                              i_hex_string  => l_fin_rec.auth_resp_code
                                          );
        end if;

        l_fin_rec.issuer_script_result := emv_api_tag_pkg.get_tag_value('9F18', l_emv_tag_tab, com_api_const_pkg.TRUE);
        if l_fin_rec.issuer_script_result is not null then
            l_fin_rec.issuer_script_result := l_fin_rec.issuer_script_result || '00';
        end if;

        l_fin_rec.cryptogram_info_data := null;
        l_fin_rec.form_factor_indicator := emv_api_tag_pkg.get_tag_value('9F6E', l_emv_tag_tab, com_api_const_pkg.TRUE);
    end if;

    l_fin_rec.cvv2_result_code :=
        get_cvv2_result_code(
            i_cvv2_result   => i_auth_rec.cvv2_result
        );

    l_fin_rec.host_inst_id := net_api_network_pkg.get_inst_id(l_fin_rec.network_id);

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        update vis_fin_message
           set status = decode (
                  status
                , net_api_const_pkg.CLEARING_MSG_STATUS_READY
                , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                , status
            )
         where id = i_auth_rec.original_id
     returning decode (
                   status
                 , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                 , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                 , net_api_const_pkg.CLEARING_MSG_STATUS_READY
                )
          into l_fin_rec.status;

        if sql%rowcount = 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_auth_rec.original_id
            );
        end if;

        l_fin_rec.status := nvl(l_fin_rec.status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
    end if;

    if l_fin_rec.auth_resp_code is null then
        if i_auth_rec.is_advice = com_api_const_pkg.TRUE then
            l_fin_rec.auth_resp_code :=
                case substr(l_fin_rec.card_verif_result, 3, 1)
                    when '2' then 'Z3'
                    when '6' then 'Y3'
                    when '8' then 'Z1'
                    when '9' then 'Y1'
                end;
        else
            l_fin_rec.auth_resp_code := get_resp_code (
                i_auth_id         => i_auth_rec.id
              , i_visa_dialect    => l_visa_dialect
            );
        end if;
    end if;
    if l_fin_rec.auth_resp_code is null then
        l_fin_rec.auth_resp_code := i_auth_rec.native_resp_code;
    end if;

    l_fin_rec.service_code := i_auth_rec.card_service_code;

    -- In case of USA electr_comm_ind is used for recurring payments
    if i_auth_rec.crdh_presence = 'F2250004'
        and com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.merchant_country) != vis_api_const_pkg.VISA_REGION_USA
    then
        l_fin_rec.pos_environment := 'R';
    elsif l_fin_rec.pos_entry_mode = '10' then
        l_fin_rec.pos_environment := 'C';
    else
        l_fin_rec.pos_environment := ' ';
    end if;

    -- for TCR 3
    process_auth_tcr3(
        io_fin_rec      => l_fin_rec
      , i_auth_rec      => i_auth_rec
    );

    if  l_fin_rec.trans_code in (vis_api_const_pkg.TC_CASH
                               , vis_api_const_pkg.TC_CASH_CHARGEBACK
                               , vis_api_const_pkg.TC_CASH_REVERSAL
                               , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV)
    then
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DCC_INDICATOR');
        l_fin_rec.dcc_indicator           := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
        if l_fin_rec.dcc_indicator = '0' then
            l_fin_rec.dcc_indicator       := ' ';
        end if;
    end if;

    l_fin_rec.id := put_message(i_fin_rec => l_fin_rec);
end process_auth;

procedure create_operation(
    i_fin_rec             in     vis_api_type_pkg.t_visa_fin_mes_rec
  , i_standard_id         in     com_api_type_pkg.t_tiny_id
  , i_fee_rec             in     vis_api_type_pkg.t_fee_rec          default null
  , i_status              in     com_api_type_pkg.t_dict_value       default null
  , i_create_disp_case    in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_incom_sess_file_id  in     com_api_type_pkg.t_long_id          default null
  , i_oper_type           in     com_api_type_pkg.t_dict_value       default null
) is
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_acq_inst_id           com_api_type_pkg.t_inst_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_country_code          com_api_type_pkg.t_country_code;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;

    l_merchant_number       com_api_type_pkg.t_merchant_number;
    l_terminal_number       com_api_type_pkg.t_terminal_number;
    l_merchant_name         com_api_type_pkg.t_name;
    l_mcc                   com_api_type_pkg.t_mcc;
    l_originator_refnum     com_api_type_pkg.t_rrn;
    l_auth_code             com_api_type_pkg.t_auth_code;

    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;

    l_operation             opr_api_type_pkg.t_oper_rec;
    l_participant           opr_api_type_pkg.t_oper_part_rec;
    l_need_sttl_type        com_api_type_pkg.t_boolean        := com_api_type_pkg.FALSE;
begin
    l_oper.id := i_fin_rec.id;
    if l_oper.id is null then
        l_oper.id := opr_api_create_pkg.get_id;
    end if;
    if i_status is not null then
        l_oper.status := i_status;
    end if;

    if  i_fin_rec.dispute_id is not null
        or
        i_fin_rec.is_reversal = com_api_type_pkg.TRUE
        and (i_fin_rec.is_incoming = com_api_type_pkg.FALSE
             or
             i_fee_rec.id is not null)
    then
        l_oper.original_id := get_original_id(
                                  i_fin_rec => i_fin_rec
                                , i_fee_rec => i_fee_rec
                              );
        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_oper.original_id
          , o_operation => l_operation
        );

        l_sttl_type         := l_operation.sttl_type;
        l_merchant_number   := l_operation.merchant_number;
        l_terminal_number   := l_operation.terminal_number;
        l_merchant_name     := l_operation.merchant_name;
        l_mcc               := l_operation.mcc;
        l_originator_refnum := l_operation.originator_refnum;

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_operation.id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant       => l_participant
        );

        l_iss_inst_id         := l_participant.inst_id;
        l_iss_network_id      := l_participant.network_id;
        l_iss_part.split_hash := l_participant.split_hash;
        l_card_type_id        := l_participant.card_type_id;
        l_card_country        := l_participant.card_country;
        l_card_inst_id        := l_participant.card_inst_id;
        l_card_network_id     := l_participant.card_network_id;
        l_auth_code           := l_participant.auth_code;

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_operation.id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant       => l_participant
        );

        l_acq_inst_id          := l_participant.inst_id;
        l_acq_network_id       := l_participant.network_id;
        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_acq_part.split_hash  := l_participant.split_hash;

        l_oper.terminal_type   := l_operation.terminal_type;
    else
        iss_api_bin_pkg.get_bin_info(
            i_card_number        => i_fin_rec.card_number
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_network_id   => l_iss_network_id
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_card_type        => l_card_type_id
            , o_card_country     => l_country_code
            , o_bin_currency     => l_bin_currency
            , o_sttl_currency    => l_sttl_currency
        );

        if l_card_inst_id is null then
            l_iss_inst_id := i_fin_rec.inst_id;
            l_iss_network_id := ost_api_institution_pkg.get_inst_network(i_fin_rec.inst_id);
        end if;

        l_acq_network_id := i_fin_rec.network_id;
        l_acq_inst_id := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);

        l_need_sttl_type := com_api_type_pkg.TRUE;
    end if;

    if i_oper_type is not null then
        l_oper.oper_type := i_oper_type;
    else 
        l_oper.oper_type :=
            case
                when i_fin_rec.trans_code in (vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                                            , vis_api_const_pkg.TC_FRAUD_ADVICE
                                            , vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE)
                then
                    l_operation.oper_type
                when i_fin_rec.trans_code in (vis_api_const_pkg.TC_FEE_COLLECTION
                                            , vis_api_const_pkg.TC_FUNDS_DISBURSEMENT)
                then
                    net_api_map_pkg.get_oper_type(
                        i_network_oper_type => i_fin_rec.trans_code || i_fee_rec.reason_code
                      , i_standard_id       => i_standard_id
                      , i_mask_error        => com_api_type_pkg.FALSE
                    )
                else
                    net_api_map_pkg.get_oper_type(
                        i_network_oper_type => i_fin_rec.trans_code || i_fin_rec.trans_code_qualifier || i_fin_rec.mcc || nvl(i_fin_rec.business_application_id, '__')
                      , i_standard_id       => i_standard_id
                      , i_mask_error        => com_api_type_pkg.FALSE
                    )
            end;
    end if;
    
    if l_need_sttl_type = com_api_type_pkg.TRUE then
        net_api_sttl_pkg.get_sttl_type (
            i_iss_inst_id        => l_iss_inst_id
            , i_acq_inst_id      => l_acq_inst_id
            , i_card_inst_id     => l_card_inst_id
            , i_iss_network_id   => l_iss_network_id
            , i_acq_network_id   => l_acq_network_id
            , i_card_network_id  => l_card_network_id
            , i_acq_inst_bin     => i_fin_rec.acq_inst_bin
            , o_sttl_type        => l_sttl_type
            , o_match_status     => l_match_status
            , i_oper_type        => l_oper.oper_type
            , i_mask_error       => com_api_type_pkg.TRUE
        );

        if l_sttl_type is null then
            l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

            trc_log_pkg.warn(
                i_text          => 'UNABLE_TO_DEFINE_SETTLEMENT_TYPE'
                , i_env_param1  => l_iss_inst_id
                , i_env_param2  => l_acq_inst_id
                , i_env_param3  => l_card_inst_id
                , i_env_param4  => l_iss_network_id
                , i_env_param5  => l_acq_network_id
                , i_env_param6  => l_card_network_id
            );
        end if;
    end if;

    l_oper.sttl_type := l_sttl_type;
    l_oper.msg_type := net_api_map_pkg.get_msg_type (
        i_network_msg_type  => i_fin_rec.usage_code || i_fin_rec.trans_code
        , i_standard_id     => i_standard_id
        , i_mask_error      => com_api_type_pkg.FALSE
    );

    l_oper.is_reversal        := i_fin_rec.is_reversal;
    l_oper.oper_amount        := i_fin_rec.oper_amount;
    l_oper.oper_currency      := i_fin_rec.oper_currency;
    l_oper.sttl_amount        := i_fin_rec.sttl_amount;
    l_oper.sttl_currency      := i_fin_rec.sttl_currency;
    l_oper.oper_date          := i_fin_rec.oper_date;
    l_oper.host_date          := null;

    if l_oper.terminal_type is null then
        l_oper.terminal_type :=
        case i_fin_rec.mcc
            when vis_api_const_pkg.MCC_ATM
            then acq_api_const_pkg.TERMINAL_TYPE_ATM
            else acq_api_const_pkg.TERMINAL_TYPE_POS
        end;
    end if;

    l_oper.acq_inst_bin       := i_fin_rec.acq_inst_bin;
    l_oper.mcc                := nvl(l_mcc,               i_fin_rec.mcc);
    l_oper.originator_refnum  := nvl(l_originator_refnum, i_fin_rec.rrn);
    l_oper.merchant_number    := nvl(l_merchant_number,   i_fin_rec.merchant_number);
    l_oper.terminal_number    := nvl(l_terminal_number,   i_fin_rec.terminal_number);
    l_oper.merchant_name      := nvl(l_merchant_name,     i_fin_rec.merchant_name);
    l_oper.merchant_street    := i_fin_rec.merchant_street;
    l_oper.merchant_city      := i_fin_rec.merchant_city;
    l_oper.merchant_region    := i_fin_rec.merchant_region;
    l_oper.merchant_country   := i_fin_rec.merchant_country;
    l_oper.merchant_postcode  := i_fin_rec.merchant_postal_code;
    l_oper.dispute_id         := i_fin_rec.dispute_id;
    l_oper.match_status       := l_match_status;
    l_oper.original_id        := coalesce(l_oper.original_id, get_original_id(i_fin_rec => i_fin_rec));

    if  i_fin_rec.trans_code in (vis_api_const_pkg.TC_SALES
                               , vis_api_const_pkg.TC_VOUCHER
                               , vis_api_const_pkg.TC_CASH)
        and i_fin_rec.usage_code = com_api_type_pkg.TRUE
        and iss_api_card_pkg.get_card_id(i_card_number => i_fin_rec.card_number) is null
    then
        l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

        trc_log_pkg.warn(
            i_text           => 'CARD_NOT_FOUND'
            , i_env_param1   => iss_api_card_pkg.get_card_mask(i_fin_rec.card_number)
            , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            , i_object_id    => l_oper.id
        );
    end if;

    l_iss_part.inst_id         := l_iss_inst_id;
    l_iss_part.network_id      := l_iss_network_id;
    l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value := i_fin_rec.card_number;
    l_iss_part.customer_id     := iss_api_card_pkg.get_customer_id(i_card_number => i_fin_rec.card_number);
    l_iss_part.card_id         := i_fin_rec.card_id;
    l_iss_part.card_type_id    := l_card_type_id;

    if nvl(i_fin_rec.card_expir_date, '*') = '0000' then
        begin
            select expir_date
              into l_iss_part.card_expir_date
              from (select i.expir_date
                      from iss_card_vw c
                         , iss_card_instance i
                     where c.id = i_fin_rec.card_id
                       and c.id = i.card_id
                  order by i.seq_number desc
           ) where rownum = 1;
        exception
            when no_data_found then
                l_iss_part.card_expir_date := null;
        end;
    else
        l_iss_part.card_expir_date := to_date(i_fin_rec.card_expir_date, 'YYMM');
    end if;

    l_iss_part.card_seq_number   := trim(i_fin_rec.card_seq_number);
    l_iss_part.card_number       := i_fin_rec.card_number;
    l_iss_part.card_mask         := i_fin_rec.card_mask;
    l_iss_part.card_country      := l_card_country;
    l_iss_part.card_inst_id      := l_card_inst_id;
    l_iss_part.card_network_id   := l_card_network_id;
    l_iss_part.account_id        := null;
    l_iss_part.account_number    := null;
    l_iss_part.account_amount    := null;
    l_iss_part.account_currency  := null;
    l_iss_part.auth_code         := nvl(l_auth_code, i_fin_rec.auth_code);

    l_acq_part.inst_id           := l_acq_inst_id;
    l_acq_part.network_id        := l_acq_network_id;

    l_oper.incom_sess_file_id    := i_incom_sess_file_id;

    opr_api_create_pkg.create_operation(
        i_oper      => l_oper
      , i_iss_part  => l_iss_part
      , i_acq_part  => l_acq_part
    );
    if i_create_disp_case = com_api_type_pkg.TRUE then
        csm_api_check_pkg.perform_check(
            i_oper_id           => l_oper.id
          , i_card_number       => l_iss_part.card_number
          , i_merchant_number   => l_oper.merchant_number
          , i_inst_id           => l_card_inst_id
          , i_msg_type          => l_oper.msg_type
          , i_dispute_id        => l_oper.dispute_id
          , i_de_024            => null
          , i_reason_code       => i_fee_rec.reason_code
          , i_original_id       => l_oper.original_id
          , i_de004             => i_fin_rec.dispute_amount
          , i_de049             => i_fin_rec.dispute_currency
        );
    end if;
end create_operation;

function put_message(
    i_fin_rec               in vis_api_type_pkg.t_visa_fin_mes_rec
) return com_api_type_pkg.t_long_id is
    l_id                    com_api_type_pkg.t_long_id;
begin
    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);

    insert into vis_fin_message(
        id
      , status
      , is_reversal
      , is_incoming
      , is_returned
      , is_invalid
      , inst_id
      , network_id
      , trans_code
      , trans_code_qualifier
      , card_id
      , card_hash
      , card_mask
      , oper_amount
      , oper_currency
      , oper_date
      , sttl_amount
      , sttl_currency
      , arn
      , acq_business_id
      , merchant_name
      , merchant_city
      , merchant_country
      , merchant_postal_code
      , merchant_region
      , mcc
      , req_pay_service
      , usage_code
      , reason_code
      , settlement_flag
      , auth_char_ind
      , auth_code
      , pos_terminal_cap
      , inter_fee_ind
      , crdh_id_method
      , collect_only_flag
      , pos_entry_mode
      , central_proc_date
      , reimburst_attr
      , iss_workst_bin
      , acq_workst_bin
      , chargeback_ref_num
      , docum_ind
      , member_msg_text
      , spec_cond_ind
      , fee_program_ind
      , issuer_charge
      , merchant_number
      , terminal_number
      , national_reimb_fee
      , electr_comm_ind
      , spec_chargeback_ind
      , interface_trace_num
      , unatt_accept_term_ind
      , prepaid_card_ind
      , service_development
      , avs_resp_code
      , auth_source_code
      , purch_id_format
      , account_selection
      , installment_pay_count
      , purch_id
      , cashback
      , chip_cond_code
      , transaction_id
      , pos_environment
      , transaction_type
      , card_seq_number
      , terminal_profile
      , unpredict_number
      , appl_trans_counter
      , appl_interch_profile
      , cryptogram
      , term_verif_result
      , cryptogram_amount
      , card_expir_date
      , cryptogram_version
      , cvv2_result_code
      , auth_resp_code
      , card_verif_result
      , floor_limit_ind
      , exept_file_ind
      , pcas_ind
      , issuer_appl_data
      , issuer_script_result
      , network_amount
      , network_currency
      , dispute_id
      , file_id
      , batch_id
      , record_number
      , rrn
      , acquirer_bin
      , merchant_street
      , cryptogram_info_data
      , merchant_verif_value
      , host_inst_id
      , proc_bin
      , chargeback_reason_code
      , destination_channel
      , source_channel
      , acq_inst_bin
      , clearing_sequence_num
      , clearing_sequence_count
      , service_code
      , business_format_code
      , token_assurance_level
      , pan_token
      , validation_code
      , spend_qualified_ind
      , payment_forms_num
      , business_format_code_e
      , agent_unique_id
      , additional_auth_method
      , additional_reason_code
      , product_id
      , auth_amount
      , auth_currency
      , form_factor_indicator
      , fast_funds_indicator
      , business_format_code_3
      , business_application_id
      , source_of_funds
      , payment_reversal_code
      , sender_reference_number
      , sender_account_number
      , sender_name
      , sender_address
      , sender_city
      , sender_state
      , sender_country
      , network_code
      , fee_interchange_amount
      , fee_interchange_sign
      , program_id
      , dcc_indicator
      , terminal_country
      , recipient_name
      , terminal_trans_date
      , conv_date
    ) values (
        l_id
      , i_fin_rec.status
      , i_fin_rec.is_reversal
      , i_fin_rec.is_incoming
      , i_fin_rec.is_returned
      , i_fin_rec.is_invalid
      , i_fin_rec.inst_id
      , i_fin_rec.network_id
      , i_fin_rec.trans_code
      , i_fin_rec.trans_code_qualifier
      , i_fin_rec.card_id
      , i_fin_rec.card_hash
      , i_fin_rec.card_mask
      , i_fin_rec.oper_amount
      , i_fin_rec.oper_currency
      , i_fin_rec.oper_date
      , i_fin_rec.sttl_amount
      , i_fin_rec.sttl_currency
      , i_fin_rec.arn
      , i_fin_rec.acq_business_id
      , i_fin_rec.merchant_name
      , i_fin_rec.merchant_city
      , i_fin_rec.merchant_country
      , i_fin_rec.merchant_postal_code
      , i_fin_rec.merchant_region
      , i_fin_rec.mcc
      , i_fin_rec.req_pay_service
      , i_fin_rec.usage_code
      , i_fin_rec.reason_code
      , i_fin_rec.settlement_flag
      , i_fin_rec.auth_char_ind
      , i_fin_rec.auth_code
      , i_fin_rec.pos_terminal_cap
      , i_fin_rec.inter_fee_ind
      , i_fin_rec.crdh_id_method
      , i_fin_rec.collect_only_flag
      , i_fin_rec.pos_entry_mode
      , i_fin_rec.central_proc_date
      , i_fin_rec.reimburst_attr
      , i_fin_rec.iss_workst_bin
      , i_fin_rec.acq_workst_bin
      , i_fin_rec.chargeback_ref_num
      , i_fin_rec.docum_ind
      , i_fin_rec.member_msg_text
      , i_fin_rec.spec_cond_ind
      , i_fin_rec.fee_program_ind
      , i_fin_rec.issuer_charge
      , i_fin_rec.merchant_number
      , i_fin_rec.terminal_number
      , i_fin_rec.national_reimb_fee
      , i_fin_rec.electr_comm_ind
      , i_fin_rec.spec_chargeback_ind
      , i_fin_rec.interface_trace_num
      , i_fin_rec.unatt_accept_term_ind
      , i_fin_rec.prepaid_card_ind
      , i_fin_rec.service_development
      , i_fin_rec.avs_resp_code
      , i_fin_rec.auth_source_code
      , i_fin_rec.purch_id_format
      , i_fin_rec.account_selection
      , i_fin_rec.installment_pay_count
      , i_fin_rec.purch_id
      , i_fin_rec.cashback
      , i_fin_rec.chip_cond_code
      , i_fin_rec.transaction_id
      , i_fin_rec.pos_environment
      , i_fin_rec.transaction_type
      , i_fin_rec.card_seq_number
      , i_fin_rec.terminal_profile
      , i_fin_rec.unpredict_number
      , i_fin_rec.appl_trans_counter
      , i_fin_rec.appl_interch_profile
      , i_fin_rec.cryptogram
      , i_fin_rec.term_verif_result
      , i_fin_rec.cryptogram_amount
      , i_fin_rec.card_expir_date
      , i_fin_rec.cryptogram_version
      , i_fin_rec.cvv2_result_code
      , i_fin_rec.auth_resp_code
      , i_fin_rec.card_verif_result
      , i_fin_rec.floor_limit_ind
      , i_fin_rec.exept_file_ind
      , i_fin_rec.pcas_ind
      , i_fin_rec.issuer_appl_data
      , i_fin_rec.issuer_script_result
      , i_fin_rec.network_amount
      , i_fin_rec.network_currency
      , i_fin_rec.dispute_id
      , i_fin_rec.file_id
      , i_fin_rec.batch_id
      , i_fin_rec.record_number
      , i_fin_rec.rrn
      , i_fin_rec.acquirer_bin
      , i_fin_rec.merchant_street
      , i_fin_rec.cryptogram_info_data
      , i_fin_rec.merchant_verif_value
      , i_fin_rec.host_inst_id
      , i_fin_rec.proc_bin
      , i_fin_rec.chargeback_reason_code
      , i_fin_rec.destination_channel
      , i_fin_rec.source_channel
      , i_fin_rec.acq_inst_bin
      , i_fin_rec.clearing_sequence_num
      , i_fin_rec.clearing_sequence_count
      , i_fin_rec.service_code
      , i_fin_rec.business_format_code
      , i_fin_rec.token_assurance_level
      , i_fin_rec.pan_token
      , i_fin_rec.validation_code
      , i_fin_rec.spend_qualified_ind
      , i_fin_rec.payment_forms_num
      , i_fin_rec.business_format_code_e
      , i_fin_rec.agent_unique_id
      , i_fin_rec.additional_auth_method
      , i_fin_rec.additional_reason_code
      , i_fin_rec.product_id
      , i_fin_rec.auth_amount
      , i_fin_rec.auth_currency
      , i_fin_rec.form_factor_indicator
      , i_fin_rec.fast_funds_indicator
      , i_fin_rec.business_format_code_3
      , i_fin_rec.business_application_id
      , i_fin_rec.source_of_funds
      , i_fin_rec.payment_reversal_code
      , i_fin_rec.sender_reference_number
      , i_fin_rec.sender_account_number
      , i_fin_rec.sender_name
      , i_fin_rec.sender_address
      , i_fin_rec.sender_city
      , i_fin_rec.sender_state
      , i_fin_rec.sender_country
      , i_fin_rec.network_code
      , i_fin_rec.interchange_fee_amount
      , i_fin_rec.interchange_fee_sign
      , i_fin_rec.program_id
      , i_fin_rec.dcc_indicator
      , i_fin_rec.terminal_country
      , i_fin_rec.recipient_name
      , i_fin_rec.terminal_trans_date
      , i_fin_rec.conv_date
    );

    insert into vis_card (
        id
      , card_number
    ) values (
        l_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    if i_fin_rec.usage_code = '9' and i_fin_rec.trans_code <> vis_api_const_pkg.TC_MULTIPURPOSE_MESSAGE then
        insert into vis_tcr4 (
            id
          , trans_comp_number
          , agent_unique_id
          , business_format_code
          , contact_information
          , adjustment_indicator
          , message_reason_code
          , dispute_condition
          , vrol_financial_id
          , vrol_case_number
          , vrol_bundle_number
          , client_case_number
          , dispute_status
          , surcharge_amount
          , surcharge_sign
          , payment_acc_ref
          , token_requestor_id
        ) values (
            l_id
          , '4'
          , i_fin_rec.agent_unique_id
          , nvl(i_fin_rec.business_format_code_4, 'DF')
          , null
          , ' '
          , null --i_fin_rec.message_reason_code
          , i_fin_rec.dispute_condition
          , i_fin_rec.vrol_financial_id
          , i_fin_rec.vrol_case_number
          , i_fin_rec.vrol_bundle_number
          , i_fin_rec.client_case_number
          , i_fin_rec.dispute_status
          , i_fin_rec.surcharge_amount
          , i_fin_rec.surcharge_sign
          , null
          , null
        );
    elsif i_fin_rec.agent_unique_id is not null
          or i_fin_rec.payment_acc_ref is not null
          or i_fin_rec.token_requestor_id is not null
    then
        insert into vis_tcr4 (
            id
          , trans_comp_number
          , agent_unique_id
          , business_format_code
          , contact_information
          , adjustment_indicator
          , message_reason_code
          , dispute_condition
          , vrol_financial_id
          , vrol_case_number
          , vrol_bundle_number
          , client_case_number
          , dispute_status
          , surcharge_amount
          , surcharge_sign
          , payment_acc_ref
          , token_requestor_id
        ) values (
            l_id
          , '4'
          , i_fin_rec.agent_unique_id
          , nvl(i_fin_rec.business_format_code_4, 'SD')
          , null
          , ' '
          , i_fin_rec.message_reason_code --null
          , null
          , null
          , null
          , null
          , null
          , null
          , i_fin_rec.surcharge_amount
          , i_fin_rec.surcharge_sign
          , i_fin_rec.payment_acc_ref
          , i_fin_rec.token_requestor_id
        );
    end if;
    
    if i_fin_rec.business_format_code_3 = vis_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER then
        insert into vis_tcr3(
            id
          , trans_comp_number
          , business_application_id
          , business_format_code
          , passenger_name
          , departure_date
          , orig_city_airport_code
          , carrier_code_1
          , service_class_code_1
          , stop_over_code_1
          , dest_city_airport_code_1
          , carrier_code_2
          , service_class_code_2
          , stop_over_code_2
          , dest_city_airport_code_2
          , carrier_code_3
          , service_class_code_3
          , stop_over_code_3
          , dest_city_airport_code_3
          , carrier_code_4
          , service_class_code_4
          , stop_over_code_4
          , dest_city_airport_code_4
          , travel_agency_code
          , travel_agency_name
          , restrict_ticket_indicator
          , fare_basis_code_1
          , fare_basis_code_2
          , fare_basis_code_3
          , fare_basis_code_4
          , comp_reserv_system
          , flight_number_1
          , flight_number_2
          , flight_number_3
          , flight_number_4
          , credit_reason_indicator
          , ticket_change_indicator
        ) values(
            l_id
          , i_fin_rec.trans_comp_number_tcr3
          , i_fin_rec.business_application_id_tcr3
          , i_fin_rec.business_format_code_3
          , i_fin_rec.passenger_name
          , i_fin_rec.departure_date
          , i_fin_rec.orig_city_airport_code
          , i_fin_rec.carrier_code_1
          , i_fin_rec.service_class_code_1
          , i_fin_rec.stop_over_code_1
          , i_fin_rec.dest_city_airport_code_1
          , i_fin_rec.carrier_code_2
          , i_fin_rec.service_class_code_2
          , i_fin_rec.stop_over_code_2
          , i_fin_rec.dest_city_airport_code_2
          , i_fin_rec.carrier_code_3
          , i_fin_rec.service_class_code_3
          , i_fin_rec.stop_over_code_3
          , i_fin_rec.dest_city_airport_code_3
          , i_fin_rec.carrier_code_4
          , i_fin_rec.service_class_code_4
          , i_fin_rec.stop_over_code_4
          , i_fin_rec.dest_city_airport_code_4
          , i_fin_rec.travel_agency_code
          , i_fin_rec.travel_agency_name
          , i_fin_rec.restrict_ticket_indicator
          , i_fin_rec.fare_basis_code_1
          , i_fin_rec.fare_basis_code_2
          , i_fin_rec.fare_basis_code_3
          , i_fin_rec.fare_basis_code_4
          , i_fin_rec.comp_reserv_system
          , i_fin_rec.flight_number_1
          , i_fin_rec.flight_number_2
          , i_fin_rec.flight_number_3
          , i_fin_rec.flight_number_4
          , i_fin_rec.credit_reason_indicator
          , i_fin_rec.ticket_change_indicator
        );
    end if;
    
    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] VISA fin messages'
        , i_env_param1  => l_id
    );

    return l_id;
end put_message;

procedure put_retrieval(
    i_retrieval_rec         in vis_api_type_pkg.t_retrieval_rec
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    l_id := nvl(i_retrieval_rec.id, opr_api_create_pkg.get_id);

    insert into vis_retrieval(
        id
        , file_id
        , req_id
        , purchase_date
        , source_amount
        , source_currency
        , reason_code
        , national_reimb_fee
        , atm_account_sel
        , reimb_flag
        , fax_number
        , req_fulfill_method
        , used_fulfill_method
        , iss_rfc_bin
        , iss_rfc_subaddr
        , iss_billing_currency
        , iss_billing_amount
        , trans_id
        , excluded_trans_id_reason
        , crs_code
        , multiple_clearing_seqn
        , product_code
        , contact_info
        , iss_inst_id
        , acq_inst_id
    )
    values (
        l_id
        , i_retrieval_rec.file_id
        , i_retrieval_rec.req_id
        , i_retrieval_rec.purchase_date
        , i_retrieval_rec.source_amount
        , i_retrieval_rec.source_currency
        , i_retrieval_rec.reason_code
        , i_retrieval_rec.national_reimb_fee
        , i_retrieval_rec.atm_account_sel
        , i_retrieval_rec.reimb_flag
        , i_retrieval_rec.fax_number
        , i_retrieval_rec.req_fulfill_method
        , i_retrieval_rec.used_fulfill_method
        , i_retrieval_rec.iss_rfc_bin
        , i_retrieval_rec.iss_rfc_subaddr
        , i_retrieval_rec.iss_billing_currency
        , i_retrieval_rec.iss_billing_amount
        , i_retrieval_rec.transaction_id
        , i_retrieval_rec.excluded_trans_id_reason
        , i_retrieval_rec.crs_code
        , i_retrieval_rec.multiple_clearing_seqn
        , i_retrieval_rec.product_code
        , i_retrieval_rec.contact_info
        , i_retrieval_rec.iss_inst_id
        , i_retrieval_rec.acq_inst_id
    );

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] VISA fin messages'
        , i_env_param1  => l_id
    );
end put_retrieval;

procedure put_fee(
    i_fee_rec               in vis_api_type_pkg.t_fee_rec
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    l_id := nvl(i_fee_rec.id, opr_api_create_pkg.get_id);

    insert into vis_fee(
        id
        , file_id
        , pay_fee
        , dst_bin
        , src_bin
        , reason_code
        , country_code
        , event_date
        , pay_amount
        , pay_currency
        , src_amount
        , src_currency
        , message_text
        , trans_id
        , reimb_attr
        , dst_inst_id
        , src_inst_id
        , funding_source
    )
    values (
        l_id
        , i_fee_rec.file_id
        , i_fee_rec.pay_fee
        , i_fee_rec.dst_bin
        , i_fee_rec.src_bin
        , i_fee_rec.reason_code
        , i_fee_rec.country_code
        , i_fee_rec.event_date
        , i_fee_rec.pay_amount
        , i_fee_rec.pay_currency
        , i_fee_rec.src_amount
        , i_fee_rec.src_currency
        , i_fee_rec.message_text
        , i_fee_rec.trans_id
        , i_fee_rec.reimb_attr
        , i_fee_rec.dst_inst_id
        , i_fee_rec.src_inst_id
        , i_fee_rec.funding_source
    );

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] VISA fin messages'
        , i_env_param1  => l_id
    );
end put_fee;

procedure put_fraud(
    i_fraud_rec  in vis_api_type_pkg.t_visa_fraud_rec
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    -- Function coalesce let to avoid useless shift of a sequence
    -- <opr_operation_seq> by calling opr_api_create_pkg.get_id()
    l_id := coalesce(i_fraud_rec.id, opr_api_create_pkg.get_id);

    insert into vis_fraud (
        id
        , file_id
        , rec_no
        , batch_file_id
        , batch_rec_no
        , fraud_msg_ref
        , reject_msg_no
        , dispute_id
        , delete_flag
        , is_rejected
        , is_incoming
        , status
        , inst_id
        , agent_id
        , dest_bin
        , source_bin
        , account_number
        , arn
        , acq_business_id
        , response_code
        , purchase_date
        , merchant_name
        , merchant_city
        , merchant_country
        , merchant_postal_code
        , mcc
        , state_province
        , fraud_amount
        , fraud_currency
        , vic_processing_date
        , iss_gen_auth
        , notification_code
        , account_seq_number
        , reserved
        , fraud_type
        , card_expir_date
        , fraud_inv_status
        , reimburst_attr
        , addendum_present
        , transaction_id
        , excluded_trans_id_reason
        , multiple_clearing_seqn
        , merchant_number
        , terminal_number
        , travel_agency_id
        , auth_code
        , crdh_id_method
        , pos_entry_mode
        , pos_terminal_cap
        , card_capability
        , crdh_activated_term_ind
        , cashback_ind
        , cashback
        , electr_comm_ind
        , iss_inst_id
        , acq_inst_id
        , last_update
        , agent_unique_id
        , payment_account_ref
        , network_id
        , host_inst_id
        , proc_bin
    )
    values (
        l_id
        , i_fraud_rec.file_id
        , i_fraud_rec.rec_no
        , i_fraud_rec.batch_file_id
        , i_fraud_rec.batch_rec_no
        , i_fraud_rec.fraud_msg_ref
        , i_fraud_rec.reject_msg_no
        , i_fraud_rec.dispute_id
        , i_fraud_rec.delete_flag
        , i_fraud_rec.is_rejected
        , i_fraud_rec.is_incoming
        , i_fraud_rec.status
        , i_fraud_rec.inst_id
        , i_fraud_rec.agent_id
        , i_fraud_rec.dest_bin
        , i_fraud_rec.source_bin
        , i_fraud_rec.account_number
        , i_fraud_rec.arn
        , i_fraud_rec.acq_business_id
        , i_fraud_rec.response_code
        , i_fraud_rec.purchase_date
        , i_fraud_rec.merchant_name
        , i_fraud_rec.merchant_city
        , i_fraud_rec.merchant_country
        , i_fraud_rec.merchant_postal_code
        , i_fraud_rec.mcc
        , i_fraud_rec.state_province
        , i_fraud_rec.fraud_amount
        , i_fraud_rec.fraud_currency
        , i_fraud_rec.vic_processing_date
        , i_fraud_rec.iss_gen_auth
        , i_fraud_rec.notification_code
        , i_fraud_rec.account_seq_number
        , i_fraud_rec.reserved
        , i_fraud_rec.fraud_type
        , i_fraud_rec.card_expir_date
        , i_fraud_rec.fraud_inv_status
        , i_fraud_rec.reimburst_attr
        , i_fraud_rec.addendum_present
        , i_fraud_rec.transaction_id
        , i_fraud_rec.excluded_trans_id_reason
        , i_fraud_rec.multiple_clearing_seqn
        , i_fraud_rec.merchant_number
        , i_fraud_rec.terminal_number
        , i_fraud_rec.travel_agency_id
        , i_fraud_rec.auth_code
        , i_fraud_rec.crdh_id_method
        , i_fraud_rec.pos_entry_mode
        , i_fraud_rec.pos_terminal_cap
        , i_fraud_rec.card_capability
        , i_fraud_rec.crdh_activated_term_ind
        , i_fraud_rec.cashback_ind
        , i_fraud_rec.cashback
        , i_fraud_rec.electr_comm_ind
        , i_fraud_rec.iss_inst_id
        , i_fraud_rec.acq_inst_id
        , i_fraud_rec.last_update
        , i_fraud_rec.agent_unique_id
        , i_fraud_rec.payment_account_ref
        , i_fraud_rec.network_id
        , i_fraud_rec.host_inst_id
        , i_fraud_rec.proc_bin
    );

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] VISA fraud messages'
        , i_env_param1  => l_id
    );
end put_fraud;

function is_collection_allow(
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_mcc                 in com_api_type_pkg.t_mcc
) return com_api_type_pkg.t_boolean is
    l_param_val         com_api_type_pkg.t_dict_value;
    l_return            com_api_type_pkg.t_boolean;
    l_host_id           com_api_type_pkg.t_tiny_id;
    l_standard_id       com_api_type_pkg.t_tiny_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
begin

    l_host_id := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);

    if l_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_NETWORK'
            , i_env_param1  => i_network_id
        );
    end if;

    cmn_api_standard_pkg.get_param_value (
        i_inst_id        => i_inst_id
        , i_standard_id  => l_standard_id
        , i_object_id    => l_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => vis_api_const_pkg.COLLECTION_ONLY
        , o_param_value  => l_param_val
        , i_param_tab    => l_param_tab
    );

    if (l_param_val = vis_api_const_pkg.COLLECTION_ONLY_NOWD
        and i_mcc not in (vis_api_const_pkg.MCC_CASH, vis_api_const_pkg.MCC_ATM)) then
        l_return := com_api_const_pkg.true;
    elsif (l_param_val = vis_api_const_pkg.COLLECTION_ONLY_ALL) then
        l_return := com_api_const_pkg.true;
    else
        l_return := com_api_const_pkg.false;
    end if;

    return l_return;
end is_collection_allow;

/*
 * Function parses incoming value card_data_input_mode and returns POS entry mode.
 */
function get_pos_entry_mode(
    i_card_data_input_mode  in com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.t_pos_entry_mode
is
begin
    return
        case
            -- Magnetic stripe read and exact content of Track 1 or Track 2 included (CVV check is possible)
            when i_card_data_input_mode = 'F227000B'                then '90'
            -- Integrated circuit card read; CVV or iCVV data reliable
            when i_card_data_input_mode in ('F227000C', 'F227000F') then '05'
            -- Manual key entry
            when i_card_data_input_mode in ('F2270006', 'F227000S', 'F2270005', 'F2270007', 'F2270009') then '01'
            -- Proximity Payment using VSDC chip data rules
            when i_card_data_input_mode = 'F227000M'                then '07'
            -- Proximity payment using magnetic stripe data rules
            when i_card_data_input_mode = 'F227000A'                then '91'
            -- Magnetic stripe read; CVV checking may not be possible
            when i_card_data_input_mode = 'F2270002'                then '02'
            -- Credential on file
            when i_card_data_input_mode = 'F227000E'                then '10'
            -- Barcode read
            when i_card_data_input_mode = 'F2270003'                then '03'
                                                                                else null
        end;
end get_pos_entry_mode;

function is_visa(
    i_id                      in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result com_api_type_pkg.t_boolean;
begin
    select count(1)
      into l_result
      from vis_fin_message
     where id = i_id
       and rownum <= 1;
    if l_result = 0 then
        select count(1)
          into l_result
          from vis_fraud
         where id = i_id
           and rownum <= 1;
    end if;

    return l_result;
end is_visa;

function is_visa_sms(
    i_id    in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
begin
    select count(1)
      into l_result
      from vis_fin_message fm
         , opr_participant iss
     where fm.id                = i_id
       and iss.oper_id          = fm.id
       and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and iss.inst_id          = vis_api_const_pkg.INSTITUTION_VISA_SMS
       and rownum <= 1;

    return l_result;
end is_visa_sms;

/*
 * Remove message and related operation
 */ 
procedure remove_message(
    i_id    in     com_api_type_pkg.t_long_id
  , i_force                   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
begin
    delete 
      from vis_fin_message
     where id = i_id;
    if sql%rowcount = 0 and i_force = com_api_type_pkg.FALSE then
        trc_log_pkg.debug(
            i_text       => 'Remove visa message: [#1] is not found'
          , i_env_param1 => i_id
        );
    else
        opr_api_operation_pkg.remove_operation(
            i_oper_id => i_id
        );
    end if;
end remove_message;

/*
 * Check if editable
 */ 
function is_editable(
    i_id              in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result    com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    for r in (
        select id
          from vis_fin_message
         where id          = i_id
           and is_incoming = com_api_const_pkg.FALSE
           and status      = net_api_const_pkg.CLEARING_MSG_STATUS_READY
           and rownum      = 1
    )
    loop
        l_result := com_api_const_pkg.TRUE;
        exit;
    end loop;

    return l_result;
end is_editable;

function is_doc_export_import_enabled(
    i_id              in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result    com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
   select count(1)
     into l_result
     from vis_fin_message
    where id          = i_id
      and (
              (trans_code = vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY)
           or (trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK
                            , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                            , vis_api_const_pkg.TC_CASH_CHARGEBACK) and usage_code in (1, 9))
           or (trans_code in (vis_api_const_pkg.TC_SALES
                            , vis_api_const_pkg.TC_VOUCHER
                            , vis_api_const_pkg.TC_CASH) and usage_code in (2, 9))
           );

    return l_result;
end is_doc_export_import_enabled;

procedure get_bin_range_data(
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_card_type_id        in     com_api_type_pkg.t_tiny_id
  , o_product_id             out com_api_type_pkg.t_dict_value
  , o_region                 out com_api_type_pkg.t_dict_value
  , o_account_funding_source out com_api_type_pkg.t_dict_value
) is
begin
    for tab in (
        select n.product_id             as product_id
             , n.region                 as region
             , n.account_funding_source as account_funding_source
          from (select bin.product_id
                     , bin.region
                     , bin.account_funding_source
                     , rownum rn
                  from vis_bin_range bin
                  join net_bin_range_index ind on ind.pan_low   = rpad(bin.pan_low,  bin.pan_length, '0')
                                              and ind.pan_high  = rpad(bin.pan_high, bin.pan_length, '9')
                 where substr(i_card_number, 1, 9) between bin.pan_low and bin.pan_high
                   and length(i_card_number) = bin.pan_length         
               ) n
         where rn = 1
    )
    loop
        o_product_id             := tab.product_id;
        o_region                 := tab.region;
        o_account_funding_source := tab.account_funding_source;
    end loop;
    
    trc_log_pkg.debug(
        i_text => 'vis get_bin_range_data: card_number' || i_card_number || ' product_id=' || o_product_id ||
                  ' region=' || o_region || ' account_funding_source=' || o_account_funding_source
    );
        
end get_bin_range_data;

end vis_api_fin_message_pkg;
/
