create or replace package body cup_prc_incoming_pkg as

g_error_flag        com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;

procedure process_file_header(
    i_header_data           in     varchar2
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id
  , i_inst_name             in     com_api_type_pkg.t_name
  , i_host_id               in     com_api_type_pkg.t_tiny_id
  , o_cup_file                 out cup_api_type_pkg.t_cup_file_rec
  , i_session_file_id       in     com_api_type_pkg.t_long_id
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_file_header';
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': START with i_dst_inst_id [#1], i_inst_name [#2]'
      , i_env_param1  => i_dst_inst_id
      , i_env_param2  => i_inst_name
    );

    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_NETWORK'
            , i_env_param1  => i_network_id
        );
    end if;

    o_cup_file.is_incoming         := com_api_const_pkg.TRUE;
    o_cup_file.is_rejected         := com_api_const_pkg.FALSE;
    o_cup_file.network_id          := i_network_id;
    o_cup_file.trans_date          := get_sysdate;
    o_cup_file.inst_name           := i_inst_name;

    --search inst_id of inst_name
    o_cup_file.inst_id := i_dst_inst_id;
    if o_cup_file.inst_id is null then

        o_cup_file.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id         => i_standard_id
            , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id         => i_host_id
            , i_param_name        => cup_api_const_pkg.CUP_ACQUIRER_NAME
            , i_value_char        => i_inst_name
        );

        if o_cup_file.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'CUP_INSTITUTION_NOT_FOUND'
                , i_env_param1  => i_inst_name
                , i_env_param2  => i_network_id
            );
        end if;

    end if;

    if substr(i_header_data, 35, 4) = 'TEST' then
        o_cup_file.action_code := '1';
    else
        o_cup_file.action_code := '0';
    end if;

    trc_log_pkg.debug(
        i_text        => 'o_cup_file.action_code [#1], i_action_code [#2]'
      , i_env_param1  => o_cup_file.action_code
      , i_env_param2  => i_action_code
    );

    if nvl(i_action_code, '0') != nvl(o_cup_file.action_code, '0') then
        com_api_error_pkg.raise_error(
            i_error       => 'CMP_WRONG_TEST_OPTION_PARAMETER'
          , i_env_param1  => i_action_code
          , i_env_param2  => o_cup_file.action_code
        );
    end if;

    o_cup_file.file_number     := 0;
    o_cup_file.pack_no         := null;
    o_cup_file.version         := substr(i_header_data, 39, 8);
    o_cup_file.encoding        := null;
    o_cup_file.file_type       := null;
    o_cup_file.session_file_id := i_session_file_id;
    o_cup_file.id              := cup_file_seq.nextval;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': FINISH o_cup_file.id [#1]'
      , i_env_param1  => o_cup_file.id
    );
end process_file_header;

procedure process_dispute_file_header(
    i_header_data           in varchar2
  , i_network_id            in com_api_type_pkg.t_tiny_id
  , i_action_code           in com_api_type_pkg.t_curr_code
  , i_dst_inst_id           in com_api_type_pkg.t_inst_id
  , i_file_type             in com_api_type_pkg.t_name
  , o_cup_file             out cup_api_type_pkg.t_cup_file_rec
  , i_session_file_id       in com_api_type_pkg.t_long_id
  , i_use_sysdate           in com_api_type_pkg.t_boolean
) is
begin
    trc_log_pkg.debug (
        i_text          => 'process_dispute_file_header start'
    );

    if i_network_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'UNKNOWN_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;

    o_cup_file.is_incoming     := com_api_const_pkg.TRUE;
    o_cup_file.is_rejected     := com_api_const_pkg.FALSE;
    o_cup_file.network_id      := i_network_id;

    if i_use_sysdate = com_api_const_pkg.TRUE then
        o_cup_file.trans_date  := com_api_sttl_day_pkg.get_sysdate;
    else
        o_cup_file.trans_date  := to_date(substr(i_header_data, 74, 8), 'yyyymmdd');
    end if;

    o_cup_file.inst_id         := i_dst_inst_id;
    o_cup_file.action_code     := i_action_code;
    o_cup_file.file_number     := 0;
    o_cup_file.pack_no         := null;
    o_cup_file.version         := null;
    o_cup_file.encoding        := null;
    o_cup_file.file_type       := i_file_type;
    o_cup_file.session_file_id := i_session_file_id;
    o_cup_file.id              := cup_file_seq.nextval;

    trc_log_pkg.debug (
        i_text          => 'process_dispute_file_header end. o_cup_file.id [#1]'
      , i_env_param1    => o_cup_file.id
    );
end process_dispute_file_header;

procedure process_file_trailer (
    i_trailer_data          in      varchar2
  , io_cup_file             in  out cup_api_type_pkg.t_cup_file_rec
) is
    l_trans_record_number           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'process_file_trailer start'
    );

    l_trans_record_number := substr(i_trailer_data, 8, 10);

    trc_log_pkg.debug (
        i_text          => 'l_trans_record_number [#1]'
      , i_env_param1    => l_trans_record_number
    );

    insert into cup_file (
        id
        , is_incoming
        , is_rejected
        , network_id
        , trans_date
        , inst_id
        , inst_name
        , action_code
        , file_number
        , pack_no
        , version
        , crc
        , encoding
        , file_type
        , session_file_id
    )
    values(
        io_cup_file.id
        , io_cup_file.is_incoming
        , io_cup_file.is_rejected
        , io_cup_file.network_id
        , io_cup_file.trans_date
        , io_cup_file.inst_id
        , io_cup_file.inst_name
        , io_cup_file.action_code
        , io_cup_file.file_number
        , io_cup_file.pack_no
        , io_cup_file.version
        , io_cup_file.crc
        , io_cup_file.encoding
        , io_cup_file.file_type
        , io_cup_file.session_file_id
    );
    trc_log_pkg.debug (
        i_text          => 'process_file_trailer end'
    );
end process_file_trailer;

procedure process_dispute_file_trailer (
    i_trailer_data          in      varchar2
    , io_cup_file           in  out cup_api_type_pkg.t_cup_file_rec
) is
    l_trans_record_number           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'process_file_trailer start'
    );

    l_trans_record_number := substr(i_trailer_data, 82, 6);

    trc_log_pkg.debug (
        i_text          => 'l_trans_record_number [#1]'
      , i_env_param1    => l_trans_record_number
    );

    insert into cup_file (
        id
        , is_incoming
        , is_rejected
        , network_id
        , trans_date
        , inst_id
        , inst_name
        , action_code
        , file_number
        , pack_no
        , version
        , crc
        , encoding
        , file_type
        , session_file_id
    )
    values(
        io_cup_file.id
        , io_cup_file.is_incoming
        , io_cup_file.is_rejected
        , io_cup_file.network_id
        , io_cup_file.trans_date
        , io_cup_file.inst_id
        , io_cup_file.inst_name
        , io_cup_file.action_code
        , io_cup_file.file_number
        , io_cup_file.pack_no
        , io_cup_file.version
        , io_cup_file.crc
        , io_cup_file.encoding
        , io_cup_file.file_type
        , io_cup_file.session_file_id
    );
    trc_log_pkg.debug (
        i_text          => 'process_dispute_file_trailer end'
    );
end process_dispute_file_trailer;

function date_yymm (
    i_date                  in varchar2
) return date is
begin
    if i_date is null or i_date = '0000' then
        return null;
    end if;

    return to_date(i_date, 'YYMM');
end date_yymm;

-- This algorithm you can see in the "vis_prc_incoming_pkg.date_mmdd" method also.
function date_without_year (
    i_date                  in com_api_type_pkg.t_name
  , i_filedate              in date
  , i_datemask              in com_api_type_pkg.t_name
) return date is
    YEAR_MASK      constant com_api_type_pkg.t_name := 'YYYY';
    l_datemask              com_api_type_pkg.t_name;
    l_year                  com_api_type_pkg.t_name;
    l_dt                    date;
begin
    if i_date is null or i_date = '0000' then
        return null;
    end if;

    l_datemask := YEAR_MASK || i_datemask;
    l_year     := to_char(i_filedate, YEAR_MASK);
    l_dt       := to_date(l_year || i_date, l_datemask);

    if l_dt > i_filedate then
        l_year := to_char(to_number(l_year) - 1);
        l_dt   := to_date(l_year || i_date, l_datemask);

        if abs(months_between(l_dt, i_filedate)) > 11 then
            l_year := to_char(i_filedate, YEAR_MASK);
            l_dt   := to_date(l_year || i_date, l_datemask);
        end if;
    end if;

    -- if operation date greater than file date then lessen date for a year
    if l_dt > i_filedate then
        l_dt := add_months(l_dt, -12);
    end if;

    return l_dt;
end date_without_year;

procedure create_operation(
    io_cup_fin_rec       in out nocopy  cup_api_type_pkg.t_cup_fin_mes_rec
  , i_standard_id        in             com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id in             com_api_type_pkg.t_long_id
  , i_oper_type          in             com_api_type_pkg.t_dict_value default null
  , i_msg_type           in             com_api_type_pkg.t_dict_value default null
)is
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_network_id        com_api_type_pkg.t_tiny_id;
    l_acq_inst_id           com_api_type_pkg.t_inst_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_country_code          com_api_type_pkg.t_country_code;
    l_bin_currency          com_api_type_pkg.t_curr_code;
    l_sttl_currency         com_api_type_pkg.t_curr_code;
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;

    l_oper                  opr_api_type_pkg.t_oper_rec;
    l_iss_part              opr_api_type_pkg.t_oper_part_rec;
    l_acq_part              opr_api_type_pkg.t_oper_part_rec;
    l_orig_id               com_api_type_pkg.t_long_id;
    l_card                  iss_api_type_pkg.t_card_rec;
