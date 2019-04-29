create or replace package body amx_api_dispute_pkg as

procedure update_dispute_id (
    i_id                      in     com_api_type_pkg.t_long_id
  , i_dispute_id              in     com_api_type_pkg.t_long_id
) is
begin
    update amx_fin_message
       set dispute_id = i_dispute_id
     where id         = i_id;

    update opr_operation
       set dispute_id = i_dispute_id
     where id         = i_id;
end;

procedure sync_dispute_id (
    io_fin_rec                in out nocopy amx_api_type_pkg.t_amx_fin_mes_rec
  , o_dispute_id                 out com_api_type_pkg.t_long_id
) is
begin
    if io_fin_rec.dispute_id is null then
        io_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;

        update_dispute_id (
            i_id            => io_fin_rec.id
            , i_dispute_id  => io_fin_rec.dispute_id
        );
    end if;

    o_dispute_id := io_fin_rec.dispute_id;
end;

procedure fetch_dispute_id (
    i_fin_cur                 in     sys_refcursor
  , o_fin_rec                    out amx_api_type_pkg.t_amx_fin_mes_rec
) is
    l_fin_tab                 amx_api_type_pkg.t_amx_fin_mes_tab;
begin
    savepoint fetch_dispute_id;

    if i_fin_cur%isopen then
        fetch i_fin_cur bulk collect into l_fin_tab;

        for i in 1..l_fin_tab.count loop
            if i = 1 then
                if l_fin_tab(i).dispute_id is null then
                    l_fin_tab(i).dispute_id := dsp_api_shared_data_pkg.get_id;
                    update_dispute_id (
                        i_id            => l_fin_tab(i).id
                        , i_dispute_id  => l_fin_tab(i).dispute_id
                    );
                end if;

                o_fin_rec := l_fin_tab(i);
            else
                if l_fin_tab(i).dispute_id is null then
                    update_dispute_id (
                        i_id            => l_fin_tab(i).id
                        , i_dispute_id  => o_fin_rec.dispute_id
                    );

                elsif l_fin_tab(i).dispute_id != o_fin_rec.dispute_id then
                    trc_log_pkg.warn (
                        i_text => 'TOO_MANY_DISPUTES_FOUND'
                    );
                    o_fin_rec := null;
                    rollback to savepoint fetch_dispute_id;
                    return;

                end if;

            end if;
        end loop;

        if l_fin_tab.count = 0 then
            trc_log_pkg.warn (
                i_text  => 'NO_DISPUTE_FOUND'
            );
            o_fin_rec := null;
            rollback to savepoint fetch_dispute_id;
        else
            trc_log_pkg.debug (
                i_text  => 'dispute_id [' || o_fin_rec.dispute_id || ']'
            );
        end if;
    end if;
exception
    when others then
        rollback to savepoint fetch_dispute_id;
        raise;
end fetch_dispute_id;

procedure load_auth (
    i_id                      in     com_api_type_pkg.t_long_id
  , io_auth                   in out nocopy aut_api_type_pkg.t_auth_rec
) is
begin
    select
        min(o.id) id
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
    into
        io_auth.id
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
    from
        opr_operation o
        , opr_participant p
        , opr_card c
    where
        o.id = i_id
        and p.oper_id = o.id
        and p.oper_id = c.oper_id(+)
        and p.participant_type = c.participant_type(+);
end;


procedure assign_dispute(
    io_amx_fin_rec            in out nocopy amx_api_type_pkg.t_amx_fin_mes_rec    
  , o_auth                       out aut_api_type_pkg.t_auth_rec
) is
    l_orgn_fin_rec            amx_api_type_pkg.t_amx_fin_mes_rec;
    l_need_original_rec       com_api_type_pkg.t_boolean;

