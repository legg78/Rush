create or replace package body cst_mpu_api_fin_message_pkg as

G_COLUMN_LIST     constant com_api_type_pkg.t_text :=
    '  f.id'
||  ', f.inst_id'
||  ', f.network_id'
||  ', f.is_incoming'
||  ', f.is_reversal'
||  ', f.is_matched'
||  ', f.status'
||  ', f.file_id'
||  ', f.dispute_id'
||  ', f.original_id'
||  ', f.message_number'
||  ', f.record_type'
||  ', c.card_number'
||  ', f.proc_code'
||  ', f.trans_amount'
||  ', f.sttl_amount'
||  ', f.sttl_rate'
||  ', f.sys_trace_num'
||  ', f.trans_date'
||  ', f.sttl_date'
||  ', f.mcc'
||  ', f.acq_inst_code'
||  ', f.iss_bank_code'
||  ', f.bnb_bank_code'
||  ', f.forw_inst_code'
||  ', f.receiv_inst_code'
||  ', f.auth_number'
||  ', f.rrn'
||  ', f.terminal_number'
||  ', f.trans_currency'
||  ', f.sttl_currency'
||  ', f.acct_from'
||  ', f.acct_to'
||  ', f.mti'
||  ', f.trans_status'
||  ', f.service_fee_receiv'
||  ', f.service_fee_pay'
||  ', f.service_fee_interchg'
||  ', f.pos_entry_mode'
||  ', f.sys_trace_num_orig'
||  ', f.pos_cond_code'
||  ', f.merchant_number'
||  ', f.merchant_name'
||  ', f.accept_amount'
||  ', f.cardholder_trans_fee'
||  ', f.transmit_date'
||  ', f.orig_trans_info'
||  ', f.trans_features'
||  ', f.merchant_country'
||  ', f.auth_type'
||  ', f.reason_code'
||  ', max(f.trans_date) over(order by f.id)max_trans_date'
;

procedure load_auth(
    i_id                    in            com_api_type_pkg.t_long_id
  , io_auth                 in out nocopy aut_api_type_pkg.t_auth_rec
) is
begin
    select min(o.id) id
         , min(o.sttl_type) sttl_type
         , min(o.match_status) match_status
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.inst_id, null)) iss_inst_id
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.network_id, null)) iss_network_id
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id, null)) acq_inst_id
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) acq_network_id
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_inst_id, null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_network_id, null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_type_id, null))
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_country, null))
      into io_auth.id
         , io_auth.sttl_type
         , io_auth.match_status
         , io_auth.iss_inst_id
         , io_auth.iss_network_id
         , io_auth.acq_inst_id
         , io_auth.acq_network_id
         , io_auth.card_inst_id
         , io_auth.card_network_id
         , io_auth.card_type_id
         , io_auth.card_country
      from opr_operation o
         , opr_participant p
         , opr_card c
     where o.id               = i_id
       and p.oper_id          = o.id
       and p.oper_id          = c.oper_id(+)
       and p.participant_type = c.participant_type(+);

end load_auth;

procedure put_fund_stat(
    i_fund_stat in    cst_mpu_api_type_pkg.t_mpu_fund_sttl_rec
) is
    l_fund_stat_id     com_api_type_pkg.t_long_id;
begin
    l_fund_stat_id := 
        nvl(i_fund_stat.id
          , com_api_id_pkg.get_id(cst_mpu_fund_stat_seq.nextval, get_sysdate())
        );

    insert into cst_mpu_fund_stat_vw(
        id
      , inst_id
      , network_id
      , status
      , file_id
      , record_type
      , member_inst_code
      , out_amount_sign
      , out_amount
      , out_fee_sign
      , out_fee_amount
      , in_amount_sign
      , in_amount
      , in_fee_sign
      , in_fee_amount
      , stf_amount_sign
      , stf_amount
      , stf_fee_sign
      , stf_fee_amount
      , out_summary
      , in_summary
      , sttl_currency
    ) values (
        l_fund_stat_id
      , i_fund_stat.inst_id
      , i_fund_stat.network_id
      , i_fund_stat.status
      , i_fund_stat.file_id
      , i_fund_stat.record_type
      , i_fund_stat.member_inst_code
      , i_fund_stat.out_amount_sign
      , i_fund_stat.out_amount
      , i_fund_stat.out_fee_sign
      , i_fund_stat.out_fee_amount
      , i_fund_stat.in_amount_sign
      , i_fund_stat.in_amount
      , i_fund_stat.in_fee_sign
      , i_fund_stat.in_fee_amount
      , i_fund_stat.stf_amount_sign
      , i_fund_stat.stf_amount
      , i_fund_stat.stf_fee_sign
      , i_fund_stat.stf_fee_amount
      , i_fund_stat.out_summary
      , i_fund_stat.in_summary
      , i_fund_stat.sttl_currency
    );
