create or replace package body way_api_fin_message_pkg as
/*********************************************************
 *  API for VISA financial message <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Module: VIS_API_FIN_MESSAGE_PKG   <br />
 *  @headcom
 **********************************************************/

-- fin. message
/*
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
|| ', o.oper_surcharge_amount'
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
|| ', row_number() over (partition by fr.dispute_id order by fr.id) row_num'
;

G_COLUMN_LIST_FIN       constant com_api_type_pkg.t_sql_statement :=
   '  owd.msg_code'
|| ', vfm.id                                                  drn'
|| ', case'
|| '    when pti.participant_type = ''PRTYISS'''
|| '      and pti.network_id   = 1015'
|| '      and pti.inst_id      = 9015'
|| '      then'
|| '        vc.card_number'
|| '    else'
|| '        vfm.terminal_number'
|| '  end                                                     dest_contr_num'
|| ', vfm.oper_amount / power (10, nvl (cur.exponent, 0))     amount'
|| ', to_char(vfm.oper_date, ''dd.mm.yyyy hh24:mi:ss'')       local_dt'
|| ', vfm.mcc                                                 sic'
|| ', vfm.arn                                                 arn'
|| ', vfm.auth_code                                           auth_code'
|| ', case'
|| '    when pti.participant_type = ''PRTYISS'''
|| '      and pti.network_id   = 1015'
|| '      and pti.inst_id      = 9015'
|| '      then'
|| '        vfm.terminal_number'
|| '    else'
|| '        vc.card_number'
|| '  end                                                     org_contr_num'
|| ', vfm.merchant_number                                     src_mrc_id'
|| ', vfm.merchant_city                                       mrc_city'
|| ', vfm.merchant_postal_code                                mrc_state'
|| ', vfm.merchant_country                                    mrc_country'
|| ', vfm.merchant_name                                       descrp'
|| ', nvl(vfm.card_seq_number, pti.card_seq_number)           card_seqn'
|| ', vfm.oper_currency                                       currency'
|| ', lpad(com_api_flexible_data_pkg.get_flexible_value('
|| '    i_field_name  => ''WAY_MEMBER_ID'''
|| '  , i_entity_type => ''ENTTINST'''
|| '  , i_object_id   => 9015), 6, ''0'')                     member_id'
|| ', lpad(com_api_flexible_data_pkg.get_flexible_value('
|| '    i_field_name  => ''WAY_MEMBER_ID'''
|| '  , i_entity_type => ''ENTTINST'''
|| '  , i_object_id   => 9015), 6, ''0'')                     transit_id'
|| ', owd.orig_drn                                            origdrn'
|| ', owd.prev_drn                                            prevdrn'
|| ', vfm.id                                                  p_bo_utrnno'
|| ', vfm.rrn'
|| ', owd.trans_condition'
|| ', to_char(pti.card_expir_date, ''dd.mm.yyyy hh24:mi:ss'') card_exp'
|| ', to_char(owd.orig_trans_date, ''dd.mm.yyyy hh24:mi:ss'') origtransdate'
|| ', 0                                                       org_reltn'
|| ', 0                                                       dest_reltn'
|| ', case'
|| '    when vfm.pos_entry_mode in (''05'', ''07'')'
|| '    then'
|| '        lpad(vfm.card_seq_number, 3, ''0'')'
|| '    else'
|| '        null'
|| '  end                                                     f23'
|| ', vfm.appl_interch_profile                                tag82'
|| ', vfm.term_verif_result                                   tag95'
|| ', lpad(vfm.transaction_type, 2, ''0'')                    tag9c'
|| ', vfm.issuer_appl_data                                    tag9f10'
|| ', vfm.cryptogram                                          tag9f26'
|| ', vfm.terminal_profile                                    tag9f33'
|| ', vfm.appl_trans_counter                                  tag9f36'
|| ', vfm.unpredict_number                                    tag9f37'
|| ', substr(vfm.issuer_script_result, -1)                    tag9f5b'
|| ', null                                                    reason_code'
|| ', substr('
|| '    vc.card_number ||'' ''||'
|| '    ca.street      ||'' ''||'
|| '    ctr.name       ||'' ''||'
|| '    ca.postal_code'
|| '  , 50)                                                   reason_details'
|| ', null                                                    requirement'
|| ', owd.ptid'
|| ', owd.trans_location'
|| ', owd.postal_code'
|| ', owd.src'
|| ', owd.tcashback_curr'
|| ', owd.tcashback_amount'
|| ', owd.surcharge_curr'
|| ', owd.surcharge_amount'
|| ', owd.mbr_reconc_ind'
|| ', owd.cpna'
|| ', owd.cpad'
|| ', owd.cpcy'
|| ', owd.cpst'
|| ', owd.cpcn'
|| ', owd.cppc'
|| ', to_char(owd.cpdb, ''dd.mm.yyyy hh24:mi:ss'')            cpdb'
|| ', owd.utrn'
|| ', owd.rpph'
|| ', owd.rpna'
|| ', owd.dev_tag'
|| ', owd.cps'
|| ', vfm.form_factor_indicator                               tag9f6e'
|| ', owd.emv_5f2a                                            tag5f2a'
|| ', case'
|| '    when owd.emv_9f02 is null'
|| '    then'
|| '        to_char(owd.emv_9f02)'
|| '    else'
|| '    lpad(owd.emv_9f02, 12, ''0'')'
|| '  end                                                     tag9f02'
|| ', owd.emv_9f1a                                            tag9f1a'
|| ', owd.emv_9a                                              tag9a'
|| ', owd.emv_84                                              tag84'
|| ', owd.trn'
|| ', vfm.proc_bin'
|| ', vfm.trans_code'
  ;*/
/*
procedure get_fin_mes(
    i_id                    in com_api_type_pkg.t_long_id
    , o_fin_rec             out vis_api_type_pkg.t_visa_fin_mes_rec
    , i_mask_error          in com_api_type_pkg.t_boolean
) is
    l_fin_cur               sys_refcursor;
    l_statement              com_api_type_pkg.t_sql_statement;
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
end;

function estimate_messages_for_upload(
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) return number is
    l_result                number;
begin
    select --+ INDEX(f, vis_fin_message_CLMS0010_ndx)
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
end;
*/
function estimate_fin_for_upload(
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) return number is
    l_result                number;