begin
    trc_log_pkg.debug (
        i_text          => 'amx_api_dispute_pkg.assign_dispute start'
    );

    io_amx_fin_rec.dispute_id := null;
    l_need_original_rec   := com_api_type_pkg.TRUE;

    if io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_PRESENTMENT
       and io_amx_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES
       and io_amx_fin_rec.is_reversal = com_api_type_pkg.FALSE then

        amx_api_fin_message_pkg.find_original_fin(
            i_fin_rec           => io_amx_fin_rec
            , o_fin_rec         => l_orgn_fin_rec
        );
        if l_orgn_fin_rec.id is not null then
            io_amx_fin_rec.dispute_id := l_orgn_fin_rec.dispute_id;
        end if;
        l_need_original_rec   := com_api_type_pkg.FALSE;

    elsif io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_PRESENTMENT
          and io_amx_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES
          and io_amx_fin_rec.is_reversal != com_api_type_pkg.FALSE
          or
          io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_PRESENTMENT
          and io_amx_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_SECOND_PRES
          or
          io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_CHARGEBACK
          or
          io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST
          or
          io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_FULFILLMENT
          or
          io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_FEE_COLLECTION
          or
          io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_ISS_ATM_FEE
          or
          io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_ACQ_ATM_FEE
    then
        amx_api_fin_message_pkg.find_original_fin(
            i_fin_rec           => io_amx_fin_rec
            , o_fin_rec         => l_orgn_fin_rec
        );

        if l_orgn_fin_rec.id is not null then
            io_amx_fin_rec.dispute_id := l_orgn_fin_rec.dispute_id;
            io_amx_fin_rec.inst_id    := l_orgn_fin_rec.inst_id;
            io_amx_fin_rec.network_id := l_orgn_fin_rec.network_id;

            load_auth (
                i_id       => l_orgn_fin_rec.id
                , io_auth  => o_auth
            );
        end if;

    else
        trc_log_pkg.debug (
            i_text          => 'No necessity to assign dispute_id. [#1]'
            , i_env_param1  => io_amx_fin_rec.id
        );

    end if;

    if io_amx_fin_rec.dispute_id is not null then

        trc_log_pkg.debug (
            i_text          => 'Dispute id assigned [#1][#2]'
            , i_env_param1  => io_amx_fin_rec.id
            , i_env_param2  => io_amx_fin_rec.dispute_id
        );

    elsif io_amx_fin_rec.dispute_id is null
          and l_need_original_rec = com_api_type_pkg.FALSE
    then
        trc_log_pkg.debug (
            i_text          => 'No dispute needed'
        );

    elsif io_amx_fin_rec.dispute_id is null
          and l_need_original_rec = com_api_type_pkg.TRUE
          and l_orgn_fin_rec.id is null
          and io_amx_fin_rec.mtid = amx_api_const_pkg.MTID_ACQ_ATM_FEE
    then
        trc_log_pkg.debug (
            i_text          => 'The dispute is need, but ATM Fee has no parent transaction_id'
        );

    else
        io_amx_fin_rec.is_invalid := com_api_type_pkg.TRUE;
        io_amx_fin_rec.status     := amx_api_const_pkg.MSG_STATUS_INVALID;

        trc_log_pkg.debug (
            i_text          => 'The dispute is need, but not found. Set message status = invalid'
        );
    end if;

    trc_log_pkg.debug (
        i_text          => 'amx_api_dispute_pkg.assign_dispute end'
    );

exception
    when others then
        raise;

end;

function get_proc_code_rvs(
    i_proc_code               in     com_api_type_pkg.t_auth_code
)return com_api_type_pkg.t_auth_code
is
    l_proc_code            com_api_type_pkg.t_auth_code;
begin
    l_proc_code :=
    case when i_proc_code = amx_api_const_pkg.PROC_CODE_CREDIT       then amx_api_const_pkg.PROC_CODE_DEBIT
         when i_proc_code = amx_api_const_pkg.PROC_CODE_CASH_DISB_CR then amx_api_const_pkg.PROC_CODE_CASH_DISB_DB
         when i_proc_code = amx_api_const_pkg.PROC_CODE_DEBIT        then amx_api_const_pkg.PROC_CODE_CREDIT
         when i_proc_code = amx_api_const_pkg.PROC_CODE_ATM_CASH     then amx_api_const_pkg.PROC_CODE_CREDIT
         when i_proc_code = amx_api_const_pkg.PROC_CODE_CASH_DISB_DB then amx_api_const_pkg.PROC_CODE_CASH_DISB_CR
         else null
    end;

    if l_proc_code is null then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_PROC_CODE_RVS_NOT_FOUND'
            , i_env_param1  => i_proc_code
        );
    end if;

    return l_proc_code;
end;

procedure gen_first_presentment_rvs(
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
)is
    l_trans_amount            com_api_type_pkg.t_money;
    l_trans_currency          com_api_type_pkg.t_curr_code;
    l_curr_exp                com_api_type_pkg.t_sign;
    l_proc_code               com_api_type_pkg.t_auth_code;

    l_fin_rec                 amx_api_type_pkg.t_amx_fin_mes_rec;
    l_auth_rec                aut_api_type_pkg.t_auth_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_message_seq_number      pls_integer := 0;

begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.gen_first_presentment_rvs start'
    );

    amx_api_fin_message_pkg.load_fin_message(
        i_fin_id                => i_original_fin_id
        , o_fin_rec             => l_fin_rec
    );

    if l_fin_rec.mtid = amx_api_const_pkg.MTID_PRESENTMENT
       and l_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES
       and l_fin_rec.is_incoming = com_api_type_pkg.FALSE
       and l_fin_rec.is_reversal = com_api_type_pkg.FALSE
    then

        sync_dispute_id (
            io_fin_rec      => l_fin_rec
            , o_dispute_id  => l_fin_rec.dispute_id
        );

        o_fin_id                := opr_api_create_pkg.get_id;
        l_fin_rec.id            := o_fin_id;
        l_fin_rec.is_rejected   := com_api_type_pkg.FALSE;
        l_fin_rec.is_incoming   := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal   := com_api_type_pkg.TRUE;
        l_fin_rec.file_id       := null;
        l_fin_rec.status        := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        l_fin_rec.proc_code     := get_proc_code_rvs(i_proc_code => l_fin_rec.proc_code);

        l_fin_rec.impact := amx_prc_incoming_pkg.get_message_impact(
                                    i_mtid            => l_fin_rec.mtid
                                    , i_func_code     => l_fin_rec.func_code
                                    , i_proc_code     => l_fin_rec.proc_code
                                    , i_incoming      => l_fin_rec.is_incoming
                                    , i_raise_error   => com_api_type_pkg.TRUE
                                );

        l_fin_rec.message_number            := null;

        l_fin_rec.trans_amount              := i_trans_amount;
        l_fin_rec.trans_currency            := i_trans_currency;
        l_fin_rec.trans_decimalization      := com_api_currency_pkg.get_currency_exponent(i_trans_currency);

        l_fin_rec.fp_pres_amount            := l_fin_rec.trans_amount;
        l_fin_rec.fp_pres_conversion_rate   := 1;
        l_fin_rec.fp_pres_currency          := l_fin_rec.trans_currency;
        l_fin_rec.fp_pres_decimalization    := l_fin_rec.trans_decimalization;

        l_fin_rec.fp_trans_date             := l_fin_rec.trans_date;

        l_fin_rec.trans_date                := com_api_sttl_day_pkg.get_sysdate;

        l_fin_rec.id := amx_api_fin_message_pkg.put_message (
                            i_fin_rec    => l_fin_rec
                        );

        opr_api_shared_data_pkg.load_auth(
            i_id            => i_original_fin_id
          , io_auth         => l_auth_rec
        );

        amx_api_fin_message_pkg.create_addendums(
            i_fin_rec                => l_fin_rec
            , i_auth_rec             => l_auth_rec
            , i_collection_only      => l_fin_rec.is_collection_only
            , io_message_seq_number  => l_message_seq_number
        );

        l_host_id := net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        amx_api_fin_message_pkg.create_operation (
             i_fin_rec       => l_fin_rec
            , i_standard_id  => l_standard_id
        );

        trc_log_pkg.debug (
            i_text         => 'amx_api_dispute_pkg.gen_first_presentment_rvs end'
        );

    else
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_CANNOT_CREATE_REVERSAL'
            , i_env_param1  => l_fin_rec.id
        );

    end if;

end;

procedure gen_second_presentment (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
)is
    l_original_fin_rec        amx_api_type_pkg.t_amx_fin_mes_rec;
    l_first_pres_rec          amx_api_type_pkg.t_amx_fin_mes_rec;
    l_fin_rec                 amx_api_type_pkg.t_amx_fin_mes_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;

begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.gen_second_presentment start'
    );

    amx_api_fin_message_pkg.load_fin_message(
        i_fin_id                => i_original_fin_id
        , o_fin_rec             => l_original_fin_rec
    );

    if l_original_fin_rec.mtid        = amx_api_const_pkg.MTID_CHARGEBACK
     and l_original_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_CHARGEBACK
     and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
     and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
    then
         -- init
        o_fin_id                := opr_api_create_pkg.get_id;
        l_fin_rec.id            := o_fin_id;
        l_fin_rec.is_rejected   := com_api_type_pkg.FALSE;
        l_fin_rec.is_incoming   := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal   := com_api_type_pkg.FALSE;
        l_fin_rec.file_id       := null;
        l_fin_rec.status        := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        l_fin_rec.inst_id       := l_original_fin_rec.inst_id;
        l_fin_rec.network_id    := l_original_fin_rec.network_id;

        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
            , o_dispute_id  => l_fin_rec.dispute_id
        );

        amx_api_fin_message_pkg.get_fin (
            i_mtid           => amx_api_const_pkg.MTID_PRESENTMENT
            , i_func_code    => amx_api_const_pkg.FUNC_CODE_FIRST_PRES
            , i_is_reversal  => l_original_fin_rec.is_reversal
            , i_dispute_id   => l_original_fin_rec.dispute_id
            , o_fin_rec      => l_first_pres_rec
            , i_mask_error   => com_api_const_pkg.FALSE
        );

        l_fin_rec.mtid                          := amx_api_const_pkg.MTID_PRESENTMENT;
        l_fin_rec.func_code                     := amx_api_const_pkg.FUNC_CODE_SECOND_PRES;
        l_fin_rec.card_number                   := l_first_pres_rec.card_number;
        l_fin_rec.pan_length                    := length(l_first_pres_rec.card_number);
        l_fin_rec.proc_code                     := l_first_pres_rec.proc_code;
        l_fin_rec.card_mask                     := l_first_pres_rec.card_mask;
        l_fin_rec.card_hash                     := l_first_pres_rec.card_hash;
        l_fin_rec.trans_amount                  := i_trans_amount;
        l_fin_rec.trans_date                    := com_api_sttl_day_pkg.get_sysdate;
        l_fin_rec.card_expir_date               := l_first_pres_rec.card_expir_date;
        l_fin_rec.capture_date                  := l_first_pres_rec.capture_date;
        l_fin_rec.pdc_1                         := l_first_pres_rec.pdc_1;
        l_fin_rec.pdc_2                         := l_first_pres_rec.pdc_2;
        l_fin_rec.pdc_3                         := l_first_pres_rec.pdc_3;
        l_fin_rec.pdc_4                         := l_first_pres_rec.pdc_4;
        l_fin_rec.pdc_5                         := l_first_pres_rec.pdc_5;
        l_fin_rec.pdc_6                         := l_first_pres_rec.pdc_6;
        l_fin_rec.pdc_7                         := l_first_pres_rec.pdc_7;
        l_fin_rec.pdc_8                         := l_first_pres_rec.pdc_8;
        l_fin_rec.pdc_9                         := l_first_pres_rec.pdc_9;
        l_fin_rec.pdc_10                        := l_first_pres_rec.pdc_10;
        l_fin_rec.pdc_11                        := l_first_pres_rec.pdc_11;
        l_fin_rec.pdc_12                        := l_first_pres_rec.pdc_12;
        l_fin_rec.reason_code                   := i_reason_code;
        l_fin_rec.mcc                           := l_first_pres_rec.mcc;
        l_fin_rec.eci                           := l_first_pres_rec.eci;
        l_fin_rec.approval_code                 := l_first_pres_rec.approval_code;
        l_fin_rec.approval_code_length          := l_first_pres_rec.approval_code_length;
        l_fin_rec.fp_trans_amount               := l_original_fin_rec.trans_amount;
        l_fin_rec.ain                           := nvl(l_original_fin_rec.ain, l_first_pres_rec.ain);
        l_fin_rec.apn                           := nvl(l_original_fin_rec.apn, l_first_pres_rec.apn);
        l_fin_rec.arn                           := l_first_pres_rec.arn;
        l_fin_rec.terminal_number               := l_first_pres_rec.terminal_number;
        l_fin_rec.merchant_number               := nvl(l_original_fin_rec.merchant_number, l_first_pres_rec.merchant_number);
        l_fin_rec.merchant_name                 := l_first_pres_rec.merchant_name;
        l_fin_rec.merchant_addr1                := l_first_pres_rec.merchant_addr1;
        l_fin_rec.merchant_addr2                := l_first_pres_rec.merchant_addr2;
        l_fin_rec.merchant_city                 := l_first_pres_rec.merchant_city;
        l_fin_rec.merchant_postal_code          := l_first_pres_rec.merchant_postal_code;
        l_fin_rec.merchant_region               := l_first_pres_rec.merchant_region;
        l_fin_rec.merchant_country              := l_first_pres_rec.merchant_country;
        l_fin_rec.matching_key                  := l_first_pres_rec.matching_key;
        l_fin_rec.matching_key_type             := l_first_pres_rec.matching_key_type;
        l_fin_rec.fp_trans_currency             := l_first_pres_rec.trans_currency;
        l_fin_rec.fp_trans_decimalization       := l_first_pres_rec.trans_decimalization;
        l_fin_rec.fp_pres_amount                := l_first_pres_rec.fp_pres_amount;
        l_fin_rec.fp_pres_conversion_rate       := l_first_pres_rec.fp_pres_conversion_rate;
        l_fin_rec.fp_pres_currency              := l_first_pres_rec.fp_pres_currency;
        l_fin_rec.fp_pres_decimalization        := l_first_pres_rec.fp_pres_decimalization;
        l_fin_rec.merchant_multinational        := l_first_pres_rec.merchant_multinational;
        l_fin_rec.trans_currency                := i_trans_currency;
        l_fin_rec.alt_merchant_number           := l_first_pres_rec.alt_merchant_number;
        l_fin_rec.alt_merchant_number_length    := l_first_pres_rec.alt_merchant_number_length;
        l_fin_rec.fp_trans_date                 := nvl(l_original_fin_rec.fp_trans_date, l_first_pres_rec.trans_date);
        l_fin_rec.card_capability               := l_first_pres_rec.card_capability;
        l_fin_rec.fp_trans_decimalization       := com_api_currency_pkg.get_currency_exponent(i_trans_currency);
        l_fin_rec.fp_network_proc_date          := nvl(l_original_fin_rec.fp_network_proc_date, l_first_pres_rec.network_proc_date);
        l_fin_rec.format_code                   := l_first_pres_rec.format_code;
        l_fin_rec.iin                           := nvl(l_original_fin_rec.iin, l_first_pres_rec.iin);
        l_fin_rec.media_code                    := l_first_pres_rec.media_code;
        l_fin_rec.message_seq_number            := 1;

        l_fin_rec.itemized_doc_code             := i_itemized_doc_code;
        l_fin_rec.itemized_doc_ref_number       := i_itemized_doc_ref_number;

        l_fin_rec.transaction_id                := nvl(l_original_fin_rec.transaction_id, l_first_pres_rec.transaction_id);
        l_fin_rec.ext_payment_data              := l_first_pres_rec.ext_payment_data;
        l_fin_rec.ipn                           := nvl(l_original_fin_rec.ipn, l_first_pres_rec.ipn);
        l_fin_rec.invoice_number                := l_first_pres_rec.invoice_number;
        l_fin_rec.is_collection_only            := l_first_pres_rec.is_collection_only;

        l_fin_rec.impact := amx_prc_incoming_pkg.get_message_impact(
                                    i_mtid            => l_fin_rec.mtid
                                    , i_func_code     => l_fin_rec.func_code
                                    , i_proc_code     => l_fin_rec.proc_code
                                    , i_incoming      => l_fin_rec.is_incoming
                                    , i_raise_error   => com_api_type_pkg.TRUE
                                );

        o_fin_id := amx_api_fin_message_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_host_id := net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );
        amx_api_fin_message_pkg.create_operation (
             i_fin_rec       => l_fin_rec
            , i_standard_id  => l_standard_id
        );
        trc_log_pkg.debug (
            i_text         => 'amx_api_dispute_pkg.gen_second_presentment end'
        );

    else
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_CANNOT_CREATE_SECOND_PRES'
            , i_env_param1  => i_original_fin_id
        );

    end if;