begin
    trc_log_pkg.debug (
        i_text          => 'cup_prc_incoming_pkg.create_operation start'
    );

    -- get card inst
    iss_api_bin_pkg.get_bin_info (
        i_card_number      => io_cup_fin_rec.card_number
      , o_iss_inst_id      => l_iss_inst_id
      , o_iss_network_id   => l_iss_network_id
      , o_card_inst_id     => l_card_inst_id
      , o_card_network_id  => l_card_network_id
      , o_card_type        => l_card_type_id
      , o_card_country     => l_country_code
      , o_bin_currency     => l_bin_currency
      , o_sttl_currency    => l_sttl_currency
      , i_raise_error      => com_api_const_pkg.FALSE
    );

    -- if card BIN not found, then mark record as invalid
    if l_card_inst_id is null then
        io_cup_fin_rec.is_invalid := com_api_const_pkg.TRUE;
        l_iss_inst_id             := io_cup_fin_rec.inst_id;
        l_iss_network_id          := ost_api_institution_pkg.get_inst_network(io_cup_fin_rec.inst_id);

        trc_log_pkg.error(
            i_text        => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
          , i_env_param1  => iss_api_card_pkg.get_card_mask(io_cup_fin_rec.card_number)
          , i_env_param2  => substr(io_cup_fin_rec.card_number, 1, 6)
        );
    end if;

    if l_acq_inst_id is null then
        l_acq_network_id := io_cup_fin_rec.network_id;
        l_acq_inst_id    := net_api_network_pkg.get_inst_id(io_cup_fin_rec.network_id);
    end if;

    -- mapping
    if i_oper_type is null then
        l_oper.oper_type :=
            net_api_map_pkg.get_oper_type (
                i_network_oper_type  => io_cup_fin_rec.trans_code || io_cup_fin_rec.trans_category
              , i_standard_id        => i_standard_id
            );
    else
        l_oper.oper_type := i_oper_type;
    end if;

    if l_oper.oper_type is null then
        io_cup_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        io_cup_fin_rec.is_invalid := com_api_const_pkg.TRUE;
        g_error_flag := com_api_const_pkg.TRUE;

        trc_log_pkg.error(
            i_text        => 'UNABLE_DETERMINE_OPER_TYPE'
          , i_env_param1  => io_cup_fin_rec.trans_code
        );
    end if;

    net_api_sttl_pkg.get_sttl_type (
        i_iss_inst_id        => l_iss_inst_id
        , i_acq_inst_id      => l_acq_inst_id
        , i_card_inst_id     => l_card_inst_id
        , i_iss_network_id   => l_iss_network_id
        , i_acq_network_id   => l_acq_network_id
        , i_card_network_id  => l_card_network_id
        , i_acq_inst_bin     => io_cup_fin_rec.acquirer_iin
        , o_sttl_type        => l_sttl_type
        , o_match_status     => l_match_status
        , i_oper_type        => l_oper.oper_type
    );

    l_card := iss_api_card_pkg.get_card(
                  i_card_number   => io_cup_fin_rec.card_number
                  , i_mask_error  => com_api_const_pkg.TRUE
              );

    l_oper.match_status := l_match_status;

    l_oper.sttl_type := l_sttl_type;
    if l_oper.sttl_type is null then
        io_cup_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        io_cup_fin_rec.is_invalid := com_api_const_pkg.TRUE;
        g_error_flag              := com_api_const_pkg.TRUE;

        trc_log_pkg.error(
            i_text        => 'UNABLE_DETERMINE_STTL_TYPE'
          , i_env_param1  => io_cup_fin_rec.trans_code
          , i_env_param2  => iss_api_card_pkg.get_card_mask(io_cup_fin_rec.card_number)
          , i_env_param3  => l_iss_inst_id
          , i_env_param4  => l_acq_inst_id
          , i_env_param5  => l_card_inst_id
          , i_env_param6  => l_iss_network_id || '/' || l_acq_network_id
        );
    end if;

    if i_msg_type is null then
        l_oper.msg_type := net_api_map_pkg.get_msg_type (
            i_network_msg_type  => io_cup_fin_rec.trans_code
          , i_standard_id       => i_standard_id
        );
    else
        l_oper.msg_type := i_msg_type;
    end if;

    if l_oper.msg_type is null then
        io_cup_fin_rec.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        io_cup_fin_rec.is_invalid := com_api_const_pkg.TRUE;
        g_error_flag              := com_api_const_pkg.TRUE;

        trc_log_pkg.error(
            i_text        => 'UNABLE_DETERMINE_MSG_TYPE'
          , i_env_param1  => io_cup_fin_rec.trans_code
          , i_env_param2  => i_standard_id
        );
    end if;

    if io_cup_fin_rec.is_invalid = com_api_const_pkg.TRUE then
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;

    l_oper.id                := io_cup_fin_rec.id;

    l_oper.is_reversal       := io_cup_fin_rec.is_reversal;
    l_oper.terminal_type     :=
    case io_cup_fin_rec.mcc when '6011' then acq_api_const_pkg.TERMINAL_TYPE_ATM
        else acq_api_const_pkg.TERMINAL_TYPE_POS
    end;

    l_oper.oper_amount             := io_cup_fin_rec.trans_amount;
    l_oper.oper_currency           := io_cup_fin_rec.trans_currency;
    l_oper.sttl_amount             := io_cup_fin_rec.sttl_amount;
    l_oper.sttl_currency           := io_cup_fin_rec.sttl_currency;
    l_oper.oper_date               := io_cup_fin_rec.transmission_date_time;
    l_oper.host_date               := null;
    l_oper.mcc                     := io_cup_fin_rec.mcc;
    l_oper.originator_refnum       := io_cup_fin_rec.rrn;
    l_oper.acq_inst_bin            := io_cup_fin_rec.acquirer_iin;
    l_oper.forw_inst_bin           := io_cup_fin_rec.forwarding_iin;

    l_oper.merchant_number         := io_cup_fin_rec.merchant_number;
    l_oper.terminal_number         := io_cup_fin_rec.terminal_number;
    l_oper.merchant_name           := io_cup_fin_rec.merchant_name;
    l_oper.merchant_country        := io_cup_fin_rec.merchant_country;
    l_oper.incom_sess_file_id      := i_incom_sess_file_id;

/*
    l_oper.merchant_city           := io_cup_fin_rec.term_city;
    l_oper.merchant_street         := io_cup_fin_rec.term_location;
    l_oper.merchant_postcode       := io_cup_fin_rec.term_zip;
*/

    l_oper.original_id             := coalesce(
                                          io_cup_fin_rec.original_id
                                        , cup_api_fin_message_pkg.get_original_id(io_cup_fin_rec)
                                      );
    -- if found original message and transaction amount is null fill message amount
    if     io_cup_fin_rec.original_id is null 
       and l_oper.original_id is not null 
       and io_cup_fin_rec.trans_amount is null then
        select o.oper_amount
             , o.oper_currency
             , o.sttl_amount
             , o.sttl_currency
          into l_oper.oper_amount
             , l_oper.oper_currency
             , l_oper.sttl_amount
             , l_oper.sttl_currency
          from opr_operation o
         where o.id = l_oper.original_id;
    end if;

    if io_cup_fin_rec.reason_code is not null
        and l_oper.oper_type in (opr_api_const_pkg.OPERATION_TYPE_FEE_CREDIT, opr_api_const_pkg.OPERATION_TYPE_FEE_DEBIT) then

        l_oper.oper_reason         := cup_api_const_pkg.CODE_FEE_COLLECTION || io_cup_fin_rec.reason_code;
    end if;

    l_iss_part.inst_id             := l_iss_inst_id;
    l_iss_part.network_id          := l_iss_network_id;
    l_iss_part.card_id             := l_card.id;
    l_iss_part.card_type_id        := nvl(l_card_type_id, l_card.card_type_id);

    --l_iss_part.card_expir_date     := date_yymm(io_cup_fin_rec.exp_date);
    l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value     := io_cup_fin_rec.card_number;
    l_iss_part.customer_id         := l_card.customer_id;
    l_iss_part.card_mask           := l_card.card_mask;
    l_iss_part.card_number         := io_cup_fin_rec.card_number;
    l_iss_part.card_hash           := l_card.card_hash;
    l_iss_part.card_country        := nvl(l_country_code, l_card.country);

    l_iss_part.card_inst_id        := l_card_inst_id;
    l_iss_part.card_network_id     := l_card_network_id;
    l_iss_part.split_hash          := l_card.split_hash;
    l_iss_part.account_amount      := null;
    l_iss_part.account_currency    := null;
    l_iss_part.account_number      := null;
    l_iss_part.auth_code           := io_cup_fin_rec.auth_resp_code;

    l_acq_part.inst_id             := l_acq_inst_id;
    l_acq_part.network_id          := l_acq_network_id;
    l_acq_part.merchant_id         := null;
    l_acq_part.terminal_id         := null;
    l_acq_part.split_hash          := null;

    -- create operation
    cup_api_fin_message_pkg.create_operation (
        i_oper        => l_oper
        , i_iss_part  => l_iss_part
        , i_acq_part  => l_acq_part
    );

    --if operation reversal in the same file with original operation
    --we must don't process reversal and original operation
    if l_oper.is_reversal = com_api_const_pkg.TRUE then
        begin
            select f.id
              into l_orig_id
              from cup_fin_message f
                 , cup_card c
             where f.file_id = io_cup_fin_rec.file_id
               and c.id = f.id
               and iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) = io_cup_fin_rec.card_number
               and f.sys_trace_num = io_cup_fin_rec.orig_sys_trace_num
               and f.is_incoming   = com_api_const_pkg.TRUE
               and f.trans_code    = cup_api_const_pkg.TC_PRESENTMENT
               and f.is_reversal   = com_api_const_pkg.FALSE
               and f.trans_amount  = io_cup_fin_rec.trans_amount;

            update opr_operation
               set status = opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
             where id in (l_orig_id, io_cup_fin_rec.id);

        exception
            when no_data_found then
                null;
        end;
    end if;

    trc_log_pkg.debug (
        i_text          => 'cup_prc_incoming_pkg.create_operation end'
    );

end create_operation;