begin
    select
        count(f.id)
      into l_result
               from vis_fin_message f
                  , opr_operation o
    where
      decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
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
end estimate_fin_for_upload;
/*
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
select --+ INDEX(f, vis_fin_message_CLMS0010_ndx)
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
*/
/*
procedure enum_fin_msg_for_upload(
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
select --+ INDEX(vfm, vis_fin_message_CLMS0010_ndx)
    ' || G_COLUMN_LIST_FIN || '
from
    vis_fin_message vfm
  , way_additional_data owd
  , opr_operation opr
  , opr_participant pti
  , opr_operation orig
  , com_currency cur
  , com_country cou
  , vis_card vc
  , com_address_object cao
  , com_country ctr
  , com_address ca
where
    decode(vfm.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
             || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
    || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''

  and vfm.is_incoming = :is_incoming_0
  and pti.oper_id = vfm.id
  and pti.participant_type = ''PRTYISS''
  and vfm.network_id = :i_network_id
  and vfm.inst_id = :i_inst_id
  and vfm.host_inst_id = :i_host_inst_id
  and vc.id = vfm.id
  and opr.id = vfm.id
  and orig.id = opr.original_id (+)
  and owd.oper_id = vfm.id (+)
  and owd.msg_code(+) is not null
  and cur.code = vfm.oper_currency
  and cou.code = vfm.merchant_country
  and cao.object_id (+) = pti.customer_id
  and cao.entity_type (+) = ''ENTTCUST''
  and cao.address_type (+) = ''ADTPHOME''
  and ctr.code = ca.country
  and ca.id = cao.address_id
  ' || DATE_PLACEHOLDER || '
order by
    proc_bin, trans_code';

    l_stmt := replace (
        l_stmt
      , DATE_PLACEHOLDER
      , case
            when i_start_date is not null or i_end_date is not null then '
    and (vfm.oper_date between nvl(:i_start_date, trunc(vfm.oper_date))
                         and nvl(:i_end_date, trunc(vfm.oper_date)) + 1 - 1/86400
         and vfm.is_reversal = ' || com_api_type_pkg.FALSE || '
         or
         opr.host_date between nvl(:i_start_date, trunc(opr.host_date))
                         and nvl(:i_end_date, trunc(opr.host_date)) + 1 - 1/86400
         and vfm.is_reversal = ' || com_api_type_pkg.TRUE || ') '
            else
                ' '
        end
    );

--dbms_output.put_line(l_stmt);

    if i_start_date is not null or i_end_date is not null then
        open o_fin_cur for l_stmt
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id, i_start_date, i_end_date, i_start_date, i_end_date;
    else
        open o_fin_cur for l_stmt
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;

    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT)  || '.enum_fin_msg_for_upload >> FAILED with l_stmt:'
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
end enum_fin_msg_for_upload;
*/
/*
function get_original_id (
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
end;

function get_original_id (
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

    if i_fin_rec.usage_code = '1' then
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

procedure get_fee (
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
end;

procedure get_retrieval (
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
end;
*/
procedure process_auth(
    i_auth_rec        in      aut_api_type_pkg.t_auth_rec
  , i_inst_id         in      com_api_type_pkg.t_inst_id     default null
  , i_network_id      in      com_api_type_pkg.t_tiny_id     default null
  , i_collect_only    in      varchar2                       default null
  , i_status          in      com_api_type_pkg.t_dict_value  default null
  , io_fin_mess_id    in out  com_api_type_pkg.t_long_id
) is
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_cps_retail_flag       com_api_type_pkg.t_boolean;
    l_cps_atm_flag          com_api_type_pkg.t_boolean;
    l_tcc                   com_api_type_pkg.t_mcc;
    l_diners_code           com_api_type_pkg.t_mcc;
    l_cab_type              com_api_type_pkg.t_mcc;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_pre_auth              aut_api_type_pkg.t_auth_rec;
    l_fin_rec               vis_api_type_pkg.t_visa_fin_mes_rec;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_visa_dialect          com_api_type_pkg.t_dict_value;
    l_tag_id                com_api_type_pkg.t_short_id;
    l_msg_proc_bin          com_api_type_pkg.t_auth_code;
    l_parent_network_id     com_api_type_pkg.t_tiny_id;
    l_is_binary             com_api_type_pkg.t_boolean;
    l_sub_add_data          com_api_type_pkg.t_mcc;
    l_ucaf                  com_api_type_pkg.t_mcc;

    l_sender_reference_number  com_api_type_pkg.t_terminal_number;
    l_sender_account_number    com_api_type_pkg.t_original_data;
    l_sender_address           com_api_type_pkg.t_name;
    l_sender_city              com_api_type_pkg.t_name;
    l_sender_country           com_api_type_pkg.t_country_code;
    l_dispute_inst_id          com_api_type_pkg.t_inst_id;
    l_current_standard_version com_api_type_pkg.t_tiny_id;
    --l_current_date             date := com_api_sttl_day_pkg.get_sysdate;

    function get_acquirer_bin (
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
                   and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT, vis_api_const_pkg.VISA_DIALECT_TIETO)
              )
             order by iso_msg_type
        ) loop
            return r.acq_inst_bin;
        end loop;
        return null;
    end;

    function get_validation_code (
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
    end;

    function get_ecommerce_indicator (
        i_auth_id        in      com_api_type_pkg.t_long_id
      , i_visa_dialect   in      com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_byte_char is
    begin
        for r in (
            select ecommerce_indicator
              from (
                select v.ecommerce_indicator
                     , v.iso_msg_type
                  from aup_visa_basei v
                 where v.auth_id = i_auth_id
                   and i_visa_dialect in (vis_api_const_pkg.VISA_DIALECT_DEFAULT, vis_api_const_pkg.VISA_DIALECT_TIETO)
            )
             order by iso_msg_type
        ) loop
            return r.ecommerce_indicator;
        end loop;
        return null;
    end;

    function get_srv_indicator (
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
    end;

    function get_resp_code (
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
    end;

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
    end;

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
    end;

    procedure set_way_additional_data(
        i_auth_rec       in aut_api_type_pkg.t_auth_rec
      , i_fin_rec        in vis_api_type_pkg.t_visa_fin_mes_rec)
      is
    l_way_add_data way_additional_data%rowtype;
    l_terminal_rec       acq_terminal%rowtype;
--    l_emv_data     com_api_type_pkg.t_param_value;
    l_emv_tab            com_api_type_pkg.t_tag_value_tab;
    l_add_auth_info      aut_auth%rowtype;
    l_reverse_amount    com_api_type_pkg.t_money;
    l_dispute_amount    com_api_type_pkg.t_money;
    l_is_partrial       com_api_type_pkg.t_boolean;

    procedure generate_dev_tag(
        i_add_auth_data in aut_auth%rowtype
      , i_terminal_data in acq_terminal%rowtype
      , o_dev_tag       out nocopy way_additional_data.dev_tag%type
        )
      is
    begin
        o_dev_tag := '10'||
        -- card data input capability
        case i_terminal_data.card_data_input_cap
            when 'F2210001' then '0001'
            when 'F2210002' then '0002'
            when 'F2210005' then '0010'
            when 'F2210006' then '0020'
            when 'F221000A' then '0002'
            when 'F221000B' then '0022'
            when 'F221000C' then '0032'
            when 'F221000D' then '0012'
            when 'F221000M' then '00F2'
            else '0000'
        end ||
        -- cardholder authentication capability
        case i_add_auth_data.crdh_auth_cap
            when 'F2220000' then '0001'     -- NO
            when 'F2220001' then '0008'     -- PIN
            when 'F2220002' then '0002'     -- Electronic signature analysis capability
            else '0000'                     -- Unknown
        end ||
        -- terminal type
        case i_terminal_data.terminal_type
            when 'TRMT0001' then 'N'        -- Imprinter
            when 'TRMT0002' then 'G'        -- ATM
            when 'TRMT0003' then 'H'        -- POS
            when 'TRMT0004' then '6'        -- ePOS
            when 'TRMT0005' then '2'        -- Mobile
            when 'TRMT0007' then '9'        -- Mobile POS
            when 'TRMT0009' then '7'        -- Transponder
            else '0'                        -- Unknown terminal type
        end ||
        -- card capture capability
        case i_add_auth_data.card_capture_cap
            when 'F2230001' then '1'        -- Card capture capability
            when 'F2230000' then 'N'        -- No capture capability
            else '0'                        -- Unknown; data unavailable
        end ||
        -- attendance indicator
        case i_add_auth_data.terminal_operating_env
            when 'F2240000' then 'N'        -- No terminal used
            when 'F2240001' then '1'        -- On card acceptor premises; attended terminal
            when 'F2240003' then '1'        -- Off card acceptor premises; attended
            when 'F2240002' then '2'        -- On card acceptor premises; unattended terminal
            when 'F2240004' then '2'        -- Off card acceptor premises; unattended
            when 'F2240005' then '2'        -- On cardholder premises; unattended
            when 'F2240006' then '2'        -- Off cardholder premises; unattended
            when 'F224000B' then '2'        -- Unattended cardholder terminal on card acceptor premises
            when 'F224000A' then '1'        -- Attended cardholder terminal on card acceptor premises
            else '0'                        -- Unknown; data unavailable
        end ||
        -- location indicator
        case i_add_auth_data.terminal_operating_env
            when 'F2240000' then 'N'        -- No terminal used
            when 'F2240001' then '1'        -- On card acceptor premises; attended terminal
            when 'F2240003' then '2'        -- Off card acceptor premises; attended
            when 'F2240002' then '1'        -- On card acceptor premises; unattended terminal
            when 'F2240004' then '2'        -- Off card acceptor premises; unattended
            when 'F2240005' then '3'        -- On cardholder premises; unattended
            when 'F2240006' then '4'        -- Off cardholder premises; unattended
            when 'F224000B' then '1'        -- Unattended cardholder terminal on card acceptor premises
            when 'F224000A' then '1'        -- Attended cardholder terminal on card acceptor premises
            else '0'                        -- Unknown; data unavailable
        end ||
        -- card data output capability
        case i_add_auth_data.card_data_output_cap
            when 'F22A0001' then 'N'         -- None
            when 'F22A0002' then '2'         -- Magnetic stripe write
            when 'F22A0003' then '3'         -- ICC
            else '0'                         -- Unknown; data unavailable
        end ||
        -- terminal output capability
        case i_add_auth_data.terminal_output_cap
            when 'F22B0001' then 'N'         -- None
            when 'F22B0002' then '2'         -- Printing capability only
            when 'F22B0003' then '3'         -- Display capability only
            when 'F22B0004' then '4'         -- Printing and display capability
            else '0'                         -- Unknown; data unavailable
        end ||
        -- PIN capture capability
        case i_add_auth_data.pin_capture_cap
            when 'F22C0000' then 'N'         -- No PIN capture capability
            when 'F22C0004' then '4'         -- PIN capture capability 4 characters maximum
            when 'F22C0005' then '5'         -- PIN capture capability 5 characters maximum
            when 'F22C0006' then '6'         -- PIN capture capability 6 characters maximum
            when 'F22C0007' then '7'         -- PIN capture capability 7 characters maximum
            when 'F22C0008' then '8'         -- PIN capture capability 8 characters maximum
            when 'F22C0009' then '9'         -- PIN capture capability 9 characters maximum
            when 'F22C000A' then 'A'         -- PIN capture capability 10 characters maximum
            when 'F22C000B' then 'B'         -- PIN capture capability 11 characters maximum
            when 'F22C000C' then 'C'         -- PIN capture capability 12 characters maximum
            else '0'                         -- Unknown; data unavailable
        end;

    end generate_dev_tag;

    function get_msgcode(
        i_trans_code  com_api_type_pkg.t_byte_char
      , i_oper_type   com_api_type_pkg.t_dict_value
      , i_is_partrial com_api_type_pkg.t_boolean
      , i_mcc         com_api_type_pkg.t_mcc
        ) return com_api_type_pkg.t_md5
      is
    --l_is_reversal     com_api_type_pkg.t_boolean;
    --l_is_dispute      com_api_type_pkg.t_boolean;
    l_group_id        com_api_type_pkg.t_byte_id;
    l_msg_code        com_api_type_pkg.t_md5;
    begin
        /*case
          when i_trans_code in ('25', '26', '27', '35', '36', '37') then
              l_is_reversal := com_api_const_pkg.TRUE;
          when i_trans_code in ('15', '16', '17', '35', '36', '37') then
              l_is_dispute  := com_api_const_pkg.TRUE;
          else
              l_is_reversal := com_api_type_pkg.FALSE;
              l_is_dispute  := com_api_type_pkg.FALSE;
        end case;*/

        -- load WAY mcc group into cache
        if g_way_mcc_group_references.count = 0 then
            g_way_mcc_group_references := com_api_array_pkg.get_elements(
                                              i_array_id           => way_api_const_pkg.WAY4_MCC_GROUP_REFERENCE
                                            , i_pattern            => '(;(\w|\d)+)'
                                            , i_replacement_string => ''
                                            , i_start_position     => 1
                                            , i_occurrence         => 1
                                              );
        end if;

        -- load WAY message codes
        if g_way_message_codes.count = 0 then
            g_way_message_codes := com_api_array_pkg.get_elements(
                                              i_array_id           => way_api_const_pkg.WAY4_MESSAGE_CODES
                                            , i_pattern            => '((\d|\w|-)+;)'
                                            , i_replacement_string => ''
                                            , i_start_position     => 1
                                            , i_occurrence         => 1
                                              );
        end if;

        -- define group_id
        l_group_id := regexp_substr(g_way_mcc_group_references(i_mcc).element_value, '[^;]+$', 1, 1);

        l_msg_code := i_oper_type   || ';' ||
                      i_trans_code  || ';' ||
                      i_is_partrial || ';' ||
                      l_group_id    || ';' ||
                      '1';

        -- define msg_code
        l_msg_code := regexp_substr(g_way_message_codes(l_msg_code).element_value,'^(\d|\w|-)+' ,1 , 1);

        return l_msg_code;

    end get_msgcode;

    function define_trans_conditions(
        i_add_auth_info in aut_auth%rowtype
      , i_terminal_rec  in acq_terminal%rowtype
--    , i_pin_captcode in auth_log_tab.pin_captcode%type default null (do not loaded)
--    , i_oper_type     in com_api_type_pkg.t_dict_value
      ) return com_api_type_pkg.t_full_desc
      is
      l_input_environment    com_api_type_pkg.t_name;
      l_device_capabiliy     com_api_type_pkg.t_name;
      l_transfer_environment com_api_type_pkg.t_name;
      l_environment_security com_api_type_pkg.t_name;
      l_authentication       com_api_type_pkg.t_name;
      l_is_online            com_api_type_pkg.t_name;
      l_parties              com_api_type_pkg.t_name;
      l_card_type            com_api_type_pkg.t_name;
      l_recived_data         com_api_type_pkg.t_name;
    begin
        -- input environment
        case i_terminal_rec.terminal_type
            when 'TRMT0003' then l_input_environment := 'POS,';       -- POS
            when 'TRMT0001' then l_input_environment := 'IMPRINTER,'; -- Imprinter
            when 'TRMT0002' then l_input_environment := 'ATM,';       -- ATM
            when 'TRMT0007' then l_input_environment := 'MPOS,';      -- Mobile POS
            else null;
        end case;

        case i_terminal_rec.cat_level
            when 'F22D0001' then l_input_environment := l_input_environment || 'TERM,CAT1,'; -- Purchase of goods by card in automated dispensing machine
            when 'F22D0002' then l_input_environment := l_input_environment || 'TERM,CAT2,'; -- Self-service terminal
            when 'F22D0003' then l_input_environment := l_input_environment || 'TERM,CAT3,'; -- Terminal with payment amount restriction
            when 'F22D0004' then l_input_environment := l_input_environment || 'CAT4,';      -- Purchasing of good in flight
            when 'F22D0007' then l_input_environment := l_input_environment || 'CAT7,';      -- Transponder transaction
            else null;
        end case;

        case i_add_auth_info.terminal_operating_env
            when 'F2240000' then l_input_environment := l_input_environment || 'NO_TERM,';   -- No terminal used
            when 'F2240002' then l_input_environment := l_input_environment || 'TERM_UNATT,'; -- On card acceptor premises; unattended terminal
            when 'F2240004' then l_input_environment := l_input_environment || 'TERM_UNATT,'; -- Off card acceptor premises; unattended
            when 'F2240005' then l_input_environment := l_input_environment || 'TERM_UNATT,'; -- On cardholder premises; unattended
            when 'F2240006' then l_input_environment := l_input_environment || 'TERM_UNATT,'; -- Off cardholder premises; unattended
            when 'F224000B' then l_input_environment := l_input_environment || 'TERM_UNATT,'; -- Unattended cardholder terminal on card acceptor premises
            else null;
        end case;

        -- Device Capability
        case i_terminal_rec.card_data_input_cap
            when 'F2210002' then l_device_capabiliy := 'TERM_TRACK,';                          -- Magnetic stripe reader capability
            when 'F2210003' then l_device_capabiliy := 'TERM_BAR,';                            -- Barcode reader
            when 'F2210004' then l_device_capabiliy := 'TERM_OCR,';                            -- Optical character reader (OCR) capability
            when 'F2210005' then l_device_capabiliy := 'TERM_CHIP,';                           -- Integrated circuit card (ICC) capability
            when 'F2210006' then l_device_capabiliy := 'TERM_KEY_ENTRY,';                      -- Key entry-only capability
            when 'F221000A' then l_device_capabiliy := 'TERM_TRACK_CTLS,';                     -- PAN auto-entry via contactless magnetic stripe
            when 'F221000M' then l_device_capabiliy := 'TERM_CHIP_CTLS,';                      -- PAN auto-entry via contactless M/Chip
            when 'F221000B' then l_device_capabiliy := 'TERM_TRACK,TERM_KEY_ENTRY,';           -- Magnetic stripe reader and key entry capability
            when 'F221000C' then l_device_capabiliy := 'TERM_TRACK,TERM_CHIP,TERM_KEY_ENTRY,'; -- Magnetic stripe reader, ICC, and key entry capability
            when 'F221000D' then l_device_capabiliy := 'TERM_TRACK,TERM_CHIP,';                -- Magnetic stripe reader and ICC capability
            when 'F221000E' then l_device_capabiliy := 'TERM_CHIP,TERM_KEY_ENTRY,';            -- ICC and key entry capability
            else null;
        end case;

        -- Transfer Environment
        case i_add_auth_info.crdh_presence
            when 'F2250002' then l_transfer_environment := 'MAIL,';  -- Cardholder not present (mail/facsimile transaction)
            when 'F2250003' then l_transfer_environment := 'PHONE,'; -- Cardholder not present (phone order or from automated response unit [ARU])
            when 'F2250005' then l_transfer_environment := 'ENET,';  -- Cardholder not present (electronic order [PC, Internet, mobile phone or PDA])
            else null;
        end case;

        -- Environment Security
        case i_add_auth_info.card_data_input_mode
            when 'F2270007' then l_environment_security := 'SECURE_CODE,LINE_SECURE,'; -- Electronic commerce, channel encryption
            when 'F2270008' then l_environment_security := 'SECURE_CODE,LINE_SECURE,'; -- Master Pass channel encrypted
            when 'F227000D' then l_environment_security := 'SECURE_CODE,LINE_SECURE,'; -- Master Digital Secure Remote Payment
            else null;
        end case;

        -- Authentication
        case i_add_auth_info.crdh_auth_entity
            when 'F2290000' then l_authentication := case 
                                                         when i_add_auth_info.crdh_auth_method = 'F2280000' then 'NO_AUTH,'
                                                         else null    -- Not authenticated
                                                     end;
            when 'F2290002' then l_authentication := 'AUTH_CAD,';   -- (CAD)    Card acceptance device (CAD)
            when 'F2290003' then l_authentication := 'AUTH_AGENT,'; -- Authorizing agent - online PIN
            when 'F2290004' then l_authentication := 'AUTH_MERCH,'; -- Merchant/card acceptor - signature
            else l_authentication := 'AUTHENTICATED,';
        end case;

        case
            when i_add_auth_info.crdh_auth_method = 'F2280002' then l_authentication := l_authentication || 'SBT,SBT_ELV,';             -- Electronic signature analysis
            when i_add_auth_info.crdh_auth_method = 'F2280005' then l_authentication := l_authentication || 'SBT,SBT_MAN,';             -- Manual signature verification
            when i_add_auth_info.crdh_auth_method = 'F2280001'
                and i_add_auth_info.crdh_auth_entity = 'F2290003' then l_authentication := l_authentication || 'PBT,PBT_ONLINE,';       -- PIN Authorizing agent - online PIN
            when i_add_auth_info.crdh_auth_method = 'F2280001'
                and i_add_auth_info.crdh_auth_entity = 'F2290001' then l_authentication := l_authentication || 'PBT,PBT_OFFLINE,';      -- PIN offline PIN
            when i_add_auth_info.card_data_input_mode in ('F2270005', 'F2270007', 'F2270008') and l_fin_rec.trans_code in ('05', '25') then l_authentication := l_authentication || 'CVC2,'; -- Electronic commerce, channel encryption/Master Pass channel encrypted
            else null;
        end case;

        -- on/off line
        case i_add_auth_info.crdh_auth_entity
            when 'F2290003' then l_is_online := 'ONLINE,';  -- Authorizing agent - online PIN
            when 'F2290001' then l_is_online := 'OFFLINE,'; -- ICC - offline PIN
            else null;
        end case;

        -- parties
        case i_add_auth_info.card_presence
            when 'F2260000' then l_parties := 'CARD,';    -- Card present
            when 'F2260001' then l_parties := 'NO_CARD,'; -- Card not present
            else null;
        end case;

        case i_add_auth_info.crdh_presence
            when 'F2250000' then l_parties := l_parties || 'CARDHOLDER,'; -- Cardholder present
            else l_parties := l_parties || 'NO_CARDHOLDER,'; --     Cardholder not present
        end case;

        case
            when i_add_auth_info.terminal_operating_env = 'F2240000' then
                l_parties := l_parties || 'NO_MERCH,';
            when i_add_auth_info.terminal_operating_env not in ('F2240000', 'F2240009', 'F2240007') then
        l_parties := l_parties || 'MERCH,';
            else null;
        end case;

        -- Card type/Recived data
        case i_add_auth_info.card_data_input_mode
            when 'F2270001' then l_recived_data := 'KEY_ENTRY,';             -- Manual input; no terminal
            when 'F2270002' then l_recived_data := 'CARD_TRACK,DATA_TRACK,READ_TRACK,'; -- Magnetic stripe reader input
            when 'F2270006' then l_recived_data := 'KEY_ENTRY,';             -- Key entered input
            when 'F227000B' then l_recived_data := 'CARD_TRACK,DATA_TRACK,READ_TRACK,'; -- Magnetic stripe reader input; track data captured and passed unaltered
            when 'F227000A' then l_recived_data := 'CARD_TRACK,DATA_TRACK,READ_TRACK,'; -- PAN auto-entry via contactless magnetic stripe
            when 'F227000C' then l_recived_data := 'CARD_CHIP,READ_CHIP,DATA_CHIP,';    -- Online chip
            else null;
        end case;

        return ',' || l_input_environment    ||
                      l_device_capabiliy     ||
                      l_transfer_environment ||
                      l_environment_security ||
                      l_authentication       ||
                      l_is_online            ||
                      l_parties              ||
                      l_card_type            ||
                      l_recived_data;
    end define_trans_conditions;


    begin

        l_way_add_data.oper_id := i_fin_rec.id;

        if i_fin_rec.mcc in (6532, 6533) then
            l_way_add_data.ptid := PROGRAM_REG_ID_C01;
        elsif i_fin_rec.mcc  in (6538, 6536, 6537) then
            l_way_add_data.ptid := PROGRAM_REG_ID_C07;
        else
            l_way_add_data.ptid := PROGRAM_REG_ID_C07;
        end if;

        l_way_add_data.trans_location := i_fin_rec.merchant_name||' '||i_fin_rec.merchant_street||' '||i_fin_rec.merchant_city;
        l_way_add_data.postal_code    := i_fin_rec.merchant_postal_code;
        l_way_add_data.src            := i_auth_rec.service_code;

        if i_auth_rec.oper_surcharge_amount > 0 then
            l_way_add_data.surcharge_curr := case i_fin_rec.oper_currency
                                                 when '810' then
                                                     '643'
                                                 else
                                                     i_fin_rec.oper_currency
                                             end;
            l_way_add_data.surcharge_amount := i_auth_rec.oper_surcharge_amount;
        end if;

        l_way_add_data.mbr_reconc_ind := i_fin_rec.id;
        l_way_add_data.cpna           := substr(replace(nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  8707),
                                                            aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  13))
                                                           , ',',' '),1, 25);                                                                                                 -- DF8042
        l_way_add_data.cpad           := substr(nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  30), 'building 1, microdistrict Cher'), 1, 30); 
        l_way_add_data.cpcy           := substr(nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  31), 'Moscow'), 1, 25);                         
        l_way_add_data.cpcn           := substr(nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  33), 'RUS'), 1, 3);                             
        l_way_add_data.cppc           := substr(nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  34), '117648'), 1, 10);                         
        l_way_add_data.cpst           := substr(' ', 1, 3);
        l_way_add_data.utrn           := i_auth_rec.external_auth_id;
        l_way_add_data.cpdb           := to_char(to_date(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  118), 'YYYYMMDD'), 'MMDDYYYY');             
        l_way_add_data.rpna           := replace(substr(nvl(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  15), 'UNKNOWN UNKNOWN'), 1, 75), ',', ' ');
        l_way_add_data.rpph           := substr(aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id  =>  8741), 1, 20);                                        -- DF876D

        if i_auth_rec.terminal_id is not null then
            begin
                select
                    *
                  into l_terminal_rec
                  from
                  acq_terminal at
                where
                  at.id = i_auth_rec.terminal_id;
            exception
                when no_data_found then
                    null;
            end;
        end if;
           /*Select (Select m.Network_Inst
                   From fe_network_map m
                   Where m.network = '45'
                   And m.fe_net_name = 'OPEN_WAY'
                   And Rownum = 1)
           Into l_OW_Inst_ID
           From dual;*/
            -- get emv data
        select
            a.*
          into l_add_auth_info
          from
          aut_auth a
        where
          a.id = i_auth_rec.id;

        if l_add_auth_info.emv_data is not null then
            -- parse emv data
            emv_api_tag_pkg.parse_emv_data(
                i_emv_data    => l_add_auth_info.emv_data
              , o_emv_tag_tab => l_emv_tab
              , i_is_binary   => com_api_const_pkg.TRUE
              , i_mask_error  => com_api_const_pkg.TRUE);
            begin
                l_way_add_data.emv_5f2a := l_emv_tab('5F2A');
                l_way_add_data.emv_9f02 := l_emv_tab('9F02');
                l_way_add_data.emv_9f1a := l_emv_tab('9F1A');
                l_way_add_data.emv_9a   := l_emv_tab('9A');
                l_way_add_data.emv_84   := l_emv_tab('9F06');
            exception
                when others then
                    null;
            end;
        end if;

        l_way_add_data.trn         := i_auth_rec.network_refnum;
        l_way_add_data.postal_code := l_fin_rec.merchant_postal_code;

        generate_dev_tag(
            i_add_auth_data => l_add_auth_info
          , i_terminal_data => l_terminal_rec
          , o_dev_tag       => l_way_add_data.dev_tag
            );

        l_way_add_data.cps := rpad(i_fin_rec.auth_resp_code, 2, ' ')   ||
                              rpad(i_fin_rec.auth_source_code, 1, ' ') ||
                              rpad(i_fin_rec.auth_char_ind, 1, ' ')    ||
                              ' '                                      ||
                              rpad(i_auth_rec.network_refnum, 15, ' ') ||
                              ' '                                      ||
                              rpad(' ', 4, ' ')                        ||
                              ' '                                      ||
                              rpad(i_fin_rec.oper_currency, 3, ' ')    ||
                              lpad(i_fin_rec.oper_amount, 12, '0')     ||
                              ' '                                      ||
                              lpad('0', 12, '0');

        -- define original oper params if this reversal
        if i_fin_rec.is_reversal = 1 then
            for orig_oper in (select
                                  vfo.id
                                , vfo.oper_amount
                                , vfo.oper_date

                                from
                                vis_fin_message vfm,
                                opr_operation rev,
                                opr_operation orig,
                                vis_fin_message vfo
                              where
                                vfm.id = i_fin_rec.id
                                and vfm.trans_code in (
                                                      '25' -- Reversal,Sales Draft
                                                    , '26' -- Reversal,Credit Voucher
                                                    , '27' -- Reversal,Cash Disbursment
                                                    , '35' -- Chargeback Reversal,Sales Draft
                                                    , '36' -- Chargeback Reversal,Credit Voucher
                                                    , '37' -- Chargeback Reversal,Cash Disbursment
                                                      )
                                and vfm.is_reversal = 1
                                and rev.id = vfm.id
                                and orig.id = rev.original_id
                                and vfo.id = orig.id
                                and vfm.dispute_id is null) loop

                l_reverse_amount               := orig_oper.oper_amount;
                l_way_add_data.orig_drn        := orig_oper.id;
                l_way_add_data.prev_drn          := orig_oper.id;
                l_way_add_data.orig_trans_date := orig_oper.oper_date;
            end loop;
        end if;

        -- define original oper params if this dispute
        if i_fin_rec.dispute_id is not null then
            for disput in (select
                               vfo.oper_amount
                             from
                             vis_fin_message vfm,
                             opr_operation opr,
                             opr_operation orig,
                             vis_fin_message vfo
                           where
                             vfm.dispute_id = i_fin_rec.dispute_id
                             and vfm.usage_code = 1
                             and opr.id = vfm.id
                             and opr.original_id is not null
                             and orig.id = opr.original_id
                             and orig.dispute_id = opr.dispute_id
                             and orig.original_id is null
                             and vfo.id = orig.id) loop

                l_dispute_amount := disput.oper_amount;
            end loop;
        end if;

        if i_fin_rec.oper_amount = coalesce(l_reverse_amount
                                          , l_dispute_amount
                                          , i_fin_rec.oper_amount
                                            ) then
            l_is_partrial := com_api_const_pkg.FALSE;
        else
            l_is_partrial := com_api_const_pkg.TRUE;
        end if;

        l_way_add_data.msg_code := get_msgcode(
                                       i_fin_rec.trans_code
                                     , i_auth_rec.oper_type
                                     , l_is_partrial
                                     , i_fin_rec.mcc
                                       );

        if l_way_add_data.msg_code is null then
            trc_log_pkg.error(
                i_text       => 'Message code is not defined for the transaction [#1]. Fill array WAY message codes [#2] with correct data.'
              , i_env_param1 => i_fin_rec.id
              , i_env_param2 => way_api_const_pkg.WAY4_MESSAGE_CODES
            );
        end if;

        -- get trans_condition
        l_way_add_data.trans_condition := define_trans_conditions(
                                              i_add_auth_info => l_add_auth_info
                                            , i_terminal_rec  => l_terminal_rec
                                              );

        -- deleting rows during re-processing
        --delete from way_additional_data where oper_id = i_fin_rec.id;

        insert into way_additional_data values l_way_add_data;

    end set_way_additional_data;

