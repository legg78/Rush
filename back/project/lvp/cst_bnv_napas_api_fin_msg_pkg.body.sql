create or replace package body cst_bnv_napas_api_fin_msg_pkg as

function get_original_id(
    i_fin_rec              in     cst_bnv_napas_api_type_pkg.t_bnv_napas_fin_mes_rec
) return com_api_type_pkg.t_long_id
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_original_id: ';
    l_original_id                 com_api_type_pkg.t_long_id;
begin
    select o.id
      into l_original_id
      from opr_operation o
     where o.dispute_id = i_fin_rec.dispute_id
       and o.id        != i_fin_rec.id;

    trc_log_pkg.debug(
        i_text         => LOG_PREFIX || 'Found l_original_id [#1] by dispute_id [#2] excluding id [#3]'
      , i_env_param1   => l_original_id
      , i_env_param2   => i_fin_rec.dispute_id
      , i_env_param3   => i_fin_rec.id
    );

    return l_original_id;

exception
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'ORIGINAL_DISPUTE_OPERATION_IS_NOT_FOUND'
          , i_env_param1 => i_fin_rec.dispute_id
          , i_env_param2 => i_fin_rec.id
        );
end get_original_id;

function put_message(
    i_fin_rec              in     cst_bnv_napas_api_type_pkg.t_bnv_napas_fin_mes_rec
) return com_api_type_pkg.t_long_id
is
    l_id                          com_api_type_pkg.t_long_id;
    l_fin_mes_count               com_api_type_pkg.t_short_id;
    l_card_number                 com_api_type_pkg.t_card_number;