end;

procedure gen_first_chargeback (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code 
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_text       in     com_api_type_pkg.t_name          default null
)is
    l_original_fin_rec        amx_api_type_pkg.t_amx_fin_mes_rec;
    l_fin_rec                 amx_api_type_pkg.t_amx_fin_mes_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.gen_first_chargeback start'
    );

    amx_api_fin_message_pkg.load_fin_message(
        i_fin_id                => i_original_fin_id
        , o_fin_rec             => l_original_fin_rec
    );

    if l_original_fin_rec.mtid           = amx_api_const_pkg.MTID_PRESENTMENT
      and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
      and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
    then
        -- init
        o_fin_id                := opr_api_create_pkg.get_id;
        l_fin_rec.id            := o_fin_id;
        l_fin_rec.is_rejected   := com_api_type_pkg.FALSE;
        l_fin_rec.is_incoming   := com_api_type_pkg.FALSE;
        l_fin_rec.file_id       := null;
        l_fin_rec.status        := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        l_fin_rec.inst_id       := l_original_fin_rec.inst_id;
        l_fin_rec.network_id    := l_original_fin_rec.network_id;

        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
            , o_dispute_id  => l_fin_rec.dispute_id
        );
        l_fin_rec.mtid                      := amx_api_const_pkg.MTID_CHARGEBACK;
        l_fin_rec.func_code                 := i_func_code;
        l_fin_rec.card_number               := l_original_fin_rec.card_number;
        l_fin_rec.pan_length                := length(l_fin_rec.card_number);
        l_fin_rec.card_mask                 := l_original_fin_rec.card_mask;
        l_fin_rec.card_hash                 := l_original_fin_rec.card_hash;
        l_fin_rec.proc_code                 := l_original_fin_rec.proc_code;

        l_fin_rec.trans_amount              := i_trans_amount;
        l_fin_rec.trans_date                := com_api_sttl_day_pkg.get_sysdate;
        l_fin_rec.card_expir_date           := l_original_fin_rec.card_expir_date;

        l_fin_rec.capture_date              := l_original_fin_rec.capture_date;
        l_fin_rec.reason_code               := i_reason_code;
        l_fin_rec.mcc                       := l_original_fin_rec.mcc;
        l_fin_rec.fp_trans_amount           := l_original_fin_rec.trans_amount;
        l_fin_rec.ain                       := l_original_fin_rec.ain;
        l_fin_rec.ipn                       := l_original_fin_rec.ipn;
        l_fin_rec.arn                       := l_original_fin_rec.arn;
        l_fin_rec.terminal_number           := l_original_fin_rec.terminal_number;
        l_fin_rec.merchant_number           := l_original_fin_rec.merchant_number;
        l_fin_rec.alt_merchant_number       := l_original_fin_rec.alt_merchant_number;
        l_fin_rec.alt_merchant_number_length:= l_original_fin_rec.alt_merchant_number_length;

        l_fin_rec.fp_trans_currency         := l_original_fin_rec.trans_currency;
        l_fin_rec.fp_trans_decimalization   := l_original_fin_rec.trans_decimalization;
        l_fin_rec.fp_pres_amount            := l_original_fin_rec.fp_pres_amount;
        l_fin_rec.fp_pres_conversion_rate   := l_original_fin_rec.fp_pres_conversion_rate;
        l_fin_rec.fp_pres_currency          := l_original_fin_rec.fp_pres_currency;
        l_fin_rec.fp_pres_decimalization    := l_original_fin_rec.fp_pres_decimalization;

        l_fin_rec.trans_currency            := i_trans_currency;
        l_fin_rec.fp_trans_date             := l_original_fin_rec.trans_date;
        l_fin_rec.trans_decimalization      := com_api_currency_pkg.get_currency_exponent(i_trans_currency);
        l_fin_rec.chbck_reason_text         := i_chbck_reason_text;
        l_fin_rec.fp_network_proc_date      := l_original_fin_rec.network_proc_date;
        l_fin_rec.iin                       := l_original_fin_rec.iin;
        l_fin_rec.message_seq_number        := 1;
        l_fin_rec.transaction_id            := l_original_fin_rec.transaction_id;
        l_fin_rec.is_collection_only        := l_original_fin_rec.is_collection_only;

        l_fin_rec.apn                       := l_original_fin_rec.apn;

        l_fin_rec.impact := amx_prc_incoming_pkg.get_message_impact(
                                    i_mtid            => l_fin_rec.mtid
                                    , i_func_code     => l_fin_rec.func_code
                                    , i_proc_code     => l_fin_rec.proc_code
                                    , i_incoming      => l_fin_rec.is_incoming
                                    , i_raise_error   => com_api_type_pkg.TRUE
                                );

        o_fin_id := amx_api_fin_message_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_host_id := net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );

        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        amx_api_fin_message_pkg.create_operation (
             i_fin_rec       => l_fin_rec
            , i_standard_id  => l_standard_id
        );

        trc_log_pkg.debug (
            i_text         => 'amx_api_dispute_pkg.gen_first_chargeback end'
        );

    else
        if i_func_code = amx_api_const_pkg.FUNC_CODE_FIRST_CHARGEBACK then
            com_api_error_pkg.raise_error (
                i_error         => 'AMX_CANNOT_CREATE_FIRST_CHBCK'
                , i_env_param1  => i_original_fin_id
            );
        else
            com_api_error_pkg.raise_error (
                i_error         => 'AMX_CANNOT_CREATE_FINAL_CHBCK'
                , i_env_param1  => i_original_fin_id
            );
        end if;
    end if;