begin
    if io_fin_mess_id is null then
        io_fin_mess_id := opr_api_create_pkg.get_id;
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
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);

    trc_log_pkg.debug (
        i_text        => 'process_auth: inst_id[#1] network_id[#2] host_id[#3] standard_id[#4]'
      , i_env_param1  => l_dispute_inst_id
      , i_env_param2  => l_fin_rec.network_id
      , i_env_param3  => l_host_id
      , i_env_param4  => l_standard_id
    );

    rul_api_shared_data_pkg.load_oper_params(
        i_oper_id  => i_auth_rec.id
      , io_params  => l_param_tab
    );

    cmn_api_standard_pkg.get_param_value(
        i_inst_id       => l_dispute_inst_id
      , i_standard_id   => l_standard_id
      , i_object_id     => l_host_id
      , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name    => way_api_const_pkg.WAY4_DIALECT
      , i_param_tab     => l_param_tab
      , o_param_value   => l_visa_dialect
    );

    -- get VISA Retail CPS Participation Flag
/*    l_cps_retail_flag :=
        cmn_api_standard_pkg.get_number_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'VISA_RETAIL_CPS_PARTICIPATION_FLAG'
          , i_param_tab     => l_param_tab
        );*/

    -- get VISA ATM CPS Participation Flag