procedure process_presentment(
    i_tc_buffer             in      varchar2
  , i_cup_file              in      cup_api_type_pkg.t_cup_file_rec
  , i_standard_id           in      com_api_type_pkg.t_tiny_id
  , i_network_id            in      com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id    in      com_api_type_pkg.t_long_id
) is
    l_cup_fin_rec                   cup_api_type_pkg.t_cup_fin_mes_rec;
    l_block0                        com_api_type_pkg.t_text;
    l_block1                        com_api_type_pkg.t_text;
    l_block2                        com_api_type_pkg.t_text;
    l_block3                        com_api_type_pkg.t_text;
    l_bitmap                        com_api_type_pkg.t_name;
    l_is_block1                     com_api_type_pkg.t_tiny_id;
    l_is_block2                     com_api_type_pkg.t_tiny_id;
    l_is_block3                     com_api_type_pkg.t_tiny_id;
    l_offset                        com_api_type_pkg.t_medium_id := 1;
    l_curr_standard_version         com_api_type_pkg.t_tiny_id;

    function get_next_block(
        i_size                  com_api_type_pkg.t_medium_id
    ) return com_api_type_pkg.t_text
    is
        l_block   com_api_type_pkg.t_text;
    begin
        l_block := substr(i_tc_buffer, l_offset, i_size);
        l_offset := l_offset + i_size;
        return l_block;
    end;

    procedure parse_block1 is
    begin
        if l_is_block1 = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => 'Parse block 1'
            );
            l_cup_fin_rec.pos_entry_mode           := trim(substr(l_block1,   1,   3));
            l_cup_fin_rec.payment_service_type     := trim(substr(l_block1,   5,   2));
            l_cup_fin_rec.sttl_amount              := trim(substr(l_block1,   7,  12));
            l_cup_fin_rec.sttl_currency            := trim(substr(l_block1,  19,   3));
            l_cup_fin_rec.settlement_exch_rate     := trim(substr(l_block1,  22,   8));
            l_cup_fin_rec.cardholder_bill_amount   := trim(substr(l_block1,  30,  12));
            l_cup_fin_rec.cardholder_acc_currency  := trim(substr(l_block1,  42,   3));
            l_cup_fin_rec.cardholder_exch_rate     := trim(substr(l_block1,  45,   8));
            l_cup_fin_rec.service_fee_amount       := trim(substr(l_block1,  53,  12));
            l_cup_fin_rec.qrc_voucher_number       := trim(substr(l_block1,  92,  20));
        end if;
    end parse_block1;

    procedure parse_block2 is
    begin
        if l_is_block2 = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => 'Parse block 2'
            );
            l_cup_fin_rec.appl_crypt               := trim(substr(l_block2,   1,  16));
            l_cup_fin_rec.pos_entry_mode           := trim(substr(l_block2,  17,   3));  -- this tag exists in block1 and block2, it is redefined value
            l_cup_fin_rec.card_serial_num          := trim(substr(l_block2,  20,   3));
            l_cup_fin_rec.terminal_entry_capab     := trim(substr(l_block2,  23,   1));
            l_cup_fin_rec.ic_card_cond_code        := trim(substr(l_block2,  24,   1));
            l_cup_fin_rec.terminal_capab           := trim(substr(l_block2,  25,   6));
            l_cup_fin_rec.terminal_verif_result    := trim(substr(l_block2,  31,  10));
            l_cup_fin_rec.unpred_num               := trim(substr(l_block2,  41,   8));
            l_cup_fin_rec.interface_serial         := trim(substr(l_block2,  49,   8));
            l_cup_fin_rec.iss_bank_app_data        := trim(substr(l_block2,  57,  64));
            l_cup_fin_rec.trans_counter            := trim(substr(l_block2, 121,   4));
            l_cup_fin_rec.appl_charact             := trim(substr(l_block2, 125,   4));
            l_cup_fin_rec.terminal_auth_date       := to_date(substr(l_block2, 129, 6), 'yymmdd');
            l_cup_fin_rec.terminal_country         := trim(substr(l_block2, 135,   3));
            l_cup_fin_rec.script_result_of_card_issuer := trim(substr(l_block2, 138,  42));
            l_cup_fin_rec.trans_resp_code          := trim(substr(l_block2, 180,   2));
            l_cup_fin_rec.trans_category           := trim(substr(l_block2, 182,   2));
            l_cup_fin_rec.auth_amount              := trim(substr(l_block2, 184,  12));
            l_cup_fin_rec.auth_currency            := trim(substr(l_block2, 196,   3));
            l_cup_fin_rec.cipher_text_inf_data     := trim(substr(l_block2, 199,   2));
            l_cup_fin_rec.other_amount             := trim(substr(l_block2, 201,  12));
            l_cup_fin_rec.auth_method              := trim(substr(l_block2, 213,   6));
            l_cup_fin_rec.terminal_category        := trim(substr(l_block2, 219,   2));
            l_cup_fin_rec.dedic_doc_name           := trim(substr(l_block2, 221,  32));
            l_cup_fin_rec.app_version_no           := trim(substr(l_block2, 253,   4));
            l_cup_fin_rec.trans_serial_counter     := trim(substr(l_block2, 257,   8));
        end if;
    end parse_block2;

    procedure parse_block3 is
    begin
        if l_is_block3 = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => 'Parse block 3'
            );
            l_cup_fin_rec.payment_facilitator_id   := trim(substr(l_block3, 27,   8));
            trc_log_pkg.debug(
                i_text        => 'payment_facilitator_id [#1]'
              , i_env_param1  => l_cup_fin_rec.payment_facilitator_id
            );
        end if;
    end parse_block3;

begin
    trc_log_pkg.debug(
        i_text          => 'process_presentment start'
    );

    l_curr_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id => nvl(i_network_id, cup_api_const_pkg.UPI_NETWORK_ID)
        );
    trc_log_pkg.debug(
        i_text         => 'cup_prc_incoming_pkg.process_presentment: standard version [#1]'
      , i_env_param1   => l_curr_standard_version
    );

    l_block0 := get_next_block(269);

    l_cup_fin_rec.trans_code := substr(l_block0, 1, 3);
    l_bitmap                 := substr(l_block0, 4, 4);
    trc_log_pkg.debug(
        i_text => 'l_bitmap [' || l_bitmap || ']'
    );

    l_is_block1 := sign(bitand(to_number(l_bitmap, 'XXXXXXXXXXXXXXXX'), power(2, 14)));
    l_is_block2 := sign(bitand(to_number(l_bitmap, 'XXXXXXXXXXXXXXXX'), power(2, 13)));

    if l_curr_standard_version >= cup_api_const_pkg.STANDARD_VERSION_ID_19Q2 then
        l_is_block3 := sign(bitand(to_number(l_bitmap, 'XXXXXXXXXXXXXXXX'), power(2, 12))); -- ???
    end if;

    if l_is_block1 = com_api_const_pkg.TRUE then
        l_block1   := get_next_block(118);
    end if;

    if l_is_block2 = com_api_const_pkg.TRUE then
        l_block2 := get_next_block(294);
    end if;

    if l_is_block3 = com_api_const_pkg.TRUE then
        l_block3 := get_next_block(300);
    end if;

    -- block 0
    l_cup_fin_rec.card_number                  := trim(substr(l_block0,   8,  19));
    l_cup_fin_rec.trans_amount                 := trim(substr(l_block0,  27,  12));
    l_cup_fin_rec.trans_currency               := trim(substr(l_block0,  39,   3));
    l_cup_fin_rec.transmission_date_time       := date_without_year(
                                                      i_date            => trim(substr(l_block0,  42,  10))
                                                    , i_filedate        => i_cup_file.trans_date
                                                    , i_datemask        => 'mmddhh24miss'
                                                  );
    l_cup_fin_rec.sys_trace_num                := trim(substr(l_block0,  52,   6));
    l_cup_fin_rec.auth_resp_code               := trim(substr(l_block0,  58,   6));
    l_cup_fin_rec.trans_date                   := trim(substr(l_block0,  64,   4));
    l_cup_fin_rec.rrn                          := trim(substr(l_block0,  68,  12));
    l_cup_fin_rec.acquirer_iin                 := trim(substr(l_block0,  80,  11));
    l_cup_fin_rec.forwarding_iin               := trim(substr(l_block0,  91,  11));
    l_cup_fin_rec.mcc                          := trim(substr(l_block0, 102,   4));
    l_cup_fin_rec.terminal_number              := trim(substr(l_block0, 106,   8));
    l_cup_fin_rec.merchant_number              := trim(substr(l_block0, 114,  15));
    l_cup_fin_rec.merchant_name                := trim(substr(l_block0, 129,  40));

    -- save reference to original operation for matching
    if substr(l_block0, 169,  23) != rpad('0', 23, '0') then
        l_cup_fin_rec.orig_trans_code              := trim(substr(l_block0, 169,   3));
        l_cup_fin_rec.orig_transmission_date_time  := date_without_year(
                                                          i_date            => trim(substr(l_block0, 172,  10))
                                                        , i_filedate        => i_cup_file.trans_date
                                                        , i_datemask        => 'mmddhh24miss'
                                                      );
        l_cup_fin_rec.orig_sys_trace_num           := trim(substr(l_block0, 182,   6));
        if substr(l_block0, 188, 4) != '0000' then
            l_cup_fin_rec.orig_trans_date          := date_without_year(
                                                          i_date            => trim(substr(l_block0, 188,   4))
                                                        , i_filedate        => i_cup_file.trans_date
                                                        , i_datemask        => 'mmdd'
                                                      );
        end if;
    end if;

    l_cup_fin_rec.reason_code                  := trim(substr(l_block0, 192,   4));
    l_cup_fin_rec.double_message_id            := trim(substr(l_block0, 196,   1));
    l_cup_fin_rec.cups_ref_num                 := trim(substr(l_block0, 197,   9));
    l_cup_fin_rec.receiving_iin                := trim(substr(l_block0, 206,  11));
    l_cup_fin_rec.issuer_iin                   := trim(substr(l_block0, 217,  11));
    l_cup_fin_rec.cups_notice                  := trim(substr(l_block0, 228,   1));
    l_cup_fin_rec.trans_init_channel           := trim(substr(l_block0, 229,   2));
    l_cup_fin_rec.trans_features_id            := trim(substr(l_block0, 231,   1));

    -- others information of Block 0
    l_cup_fin_rec.pos_cond_code                := trim(substr(l_block0, 243,   2));
    l_cup_fin_rec.merchant_country             := trim(substr(l_block0, 245,   3));
    l_cup_fin_rec.b2b_business_type            := trim(substr(l_block0, 265,   2));
    l_cup_fin_rec.b2b_payment_medium           := trim(substr(l_block0, 267,   1));

    parse_block1;
    parse_block2;
    parse_block3;

    -- init_record
    l_cup_fin_rec.is_reversal := com_api_const_pkg.FALSE;
    l_cup_fin_rec.is_incoming := com_api_const_pkg.TRUE;
    l_cup_fin_rec.is_rejected := com_api_const_pkg.FALSE;
    l_cup_fin_rec.is_invalid  := com_api_const_pkg.FALSE;
    l_cup_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_cup_fin_rec.file_id     := i_cup_file.id;
    l_cup_fin_rec.network_id  := i_cup_file.network_id;
    l_cup_fin_rec.inst_id     := i_cup_file.inst_id;
    l_cup_fin_rec.id          := opr_api_create_pkg.get_id;

    if l_cup_fin_rec.trans_code = cup_api_const_pkg.TC_PRESENTMENT then
        l_cup_fin_rec.is_reversal := 0;
    elsif l_cup_fin_rec.trans_code = cup_api_const_pkg.TC_ONLINE_REFUND then
        l_cup_fin_rec.is_reversal := 0;
    end if;
/*
    -- It is unused fields:
    l_cup_fin_rec.host_inst_id
    l_cup_fin_rec.local
    l_cup_fin_rec.point
    l_cup_fin_rec.proc_func_code
    l_cup_fin_rec.original_id
*/
    create_operation(
        io_cup_fin_rec       => l_cup_fin_rec
      , i_standard_id        => i_standard_id
      , i_incom_sess_file_id => i_incom_sess_file_id
    );

    if l_cup_fin_rec.is_invalid = com_api_const_pkg.TRUE then
        g_error_flag := com_api_const_pkg.TRUE;
        l_cup_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;

    l_cup_fin_rec.id := cup_api_fin_message_pkg.put_message (
        i_fin_rec => l_cup_fin_rec
    );


    trc_log_pkg.debug (
        i_text          => 'process_presentment end'
    );
end process_presentment;