end;

procedure gen_retrieval_request (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_name          default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_code       in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_name          default null
)is
    l_fin_rec                 amx_api_type_pkg.t_amx_fin_mes_rec;
    l_original_fin_rec        amx_api_type_pkg.t_amx_fin_mes_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.gen_retrieval_request start'
    );

    amx_api_fin_message_pkg.load_fin_message(
        i_fin_id                => i_original_fin_id
        , o_fin_rec             => l_original_fin_rec
    );

    if l_original_fin_rec.mtid        = amx_api_const_pkg.MTID_PRESENTMENT
     and l_original_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES
     and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
     and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
    then

        -- init
        o_fin_id                := opr_api_create_pkg.get_id;
        l_fin_rec.id            := o_fin_id;
        l_fin_rec.is_rejected   := com_api_type_pkg.FALSE;
        l_fin_rec.is_incoming   := com_api_type_pkg.FALSE;
        l_fin_rec.file_id       := null;
        l_fin_rec.status        := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        l_fin_rec.inst_id       := l_original_fin_rec.inst_id;
        l_fin_rec.network_id    := l_original_fin_rec.network_id;

        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
            , o_dispute_id  => l_fin_rec.dispute_id
        );
        l_fin_rec.mtid                      := amx_api_const_pkg.MTID_RETRIEVAL_REQUEST;
        l_fin_rec.func_code                 := i_func_code;

        l_fin_rec.card_number               := l_original_fin_rec.card_number;
        l_fin_rec.pan_length                := length(l_fin_rec.card_number);
        l_fin_rec.card_mask                 := l_original_fin_rec.card_mask;
        l_fin_rec.card_hash                 := l_original_fin_rec.card_hash;
        l_fin_rec.proc_code                 := l_original_fin_rec.proc_code;

        l_fin_rec.trans_date                := com_api_sttl_day_pkg.get_sysdate;
        l_fin_rec.card_expir_date           := l_original_fin_rec.card_expir_date;
        l_fin_rec.capture_date              := l_original_fin_rec.capture_date;
        l_fin_rec.mcc                       := l_original_fin_rec.mcc;
        l_fin_rec.reason_code               := i_reason_code;

        l_fin_rec.fp_trans_amount           := l_original_fin_rec.trans_amount;
        l_fin_rec.ain                       := l_original_fin_rec.ain;
        l_fin_rec.ipn                       := l_original_fin_rec.ipn;
        l_fin_rec.arn                       := l_original_fin_rec.arn;

        l_fin_rec.terminal_number           := l_original_fin_rec.terminal_number;
        l_fin_rec.merchant_number           := l_original_fin_rec.merchant_number;
        l_fin_rec.alt_merchant_number       := l_original_fin_rec.alt_merchant_number;
        l_fin_rec.alt_merchant_number_length:= l_original_fin_rec.alt_merchant_number_length;

        l_fin_rec.fp_trans_currency         := l_original_fin_rec.trans_currency;
        l_fin_rec.fp_trans_decimalization   := l_original_fin_rec.trans_decimalization;
        l_fin_rec.fp_pres_amount            := l_original_fin_rec.fp_pres_amount;
        l_fin_rec.fp_pres_currency          := l_original_fin_rec.fp_pres_currency;
        l_fin_rec.fp_pres_decimalization    := l_original_fin_rec.fp_pres_decimalization;

        l_fin_rec.fp_trans_date             := l_original_fin_rec.trans_date;
        l_fin_rec.chbck_reason_code         := i_chbck_reason_code;
        l_fin_rec.fp_network_proc_date      := l_original_fin_rec.network_proc_date;
        l_fin_rec.iin                       := l_original_fin_rec.iin;
        l_fin_rec.message_seq_number        := 1;
        l_fin_rec.itemized_doc_code         := i_itemized_doc_code;
        l_fin_rec.transaction_id            := l_original_fin_rec.transaction_id;
        l_fin_rec.apn                       := l_original_fin_rec.apn;
        l_fin_rec.is_collection_only        := l_original_fin_rec.is_collection_only;

        o_fin_id := amx_api_fin_message_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_host_id := net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );

        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        amx_api_fin_message_pkg.create_operation (
             i_fin_rec       => l_fin_rec
            , i_standard_id  => l_standard_id
        );

        trc_log_pkg.debug (
            i_text         => 'amx_api_dispute_pkg.gen_retrieval_request end'
        );

    else
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_CANNOT_CREATE_RETRIEVAL_REQ'
            , i_env_param1  => i_original_fin_id
        );
    end if;