/*    l_cps_atm_flag :=
        cmn_api_standard_pkg.get_number_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => 'VISA_ATM_CPS_PARTICIPATION_FLAG'
          , i_param_tab     => l_param_tab
        );*/

    -- get VISA Acquirer Business ID
/*    l_fin_rec.acq_business_id :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => vis_api_const_pkg.ACQ_BUSINESS_ID
          , i_param_tab     => l_param_tab
        );
*/
    trc_log_pkg.debug('process_auth: cps_retail_flag='||l_cps_retail_flag||', cps_atm_flag='||l_cps_atm_flag||', acq_business_id='||l_fin_rec.acq_business_id);

/*    if l_fin_rec.acq_business_id is null then
        com_api_error_pkg.raise_error (
            i_error        => 'VISA_ACQ_BUSINESS_ID_NOT_FOUND'
          , i_env_param1   => l_dispute_inst_id
          , i_env_param2   => l_standard_id
          , i_env_param3   => l_host_id
        );
    end if;*/

    -- get VISA Acquirer Processing BIN
    l_fin_rec.proc_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => way_api_const_pkg.WAY4_CMID
          , i_param_tab     => l_param_tab
        );

    trc_log_pkg.debug('process_auth: proc_bin='||l_fin_rec.proc_bin);

    if l_fin_rec.proc_bin is null then
        com_api_error_pkg.raise_error (
            i_error       => 'WAY4_CMID_NOT_DEFINED'
          , i_env_param1  => l_dispute_inst_id
          , i_env_param2  => l_standard_id
          , i_env_param3  => l_host_id
        );
    end if;

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
    l_fin_rec.rrn            := i_auth_rec.originator_refnum;

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
        case
            when i_auth_rec.is_reversal = com_api_type_pkg.TRUE
            then '0'
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT)
            then '1'
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
            then '2'
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PAYMENT)
                 and i_auth_rec.mcc   in (vis_api_const_pkg.MCC_WIRE_TRANSFER_MONEY
                                        , vis_api_const_pkg.MCC_FIN_INSTITUTIONS
                                        , vis_api_const_pkg.MCC_BETTING_CASINO_GAMBLING)
            then '2'
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE)
                 and l_fin_rec.business_application_id in ('WT', 'LO')
            then '1'
            else '0'
        end;

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
    l_fin_rec.oper_amount      := i_auth_rec.oper_amount;
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

    -- check proc_bin NSPK
   /* l_parent_network_id :=
        cmn_api_standard_pkg.get_number_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => vis_api_const_pkg.VISA_PARENT_NETWORK
          , i_param_tab     => l_param_tab
        );
*/
    trc_log_pkg.debug (
        i_text        => 'process_auth: l_parent_network_id[#1]'
      , i_env_param1  => l_parent_network_id
    );

    if l_parent_network_id is not null then
        l_msg_proc_bin := get_msg_proc_bin(i_parent_network_id  => l_parent_network_id);
    else
        l_msg_proc_bin := l_fin_rec.proc_bin;
    end if;

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        begin
            select arn
              into l_fin_rec.arn
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
        l_fin_rec.arn :=
            acq_api_merchant_pkg.get_arn(
                i_acquirer_bin => l_msg_proc_bin
              , i_proc_date    => i_auth_rec.oper_date
            );
    end if;

    trc_log_pkg.debug (
        i_text        => 'process_auth: l_fin_rec.arn[#1]'
      , i_env_param1  => l_fin_rec.arn
    );

    l_fin_rec.merchant_name        := substrb(i_auth_rec.merchant_name, 1, 25);
    l_fin_rec.merchant_city        := substrb(i_auth_rec.merchant_city, 1, 13);
    l_fin_rec.merchant_country     := i_auth_rec.merchant_country;
    l_fin_rec.merchant_postal_code := i_auth_rec.merchant_postcode;
    if i_auth_rec.merchant_country in ('840', '124') then
        l_fin_rec.merchant_region := i_auth_rec.merchant_region;
    end if;
    l_fin_rec.merchant_street := i_auth_rec.merchant_street;
    l_fin_rec.mcc             := i_auth_rec.mcc;

    l_fin_rec.req_pay_service := null;
