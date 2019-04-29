create or replace package body nbc_api_fin_message_pkg as

g_column_list           com_api_type_pkg.t_text :=
    'f.id'
||  ', f.split_hash'
||  ', f.status'
||  ', f.mti'
||  ', f.file_id'
||  ', f.record_number'
||  ', f.is_reversal'
||  ', f.is_incoming'
||  ', f.is_invalid'
||  ', f.original_id'
||  ', f.dispute_id'
||  ', f.inst_id'
||  ', f.network_id'
||  ', f.msg_file_type'
||  ', f.participant_type'
||  ', f.record_type'
||  ', f.card_mask'
||  ', f.card_hash'
||  ', f.proc_code'
||  ', f.nbc_resp_code'
||  ', f.acq_resp_code'
||  ', f.iss_resp_code'
||  ', f.bnb_resp_code'
||  ', f.dispute_trans_result'
||  ', f.trans_amount'
||  ', f.sttl_amount'
||  ', f.crdh_bill_amount'
||  ', f.crdh_bill_fee'
||  ', f.settl_rate'
||  ', f.crdh_bill_rate'
||  ', f.system_trace_number'
||  ', f.local_trans_time'
||  ', f.local_trans_date'
||  ', f.settlement_date'
||  ', f.merchant_type'
||  ', f.trans_fee_amount'
||  ', f.acq_inst_code'
||  ', f.iss_inst_code'
||  ', f.bnb_inst_code'
||  ', f.rrn'
||  ', f.auth_number'
||  ', f.resp_code'
||  ', f.terminal_id'
||  ', f.trans_currency'
||  ', f.settl_currency'
||  ', f.crdh_bill_currency'
||  ', f.from_account_id'
||  ', f.to_account_id'
||  ', f.nbc_fee'
||  ', f.acq_fee'
||  ', f.iss_fee'
||  ', f.bnb_fee'
||  ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
||  ', f.add_party_type'
;

function put_message (
    i_fin_rec               in nbc_api_type_pkg.t_nbc_fin_mes_rec
) return com_api_type_pkg.t_long_id
is
    l_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text         => 'nbc_api_fin_message_pkg.put_message start'
    );

    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);
    --l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.card_number);

    insert into nbc_fin_message (
        id
      , split_hash
      , status
      , mti
      , file_id
      , record_number
      , is_reversal
      , is_incoming
      , is_invalid
      , original_id
      , dispute_id
      , inst_id
      , network_id
      , msg_file_type
      , participant_type
      , record_type
      , card_mask
      , card_hash
      , proc_code
      , nbc_resp_code
      , acq_resp_code
      , iss_resp_code
      , bnb_resp_code
      , dispute_trans_result
      , trans_amount
      , sttl_amount
      , crdh_bill_amount
      , crdh_bill_fee
      , settl_rate
      , crdh_bill_rate
      , system_trace_number
      , local_trans_time
      , local_trans_date
      , settlement_date
      , merchant_type
      , trans_fee_amount
      , acq_inst_code
      , iss_inst_code
      , bnb_inst_code
      , rrn
      , auth_number
      , resp_code
      , terminal_id
      , trans_currency
      , settl_currency
      , crdh_bill_currency
      , from_account_id
      , to_account_id
      , nbc_fee
      , acq_fee
      , iss_fee
      , bnb_fee
      , add_party_type
    ) values (
        l_id
      , i_fin_rec.split_hash
      , i_fin_rec.status
      , i_fin_rec.mti
      , i_fin_rec.file_id
      , i_fin_rec.record_number
      , i_fin_rec.is_reversal
      , i_fin_rec.is_incoming
      , i_fin_rec.is_invalid
      , i_fin_rec.original_id
      , i_fin_rec.dispute_id
      , i_fin_rec.inst_id
      , i_fin_rec.network_id
      , i_fin_rec.msg_file_type
      , i_fin_rec.participant_type
      , i_fin_rec.record_type
      , i_fin_rec.card_mask
      , i_fin_rec.card_hash
      , i_fin_rec.proc_code
      , i_fin_rec.nbc_resp_code
      , i_fin_rec.acq_resp_code
      , i_fin_rec.iss_resp_code
      , i_fin_rec.bnb_resp_code
      , i_fin_rec.dispute_trans_result
      , i_fin_rec.trans_amount
      , i_fin_rec.sttl_amount
      , i_fin_rec.crdh_bill_amount
      , i_fin_rec.crdh_bill_fee
      , i_fin_rec.settl_rate
      , i_fin_rec.crdh_bill_rate
      , i_fin_rec.system_trace_number
      , i_fin_rec.local_trans_time
      , i_fin_rec.local_trans_date
      , i_fin_rec.settlement_date
      , i_fin_rec.merchant_type
      , i_fin_rec.trans_fee_amount
      , i_fin_rec.acq_inst_code
      , i_fin_rec.iss_inst_code
      , i_fin_rec.bnb_inst_code
      , i_fin_rec.rrn
      , i_fin_rec.auth_number
      , i_fin_rec.resp_code
      , i_fin_rec.terminal_id
      , i_fin_rec.trans_currency
      , i_fin_rec.settl_currency
      , i_fin_rec.crdh_bill_currency
      , i_fin_rec.from_account_id
      , i_fin_rec.to_account_id
      , i_fin_rec.nbc_fee
      , i_fin_rec.acq_fee
      , i_fin_rec.iss_fee
      , i_fin_rec.bnb_fee
      , i_fin_rec.add_party_type
    );

    insert into nbc_card (
        id
        , card_number
    ) values (
        l_id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] NBC fin messages'
        , i_env_param1  => l_id
    );

    return l_id;