procedure process_interchange_fee(
    i_tc_buffer             in      varchar2
    , i_cup_file            in      cup_api_type_pkg.t_cup_file_rec
    , i_is_separator        in      com_api_type_pkg.t_boolean
) is
    l_cup_fee_rec           cup_api_type_pkg.t_cup_fee_rec;

    procedure match_cup_fee(
        io_fee_rec          in out  cup_api_type_pkg.t_cup_fee_rec
    ) is
    begin
        select min(id)
          into io_fee_rec.fin_msg_id
          from cup_fin_message
         where acquirer_iin           = io_fee_rec.acquirer_iin
           and forwarding_iin         = io_fee_rec.forwarding_iin
           and sys_trace_num          = io_fee_rec.sys_trace_num
           and transmission_date_time = io_fee_rec.transmission_date_time
           and is_reversal            = io_fee_rec.is_reversal
           and (trans_code           != cup_api_const_pkg.TC_DISPUTE
                or io_fee_rec.trans_type_id = cup_api_const_pkg.TRANS_TYPE_DISPUTE_MANUAL);

        if io_fee_rec.fin_msg_id is null then
            select min(o.id)
              into io_fee_rec.fin_msg_id
              from aut_auth a
                 , opr_operation o
                 , opr_participant pi
                 , opr_participant pa
             where a.system_trace_audit_number = io_fee_rec.sys_trace_num
               and o.oper_date                 = io_fee_rec.transmission_date_time
               and o.is_reversal               = io_fee_rec.is_reversal
               and a.id                        = o.id
               and pi.oper_id                  = o.id
               and pi.participant_type         = com_api_const_pkg.PARTICIPANT_ISSUER
               and pa.oper_id                  = o.id
               and pa.participant_type         = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and o.terminal_type             = acq_api_const_pkg.TERMINAL_TYPE_ATM;

            if io_fee_rec.fin_msg_id is null then
                io_fee_rec.match_status := opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED;
                trc_log_pkg.debug (
                    i_text          => 'interchange_fee not matched, financial message not found. acquirer_iin [#1], forwarding_iin [#2], sys_trace_num [#3], transmission_date_time [#4]'
                    , i_env_param1  => io_fee_rec.acquirer_iin
                    , i_env_param2  => io_fee_rec.forwarding_iin
                    , i_env_param3  => io_fee_rec.sys_trace_num
                    , i_env_param4  => io_fee_rec.transmission_date_time
                );
            else
                io_fee_rec.match_status := opr_api_const_pkg.OPERATION_MATCH_MATCHED;
            end if;
        else
            io_fee_rec.match_status := opr_api_const_pkg.OPERATION_MATCH_MATCHED;
        end if;
    end;
begin
    trc_log_pkg.debug (
        i_text          => 'process_interchange_fee start'
    );

    if i_is_separator = com_api_const_pkg.FALSE then -- WITHOUT separator
        l_cup_fee_rec.acquirer_iin                 := trim(substr(i_tc_buffer, 1, 11));
        l_cup_fee_rec.forwarding_iin               := trim(substr(i_tc_buffer, 12, 11));
        l_cup_fee_rec.sys_trace_num                := trim(substr(i_tc_buffer, 23, 6));
        l_cup_fee_rec.transmission_date_time       := date_without_year(
                                                          i_date            => trim(substr(i_tc_buffer, 29, 10))
                                                        , i_filedate        => i_cup_file.trans_date
                                                        , i_datemask        => 'mmddhh24miss'
                                                      );
        l_cup_fee_rec.card_number                  := trim(substr(i_tc_buffer, 39, 19));
        l_cup_fee_rec.merchant_number              := trim(substr(i_tc_buffer, 58, 15));
        l_cup_fee_rec.auth_resp_code               := trim(substr(i_tc_buffer, 73, 6));
        l_cup_fee_rec.is_reversal                  := trim(substr(i_tc_buffer, 79, 1));
        l_cup_fee_rec.trans_type_id                := trim(substr(i_tc_buffer, 80, 1));
        l_cup_fee_rec.receiving_iin                := trim(substr(i_tc_buffer, 81, 11));
        l_cup_fee_rec.issuer_iin                   := trim(substr(i_tc_buffer, 92, 11));
        l_cup_fee_rec.sttl_currency                := trim(substr(i_tc_buffer, 103, 3));
        l_cup_fee_rec.interchange_fee_sign         := case trim(substr(i_tc_buffer, 110, 1))
                                                          when 'C' then  1
                                                          when 'D' then -1
                                                          else to_number(null)
                                                      end;
        l_cup_fee_rec.interchange_fee_amount       := trim(substr(i_tc_buffer, 111, 16))/ 10000;
        l_cup_fee_rec.reimbursement_fee_sign       := case trim(substr(i_tc_buffer, 131, 1))
                                                          when 'C' then  1
                                                          when 'D' then -1
                                                          else to_number(null)
                                                      end;
        l_cup_fee_rec.reimbursement_fee_amount     := trim(substr(i_tc_buffer, 132, 16))/ 10000;
        l_cup_fee_rec.service_fee_sign             := case trim(substr(i_tc_buffer, 152, 1))
                                                          when 'C' then  1
                                                          when 'D' then -1
                                                          else to_number(null)
                                                      end;
        l_cup_fee_rec.service_fee_amount           := trim(substr(i_tc_buffer, 153, 16))/ 10000;
    else  -- WITH space separator
        l_cup_fee_rec.acquirer_iin                 := trim(substr(i_tc_buffer, 1, 11));
        l_cup_fee_rec.forwarding_iin               := trim(substr(i_tc_buffer, 13, 11));
        l_cup_fee_rec.sys_trace_num                := trim(substr(i_tc_buffer, 25, 6));
        l_cup_fee_rec.transmission_date_time       := date_without_year(
                                                          i_date            => trim(substr(i_tc_buffer, 32, 10))
                                                        , i_filedate        => i_cup_file.trans_date
                                                        , i_datemask        => 'mmddhh24miss'
                                                      );
        l_cup_fee_rec.card_number                  := trim(substr(i_tc_buffer, 43, 19));
        l_cup_fee_rec.merchant_number              := trim(substr(i_tc_buffer, 63, 15));
        l_cup_fee_rec.auth_resp_code               := trim(substr(i_tc_buffer, 79, 6));
        l_cup_fee_rec.is_reversal                  := trim(substr(i_tc_buffer, 86, 1));
        l_cup_fee_rec.trans_type_id                := trim(substr(i_tc_buffer, 88, 1));
        l_cup_fee_rec.receiving_iin                := trim(substr(i_tc_buffer, 90, 11));
        l_cup_fee_rec.issuer_iin                   := trim(substr(i_tc_buffer, 102, 11));
        l_cup_fee_rec.sttl_currency                := trim(substr(i_tc_buffer, 114, 3));
        l_cup_fee_rec.interchange_fee_sign         := case trim(substr(i_tc_buffer, 123, 1))
                                                          when 'C' then  1
                                                          when 'D' then -1
                                                          else to_number(null)
                                                      end;
        l_cup_fee_rec.interchange_fee_amount       := trim(substr(i_tc_buffer, 125, 16))/ 10000;
        l_cup_fee_rec.reimbursement_fee_sign       := case trim(substr(i_tc_buffer, 147, 1))
                                                          when 'C' then  1
                                                          when 'D' then -1
                                                          else to_number(null)
                                                      end;
        l_cup_fee_rec.reimbursement_fee_amount     := trim(substr(i_tc_buffer, 149, 16))/ 10000;
        l_cup_fee_rec.service_fee_sign             := case trim(substr(i_tc_buffer, 171, 1))
                                                          when 'C' then  1
                                                          when 'D' then -1
                                                          else to_number(null)
                                                      end;
        l_cup_fee_rec.service_fee_amount           := trim(substr(i_tc_buffer, 172, 16))/ 10000;
    end if;

    l_cup_fee_rec.file_id      := i_cup_file.session_file_id;
    l_cup_fee_rec.inst_id      := i_cup_file.inst_id;
    l_cup_fee_rec.match_status := opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH;
    l_cup_fee_rec.fee_type     := cup_api_const_pkg.FT_INTERCHANGE;

    match_cup_fee(
        io_fee_rec      => l_cup_fee_rec
    );

    cup_api_fin_message_pkg.put_fee (
        i_fee_rec       => l_cup_fee_rec
    );

    cup_api_fin_message_pkg.create_fee_oper_stage(
        i_match_status  => l_cup_fee_rec.match_status
      , i_fin_msg_id    => l_cup_fee_rec.fin_msg_id
      , i_fee_type      => l_cup_fee_rec.fee_type
    );

    trc_log_pkg.debug (
        i_text          => 'process_interchange_fee end'
    );
end process_interchange_fee;

procedure process_dispute(
    i_tc_buffer             in      varchar2
    , i_cup_file            in      cup_api_type_pkg.t_cup_file_rec
    , i_is_issuer           in      com_api_type_pkg.t_boolean
    , i_create_operation    in      com_api_type_pkg.t_boolean default null
    , i_standard_id         in      com_api_type_pkg.t_tiny_id
    , i_session_file_id     in      com_api_type_pkg.t_long_id
) is
    l_cup_dispute_rec               cup_api_type_pkg.t_cup_fin_mes_rec;
    l_offset                        com_api_type_pkg.t_count := 0;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_msg_type                      com_api_type_pkg.t_dict_value;
    l_terminal_number               com_api_type_pkg.t_terminal_number;
    l_orig_cardholder_bill_amount   com_api_type_pkg.t_money;
    l_orig_oper_id                  com_api_type_pkg.t_long_id;
    l_orig_dispute_id               com_api_type_pkg.t_long_id;
    l_orig_trans_amount             com_api_type_pkg.t_money;
    l_orig_trans_currency           com_api_type_pkg.t_name;
    l_card_number                   com_api_type_pkg.t_card_number;
