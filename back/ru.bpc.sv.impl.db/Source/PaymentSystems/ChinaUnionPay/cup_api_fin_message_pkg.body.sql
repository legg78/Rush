create or replace package body cup_api_fin_message_pkg as

G_COLUMN_LIST     constant com_api_type_pkg.t_text :=
    'f.rowid'
||  ', f.id'
||  ', f.status'
||  ', f.is_reversal'
||  ', f.is_incoming'
||  ', f.is_rejected'
||  ', f.is_invalid'
||  ', f.inst_id'
||  ', f.network_id'
||  ', f.host_inst_id'
||  ', f.rrn'
||  ', f.merchant_number'
||  ', f.acquirer_iin'
||  ', f.trans_amount'
||  ', f.app_version_no'
||  ', f.appl_charact'
||  ', f.appl_crypt'
||  ', f.auth_amount'
||  ', f.auth_method'
||  ', f.auth_resp_code'
||  ', f.terminal_capab'
||  ', f.card_serial_num'
||  ', f.cipher_text_inf_data'
||  ', f.auth_currency'
||  ', f.terminal_country'
||  ', f.dedic_doc_name'
||  ', f.ic_card_cond_code'
||  ', f.interface_serial'
||  ', f.iss_bank_app_data'
||  ', f.local'
||  ', f.mcc'
||  ', f.merchant_name'
||  ', f.other_amount'
||  ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
||  ', f.point'
||  ', f.proc_func_code'
||  ', f.terminal_entry_capab'
||  ', f.terminal_verif_result'
||  ', f.script_result_of_card_issuer'
||  ', f.forwarding_iin'
||  ', f.pos_entry_mode'
||  ', f.sys_trace_num'
||  ', f.terminal_category'
||  ', f.terminal_number'
||  ', f.trans_currency'
||  ', f.trans_init_channel'
||  ', f.trans_category'
||  ', f.trans_counter'
||  ', f.trans_date'
||  ', f.trans_resp_code'
||  ', f.trans_serial_counter'
||  ', f.trans_code'
||  ', f.transmission_date_time'
||  ', f.unpred_num'
||  ', f.collect_only_flag'
||  ', f.original_id'
||  ', f.merchant_country'
||  ', f.pos_cond_code'
||  ', f.terminal_auth_date'
||  ', f.orig_trans_code'
||  ', f.orig_transmission_date_time'
||  ', f.orig_sys_trace_num'
||  ', f.orig_trans_date'
||  ', f.file_id'
||  ', f.reason_code'
||  ', f.double_message_id'
||  ', f.cups_ref_num'
||  ', f.receiving_iin'
||  ', f.issuer_iin'
||  ', f.cups_notice'
||  ', f.trans_features_id'
||  ', f.payment_service_type'
||  ', f.settlement_exch_rate'
||  ', f.cardholder_bill_amount'
||  ', f.cardholder_acc_currency'
||  ', f.cardholder_exch_rate'
||  ', f.service_fee_amount'
||  ', f.sttl_amount'
||  ', f.sttl_currency'
||  ', f.message_type'
||  ', f.receivable_fee'
||  ', f.payable_fee'
||  ', null as interchange_fee'
||  ', null as transaction_fee'
||  ', null as reserved'
||  ', f.dispute_id'
||  ', f.b2b_business_type'
||  ', f.b2b_payment_medium'
||  ', f.qrc_voucher_number'
||  ', f.payment_facilitator_id'
;