end put_message;

procedure process_auth (
    i_auth_rec              in     aut_api_type_pkg.t_auth_rec
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_status                in     com_api_type_pkg.t_dict_value default null
  , io_fin_mess_id          in out com_api_type_pkg.t_long_id
) is
    TAG_DATE_FORMAT       constant com_api_type_pkg.t_name    := 'yymmddhh24miss';

    l_fin_rec                      nbc_api_type_pkg.t_nbc_fin_mes_rec;
    l_host_id                      com_api_type_pkg.t_tiny_id;
    l_standard_id                  com_api_type_pkg.t_tiny_id;
    l_param_tab                    com_api_type_pkg.t_param_tab;
    l_bank_code                    com_api_type_pkg.t_name;
    l_account_1_type               com_api_type_pkg.t_name;
    l_account_2_type               com_api_type_pkg.t_name;
    l_local_trans_date_time        date;
    l_iss_inst_code_by_pan         com_api_type_pkg.t_name;
    l_count                        com_api_type_pkg.t_tiny_id;
    l_proc_code                    com_api_type_pkg.t_auth_code;
    l_ibft_party_type_algo         com_api_type_pkg.t_dict_value;
    
    function get_mapping_account_type(
        i_account_type    com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name is
    begin
        return
            case i_account_type
                when 1           -- Checking
                then '00'
                when 2           -- Savings
                then '10'
                when 3           -- Credit Card
                then '30'
                else '00'        -- Other
            end;
    end;
begin
    trc_log_pkg.debug(
        i_text       => 'nbc_api_fin_message_pkg.process_auth START'
    );

    -- if transaction has reversal - dont need to create fin message.
    select count(1)
      into l_count
      from opr_operation r
     where r.original_id = io_fin_mess_id
       and r.is_reversal = 1;

    if l_count = 0 then
        l_fin_rec.id           := io_fin_mess_id;
        l_fin_rec.status       := nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
        l_fin_rec.is_incoming  := com_api_type_pkg.FALSE;
        l_fin_rec.is_invalid   := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal  := com_api_type_pkg.FALSE;
        l_fin_rec.inst_id      := nvl(i_inst_id, i_auth_rec.acq_inst_id);
        l_fin_rec.network_id   := nvl(i_network_id, i_auth_rec.iss_network_id);

        -- get network communication standard
        l_host_id              := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
        l_standard_id          := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);

        trc_log_pkg.debug(
            i_text       => 'process_auth: inst_id [#1], network_id [#2], host_id [#3], standard_id [#4]'
          , i_env_param1 => l_fin_rec.inst_id
          , i_env_param2 => l_fin_rec.network_id
          , i_env_param3 => l_host_id
          , i_env_param4 => l_standard_id
        );

        -- record type
        l_fin_rec.original_id         := io_fin_mess_id; --auth.id
        l_fin_rec.record_type         := nbc_api_const_pkg.RECORD_TYPE_DETAIL;
        l_fin_rec.msg_file_type       := 'RF';

        --amounts
        l_fin_rec.trans_amount        := i_auth_rec.oper_request_amount;
        l_fin_rec.trans_currency      := i_auth_rec.oper_currency;
        l_fin_rec.sttl_amount         := null;
        l_fin_rec.settl_currency      := null;
        l_fin_rec.crdh_bill_amount    := null;
        l_fin_rec.crdh_bill_currency  := i_auth_rec.account_currency;
        l_fin_rec.crdh_bill_rate      := i_auth_rec.bin_cnvt_rate;

        -- trace number
        l_fin_rec.system_trace_number := substr(i_auth_rec.system_trace_audit_number, -6);

        l_local_trans_date_time       := to_date(
                                             aup_api_tag_pkg.get_tag_value(
                                                 i_auth_id   => i_auth_rec.id
                                               , i_tag_id    => nbc_api_const_pkg.TAG_LOCAL_TRANS_DATE_TIME
                                             )
                                           , TAG_DATE_FORMAT
                                         );
        l_fin_rec.local_trans_time    := to_char(l_local_trans_date_time, 'HH24MISS');
        l_fin_rec.local_trans_date    := l_local_trans_date_time;
        l_fin_rec.settlement_date     := trunc(i_auth_rec.network_cnvt_date);
        l_fin_rec.rrn                 := substr(nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum), -12);
        l_fin_rec.auth_number         := i_auth_rec.auth_code;

        l_fin_rec.merchant_type       := i_auth_rec.mcc;
        l_fin_rec.terminal_id         := case when length(i_auth_rec.terminal_number) >= 8
                                            then substr(i_auth_rec.terminal_number, -8)
                                            else i_auth_rec.terminal_number
                                         end;
        l_fin_rec.resp_code           := '00';

        if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND then
            l_fin_rec.mti := '0230';
        else
            l_fin_rec.mti := '0210';
        end if;

        l_bank_code := cmn_api_standard_pkg.get_varchar_value(
                           i_inst_id     => l_fin_rec.inst_id
                         , i_standard_id => l_standard_id
                         , i_object_id   => l_host_id
                         , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                         , i_param_name  => nbc_api_const_pkg.NBC_BANK_CODE
                         , i_param_tab   => l_param_tab
                       );
        trc_log_pkg.debug(
            i_text       => 'process_auth: l_bank_code [' || l_bank_code || ']'
        );

        -- card number
        l_fin_rec.card_number         := i_auth_rec.card_number;

        l_fin_rec.card_mask           := iss_api_card_pkg.get_card_mask(l_fin_rec.card_number);
        l_fin_rec.card_hash           := com_api_hash_pkg.get_card_hash(l_fin_rec.card_number);
        l_fin_rec.split_hash          := com_api_hash_pkg.get_split_hash(l_fin_rec.card_number);

        -- fees
        l_fin_rec.acq_fee             := i_auth_rec.oper_surcharge_amount;

        l_fin_rec.iss_fee             := aup_api_tag_pkg.get_tag_value(
                                             i_auth_id   => i_auth_rec.id
                                           , i_tag_id    => nbc_api_const_pkg.TAG_ISS_FEE_AMOUNT
                                         );
        l_fin_rec.nbc_fee             := aup_api_tag_pkg.get_tag_value(
                                             i_auth_id   => i_auth_rec.id
                                           , i_tag_id    => nbc_api_const_pkg.TAG_NBC_FEE_AMOUNT
                                         );
        l_fin_rec.bnb_fee             := aup_api_tag_pkg.get_tag_value(
                                             i_auth_id   => i_auth_rec.id
                                           , i_tag_id    => nbc_api_const_pkg.TAG_BNB_FEE_AMOUNT
                                         );

        l_fin_rec.trans_fee_amount    := nvl(l_fin_rec.acq_fee, 0) +
                                         nvl(l_fin_rec.iss_fee, 0) +
                                         nvl(l_fin_rec.nbc_fee, 0) +
                                         nvl(l_fin_rec.bnb_fee, 0);

        -- accounts
        l_fin_rec.from_account_id     := i_auth_rec.account_number;
        l_fin_rec.to_account_id       := aup_api_tag_pkg.get_tag_value(
                                             i_auth_id   => i_auth_rec.id
                                           , i_tag_id    => nbc_api_const_pkg.TAG_TO_ACCOUNT_NUMBER
                                         );
        -- account_types
        l_account_1_type              := aup_api_tag_pkg.get_tag_value(
                                             i_auth_id      => i_auth_rec.id
                                           , i_tag_id       => nbc_api_const_pkg.TAG_ACCOUNT_1_TYPE
                                         );
        l_account_1_type              := get_mapping_account_type(
                                             i_account_type => l_account_1_type
                                         );
        l_account_2_type              := aup_api_tag_pkg.get_tag_value(
                                             i_auth_id      => i_auth_rec.id
                                           , i_tag_id       => nbc_api_const_pkg.TAG_ACCOUNT_2_TYPE
                                         );
        l_account_2_type              := get_mapping_account_type(
                                             i_account_type => l_account_2_type
                                         );

        -- don't fill
        --      , crdh_bill_fee
        --      , settl_rate

        -- get iss_inst_code by PAN
        begin
            select iss_inst_code
              into l_iss_inst_code_by_pan
              from nbc_iss_inst_code
             where i_auth_rec.card_number between pan_low and pan_high;

        exception
            when no_data_found then
                l_iss_inst_code_by_pan := null;
        end;
        -- Determine role
        -- check ibft parametres on standart. If they are exists, then need to use set_ibft_participant_type
        begin
            cmn_api_standard_pkg.get_param_value(
                i_inst_id     => l_fin_rec.inst_id
              , i_standard_id => l_standard_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id   => l_host_id
              , i_param_name  => nbc_api_const_pkg.PARAM_IBFT_PARTY_TYPE_ALGO
              , i_param_tab   => l_param_tab
              , o_param_value => l_ibft_party_type_algo
            );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'STANDARD_PARAM_NOT_EXISTS' then
                    l_ibft_party_type_algo := null;
                    trc_log_pkg.debug('Standard parameter IBFT_PARTY_TYPE_ALGO is not exists');
                else
                    raise;
                end if;
        end;
        
        if l_ibft_party_type_algo is null then
            -- If ibft parametres on standart are not exists, use old user-exit
            nbc_cst_fin_message_pkg.set_participant_type(
                i_auth_rec              => i_auth_rec
              , i_inst_id               => i_inst_id
              , io_fin_rec              => l_fin_rec
              , i_bank_code             => l_bank_code
              , i_iss_inst_code_by_pan  => l_iss_inst_code_by_pan
            );
        else
  
            set_ibft_participant_type(
                i_auth_rec             => i_auth_rec
              , i_inst_id              => i_inst_id
              , i_host_id              => l_host_id
              , i_standard_id          => l_standard_id
              , io_fin_rec             => l_fin_rec
              , i_bank_code            => l_bank_code
              , i_iss_inst_code_by_pan => l_iss_inst_code_by_pan
              , i_party_algo           => l_ibft_party_type_algo
            );
        end if;

        if l_fin_rec.participant_type is null then
            if i_auth_rec.dst_inst_id is not null
                and i_inst_id = i_auth_rec.dst_inst_id
                and i_auth_rec.dst_card_number is null
                and (i_auth_rec.dst_client_id_value is not null and i_auth_rec.dst_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT)
                and i_auth_rec.dst_account_id is not null
            then
                -- participant type - Destination
                l_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                l_fin_rec.acq_inst_code    := l_bank_code;
                l_fin_rec.bnb_inst_code    := l_bank_code;

            elsif i_inst_id = i_auth_rec.acq_inst_id
                and i_auth_rec.terminal_id is not null
            then
                l_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                l_fin_rec.iss_inst_code    := l_iss_inst_code_by_pan;
                l_fin_rec.acq_inst_code    := l_bank_code;

            elsif i_inst_id = i_auth_rec.iss_inst_id
            then
                l_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                l_fin_rec.iss_inst_code    := l_bank_code;
                l_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;

            end if;
        end if;
        trc_log_pkg.debug(
            i_text       => 'process_auth: participant_type [' || l_fin_rec.participant_type || ']'
        );

        -- proc_code:
        -- if we are not Acquirer - get from tag
        if  l_fin_rec.participant_type != nbc_api_const_pkg.PARTICIPANT_ACQUIRER
            and nvl(l_fin_rec.add_party_type, l_fin_rec.participant_type) != nbc_api_const_pkg.PARTICIPANT_ACQUIRER
        then
            l_proc_code := aup_api_tag_pkg.get_tag_value(
                               i_auth_id  => i_auth_rec.id
                             , i_tag_id   => nbc_api_const_pkg.TAG_PROC_CODE
                           );
            if trim(l_proc_code) is not null then
                trc_log_pkg.debug(
                    i_text       => 'process_auth: l_fin_rec.proc_code from TAG'
                );
                l_fin_rec.proc_code := l_proc_code;
            end if;

        elsif l_fin_rec.proc_code is not null then
            -- ibft trxs - proc_code set before
            l_fin_rec.proc_code  := substr(l_fin_rec.proc_code, 1, 2) || l_account_1_type || l_account_2_type;

            trc_log_pkg.debug(
                i_text       => 'process_auth: l_fin_rec.proc_code for IBFT'
            );

        else
            -- default mapping
            l_fin_rec.proc_code := substr(
                                       net_api_map_pkg.get_network_type(
                                           i_oper_type    => i_auth_rec.oper_type
                                         , i_standard_id  => l_standard_id
                                         , i_mask_error   => com_api_type_pkg.FALSE
                                       )
                                     , 1, 2
                                   );
            l_fin_rec.proc_code := substr(l_fin_rec.proc_code, 1, 2) || l_account_1_type || l_account_2_type;

            trc_log_pkg.debug(
                i_text       => 'process_auth: l_fin_rec.proc_code default mapping'
            );
        end if;

        trc_log_pkg.debug(
            i_text       => 'process_auth: l_fin_rec.proc_code [' || l_fin_rec.proc_code || ']'
        );

        l_fin_rec.id := put_message(i_fin_rec  => l_fin_rec);
    end if;

    trc_log_pkg.debug(
        i_text         => 'nbc_api_fin_message_pkg.process_auth END'
    );