end;

procedure put_merchant_settlement(
    i_merchant_sttl in      cst_mpu_api_type_pkg.t_mpu_mrch_settlement_rec
) is 
    l_merchant_sttl_id     com_api_type_pkg.t_long_id;
begin
    l_merchant_sttl_id := 
        nvl(i_merchant_sttl.id
          , com_api_id_pkg.get_id(cst_mpu_mrch_settlement_seq.nextval, get_sysdate())
        );

    insert into cst_mpu_mrch_settlement_vw(
        id
      , inst_id
      , network_id
      , status
      , file_id
      , record_type
      , member_inst_code
      , merchant_number
      , in_amount_sign
      , in_amount
      , in_fee_sign
      , in_fee_amount
      , total_sttl_amount_sign
      , total_sttl_amount
      , in_summary
      , sttl_currency
      , mrch_sttl_account
    ) values (
        l_merchant_sttl_id
      , i_merchant_sttl.inst_id
      , i_merchant_sttl.network_id
      , i_merchant_sttl.status
      , i_merchant_sttl.file_id
      , i_merchant_sttl.record_type
      , i_merchant_sttl.member_inst_code
      , i_merchant_sttl.merchant_number
      , i_merchant_sttl.in_amount_sign
      , i_merchant_sttl.in_amount
      , i_merchant_sttl.in_fee_sign
      , i_merchant_sttl.in_fee_amount
      , i_merchant_sttl.total_sttl_amount_sign
      , i_merchant_sttl.total_sttl_amount
      , i_merchant_sttl.in_summary
      , i_merchant_sttl.sttl_currency
      , i_merchant_sttl.mrch_sttl_account
    );
end;

procedure put_volume_stat(
    i_volume_stat in     cst_mpu_api_type_pkg.t_mpu_volume_stat_rec
) is
    l_volume_stat_id     com_api_type_pkg.t_long_id;
begin
    l_volume_stat_id := 
        nvl(i_volume_stat.id
          , com_api_id_pkg.get_id(cst_mpu_volume_stat_seq.nextval, get_sysdate())
        );
    insert into cst_mpu_volume_stat_vw(
        id
      , inst_id
      , network_id
      , status
      , file_id
      , record_type
      , member_inst_code
      , sttl_currency
      , stat_trans_code
      , summary
      , credit_amount
      , debit_amount
    ) values (
        l_volume_stat_id
      , i_volume_stat.inst_id
      , i_volume_stat.network_id
      , i_volume_stat.status
      , i_volume_stat.file_id
      , i_volume_stat.record_type
      , i_volume_stat.member_inst_code
      , i_volume_stat.sttl_currency
      , i_volume_stat.stat_trans_code
      , i_volume_stat.summary
      , i_volume_stat.credit_amount
      , i_volume_stat.debit_amount
    );
end;