function put_message (
    i_fin_rec               in cup_api_type_pkg.t_cup_fin_mes_rec
) return com_api_type_pkg.t_long_id
is
    l_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text         => 'cup_api_fin_message_pkg.put_message start'
    );

    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);

    insert into cup_fin_message (
        id
      , status
      , is_reversal
      , is_incoming
      , is_rejected
      , is_invalid
      , inst_id
      , network_id
      , host_inst_id
      , collect_only_flag
      , rrn
      , merchant_number
      , acquirer_iin
      , trans_amount
      , app_version_no
      , appl_charact
      , appl_crypt
      , auth_amount
      , auth_method
      , auth_resp_code
      , terminal_capab
      , card_serial_num
      , cipher_text_inf_data
      , auth_currency
      , terminal_country
      , dedic_doc_name
      , ic_card_cond_code
      , interface_serial
      , iss_bank_app_data
      , local
      , mcc
      , merchant_name
      , other_amount
      , point
      , proc_func_code
      , terminal_entry_capab
      , terminal_verif_result
      , script_result_of_card_issuer
      , forwarding_iin
      , pos_entry_mode
      , sys_trace_num
      , terminal_category
      , terminal_number
      , trans_currency
      , trans_init_channel
      , trans_category
      , trans_counter
      , trans_date
      , trans_resp_code
      , trans_serial_counter
      , trans_code
      , transmission_date_time
      , unpred_num
      , original_id
      , merchant_country
      , pos_cond_code
      , terminal_auth_date
      , orig_trans_code
      , orig_transmission_date_time
      , orig_sys_trace_num
      , orig_trans_date
      , file_id
      , reason_code
      , double_message_id
      , cups_ref_num
      , receiving_iin
      , issuer_iin
      , cups_notice
      , trans_features_id
      , payment_service_type
      , settlement_exch_rate
      , cardholder_bill_amount
      , cardholder_acc_currency
      , cardholder_exch_rate
      , service_fee_amount
      , sttl_amount
      , sttl_currency
      , message_type
      , receivable_fee
      , payable_fee
      , dispute_id
      , b2b_business_type
      , b2b_payment_medium
      , qrc_voucher_number
      , payment_facilitator_id
    ) values (
        l_id
      , i_fin_rec.status
      , i_fin_rec.is_reversal
      , i_fin_rec.is_incoming
      , i_fin_rec.is_rejected
      , i_fin_rec.is_invalid
      , i_fin_rec.inst_id
      , i_fin_rec.network_id
      , i_fin_rec.host_inst_id
      , i_fin_rec.collect_only_flag
      , i_fin_rec.rrn
      , i_fin_rec.merchant_number
      , i_fin_rec.acquirer_iin
      , i_fin_rec.trans_amount
      , i_fin_rec.app_version_no
      , i_fin_rec.appl_charact
      , i_fin_rec.appl_crypt
      , i_fin_rec.auth_amount
      , i_fin_rec.auth_method
      , i_fin_rec.auth_resp_code
      , i_fin_rec.terminal_capab
      , i_fin_rec.card_serial_num
      , i_fin_rec.cipher_text_inf_data
      , i_fin_rec.auth_currency
      , i_fin_rec.terminal_country
      , i_fin_rec.dedic_doc_name
      , i_fin_rec.ic_card_cond_code
      , i_fin_rec.interface_serial
      , i_fin_rec.iss_bank_app_data
      , i_fin_rec.local
      , i_fin_rec.mcc
      , i_fin_rec.merchant_name
      , i_fin_rec.other_amount
      , i_fin_rec.point
      , i_fin_rec.proc_func_code
      , i_fin_rec.terminal_entry_capab
      , i_fin_rec.terminal_verif_result
      , i_fin_rec.script_result_of_card_issuer
      , i_fin_rec.forwarding_iin
      , i_fin_rec.pos_entry_mode
      , i_fin_rec.sys_trace_num
      , i_fin_rec.terminal_category
      , i_fin_rec.terminal_number
      , i_fin_rec.trans_currency
      , i_fin_rec.trans_init_channel
      , i_fin_rec.trans_category
      , i_fin_rec.trans_counter
      , i_fin_rec.trans_date
      , i_fin_rec.trans_resp_code
      , i_fin_rec.trans_serial_counter
      , i_fin_rec.trans_code
      , i_fin_rec.transmission_date_time
      , i_fin_rec.unpred_num
      , i_fin_rec.original_id
      , i_fin_rec.merchant_country
      , i_fin_rec.pos_cond_code
      , i_fin_rec.terminal_auth_date
      , i_fin_rec.orig_trans_code
      , i_fin_rec.orig_transmission_date_time
      , i_fin_rec.orig_sys_trace_num
      , i_fin_rec.orig_trans_date
      , i_fin_rec.file_id
      , i_fin_rec.reason_code
      , i_fin_rec.double_message_id
      , i_fin_rec.cups_ref_num
      , i_fin_rec.receiving_iin
      , i_fin_rec.issuer_iin
      , i_fin_rec.cups_notice
      , i_fin_rec.trans_features_id
      , i_fin_rec.payment_service_type
      , i_fin_rec.settlement_exch_rate
      , i_fin_rec.cardholder_bill_amount
      , i_fin_rec.cardholder_acc_currency
      , i_fin_rec.cardholder_exch_rate
      , i_fin_rec.service_fee_amount
      , i_fin_rec.sttl_amount
      , i_fin_rec.sttl_currency
      , i_fin_rec.message_type
      , i_fin_rec.receivable_fee
      , i_fin_rec.payable_fee
      , i_fin_rec.dispute_id
      , i_fin_rec.b2b_business_type
      , i_fin_rec.b2b_payment_medium
      , i_fin_rec.qrc_voucher_number
      , i_fin_rec.payment_facilitator_id
    );

    insert into cup_card (
        id
        , card_number
    ) values (
        l_id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] CUP fin messages'
        , i_env_param1  => l_id
    );

    return l_id;