end process_auth;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_participant_type    in com_api_type_pkg.t_dict_value
) is
    l_stmt                  varchar2(4000);
    l_status                com_api_type_pkg.t_dict_value;
    l_index_name            com_api_type_pkg.t_name;
begin

    if i_participant_type = 'DSP' then
        l_status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
        l_index_name := '/*+ INDEX(f, nbc_fin_message_CLMS0040_ndx)*/';
    else
        l_status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        l_index_name := '/*+ INDEX(f, nbc_fin_message_CLMS0010_ndx)*/';
    end if;

    l_stmt := '
        select *
          from (
        select '|| l_index_name ||' '
                || g_column_list||'
        from
            nbc_fin_message f
            , nbc_card c
        where
            decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
            and f.is_incoming      = :is_incoming
            and f.network_id       = :i_network_id
            and f.inst_id          = :i_inst_id
            and f.participant_type = :i_participant_type
            and f.is_reversal      = 0
            and c.id(+) = f.id ';

    l_stmt := l_stmt ||'
        union all
        select '|| l_index_name ||' '
                || g_column_list||'
        from
            nbc_fin_message f
            , nbc_card c
        where
            decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
            and f.is_incoming      = :is_incoming
            and f.network_id       = :i_network_id
            and f.inst_id          = :i_inst_id
            and f.add_party_type   = :i_participant_type
            and f.is_reversal      = 0
            and c.id(+) = f.id
            ) f ';

    l_stmt := l_stmt ||' order by f.id';

    trc_log_pkg.debug(
        i_text          => 'l_stmt= [' || l_stmt || ']'
    );

    open o_fin_cur for l_stmt using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_participant_type, com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_participant_type;

