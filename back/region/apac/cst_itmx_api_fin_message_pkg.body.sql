create or replace package body cst_itmx_api_fin_message_pkg as
/*********************************************************
 *  API for ITMX financial message <br />
 *  Created by Zakharov M.(m.zakharov@bpcbt.com)  at 17.12.2018 <br />
 *  Module: CST_ITMX_API_FIN_MESSAGE_PKG   <br />
 *  @headcom
 **********************************************************/
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
|| ', null agent_unique_id'
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
|| ', null message_reason_code'
|| ', null dispute_condition'
|| ', null vrol_financial_id'
|| ', null vrol_case_number'
|| ', null vrol_bundle_number'
|| ', null client_case_number'
|| ', null dispute_status'
|| ', null payment_acc_ref'
|| ', null token_requestor_id'
|| ', f.terminal_country'

|| ', null trans_comp_number_tcr3'
|| ', null business_application_id_tcr3'
|| ', null business_format_code_tcr3'
|| ', null passenger_name'
|| ', null departure_date'
|| ', null orig_city_airport_code'
|| ', null carrier_code_1'
|| ', null service_class_code_1'
|| ', null stop_over_code_1'
|| ', null dest_city_airport_code_1'
|| ', null carrier_code_2'
|| ', null service_class_code_2'
|| ', null stop_over_code_2'
|| ', null dest_city_airport_code_2'
|| ', null carrier_code_3'
|| ', null service_class_code_3'
|| ', null stop_over_code_3'
|| ', null dest_city_airport_code_3'
|| ', null carrier_code_4'
|| ', null service_class_code_4'
|| ', null stop_over_code_4'
|| ', null dest_city_airport_code_4'
|| ', null travel_agency_code'
|| ', null travel_agency_name'
|| ', null restrict_ticket_indicator'
|| ', null fare_basis_code_1'
|| ', null fare_basis_code_2'
|| ', null fare_basis_code_3'
|| ', null fare_basis_code_4'
|| ', null comp_reserv_system'
|| ', null flight_number_1'
|| ', null flight_number_2'
|| ', null flight_number_3'
|| ', null flight_number_4'
|| ', null credit_reason_indicator'
|| ', null ticket_change_indicator'
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

function get_ecommerce_indicator(
    i_auth_rec       in     aut_api_type_pkg.t_auth_rec
  , i_pre_auth       in     aut_api_type_pkg.t_auth_rec               default null
) return com_api_type_pkg.t_byte_char is
    l_electr_comm_ind       com_api_type_pkg.t_byte_char;
    l_sub_add_data          com_api_type_pkg.t_mcc;
    l_ucaf                  com_api_type_pkg.t_mcc;
begin

    l_electr_comm_ind := substr(
        trim(
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => 34405  -- aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR
            )
        )
      , -1
    );

    if l_electr_comm_ind is null then

        if i_auth_rec.pos_cond_code = '08' then
            l_electr_comm_ind := '1';
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
                        when substr(i_auth_rec.card_data_input_mode, -1)  = 'S'
                             and i_auth_rec.crdh_auth_method is null 
                        then '8'
                        when substr(i_auth_rec.card_data_input_mode, -1) in ('7', 'E', '1')
                             and substr(i_auth_rec.crdh_auth_method, -1)  = '0'
                        then '7'
                        when substr(i_auth_rec.card_data_input_mode, -1)  = '7'
                             and substr(i_auth_rec.crdh_auth_method, -1) in ('9', 'W', 'X')
                        then '6'
                        when substr(i_auth_rec.card_data_input_mode, -1) in ('7', 'E', '1')
                             and substr(i_auth_rec.crdh_auth_method, -1)  = 'S'
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

function estimate_fin_fraud_for_upload(
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) return number is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.estimate_fin_fraud_for_upload ';  

    l_result                number;