end;

procedure gen_fulfillment (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_name          default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
) is
    l_fin_rec                 amx_api_type_pkg.t_amx_fin_mes_rec;
    l_original_fin_rec        amx_api_type_pkg.t_amx_fin_mes_rec;
    l_first_pres_rec          amx_api_type_pkg.t_amx_fin_mes_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.gen_fulfillment start'
    );

    amx_api_fin_message_pkg.load_fin_message(
        i_fin_id                => i_original_fin_id
        , o_fin_rec             => l_original_fin_rec
    );

    if l_original_fin_rec.mtid        = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST
     and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
    then
        -- init
        o_fin_id                := opr_api_create_pkg.get_id;
        l_fin_rec.id            := o_fin_id;
        l_fin_rec.is_rejected   := com_api_type_pkg.FALSE;
        l_fin_rec.is_incoming   := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal   := com_api_type_pkg.FALSE;
        l_fin_rec.file_id       := null;
        l_fin_rec.status        := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        l_fin_rec.inst_id       := l_original_fin_rec.inst_id;
        l_fin_rec.network_id    := l_original_fin_rec.network_id;

        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
            , o_dispute_id  => l_fin_rec.dispute_id
        );

        amx_api_fin_message_pkg.get_fin (
            i_mtid           => amx_api_const_pkg.MTID_PRESENTMENT
            , i_func_code    => amx_api_const_pkg.FUNC_CODE_FIRST_PRES
            , i_is_reversal  => l_original_fin_rec.is_reversal
            , i_dispute_id   => l_original_fin_rec.dispute_id
            , o_fin_rec      => l_first_pres_rec
            , i_mask_error   => com_api_const_pkg.TRUE
        );

        l_fin_rec.mtid                      := amx_api_const_pkg.MTID_FULFILLMENT;
        l_fin_rec.func_code                 := i_func_code;

        l_fin_rec.card_number               := l_original_fin_rec.card_number;
        l_fin_rec.pan_length                := length(l_fin_rec.card_number);
        l_fin_rec.card_mask                 := l_original_fin_rec.card_mask;
        l_fin_rec.card_hash                 := l_original_fin_rec.card_hash;
        l_fin_rec.proc_code                 := l_original_fin_rec.proc_code;

        l_fin_rec.trans_date                := com_api_sttl_day_pkg.get_sysdate;
        l_fin_rec.card_expir_date           := l_original_fin_rec.card_expir_date;
        l_fin_rec.capture_date              := l_original_fin_rec.capture_date;
        l_fin_rec.mcc                       := l_original_fin_rec.mcc;
        l_fin_rec.reason_code               := i_reason_code;

        l_fin_rec.fp_trans_amount           := nvl(l_original_fin_rec.fp_trans_amount, l_original_fin_rec.trans_amount);
        l_fin_rec.ain                       := l_original_fin_rec.ain;
        l_fin_rec.apn                       := l_original_fin_rec.apn;
        l_fin_rec.arn                       := l_original_fin_rec.arn;

        l_fin_rec.terminal_number           := nvl(l_original_fin_rec.terminal_number, l_first_pres_rec.terminal_number);
        l_fin_rec.merchant_number           := l_original_fin_rec.merchant_number;
        l_fin_rec.alt_merchant_number       := l_original_fin_rec.alt_merchant_number;
        l_fin_rec.alt_merchant_number_length:= l_original_fin_rec.alt_merchant_number_length;

        l_fin_rec.fp_trans_currency         := nvl(l_original_fin_rec.fp_trans_currency, l_original_fin_rec.trans_currency);
        l_fin_rec.fp_trans_decimalization   := nvl(l_original_fin_rec.fp_trans_decimalization, l_original_fin_rec.trans_decimalization);
        l_fin_rec.fp_pres_amount            := l_original_fin_rec.fp_pres_amount;
        l_fin_rec.fp_pres_currency          := l_original_fin_rec.fp_pres_currency;
        l_fin_rec.fp_pres_decimalization    := l_original_fin_rec.fp_pres_decimalization;

        l_fin_rec.fp_trans_date             := nvl(l_original_fin_rec.fp_trans_date, l_original_fin_rec.trans_date);
        l_fin_rec.chbck_reason_code         := l_original_fin_rec.chbck_reason_code;
        l_fin_rec.fp_network_proc_date      := nvl(l_original_fin_rec.fp_network_proc_date, l_original_fin_rec.network_proc_date);
        l_fin_rec.iin                       := l_original_fin_rec.iin;
        l_fin_rec.message_seq_number        := 1;
        l_fin_rec.itemized_doc_code         := i_itemized_doc_code;
        l_fin_rec.itemized_doc_ref_number   := i_itemized_doc_ref_number;

        l_fin_rec.transaction_id            := l_original_fin_rec.transaction_id;
        l_fin_rec.ipn                       := l_original_fin_rec.ipn;
        l_fin_rec.is_collection_only        := l_original_fin_rec.is_collection_only;

        o_fin_id := amx_api_fin_message_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_host_id := net_api_network_pkg.get_default_host(
            i_network_id  => l_fin_rec.network_id
        );

        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        amx_api_fin_message_pkg.create_operation (
             i_fin_rec       => l_fin_rec
            , i_standard_id  => l_standard_id
        );

        trc_log_pkg.debug (
            i_text         => 'amx_api_dispute_pkg.gen_retrieval_request end'
        );

    else
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_CANNOT_CREATE_FULFILLMENT'
            , i_env_param1  => i_original_fin_id
        );
    end if;