end enum_messages_for_upload;

function estimate_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_participant_type    in com_api_type_pkg.t_dict_value
) return number is
    l_stmt                  varchar2(4000);
    l_result                number;
    l_status                com_api_type_pkg.t_dict_value;
    l_index_name            com_api_type_pkg.t_name;
begin

    if i_participant_type = 'DSP' then
        l_status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
        l_index_name := '/*+ INDEX(f, nbc_fin_message_CLMS0040_ndx)*/';
    else
        l_status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        l_index_name := '/*+ INDEX(f, nbc_fin_message_CLMS0010_ndx)*/';
    end if;

    l_stmt := '
        select sum(cnt)
          from (
            select ' || l_index_name ||
             ' count(f.id) cnt
            from
                nbc_fin_message f
                , nbc_card c
            where
                decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
                and f.is_incoming  = :is_incoming
                and f.network_id   = :i_network_id
                and f.inst_id      = :i_inst_id
                and f.is_reversal  = 0
                and c.id(+) = f.id ';

    if i_participant_type is not null then

        l_stmt := l_stmt || ' and f.participant_type = :i_participant_type';

        l_stmt := l_stmt || '
            union all
            select ' || l_index_name ||
             ' count(f.id) cnt
            from
                nbc_fin_message f
                , nbc_card c
            where
                decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
                and f.is_incoming      = :is_incoming
                and f.network_id       = :i_network_id
                and f.inst_id          = :i_inst_id
                and f.add_party_type   = :i_participant_type
                and f.is_reversal      = 0
                and c.id(+) = f.id
                )';

        trc_log_pkg.debug(
            i_text          => 'l_stmt= [' || l_stmt || ']'
        );

        execute immediate l_stmt into l_result using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_participant_type, com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_participant_type;
    else
        l_stmt :=  l_stmt || ')';

        trc_log_pkg.debug(
            i_text          => 'l_stmt= [' || l_stmt || ']'
        );

        execute immediate l_stmt into l_result using com_api_type_pkg.FALSE, i_network_id, i_inst_id;
    end if;

    return l_result;