/*        case when i_auth_rec.mcc = '6011' and l_cps_atm_flag = com_api_type_pkg.TRUE then '9'
             when i_auth_rec.mcc not in ('6010', '6011') and l_cps_retail_flag = com_api_type_pkg.TRUE then 'A'
             else null
        end;*/
    l_fin_rec.auth_char_ind := get_srv_indicator (
        i_auth_id       => i_auth_rec.id
      , i_visa_dialect  => l_visa_dialect
    );

    if nvl(l_fin_rec.auth_char_ind, '0') = '0' then
        l_fin_rec.auth_char_ind := 'N';
/*        case when i_auth_rec.mcc = '6011' and l_cps_atm_flag = com_api_type_pkg.TRUE then 'E'
             when i_auth_rec.mcc not in ('6010', '6011') and l_cps_retail_flag = com_api_type_pkg.TRUE then 'A'
             else 'N'
        end;*/
    end if;

    l_fin_rec.usage_code       := '1';
    l_fin_rec.reason_code      := '00';
    l_fin_rec.settlement_flag  := '9';
    l_fin_rec.auth_code        := i_auth_rec.auth_code;

    if l_current_standard_version >= vis_api_const_pkg.STANDARD_VERSION_ID_17Q4 then
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
    else
        l_fin_rec.pos_terminal_cap :=
            case i_auth_rec.card_data_input_mode
                when  'F2270000' then '0'                                  -- Unknown; data not available.
                else
                    case i_auth_rec.card_data_input_cap
                        when 'F2210001' then '1'                           -- Manual; no terminal.
                        when 'F2210002' then '2'                           -- Magnetic stripe reader capability.
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
    end if;

    l_fin_rec.inter_fee_ind  := null;

    l_fin_rec.crdh_id_method :=
        case
            when i_auth_rec.card_data_input_mode in ('F2270006', 'F2270005', 'F2270007', 'F2270009', 'F227000S') then '4'  -- Mail/Telephone or  Electronic Commerce
            when i_auth_rec.crdh_auth_method in ('F2280001')             then '2'    -- PIN
            when i_auth_rec.crdh_auth_method in ('F2280002', 'F2280005') then '1'    -- Signature
            when i_auth_rec.cat_level        in ('F22D0003')             then '3'    -- Unattended terminal; no PIN pad
            else null                                                                -- Not specified
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
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS      and i_auth_rec.mcc  = '6010' then '0'
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM       and i_auth_rec.mcc != '6011'
              or i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS       and i_auth_rec.mcc != '6010'
              or i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS                                   then 'B'
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM       and i_auth_rec.mcc  = '6011' then '2'
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS       and i_auth_rec.mcc  = '6010' then '0'
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and i_auth_rec.mcc  = '6010' then '6'
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and i_auth_rec.mcc != '6010' and i_auth_rec.crdh_auth_method = 'F2280001' then '8'
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
        case
            when i_auth_rec.merchant_country in (com_api_const_pkg.COUNTRY_NEW_ZEALAND, com_api_const_pkg.COUNTRY_AUSTRALIA)
             and i_auth_rec.merchant_country = i_auth_rec.card_country
             and i_auth_rec.mcc in ('6012', '6051')
             and i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE
             and l_current_standard_version >= vis_api_const_pkg.STANDARD_VERSION_ID_17Q4
             then
                '9'
            when l_cab_type = 'U' then
                '8'
            else
                null
        end;

    l_fin_rec.fee_program_ind := null;
    l_fin_rec.issuer_charge := null;
    l_fin_rec.merchant_number := i_auth_rec.merchant_number;
    l_fin_rec.terminal_number := substr(i_auth_rec.terminal_number, 1, 8);
    l_fin_rec.national_reimb_fee := 0;

    l_pre_auth.certificate_method     := nvl(l_pre_auth.certificate_method, i_auth_rec.certificate_method);
    l_pre_auth.certificate_type       := nvl(l_pre_auth.certificate_type, i_auth_rec.certificate_type);
    l_pre_auth.ucaf_indicator         := nvl(l_pre_auth.ucaf_indicator, i_auth_rec.ucaf_indicator);

    l_fin_rec.electr_comm_ind := get_ecommerce_indicator (
        i_auth_id       => i_auth_rec.id
      , i_visa_dialect  => l_visa_dialect
    );

    if nvl(l_fin_rec.electr_comm_ind, '0') = '0' then
        if i_auth_rec.pos_cond_code = '08' then
            l_fin_rec.electr_comm_ind := '1';
        elsif i_auth_rec.crdh_presence = 'F2250004'
          and com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.merchant_country) = vis_api_const_pkg.VISA_REGION_USA then
            -- recurring payments indicator for USA
            l_fin_rec.electr_comm_ind := '2';
        elsif i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS then
            l_fin_rec.electr_comm_ind :=
                case
                    when substr(l_pre_auth.certificate_method, -1) = '1' and
                         substr(l_pre_auth.certificate_type, -1) = '1'
                    then '9'
                    when substr(l_pre_auth.certificate_method, -1) = '1' and
                         substr(l_pre_auth.certificate_type, -1) = '2'
                    then '5'
                    when substr(l_pre_auth.certificate_method, -1) = '1' then
                        case substr(l_pre_auth.ucaf_indicator, -1)
                            when '0' then '7'
                            when '1' then '6'
                            when '2' then '5'
                        end
                    when substr(l_pre_auth.certificate_method, -1) = '3' and
                         substr(l_pre_auth.certificate_type, -1) = '1'
                    then '6'
                    when substr(l_pre_auth.certificate_method, -1) = '3' and
                         substr(l_pre_auth.certificate_type, -1) = '2'
                    then '5'
                    when substr(l_pre_auth.certificate_method, -1) = '9'
                    then '8'
                end;

            if l_fin_rec.electr_comm_ind is null then

                l_sub_add_data  := substr(i_auth_rec.addl_data, 1, 2);
                l_ucaf          := substr(i_auth_rec.addl_data, 203, 1);

                if l_sub_add_data = '11' then
                    l_fin_rec.electr_comm_ind := '9';

                elsif l_sub_add_data = '12' then
                    l_fin_rec.electr_comm_ind := '5';

                elsif l_sub_add_data in ('21', '22') then
                    if l_ucaf = '0' then
                        l_fin_rec.electr_comm_ind := '7';
                    elsif l_ucaf = '1' then
                        l_fin_rec.electr_comm_ind := '6';
                    elsif l_ucaf = '2' then
                        l_fin_rec.electr_comm_ind := '5';
                    end if;

                elsif l_sub_add_data = '31' then
                    l_fin_rec.electr_comm_ind := '6';

                elsif l_sub_add_data = '32' then
                    l_fin_rec.electr_comm_ind := '5';

                elsif l_sub_add_data = '90' then
                    l_fin_rec.electr_comm_ind := '8';

                elsif l_sub_add_data = '01' then
                    if l_ucaf = '1' then
                       l_fin_rec.electr_comm_ind := '6';
                    elsif l_ucaf = '2' then
                       l_fin_rec.electr_comm_ind := '5';
                    elsif l_ucaf = '3' then
                       l_fin_rec.electr_comm_ind := '9';
                    else
                       l_fin_rec.electr_comm_ind := '7';
                    end if;

                elsif l_sub_add_data = '02' then
                    l_fin_rec.electr_comm_ind := '8';

                elsif l_sub_add_data = '03' then
                    l_fin_rec.electr_comm_ind := '9';
                end if;
            end if;
        elsif i_auth_rec.mcc in (5960, 5962, 5964, 5965, 5966, 5967, 5968, 5969) then
            l_fin_rec.electr_comm_ind := '1';
        end if;
    end if;

    trc_log_pkg.debug (
        i_text        => 'process_auth: i_auth_rec.terminal_type[#1], l_sub_add_data[#2], l_ucaf[#3], l_fin_rec.electr_comm_ind[#4]'
      , i_env_param1  => i_auth_rec.terminal_type
      , i_env_param2  => l_sub_add_data
      , i_env_param3  => l_ucaf
      , i_env_param4  => l_fin_rec.electr_comm_ind
    );

    if l_fin_rec.crdh_id_method = '4' then
        if com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.merchant_country) = vis_api_const_pkg.VISA_REGION_EUROPE
           and com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.card_country) = vis_api_const_pkg.VISA_REGION_EUROPE
        then
            l_fin_rec.reimburst_attr := '5';
        else
            l_fin_rec.reimburst_attr := '0';
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
        l_fin_rec.auth_source_code   := '5';
    end if;

    l_fin_rec.spec_chargeback_ind    := null;
    l_fin_rec.interface_trace_num    := null;
    l_fin_rec.unatt_accept_term_ind  := case
                                            when i_auth_rec.terminal_operating_env in ('F2240002','F2240004','F2240005')
                                            then
                                                case
                                                    when i_auth_rec.crdh_auth_method = 'F2280001'
                                                    then '2'
                                                    else '3'
                                                end
                                            else ''
                                        end;

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
                                            then case
                                                 when l_current_standard_version >= vis_api_const_pkg.STANDARD_VERSION_ID_17Q4
                                                 then nvl(aup_api_tag_pkg.get_tag_value(
                                                              i_auth_id   => i_auth_rec.id
                                                            , i_tag_id    => aup_api_tag_pkg.find_tag_by_reference('DF8A09'))
                                                          , ' '
                                                          )
                                                 else '6'  -- for offline transactions - offline approval
                                                 end
                                            else '5'
                                        end;
    end if;

    l_fin_rec.purch_id_format        := '0';

    if i_auth_rec.mcc = '6011' then
        l_fin_rec.account_selection  := case i_auth_rec.account_type
                                            when 'ACCT0010' then '1'
                                            when 'ACCT0020' then '2'
                                            when 'ACCT0030' then '3'
                                            else '0'
                                        end;
    else
        l_fin_rec.account_selection  := ' ';
    end if;

    l_fin_rec.installment_pay_count  := null;
    l_fin_rec.purch_id               := null;
    l_fin_rec.cashback               := null;

    if i_auth_rec.card_data_input_mode in ('F2270002', 'F227000B')     -- read card via magstripe
       and substr(i_auth_rec.card_service_code, 1, 1) in ('2','6')     -- chip card
       and i_auth_rec.card_data_input_cap in ('F2210005', 'F221000C', 'F221000D', 'F221000E', 'F221000M')  -- chip-capable terminal
    then
        l_fin_rec.chip_cond_code := '1';
    else
        l_fin_rec.chip_cond_code := '0';
    end if;

    l_fin_rec.validation_code := get_validation_code (
        i_auth_id       => i_auth_rec.id
      , i_visa_dialect  => l_visa_dialect
    );
    if l_fin_rec.validation_code is null then
        l_fin_rec.validation_code := get_validation_code (
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
        l_fin_rec.terminal_country     := emv_api_tag_pkg.get_tag_value('9F1A', l_emv_tag_tab, com_api_const_pkg.TRUE);
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
        case substr(i_auth_rec.cvv2_result, -1)
            when '1' then 'M'
            when '2' then 'N'
            when '3' then 'P'
            when '4' then 'S'
            when '5' then 'U'
            else null
        end;

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
    if  l_fin_rec.trans_code in (vis_api_const_pkg.TC_VOUCHER
                               , vis_api_const_pkg.TC_SALES)
    then
        l_fin_rec.business_format_code_3  := vis_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER;
        l_fin_rec.orig_city_airport_code := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_ORIG_CITY_AIR
        );
        l_fin_rec.carrier_code_1 := aup_api_tag_pkg.get_tag_value(
            i_auth_id => i_auth_rec.id
          , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE1
        );
        if l_fin_rec.orig_city_airport_code is not null
            and l_fin_rec.carrier_code_1 is not null
        then
            l_fin_rec.trans_comp_number_tcr3       := '3';
            l_fin_rec.business_application_id_tcr3 := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_BUSINESS_APPLICATION_ID
            );
            l_fin_rec.passenger_name               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_PASSENGER_NAME
            );
            l_fin_rec.departure_date               := to_date(
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => i_auth_rec.id
                  , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEPARTURE_DATE
                )
              , 'MMDDYY'
            );
            l_fin_rec.service_class_code_1         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS1
            );
            l_fin_rec.stop_over_code_1             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE1
            );
            l_fin_rec.dest_city_airport_code_1     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR1
            );
            l_fin_rec.carrier_code_2               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE2
            );
            l_fin_rec.service_class_code_2         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS2
            );
            l_fin_rec.stop_over_code_2             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE2
            );
            l_fin_rec.dest_city_airport_code_2     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR2
            );
            l_fin_rec.carrier_code_3               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE3
            );
            l_fin_rec.service_class_code_3         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS3
            );
            l_fin_rec.stop_over_code_3             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE3
            );
            l_fin_rec.dest_city_airport_code_3     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR3
            );
            l_fin_rec.carrier_code_4               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE4
            );
            l_fin_rec.service_class_code_4         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS4
            );
            l_fin_rec.stop_over_code_4             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE4
            );
            l_fin_rec.dest_city_airport_code_4     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR4
            );
            l_fin_rec.travel_agency_code           := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_TRAV_AGEN_CODE
            );
            l_fin_rec.travel_agency_name           := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_TRAV_AGEN_NAME
            );
            l_fin_rec.restrict_ticket_indicator    := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_R_TICKET_INDIC
            );
            l_fin_rec.fare_basis_code_1            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE1
            );
            l_fin_rec.fare_basis_code_2            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE2
            );
            l_fin_rec.fare_basis_code_3            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE3
            );
            l_fin_rec.fare_basis_code_4            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE4
            );
            l_fin_rec.comp_reserv_system           := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_COMP_RESRV_SYS
            );
            l_fin_rec.flight_number_1              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER1
            );
            l_fin_rec.flight_number_2              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER2
            );
            l_fin_rec.flight_number_3              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER3
            );
            l_fin_rec.flight_number_4              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER4
            );
            l_fin_rec.credit_reason_indicator      := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_CRD_RSN_INDIC
            );
            l_fin_rec.ticket_change_indicator      := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => vis_api_const_pkg.TAG_PASS_ITINER_TIC_CHN_INDIC
            );
        else
            if l_fin_rec.trans_code = vis_api_const_pkg.TC_VOUCHER
               and l_fin_rec.trans_code_qualifier = '2'
               and i_auth_rec.mcc in (vis_api_const_pkg.MCC_WIRE_TRANSFER_MONEY
                                    , vis_api_const_pkg.MCC_FIN_INSTITUTIONS
                                    , vis_api_const_pkg.MCC_BETTING_CASINO_GAMBLING)
               or
               l_fin_rec.trans_code = vis_api_const_pkg.TC_SALES
               and l_fin_rec.trans_code_qualifier = '1'
               and l_fin_rec.business_application_id in ('WT','LO')
            then
                l_fin_rec.orig_city_airport_code  := null;
                l_fin_rec.carrier_code_1          := null;

                l_fin_rec.fast_funds_indicator    := null;
                l_fin_rec.business_format_code_3  := vis_api_const_pkg.INDUSTRY_SPEC_DATA_CREDIT_FUND;

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A32');
                l_fin_rec.source_of_funds         := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

                l_fin_rec.payment_reversal_code   := null;

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8608');  -- SENDER_ACCOUNT
                l_fin_rec.sender_account_number   := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
                if l_fin_rec.sender_account_number is null then
                    l_fin_rec.sender_reference_number := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);
                end if;
                -- l_tag_id := aup_api_tag_pkg.find_tag_by_reference('ACQ_ORIG_REFNUM');
                -- l_fin_rec.sender_reference_number := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('CUSTOMER_NAME');  -- SENDER_NAME
                l_fin_rec.sender_name             := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('SENDER_STREET');
                l_fin_rec.sender_address          := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('SENDER_CITY');
                l_fin_rec.sender_city             := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

                l_fin_rec.sender_state            := null;

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('SENDER_COUNTRY');
                l_fin_rec.sender_country          := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
            else
                l_fin_rec.business_format_code_3  := null;
                l_fin_rec.business_application_id := null;
            end if;
        end if;
    else
        l_fin_rec.business_application_id := null;
    end if;

    if  l_fin_rec.trans_code in (vis_api_const_pkg.TC_CASH
                               , vis_api_const_pkg.TC_CASH_CHARGEBACK
                               , vis_api_const_pkg.TC_CASH_REVERSAL
                               , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV)
    then
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DCC_INDICATOR');
        l_fin_rec.dcc_indicator           := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
    end if;

    l_fin_rec.id := put_message(i_fin_rec => l_fin_rec);

    -- set specific WAY info
    set_way_additional_data(
        i_auth_rec       => i_auth_rec
      , i_fin_rec        => l_fin_rec
    );