begin

    l_card_number := iss_api_token_pkg.encode_card_number(
                         i_card_number => i_fin_rec.card_number
                     );

    select count(*)
      into l_fin_mes_count
      from cst_bnv_napas_fin_msg m
         , cst_bnv_napas_card c
     where m.status = cst_bnv_napas_api_const_pkg.MSG_STATUS_LOADED
       and m.id = c.id
       and (m.mti                 = i_fin_rec.mti                or m.mti                is null and i_fin_rec.mti                is null)
       and (m.trans_code          = i_fin_rec.trans_code         or m.trans_code         is null and i_fin_rec.trans_code         is null)
       and (m.service_code        = i_fin_rec.service_code       or m.service_code       is null and i_fin_rec.service_code       is null)
       and (m.channel_code        = i_fin_rec.channel_code       or m.channel_code       is null and i_fin_rec.channel_code       is null)
       and (m.oper_amount         = i_fin_rec.oper_amount        or m.oper_amount        is null and i_fin_rec.oper_amount        is null)
       and (m.real_amount         = i_fin_rec.real_amount        or m.real_amount        is null and i_fin_rec.real_amount        is null)
       and (m.oper_currency       = i_fin_rec.oper_currency      or m.oper_currency      is null and i_fin_rec.oper_currency      is null)
       and (m.sttl_amount         = i_fin_rec.sttl_amount        or m.sttl_amount        is null and i_fin_rec.sttl_amount        is null)
       and (m.sttl_currency       = i_fin_rec.sttl_currency      or m.sttl_currency      is null and i_fin_rec.sttl_currency      is null)
       and (m.sttl_exchange_rate  = i_fin_rec.sttl_exchange_rate or m.sttl_exchange_rate is null and i_fin_rec.sttl_exchange_rate is null)
       and (m.bill_amount         = i_fin_rec.bill_amount        or m.bill_amount        is null and i_fin_rec.bill_amount        is null)
       and (m.bill_real_amount    = i_fin_rec.bill_real_amount   or m.bill_real_amount   is null and i_fin_rec.bill_real_amount   is null)
       and (m.bill_currency       = i_fin_rec.bill_currency      or m.bill_currency      is null and i_fin_rec.bill_currency      is null)
       and (m.bill_exchange_rate  = i_fin_rec.bill_exchange_rate or m.bill_exchange_rate is null and i_fin_rec.bill_exchange_rate is null)
       and (m.sys_trace_number    = i_fin_rec.sys_trace_number   or m.sys_trace_number   is null and i_fin_rec.sys_trace_number   is null)
       and m.trans_date           = i_fin_rec.trans_date
       and m.sttl_date            = i_fin_rec.sttl_date
       and (m.mcc                 = i_fin_rec.mcc                or m.mcc                is null and i_fin_rec.mcc                is null)
       and (m.pos_entry_mode      = i_fin_rec.pos_entry_mode     or m.pos_entry_mode     is null and i_fin_rec.pos_entry_mode     is null)
       and (m.pos_condition_code  = i_fin_rec.pos_condition_code or m.pos_condition_code is null and i_fin_rec.pos_condition_code is null)
       and (m.terminal_number     = i_fin_rec.terminal_number    or m.terminal_number    is null and i_fin_rec.terminal_number    is null)
       and (m.acq_inst_bin        = i_fin_rec.acq_inst_bin       or m.acq_inst_bin       is null and i_fin_rec.acq_inst_bin       is null)
       and (m.iss_inst_bin        = i_fin_rec.iss_inst_bin       or m.iss_inst_bin       is null and i_fin_rec.iss_inst_bin       is null)
       and (m.merchant_number     = i_fin_rec.merchant_number    or m.merchant_number    is null and i_fin_rec.merchant_number    is null)
       and (m.bnb_inst_bin        = i_fin_rec.bnb_inst_bin       or m.bnb_inst_bin       is null and i_fin_rec.bnb_inst_bin       is null)
       and (m.src_account_number  = i_fin_rec.src_account_number or m.src_account_number is null and i_fin_rec.src_account_number is null)
       and (m.dst_account_number  = i_fin_rec.dst_account_number or m.dst_account_number is null and i_fin_rec.dst_account_number is null)
       and (m.iss_fee_napas       = i_fin_rec.iss_fee_napas      or m.iss_fee_napas      is null and i_fin_rec.iss_fee_napas      is null)
       and (m.iss_fee_acq         = i_fin_rec.iss_fee_acq        or m.iss_fee_acq        is null and i_fin_rec.iss_fee_acq        is null)
       and (m.iss_fee_bnb         = i_fin_rec.iss_fee_bnb        or m.iss_fee_bnb        is null and i_fin_rec.iss_fee_bnb        is null)
       and (m.acq_fee_napas       = i_fin_rec.acq_fee_napas      or m.acq_fee_napas      is null and i_fin_rec.acq_fee_napas      is null)
       and (m.acq_fee_iss         = i_fin_rec.acq_fee_iss        or m.acq_fee_iss        is null and i_fin_rec.acq_fee_iss        is null)
       and (m.acq_fee_bnb         = i_fin_rec.acq_fee_bnb        or m.acq_fee_bnb        is null and i_fin_rec.acq_fee_bnb        is null)
       and (m.bnb_fee_napas       = i_fin_rec.bnb_fee_napas      or m.bnb_fee_napas      is null and i_fin_rec.bnb_fee_napas      is null)
       and (m.bnb_fee_acq         = i_fin_rec.bnb_fee_acq        or m.bnb_fee_acq        is null and i_fin_rec.bnb_fee_acq        is null)
       and (m.bnb_fee_iss         = i_fin_rec.bnb_fee_iss        or m.bnb_fee_iss        is null and i_fin_rec.bnb_fee_iss        is null)
       and (m.rrn                 = i_fin_rec.rrn                or m.rrn                is null and i_fin_rec.rrn                is null)
       and (m.auth_code           = i_fin_rec.auth_code          or m.auth_code          is null and i_fin_rec.auth_code          is null)
       and (m.transaction_id      = i_fin_rec.transaction_id     or m.transaction_id     is null and i_fin_rec.transaction_id     is null)
       and (m.resp_code           = i_fin_rec.resp_code          or m.resp_code          is null and i_fin_rec.resp_code          is null)
       and m.is_dispute           = i_fin_rec.is_dispute
       and reverse(c.card_number) = reverse(l_card_number);

    if l_fin_mes_count = 0 then      
        l_id := coalesce(i_fin_rec.id, opr_api_create_pkg.get_id);

        insert into cst_bnv_napas_fin_msg(
            id
          , mti
          , trans_code
          , service_code
          , channel_code
          , oper_amount
          , real_amount
          , oper_currency
          , sttl_amount
          , sttl_currency
          , sttl_exchange_rate
          , bill_amount
          , bill_real_amount
          , bill_currency
          , bill_exchange_rate
          , sys_trace_number
          , trans_date
          , sttl_date
          , mcc
          , pos_entry_mode
          , pos_condition_code
          , terminal_number
          , acq_inst_bin
          , iss_inst_bin
          , merchant_number
          , bnb_inst_bin
          , src_account_number
          , dst_account_number
          , iss_fee_napas
          , iss_fee_acq
          , iss_fee_bnb
          , acq_fee_napas
          , acq_fee_iss
          , acq_fee_bnb
          , bnb_fee_napas
          , bnb_fee_acq
          , bnb_fee_iss
          , rrn
          , auth_code
          , transaction_id
          , resp_code
          , is_dispute
          , status
          , file_id
          , record_number
          , is_reversal
        ) values (
            l_id
          , i_fin_rec.mti
          , i_fin_rec.trans_code
          , i_fin_rec.service_code
          , i_fin_rec.channel_code
          , i_fin_rec.oper_amount
          , i_fin_rec.real_amount
          , i_fin_rec.oper_currency
          , i_fin_rec.sttl_amount
          , i_fin_rec.sttl_currency
          , i_fin_rec.sttl_exchange_rate
          , i_fin_rec.bill_amount
          , i_fin_rec.bill_real_amount
          , i_fin_rec.bill_currency
          , i_fin_rec.bill_exchange_rate
          , i_fin_rec.sys_trace_number
          , i_fin_rec.trans_date
          , i_fin_rec.sttl_date
          , i_fin_rec.mcc
          , i_fin_rec.pos_entry_mode
          , i_fin_rec.pos_condition_code
          , i_fin_rec.terminal_number
          , i_fin_rec.acq_inst_bin
          , i_fin_rec.iss_inst_bin
          , i_fin_rec.merchant_number
          , i_fin_rec.bnb_inst_bin
          , i_fin_rec.src_account_number
          , i_fin_rec.dst_account_number
          , i_fin_rec.iss_fee_napas
          , i_fin_rec.iss_fee_acq
          , i_fin_rec.iss_fee_bnb
          , i_fin_rec.acq_fee_napas
          , i_fin_rec.acq_fee_iss
          , i_fin_rec.acq_fee_bnb
          , i_fin_rec.bnb_fee_napas
          , i_fin_rec.bnb_fee_acq
          , i_fin_rec.bnb_fee_iss
          , i_fin_rec.rrn
          , i_fin_rec.auth_code
          , i_fin_rec.transaction_id
          , i_fin_rec.resp_code
          , i_fin_rec.is_dispute
          , i_fin_rec.status
          , i_fin_rec.file_id
          , i_fin_rec.record_number
          , i_fin_rec.is_reversal
        );

        insert into cst_bnv_napas_card(
            id
          , card_number
        ) values (
            l_id
          , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
        );

        trc_log_pkg.debug(
            i_text        => 'put_message >> fin. message ID [#1]'
          , i_env_param1  => l_id
        );

        return l_id;
    else
        return null;
    end if;