begin
    trc_log_pkg.debug (
        i_text          => 'process_dispute start'
    );

    -- Init record
    l_cup_dispute_rec.is_reversal              := com_api_const_pkg.FALSE;
    l_cup_dispute_rec.is_incoming              := com_api_const_pkg.TRUE;
    l_cup_dispute_rec.is_rejected              := com_api_const_pkg.FALSE;
    l_cup_dispute_rec.is_invalid               := com_api_const_pkg.FALSE;
    l_cup_dispute_rec.status                   := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_cup_dispute_rec.file_id                  := i_cup_file.id;
    l_cup_dispute_rec.network_id               := i_cup_file.network_id;
    l_cup_dispute_rec.inst_id                  := i_cup_file.inst_id;
    l_cup_dispute_rec.id                       := opr_api_create_pkg.get_id;
    l_cup_dispute_rec.trans_code               := cup_api_const_pkg.TC_DISPUTE;

    -- Parse incoming line
    l_cup_dispute_rec.acquirer_iin             := trim(substr(i_tc_buffer, 1, 11));
    l_cup_dispute_rec.forwarding_iin           := trim(substr(i_tc_buffer, 13, 11));
    l_cup_dispute_rec.sys_trace_num            := trim(substr(i_tc_buffer, 25, 6));
    l_cup_dispute_rec.transmission_date_time   := date_without_year(
                                                      i_date            => trim(substr(i_tc_buffer, 32, 10))
                                                    , i_filedate        => i_cup_file.trans_date
                                                    , i_datemask        => 'mmddhh24miss'
                                                  );
    l_cup_dispute_rec.card_number              := trim(substr(i_tc_buffer, 43, 19));
    l_cup_dispute_rec.message_type             := trim(substr(i_tc_buffer, 76, 4));
    l_cup_dispute_rec.proc_func_code           := trim(substr(i_tc_buffer, 81, 6));
    l_cup_dispute_rec.mcc                      := trim(substr(i_tc_buffer, 88, 4));
    l_cup_dispute_rec.terminal_number          := trim(substr(i_tc_buffer, 93, 8));
    l_cup_dispute_rec.merchant_number          := trim(substr(i_tc_buffer, 102, 15));
    l_cup_dispute_rec.merchant_name            := trim(substr(i_tc_buffer, 118, 40));
    l_cup_dispute_rec.rrn                      := trim(substr(i_tc_buffer, 159, 12));
    l_cup_dispute_rec.pos_cond_code            := trim(substr(i_tc_buffer, 172, 2));
    l_cup_dispute_rec.auth_resp_code           := trim(substr(i_tc_buffer, 175, 6));
    l_cup_dispute_rec.receiving_iin            := trim(substr(i_tc_buffer, 182, 11));
    l_cup_dispute_rec.orig_sys_trace_num       := trim(substr(i_tc_buffer, 194, 6));
    l_cup_dispute_rec.trans_resp_code          := trim(substr(i_tc_buffer, 201, 2));
    l_cup_dispute_rec.pos_entry_mode           := trim(substr(i_tc_buffer, 208, 3));
    l_cup_dispute_rec.sttl_currency            := trim(substr(i_tc_buffer, 212, 3));
    l_cup_dispute_rec.sttl_amount              := trim(substr(i_tc_buffer, 216, 12));
    l_cup_dispute_rec.settlement_exch_rate     := trim(substr(i_tc_buffer, 229, 8));
    l_cup_dispute_rec.orig_trans_date          := date_without_year(
                                                      i_date            => trim(substr(i_tc_buffer, 238, 4))
                                                    , i_filedate        => i_cup_file.trans_date
                                                    , i_datemask        => 'mmdd'
                                                  );
    l_cup_dispute_rec.trans_date               := trim(substr(i_tc_buffer, 238, 4));
    if i_is_issuer = com_api_const_pkg.TRUE then -- Issuer
        l_cup_dispute_rec.cardholder_acc_currency  := trim(substr(i_tc_buffer, 248, 3));
        l_cup_dispute_rec.cardholder_bill_amount   := trim(substr(i_tc_buffer, 252, 12));
        l_cup_dispute_rec.cardholder_exch_rate     := trim(substr(i_tc_buffer, 265, 8));

        l_offset := l_offset + 26;
    end if;
    l_cup_dispute_rec.receivable_fee           := trim(substr(i_tc_buffer, 248 + l_offset, 12));
    l_cup_dispute_rec.payable_fee              := trim(substr(i_tc_buffer, 261 + l_offset, 12));
    l_cup_dispute_rec.interchange_fee          := trim(substr(i_tc_buffer, 274 + l_offset, 12));
    l_cup_dispute_rec.transaction_fee          := trim(substr(i_tc_buffer, 287 + l_offset, 12));
    l_cup_dispute_rec.orig_transmission_date_time := date_without_year(
                                                         i_date        => trim(substr(i_tc_buffer, 300 + l_offset, 10))
                                                       , i_filedate    => i_cup_file.trans_date
                                                       , i_datemask    => 'mmddhh24miss'
                                                     );
    l_cup_dispute_rec.orig_trans_code          := trim(substr(i_tc_buffer, 311 + l_offset, 4));
    l_cup_dispute_rec.reserved                 := substr(i_tc_buffer, 318 + l_offset, 30);

    l_cup_dispute_rec.merchant_country         := com_api_country_pkg.get_country_code_by_name(
                                                      i_name        => substr(l_cup_dispute_rec.merchant_name, 38, 3)
                                                    , i_raise_error => com_api_const_pkg.FALSE
                                                  );

    l_card_number                              := iss_api_token_pkg.encode_card_number(
                                                      i_card_number => l_cup_dispute_rec.card_number
                                                  );
    l_cup_dispute_rec.reason_code              := substr(l_cup_dispute_rec.reserved, 25, 4);

    -- Find original operation for dispute message.
    begin
        select id
             , dispute_id
             , trans_amount
             , trans_currency
             , cardholder_bill_amount
          into l_orig_oper_id
             , l_orig_dispute_id
             , l_orig_trans_amount
             , l_orig_trans_currency
             , l_orig_cardholder_bill_amount
          from (
              select m.id
                   , m.dispute_id
                   , m.trans_amount
                   , m.trans_currency
                   , m.cardholder_bill_amount
                from cup_fin_message m
                   , cup_card c
                   , opr_operation o
               where m.sys_trace_num          = l_cup_dispute_rec.orig_sys_trace_num
                 and c.card_number            = l_card_number
                 and c.id                     = m.id
                 and o.id                     = m.id
                 and o.msg_type               = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
               order by c.id
          )
         where rownum = 1;
    exception
        when no_data_found then

            begin
                select o.id
                     , o.dispute_id
                     , o.oper_amount
                     , o.oper_currency
                     , a.bin_amount
                  into l_orig_oper_id
                     , l_orig_dispute_id
                     , l_orig_trans_amount
                     , l_orig_trans_currency
                     , l_orig_cardholder_bill_amount
                  from aut_auth a
                     , opr_operation o
                     , opr_participant pi
                     , opr_participant pa
                     , opr_card c
                 where a.system_trace_audit_number = l_cup_dispute_rec.orig_sys_trace_num
                   and o.is_reversal               = com_api_const_pkg.FALSE
                   and a.id                        = o.id
                   and pi.oper_id                  = o.id
                   and pi.participant_type         = com_api_const_pkg.PARTICIPANT_ISSUER
                   and pa.oper_id                  = o.id
                   and pa.participant_type         = com_api_const_pkg.PARTICIPANT_ACQUIRER
                   and c.oper_id                   = o.id
                   and c.participant_type          = com_api_const_pkg.PARTICIPANT_ISSUER
                   and c.card_number               = l_card_number;

            exception
                when no_data_found then

                    -- Dispute message is invalid when original operation does not exist.
                    l_cup_dispute_rec.is_invalid := com_api_const_pkg.TRUE;

                    trc_log_pkg.error (
                        i_text         => 'CUP_ORIGINAL_OPERATION_IS_NOT_FOUND'
                      , i_env_param1   => l_cup_dispute_rec.id
                      , i_env_param2   => l_cup_dispute_rec.sys_trace_num
                      , i_env_param3   => iss_api_card_pkg.get_card_mask(l_cup_dispute_rec.card_number)
                      , i_env_param4   => l_cup_dispute_rec.trans_date
                      , i_object_id    => l_cup_dispute_rec.id
                    );
            end;
    end;

    l_cup_dispute_rec.original_id := l_orig_oper_id;

    if l_orig_oper_id is not null then
        trc_log_pkg.debug (
            i_text        => 'Original message found. id [#1], dispute_id [#2]'
          , i_env_param1  => l_orig_oper_id
          , i_env_param2  => l_orig_dispute_id
        );

        l_cup_dispute_rec.trans_currency   := l_orig_trans_currency;

        if l_cup_dispute_rec.trans_currency = l_cup_dispute_rec.cardholder_acc_currency then
            l_orig_cardholder_bill_amount  := l_orig_trans_amount;
        end if;

        if l_cup_dispute_rec.cardholder_bill_amount < l_orig_cardholder_bill_amount then
            -- chargeback message with partial amount
            l_cup_dispute_rec.trans_amount := l_orig_trans_amount * (l_cup_dispute_rec.cardholder_bill_amount / l_orig_cardholder_bill_amount);
            trc_log_pkg.debug('dispute amount: case <');

        elsif l_cup_dispute_rec.cardholder_bill_amount > l_orig_cardholder_bill_amount then
            -- chargeback message with incorrect amount
            l_cup_dispute_rec.trans_amount := l_orig_trans_amount * (l_cup_dispute_rec.cardholder_bill_amount / l_orig_cardholder_bill_amount);
            l_cup_dispute_rec.is_invalid   := com_api_const_pkg.TRUE;
            trc_log_pkg.debug('dispute amount: case >');

            trc_log_pkg.error (
                i_text         => 'DISPUTED_AMOUNT_IS_GREATER_ORIGINAL_AMOUNT'
              , i_env_param1   => l_cup_dispute_rec.id
              , i_env_param2   => l_orig_oper_id
              , i_object_id    => l_cup_dispute_rec.id
            );

        else
            l_cup_dispute_rec.trans_amount := l_orig_trans_amount;
            trc_log_pkg.debug('dispute amount: case =');

        end if;

        if l_orig_dispute_id is null then
            -- assign a new dispute id
            l_cup_dispute_rec.dispute_id := l_orig_oper_id;

            update cup_fin_message
               set dispute_id = l_orig_oper_id
             where id = l_orig_oper_id;
        else
            l_cup_dispute_rec.dispute_id := l_orig_dispute_id;
        end if;
    end if;

    if l_cup_dispute_rec.dispute_id is null then
        l_cup_dispute_rec.is_invalid := com_api_const_pkg.TRUE;

        trc_log_pkg.error (
            i_text         => 'NO_DISPUTE_FOUND'
          , i_env_param1   => l_cup_dispute_rec.id
          , i_object_id    => l_cup_dispute_rec.id
        );

    end if;

    l_msg_type := net_api_map_pkg.get_msg_type (
        i_network_msg_type  => l_cup_dispute_rec.trans_code
                            || lpad(l_cup_dispute_rec.message_type, 4, '0')
                            || substr(l_cup_dispute_rec.proc_func_code, 1, 2)
                            || l_cup_dispute_rec.pos_cond_code
      , i_standard_id       => i_standard_id
    );

    if i_create_operation = com_api_const_pkg.TRUE then

        if l_cup_dispute_rec.message_type                        in (0422, 0220)
           and substr(l_cup_dispute_rec.proc_func_code, 1, 2)     = '22'
           and l_cup_dispute_rec.pos_cond_code                   in ('00', '83')
        then
            l_oper_type := 'OPTP0422';  -- Account credit adjustment

        elsif l_cup_dispute_rec.message_type                     in (0422, 0220)
              and substr(l_cup_dispute_rec.proc_func_code, 1, 2)  = '02'
              and l_cup_dispute_rec.pos_cond_code                 = '00'
        then
            l_oper_type := 'OPTP0402';  -- Account debit adjustment

        else
            -- Get oper_type from original operation
            begin
                select oper_type
                     , terminal_number
                  into l_oper_type
                     , l_terminal_number
                  from opr_operation o
                 where o.id = l_orig_oper_id;
            exception
                when no_data_found then
                    if l_cup_dispute_rec.mcc = '6011' then
                        l_oper_type := opr_api_const_pkg.OPERATION_TYPE_ATM_CASH;
                    else
                        l_oper_type := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                    end if;
            end;
            -- inherit terminal_number from original operation to support long terminal_number version
            l_cup_dispute_rec.terminal_number := nvl(l_terminal_number, l_cup_dispute_rec.terminal_number);

        end if;

        create_operation(
            io_cup_fin_rec       => l_cup_dispute_rec
          , i_standard_id        => i_standard_id
          , i_incom_sess_file_id => i_session_file_id
          , i_oper_type          => l_oper_type
          , i_msg_type           => l_msg_type
        );

    end if;

    if l_cup_dispute_rec.is_invalid = com_api_const_pkg.TRUE then
        g_error_flag := com_api_const_pkg.TRUE;
        l_cup_dispute_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;

    l_cup_dispute_rec.id := cup_api_fin_message_pkg.put_message (
        i_fin_rec => l_cup_dispute_rec
    );

    trc_log_pkg.debug (
        i_text          => 'process_dispute end'
    );