end;

procedure create_operation (
    i_oper                  in opr_api_type_pkg.t_oper_rec
    , i_iss_part            in opr_api_type_pkg.t_oper_part_rec
    , i_acq_part            in opr_api_type_pkg.t_oper_part_rec
)is
    l_oper_id               com_api_type_pkg.t_long_id := i_oper.id;
begin
    trc_log_pkg.debug (
        i_text         => 'cup_api_fin_message_pkg.create_operation start'
    );

    opr_api_create_pkg.create_operation (
        io_oper_id             => l_oper_id
        , i_session_id         => get_session_id
        , i_status             => nvl(i_oper.status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
        , i_status_reason      => i_oper.status_reason
        , i_sttl_type          => i_oper.sttl_type
        , i_msg_type           => i_oper.msg_type
        , i_oper_type          => i_oper.oper_type
        , i_oper_reason        => i_oper.oper_reason
        , i_is_reversal        => i_oper.is_reversal
        , i_oper_amount        => i_oper.oper_amount
        , i_oper_currency      => i_oper.oper_currency
        , i_sttl_amount        => i_oper.sttl_amount
        , i_sttl_currency      => i_oper.sttl_currency
        , i_oper_date          => i_oper.oper_date
        , i_host_date          => i_oper.host_date
        , i_terminal_type      => i_oper.terminal_type
        , i_mcc                => i_oper.mcc
        , i_originator_refnum  => i_oper.originator_refnum
        , i_acq_inst_bin       => i_oper.acq_inst_bin
        , i_forw_inst_bin      => i_oper.forw_inst_bin
        , i_merchant_number    => i_oper.merchant_number
        , i_terminal_number    => i_oper.terminal_number
        , i_merchant_name      => i_oper.merchant_name
        , i_merchant_street    => i_oper.merchant_street
        , i_merchant_city      => i_oper.merchant_city
        , i_merchant_region    => i_oper.merchant_region
        , i_merchant_country   => i_oper.merchant_country
        , i_merchant_postcode  => i_oper.merchant_postcode
        , i_dispute_id         => i_oper.dispute_id
        , i_match_status       => i_oper.match_status
        , i_original_id        => i_oper.original_id
        , i_proc_mode          => i_oper.proc_mode
        , i_incom_sess_file_id => i_oper.incom_sess_file_id
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => i_oper.msg_type
        , i_oper_type         => i_oper.oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
        , i_host_date         => i_oper.host_date
        , i_inst_id           => i_iss_part.inst_id
        , i_network_id        => i_iss_part.network_id
        , i_customer_id       => i_iss_part.customer_id
        , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
        , i_client_id_value   => i_iss_part.card_number
        , i_card_id           => i_iss_part.card_id
        , i_card_type_id      => i_iss_part.card_type_id
        , i_card_expir_date   => i_iss_part.card_expir_date
        , i_card_seq_number   => i_iss_part.card_seq_number
        , i_card_number       => i_iss_part.card_number
        , i_card_mask         => i_iss_part.card_mask
        , i_card_hash         => i_iss_part.card_hash
        , i_card_country      => i_iss_part.card_country
        , i_card_inst_id      => i_iss_part.card_inst_id
        , i_card_network_id   => i_iss_part.card_network_id
        , i_account_id        => null
        , i_account_number    => null
        , i_account_amount    => null
        , i_account_currency  => null
        , i_auth_code         => i_iss_part.auth_code
        , i_split_hash        => i_iss_part.split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => i_oper.msg_type
        , i_oper_type         => i_oper.oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
        , i_host_date         => i_oper.host_date
        , i_inst_id           => i_acq_part.inst_id
        , i_network_id        => i_acq_part.network_id
        , i_merchant_id       => null
        , i_terminal_id       => null
        , i_terminal_number   => i_oper.terminal_number
        , i_split_hash        => null
        , i_without_checks    => com_api_const_pkg.TRUE
    );
    trc_log_pkg.debug (
        i_text         => 'cup_api_fin_message_pkg.create_operation end'
    );
end;

procedure get_fin (
    i_id                    in com_api_type_pkg.t_long_id
  , o_fin_rec              out cup_api_type_pkg.t_cup_fin_mes_rec
  , i_mask_error            in com_api_type_pkg.t_boolean         := com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || G_COLUMN_LIST || '
from
cup_fin_message f
, cup_card c
where
f.id = :i_id
and f.id = c.id(+)';
    open l_fin_cur for l_statemet using i_id;
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

procedure process_auth(
    i_auth_rec              in     aut_api_type_pkg.t_auth_rec
  , i_inst_id               in     com_api_type_pkg.t_inst_id default null
  , i_network_id            in     com_api_type_pkg.t_tiny_id default null
  , i_status                in     com_api_type_pkg.t_dict_value default null
  , io_fin_mess_id          in out com_api_type_pkg.t_long_id
) is
    l_fin_rec                      cup_api_type_pkg.t_cup_fin_mes_rec;
    l_host_id                      com_api_type_pkg.t_tiny_id;
    l_standard_id                  com_api_type_pkg.t_tiny_id;
    l_emv_tag_tab                  com_api_type_pkg.t_tag_value_tab;
    l_is_binary                    com_api_type_pkg.t_boolean;
begin
   trc_log_pkg.debug (
       i_text         => 'cup_api_fin_message_pkg.process_auth START'
   );

    if io_fin_mess_id is null then
        io_fin_mess_id := opr_api_create_pkg.get_id;
    end if;

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        -- find presentment and make reversal
        get_fin (
            i_id           => i_auth_rec.original_id
          , o_fin_rec      => l_fin_rec
        );

        update cup_fin_message
           set status = case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                                  and trans_amount   = i_auth_rec.oper_amount
                                  and trans_currency = i_auth_rec.oper_currency
                             then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                             else status
                        end
         where rowid = l_fin_rec.row_id
         returning case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_PENDING)
                          or i_auth_rec.oper_amount = 0
                        then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                        else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                   end
          into l_fin_rec.status;

        -- Save values of original operation
        l_fin_rec.orig_trans_code             := l_fin_rec.trans_code;
        l_fin_rec.orig_transmission_date_time := l_fin_rec.transmission_date_time;
        l_fin_rec.orig_sys_trace_num          := l_fin_rec.sys_trace_num;
        l_fin_rec.orig_trans_date             := l_fin_rec.orig_trans_date;

        -- Save changed values of reversal operation
        l_fin_rec.id             := io_fin_mess_id;
        l_fin_rec.file_id        := null;
        l_fin_rec.trans_code     := cup_api_const_pkg.TC_ONLINE_REFUND;

        l_fin_rec.is_reversal    := i_auth_rec.is_reversal;
        l_fin_rec.is_incoming    := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected    := com_api_type_pkg.FALSE;
        l_fin_rec.is_invalid     := com_api_type_pkg.FALSE;
        l_fin_rec.original_id    := i_auth_rec.original_id;
        l_fin_rec.rrn            := i_auth_rec.originator_refnum;
        l_fin_rec.trans_date     := to_char(i_auth_rec.host_date, 'mmdd');
        l_fin_rec.sys_trace_num  := i_auth_rec.system_trace_audit_number;
        l_fin_rec.trans_amount   := i_auth_rec.oper_amount;
        l_fin_rec.trans_currency := i_auth_rec.oper_currency;
        l_fin_rec.transmission_date_time := i_auth_rec.oper_date;

    else

        l_fin_rec.id           := io_fin_mess_id;
        l_fin_rec.status       := nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
        l_fin_rec.inst_id      := nvl(i_inst_id, i_auth_rec.acq_inst_id);
        l_fin_rec.network_id   := nvl(i_network_id, i_auth_rec.iss_network_id);
        l_fin_rec.host_inst_id := net_api_network_pkg.get_inst_id(l_fin_rec.network_id);

        l_fin_rec.is_reversal    := i_auth_rec.is_reversal;
        l_fin_rec.is_incoming    := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected    := com_api_type_pkg.FALSE;
        l_fin_rec.is_invalid     := com_api_type_pkg.FALSE;
        l_fin_rec.original_id    := i_auth_rec.original_id;
        l_fin_rec.rrn            := i_auth_rec.originator_refnum;
        l_fin_rec.trans_date     := to_char(i_auth_rec.host_date, 'mmdd');
        l_fin_rec.sys_trace_num  := i_auth_rec.system_trace_audit_number;
        l_fin_rec.trans_amount   := i_auth_rec.oper_amount;
        l_fin_rec.trans_currency := i_auth_rec.oper_currency;
        l_fin_rec.transmission_date_time := i_auth_rec.oper_date;

        -- get network communication standard
        l_host_id              := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
        l_standard_id          := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

        trc_log_pkg.debug (
            i_text          => 'process_auth: inst_id[#1] network_id[#2] host_id[#3] standard_id[#4]'
            , i_env_param1  => l_fin_rec.inst_id
            , i_env_param2  => l_fin_rec.network_id
            , i_env_param3  => l_host_id
            , i_env_param4  => l_standard_id
        );

        -- Converting operation type into CUP transaction code
        if i_auth_rec.oper_type in (
               opr_api_const_pkg.OPERATION_TYPE_ATM_CASH          -- ATM Cash withdrawal
             , opr_api_const_pkg.OPERATION_TYPE_POS_CASH          -- POS Cash advance
             , opr_api_const_pkg.OPERATION_TYPE_PURCHASE          -- Purchase
             , opr_api_const_pkg.OPERATION_TYPE_UNIQUE            -- Unique Transaction (Quasi Cash)
             , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT         -- P2P Debit
             , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT   -- Service provider payment
             , opr_api_const_pkg.OPERATION_TYPE_PAYMENT           -- Payment transaction
             , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT        -- P2P Credit
             , opr_api_const_pkg.OPERATION_TYPE_CASHIN            -- Cash-In
        )
        then
            l_fin_rec.trans_code := cup_api_const_pkg.TC_PRESENTMENT;
        elsif i_auth_rec.oper_type in (
               opr_api_const_pkg.OPERATION_TYPE_REFUND            -- Purchase return (Credit)
        )
        then
            l_fin_rec.trans_code := cup_api_const_pkg.TC_ONLINE_REFUND;
        else
            l_fin_rec.trans_code := net_api_map_pkg.get_network_type(
                                        i_oper_type    => i_auth_rec.oper_type
                                      , i_standard_id  => l_standard_id
                                      , i_mask_error   => com_api_type_pkg.FALSE
                                    );
        end if;

        if l_fin_rec.trans_code is null then
            trc_log_pkg.error(
                i_text          => 'UNABLE_DETERMINE_CUP_TRANSACTION_CODE'
              , i_env_param1    => l_fin_rec.id
            );
        end if;

        l_fin_rec.mcc               := i_auth_rec.mcc;
        l_fin_rec.merchant_name     := i_auth_rec.merchant_name;
        l_fin_rec.terminal_number   := 
            case when length(i_auth_rec.terminal_number) >= 8 
               then substr(i_auth_rec.terminal_number, -8) 
               else i_auth_rec.terminal_number
            end;
        l_fin_rec.merchant_country  := i_auth_rec.merchant_country;
        l_fin_rec.pos_cond_code     := i_auth_rec.pos_cond_code;

        -- Maps transaction init channel from dictionary code to integer value
        l_fin_rec.trans_init_channel := case i_auth_rec.terminal_type
                                            when 'TRMT0001' then 6
                                            when 'TRMT0002' then 1
                                            when 'TRMT0003' then 3
                                            when 'TRMT0004' then 5
                                            when 'TRMT0005' then 8
                                            when 'TRMT0006' then 7
                                            when 'TRMT0007' then 8
                                            else null
                                        end;

        l_fin_rec.trans_resp_code    := i_auth_rec.resp_code;
        l_fin_rec.merchant_number    := i_auth_rec.merchant_number;
        l_fin_rec.acquirer_iin       := i_auth_rec.acq_inst_id;
        l_fin_rec.card_serial_num    := i_auth_rec.card_seq_number;
        l_fin_rec.card_number        := i_auth_rec.card_number;
        l_fin_rec.auth_resp_code     := i_auth_rec.auth_code;
        l_fin_rec.point              := i_auth_rec.pos_entry_mode;
        l_fin_rec.pos_entry_mode     := i_auth_rec.pos_entry_mode;
        l_fin_rec.forwarding_iin     := i_auth_rec.iss_inst_id;

        if i_auth_rec.addl_data is not null then
            -- It was as follows:
            --  TagHolder addlData = new TagHolder(op.getAuthData().getAddlData());
            --  auth.setIcCardCondCode(addlData.getStringValue(0x14A));
            l_fin_rec.ic_card_cond_code := substr(i_auth_rec.addl_data, 330);
        end if;

        -- Helps to map read capacity of terminal from string to index in array
        l_fin_rec.terminal_entry_capab := case i_auth_rec.card_data_input_cap
                                              when 'F2210000' then 1    -- Unknown; data not available.
                                              when 'F2210001' then 2    -- no terminal used.
                                              when 'F2210003' then 3    -- bar code.
                                              when 'F2210004' then 4    -- OCR.
                                              when 'F221000D' then 5    -- magnetic stripe and chip reader
                                              when 'F2210006' then 6    -- key entry.
                                              when 'F221000B' then 7    -- magnetic stripe reader and key entry.
                                              when 'F221000C' then 8    -- magnetic stripe and chip reader and key entry
                                              when 'F2210005' then 9    -- chip reader.
                                              else null
                                          end;

        if i_auth_rec.emv_data is not null then
            l_is_binary := nvl(
                               set_ui_value_pkg.get_system_param_n(i_param_name => 'EMV_TAGS_IS_BINARY')
                             , com_api_type_pkg.FALSE
                           );
            trc_log_pkg.debug('process_auth: l_is_binary = ' || l_is_binary);

            emv_api_tag_pkg.parse_emv_data(
                i_emv_data          => i_auth_rec.emv_data
              , o_emv_tag_tab       => l_emv_tag_tab
              , i_is_binary         => l_is_binary
            );

            l_fin_rec.script_result_of_card_issuer := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F5B'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.app_version_no := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F09'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.appl_charact := emv_api_tag_pkg.get_tag_value(
                i_tag               => '82'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.appl_crypt   := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F26'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.auth_amount  := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F02'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.auth_method := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F34'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.terminal_capab := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F33'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.cipher_text_inf_data := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F27'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.auth_currency := emv_api_tag_pkg.get_tag_value(
                i_tag               => '5F2A'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.terminal_country := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F1A'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.dedic_doc_name := emv_api_tag_pkg.get_tag_value(
                i_tag               => '84'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.iss_bank_app_data := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F10'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.other_amount := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F03'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.terminal_verif_result := emv_api_tag_pkg.get_tag_value(
                i_tag               => '95'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.interface_serial := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F1E'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.terminal_category := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F35'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.trans_category := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9C'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.trans_counter := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F36'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.terminal_auth_date := to_date(emv_api_tag_pkg.get_tag_value(
                i_tag               => '9A'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            ), 'yymmdd');
            l_fin_rec.trans_serial_counter := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F41'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
            l_fin_rec.unpred_num := emv_api_tag_pkg.get_tag_value(
                i_tag               => '9F37'
              , i_emv_tag_tab       => l_emv_tag_tab
              , i_mask_error        => com_api_const_pkg.TRUE
            );
        end if;

        -- These fields is not filled in the "cup_fin_message" table:
        l_fin_rec.local                := null;
        l_fin_rec.proc_func_code       := null;
        l_fin_rec.collect_only_flag    := null;

        if  l_fin_rec.trans_category = '29' -- Primary credit
            and l_fin_rec.merchant_country != i_auth_rec.card_country -- operation is cross-border
        then
            l_fin_rec.b2b_business_type := '00';
            l_fin_rec.b2b_payment_medium := ' ';
        end if;

        if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND then
            l_fin_rec.qrc_voucher_number := i_auth_rec.network_refnum;
        end if;

        l_fin_rec.payment_facilitator_id := aup_api_tag_pkg.get_tag_value(
                                                i_auth_id => l_fin_rec.id
                                              , i_tag_id  => aup_api_const_pkg.TAG_PAYMENT_FACILITATOR_ID
                                            );
    end if;

    l_fin_rec.id := put_message (
                        i_fin_rec    => l_fin_rec
                    );

    trc_log_pkg.debug (
        i_text         => 'cup_api_fin_message_pkg.process_auth end'
    );
end process_auth;

function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
) return number is
    l_result                number;
begin
    trc_log_pkg.debug (
        i_text         => 'estimate_messages_for_upload start: i_network_id [#1] i_inst_id [#2] i_host_inst_id [#3]'
      , i_env_param1   => i_network_id
      , i_env_param2   => i_inst_id
      , i_env_param3   => i_host_inst_id
    );

    select count(f.id)
      into l_result
      from cup_fin_message f
         , cup_card c
     where decode(f.status, 'CLMS0010', 'CLMS0010' , null) = 'CLMS0010'  -- In functional index like 'decode' we use dictionary code instead of package variable.
        and f.is_incoming  = com_api_type_pkg.FALSE
        and f.network_id   = i_network_id
        and f.inst_id      = i_inst_id
        and f.host_inst_id = i_host_inst_id
        and c.id(+)        = f.id;

    trc_log_pkg.debug (
        i_text         => 'estimate_messages_for_upload end: estimated_count [#1]'
      , i_env_param1   => l_result
    );

    return l_result;
end;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
) is
    l_stmt                  varchar2(4000);
    l_status                com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'estimate_messages_for_upload start: i_network_id [#1] i_inst_id [#2] i_host_inst_id [#3]'
      , i_env_param1   => i_network_id
      , i_env_param2   => i_inst_id
      , i_env_param3   => i_host_inst_id
    );

    l_status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

    l_stmt := '
        select ' || G_COLUMN_LIST|| '
          from cup_fin_message f
             , cup_card c
         where decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
           and f.is_incoming = :is_incoming
           and f.network_id = :i_network_id
           and f.inst_id = :i_inst_id
           and f.host_inst_id = :i_host_inst_id
           and c.id(+) = f.id
         order by f.id ';

    trc_log_pkg.debug(
        i_text          => 'l_stmt= [' || l_stmt || ']'
    );

    open o_fin_cur for l_stmt using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;