function put_message (
    i_fin_rec  in     cst_mpu_api_type_pkg.t_mpu_fin_mes_rec
) return com_api_type_pkg.t_long_id is
    l_id              com_api_type_pkg.t_long_id;
    l_split_hash      com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (i_text => 'cup_api_fin_message_pkg.put_message start');
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.acct_from);

    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);

    insert into cst_mpu_fin_msg_vw (
        id
      , split_hash
      , inst_id
      , network_id
      , is_incoming
      , is_reversal
      , is_matched
      , status
      , file_id
      , dispute_id
      , original_id
      , message_number
      , record_type
      , card_mask
      , proc_code
      , trans_amount
      , sttl_amount
      , sttl_rate
      , sys_trace_num
      , trans_date
      , sttl_date
      , mcc
      , acq_inst_code
      , iss_bank_code
      , bnb_bank_code
      , forw_inst_code
      , receiv_inst_code
      , auth_number
      , rrn
      , terminal_number
      , trans_currency
      , sttl_currency
      , acct_from
      , acct_to
      , mti
      , trans_status
      , service_fee_receiv
      , service_fee_pay
      , service_fee_interchg
      , pos_entry_mode
      , sys_trace_num_orig
      , pos_cond_code
      , merchant_number
      , merchant_name
      , accept_amount
      , cardholder_trans_fee
      , transmit_date
      , orig_trans_info
      , trans_features
      , merchant_country
      , auth_type
      , reason_code
    ) values (
        l_id
      , l_split_hash
      , i_fin_rec.inst_id
      , i_fin_rec.network_id
      , i_fin_rec.is_incoming
      , i_fin_rec.is_reversal
      , i_fin_rec.is_matched
      , i_fin_rec.status
      , i_fin_rec.file_id
      , i_fin_rec.dispute_id
      , i_fin_rec.original_id
      , i_fin_rec.message_number
      , i_fin_rec.record_type
      , iss_api_card_pkg.get_card_mask(i_card_number =>  i_fin_rec.card_number)
      , i_fin_rec.proc_code
      , i_fin_rec.trans_amount
      , i_fin_rec.sttl_amount
      , i_fin_rec.sttl_rate
      , i_fin_rec.sys_trace_num
      , i_fin_rec.trans_date
      , i_fin_rec.sttl_date
      , i_fin_rec.mcc
      , i_fin_rec.acq_inst_code
      , i_fin_rec.iss_bank_code
      , i_fin_rec.bnb_bank_code
      , i_fin_rec.forw_inst_code
      , i_fin_rec.receiv_inst_code
      , i_fin_rec.auth_number
      , i_fin_rec.rrn
      , i_fin_rec.terminal_number
      , i_fin_rec.trans_currency
      , i_fin_rec.sttl_currency
      , i_fin_rec.acct_from
      , i_fin_rec.acct_to
      , i_fin_rec.mti
      , i_fin_rec.trans_status
      , i_fin_rec.service_fee_receiv
      , i_fin_rec.service_fee_pay
      , i_fin_rec.service_fee_interchg
      , i_fin_rec.pos_entry_mode
      , i_fin_rec.sys_trace_num_orig
      , i_fin_rec.pos_cond_code
      , i_fin_rec.merchant_number
      , i_fin_rec.merchant_name
      , i_fin_rec.accept_amount
      , i_fin_rec.cardholder_trans_fee
      , i_fin_rec.transmit_date
      , i_fin_rec.orig_trans_info
      , i_fin_rec.trans_features
      , i_fin_rec.merchant_country
      , i_fin_rec.auth_type
      , i_fin_rec.reason_code
    );

    insert into cst_mpu_card (
        id
      , card_number
    ) values (
        l_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    trc_log_pkg.debug (
        i_text        => 'flush_messages: implemented [#1] MPU fin messages'
      , i_env_param1  => l_id
    );

    return l_id;
end;

procedure create_operation (
    i_oper      in    opr_api_type_pkg.t_oper_rec
  , i_iss_part  in    opr_api_type_pkg.t_oper_part_rec
  , i_acq_part  in    opr_api_type_pkg.t_oper_part_rec
)is
    l_oper_id         com_api_type_pkg.t_long_id := i_oper.id;
begin
    trc_log_pkg.debug(i_text => 'cst_mpu_api_fin_message_pkg.create_operation start');

    opr_api_create_pkg.create_operation (
        io_oper_id           => l_oper_id
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
        i_oper_id           => l_oper_id
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
        i_oper_id           => l_oper_id
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
        i_text         => 'cst_mpu_api_fin_message_pkg.create_operation end'
    );
end;

procedure get_fin(
    i_id          in      com_api_type_pkg.t_long_id
  , o_fin_rec        out  cst_mpu_api_type_pkg.t_mpu_fin_mes_rec
  , i_mask_error  in      com_api_type_pkg.t_boolean   := com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statement              com_api_type_pkg.t_text;
begin
    l_statement := '
select
' || G_COLUMN_LIST || '
from
cst_mpu_fin f
, cst_mpu_card c
where
f.id = :i_id
and f.id = c.id(+)';
    open l_fin_cur for l_statement using i_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_id
            );
        else
            trc_log_pkg.error(
                i_text        => 'FINANCIAL_MESSAGE_NOT_FOUND'
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

-- Create outgoing message
procedure process_auth(
    i_auth_rec              in     aut_api_type_pkg.t_auth_rec
  , i_inst_id               in     com_api_type_pkg.t_inst_id default null
  , i_network_id            in     com_api_type_pkg.t_tiny_id default null
  , i_status                in     com_api_type_pkg.t_dict_value default null
  , io_fin_mess_id          in out com_api_type_pkg.t_long_id
) is
    l_fin_rec                      cst_mpu_api_type_pkg.t_mpu_fin_mes_rec;
    l_orig_fin_rec                 cst_mpu_api_type_pkg.t_mpu_fin_mes_rec;
    l_host_id                      com_api_type_pkg.t_tiny_id;
    l_standard_id                  com_api_type_pkg.t_tiny_id;
begin
   trc_log_pkg.debug (
       i_text         => 'cup_api_fin_message_pkg.process_auth START'
   );

    if io_fin_mess_id is null then
        io_fin_mess_id := opr_api_create_pkg.get_id;
    end if;

    l_fin_rec.id           := io_fin_mess_id;
    l_fin_rec.status       := nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
    l_fin_rec.inst_id      := nvl(i_inst_id, i_auth_rec.acq_inst_id);
    l_fin_rec.network_id   := nvl(i_network_id, i_auth_rec.iss_network_id);

    l_fin_rec.is_reversal    := i_auth_rec.is_reversal;
    l_fin_rec.is_incoming    := com_api_type_pkg.FALSE;
    l_fin_rec.original_id    := i_auth_rec.original_id;
    l_fin_rec.rrn            := i_auth_rec.originator_refnum;
    l_fin_rec.trans_date     := i_auth_rec.host_date;
    l_fin_rec.sys_trace_num  := i_auth_rec.system_trace_audit_number;
    l_fin_rec.trans_amount   := i_auth_rec.oper_amount;
    l_fin_rec.trans_currency := i_auth_rec.oper_currency;
    l_fin_rec.trans_date     := i_auth_rec.oper_date;
    l_fin_rec.card_number    := i_auth_rec.card_number;
    l_fin_rec.record_type    := cst_mpu_api_const_pkg.RECORD_TYPE_SETTLEMENT;
 
    -- get network communication standard
    l_host_id              := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id          := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    trc_log_pkg.debug (
        i_text        => 'process_auth: inst_id[#1] network_id[#2] host_id[#3] standard_id[#4]'
      , i_env_param1  => l_fin_rec.inst_id
      , i_env_param2  => l_fin_rec.network_id
      , i_env_param3  => l_host_id
      , i_env_param4  => l_standard_id
    );

    if i_auth_rec.original_id is not null then
        get_fin (
            i_id           => i_auth_rec.original_id
          , o_fin_rec      => l_orig_fin_rec
        );
        -- for Refund , MTI Acquirer = 0200/0210 and Processing Code = 20xx00
        if l_fin_rec.mti in ( 
               cst_mpu_api_const_pkg.MSG_TYPE_FIN_REQUEST
             , cst_mpu_api_const_pkg.MSG_TYPE_FIN_REQUEST_RESPONCE
          )
        and substr(l_fin_rec.proc_code, 1, 2) = '20'
        and substr(l_fin_rec.proc_code, 5, 2) = '00'
        then 
         -- This is REFUND, and  need to fill orig_trans_info! 
         -- Need to find original operation and get its data for this field.
            l_fin_rec.orig_trans_info := l_orig_fin_rec.orig_trans_info;
            l_fin_rec.record_type    := cst_mpu_api_const_pkg.RECORD_TYPE_SETTL_REFUND;
        end if;
    end if;

    l_fin_rec.id := put_message (
                        i_fin_rec    => l_fin_rec
                    );

    trc_log_pkg.debug (
        i_text         => 'cst_mpu_api_fin_message_pkg.process_auth end'
    );
end process_auth;

function estimate_messages_for_upload (
    i_network_id  in     com_api_type_pkg.t_tiny_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
) return number is
    l_result             number;
begin
    trc_log_pkg.debug (
        i_text         => 'estimate_messages_for_upload start: i_network_id [#1] i_inst_id [#2] i_host_inst_id [#3]'
      , i_env_param1   => i_network_id
      , i_env_param2   => i_inst_id
    );

    select count(f.id)
      into l_result
      from cst_mpu_fin_msg f
         , cst_mpu_card c
     where decode(f.status, 'CLMS0010', 'CLMS0010' , null) = 'CLMS0010'  -- In functional index like 'decode' we use dictionary code instead of package variable.
       and f.is_incoming  = com_api_type_pkg.FALSE
       and f.network_id   = i_network_id
       and f.inst_id      = i_inst_id
       and c.id(+)        = f.id;

    trc_log_pkg.debug (
        i_text         => 'estimate_messages_for_upload end: estimated_count [#1]'
      , i_env_param1   => l_result
    );

    return l_result;
end;

procedure enum_messages_for_upload (
    o_fin_cur     in out  sys_refcursor
  , i_network_id  in      com_api_type_pkg.t_tiny_id
  , i_inst_id     in      com_api_type_pkg.t_inst_id
) is
    l_stmt                com_api_type_pkg.t_raw_data; -- varchar2(4000);
    l_status              com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'estimate_messages_for_upload start: i_network_id [#1] i_inst_id [#2] i_host_inst_id [#3]'
      , i_env_param1   => i_network_id
      , i_env_param2   => i_inst_id
    );

    l_status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

    l_stmt := '
        select ' || G_COLUMN_LIST|| '
          from cst_mpu_fin_msg f
             , cst_mpu_card c
         where decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
           and f.is_incoming  = :is_incoming
           and f.network_id   = :i_network_id
           and f.inst_id      = :i_inst_id
           and c.id(+)        = f.id
         order by f.id ';

    trc_log_pkg.debug(i_text => 'l_stmt= [' || l_stmt || ']');

    open o_fin_cur for l_stmt using com_api_type_pkg.FALSE, i_network_id, i_inst_id;
end;

end cst_mpu_api_fin_message_pkg;
/