end put_message;

procedure create_operation(
    i_fin_rec              in     cst_bnv_napas_api_type_pkg.t_bnv_napas_fin_mes_rec
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
  , i_status               in     com_api_type_pkg.t_dict_value                 default null
  , i_create_disp_case     in     com_api_type_pkg.t_boolean                    default com_api_const_pkg.FALSE
  , i_incom_sess_file_id   in     com_api_type_pkg.t_long_id                    default null
) is
    l_iss_inst_id                 com_api_type_pkg.t_inst_id;
    l_acq_inst_id                 com_api_type_pkg.t_inst_id;
    l_card_inst_id                com_api_type_pkg.t_inst_id;
    l_iss_network_id              com_api_type_pkg.t_network_id;
    l_acq_network_id              com_api_type_pkg.t_network_id;
    l_card_network_id             com_api_type_pkg.t_network_id;
    l_card_type_id                com_api_type_pkg.t_tiny_id;
    l_card_country                com_api_type_pkg.t_country_code;
    l_bin_currency                com_api_type_pkg.t_curr_code;
    l_sttl_currency               com_api_type_pkg.t_curr_code;
    l_country_code                com_api_type_pkg.t_country_code;
    l_sttl_type                   com_api_type_pkg.t_dict_value;
    l_match_status                com_api_type_pkg.t_dict_value;

    l_oper                        opr_api_type_pkg.t_oper_rec;
    l_iss_part                    opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                    opr_api_type_pkg.t_oper_part_rec;

    l_operation                   opr_api_type_pkg.t_oper_rec;
    l_participant                 opr_api_type_pkg.t_oper_part_rec;
    l_need_sttl_type              com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    l_oper.id := i_fin_rec.id;
    if l_oper.id is null then
        l_oper.id := opr_api_create_pkg.get_id;
    end if;
    if i_status is not null then
        l_oper.status := i_status;
    end if;

    if i_fin_rec.is_dispute = com_api_const_pkg.TRUE then
        l_oper.original_id :=
            get_original_id(
                i_fin_rec => i_fin_rec
            );
        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_oper.original_id
          , o_operation => l_operation
        );

        l_sttl_type := l_operation.sttl_type;

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
            i_card_number      => i_fin_rec.card_number
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

    l_oper.oper_type :=
        net_api_map_pkg.get_oper_type(
            i_network_oper_type => i_fin_rec.trans_code
          , i_standard_id       => i_standard_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    if l_need_sttl_type = com_api_type_pkg.TRUE then
        net_api_sttl_pkg.get_sttl_type(
            i_iss_inst_id      => l_iss_inst_id
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
    l_oper.msg_type  := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;

    l_oper.is_reversal        := i_fin_rec.is_reversal;
    l_oper.oper_amount        := i_fin_rec.oper_amount;
    l_oper.oper_currency      := i_fin_rec.oper_currency;
    l_oper.sttl_amount        := i_fin_rec.sttl_amount;
    l_oper.sttl_currency      := i_fin_rec.sttl_currency;
    l_oper.oper_date          := i_fin_rec.trans_date;
    l_oper.host_date          := null;

    if l_oper.terminal_type is null then
        l_oper.terminal_type :=
        case i_fin_rec.mcc
            when cst_bnv_napas_api_const_pkg.MCC_ATM
            then acq_api_const_pkg.TERMINAL_TYPE_ATM
            else acq_api_const_pkg.TERMINAL_TYPE_POS
        end;
    end if;

    l_oper.mcc                := i_fin_rec.mcc;
    l_oper.originator_refnum  := i_fin_rec.rrn;
    l_oper.acq_inst_bin       := i_fin_rec.acq_inst_bin;
    l_oper.terminal_number    := i_fin_rec.terminal_number;
    l_oper.merchant_number    := i_fin_rec.merchant_number;
    l_oper.dispute_id         := i_fin_rec.dispute_id;
    l_oper.match_status       := l_match_status;
    l_oper.original_id        := l_oper.original_id;
    l_oper.incom_sess_file_id := i_incom_sess_file_id;

    l_iss_part.inst_id         := l_iss_inst_id;
    l_iss_part.network_id      := l_iss_network_id;
    l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value := i_fin_rec.card_number;
    l_iss_part.customer_id     := iss_api_card_pkg.get_customer_id(i_card_number => i_fin_rec.card_number);
    l_iss_part.card_id         := iss_api_card_pkg.get_card_id(i_fin_rec.card_number);
    l_iss_part.card_type_id    := l_card_type_id;

    begin
        select expir_date
             , seq_number
          into l_iss_part.card_expir_date
             , l_iss_part.card_seq_number
          from (select i.expir_date, i.seq_number
                  from iss_card_vw c
                     , iss_card_instance i
                 where c.id = l_iss_part.card_id
                   and c.id = i.card_id
              order by i.seq_number desc
       ) where rownum = 1;
    exception
        when no_data_found then
            l_iss_part.card_expir_date := null;
            l_iss_part.card_seq_number := null;
    end;

    l_iss_part.card_number       := i_fin_rec.card_number;
    l_iss_part.card_mask         := iss_api_card_pkg.get_card_mask(i_fin_rec.card_number);
    l_iss_part.card_country      := l_card_country;
    l_iss_part.card_inst_id      := l_card_inst_id;
    l_iss_part.card_network_id   := l_card_network_id;
    l_iss_part.account_id        := null;
    l_iss_part.account_number    := null;
    l_iss_part.account_amount    := null;
    l_iss_part.account_currency  := null;
    l_iss_part.auth_code         := i_fin_rec.auth_code;

    l_acq_part.inst_id           := l_acq_inst_id;
    l_acq_part.network_id        := l_acq_network_id;

    opr_api_create_pkg.create_operation(
        i_oper      => l_oper
      , i_iss_part  => l_iss_part
      , i_acq_part  => l_acq_part
    );
end create_operation;

end;
/