end;

procedure put_fee (
    i_fee_rec               in cup_api_type_pkg.t_cup_fee_rec
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text         => 'cup_api_fin_message_pkg.put_fee start'
    );

    l_id := nvl(i_fee_rec.id, opr_api_create_pkg.get_id);

    insert into cup_fee (
        id
        , fee_type
        , acquirer_iin
        , forwarding_iin
        , sys_trace_num
        , transmission_date_time
        , merchant_number
        , auth_resp_code
        , is_reversal
        , trans_type_id
        , receiving_iin
        , issuer_iin
        , sttl_currency
        , sttl_sign
        , sttl_amount
        , interchange_fee_sign
        , interchange_fee_amount
        , reimbursement_fee_sign
        , reimbursement_fee_amount
        , service_fee_sign
        , service_fee_amount
        , file_id
        , fin_msg_id
        , match_status
        , inst_id
        , sender_iin_level1
        , sender_iin_level2
        , receiving_iin_level2
        , reason_code
    ) values (
        l_id
        , i_fee_rec.fee_type
        , i_fee_rec.acquirer_iin
        , i_fee_rec.forwarding_iin
        , i_fee_rec.sys_trace_num
        , i_fee_rec.transmission_date_time
        , i_fee_rec.merchant_number
        , i_fee_rec.auth_resp_code
        , i_fee_rec.is_reversal
        , i_fee_rec.trans_type_id
        , i_fee_rec.receiving_iin
        , i_fee_rec.issuer_iin
        , i_fee_rec.sttl_currency
        , i_fee_rec.sttl_sign
        , i_fee_rec.sttl_amount
        , i_fee_rec.interchange_fee_sign
        , i_fee_rec.interchange_fee_amount
        , i_fee_rec.reimbursement_fee_sign
        , i_fee_rec.reimbursement_fee_amount
        , i_fee_rec.service_fee_sign
        , i_fee_rec.service_fee_amount
        , i_fee_rec.file_id
        , i_fee_rec.fin_msg_id
        , i_fee_rec.match_status
        , i_fee_rec.inst_id
        , i_fee_rec.sender_iin_level1
        , i_fee_rec.sender_iin_level2
        , i_fee_rec.receiving_iin_level2
        , i_fee_rec.reason_code
    );

    insert into cup_card (
        id
        , card_number
    ) values (
        l_id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_fee_rec.card_number)
    );

    trc_log_pkg.debug (
        i_text          => 'flush_fee: implemented [#1] CUP fee'
        , i_env_param1  => l_id
    );