begin
    trc_log_pkg.info(
        i_text => LOG_PREFIX || '<< i_network_id [#1], i_inst_id [#2], i_host_inst_id [#3]'
        || ', i_start_date [#4], i_end_date [#5]'
        , i_env_param1 => i_network_id
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_host_inst_id
        , i_env_param4 => to_char(i_start_date, 'dd.mm.yyyy hh24:mi:ss') 
        , i_env_param5 => to_char(i_end_date, 'dd.mm.yyyy hh24:mi:ss')
    );


  select sum(cnt)
    into l_result
    from ( select /*+ INDEX(f, cst_itmx_fin_mess_CLMS0010_ndx)*/
                  count(f.id) cnt
             from cst_itmx_fin_message f
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
         );

    trc_log_pkg.info(
        i_text => LOG_PREFIX || '>> l_result [#1]'
        , i_env_param1 => l_result
    );
    return l_result;
end estimate_fin_fraud_for_upload;

procedure enum_fin_msg_fraud_for_upload(
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_start_date          in date
    , i_end_date            in date
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.enum_fin_msg_fraud_for_upload ';  

    DATE_PLACEHOLDER        constant com_api_type_pkg.t_name := '##DATE##';
    l_stmt                  com_api_type_pkg.t_sql_statement;
begin
    trc_log_pkg.info(
        i_text => LOG_PREFIX || '<< i_network_id [#1], i_inst_id [#2], i_host_inst_id [#3]'
        || ', i_start_date [#4], i_end_date [#5]'
        , i_env_param1 => i_network_id
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_host_inst_id
        , i_env_param4 => to_char(i_start_date, 'dd.mm.yyyy hh24:mi:ss') 
        , i_env_param5 => to_char(i_end_date, 'dd.mm.yyyy hh24:mi:ss')
    );

    l_stmt := '
select * from
(
    select /*+ INDEX(f, cst_itmx_fin_mess_CLMS0010_ndx)*/
        ' || G_COLUMN_LIST_FIN_FR || ', f.trans_code, ' ||
        'iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
          || G_COLUMN_LIST_FRAUD_NULL || '
    from
        cst_itmx_fin_message f
      , opr_card c
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
        and c.oper_id(+) = f.id ' || DATE_PLACEHOLDER || '
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
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id, i_start_date, i_end_date, i_start_date, i_end_date;
    else
        open o_fin_cur for l_stmt
        using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;
    end if;

    trc_log_pkg.info(
        i_text => LOG_PREFIX || '>>'
    );
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

function get_pos_entry_mode(
    i_card_data_input_mode  in com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.t_pos_entry_mode
is
begin
    return
        case
            -- Magnetic stripe read and exact content of Track 1 or Track 2 included (CVV check is possible)
            when substr(i_card_data_input_mode, -1) = 'B' then '90'
            -- Integrated circuit card read; CVV or iCVV data reliable
            when substr(i_card_data_input_mode, -1) in ('C', 'F') then '05'
            -- Manual key entry
            when substr(i_card_data_input_mode, -1) in ('6', 'S', '5', '7', '9') then '01'
            -- Proximity Payment using VSDC chip data rules
            when substr(i_card_data_input_mode, -1) = 'M' then '07'
            -- Proximity payment using magnetic stripe data rules
            when substr(i_card_data_input_mode, -1) = 'A' then '91'
            -- Magnetic stripe read; CVV checking may not be possible
            when substr(i_card_data_input_mode, -1) = '2' then '02'
            -- Credential on file
            when substr(i_card_data_input_mode, -1) = 'E' then '10'
            -- Barcode read
            when substr(i_card_data_input_mode, -1) = '3' then '03'
                                                          else null
        end;
end get_pos_entry_mode;

procedure process_auth(
    i_auth_rec        in      aut_api_type_pkg.t_auth_rec
  , i_inst_id         in      com_api_type_pkg.t_inst_id     default null
  , i_network_id      in      com_api_type_pkg.t_tiny_id     default null
  , i_collect_only    in      com_api_type_pkg.t_boolean     default null
  , i_status          in      com_api_type_pkg.t_dict_value  default null
  , io_fin_mess_id    in out  com_api_type_pkg.t_long_id
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_auth ';  

    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_host_id               com_api_type_pkg.t_tiny_id;

    l_tcc                   com_api_type_pkg.t_mcc;
    l_diners_code           com_api_type_pkg.t_mcc;
    l_cab_type              com_api_type_pkg.t_mcc;
    l_emv_tag_tab           com_api_type_pkg.t_tag_value_tab;
    l_pre_auth              aut_api_type_pkg.t_auth_rec;
    l_fin_rec               cst_itmx_api_type_pkg.t_itmx_fin_mes_rec;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_tag_id                com_api_type_pkg.t_short_id;
    l_msg_proc_bin          com_api_type_pkg.t_auth_code;
    l_parent_network_id     com_api_type_pkg.t_tiny_id;
    l_is_binary             com_api_type_pkg.t_boolean;
    l_param_value           com_api_type_pkg.t_param_value;

    l_sender_reference_number  com_api_type_pkg.t_terminal_number;
    l_sender_account_number    com_api_type_pkg.t_original_data;
    l_sender_address           com_api_type_pkg.t_name;
    l_sender_city              com_api_type_pkg.t_name;
    l_sender_country           com_api_type_pkg.t_country_code;
    l_dispute_inst_id          com_api_type_pkg.t_inst_id;

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
              , i_param_name    => cst_itmx_api_const_pkg.CMID
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

begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || '<< i_inst_id [#1], i_network_id [#2], i_collect_only [#3]'
        || ', i_status [#4], io_fin_mess_id [#5]'
        , i_env_param1 => i_inst_id
        , i_env_param2 => i_network_id
        , i_env_param3 => i_collect_only
        , i_env_param4 => i_status
        , i_env_param5 => io_fin_mess_id
    );

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

    l_dispute_inst_id     := l_fin_rec.inst_id;

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

    -- get ITMX Acquirer Business ID
    l_fin_rec.acq_business_id :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => cst_itmx_api_const_pkg.ACQ_BUSINESS_ID
          , i_param_tab     => l_param_tab
        );

    trc_log_pkg.debug('process_auth: acq_business_id='||l_fin_rec.acq_business_id);

    if l_fin_rec.acq_business_id is null then
        com_api_error_pkg.raise_error (
            i_error        => 'VISA_ACQ_BUSINESS_ID_NOT_FOUND'
          , i_env_param1   => l_dispute_inst_id
          , i_env_param2   => l_standard_id
          , i_env_param3   => l_host_id
        );
    end if;

    -- get ITMX Acquirer Processing BIN
    l_fin_rec.proc_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => cst_itmx_api_const_pkg.CMID
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

    l_fin_rec.dispute_id     := null;
    l_fin_rec.file_id        := null;
    l_fin_rec.batch_id       := null;
    l_fin_rec.record_number  := null;
    l_fin_rec.rrn            := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);

    -- converting reversal flag and operation type into ITMX transaction code
    l_fin_rec.trans_code :=
        case
            when i_auth_rec.is_reversal = com_api_type_pkg.FALSE then
                case
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                        then cst_itmx_api_const_pkg.TC_CASH
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_UNIQUE, opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT, opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
                        then cst_itmx_api_const_pkg.TC_SALES
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND, opr_api_const_pkg.OPERATION_TYPE_PAYMENT, opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT, opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                        then cst_itmx_api_const_pkg.TC_VOUCHER
                    else
                        null
                end
            when i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
                case
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                        then cst_itmx_api_const_pkg.TC_CASH_REVERSAL
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_UNIQUE, opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT, opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
                        then cst_itmx_api_const_pkg.TC_SALES_REVERSAL
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND, opr_api_const_pkg.OPERATION_TYPE_PAYMENT, opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT, opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                        then cst_itmx_api_const_pkg.TC_VOUCHER_REVERSAL
                    else
                        null
                end
            end;
    if l_fin_rec.trans_code is null then
        trc_log_pkg.error(
            i_text          => 'UNABLE_DETERMINE_ITMX_TRANSACTION_CODE'
          , i_env_param1    => l_fin_rec.id
        );
    end if;

    -- define original authorization for completion
    if  i_auth_rec.msg_type = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
        or l_fin_rec.trans_code = cst_itmx_api_const_pkg.TC_VOUCHER
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
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT)
            then '1'
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
            then '2'
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PAYMENT)
                 and i_auth_rec.mcc   in (cst_itmx_api_const_pkg.MCC_WIRE_TRANSFER_MONEY
                                        , cst_itmx_api_const_pkg.MCC_FIN_INSTITUTIONS
                                        , cst_itmx_api_const_pkg.MCC_BETTING_CASINO_GAMBLING)
            then '2'
            when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE)
                 and l_fin_rec.business_application_id in ('WT')
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
    l_fin_rec.network_code     := null;

    l_fin_rec.acquirer_bin     := i_auth_rec.acq_inst_bin;

    -- check proc_bin NSPK
    l_parent_network_id :=
        cmn_api_standard_pkg.get_number_value(
            i_inst_id       => l_dispute_inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => cst_itmx_api_const_pkg.ITMX_PARENT_NETWORK
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

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        begin
            select arn
                 , acq_business_id
                 , proc_bin
              into l_fin_rec.arn
                 , l_fin_rec.acq_business_id
                 , l_fin_rec.proc_bin
              from cst_itmx_fin_message
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
                i_prefix       => '2'
              , i_acquirer_bin => nvl(l_msg_proc_bin, l_fin_rec.proc_bin)
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
        l_fin_rec.merchant_region  := i_auth_rec.merchant_region;
    end if;
    l_fin_rec.merchant_street      := i_auth_rec.merchant_street;
    l_fin_rec.mcc                  := i_auth_rec.mcc;

    l_fin_rec.req_pay_service      := null;

    l_fin_rec.auth_char_ind        := 'N';

    l_fin_rec.usage_code           := '1';
    l_fin_rec.reason_code          := '00';
    l_fin_rec.settlement_flag      := '9';
    l_fin_rec.auth_code            := i_auth_rec.auth_code;
    
    l_fin_rec.pos_terminal_cap :=
        case substr(i_auth_rec.card_data_input_mode, -1)
            when  '0' then '0'                                  -- Unknown; data not available.
            else
                case substr(i_auth_rec.card_data_input_cap, -1)
                    when '1' then '1'                           -- Manual; no terminal.
                    when '2' then '2'                           -- Magnetic stripe reader capability.
                    when '3' then '3'                           -- Barcode read capability
                    when 'A' then '2'
                    when 'B' then '2'
                    when '5' then '5'                           -- Integrated circuit card (ICC) capability.
                    when 'C' then '5'
                    when 'D' then '5'
                    when 'E' then '5'
                    when '6' then '9'                           -- Key entry-only capability.
                    when 'M' then '5'                           -- PAN auto-entry via contactless M/Chip.
                    else null
                end
        end;

    l_fin_rec.inter_fee_ind  := null;
    l_fin_rec.crdh_id_method :=
        case
        when substr(i_auth_rec.card_data_input_mode, -1) in ('6', '5', '7', '9', 'S') 
             or (
                    substr(i_auth_rec.card_data_input_mode, -1) in ('E', '1')
                    and substr(i_auth_rec.crdh_auth_method, -1)  = 'S'
                )
        then '4'                                                                          -- Mail/Telephone or  Electronic Commerce
        when substr(i_auth_rec.crdh_auth_method, -1) in ('1') then '2'                    -- PIN
        when substr(i_auth_rec.crdh_auth_method, -1) in ('2', '5') then '1'               -- Signature
        when substr(i_auth_rec.cat_level, -1) in ('3') then '3'                           -- Unattended terminal; no PIN pad
        else null                                                                         -- Not specified
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
                 and substr(i_auth_rec.crdh_auth_method, -1) = '1'                                                   then '8'
            else '0'
        end;

    l_fin_rec.iss_workst_bin     := null;
    l_fin_rec.acq_workst_bin     := nvl(l_msg_proc_bin, l_fin_rec.proc_bin);
    l_fin_rec.chargeback_ref_num := '000000';
    l_fin_rec.docum_ind          := null;

    if    i_auth_rec.is_reversal = com_api_type_pkg.FALSE
      and (i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PAYMENT) and i_auth_rec.mcc in (cst_itmx_api_const_pkg.MCC_WIRE_TRANSFER_MONEY, cst_itmx_api_const_pkg.MCC_FIN_INSTITUTIONS)
        or i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT)
          )
    then
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(cst_itmx_api_const_pkg.TAG_REF_SENDER_ACCOUNT);
        l_sender_account_number := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
        if l_sender_account_number is null then
            l_sender_reference_number := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);
        end if;
        
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(cst_itmx_api_const_pkg.TAG_REF_SENDER_STREET);
        l_sender_address := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(cst_itmx_api_const_pkg.TAG_REF_SENDER_CITY);
        l_sender_city := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

        l_tag_id := aup_api_tag_pkg.find_tag_by_reference(cst_itmx_api_const_pkg.TAG_REF_SENDER_COUNTRY);
        l_sender_country := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
        
        l_fin_rec.member_msg_text :=
            nvl(l_sender_account_number, l_sender_reference_number) || ' '
         || l_sender_country  || ' '
         || l_sender_city  || ' '
         || l_sender_address;
    else
        l_fin_rec.member_msg_text := null;
    end if;

    l_fin_rec.spec_cond_ind := null;

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
      , i_pre_auth      => l_pre_auth
    );

    trc_log_pkg.debug(
        i_text        => 'process_auth: i_auth_rec.terminal_type[#1], l_fin_rec.electr_comm_ind[#2], i_auth_rec.card_data_input_mode[#3], i_auth_rec.crdh_auth_method[#4]'
      , i_env_param1  => i_auth_rec.terminal_type
      , i_env_param2  => l_fin_rec.electr_comm_ind
      , i_env_param3  => i_auth_rec.card_data_input_mode
      , i_env_param4  => i_auth_rec.crdh_auth_method
    );

    if l_fin_rec.crdh_id_method = '4' then
        if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE then
            l_fin_rec.reimburst_attr := '0';
        end if;
    elsif l_fin_rec.electr_comm_ind in ('5', '6') then
        l_fin_rec.reimburst_attr     := '5';
    elsif l_fin_rec.electr_comm_ind in ('1', '3', '4', '7') then
        if com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.merchant_country) = cst_itmx_api_const_pkg.ITMX_REGION_ASIA_PACIFIC
           and com_api_country_pkg.get_visa_region(i_country_code => i_auth_rec.card_country) = cst_itmx_api_const_pkg.ITMX_REGION_ASIA_PACIFIC
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
    l_fin_rec.unatt_accept_term_ind  := case
                                            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                                            then '3'
                                            when substr(i_auth_rec.terminal_operating_env, -1) in ('2','4','5')
                                            then
                                                case
                                                    when substr(i_auth_rec.crdh_auth_method, -1) = '1'
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
                                            then nvl(aup_api_tag_pkg.get_tag_value(
                                                     i_auth_id   => i_auth_rec.id
                                                   , i_tag_id    => aup_api_tag_pkg.find_tag_by_reference('DF8A09'))
                                                 , ' '
                                                 )
                                            else ' '
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
    l_fin_rec.cashback               := i_auth_rec.oper_cashback_amount;

    if substr(i_auth_rec.card_data_input_mode, -1) in ('2', 'B')                   -- read card via magstripe
       and substr(i_auth_rec.card_service_code, 1, 1) in ('2','6')                 -- chip card
       and substr(i_auth_rec.card_data_input_cap, -1) in ('5', 'C', 'D', 'E', 'M') -- chip-capable terminal
    then
        l_fin_rec.chip_cond_code := '1';
    else
        l_fin_rec.chip_cond_code := '0';
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
        update cst_itmx_fin_message
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
        end if;
    end if;
    if l_fin_rec.auth_resp_code is null then
        l_fin_rec.auth_resp_code := i_auth_rec.native_resp_code;
    end if;

    l_fin_rec.service_code := i_auth_rec.card_service_code;

    -- In case of USA electr_comm_ind is used for recurring payments
    if substr(i_auth_rec.crdh_presence, -1) = '4' then
        l_fin_rec.pos_environment := 'R';
    else
        l_fin_rec.pos_environment := ' ';
    end if;

    -- for TCR 3
    if  l_fin_rec.trans_code in (cst_itmx_api_const_pkg.TC_VOUCHER
                               , cst_itmx_api_const_pkg.TC_SALES
                               , cst_itmx_api_const_pkg.TC_VOUCHER_REVERSAL
                               , cst_itmx_api_const_pkg.TC_SALES_REVERSAL)
    then

        l_fin_rec.business_format_code_3 :=
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => l_fin_rec.id
              , i_tag_id  => aup_api_const_pkg.TAG_BUSINESS_FORMAT_CODE
            );
        
        if l_fin_rec.business_format_code_3 = cst_itmx_api_const_pkg.INDUSTRY_SPEC_DATA_PASS_ITINER then
            l_fin_rec.trans_comp_number_tcr3 := '3';
            l_fin_rec.orig_city_airport_code := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_ORIG_CITY_AIR
            );
            l_fin_rec.carrier_code_1 := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE1
            );
            l_fin_rec.business_application_id_tcr3 := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_BUSINESS_APPLICATION_ID
            );
            l_fin_rec.passenger_name               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_PASSENGER_NAME
            );
            l_fin_rec.departure_date               := to_date(
                aup_api_tag_pkg.get_tag_value(
                    i_auth_id => i_auth_rec.id
                  , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_DEPARTURE_DATE
                )
              , 'MMDDYY'
            );
            l_fin_rec.service_class_code_1         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS1
            );
            l_fin_rec.stop_over_code_1             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE1
            );
            l_fin_rec.dest_city_airport_code_1     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR1
            );
            l_fin_rec.carrier_code_2               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE2
            );
            l_fin_rec.service_class_code_2         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS2
            );
            l_fin_rec.stop_over_code_2             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE2
            );
            l_fin_rec.dest_city_airport_code_2     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR2
            );
            l_fin_rec.carrier_code_3               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE3
            );
            l_fin_rec.service_class_code_3         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS3
            );
            l_fin_rec.stop_over_code_3             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE3
            );
            l_fin_rec.dest_city_airport_code_3     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR3
            );
            l_fin_rec.carrier_code_4               := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_CARRIER_CODE4
            );
            l_fin_rec.service_class_code_4         := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_SERVICE_CLASS4
            );
            l_fin_rec.stop_over_code_4             := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_STOP_OVR_CODE4
            );
            l_fin_rec.dest_city_airport_code_4     := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_DEST_CITY_AIR4
            );
            l_fin_rec.travel_agency_code           := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_TRAV_AGEN_CODE
            );
            l_fin_rec.travel_agency_name           := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_TRAV_AGEN_NAME
            );
            l_fin_rec.restrict_ticket_indicator    := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_R_TICKET_INDIC
            );
            l_fin_rec.fare_basis_code_1            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE1
            );
            l_fin_rec.fare_basis_code_2            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE2
            );
            l_fin_rec.fare_basis_code_3            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE3
            );
            l_fin_rec.fare_basis_code_4            := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FARE_BAS_CODE4
            );
            l_fin_rec.comp_reserv_system           := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_COMP_RESRV_SYS
            );
            l_fin_rec.flight_number_1              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER1
            );
            l_fin_rec.flight_number_2              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER2
            );
            l_fin_rec.flight_number_3              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER3
            );
            l_fin_rec.flight_number_4              := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_FLIGHT_NUMBER4
            );
            l_fin_rec.credit_reason_indicator      := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_CRD_RSN_INDIC
            );
            l_fin_rec.ticket_change_indicator      := aup_api_tag_pkg.get_tag_value(
                i_auth_id => i_auth_rec.id
              , i_tag_id  => cst_itmx_api_const_pkg.TAG_PASS_ITINER_TIC_CHN_INDIC
            );
        else
            if l_fin_rec.trans_code in (cst_itmx_api_const_pkg.TC_VOUCHER, cst_itmx_api_const_pkg.TC_VOUCHER_REVERSAL)
               and l_fin_rec.trans_code_qualifier = '2'
               and i_auth_rec.mcc in (cst_itmx_api_const_pkg.MCC_WIRE_TRANSFER_MONEY
                                    , cst_itmx_api_const_pkg.MCC_FIN_INSTITUTIONS
                                    , cst_itmx_api_const_pkg.MCC_BETTING_CASINO_GAMBLING)
               or
               l_fin_rec.trans_code in (cst_itmx_api_const_pkg.TC_SALES, cst_itmx_api_const_pkg.TC_SALES_REVERSAL)
               and l_fin_rec.trans_code_qualifier = '1'
            then
                l_fin_rec.fast_funds_indicator    := null;
                l_fin_rec.business_format_code_3  := cst_itmx_api_const_pkg.INDUSTRY_SPEC_DATA_CREDIT_FUND;

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8A32');
                l_fin_rec.source_of_funds         := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);

                l_fin_rec.payment_reversal_code   := null;

                l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF8608');  -- SENDER_ACCOUNT
                l_fin_rec.sender_account_number   := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
                
                if l_fin_rec.business_application_id in ('AA', 'PP') and l_fin_rec.sender_account_number is null then
                    l_fin_rec.sender_reference_number := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);
                end if;

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

    if  l_fin_rec.trans_code in (cst_itmx_api_const_pkg.TC_CASH
                               , cst_itmx_api_const_pkg.TC_CASH_CHARGEBACK
                               , cst_itmx_api_const_pkg.TC_CASH_REVERSAL
                               , cst_itmx_api_const_pkg.TC_CASH_CHARGEBACK_REV)
    then
        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DCC_INDICATOR');
        l_fin_rec.dcc_indicator           := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
        if l_fin_rec.dcc_indicator = '0' then
            l_fin_rec.dcc_indicator       := ' ';
        end if;
    end if;

    l_fin_rec.id := put_message(i_fin_rec => l_fin_rec);
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || '>> io_fin_mess_id [#1]'
        , i_env_param1 => io_fin_mess_id
    );
    
end process_auth;

function put_message(
    i_fin_rec               in cst_itmx_api_type_pkg.t_itmx_fin_mes_rec
) return com_api_type_pkg.t_long_id is
    l_id                    com_api_type_pkg.t_long_id;
begin
    if i_fin_rec.id is not null then
        l_id := i_fin_rec.id;
    else
        l_id := opr_api_create_pkg.get_id;
    end if;    

    insert into cst_itmx_fin_message (
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

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] ITMX fin messages'
        , i_env_param1  => l_id
    );

    return l_id;
end put_message;

end cst_itmx_api_fin_message_pkg;
/