end;

procedure modify_first_chargeback (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code     default null
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_text       in     com_api_type_pkg.t_name          default null
)is
    l_trans_decimalization  com_api_type_pkg.t_curr_code;
    l_status                com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_first_chargeback start'
    );

    amx_api_fin_message_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    l_trans_decimalization    := com_api_currency_pkg.get_currency_exponent(i_trans_currency);

    update amx_fin_message
       set trans_amount = i_trans_amount
         , trans_currency = i_trans_currency
         , trans_decimalization = l_trans_decimalization
         , reason_code = i_reason_code
         , chbck_reason_text = i_chbck_reason_text
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_trans_amount
      , i_oper_currency => i_trans_currency
    );

    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_first_chargeback end'
    );

end;

procedure modify_second_presentment (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
)is
    l_trans_decimalization  com_api_type_pkg.t_curr_code;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_second_presentment start'
    );

    amx_api_fin_message_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    l_trans_decimalization    := com_api_currency_pkg.get_currency_exponent(i_trans_currency);

    update amx_fin_message
       set trans_amount = i_trans_amount
         , trans_currency = i_trans_currency
         , trans_decimalization = l_trans_decimalization
         , reason_code = i_reason_code
         , itemized_doc_code   = i_itemized_doc_code
         , itemized_doc_ref_number = i_itemized_doc_ref_number
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_trans_amount
      , i_oper_currency => i_trans_currency
    );

    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_second_presentment end'
    );

end;

procedure modify_retrieval_request (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_chbck_reason_code       in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
)is
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_retrieval_request start'
    );

    amx_api_fin_message_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update amx_fin_message
       set func_code  = i_func_code
         , reason_code = i_reason_code
         , chbck_reason_code = i_chbck_reason_code
         , itemized_doc_code   = i_itemized_doc_code
     where id = i_fin_id;

    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_retrieval_request end'
    );
end;

procedure modify_fulfillment (
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_func_code               in     com_api_type_pkg.t_curr_code     default null
  , i_reason_code             in     com_api_type_pkg.t_name          default null
  , i_itemized_doc_code       in     com_api_type_pkg.t_byte_char     default null
  , i_itemized_doc_ref_number in     com_api_type_pkg.t_name          default null
) is
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_fulfillment start'
    );

    amx_api_fin_message_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update amx_fin_message
       set func_code  = i_func_code
         , reason_code = i_reason_code
         , itemized_doc_code   = i_itemized_doc_code
         , itemized_doc_ref_number = i_itemized_doc_ref_number
     where id = i_fin_id;

    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_fulfillment end'
    );
end;

procedure modify_first_presentment_rvs(
    i_fin_id                  in     com_api_type_pkg.t_long_id
  , i_trans_amount            in     com_api_type_pkg.t_money         default null
  , i_trans_currency          in     com_api_type_pkg.t_curr_code     default null
)is
    l_trans_decimalization  com_api_type_pkg.t_curr_code;
begin
    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_first_presentment_rvs start'
    );

    amx_api_fin_message_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    l_trans_decimalization    := com_api_currency_pkg.get_currency_exponent(i_trans_currency);

    update amx_fin_message
       set trans_amount = i_trans_amount
         , trans_currency = i_trans_currency
         , trans_decimalization = l_trans_decimalization
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_trans_amount
      , i_oper_currency => i_trans_currency
    );

    trc_log_pkg.debug (
        i_text         => 'amx_api_dispute_pkg.modify_first_presentment_rvs end'
    );
end;

end;
/