end put_fee;

procedure put_audit_trailer (
    i_cup_audit_rec         in cup_api_type_pkg.t_cup_audit_rec
) is
    l_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text         => 'cup_api_fin_message_pkg.put_audit_trailer start'
    );

    l_id := nvl(i_cup_audit_rec.id, opr_api_create_pkg.get_id);

    insert into cup_audit_trailer (
        id
        , acquirer_iin
        , forwarding_iin
        , sys_trace_num
        , transmission_date_time
        , trans_amount
        , message_type
        , proc_func_code
        , mcc
        , terminal_number
        , merchant_number
        , merchant_name
        , rrn
        , pos_cond_code
        , auth_resp_code
        , receiving_iin
        , orig_sys_trace_num
        , trans_resp_code
        , trans_currency
        , pos_entry_mode
        , sttl_currency
        , sttl_amount
        , sttl_exch_rate
        , sttl_date
        , exchange_date
        , cardholder_acc_currency
        , cardholder_bill_amount
        , cardholder_exch_rate
        , receivable_fee
        , payable_fee
        , billing_currency
        , billing_exch_rate
        , file_id
        , inst_id
        , match_status
        , fin_msg_id
    ) values (
        l_id
        , i_cup_audit_rec.acquirer_iin
        , i_cup_audit_rec.forwarding_iin
        , i_cup_audit_rec.sys_trace_num
        , i_cup_audit_rec.transmission_date_time
        , i_cup_audit_rec.trans_amount
        , i_cup_audit_rec.message_type
        , i_cup_audit_rec.proc_func_code
        , i_cup_audit_rec.mcc
        , i_cup_audit_rec.terminal_number
        , i_cup_audit_rec.merchant_number
        , i_cup_audit_rec.merchant_name
        , i_cup_audit_rec.rrn
        , i_cup_audit_rec.pos_cond_code
        , i_cup_audit_rec.auth_resp_code
        , i_cup_audit_rec.receiving_iin
        , i_cup_audit_rec.orig_sys_trace_num
        , i_cup_audit_rec.trans_resp_code
        , i_cup_audit_rec.trans_currency
        , i_cup_audit_rec.pos_entry_mode
        , i_cup_audit_rec.sttl_currency
        , i_cup_audit_rec.sttl_amount
        , i_cup_audit_rec.sttl_exch_rate
        , i_cup_audit_rec.sttl_date
        , i_cup_audit_rec.exchange_date
        , i_cup_audit_rec.cardholder_acc_currency
        , i_cup_audit_rec.cardholder_bill_amount
        , i_cup_audit_rec.cardholder_exch_rate
        , i_cup_audit_rec.receivable_fee
        , i_cup_audit_rec.payable_fee
        , i_cup_audit_rec.billing_currency
        , i_cup_audit_rec.billing_exch_rate
        , i_cup_audit_rec.file_id
        , i_cup_audit_rec.inst_id
        , i_cup_audit_rec.match_status
        , i_cup_audit_rec.fin_msg_id
    );

    insert into cup_card (
        id
        , card_number
    ) values (
        l_id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_cup_audit_rec.card_number)
    );

    trc_log_pkg.debug (
        i_text          => 'flush_audit_trailer: implemented [#1] CUP audit trailer'
        , i_env_param1  => l_id
    );