end process_dispute;

procedure process_audit_trailer(
    i_tc_buffer             in      varchar2
    , i_cup_file            in      cup_api_type_pkg.t_cup_file_rec
    , i_is_issuer           in      com_api_type_pkg.t_boolean
) is
    l_cup_audit_rec         cup_api_type_pkg.t_cup_audit_rec;
    l_offset                com_api_type_pkg.t_count := 0;

    procedure match_cup_audit(
        io_cup_audit_rec    in out  cup_api_type_pkg.t_cup_audit_rec
    ) is
    begin
        if i_is_issuer = com_api_const_pkg.TRUE then
            select min(o.id)
              into io_cup_audit_rec.fin_msg_id
              from aut_auth a
                 , opr_operation o
                 , opr_participant pi
                 , opr_participant pa
             where a.system_trace_audit_number = io_cup_audit_rec.sys_trace_num
               and o.id                        = a.id
               and o.acq_inst_bin              = io_cup_audit_rec.acquirer_iin
               and o.forw_inst_bin             = io_cup_audit_rec.forwarding_iin
               and o.oper_date                 = io_cup_audit_rec.transmission_date_time
               and o.is_reversal               = com_api_const_pkg.FALSE
               and o.terminal_type             = acq_api_const_pkg.TERMINAL_TYPE_ATM
               and pi.oper_id                  = o.id
               and pi.participant_type         = com_api_const_pkg.PARTICIPANT_ISSUER
               and pa.oper_id                  = o.id
               and pa.participant_type         = com_api_const_pkg.PARTICIPANT_ACQUIRER;

        else
            select min(id)
              into io_cup_audit_rec.fin_msg_id
              from cup_fin_message
             where acquirer_iin            = io_cup_audit_rec.acquirer_iin
               and forwarding_iin          = io_cup_audit_rec.forwarding_iin
               and sys_trace_num           = io_cup_audit_rec.sys_trace_num
               and transmission_date_time  = io_cup_audit_rec.transmission_date_time
               and trans_code             != cup_api_const_pkg.TC_DISPUTE;

        end if;

        if io_cup_audit_rec.fin_msg_id is null then
            io_cup_audit_rec.match_status := opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED;
            trc_log_pkg.debug (
                i_text          => 'audit trailer not matched, financial message not found. acquirer_iin [#1], forwarding_iin [#2], sys_trace_num [#3], transmission_date_time [#4]'
                , i_env_param1  => io_cup_audit_rec.acquirer_iin
                , i_env_param2  => io_cup_audit_rec.forwarding_iin
                , i_env_param3  => io_cup_audit_rec.sys_trace_num
                , i_env_param4  => io_cup_audit_rec.transmission_date_time
            );
        else
            io_cup_audit_rec.match_status := opr_api_const_pkg.OPERATION_MATCH_MATCHED;
        end if;
    end;
begin
    trc_log_pkg.debug (
        i_text          => 'process_audit_trailer start'
    );

    l_cup_audit_rec.acquirer_iin             := trim(substr(i_tc_buffer, 1, 11));
    l_cup_audit_rec.forwarding_iin           := trim(substr(i_tc_buffer, 13, 11));
    l_cup_audit_rec.sys_trace_num            := trim(substr(i_tc_buffer, 25, 6));
    l_cup_audit_rec.transmission_date_time   := date_without_year(
                                                    i_date            => trim(substr(i_tc_buffer, 32, 10))
                                                  , i_filedate        => i_cup_file.trans_date
                                                  , i_datemask        => 'mmddhh24miss'
                                                );
    l_cup_audit_rec.card_number              := trim(substr(i_tc_buffer, 43, 19));
    l_cup_audit_rec.trans_amount             := trim(substr(i_tc_buffer, 63, 12));
    l_cup_audit_rec.message_type             := trim(substr(i_tc_buffer, 76, 4));
    l_cup_audit_rec.proc_func_code           := trim(substr(i_tc_buffer, 81, 6));
    l_cup_audit_rec.mcc                      := trim(substr(i_tc_buffer, 88, 4));
    l_cup_audit_rec.terminal_number          := trim(substr(i_tc_buffer, 93, 8));
    l_cup_audit_rec.merchant_number          := trim(substr(i_tc_buffer, 102, 15));
    l_cup_audit_rec.merchant_name            := trim(substr(i_tc_buffer, 118, 40));
    l_cup_audit_rec.rrn                      := trim(substr(i_tc_buffer, 159, 12));
    l_cup_audit_rec.pos_cond_code            := trim(substr(i_tc_buffer, 172, 2));
    l_cup_audit_rec.auth_resp_code           := trim(substr(i_tc_buffer, 175, 6));
    l_cup_audit_rec.receiving_iin            := trim(substr(i_tc_buffer, 182, 11));
    l_cup_audit_rec.orig_sys_trace_num       := trim(substr(i_tc_buffer, 194, 6));
    l_cup_audit_rec.trans_resp_code          := trim(substr(i_tc_buffer, 201, 2));
    l_cup_audit_rec.trans_currency           := trim(substr(i_tc_buffer, 204, 3));
    l_cup_audit_rec.pos_entry_mode           := trim(substr(i_tc_buffer, 208, 3));
    l_cup_audit_rec.sttl_currency            := trim(substr(i_tc_buffer, 212, 3));
    l_cup_audit_rec.sttl_amount              := trim(substr(i_tc_buffer, 216, 12));
    l_cup_audit_rec.sttl_exch_rate           := trim(substr(i_tc_buffer, 229, 8));
    l_cup_audit_rec.sttl_date                := date_without_year(
                                                    i_date            => trim(substr(i_tc_buffer, 238, 4))
                                                  , i_filedate        => i_cup_file.trans_date
                                                  , i_datemask        => 'mmdd'
                                                );
    l_cup_audit_rec.exchange_date            := date_without_year(
                                                    i_date            => trim(substr(i_tc_buffer, 243, 4))
                                                  , i_filedate        => i_cup_file.trans_date
                                                  , i_datemask        => 'mmdd'
                                                );
    if i_is_issuer = com_api_const_pkg.TRUE then -- Issuer
        l_cup_audit_rec.cardholder_acc_currency  := trim(substr(i_tc_buffer, 248, 3));
        l_cup_audit_rec.cardholder_bill_amount   := trim(substr(i_tc_buffer, 252, 12));
        l_cup_audit_rec.cardholder_exch_rate     := trim(substr(i_tc_buffer, 265, 8));

        l_offset := l_offset + 26;
    end if;
    l_cup_audit_rec.receivable_fee           := trim(substr(i_tc_buffer, 248 + l_offset, 12));
    l_cup_audit_rec.payable_fee              := trim(substr(i_tc_buffer, 261 + l_offset, 12));
    l_cup_audit_rec.interchange_fee          := trim(substr(i_tc_buffer, 274 + l_offset, 12));
    l_cup_audit_rec.interchange_currency     := trim(substr(i_tc_buffer, 287 + l_offset, 3));
    l_cup_audit_rec.interchange_exch_rate    := trim(substr(i_tc_buffer, 291 + l_offset, 8));
    l_cup_audit_rec.transaction_fee          := trim(substr(i_tc_buffer, 300 + l_offset, 12));
    l_cup_audit_rec.billing_currency         := trim(substr(i_tc_buffer, 313 + l_offset, 3));
    l_cup_audit_rec.billing_exch_rate        := trim(substr(i_tc_buffer, 317 + l_offset, 8));
    l_cup_audit_rec.reserved                 := substr(i_tc_buffer, 326 + l_offset, 30);
    l_cup_audit_rec.file_id                  := i_cup_file.session_file_id;
    l_cup_audit_rec.inst_id                  := i_cup_file.inst_id;
    l_cup_audit_rec.match_status             := opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH;

    match_cup_audit(
        io_cup_audit_rec => l_cup_audit_rec
    );

    cup_api_fin_message_pkg.put_audit_trailer (
        i_cup_audit_rec => l_cup_audit_rec
    );

    trc_log_pkg.debug (
        i_text          => 'process_audit_trailer end'
    );
end process_audit_trailer;

procedure process_fee_collection(
    i_tc_buffer             in      varchar2
    , i_cup_file            in      cup_api_type_pkg.t_cup_file_rec
    , i_create_operation    in      com_api_type_pkg.t_boolean default null
    , i_standard_id         in      com_api_type_pkg.t_tiny_id
    , i_session_file_id     in      com_api_type_pkg.t_long_id
) is
    l_cup_fee_rec           cup_api_type_pkg.t_cup_fee_rec;
    l_oper_type             com_api_type_pkg.t_dict_value;
    l_cup_fin_rec           cup_api_type_pkg.t_cup_fin_mes_rec;