end process_auth;

/*
procedure create_operation (
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
                                            , vis_api_const_pkg.TC_FRAUD_ADVICE)
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
                        i_network_oper_type => i_fin_rec.trans_code || i_fin_rec.trans_code_qualifier || i_fin_rec.mcc
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
        );
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
        csm_api_check_pkg.perform_check (
            i_oper_id             => l_oper.id
            , i_card_id           => l_iss_part.card_id
            , i_card_number       => l_iss_part.card_number
            , i_customer_id       => l_iss_part.customer_id
            , i_account_number    => l_iss_part.account_number
            , i_inst_id           => l_card_inst_id
            , i_msg_type          => l_oper.msg_type
            , i_oper_type         => l_oper.oper_type
            , i_sttl_type         => l_oper.sttl_type
            , i_is_reversal       => l_oper.is_reversal
            , i_dispute_id        => l_oper.dispute_id
            , i_de_024            => null
            , i_reason_code       => i_fee_rec.reason_code
            , i_original_id       => l_oper.original_id
            , i_de004             => i_fin_rec.dispute_amount
            , i_de049             => i_fin_rec.dispute_currency
        );
    end if;
end create_operation;
*/
function put_message (
    i_fin_rec               in vis_api_type_pkg.t_visa_fin_mes_rec
) return com_api_type_pkg.t_long_id is
    l_id                    com_api_type_pkg.t_long_id;