end put_audit_trailer;

procedure create_fee_oper_stage(
    i_match_status          in com_api_type_pkg.t_dict_value
  , i_fin_msg_id            in com_api_type_pkg.t_long_id
  , i_fee_type              in com_api_type_pkg.t_dict_value
) is
begin
    if i_match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED
       and i_fee_type = cup_api_const_pkg.FT_INTERCHANGE
    then
        insert into opr_oper_stage (
            oper_id
          , proc_stage
          , exec_order
          , status
          , split_hash
        ) values (
            i_fin_msg_id
          , opr_api_const_pkg.PROCESSING_STAGE_INTERCH_FEE
          , 1
          , opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
          , com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, i_fin_msg_id)
        ); 
    end if;
end create_fee_oper_stage;

function is_cup (
    i_id                      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result                  com_api_type_pkg.t_boolean;
begin
    select count(1)
      into l_result
      from cup_fin_message
     where id = i_id
       and rownum <= 1;

    if l_result = 0 then
        select count(1)
          into l_result
          from cup_fee
         where id = i_id
           and rownum <= 1;
    end if;

    return l_result;
end;

function get_original_id (
    i_fin_rec               in cup_api_type_pkg.t_cup_fin_mes_rec
) return com_api_type_pkg.t_long_id is
    l_original_id           com_api_type_pkg.t_long_id;
begin
    select min(f.id)
      into l_original_id
      from cup_fin_message f
         , cup_card c 
     where c.id            = f.id
       and iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) = i_fin_rec.card_number
       and f.sys_trace_num = i_fin_rec.orig_sys_trace_num
       and f.trans_code    = cup_api_const_pkg.TC_PRESENTMENT
       and f.is_reversal   = com_api_type_pkg.FALSE;

    return l_original_id;
end;

procedure get_fin_mes(
    i_id                    in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out cup_api_type_pkg.t_cup_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statement             com_api_type_pkg.t_sql_statement;
begin
    l_statement :=
        'select ' || G_COLUMN_LIST
        || ' from'
        ||   ' cup_fin_message_vw f'
        || ' , cup_card c'
        || ' where'
        || ' f.id = :i_id'
        || ' and f.id = c.id(+)';

    open  l_fin_cur for l_statement using i_id;
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

end cup_api_fin_message_pkg;
/