begin
    trc_log_pkg.debug (
        i_text          => 'process_fee_collection start'
    );

    l_cup_fee_rec.fee_type                     := trim(substr(i_tc_buffer, 1, 3));
    l_cup_fee_rec.sttl_sign                    := case trim(substr(i_tc_buffer, 5, 1))
                                                      when 'C' then  1
                                                      when 'D' then -1
                                                      else to_number(null)
                                                  end;
    l_cup_fee_rec.sttl_amount                  := trim(substr(i_tc_buffer, 6, 12));
    l_cup_fee_rec.reason_code                  := trim(substr(i_tc_buffer, 19, 4));
    l_cup_fee_rec.sender_iin_level1            := trim(substr(i_tc_buffer, 24, 11));
    l_cup_fee_rec.sender_iin_level2            := trim(substr(i_tc_buffer, 36, 11));
    l_cup_fee_rec.receiving_iin                := trim(substr(i_tc_buffer, 48, 11));
    l_cup_fee_rec.receiving_iin_level2         := trim(substr(i_tc_buffer, 60, 11));
    l_cup_fee_rec.transmission_date_time       := date_without_year(
                                                      i_date            => trim(substr(i_tc_buffer, 72, 10))
                                                    , i_filedate        => i_cup_file.trans_date
                                                    , i_datemask        => 'mmddhh24miss'
                                                  );
    l_cup_fee_rec.sys_trace_num                := trim(substr(i_tc_buffer, 83, 6));
    l_cup_fee_rec.card_number                  := trim(substr(i_tc_buffer, 90, 19));
    l_cup_fee_rec.sttl_currency                := trim(substr(i_tc_buffer, 110, 3));
    l_cup_fee_rec.file_id                      := i_cup_file.session_file_id;
    l_cup_fee_rec.inst_id                      := i_cup_file.inst_id;
    l_cup_fee_rec.match_status                 := opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH;
    l_cup_fee_rec.id                           := opr_api_create_pkg.get_id;

    if i_create_operation = com_api_const_pkg.TRUE then
        l_oper_type := case l_cup_fee_rec.sttl_sign
                            when  1 then opr_api_const_pkg.OPERATION_TYPE_FEE_CREDIT
                            when -1 then opr_api_const_pkg.OPERATION_TYPE_FEE_DEBIT
                            else null
                       end;

        l_cup_fin_rec.card_number              := l_cup_fee_rec.card_number;
        l_cup_fin_rec.inst_id                  := l_cup_fee_rec.inst_id;
        l_cup_fin_rec.network_id               := i_cup_file.network_id;
        l_cup_fin_rec.sttl_amount              := l_cup_fee_rec.sttl_amount;
        l_cup_fin_rec.sttl_currency            := l_cup_fee_rec.sttl_currency;
        l_cup_fin_rec.transmission_date_time   := l_cup_fee_rec.transmission_date_time;
        l_cup_fin_rec.is_reversal              := com_api_const_pkg.FALSE;
        l_cup_fin_rec.id                       := l_cup_fee_rec.id;
        l_cup_fin_rec.reason_code              := l_cup_fee_rec.reason_code;
        l_cup_fee_rec.fin_msg_id               := l_cup_fee_rec.id;

        create_operation(
            io_cup_fin_rec       => l_cup_fin_rec
          , i_standard_id        => i_standard_id
          , i_incom_sess_file_id => i_session_file_id
          , i_oper_type          => l_oper_type
          , i_msg_type           => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
        );

    end if;

    cup_api_fin_message_pkg.put_fee (
        i_fee_rec => l_cup_fee_rec
    );

    trc_log_pkg.debug (
        i_text          => 'process_fee_collection end'
    );
end process_fee_collection;

procedure load_clearing (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
)is
    l_tc_buffer             cup_api_type_pkg.t_tc_buffer;
    l_cup_file              cup_api_type_pkg.t_cup_file_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;
    l_estimated_count       com_api_type_pkg.t_long_id;
    l_trailer_load          com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_header_load           com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_inst_name             com_api_type_pkg.t_name;
    l_session_id            com_api_type_pkg.t_long_id;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = l_session_id
           and a.session_file_id = b.id;

begin
    trc_log_pkg.debug (
        i_text        => 'cup_prc_incoming_pkg.load_clearing start. i_network_id [#1] i_action_code [#2] i_dst_inst_id [#3]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_action_code
      , i_env_param3  => i_dst_inst_id
    );

    prc_api_stat_pkg.log_start;

    l_session_id   := prc_api_session_pkg.get_session_id;

    -- get estimated count
    open cu_records_count;
    fetch cu_records_count into l_estimated_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count  => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text             => 'estimation record = ' || l_estimated_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id => i_network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    trc_log_pkg.debug (
        i_text        => 'load_clearing: host_id [#1], standard_id [#2]'
      , i_env_param1  => l_host_id
      , i_env_param2  => l_standard_id
    );

    for p in (
        select id as session_file_id
             , record_count
          from prc_session_file
         where session_id = l_session_id
         order by id
    ) loop
        l_errors_count := 0;
        l_trailer_load := com_api_const_pkg.FALSE;
        l_header_load  := com_api_const_pkg.FALSE;

        begin
            savepoint sp_cup_incoming_file;
            trc_log_pkg.debug (
                i_text          => 'file processing start: session_file_id=' || p.session_file_id
            );

            for r in (
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            -- processing current file
            loop
                g_error_flag := com_api_const_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1)  := r.raw_data;

                -- check header
                if l_header_load = com_api_const_pkg.FALSE then
                    l_inst_name := trim(substr(l_tc_buffer(1), 8, 11));

                    if l_inst_name is not null
                       and substr(l_tc_buffer(1), 1, 7) = '0008000'
                    then
                        process_file_header(
                            i_header_data       => l_tc_buffer(1)
                          , i_network_id        => i_network_id
                          , i_standard_id       => l_standard_id
                          , i_action_code       => i_action_code
                          , i_dst_inst_id       => i_dst_inst_id
                          , i_inst_name         => l_inst_name
                          , i_host_id           => l_host_id
                          , o_cup_file          => l_cup_file
                          , i_session_file_id   => p.session_file_id
                        );
                        l_header_load := com_api_const_pkg.TRUE;
                        l_record_number := l_record_number + 1;
                    else
                        com_api_error_pkg.raise_error(
                            i_error          => 'HEADER_NOT_FOUND'
                          , i_env_param1     => p.session_file_id
                        );
                    end if;

                elsif substr(l_tc_buffer(1), 1, 7) = '0018000' then
                    process_file_trailer (
                        i_trailer_data       => l_tc_buffer(1)
                      , io_cup_file          => l_cup_file
                    );
                    l_trailer_load := com_api_const_pkg.TRUE;
                    l_record_number := l_record_number + 1;
                else
                    --process_presentment
                    if l_trailer_load = com_api_const_pkg.TRUE then
                        com_api_error_pkg.raise_error(
                            i_error          => 'PRESENTMENT_AFTER_TRAILER'
                          , i_env_param1     => p.session_file_id
                        );
                    end if;

                    process_presentment(
                        i_tc_buffer          => l_tc_buffer(1)
                      , i_cup_file           => l_cup_file
                      , i_standard_id        => l_standard_id
                      , i_network_id         => i_network_id
                      , i_incom_sess_file_id => p.session_file_id
                    );

                    l_record_number := l_record_number + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_number, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_number
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;

            -- check trailer exists
            if l_trailer_load = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'TRAILER_NOT_FOUND'
                  , i_env_param1  => p.session_file_id
                );
            end if;

            trc_log_pkg.debug (
                i_text          => 'file processing end'
            );

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_cup_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_number := l_record_number + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_number
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_number
      , i_excepted_total    => nvl(l_errors_count , 0)
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text          => 'cup_prc_incoming_pkg.load_clearing finish'
    );

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end load_clearing;

procedure load_interchange_fee (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
) is
    l_tc_buffer             cup_api_type_pkg.t_tc_buffer;
    l_cup_file              cup_api_type_pkg.t_cup_file_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_session_id            com_api_type_pkg.t_long_id;
    l_is_separator          com_api_type_pkg.t_boolean;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = l_session_id
           and a.session_file_id = b.id;

begin
    trc_log_pkg.debug(
        i_text        => 'cup_prc_incoming_pkg.load_interchange_fee start. i_network_id [#1] i_action_code [#2] i_dst_inst_id [#3]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_action_code
      , i_env_param3  => i_dst_inst_id
    );

    prc_api_stat_pkg.log_start;

    l_session_id   := prc_api_session_pkg.get_session_id;
    l_record_count := 0;

    -- get estimated count
    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count    => l_record_count
    );

    trc_log_pkg.debug (
        i_text          => 'estimation record = ' || l_record_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id => i_network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    trc_log_pkg.debug (
        i_text          => 'load_interchange_fee: host_id[#1] standard_id[#2]'
        , i_env_param1  => l_host_id
        , i_env_param2  => l_standard_id
    );

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = l_session_id
         order by id
    ) loop
        l_errors_count := 0;
        if substr(p.file_name,13,7) = 'FEEDTLB' then
            l_is_separator := com_api_const_pkg.TRUE;
        else
            l_is_separator := com_api_const_pkg.FALSE;
        end if;

        process_dispute_file_header(
            i_header_data     => null
          , i_network_id      => i_network_id
          , i_action_code     => i_action_code
          , i_dst_inst_id     => i_dst_inst_id
          , i_file_type       => trim(substr(p.file_name, 13, 7))
          , o_cup_file        => l_cup_file
          , i_session_file_id => p.session_file_id
          , i_use_sysdate     => com_api_const_pkg.TRUE
        );

        begin
            savepoint sp_cup_incoming_file;
            trc_log_pkg.debug (
                i_text          => 'file processing start: session_file_id=' || p.session_file_id
            );

            for r in (
                select record_number
                     , raw_data
                     , session_file_id
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            -- processing current file
            loop
                g_error_flag := com_api_const_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1)  := r.raw_data;

                --process_interchange_fee
                process_interchange_fee(
                    i_tc_buffer          => l_tc_buffer(1)
                    , i_cup_file         => l_cup_file
                    , i_is_separator     => l_is_separator
                );

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

                l_record_number := l_record_number + 1;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_number, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_number
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;

            trc_log_pkg.debug (
                i_text          => 'file processing end'
            );

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_cup_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_number := l_record_number + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_number
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;

        process_dispute_file_trailer (
            i_trailer_data  => null
          , io_cup_file     => l_cup_file
        );

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_number
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text          => 'cup_prc_incoming_pkg.load_interchange_fee finish'
    );

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end load_interchange_fee;

procedure load_dispute (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
  , i_create_operation      in     com_api_type_pkg.t_boolean   default null
) is
    l_tc_buffer             cup_api_type_pkg.t_tc_buffer;
    l_cup_file              cup_api_type_pkg.t_cup_file_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_session_id            com_api_type_pkg.t_long_id;
    l_is_separator          com_api_type_pkg.t_boolean;
    l_is_issuer             com_api_type_pkg.t_boolean;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = l_session_id
           and a.session_file_id = b.id;