begin
    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);

    insert into vis_fin_message (
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
    );

    insert into vis_card (
        id
      , card_number
    ) values (
        l_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    if i_fin_rec.usage_code = '9' then
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
          , 'DF'
          , null
          , ' '
          , i_fin_rec.message_reason_code
          , i_fin_rec.dispute_condition
          , i_fin_rec.vrol_financial_id
          , i_fin_rec.vrol_case_number
          , i_fin_rec.vrol_bundle_number
          , i_fin_rec.client_case_number
          , i_fin_rec.dispute_status
          , null
          , null
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
          , 'SD'
          , null
          , ' '
          , null
          , null
          , null
          , null
          , null
          , null
          , null
          , null
          , null
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
end;
/*
procedure put_retrieval (
    i_retrieval_rec         in vis_api_type_pkg.t_retrieval_rec
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    l_id := nvl(i_retrieval_rec.id, opr_api_create_pkg.get_id);

    insert into vis_retrieval (
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
end;

procedure put_fee (
    i_fee_rec               in vis_api_type_pkg.t_fee_rec
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    l_id := nvl(i_fee_rec.id, opr_api_create_pkg.get_id);

    insert into vis_fee (
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
end;

procedure put_fraud (
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
    );

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] VISA fraud messages'
        , i_env_param1  => l_id
    );
end;

function is_collection_allow (
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
end;


 -- Function parses incoming value card_data_input_mode and returns POS entry mode.
*/
function get_pos_entry_mode(
    i_card_data_input_mode  in com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.t_pos_entry_mode
is
begin
    return
        case
            -- Magnetic stripe read and exact content of Track 1 or Track 2 included (CVV check is possible)
            when i_card_data_input_mode = 'F227000B'   then '90'
            -- Integrated circuit card read; CVV or iCVV data reliable
            when i_card_data_input_mode in ('F227000C', 'F227000F') then '05'
            -- Manual key entry
            when i_card_data_input_mode in ('F2270006', 'F227000S', 'F2270005', 'F2270007', 'F2270009') then '01'
            -- Proximity Payment using VSDC chip data rules
            when i_card_data_input_mode = 'F227000M'   then '07'
            -- Proximity payment using magnetic stripe data rules
            when i_card_data_input_mode = 'F227000A'   then '91'
            -- Magnetic stripe read; CVV checking may not be possible
            when i_card_data_input_mode = 'F2270002'   then '02'
            -- Credential on file
            when i_card_data_input_mode = 'F227000E'   then '10'
            -- Barcode read
            when i_card_data_input_mode = 'F2270003'   then '03'
                                                       else null
        end;
end;
/*
function is_visa (
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

    return l_result;
end;

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
end;
*/
end way_api_fin_message_pkg;
/