end estimate_messages_for_upload;

procedure change_dispute_result (
    i_id                    in com_api_type_pkg.t_long_id
    , i_result              in com_api_type_pkg.t_dict_value
) is
begin
    update nbc_fin_message
       set dispute_trans_result = i_result
         , is_incoming          = com_api_type_pkg.FALSE
     where id = i_id;

    trc_log_pkg.debug(
        i_text          => 'Updated [' || sql%rowcount || '] records'
    );

end;

procedure set_ibft_participant_type(
    i_auth_rec              in            aut_api_type_pkg.t_auth_rec
  , i_inst_id               in            com_api_type_pkg.t_inst_id
  , i_host_id               in            com_api_type_pkg.t_tiny_id
  , i_standard_id           in            com_api_type_pkg.t_tiny_id
  , io_fin_rec              in out nocopy nbc_api_type_pkg.t_nbc_fin_mes_rec
  , i_bank_code             in            com_api_type_pkg.t_name
  , i_iss_inst_code_by_pan  in            com_api_type_pkg.t_name
  , i_party_algo            in            com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX                   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_participant_type ';
    l_receiving_inst_code                 com_api_type_pkg.t_name;

    l_ibft_transfer_optp                  com_api_type_pkg.t_dict_value;
    l_ibft_atm_optp                       com_api_type_pkg.t_dict_value;
    l_ibft_atm_payment_optp               com_api_type_pkg.t_dict_value;
    l_ibft_p2p_optp                       com_api_type_pkg.t_dict_value;
    l_param_tab                           com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'inst_id [#1], host_id [#2], standard_id [#3]'
                      || ', bank_code [#4], i_iss_inst_code_by_pan [#5], i_party_algo [#6]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_host_id
      , i_env_param3  => i_standard_id
      , i_env_param4  => i_bank_code
      , i_env_param5  => i_iss_inst_code_by_pan
      , i_env_param6  => i_party_algo
    );

    -- get parameter values
    cmn_api_standard_pkg.get_param_value(
        i_inst_id     => io_fin_rec.inst_id
      , i_standard_id => i_standard_id
      , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id   => i_host_id
      , i_param_name  => nbc_api_const_pkg.PARAM_IBFT_TRANSFER_OPTP
      , i_param_tab   => l_param_tab
      , o_param_value => l_ibft_transfer_optp
    );

    cmn_api_standard_pkg.get_param_value(
        i_inst_id     => io_fin_rec.inst_id
      , i_standard_id => i_standard_id
      , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id   => i_host_id
      , i_param_name  => nbc_api_const_pkg.PARAM_IBFT_ATM_OPTP
      , i_param_tab   => l_param_tab
      , o_param_value => l_ibft_atm_optp
    );
    
    cmn_api_standard_pkg.get_param_value(
        i_inst_id     => io_fin_rec.inst_id
      , i_standard_id => i_standard_id
      , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id   => i_host_id
      , i_param_name  => nbc_api_const_pkg.PARAM_IBFT_ATM_PAYMENT_OPTP
      , i_param_tab   => l_param_tab
      , o_param_value => l_ibft_atm_payment_optp
    );

    cmn_api_standard_pkg.get_param_value(
        i_inst_id     => io_fin_rec.inst_id
      , i_standard_id => i_standard_id
      , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id   => i_host_id
      , i_param_name  => nbc_api_const_pkg.PARAM_IBFT_P2P_OPTP
      , i_param_tab   => l_param_tab
      , o_param_value => l_ibft_p2p_optp
    );
    
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'l_ibft_transfer_optp [#1], l_ibft_atm_optp [#2], l_ibft_atm_payment_optp [#3]'
                      || ', l_ibft_p2p_optp [#4]'
      , i_env_param1  => l_ibft_transfer_optp
      , i_env_param2  => l_ibft_atm_optp
      , i_env_param3  => l_ibft_atm_payment_optp
      , i_env_param4  => l_ibft_p2p_optp
    );
 
    --l_ibft_p2p_optp - in Acleda OPTP0689:
    --ACQ = 1001, ISS # 1001 => ACQ
    --ACQ # 1001, ISS = 1001 => ISS, BNB
    
    --l_ibft_transfer_optp - in Acleda OPTP0610:
    --ACQ = 1001, ISS # 1001 => ACQ, BNB
    --ACQ # 1001, ISS = 1001 => ISS
    --ACQ # 1001, ISS # 1001 => BNB
    
    --l_ibft_atm_payment_optp - in Acleda OPTP0621:
    --ACQ = 1001, ISS = 1001 => ISS, ACQ
    --ACQ # 1001, ISS # 1001 => BNB
    
    --l_ibft_atm_optp - in Acleda OPTP0613:
    --ACQ = 1001, ISS # 1001 => ACQ

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || '<< oper_type [#1], acq_inst_id [#2], iss_inst_id [#3]'
                      || ', i_inst_id [#4], i_iss_inst_code_by_pan [#5], i_bank_code [#6]'
      , i_env_param1  => i_auth_rec.oper_type
      , i_env_param2  => i_auth_rec.acq_inst_id
      , i_env_param3  => i_auth_rec.iss_inst_id
      , i_env_param4  => i_inst_id
      , i_env_param5  => i_iss_inst_code_by_pan
      , i_env_param6  => i_bank_code
    );

    l_receiving_inst_code := trim(
                                 aup_api_tag_pkg.get_tag_value(
                                     i_auth_id   => i_auth_rec.id
                                   , i_tag_id    => nbc_api_const_pkg.TAG_RECEIVING_INST_CODE
                                 )
                             );
    trc_log_pkg.debug(
        i_text        => 'l_receiving_inst_code [#1]'
      , i_env_param1  => l_receiving_inst_code
    );
    
    if i_party_algo = 'NBCADFLT' then

        case i_auth_rec.oper_type

            when l_ibft_p2p_optp then
                if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                    io_fin_rec.proc_code        := '40';
                    io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                    io_fin_rec.acq_inst_code    := i_bank_code;
                    io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

                elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id = i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                    io_fin_rec.add_party_type   := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                    io_fin_rec.iss_inst_code    := i_bank_code;
                    io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                    io_fin_rec.bnb_inst_code    := i_bank_code;

                end if;

            when l_ibft_transfer_optp then
                if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                    io_fin_rec.add_party_type   := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                    io_fin_rec.proc_code        := '41';
                    io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                    io_fin_rec.acq_inst_code    := i_bank_code;
                    io_fin_rec.bnb_inst_code    := i_bank_code;

                elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id = i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                    io_fin_rec.iss_inst_code    := i_bank_code;
                    io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                    io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

                    if i_auth_rec.acq_inst_bin = l_receiving_inst_code then
                        null;
                    else
                        io_fin_rec.mti       := '0230';
                    end if;

                elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                    io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                    io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                    io_fin_rec.bnb_inst_code    := i_bank_code;

                end if;

            when l_ibft_atm_payment_optp then
                if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id = i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                    io_fin_rec.add_party_type   := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                    io_fin_rec.proc_code        := '42';
                    io_fin_rec.mti              := '0230';
                    io_fin_rec.iss_inst_code    := i_bank_code;
                    io_fin_rec.acq_inst_code    := i_bank_code;
                    io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

                elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                    io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                    io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;

                    if i_bank_code = l_receiving_inst_code then
                        io_fin_rec.bnb_inst_code    := l_receiving_inst_code;
                    else
                        io_fin_rec.bnb_inst_code    := i_bank_code;
                    end if;

                end if;

            when l_ibft_atm_optp then
                if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                    io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                    io_fin_rec.proc_code        := '48';
                    io_fin_rec.mti              := '0230';
                    io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                    io_fin_rec.acq_inst_code    := i_bank_code;
                    io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

                end if;

            else
                null;
        end case;

        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || '>> io_fin_rec = {participant_type [#1], proc_code [#2], mti [#3]'
                                        || ', acq_inst_code [#4], iss_inst_code [#5], bnb_inst_code [#6]}'
          , i_env_param1  => io_fin_rec.participant_type
          , i_env_param2  => io_fin_rec.proc_code
          , i_env_param3  => io_fin_rec.mti
          , i_env_param4  => io_fin_rec.acq_inst_code
          , i_env_param5  => io_fin_rec.iss_inst_code
          , i_env_param6  => io_fin_rec.bnb_inst_code
        );
    else --for future use can be created others algorithms
        null;
    end if;
end;

end;
/