begin
    trc_log_pkg.debug(
        i_text        => 'cup_prc_incoming_pkg.load_dispute start. i_network_id [#1] i_action_code [#2] i_dst_inst_id [#3]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_action_code
      , i_env_param3  => i_dst_inst_id
    );

    prc_api_stat_pkg.log_start;

    l_session_id   := prc_api_session_pkg.get_session_id;
    l_record_count := 0;

    -- get estimated count
    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count    => l_record_count
    );

    trc_log_pkg.debug (
        i_text          => 'estimation record = ' || l_record_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id => i_network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    trc_log_pkg.debug (
        i_text          => 'load_dispute: host_id[#1] standard_id[#2]'
        , i_env_param1  => l_host_id
        , i_env_param2  => l_standard_id
    );

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = l_session_id
         order by id
    ) loop
        l_errors_count := 0;
        if substr(p.file_name, 12, 1) = 'I' then
            l_is_issuer := com_api_const_pkg.TRUE;
        else
            l_is_issuer := com_api_const_pkg.FALSE;
        end if;
        if substr(p.file_name, 13, 4) = 'ERRB' then
            l_is_separator := com_api_const_pkg.TRUE;
        else
            l_is_separator := com_api_const_pkg.FALSE;

            process_dispute_file_header(
                i_header_data     => null
              , i_network_id      => i_network_id
              , i_action_code     => i_action_code
              , i_dst_inst_id     => i_dst_inst_id
              , i_file_type       => trim(substr(p.file_name, 12, 5))
              , o_cup_file        => l_cup_file
              , i_session_file_id => p.session_file_id
              , i_use_sysdate     => com_api_const_pkg.TRUE
            );
        end if;

        begin
            savepoint sp_cup_incoming_file;
            trc_log_pkg.debug (
                i_text          => 'file processing start: session_file_id=' || p.session_file_id
            );

            for r in (
                select record_number
                     , raw_data
                     , session_file_id
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            -- processing current file
            loop
                g_error_flag := com_api_const_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1)  := r.raw_data;

                if l_is_separator = com_api_const_pkg.TRUE and substr(l_tc_buffer(1), 1, 62) = lpad(' ', 62) then
                    process_dispute_file_header(
                        i_header_data     => l_tc_buffer(1)
                      , i_network_id      => i_network_id
                      , i_action_code     => i_action_code
                      , i_dst_inst_id     => i_dst_inst_id
                      , i_file_type       => trim(substr(p.file_name, 12, 5))
                      , o_cup_file        => l_cup_file
                      , i_session_file_id => r.session_file_id
                      , i_use_sysdate     => com_api_const_pkg.FALSE
                    );
                elsif l_is_separator = com_api_const_pkg.TRUE and substr(l_tc_buffer(1), 1, 62) = lpad('Z', 62, 'Z') then
                    process_dispute_file_trailer (
                        i_trailer_data     => l_tc_buffer(1)
                      , io_cup_file        => l_cup_file
                    );
                else
                    --process_dispute
                    process_dispute(
                        i_tc_buffer        => l_tc_buffer(1)
                      , i_cup_file         => l_cup_file
                      , i_is_issuer        => l_is_issuer
                      , i_create_operation => i_create_operation
                      , i_standard_id      => l_standard_id
                      , i_session_file_id  => r.session_file_id
                    );
                    l_record_number := l_record_number + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_number
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;

            trc_log_pkg.debug (
                i_text          => 'file processing end'
            );

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_cup_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_number := l_record_number + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_number
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;

        if l_is_separator = com_api_const_pkg.FALSE then
            process_dispute_file_trailer (
                i_trailer_data  => null
              , io_cup_file     => l_cup_file
            );
        end if;

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_number
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text          => 'cup_prc_incoming_pkg.load_dispute finish'
    );

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end load_dispute;

procedure load_audit_trailer (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
) is
    l_tc_buffer             cup_api_type_pkg.t_tc_buffer;
    l_cup_file              cup_api_type_pkg.t_cup_file_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_session_id            com_api_type_pkg.t_long_id;
    l_is_separator          com_api_type_pkg.t_boolean;
    l_is_issuer             com_api_type_pkg.t_boolean;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = l_session_id
           and a.session_file_id = b.id;

begin
    trc_log_pkg.debug(
        i_text        => 'cup_prc_incoming_pkg.load_audit_trailer start. i_network_id [#1] i_action_code [#2] i_dst_inst_id [#3]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_action_code
      , i_env_param3  => i_dst_inst_id
    );

    prc_api_stat_pkg.log_start;

    l_session_id   := prc_api_session_pkg.get_session_id;
    l_record_count := 0;

    -- get estimated count
    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count    => l_record_count
    );

    trc_log_pkg.debug (
        i_text          => 'estimation record = ' || l_record_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id => i_network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    trc_log_pkg.debug (
        i_text          => 'load_audit_trailer: host_id[#1] standard_id[#2]'
        , i_env_param1  => l_host_id
        , i_env_param2  => l_standard_id
    );

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = l_session_id
         order by id
    ) loop
        l_errors_count := 0;
        if substr(p.file_name, 12, 1) = 'I' then
            l_is_issuer := com_api_const_pkg.TRUE;
        else
            l_is_issuer := com_api_const_pkg.FALSE;
        end if;
        if substr(p.file_name, 13, 4) = 'COMB' then
            l_is_separator := com_api_const_pkg.TRUE;
        else
            l_is_separator := com_api_const_pkg.FALSE;

            process_dispute_file_header(
                i_header_data     => null
              , i_network_id      => i_network_id
              , i_action_code     => i_action_code
              , i_dst_inst_id     => i_dst_inst_id
              , i_file_type       => trim(substr(p.file_name, 12, 5))
              , o_cup_file        => l_cup_file
              , i_session_file_id => p.session_file_id
              , i_use_sysdate     => com_api_const_pkg.TRUE
            );
        end if;

        begin
            savepoint sp_cup_incoming_file;
            trc_log_pkg.debug (
                i_text          => 'file processing start: session_file_id=' || p.session_file_id
            );

            for r in (
                select record_number
                     , raw_data
                     , session_file_id
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            -- processing current file
            loop
                g_error_flag := com_api_const_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1)  := r.raw_data;

                if l_is_separator = com_api_const_pkg.TRUE and substr(l_tc_buffer(1), 1, 62) = lpad(' ', 62) then
                    process_dispute_file_header(
                        i_header_data     => l_tc_buffer(1)
                      , i_network_id      => i_network_id
                      , i_action_code     => i_action_code
                      , i_dst_inst_id     => i_dst_inst_id
                      , i_file_type       => trim(substr(p.file_name, 12, 5))
                      , o_cup_file        => l_cup_file
                      , i_session_file_id => r.session_file_id
                      , i_use_sysdate     => com_api_const_pkg.FALSE
                    );
                elsif l_is_separator = com_api_const_pkg.TRUE and substr(l_tc_buffer(1), 1, 62) = lpad('Z', 62, 'Z') then
                    process_dispute_file_trailer (
                        i_trailer_data     => l_tc_buffer(1)
                      , io_cup_file        => l_cup_file
                    );
                else
                    --process_audit_trailer
                    process_audit_trailer(
                        i_tc_buffer        => l_tc_buffer(1)
                      , i_cup_file         => l_cup_file
                      , i_is_issuer        => l_is_issuer
                    );
                    l_record_number := l_record_number + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_number
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;

            trc_log_pkg.debug (
                i_text          => 'file processing end'
            );

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_cup_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_number := l_record_number + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_number
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;

        if l_is_separator = com_api_const_pkg.FALSE then
            process_dispute_file_trailer (
                i_trailer_data  => null
              , io_cup_file     => l_cup_file
            );
        end if;

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_number
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text          => 'cup_prc_incoming_pkg.load_audit_trailer finish'
    );

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end load_audit_trailer;

procedure load_fee_collection (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code default '0' -- possible value '1' for test processing
  , i_dst_inst_id           in     com_api_type_pkg.t_inst_id   default null
  , i_create_operation      in     com_api_type_pkg.t_boolean   default null
)
is
    l_tc_buffer             cup_api_type_pkg.t_tc_buffer;
    l_cup_file              cup_api_type_pkg.t_cup_file_rec;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_session_id            com_api_type_pkg.t_long_id;
    l_is_separator          com_api_type_pkg.t_boolean;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = l_session_id
           and a.session_file_id = b.id;

begin
    trc_log_pkg.debug(
        i_text        => 'cup_prc_incoming_pkg.load_fee_collection start. i_network_id [#1] i_action_code [#2] i_dst_inst_id [#3]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_action_code
      , i_env_param3  => i_dst_inst_id
    );

    prc_api_stat_pkg.log_start;

    l_session_id   := prc_api_session_pkg.get_session_id;
    l_record_count := 0;

    -- get estimated count
    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count    => l_record_count
    );

    trc_log_pkg.debug (
        i_text          => 'estimation record = ' || l_record_count
    );

    -- get network communication standard
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id => i_network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard(
                         i_host_id => l_host_id
                     );

    trc_log_pkg.debug (
        i_text          => 'load_fee_collection: host_id[#1] standard_id[#2]'
        , i_env_param1  => l_host_id
        , i_env_param2  => l_standard_id
    );

    for p in (
        select id as session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = l_session_id
         order by id
    ) loop
        l_errors_count := 0;
        if substr(p.file_name, 13, 4) = 'FCPB' then
            l_is_separator := com_api_const_pkg.TRUE;
        else
            l_is_separator := com_api_const_pkg.FALSE;

            process_dispute_file_header(
                i_header_data     => null
              , i_network_id      => i_network_id
              , i_action_code     => i_action_code
              , i_dst_inst_id     => i_dst_inst_id
              , i_file_type       => trim(substr(p.file_name, 12, 5))
              , o_cup_file        => l_cup_file
              , i_session_file_id => p.session_file_id
              , i_use_sysdate     => com_api_const_pkg.TRUE
            );
        end if;

        begin
            savepoint sp_cup_incoming_file;
            trc_log_pkg.debug (
                i_text          => 'file processing start: session_file_id=' || p.session_file_id
            );

            for r in (
                select record_number
                     , raw_data
                     , session_file_id
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            -- processing current file
            loop
                g_error_flag := com_api_const_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1)  := r.raw_data;

                if l_is_separator = com_api_const_pkg.TRUE and substr(l_tc_buffer(1), 1, 62) = lpad(' ', 62) then
                    process_dispute_file_header(
                        i_header_data     => l_tc_buffer(1)
                      , i_network_id      => i_network_id
                      , i_action_code     => i_action_code
                      , i_dst_inst_id     => i_dst_inst_id
                      , i_file_type       => trim(substr(p.file_name, 12, 5))
                      , o_cup_file        => l_cup_file
                      , i_session_file_id => r.session_file_id
                      , i_use_sysdate     => com_api_const_pkg.FALSE
                    );
                elsif l_is_separator = com_api_const_pkg.TRUE and substr(l_tc_buffer(1), 1, 62) = lpad('Z', 62, 'Z') then
                    process_dispute_file_trailer (
                        i_trailer_data     => l_tc_buffer(1)
                      , io_cup_file        => l_cup_file
                    );
                else
                    --process_fee_collection
                    process_fee_collection(
                        i_tc_buffer        => l_tc_buffer(1)
                      , i_cup_file         => l_cup_file
                      , i_create_operation => i_create_operation
                      , i_standard_id      => l_standard_id
                      , i_session_file_id  => r.session_file_id
                    );
                    l_record_number := l_record_number + 1;
                end if;

                -- cleanup buffer before loading next record(s)
                l_tc_buffer.delete;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_number
                      , i_excepted_count => l_errors_count
                    );
                end if;

            end loop;

            trc_log_pkg.debug (
                i_text          => 'file processing end'
            );

        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_cup_incoming_file;

                l_errors_count := l_errors_count + p.record_count;
                l_record_number := l_record_number + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_number
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );

                raise;
        end;

        if l_is_separator = com_api_const_pkg.FALSE then
            process_dispute_file_trailer (
                i_trailer_data  => null
              , io_cup_file     => l_cup_file
            );
        end if;

    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_number
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text          => 'cup_prc_incoming_pkg.load_fee_collection finish'
    );

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end load_fee_collection;

end cup_prc_incoming_pkg;
/
