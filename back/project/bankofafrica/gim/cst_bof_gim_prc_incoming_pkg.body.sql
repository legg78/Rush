create or replace package body cst_bof_gim_prc_incoming_pkg as

type t_amount_count_tab is table of integer index by com_api_type_pkg.t_curr_code;

g_filedate          date                       := null;
g_error_flag        com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
g_errors_count      com_api_type_pkg.t_long_id := 0;

CLRF       constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);

function get_inst_id_by_proc_bin(
    i_proc_bin             in     com_api_type_pkg.t_name
  , i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_inst_id_by_proc_bin: ';
    l_proc_bin             com_api_type_pkg.t_name;
    l_result               com_api_type_pkg.t_inst_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
begin
    for r in (
        select m.inst_id
             , i.host_member_id host_id
          from net_interface i
             , net_member m
         where m.network_id = i_network_id
           and m.id         = i.consumer_member_id
    ) loop
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'inst_id [#1], standard_id [#2], host_id [#3]'
          , i_env_param1 => r.inst_id
          , i_env_param2 => i_standard_id
          , i_env_param3 => r.host_id
        );
        begin
            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => r.inst_id
              , i_standard_id  => i_standard_id
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => r.host_id
              , i_param_name   => cst_bof_gim_api_const_pkg.CMID
              , o_param_value  => l_proc_bin
              , i_param_tab    => l_param_tab
            );
        exception
            when com_api_error_pkg.e_application_error then
                null;
        end;

        if trim(l_proc_bin) = trim(i_proc_bin) then
            l_result :=  r.inst_id;
            exit;
        end if;

    end loop;

    return l_result;
end;

procedure init_fin_record(
    io_gim                 in out cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
) is
begin
    io_gim.id           := null;
    io_gim.is_incoming  := com_api_const_pkg.TRUE;
    io_gim.is_returned  := com_api_const_pkg.FALSE;
    io_gim.is_invalid   := com_api_const_pkg.FALSE;
    io_gim.is_reversal  := com_api_const_pkg.FALSE;
end;

function date_ddmmyy(
    p_date                 in varchar2
) return date is
begin
    return
        case
            when trim(p_date) is null or p_date = '000000'
            then null
            else to_date(p_date, 'DDMMYY')
        end;
exception
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'GIM_WRONG_DATETIME'
          , i_env_param1 => p_date
          , i_env_param3 => sqlerrm
        );
end;

function date_ddmmyy(
    p_date                 in varchar2
  , p_time                 in varchar2
) return date
is
    l_time                    varchar2(6);
begin
    l_time := lpad(nvl(trim(p_time), '0'), 6, '0');

    return
        case
            when trim(p_date) is null or p_date = '000000'
            then null
            else to_date(p_date || l_time, 'DDMMYYhh24miss')
        end;
exception
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'GIM_WRONG_DATETIME'
          , i_env_param1 => p_date
          , i_env_param2 => p_time
          , i_env_param3 => sqlerrm
        );
end;

function date_yymm(
    p_date                 in varchar2
) return date is
begin
    if p_date is null or p_date = '0000' then
        return null;
    end if;

    return to_date(p_date, 'YYMM');
end;

function date_mmyy(
    p_date                 in varchar2
) return date is
begin
    if p_date is null or p_date = '0000' then
        return null;
    end if;

    return to_date(p_date, 'MMYY');
end;

function date_mmdd(
    p_date                 in varchar2
) return date is
    l_century                 varchar2(4) := to_char(g_filedate, 'YYYY');
    l_dt                      date;
begin
    if trim(p_date) is null or p_date = '0000' then
        return null;
    end if;
    l_dt := to_date(l_century || p_date, 'YYYYMMDD');
    if l_dt > g_filedate then
        l_century := to_char(to_number(l_century) - 1);
        l_dt := to_date(l_century || p_date, 'YYYYMMDD');
        if abs(months_between(l_dt, g_filedate)) > 11 then
            l_century := to_char(g_filedate, 'YYYY');
            l_dt := to_date(l_century || p_date, 'YYYYMMDD');
        end if;
    end if;

    return l_dt;
end;

function date_yddd(
    p_date                 in varchar2
) return date is
    v_century                 varchar2(4) := to_char(g_filedate, 'YYYY');
    v_dt                      date;
begin
    if p_date is null then
        return null;
    end if;

    if p_date = '0000' then
        return trunc(g_filedate);
    end if;
    v_dt := to_date(substr(v_century, 1, 3) || p_date, 'YYYYDDD');

    return v_dt;
end;

function date_yyyyddd(
    p_date                 in varchar2
) return date is
begin
    return
        case
            when trim(p_date) is null or p_date = '0000000'
            then null
            else to_date(p_date, 'YYYYDDD')
        end;
end;

function date_yymmdd(
    p_date                 in varchar2
) return date is
begin
    return
        case
            when trim(p_date) is null or p_date = '000000'
            then null
            else to_date(p_date, 'YYMMDD')
        end;
end;

function prepare_amount(
    i_amount_str           in            com_api_type_pkg.t_original_data
  , i_curr_code            in            com_api_type_pkg.t_curr_code
  , i_exponent             in            com_api_type_pkg.t_tiny_id       default null
  , i_amount_desc          in            com_api_type_pkg.t_name
) return com_api_type_pkg.t_money
is
    l_file_currency_exponent             com_api_type_pkg.t_tiny_id;
    l_table_currency_exponent            com_api_type_pkg.t_tiny_id;
    l_result                             com_api_type_pkg.t_money;
begin
    l_table_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                     i_curr_code => i_curr_code
                                 );

    l_file_currency_exponent  := coalesce(i_exponent, l_table_currency_exponent);

    l_result := to_number(i_amount_str) / power(10, l_file_currency_exponent) * power(10, l_table_currency_exponent);

    return l_result;
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_invalid_number then
        com_api_error_pkg.raise_error(
            i_error      => 'GIM_WRONG_AMOUNT_VALUE'
          , i_env_param1 => i_amount_str
          , i_env_param2 => i_curr_code
          , i_env_param3 => i_amount_desc
        );
end;

procedure count_amount(
    io_amount_tab          in out nocopy t_amount_count_tab
  , i_sttl_amount          in            com_api_type_pkg.t_money
  , i_sttl_currency        in            com_api_type_pkg.t_curr_code
) is
begin
    if io_amount_tab.exists(nvl(i_sttl_currency, '')) then
        io_amount_tab(nvl(i_sttl_currency, '')) := nvl(io_amount_tab(nvl(i_sttl_currency, '')), 0) + i_sttl_amount;
    else
        io_amount_tab(nvl(i_sttl_currency, '')) := i_sttl_amount;
    end if;
end;

function get_tc_buffer_str(
    i_tc_buffer            in            cst_bof_gim_api_type_pkg.t_tc_buffer
) return com_api_type_pkg.t_text
is
    l_result    com_api_type_pkg.t_text;
begin
   if i_tc_buffer.count > 0 then
       for i in i_tc_buffer.first .. i_tc_buffer.last loop
           l_result := l_result || CLRF
                    || 'i_tc_buffer[' || i || '] = ['
                    || case
                           when i != 1
                           then i_tc_buffer(i)
                           -- Masking card number for TCR = 1
                           else substr(i_tc_buffer(i), 1, 149 + 6)
                             || lpad('*', 9, '*')
                             || substr(i_tc_buffer(i), 149 + 19 - 4) -- last 4 digits of a PAN
                       end
                    || ']';
       end loop;
   end if;

   return l_result;
end;

procedure info_amount(
    i_amount_tab           in            t_amount_count_tab
) is
    l_result                com_api_type_pkg.t_name;
begin
    l_result := i_amount_tab.first;
    loop
        exit when l_result is null;

        trc_log_pkg.info(
            i_text        => 'Settlement currency [#1] amount [#2]'
          , i_env_param1  => l_result
          , i_env_param2  => com_api_currency_pkg.get_amount_str(
                                 i_amount          => i_amount_tab(l_result)
                               , i_curr_code       => l_result
                               , i_mask_curr_code  => com_api_const_pkg.TRUE
                               , i_mask_error      => com_api_const_pkg.TRUE
                             )
        );

        l_result := i_amount_tab.next(l_result);
    end loop;
end;

procedure process_file_header(
    i_header_data          in     varchar2
  , i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
  , i_session_file_id      in     com_api_type_pkg.t_long_id
  , o_gim_file                out cst_bof_gim_api_type_pkg.t_gim_file_rec
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_file_header ';
    l_count                       pls_integer;
begin
    o_gim_file.is_incoming     := com_api_const_pkg.TRUE;
    o_gim_file.proc_bin        := substr(i_header_data, 10, 6);
    o_gim_file.proc_date       := to_date(substr(i_header_data, 16, 6), 'DDMMYY');
    g_filedate                 := o_gim_file.proc_date;

    o_gim_file.release_number  := substr(i_header_data, 26, 15);
    o_gim_file.gim_file_id     := substr(i_header_data, 22, 3);
    o_gim_file.originator_bin  := substr(i_header_data, 41, 6);
    o_gim_file.file_status_ind := substr(i_header_data, 25, 1);

    begin
        select 1
          into l_count
          from cst_bof_gim_file
         where proc_date    = o_gim_file.proc_date
           and gim_file_id  = o_gim_file.gim_file_id
           and proc_bin     = o_gim_file.proc_bin;

        com_api_error_pkg.raise_error(
            i_error       => 'GIM_FILE_ALREADY_PROCESSED'
          , i_env_param1  => to_char(o_gim_file.proc_date, 'yyyy-mm-dd')
          , i_env_param2  => o_gim_file.gim_file_id
        );
    exception
        when no_data_found then
            null;
    end;

    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'UNKNOWN_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;

    -- determine internal institution number
    o_gim_file.inst_id :=
        get_inst_id_by_proc_bin(
            i_proc_bin       => o_gim_file.proc_bin
          , i_network_id     => i_network_id
          , i_standard_id    => i_standard_id
        );

    if o_gim_file.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'GIM_BIN_NOT_REGISTERED'
          , i_env_param1  => o_gim_file.proc_bin
          , i_env_param2  => i_network_id
          , i_env_param3 =>  o_gim_file.inst_id
        );
    end if;

    o_gim_file.session_file_id := i_session_file_id;
    o_gim_file.id := cst_bof_gim_file_seq.nextval;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED: i_header_data = [#1]'
          , i_env_param1 => i_header_data
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
end process_file_header;

procedure process_file_trailer(
    i_tc_buffer            in     cst_bof_gim_api_type_pkg.t_tc_buffer
  , io_gim_file            in out cst_bof_gim_api_type_pkg.t_gim_file_rec
) is
begin
    io_gim_file.total_phys_records := substr(i_tc_buffer(1), 10, 6);

    insert into cst_bof_gim_file (
        id
      , is_incoming
      , network_id
      , proc_bin
      , proc_date
      , release_number
      , gim_file_id
      , originator_bin
      , inst_id
      , session_file_id
      , total_phys_records
    ) values (
        io_gim_file.id
      , io_gim_file.is_incoming
      , io_gim_file.network_id
      , io_gim_file.proc_bin
      , io_gim_file.proc_date
      , io_gim_file.release_number
      , io_gim_file.gim_file_id
      , io_gim_file.originator_bin
      , io_gim_file.inst_id
      , io_gim_file.session_file_id
      , io_gim_file.total_phys_records
    );
end;

procedure process_logic_file(
    i_tc_buffer             in     cst_bof_gim_api_type_pkg.t_tc_buffer
  , io_logical_file         in out com_api_type_pkg.t_byte_char
) is
    l_logical_file    com_api_type_pkg.t_byte_char;
begin
    l_logical_file := substr(i_tc_buffer(1), 1, 2);
    if io_logical_file is not null then
        -- Missing trailer check
        if     (io_logical_file = cst_bof_gim_api_const_pkg.TC_FM_HEADER  and l_logical_file <> cst_bof_gim_api_const_pkg.TC_FM_TRAILER)
            or (io_logical_file = cst_bof_gim_api_const_pkg.TC_FV_HEADER  and l_logical_file <> cst_bof_gim_api_const_pkg.TC_FV_TRAILER)
            or (io_logical_file = cst_bof_gim_api_const_pkg.TC_FMC_HEADER and l_logical_file <> cst_bof_gim_api_const_pkg.TC_FMC_TRAILER)
            or (io_logical_file = cst_bof_gim_api_const_pkg.TC_FL_HEADER  and l_logical_file <> cst_bof_gim_api_const_pkg.TC_FL_TRAILER)
            or (io_logical_file = cst_bof_gim_api_const_pkg.TC_FSW_HEADER and l_logical_file <> cst_bof_gim_api_const_pkg.TC_FSW_TRAILER)
        then
            com_api_error_pkg.raise_error(
                i_error       => 'GIM_FILE_MISSING_LOGICAL_TRAILER'
              , i_env_param1  => io_logical_file
            );
        end if;
    end if;

    if l_logical_file in (
           cst_bof_gim_api_const_pkg.TC_FM_HEADER
         , cst_bof_gim_api_const_pkg.TC_FV_HEADER
         , cst_bof_gim_api_const_pkg.TC_FMC_HEADER
         , cst_bof_gim_api_const_pkg.TC_FL_HEADER
         , cst_bof_gim_api_const_pkg.TC_FSW_HEADER
       )
    then
         io_logical_file := l_logical_file;

    elsif l_logical_file in (
              cst_bof_gim_api_const_pkg.TC_FSW_TRAILER
            , cst_bof_gim_api_const_pkg.TC_FL_TRAILER
            , cst_bof_gim_api_const_pkg.TC_FMC_TRAILER
            , cst_bof_gim_api_const_pkg.TC_FV_TRAILER
            , cst_bof_gim_api_const_pkg.TC_FM_TRAILER
          )
    then
        io_logical_file := null;
    end if;
end;

function get_card_number(
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_oper_id             in     com_api_type_pkg.t_long_id
  , io_is_invalid         in out com_api_type_pkg.t_boolean
  , i_mask_error          in     com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_card_number
is
    LOG_PREFIX              constant com_api_type_pkg.t_name     := lower($$PLSQL_UNIT) || '.get_card_number: ';
    DEFAULT_CARD_LENGTH     constant com_api_type_pkg.t_tiny_id  := 19;

    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_curr_code;
    l_pan_length            com_api_type_pkg.t_tiny_id;
    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_number [#1], i_network_id [' || i_network_id || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
    );

    iss_api_bin_pkg.get_bin_info(
        i_card_number      => i_card_number
      , o_iss_inst_id      => l_iss_inst_id
      , o_iss_network_id   => l_iss_network_id
      , o_iss_host_id      => l_iss_host_id
      , o_card_type_id     => l_card_type_id
      , o_card_country     => l_card_country
      , o_card_inst_id     => l_card_inst_id
      , o_card_network_id  => l_card_network_id
      , o_pan_length       => l_pan_length
      , i_raise_error      => com_api_const_pkg.FALSE
    );
    trc_log_pkg.debug(
        i_text => 'iss_api_bin_pkg.get_bin_info: '
               || 'l_card_inst_id [' || l_card_inst_id
               || '], l_pan_length [' || l_pan_length || ']'
    );

    if l_card_inst_id is null then
        net_api_bin_pkg.get_bin_info(
            i_card_number      => i_card_number
          , i_network_id       => i_network_id
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_host_id      => l_iss_host_id
          , o_card_type_id     => l_card_type_id
          , o_card_country     => l_card_country
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_pan_length       => l_pan_length
          , i_raise_error      => com_api_const_pkg.FALSE
        );
        trc_log_pkg.debug(
            i_text => 'net_api_bin_pkg.get_bin_info: '
                   || 'l_card_inst_id [' || l_card_inst_id
                   || '], l_pan_length [' || l_pan_length || ']'
        );
    end if;

    if l_pan_length is null then
        if i_mask_error = com_api_const_pkg.TRUE then
            l_pan_length := DEFAULT_CARD_LENGTH;
        else
            io_is_invalid    := com_api_const_pkg.TRUE;
            l_pan_length     := length(i_card_number);

            trc_log_pkg.warn(
                i_text        => 'UNKNOWN_BIN_CARD_NUMBER_NETWORK'
              , i_env_param1  => substr(i_card_number, 1, 6)
              , i_env_param2  => i_network_id
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => i_oper_id
            );
        end if;
    end if;

    if l_pan_length = 0 then
        l_pan_length := 16;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END; l_pan_length [' || l_pan_length || ']');

    return substr(i_card_number, 1, l_pan_length);
end;

procedure assign_dispute(
    io_gim                 in out nocopy cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_standard_id          in            com_api_type_pkg.t_tiny_id
  , o_iss_inst_id             out        com_api_type_pkg.t_inst_id
  , o_iss_network_id          out        com_api_type_pkg.t_tiny_id
  , o_acq_inst_id             out        com_api_type_pkg.t_inst_id
  , o_acq_network_id          out        com_api_type_pkg.t_tiny_id
  , o_sttl_type               out        com_api_type_pkg.t_dict_value
  , o_match_status            out        com_api_type_pkg.t_dict_value
) is
    l_dispute_id                         com_api_type_pkg.t_long_id;
    l_is_incoming                        com_api_type_pkg.t_boolean;
    l_card_number_enc                    com_api_type_pkg.t_card_number;

    cursor match_cur(
        i_card_number    in    com_api_type_pkg.t_card_number
      , i_is_incoming    in    com_api_type_pkg.t_boolean
      , i_arn            in    cst_bof_gim_api_type_pkg.t_arn
    ) is
    select min(m.id)           as id
         , min(m.dispute_id)   as dispute_id
         , min(m.card_id)      as card_id
         , io_gim.card_number  as card_number
         , min(o.sttl_type)    as sttl_type
         , min(o.match_status) as match_status
         , min(o.status)       as status
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER,   p.inst_id,    null)) as iss_inst_id
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER,   p.network_id, null)) as iss_network_id
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id,    null)) as acq_inst_id
         , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) as acq_network_id
      from cst_bof_gim_fin_msg m
         , cst_bof_gim_card c
         , opr_operation o
         , opr_participant p
     where m.usage_code  = '1'
       and m.arn         = i_arn
       and (    m.is_incoming = i_is_incoming
            and m.trans_code in (cst_bof_gim_api_const_pkg.TC_SALES
                               , cst_bof_gim_api_const_pkg.TC_VOUCHER
                               , cst_bof_gim_api_const_pkg.TC_CASH)
            or
                m.is_incoming = case
                                    when i_is_incoming = com_api_const_pkg.TRUE
                                    then com_api_const_pkg.FALSE
                                    else com_api_const_pkg.TRUE
                                end
            and m.trans_code = cst_bof_gim_api_const_pkg.TC_TRANSACTION_ADVICE
            and m.transaction_type in (cst_bof_gim_api_const_pkg.TT_CHRGBCK_REMITTANCE
                                     , cst_bof_gim_api_const_pkg.TT_CHRGBCK_CARDLESS_WITHDRAWAL
                                     , cst_bof_gim_api_const_pkg.TT_CHRGBCK_PURCHASE
                                     , cst_bof_gim_api_const_pkg.TT_CHRGBCK_CREDIT_VOUCHER
                                     , cst_bof_gim_api_const_pkg.TT_CHRGBCK_CASH_ADVANCE
                                     , cst_bof_gim_api_const_pkg.TT_CHRGBCK_WITHDRAWAL)
           )
       and c.card_number = i_card_number
       and c.id          = m.id
       and o.id          = m.id
       and p.oper_id     = o.id
    ;
begin
    trc_log_pkg.debug(
        i_text        => 'assign_dispute: card_number[#1], arn[#2]'
      , i_env_param1  => iss_api_card_pkg.get_card_mask(io_gim.card_number)
      , i_env_param2  => io_gim.arn
    );

    case
        when io_gim.trans_code in (
                 cst_bof_gim_api_const_pkg.TC_REQUEST_ORIGINAL_PAPER
               , cst_bof_gim_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
             )
        then
            l_is_incoming := com_api_const_pkg.FALSE;
        when io_gim.trans_code in (
                 cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
               , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
               , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK
               , cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK_REV
               , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
               , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK_REV
             )
        then
            l_is_incoming := com_api_const_pkg.FALSE;
        else
            l_is_incoming := com_api_const_pkg.TRUE;
    end case;

    trc_log_pkg.debug(
        i_text        => 'l_is_incoming [#1]'
      , i_env_param1  => l_is_incoming
    );

    l_card_number_enc := iss_api_token_pkg.encode_card_number(i_card_number => io_gim.card_number);

    for rec in match_cur(
                   i_card_number  => l_card_number_enc
                 , i_arn          => io_gim.arn
                 , i_is_incoming  => l_is_incoming
               )
    loop
        if rec.id is not null then
            io_gim.dispute_id  := rec.id;
            io_gim.card_id     := rec.card_id;
            io_gim.card_number := rec.card_number;
            if rec.status = opr_api_const_pkg.OPERATION_STATUS_MANUAL then
                io_gim.is_invalid := com_api_const_pkg.TRUE;
            end if;

            l_dispute_id        := rec.dispute_id;
            o_iss_inst_id       := rec.iss_inst_id;
            o_iss_network_id    := rec.iss_network_id;
            o_acq_inst_id       := rec.acq_inst_id;
            o_acq_network_id    := rec.acq_network_id;
            o_sttl_type         := rec.sttl_type;
            o_match_status      := rec.match_status;

            trc_log_pkg.debug(
                i_text        => 'Original message found. id = [#1], o_iss_inst_id = [#2]'
              , i_env_param1  => rec.id
              , i_env_param2  => o_iss_inst_id
            );
        end if;

        exit;
    end loop;

    if io_gim.dispute_id is null then
        trc_log_pkg.warn(
            i_text         => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
          , i_env_param1   => io_gim.id
          , i_env_param2   => io_gim.arn
          , i_env_param3   => iss_api_card_pkg.get_card_mask(io_gim.card_number)
          , i_env_param4   => com_api_type_pkg.convert_to_char(io_gim.oper_date)
          , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id    => io_gim.id
        );
        io_gim.is_invalid := com_api_const_pkg.TRUE;
    end if;

    -- Aassign a new dispute ID
    if l_dispute_id is null then
        update cst_bof_gim_fin_msg
           set dispute_id = io_gim.dispute_id
         where id         = io_gim.dispute_id;

        update opr_operation
           set dispute_id = io_gim.dispute_id
         where id         = io_gim.dispute_id;
    end if;

end assign_dispute;

procedure get_acq_network_id(
    i_terminal_number         in     com_api_type_pkg.t_terminal_number
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_network_id              in     com_api_type_pkg.t_network_id
  , i_trans_type              in     com_api_type_pkg.t_byte_char               default null
  , o_acq_inst_id                out com_api_type_pkg.t_inst_id
  , o_acq_network_id             out com_api_type_pkg.t_network_id
  , o_is_terminal_found          out com_api_type_pkg.t_boolean
) is
    l_merchant_number                com_api_type_pkg.t_merchant_number;
    l_merchant_id                    com_api_type_pkg.t_short_id;
    l_terminal_id                    com_api_type_pkg.t_short_id;
begin
    if nvl(i_trans_type, '*') = '0' then
        acq_api_terminal_pkg.get_merchant(
            i_terminal_number  => i_terminal_number
          , i_inst_id          => i_inst_id
          , o_merchant_number  => l_merchant_number
          , o_merchant_id      => l_merchant_id
          , o_terminal_id      => l_terminal_id
          , i_mask_error       => com_api_const_pkg.TRUE
        );
    end if;
    trc_log_pkg.debug(i_text => 'trans_type [' || i_trans_type || ']; l_tcr [0]; i_terminal_number [' || i_terminal_number || ']; i_inst_id [' || to_char(i_inst_id) || ']');

    if l_merchant_number is not null then
        o_acq_network_id    := ost_api_institution_pkg.get_inst_network(
                                   i_inst_id => i_inst_id
                               );
        o_acq_inst_id       := i_inst_id;
        o_is_terminal_found := com_api_const_pkg.TRUE;
    elsif i_trans_type = '0' then
        o_acq_network_id    := ost_api_institution_pkg.get_inst_network(
                                   i_inst_id => i_inst_id
                               );
        o_acq_inst_id       := i_inst_id;
        o_is_terminal_found := com_api_const_pkg.FALSE;
    else
        o_acq_network_id    := i_network_id;
        o_acq_inst_id       := net_api_network_pkg.get_inst_id(
                                   i_network_id => i_network_id
                               );
        o_is_terminal_found := com_api_const_pkg.FALSE;
    end if;
end get_acq_network_id;

procedure process_draft(
    i_tc_buffer            in            cst_bof_gim_api_type_pkg.t_tc_buffer
  , i_network_id           in            com_api_type_pkg.t_tiny_id
  , i_host_id              in            com_api_type_pkg.t_tiny_id
  , i_standard_id          in            com_api_type_pkg.t_tiny_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_proc_date            in            date
  , i_file_id              in            com_api_type_pkg.t_long_id
  , i_session_file_id      in            com_api_type_pkg.t_long_id
  , i_record_number        in            com_api_type_pkg.t_short_id
  , i_proc_bin             in            com_api_type_pkg.t_bin
  , i_originator_bin       in            com_api_type_pkg.t_bin
  , io_amount_tab          in out nocopy t_amount_count_tab
  , i_create_operation     in            com_api_type_pkg.t_boolean
  , io_no_original_id_tab  in out nocopy cst_bof_gim_api_type_pkg.t_gim_fin_mes_tab
  , i_logical_file         in            com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_draft ';
    l_gim                                cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec;
    l_recnum                             pls_integer := 1;
    l_tcr                                varchar2(1);
    l_iss_inst_id                        com_api_type_pkg.t_inst_id;
    l_acq_inst_id                        com_api_type_pkg.t_inst_id;
    l_card_inst_id                       com_api_type_pkg.t_inst_id;
    l_iss_network_id                     com_api_type_pkg.t_network_id;
    l_acq_network_id                     com_api_type_pkg.t_network_id;
    l_card_network_id                    com_api_type_pkg.t_network_id;
    l_card_type_id                       com_api_type_pkg.t_tiny_id;
    l_country_code                       com_api_type_pkg.t_country_code;
    l_bin_currency                       com_api_type_pkg.t_curr_code;
    l_sttl_currency                      com_api_type_pkg.t_curr_code;
    l_sttl_type                          com_api_type_pkg.t_dict_value;
    l_match_status                       com_api_type_pkg.t_dict_value;
    l_card_service_code                  com_api_type_pkg.t_curr_code;
    l_iss_inst_id2                       com_api_type_pkg.t_inst_id;
    l_iss_network_id2                    com_api_type_pkg.t_tiny_id;
    l_iss_host_id                        com_api_type_pkg.t_tiny_id;
    l_card_country                       com_api_type_pkg.t_country_code;
    l_pan_length                         com_api_type_pkg.t_tiny_id;
    l_oper                               opr_api_type_pkg.t_oper_rec;
    l_iss_part                           opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                           opr_api_type_pkg.t_oper_part_rec;
    l_operation                          opr_api_type_pkg.t_oper_rec;
    l_participant                        opr_api_type_pkg.t_oper_part_rec;
    l_need_original_id                   com_api_type_pkg.t_boolean;
    l_bin_rec                            iss_api_type_pkg.t_bin_rec;
    l_card_rec                           iss_api_type_pkg.t_card_rec;
    l_iss_reimb_fee_currency             com_api_type_pkg.t_curr_code;
    l_trans_type                         com_api_type_pkg.t_byte_char;
    l_is_terminal_found                  com_api_type_pkg.t_boolean;
    l_conv_iss_network_id                com_api_type_pkg.t_network_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_tc_buffer.count() = ' || i_tc_buffer.count()
                                   ||  ', io_amount_tab.count() = ' || io_amount_tab.count()
                                   ||  ', i_inst_id [' || i_inst_id
                                   || '], i_file_id [' || i_file_id
                                   || '], i_record_number [' || i_record_number
                                   || '], i_create_operation [' || i_create_operation
                                   || '], i_proc_date [#1], i_proc_bin [#2]'
      , i_env_param1 => to_char(i_proc_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param2 => i_proc_bin
    );

    -- Message specific fields
    -- data from TCR0
    init_fin_record(l_gim);
    l_gim.id                   := opr_api_create_pkg.get_id;
    l_gim.trans_code           := substr(i_tc_buffer(l_recnum), 1, 2);
    l_tcr                      := substr(i_tc_buffer(l_recnum), 9, 1);
    l_gim.logical_file         := i_logical_file;
    l_gim.file_id              := i_file_id;
    l_gim.record_number        := i_record_number;

    l_gim.is_reversal :=
        case
            when l_gim.trans_code in (
                     cst_bof_gim_api_const_pkg.TC_SALES_REVERSAL
                   , cst_bof_gim_api_const_pkg.TC_VOUCHER_REVERSAL
                   , cst_bof_gim_api_const_pkg.TC_CASH_REVERSAL
                   , cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK_REV
                   , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                   , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK_REV
                 )
            then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;

    l_gim.merchant_number      := substr(i_tc_buffer(l_recnum), 11, 15);
    l_gim.merchant_name        := substr(i_tc_buffer(l_recnum), 26, 25);
    l_gim.merchant_city        := substr(i_tc_buffer(l_recnum), 51, 13);
    l_gim.merchant_country     := trim(substr(i_tc_buffer(l_recnum), 64, 3));
    l_gim.mcc                  := substr(i_tc_buffer(l_recnum), 67, 4);
    l_gim.merchant_type        := substr(i_tc_buffer(l_recnum), 71, 1);
    l_gim.spec_cond_ind        := substr(i_tc_buffer(l_recnum), 72, 2);
    l_gim.electronic_term_ind  := substr(i_tc_buffer(l_recnum), 74, 1);
    l_gim.terminal_number      := substr(i_tc_buffer(l_recnum), 75, 8);
    l_gim.usage_code           := substr(i_tc_buffer(l_recnum), 83, 1);
    l_gim.reconciliation_ind   := substr(i_tc_buffer(l_recnum), 84, 3);
    l_gim.member_msg_text      := substr(i_tc_buffer(l_recnum), 87, 50);
    l_gim.reason_code          := substr(i_tc_buffer(l_recnum), 137, 4);
    l_gim.chargeback_ref_num   := substr(i_tc_buffer(l_recnum), 141, 6);
    l_gim.docum_ind            := substr(i_tc_buffer(l_recnum), 147, 1);
    l_gim.payment_product_ind  := substr(i_tc_buffer(l_recnum), 148, 1);

    l_conv_iss_network_id      :=
        to_number(
            com_api_array_pkg.conv_array_elem_v(
                i_array_type_id     => cst_bof_gim_api_const_pkg.ARRAY_TYPE_GIM_PMNT_PROD_INDX
                , i_array_id        => cst_bof_gim_api_const_pkg.ARRAY_GIM_PMNT_PROD_INDX
                , i_inst_id         => i_inst_id
                , i_elem_value      => l_gim.payment_product_ind
                , i_mask_error      => com_api_type_pkg.TRUE
            )
        );

    l_gim.card_number :=
        get_card_number(
            i_card_number => trim(substr(i_tc_buffer(l_recnum), 149, 19))
          , i_network_id  => i_network_id
          , i_oper_id     => l_gim.id
          , io_is_invalid => l_gim.is_invalid
        );
    l_gim.card_hash            := com_api_hash_pkg.get_card_hash(i_card_number => l_gim.card_number);
    l_gim.card_mask            := iss_api_card_pkg.get_card_mask(i_card_number => l_gim.card_number);

    l_gim.card_expir_date      := substr(i_tc_buffer(l_recnum), 168, 4);
    l_gim.crdh_id_method       := substr(i_tc_buffer(l_recnum), 172, 1);
    l_gim.crdh_cardnum_cap_ind := substr(i_tc_buffer(l_recnum), 173, 1);
    l_gim.account_selection    := substr(i_tc_buffer(l_recnum), 174, 2);
    l_gim.trans_status         := substr(i_tc_buffer(l_recnum), 176, 5);
    l_gim.trans_code_header    := substr(i_tc_buffer(l_recnum), 181, 2);
    l_trans_type               := substr(i_tc_buffer(l_recnum), 185, 1);

    l_recnum := 2;
    -- TCR1 data present
    if i_tc_buffer.exists(l_recnum) then
        l_tcr := substr(i_tc_buffer(l_recnum), 9, 1);
    end if;

    trc_log_pkg.debug(i_text => 'l_recnum [' || l_recnum || ']; l_tcr [' || l_tcr || ']');

    -- TCR1
    if l_tcr = '1' then
        l_gim.auth_code         := substr(i_tc_buffer(l_recnum), 16, 6);
        l_gim.auth_code_src_ind := substr(i_tc_buffer(l_recnum), 22, 1);
        l_gim.transaction_type  := substr(i_tc_buffer(l_recnum), 23, 1);
        l_gim.arn               := substr(i_tc_buffer(l_recnum), 24, 23);

        begin
            l_bin_rec :=
                iss_api_bin_pkg.get_bin(
                    i_bin         => substr(l_gim.card_number, 1, 6)
                  , i_mask_error  => com_api_const_pkg.TRUE
                );

            trc_log_pkg.debug(
                i_text       => 'BIN [#1] was found among issuing BINs: institution [#2], network [#3]'
              , i_env_param1 => l_bin_rec.bin
              , i_env_param2 => l_bin_rec.inst_id
              , i_env_param3 => l_bin_rec.network_id
            );

            l_gim.inst_id    := l_bin_rec.inst_id;
            l_gim.network_id := l_bin_rec.network_id;
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                    l_gim.inst_id      := null;
                    l_gim.network_id   := null;
                else
                    raise;
                end if;
        end;

        if l_gim.inst_id is null then
            l_gim.inst_id     := i_inst_id;
            l_gim.network_id  := i_network_id;
        end if;

        trc_log_pkg.debug(
            i_text => 'l_gim.inst_id [' || l_gim.inst_id
                   || '], l_gim.network_id [' || l_gim.network_id || ']'
        );

        l_gim.forw_inst_id        := substr(i_tc_buffer(l_recnum), 47, 8);
        l_gim.void_ind            := substr(i_tc_buffer(l_recnum), 55, 1);

        l_gim.oper_currency       := trim(substr(i_tc_buffer(l_recnum), 164, 3));
        l_gim.oper_amount :=
            prepare_amount(
                i_amount_str     => substr(i_tc_buffer(l_recnum), 57, 12)
              , i_curr_code      => l_gim.oper_currency
              , i_exponent       => substr(i_tc_buffer(l_recnum), 56, 1)
              , i_amount_desc    => 'Operation amount'
            );

        l_gim.receiv_inst_id      := substr(i_tc_buffer(l_recnum), 47, 8);
        l_gim.spec_chargeback_ind := substr(i_tc_buffer(l_recnum), 55, 1);

        l_gim.dest_currency       := trim(substr(i_tc_buffer(l_recnum), 167, 3));
        if l_gim.dest_currency is not null then
            l_gim.dest_amount :=
                prepare_amount(
                    i_amount_str     => substr(i_tc_buffer(l_recnum), 79, 12)
                  , i_curr_code      => l_gim.dest_currency
                  , i_exponent       => substr(i_tc_buffer(l_recnum), 78, 1)
                  , i_amount_desc    => 'Destination amount'
                );
        end if;
        l_gim.sttl_currency       := cst_bof_gim_api_const_pkg.GIM_CURR_CODE;
        l_gim.sttl_amount :=
            prepare_amount(
                i_amount_str     => substr(i_tc_buffer(l_recnum), 91, 12)
              , i_curr_code      => cst_bof_gim_api_const_pkg.GIM_CURR_CODE
              , i_amount_desc    => 'Settlement amount'
            );

        l_iss_reimb_fee_currency := case
                                        when trim(l_gim.dest_currency) is null
                                          or to_number(l_gim.dest_currency) = 0
                                        then l_gim.sttl_currency
                                        else l_gim.dest_currency
                                    end;

        l_gim.iss_reimb_fee :=
            prepare_amount(
                i_amount_str     => substr(i_tc_buffer(l_recnum), 103, 12)
              , i_curr_code      => l_iss_reimb_fee_currency
              , i_amount_desc    => 'iss_reimb_fee'
            );

        l_gim.value_date               := date_ddmmyy(substr(i_tc_buffer(l_recnum), 115, 6));
        l_gim.trans_inter_proc_date    := date_ddmmyy(substr(i_tc_buffer(l_recnum), 121, 6));
        l_gim.merchant_region          := substr(i_tc_buffer(l_recnum), 127, 3);

        l_gim.voucher_dep_bank_code    := substr(i_tc_buffer(l_recnum), 131, 2);
        l_gim.voucher_dep_branch_code  := substr(i_tc_buffer(l_recnum), 133, 4);
        l_gim.card_seq_number          := substr(i_tc_buffer(l_recnum), 137, 3);
        l_gim.reconciliation_date      := date_ddmmyy(substr(i_tc_buffer(l_recnum), 140, 6));
        l_gim.rrn                      := substr(i_tc_buffer(l_recnum), 146, 12);
        l_gim.oper_date :=
            date_ddmmyy(
                p_date => substr(i_tc_buffer(l_recnum), 10, 6)
              , p_time => substr(i_tc_buffer(l_recnum), 158, 6)
            );

        l_gim.merch_serv_charge     := substr(i_tc_buffer(l_recnum), 170, 12);
        l_gim.acq_msc_revenue       := substr(i_tc_buffer(l_recnum), 182, 12);
        l_gim.electr_comm_ind       := substr(i_tc_buffer(l_recnum), 194, 1);

        l_gim.crdh_billing_amount   := substr(i_tc_buffer(l_recnum), 195, 12);
        l_gim.rate_dst_loc_currency := substr(i_tc_buffer(l_recnum), 207, 9);
        l_gim.rate_loc_dst_currency := substr(i_tc_buffer(l_recnum), 216, 9);
    end if;

    l_recnum := 4;
    -- TCR3 data present
    if i_tc_buffer.exists(l_recnum) then
        l_tcr := substr(i_tc_buffer(l_recnum), 9, 1);
    end if;

    -- TCR3
    if l_tcr = '3' then
        l_gim.cryptogram           := substr(i_tc_buffer(l_recnum), 10, 16);
        l_gim.cryptogram_info_data := substr(i_tc_buffer(l_recnum), 26, 2);
        l_gim.issuer_appl_data     := substr(i_tc_buffer(l_recnum), 28, 64);
        l_gim.unpredict_number     := substr(i_tc_buffer(l_recnum), 92, 8);
        l_gim.appl_trans_counter   := substr(i_tc_buffer(l_recnum), 100, 4);
        l_gim.term_verif_result    := substr(i_tc_buffer(l_recnum), 104, 10);
        l_gim.trans_date           := date_ddmmyy(substr(i_tc_buffer(l_recnum), 114, 6));
        l_gim.cryptogram_amount    := substr(i_tc_buffer(l_recnum), 120, 12);
        l_gim.trans_currency       := substr(i_tc_buffer(l_recnum), 132, 3);
        l_gim.appl_interch_profile := substr(i_tc_buffer(l_recnum), 135, 4);
        l_gim.terminal_country     := substr(i_tc_buffer(l_recnum), 139, 3);
        l_gim.cashback_amount      := substr(i_tc_buffer(l_recnum), 142, 12);
        l_gim.transaction_type     := substr(i_tc_buffer(l_recnum), 154, 2);
        l_gim.crdh_verif_method    := substr(i_tc_buffer(l_recnum), 156, 6);
        l_gim.terminal_profile     := substr(i_tc_buffer(l_recnum), 162, 6);
        l_gim.terminal_type        := substr(i_tc_buffer(l_recnum), 168, 2);
        l_gim.trans_category_code  := substr(i_tc_buffer(l_recnum), 170, 1);
        l_gim.trans_seq_number     := substr(i_tc_buffer(l_recnum), 171, 8);
        l_gim.iss_auth_data        := substr(i_tc_buffer(l_recnum), 179, 32);
        l_gim.issuer_script_result := substr(i_tc_buffer(l_recnum), 211, 10);
    end if;

    l_oper.oper_type :=
        net_api_map_pkg.get_oper_type(
            i_network_oper_type  => l_gim.trans_code || l_gim.mcc
          , i_standard_id        => i_standard_id
        );

    -- Check trans_code
    if l_gim.trans_code = cst_bof_gim_api_const_pkg.TC_SALES and to_number(l_gim.cashback_amount) > 0 then
        l_oper.oper_cashback_amount := to_number(l_gim.cashback_amount);
        l_oper.oper_type            := opr_api_const_pkg.OPERATION_TYPE_CASHBACK;
    end if;

    if l_oper.oper_type is null then
        trc_log_pkg.warn(
            i_text        => 'OPERATION_TYPE_EXCEPT'
          , i_env_param1  => l_gim.trans_code || l_gim.mcc
          , i_env_param2  => i_standard_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_gim.id
        );
        l_gim.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_gim.is_invalid := com_api_const_pkg.TRUE;
        g_error_flag     := com_api_const_pkg.TRUE;
    end if;

    -- post assignment
    if l_gim.trans_code in (
           cst_bof_gim_api_const_pkg.TC_SALES
         , cst_bof_gim_api_const_pkg.TC_VOUCHER
         , cst_bof_gim_api_const_pkg.TC_CASH
       )
    then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => l_gim.card_number
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
            net_api_bin_pkg.get_bin_info(
                i_card_number      => l_gim.card_number
              , i_network_id       => i_network_id
              , o_iss_inst_id      => l_iss_inst_id
              , o_iss_host_id      => l_iss_host_id
              , o_card_type_id     => l_card_type_id
              , o_card_country     => l_card_country
              , o_card_inst_id     => l_card_inst_id
              , o_card_network_id  => l_card_network_id
              , o_pan_length       => l_pan_length
              , i_raise_error      => com_api_const_pkg.FALSE
            );
            trc_log_pkg.debug(
                i_text => 'net_api_bin_pkg.get_bin_info: '
                       || 'l_card_inst_id [' || l_card_inst_id
                       || '], l_pan_length [' || l_pan_length || ']'
            );
            -- if card BIN not found, then mark record as invalid
            if l_card_inst_id is null then
                l_gim.is_invalid  := com_api_const_pkg.TRUE;
                l_iss_inst_id     := i_inst_id;
                l_iss_network_id  := ost_api_institution_pkg.get_inst_network(i_inst_id);

                trc_log_pkg.warn(
                    i_text        => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                  , i_env_param1  => l_gim.card_mask
                  , i_env_param2  => substr(l_gim.card_number, 1, 6)
                  , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id   => l_gim.id
                );
            end if;
        end if;

        get_acq_network_id(
            i_terminal_number   => l_gim.terminal_number
          , i_inst_id           => i_inst_id
          , i_network_id        => i_network_id
          , i_trans_type        => l_trans_type
          , o_acq_inst_id       => l_acq_inst_id
          , o_acq_network_id    => l_acq_network_id
          , o_is_terminal_found => l_is_terminal_found
        );
        -- Terminal not found
        if l_is_terminal_found = com_api_const_pkg.FALSE and nvl(l_trans_type, '*') = '0' then
            l_gim.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
            l_gim.is_invalid := com_api_const_pkg.TRUE;

            trc_log_pkg.warn(
                i_text        => 'TERMINAL_NOT_FOUND'
              , i_env_param1  => i_inst_id
              , i_env_param2  => l_gim.terminal_number
              , i_env_param3  => l_trans_type
              , i_env_param4  => i_network_id
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => l_gim.id
            );

            g_error_flag := com_api_const_pkg.TRUE;
        end if;
        
        net_api_sttl_pkg.get_sttl_type(
            i_iss_inst_id      => l_iss_inst_id
          , i_acq_inst_id      => l_acq_inst_id
          , i_card_inst_id     => l_card_inst_id
          , i_iss_network_id   => l_iss_network_id
          , i_acq_network_id   => l_acq_network_id
          , i_card_network_id  => l_card_network_id
          , i_acq_inst_bin     => l_gim.acq_inst_bin
          , o_sttl_type        => l_sttl_type
          , o_match_status     => l_match_status
          , i_oper_type        => l_oper.oper_type
        );

    -- Assign dispute ID
    else
        assign_dispute(
            io_gim             => l_gim
          , i_standard_id      => i_standard_id
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_acq_inst_id      => l_acq_inst_id
          , o_acq_network_id   => l_acq_network_id
          , o_sttl_type        => l_sttl_type
          , o_match_status     => l_match_status
        );
        -- Dispute not found
        if l_gim.dispute_id is null then
            if  l_gim.trans_code in (
                    cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
                  , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
                  , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK
                  , cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK_REV
                  , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                  , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK_REV
                )
            then
                iss_api_bin_pkg.get_bin_info(
                    i_card_number      => l_gim.card_number
                  , o_iss_inst_id      => l_iss_inst_id
                  , o_iss_network_id   => l_iss_network_id
                  , o_card_inst_id     => l_card_inst_id
                  , o_card_network_id  => l_card_network_id
                  , o_card_type        => l_card_type_id
                  , o_card_country     => l_country_code
                  , o_bin_currency     => l_bin_currency
                  , o_sttl_currency    => l_sttl_currency
                );

                if l_iss_inst_id is null then
                    l_iss_network_id := i_network_id; --src
                    l_iss_inst_id    := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
                end if;
                l_card_inst_id     := null;
                l_card_network_id  := null;
                l_card_type_id     := null;
                l_country_code     := null;
                l_bin_currency     := null;
                l_sttl_currency    := null;

                get_acq_network_id(
                    i_terminal_number   => l_gim.terminal_number
                  , i_inst_id           => i_inst_id
                  , i_network_id        => i_network_id
                  , o_acq_inst_id       => l_acq_inst_id
                  , o_acq_network_id    => l_acq_network_id
                  , o_is_terminal_found => l_is_terminal_found
                );

            elsif l_gim.trans_code in (
                      cst_bof_gim_api_const_pkg.TC_SALES
                    , cst_bof_gim_api_const_pkg.TC_VOUCHER
                    , cst_bof_gim_api_const_pkg.TC_CASH
                    , cst_bof_gim_api_const_pkg.TC_SALES_REVERSAL
                    , cst_bof_gim_api_const_pkg.TC_VOUCHER_REVERSAL
                    , cst_bof_gim_api_const_pkg.TC_CASH_REVERSAL
                  )
            then
                iss_api_bin_pkg.get_bin_info(
                    i_card_number      => l_gim.card_number
                  , o_iss_inst_id      => l_iss_inst_id
                  , o_iss_network_id   => l_iss_network_id
                  , o_card_inst_id     => l_card_inst_id
                  , o_card_network_id  => l_card_network_id
                  , o_card_type        => l_card_type_id
                  , o_card_country     => l_country_code
                  , o_bin_currency     => l_bin_currency
                  , o_sttl_currency    => l_sttl_currency
                );

                if l_iss_inst_id is null then
                    l_iss_inst_id     := i_inst_id;  --dst
                    l_iss_network_id  := ost_api_institution_pkg.get_inst_network(i_inst_id => i_inst_id);
                end if;
                l_card_inst_id     := null;
                l_card_network_id  := null;
                l_card_type_id     := null;
                l_country_code     := null;
                l_bin_currency     := null;
                l_sttl_currency    := null;

                get_acq_network_id(  --src
                    i_terminal_number   => l_gim.terminal_number
                  , i_inst_id           => i_inst_id
                  , i_network_id        => i_network_id
                  , o_acq_inst_id       => l_acq_inst_id
                  , o_acq_network_id    => l_acq_network_id
                  , o_is_terminal_found => l_is_terminal_found
                );

            end if;

            if l_card_inst_id is null then
                net_api_bin_pkg.get_bin_info(
                    i_card_number           => l_gim.card_number
                  , i_oper_type             => null
                  , i_terminal_type         => null
                  , i_acq_inst_id           => l_acq_inst_id
                  , i_acq_network_id        => l_acq_network_id
                  , i_msg_type              => null
                  , i_oper_reason           => null
                  , i_oper_currency         => null
                  , i_merchant_id           => null
                  , i_terminal_id           => null
                  , o_iss_inst_id           => l_iss_inst_id2
                  , o_iss_network_id        => l_iss_network_id2
                  , o_iss_host_id           => l_iss_host_id
                  , o_card_type_id          => l_card_type_id
                  , o_card_country          => l_card_country
                  , o_card_inst_id          => l_card_inst_id
                  , o_card_network_id       => l_card_network_id
                  , o_pan_length            => l_pan_length
                  , i_raise_error           => com_api_const_pkg.FALSE
                );
            end if;

            net_api_sttl_pkg.get_sttl_type(
                i_iss_inst_id      => l_iss_inst_id
              , i_acq_inst_id      => l_acq_inst_id
              , i_card_inst_id     => l_card_inst_id
              , i_iss_network_id   => l_iss_network_id
              , i_acq_network_id   => l_acq_network_id
              , i_card_network_id  => l_card_network_id
              , i_acq_inst_bin     => l_gim.acq_inst_bin
              , o_sttl_type        => l_sttl_type
              , o_match_status     => l_match_status
              , i_oper_type        => l_oper.oper_type
            );
        end if;
    end if;

    l_card_rec :=
        iss_api_card_pkg.get_card(
            i_card_number   => l_gim.card_number
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    l_gim.card_id   := l_card_rec.id;
    l_gim.status    := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

    l_oper.match_status := l_match_status;

    l_oper.sttl_type := l_sttl_type;
    if l_oper.sttl_type is null then
        l_gim.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_gim.is_invalid := com_api_const_pkg.TRUE;

        trc_log_pkg.warn(
            i_text        => 'UNABLE_TO_DEFINE_SETTLEMENT_TYPE'
          , i_env_param1  => l_iss_inst_id
          , i_env_param2  => l_acq_inst_id
          , i_env_param3  => l_card_inst_id
          , i_env_param4  => l_iss_network_id
          , i_env_param5  => l_acq_network_id
          , i_env_param6  => l_card_network_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_gim.id
        );

        g_error_flag := com_api_const_pkg.TRUE;
    end if;

    l_oper.msg_type :=
        net_api_map_pkg.get_msg_type(
            i_network_msg_type  => l_gim.usage_code || l_gim.trans_code
          , i_standard_id       => i_standard_id
        );
    if l_oper.msg_type is null then
        trc_log_pkg.warn(
            i_text        => 'NETWORK_MESSAGE_TYPE_EXCEPT'
          , i_env_param1  => l_gim.usage_code||l_gim.trans_code
          , i_env_param2  => i_standard_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_gim.id
        );
        l_gim.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_gim.is_invalid := com_api_const_pkg.TRUE;
        g_error_flag     := com_api_const_pkg.TRUE;
    end if;

    l_oper.id                := l_gim.id;
    l_oper.is_reversal       := l_gim.is_reversal;
    l_oper.oper_amount       := l_gim.oper_amount;
    l_oper.oper_currency     := l_gim.oper_currency;
    l_oper.sttl_amount       := l_gim.sttl_amount;
    l_oper.sttl_currency     := l_gim.sttl_currency;
    l_oper.oper_date         := l_gim.oper_date;
    l_oper.host_date         := null;
    l_oper.mcc               := l_gim.mcc;
    l_oper.originator_refnum := l_gim.rrn;
    l_oper.network_refnum    := l_gim.arn;
    l_oper.acq_inst_bin      := l_gim.acq_inst_bin;
    l_oper.merchant_name     := l_gim.merchant_name;
    l_oper.merchant_city     := l_gim.merchant_city;

    l_oper.dispute_id        := l_gim.dispute_id;
    l_oper.original_id       :=
        cst_bof_gim_api_fin_msg_pkg.get_original_id(
            i_fin_rec          => l_gim
          , i_fee_rec          => null
          , o_need_original_id => l_need_original_id
        );

    if l_need_original_id = com_api_const_pkg.TRUE then
        io_no_original_id_tab(io_no_original_id_tab.count + 1) := l_gim;
    end if;

    if l_gim.dispute_id is null then
        l_oper.merchant_country  := l_gim.merchant_country;
        l_acq_part.merchant_id   := null;
        l_acq_part.terminal_id   := null;
        l_oper.terminal_number   := l_gim.terminal_number;
        l_oper.terminal_type     :=
            case
                when l_gim.electr_comm_ind in ('5', '6', '7', '8') then acq_api_const_pkg.TERMINAL_TYPE_EPOS
                when l_gim.mcc = cst_bof_gim_api_const_pkg.MCC_ATM then acq_api_const_pkg.TERMINAL_TYPE_ATM
                                                                   else acq_api_const_pkg.TERMINAL_TYPE_POS
            end;
        l_iss_part.card_expir_date := last_day(date_mmyy(l_gim.card_expir_date));
    else
        opr_api_operation_pkg.get_operation(
            i_oper_id             => l_gim.dispute_id
          , o_operation           => l_operation
        );
        l_oper.terminal_type     := l_operation.terminal_type;
        l_oper.merchant_country  := l_operation.merchant_country;
        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant        => l_participant
        );
        l_acq_part.merchant_id   := l_participant.merchant_id;
        l_acq_part.terminal_id   := l_participant.terminal_id;
        -- inherit terminal_number from original operation to support long terminal_number version
        l_oper.terminal_number   := l_operation.terminal_number;
        opr_api_operation_pkg.get_participant(
            i_oper_id            => l_operation.id
          , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant        => l_participant
        );
        l_iss_part.card_expir_date := l_participant.card_expir_date;
    end if;
    l_oper.incom_sess_file_id      := i_session_file_id;

    l_iss_network_id               := nvl(l_conv_iss_network_id, l_iss_network_id);

    l_iss_part.inst_id             := l_iss_inst_id;
    l_iss_part.network_id          := l_iss_network_id;
    l_iss_part.card_id             := l_gim.card_id;
    l_iss_part.card_type_id        := nvl(l_card_type_id, l_card_rec.card_type_id);
    l_iss_part.card_seq_number     := replace(l_gim.card_seq_number, ' ', '');
    l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value     := l_gim.card_number;
    l_iss_part.customer_id         := l_card_rec.customer_id;
    l_iss_part.card_mask           := l_gim.card_mask;
    l_iss_part.card_number         := l_gim.card_number;
    l_iss_part.card_hash           := l_gim.card_hash;
    l_iss_part.card_country        := nvl(l_country_code, l_card_rec.country);
    l_iss_part.card_inst_id        := l_card_inst_id;
    l_iss_part.card_network_id     := l_card_network_id;
    l_iss_part.split_hash          := com_api_hash_pkg.get_split_hash(l_gim.card_number);
    l_iss_part.card_service_code   := l_card_service_code;
    l_iss_part.account_amount      := null;
    l_iss_part.account_currency    := null;
    l_iss_part.account_number      := null;
    l_iss_part.auth_code           := l_gim.auth_code;

    l_acq_part.inst_id             := l_acq_inst_id;
    l_acq_part.network_id          := l_acq_network_id;
    l_acq_part.split_hash          := null;

    if  l_gim.trans_code in (cst_bof_gim_api_const_pkg.TC_SALES
                           , cst_bof_gim_api_const_pkg.TC_VOUCHER
                           , cst_bof_gim_api_const_pkg.TC_CASH)
        and l_gim.usage_code = '1'
        and l_card_rec.id is null
    then
        l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        l_oper.status    := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        trc_log_pkg.warn(
            i_text         => 'CARD_NOT_FOUND'
          , i_env_param1   => l_gim.card_mask
          , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id    => l_gim.id
        );
    end if;

    if l_gim.is_invalid = com_api_const_pkg.TRUE then
        g_error_flag  := com_api_const_pkg.TRUE;
        l_gim.status  := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;

    if nvl(i_create_operation, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
        opr_api_create_pkg.create_operation(
            i_oper      => l_oper
          , i_iss_part  => l_iss_part
          , i_acq_part  => l_acq_part
        );

        if l_gim.trans_code in (cst_bof_gim_api_const_pkg.TC_SALES
                              , cst_bof_gim_api_const_pkg.TC_CASH)
        then
            opr_api_additional_amount_pkg.save_amount(
                i_oper_id      => l_oper.id
              , i_amount_type  => com_api_const_pkg.AMOUNT_ORIGINAL_FEE
              , i_amount_value => l_gim.iss_reimb_fee
              , i_currency     => l_iss_reimb_fee_currency
            );
        end if;
    end if;

    l_gim.host_inst_id := net_api_network_pkg.get_inst_id(i_network_id => l_gim.network_id);
    l_gim.proc_bin     := i_proc_bin;

    l_gim.id           := cst_bof_gim_api_fin_msg_pkg.put_message(i_fin_rec => l_gim);

    count_amount(
        io_amount_tab    => io_amount_tab
      , i_sttl_amount    => l_oper.sttl_amount
      , i_sttl_currency  => l_oper.sttl_currency
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_gim.id [#1]'
      , i_env_param1 => l_gim.id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED on i_tc_buffer[#1]'
          , i_env_param1 => l_recnum
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
end process_draft;

procedure process_transaction_advice(
    i_tc_buffer            in            cst_bof_gim_api_type_pkg.t_tc_buffer
  , i_network_id           in            com_api_type_pkg.t_tiny_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_proc_date            in            date
  , i_file_id              in            com_api_type_pkg.t_long_id
  , i_record_number        in            com_api_type_pkg.t_short_id
  , i_proc_bin             in            com_api_type_pkg.t_bin
  , io_amount_tab          in out nocopy t_amount_count_tab
  , i_create_operation     in            com_api_type_pkg.t_boolean
  , i_logical_file         in            com_api_type_pkg.t_byte_char
  , i_standard_id          in            com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_transaction_advice ';
    l_gim                                cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec;
    l_recnum                             pls_integer := 1;
    l_tcr                                varchar2(1);
    l_bin_rec                            iss_api_type_pkg.t_bin_rec;
    l_card_rec                           iss_api_type_pkg.t_card_rec;
    l_oper                               opr_api_type_pkg.t_oper_rec;
    l_iss_part                           opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                           opr_api_type_pkg.t_oper_part_rec;
    l_iss_inst_id                        com_api_type_pkg.t_inst_id;
    l_iss_inst_id2                       com_api_type_pkg.t_inst_id;
    l_acq_inst_id                        com_api_type_pkg.t_inst_id;
    l_card_inst_id                       com_api_type_pkg.t_inst_id;
    l_iss_network_id                     com_api_type_pkg.t_network_id;
    l_iss_network_id2                    com_api_type_pkg.t_network_id;
    l_acq_network_id                     com_api_type_pkg.t_network_id;
    l_card_network_id                    com_api_type_pkg.t_network_id;
    l_card_type_id                       com_api_type_pkg.t_tiny_id;
    l_country_code                       com_api_type_pkg.t_country_code;
    l_bin_currency                       com_api_type_pkg.t_curr_code;
    l_sttl_currency                      com_api_type_pkg.t_curr_code;
    l_iss_host_id                        com_api_type_pkg.t_tiny_id;
    l_card_country                       com_api_type_pkg.t_country_code;
    l_pan_length                         com_api_type_pkg.t_tiny_id;
    l_sttl_type                          com_api_type_pkg.t_dict_value;
    l_match_status                       com_api_type_pkg.t_dict_value;
    l_merchant_number                    com_api_type_pkg.t_merchant_number;
    l_merchant_id                        com_api_type_pkg.t_short_id;
    l_terminal_id                        com_api_type_pkg.t_short_id;
    l_conv_iss_network_id                com_api_type_pkg.t_network_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_tc_buffer.count() = ' || i_tc_buffer.count()
                                   ||  ', io_amount_tab.count() = ' || io_amount_tab.count()
                                   ||  ', i_inst_id [' || i_inst_id
                                   || '], i_file_id [' || i_file_id
                                   || '], i_record_number [' || i_record_number
                                   || '], i_create_operation [' || i_create_operation
                                   || '], i_proc_date [#1], i_proc_bin [#2]'
      , i_env_param1 => to_char(i_proc_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param2 => i_proc_bin
    );

    -- Message specific fields
    -- data from TCR0
    init_fin_record(l_gim);
    l_gim.id                   := opr_api_create_pkg.get_id;
    l_gim.trans_code           := substr(i_tc_buffer(l_recnum), 1, 2);
    l_tcr                      := substr(i_tc_buffer(l_recnum), 9, 1);
    l_gim.logical_file         := i_logical_file;
    l_gim.file_id              := i_file_id;
    l_gim.record_number        := i_record_number;
    l_gim.is_reversal          := com_api_const_pkg.FALSE;

    l_gim.transaction_type     := substr(i_tc_buffer(l_recnum), 10, 2);
    l_gim.merchant_number      := trim(substr(i_tc_buffer(l_recnum), 12, 15));
    l_gim.merchant_name        := substr(i_tc_buffer(l_recnum), 42, 25);
    l_gim.merchant_city        := substr(i_tc_buffer(l_recnum), 67, 13);
    l_gim.merchant_country     := trim(substr(i_tc_buffer(l_recnum), 80, 3));
    l_gim.mcc                  := substr(i_tc_buffer(l_recnum), 83, 4);
    l_gim.merchant_type        := substr(i_tc_buffer(l_recnum), 87, 1);
    l_gim.remittance_number    := substr(i_tc_buffer(l_recnum), 88, 6);
    l_gim.electronic_term_ind  := substr(i_tc_buffer(l_recnum), 94, 1);
    l_gim.card_indicator       := substr(i_tc_buffer(l_recnum), 98, 1);
    l_gim.payment_product_ind  := substr(i_tc_buffer(l_recnum), 99, 1);

    l_conv_iss_network_id      :=
        to_number(
            com_api_array_pkg.conv_array_elem_v(
                i_array_type_id     => cst_bof_gim_api_const_pkg.ARRAY_TYPE_GIM_PMNT_PROD_INDX
                , i_array_id        => cst_bof_gim_api_const_pkg.ARRAY_GIM_PMNT_PROD_INDX
                , i_inst_id         => i_inst_id
                , i_elem_value      => l_gim.payment_product_ind
                , i_mask_error      => com_api_type_pkg.TRUE
            )
        );

    l_gim.card_number          := get_card_number(
                                      i_card_number => trim(substr(i_tc_buffer(l_recnum), 100, 19))
                                    , i_network_id  => i_network_id
                                    , i_oper_id     => l_gim.id
                                    , io_is_invalid => l_gim.is_invalid
                                    , i_mask_error  => com_api_const_pkg.TRUE
                                  );
    l_gim.card_hash            := com_api_hash_pkg.get_card_hash(
                                      i_card_number => l_gim.card_number
                                  );
    l_gim.card_mask            := iss_api_card_pkg.get_card_mask(
                                      i_card_number => l_gim.card_number
                                  );

    l_gim.card_expir_date      := substr(i_tc_buffer(l_recnum), 119, 4);
    l_gim.crdh_id_method       := substr(i_tc_buffer(l_recnum), 123, 1);
    l_gim.crdh_cardnum_cap_ind := substr(i_tc_buffer(l_recnum), 124, 1);

    l_gim.oper_date :=
        date_ddmmyy(
            p_date => substr(i_tc_buffer(l_recnum), 125, 6)
          , p_time => substr(i_tc_buffer(l_recnum), 202, 6)
        );

    l_gim.auth_code            := substr(i_tc_buffer(l_recnum), 131, 6);
    l_gim.auth_code_src_ind    := substr(i_tc_buffer(l_recnum), 137, 1);

    l_gim.oper_currency        := trim(substr(i_tc_buffer(l_recnum), 208, 3));
    l_gim.oper_amount          := prepare_amount(
                                      i_amount_str     => substr(i_tc_buffer(l_recnum), 139, 12)
                                    , i_curr_code      => l_gim.oper_currency
                                    , i_exponent       => null
                                    , i_amount_desc    => 'Operation amount'
                                  );

    l_gim.rrn                  := substr(i_tc_buffer(l_recnum), 151, 12);
    l_gim.arn                  := substr(i_tc_buffer(l_recnum), 163, 23);
    l_gim.terminal_number      := substr(i_tc_buffer(l_recnum), 186, 8);
    l_gim.voucher_number       := substr(i_tc_buffer(l_recnum), 194, 8);

    l_gim.dest_currency       := trim(substr(i_tc_buffer(l_recnum), 223, 3));
    if l_gim.dest_currency is not null then
        l_gim.dest_amount :=
            prepare_amount(
                i_amount_str     => substr(i_tc_buffer(l_recnum), 211, 12)
              , i_curr_code      => l_gim.dest_currency
              , i_exponent       => substr(i_tc_buffer(l_recnum), 226, 1)
              , i_amount_desc    => 'Destination amount'
            );
    end if;

    l_gim.int_fee_currency       := trim(substr(i_tc_buffer(l_recnum), 239, 3));
    if l_gim.int_fee_currency is not null then
        l_gim.int_fee_amount :=
            prepare_amount(
                i_amount_str     => substr(i_tc_buffer(l_recnum), 227, 12)
              , i_curr_code      => l_gim.int_fee_currency
              , i_exponent       => substr(i_tc_buffer(l_recnum), 242, 1)
              , i_amount_desc    => 'Interchange fee amount'
            );
    end if;
    l_gim.int_fee_sign           := substr(i_tc_buffer(l_recnum), 243, 1);

    begin
        l_bin_rec :=
            iss_api_bin_pkg.get_bin(
                i_bin         => substr(l_gim.card_number, 1, 6)
              , i_mask_error  => com_api_const_pkg.TRUE
            );

        trc_log_pkg.debug(
            i_text       => 'BIN [#1] was found among issuing BINs: institution [#2], network [#3]'
          , i_env_param1 => l_bin_rec.bin
          , i_env_param2 => l_bin_rec.inst_id
          , i_env_param3 => l_bin_rec.network_id
        );

        l_gim.inst_id    := l_bin_rec.inst_id;
        l_gim.network_id := l_bin_rec.network_id;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_gim.inst_id      := null;
                l_gim.network_id   := null;
            else
                raise;
            end if;
    end;

    if l_gim.inst_id is null then
        l_gim.inst_id     := i_inst_id;
        l_gim.network_id  := i_network_id;
    end if;

    trc_log_pkg.debug(
        i_text => 'l_gim.inst_id [' || l_gim.inst_id
               || '], l_gim.network_id [' || l_gim.network_id || ']'
    );

    l_card_rec         := iss_api_card_pkg.get_card(
                              i_card_number   => l_gim.card_number
                            , i_mask_error    => com_api_const_pkg.TRUE
                          );
    l_gim.card_id      := l_card_rec.id;
    l_gim.status       := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_gim.usage_code   := '1';

    l_oper.oper_type :=
        net_api_map_pkg.get_oper_type(
            i_network_oper_type  => l_gim.trans_code || l_gim.mcc
          , i_standard_id        => i_standard_id
        );

    if l_oper.oper_type is null then
        trc_log_pkg.warn(
            i_text        => 'OPERATION_TYPE_EXCEPT'
          , i_env_param1  => l_gim.trans_code || l_gim.mcc
          , i_env_param2  => i_standard_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_gim.id
        );
        l_gim.is_invalid := com_api_const_pkg.TRUE;
    end if;

    l_oper.msg_type :=
        net_api_map_pkg.get_msg_type(
            i_network_msg_type  => l_gim.usage_code || l_gim.trans_code
          , i_standard_id       => i_standard_id
        );

    if l_oper.msg_type is null then
        trc_log_pkg.warn(
            i_text        => 'NETWORK_MESSAGE_TYPE_EXCEPT'
          , i_env_param1  => l_gim.usage_code || l_gim.trans_code
          , i_env_param2  => i_standard_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_gim.id
        );
        l_gim.is_invalid := com_api_const_pkg.TRUE;
    end if;

    acq_api_terminal_pkg.get_merchant(
        i_terminal_number       => l_gim.terminal_number
      , i_inst_id               => i_inst_id
      , o_merchant_number       => l_merchant_number
      , o_merchant_id           => l_merchant_id
      , o_terminal_id           => l_terminal_id
      , i_mask_error            => com_api_const_pkg.TRUE
    );
    -- Terminal not found
    if l_terminal_id is null then
        l_gim.status     := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_gim.is_invalid := com_api_const_pkg.TRUE;

        trc_log_pkg.warn(
            i_text        => 'TERMINAL_NOT_FOUND'
          , i_env_param1  => i_inst_id
          , i_env_param2  => l_gim.terminal_number
          , i_env_param3  => i_network_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_gim.id
        );

        g_error_flag := com_api_const_pkg.TRUE;
    end if;


    l_acq_network_id  := ost_api_institution_pkg.get_inst_network(i_inst_id);
    l_acq_inst_id     := i_inst_id;

    iss_api_bin_pkg.get_bin_info(
        i_card_number      => l_gim.card_number
      , o_iss_inst_id      => l_iss_inst_id
      , o_iss_network_id   => l_iss_network_id
      , o_card_inst_id     => l_card_inst_id
      , o_card_network_id  => l_card_network_id
      , o_card_type        => l_card_type_id
      , o_card_country     => l_country_code
      , o_bin_currency     => l_bin_currency
      , o_sttl_currency    => l_sttl_currency
    );

    trc_log_pkg.debug(
        i_text => 'iss_api_bin_pkg.get_bin_info: '
               || 'l_card_inst_id [' || l_card_inst_id
               || '], l_card_network_id [' || l_card_network_id || ']'
               || '], l_pan_length [' || l_pan_length || ']'
               || '], l_iss_inst_id [' || l_iss_inst_id || ']'
               || '], l_iss_network_id [' || l_iss_network_id || ']'
    );

    if l_card_inst_id is null then
        l_iss_network_id  := i_network_id;
        net_api_bin_pkg.get_bin_info(
            i_card_number      => l_gim.card_number
          , i_network_id       => l_iss_network_id
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_host_id      => l_iss_host_id
          , o_card_type_id     => l_card_type_id
          , o_card_country     => l_card_country
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_pan_length       => l_pan_length
          , i_raise_error      => com_api_const_pkg.FALSE
        );
        trc_log_pkg.debug(
            i_text => 'net_api_bin_pkg.get_bin_info: '
                   || 'l_card_inst_id [' || l_card_inst_id
                   || '], l_card_network_id [' || l_card_network_id || ']'
                   || '], l_pan_length [' || l_pan_length || ']'
                   || '], l_iss_inst_id [' || l_iss_inst_id || ']'
                   || '], l_iss_network_id [' || l_iss_network_id || ']'
        );

        if l_card_inst_id is null then
            l_iss_network_id  := i_network_id;
            l_iss_inst_id     := net_api_network_pkg.get_inst_id(i_network_id);

            net_api_bin_pkg.get_bin_info(
                i_card_number           => l_gim.card_number
              , i_oper_type             => null
              , i_terminal_type         => null
              , i_acq_inst_id           => l_acq_inst_id
              , i_acq_network_id        => l_acq_network_id
              , i_msg_type              => null
              , i_oper_reason           => null
              , i_oper_currency         => null
              , i_merchant_id           => null
              , i_terminal_id           => null
              , o_iss_inst_id           => l_iss_inst_id2
              , o_iss_network_id        => l_iss_network_id2
              , o_iss_host_id           => l_iss_host_id
              , o_card_type_id          => l_card_type_id
              , o_card_country          => l_card_country
              , o_card_inst_id          => l_card_inst_id
              , o_card_network_id       => l_card_network_id
              , o_pan_length            => l_pan_length
              , i_raise_error           => com_api_type_pkg.FALSE
            );
        end if;
    end if;

    net_api_sttl_pkg.get_sttl_type(
        i_iss_inst_id      => l_iss_inst_id
      , i_acq_inst_id      => l_acq_inst_id
      , i_card_inst_id     => l_card_inst_id
      , i_iss_network_id   => l_iss_network_id
      , i_acq_network_id   => l_acq_network_id
      , i_card_network_id  => l_card_network_id
      , i_acq_inst_bin     => l_gim.acq_inst_bin
      , o_sttl_type        => l_sttl_type
      , o_match_status     => l_match_status
      , i_oper_type        => l_oper.oper_type
    );

    if l_sttl_type is null then
        trc_log_pkg.warn(
            i_text        => 'UNABLE_TO_DEFINE_SETTLEMENT_TYPE'
          , i_env_param1  => l_iss_inst_id
          , i_env_param2  => l_acq_inst_id
          , i_env_param3  => l_card_inst_id
          , i_env_param4  => l_iss_network_id
          , i_env_param5  => l_acq_network_id
          , i_env_param6  => l_card_network_id
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => l_gim.id
        );
        l_gim.is_invalid := com_api_const_pkg.TRUE;
    end if;

    if l_sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS then
        l_iss_network_id               := nvl(l_conv_iss_network_id, l_iss_network_id);
    end if;

    l_oper.id                      := l_gim.id;
    l_oper.is_reversal             := l_gim.is_reversal;
    l_oper.oper_amount             := l_gim.oper_amount;
    l_oper.oper_currency           := l_gim.oper_currency;
    l_oper.oper_date               := l_gim.oper_date;
    l_oper.host_date               := null;
    l_oper.mcc                     := l_gim.mcc;
    l_oper.originator_refnum       := l_gim.rrn;
    l_oper.network_refnum          := l_gim.arn;
    l_oper.acq_inst_bin            := l_gim.acq_inst_bin;
    l_oper.terminal_number         := l_gim.terminal_number;
    l_oper.merchant_name           := l_gim.merchant_name;
    l_oper.merchant_city           := l_gim.merchant_city;
    l_oper.merchant_number         := nvl(l_merchant_number, l_gim.merchant_number);

    l_oper.match_status            := l_match_status;
    l_oper.sttl_type               := l_sttl_type;

    l_acq_part.inst_id             := l_acq_inst_id;
    l_acq_part.network_id          := l_acq_network_id;
    l_acq_part.split_hash          := null;
    l_acq_part.merchant_id         := l_merchant_id;
    l_acq_part.terminal_id         := l_terminal_id;

    l_iss_part.inst_id             := l_iss_inst_id;
    l_iss_part.network_id          := l_iss_network_id;
    l_iss_part.card_id             := l_gim.card_id;
    l_iss_part.card_type_id        := nvl(l_card_type_id, l_card_rec.card_type_id);
    l_iss_part.card_seq_number     := replace(l_gim.card_seq_number, ' ', '');
    l_iss_part.client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value     := l_gim.card_number;
    l_iss_part.customer_id         := l_card_rec.customer_id;
    l_iss_part.card_mask           := l_gim.card_mask;
    l_iss_part.card_number         := l_gim.card_number;
    l_iss_part.card_hash           := l_gim.card_hash;
    l_iss_part.card_country        := nvl(l_country_code, l_card_rec.country);
    l_iss_part.card_inst_id        := l_card_inst_id;
    l_iss_part.card_network_id     := l_card_network_id;
    l_iss_part.split_hash          := com_api_hash_pkg.get_split_hash(l_gim.card_number);
    l_iss_part.auth_code           := l_gim.auth_code;

    if l_gim.is_invalid = com_api_const_pkg.TRUE then
        g_error_flag  := com_api_const_pkg.TRUE;
        l_gim.status  := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;

    if nvl(i_create_operation, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
        opr_api_create_pkg.create_operation(
            i_oper      => l_oper
          , i_iss_part  => l_iss_part
          , i_acq_part  => l_acq_part
        );

        opr_api_additional_amount_pkg.save_amount(
            i_oper_id      => l_oper.id
          , i_amount_type  => com_api_const_pkg.AMOUNT_ORIGINAL_FEE
          , i_amount_value => l_gim.int_fee_amount
          , i_currency     => l_gim.int_fee_currency
        );
    end if;

    l_gim.host_inst_id := net_api_network_pkg.get_inst_id(
                              i_network_id => l_gim.network_id
                          );
    l_gim.proc_bin     := i_proc_bin;
    l_gim.id           := cst_bof_gim_api_fin_msg_pkg.put_message(
                              i_fin_rec => l_gim
                          );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_gim.id [#1]'
      , i_env_param1 => l_gim.id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED on i_tc_buffer[#1]'
          , i_env_param1 => l_recnum
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
end process_transaction_advice;

-- Messages 10/20 fee collection/funds disbursement
procedure process_fee_funds(
    i_tc_buffer            in     cst_bof_gim_api_type_pkg.t_tc_buffer
  , i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_file_id              in     com_api_type_pkg.t_long_id
  , i_session_file_id      in     com_api_type_pkg.t_long_id
  , i_record_number        in     com_api_type_pkg.t_short_id
  , i_create_operation     in     com_api_type_pkg.t_boolean
  , i_logical_file         in     com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_fee_funds ';
    l_gim                         cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec;
    l_fee                         cst_bof_gim_api_type_pkg.t_fee_rec;
    l_oper_status                 com_api_type_pkg.t_dict_value;
    l_recnum                      pls_integer := 1;

    function get_field(
        i_start     in    pls_integer
      , i_length    in    pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(l_recnum), i_start, i_length), ' ');
    end;

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_tc_buffer.count() = ' || i_tc_buffer.count()
                                   ||  ', i_network_id [' || i_network_id
                                   || '], i_file_id [' || i_file_id
                                   || '], i_record_number [' || i_record_number
                                   || '], i_create_operation [' || i_create_operation || ']'
    );

    init_fin_record(l_gim);

    l_fee.file_id             := i_file_id;
    l_gim.id                  := opr_api_create_pkg.get_id;
    l_gim.logical_file        := i_logical_file;
    l_gim.file_id             := i_file_id;
    l_gim.status              := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_gim.trans_code          := get_field(1, 2);
    l_gim.record_number       := i_record_number;
    l_gim.payment_product_ind := get_field(11, 1);
    l_gim.forw_inst_id        := get_field(12, 8);
    l_gim.oper_currency       := get_field(160, 3);
    l_gim.oper_amount :=
        prepare_amount(
            i_amount_str     => get_field(22, 12)
          , i_curr_code      => l_gim.oper_currency
          , i_exponent       => get_field(21, 1)
          , i_amount_desc    => 'Operation amount'
        );
    l_gim.receiv_inst_id      := ltrim(get_field(34, 8), '0');
    trc_log_pkg.debug(LOG_PREFIX || 'receiv_inst_id=' || l_gim.receiv_inst_id);

    l_fee.fee_type_ind        := get_field(42, 1);
    l_gim.dest_currency       := get_field(163, 3);
    l_gim.dest_amount :=
        prepare_amount(
            i_amount_str     => get_field(44, 12)
          , i_curr_code      => l_gim.dest_currency
          , i_exponent       => get_field(43, 1)
          , i_amount_desc    => 'Destination amount'
        );
    if substr(i_tc_buffer(l_recnum), 56, 19) != lpad('0', 19, '0') then
        l_gim.card_number := get_card_number(
                                 i_card_number  => substr(i_tc_buffer(l_recnum), 56, 19)
                               , i_network_id   => i_network_id
                               , i_oper_id     => l_gim.id
                               , io_is_invalid => l_gim.is_invalid
                             );
        l_gim.card_hash   := com_api_hash_pkg.get_card_hash(l_gim.card_number);
        l_gim.card_mask   := iss_api_card_pkg.get_card_mask(l_gim.card_number);
    else
        l_gim.card_number := null;
    end if;

    l_fee.forw_inst_country_code := get_field(75, 3);
    l_fee.reason_code            := get_field(78, 4);
    l_fee.collection_branch_code := get_field(82, 4);
    l_fee.trans_count            := get_field(86, 8);
    l_fee.unit_fee               := get_field(94, 9);
    l_fee.event_date             := date_ddmmyy(get_field(103, 6));

    l_gim.trans_inter_proc_date  := date_ddmmyy(get_field(109, 6));

    l_fee.source_amount_cfa :=
        prepare_amount(
            i_amount_str     => get_field(116, 12)
          , i_curr_code      => cst_bof_gim_api_const_pkg.GIM_CURR_CODE
          , i_amount_desc    => 'Source amount (CFA)'
        );

    l_gim.value_date            := date_ddmmyy(get_field(128, 6));
    l_fee.control_number        := get_field(134, 14);
    l_gim.reconciliation_date   := date_ddmmyy(get_field(148, 6));
    l_gim.reconciliation_ind    := get_field(154, 3);
    l_gim.card_seq_number       := get_field(157, 3);

    if l_gim.inst_id is null then
        l_gim.inst_id     := i_inst_id;
        l_gim.network_id  := i_network_id;
    end if;
    trc_log_pkg.debug(LOG_PREFIX || 'l_gim.inst_id [' || l_gim.inst_id || '] l_gim.network_id [' || l_gim.network_id || ']');

    -- tcr 1
    l_recnum := l_recnum + 1;
    l_fee.message_text := get_field(10, 100);

    l_gim.oper_date   := l_fee.event_date;
    l_gim.usage_code  := '1';
    l_oper_status     := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;

    if l_gim.is_invalid = com_api_const_pkg.TRUE then
        g_error_flag  := com_api_const_pkg.TRUE;
        l_gim.status  := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_oper_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;

    l_gim.id          := cst_bof_gim_api_fin_msg_pkg.put_message(l_gim);
    l_fee.id          := l_gim.id;

    cst_bof_gim_api_fin_msg_pkg.put_fee(
        i_fee_rec  => l_fee
    );

    -- Collect addendum tcrs
    l_recnum := l_recnum + 1;

    if nvl(i_create_operation, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        cst_bof_gim_api_fin_msg_pkg.create_operation(
            i_fin_rec            => l_gim
          , i_standard_id        => i_standard_id
          , i_fee_rec            => l_fee
          , i_status             => l_oper_status
          , i_incom_sess_file_id => i_session_file_id
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_gim.id [#1], l_fee.id [#2]'
      , i_env_param1 => l_gim.id
      , i_env_param2 => l_fee.id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED on i_tc_buffer[#1]'
          , i_env_param1 => l_recnum
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
end process_fee_funds;

procedure process_retrieval_request(
    i_tc_buffer            in     cst_bof_gim_api_type_pkg.t_tc_buffer
  , i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_host_id              in     com_api_type_pkg.t_tiny_id
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_file_id              in     com_api_type_pkg.t_long_id
  , i_session_file_id      in     com_api_type_pkg.t_long_id
  , i_record_number        in     com_api_type_pkg.t_short_id
  , i_originator_bin       in     com_api_type_pkg.t_bin
  , i_create_operation     in     com_api_type_pkg.t_boolean
  , i_logical_file         in     com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_retrieval_request ';
    l_gim                         cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec;
    l_retrieval                   cst_bof_gim_api_type_pkg.t_retrieval_rec;
    l_oper_status                 com_api_type_pkg.t_dict_value;
    l_currec                      pls_integer := 1;

    l_iss_network_id              com_api_type_pkg.t_tiny_id;
    l_acq_network_id              com_api_type_pkg.t_tiny_id;
    l_sttl_type                   com_api_type_pkg.t_dict_value;
    l_match_status                com_api_type_pkg.t_dict_value;

    l_card_inst_id                com_api_type_pkg.t_inst_id;
    l_card_network_id             com_api_type_pkg.t_tiny_id;
    l_card_type_id                com_api_type_pkg.t_tiny_id;
    l_country_code                com_api_type_pkg.t_country_code;
    l_bin_currency                com_api_type_pkg.t_curr_code;
    l_sttl_currency               com_api_type_pkg.t_curr_code;

    function get_field(
        i_start       in pls_integer
      , i_length      in pls_integer
    ) return varchar2 is
    begin
        return rtrim(substr(i_tc_buffer(l_currec), i_start, i_length), ' ');
    end;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_tc_buffer.count() = ' || i_tc_buffer.count()
                                   ||  ', i_network_id [' || i_network_id
                                   ||  ', i_host_id [' || i_host_id
                                   ||  ', i_inst_id [' || i_inst_id
                                   || '], i_file_id [' || i_file_id
                                   || '], i_originator_bin [' || i_originator_bin
                                   || '], i_record_number [' || i_record_number
                                   || '], i_create_operation [' || i_create_operation || ']'
    );

    init_fin_record(l_gim);

    l_gim.id                   := opr_api_create_pkg.get_id;
    l_gim.logical_file         := i_logical_file;
    l_retrieval.file_id        := i_file_id;
    l_gim.trans_code           := get_field(1, 2);
    l_gim.usage_code           := '1'; -- ?
    l_retrieval.document_type  := get_field(11, 1);
    l_gim.card_number          := get_card_number(
                                      i_card_number => get_field(12, 19)
                                    , i_network_id  => i_network_id
                                    , i_oper_id     => l_gim.id
                                    , io_is_invalid => l_gim.is_invalid
                                  );
    l_gim.arn                  := get_field(31, 23);
    l_gim.oper_date :=
        date_ddmmyy(
            p_date => get_field(54, 6)
          , p_time => get_field(60, 6)
        );
    l_gim.oper_currency := get_field(78, 3);
    l_gim.oper_amount :=
        prepare_amount(
            i_amount_str     => get_field(66, 12)
          , i_curr_code      => l_gim.oper_currency
          , i_amount_desc    => 'Operation amount'
        );
    l_gim.card_seq_number                    := get_field(81, 3);
    l_retrieval.card_iss_ref_num             := get_field(84, 9);
    l_retrieval.cancellation_ind             := get_field(93, 1);
    l_gim.reason_code                        := get_field(94, 2);
    l_retrieval.potential_chback_reason_code := get_field(96, 4);
    l_gim.account_selection                  := get_field(94, 2);
    l_gim.rrn                                := get_field(102, 12);
    l_gim.auth_code                          := get_field(114, 6);
    l_gim.trans_inter_proc_date              := date_ddmmyy(get_field(120, 6));
    l_gim.auth_code                          := get_field(114, 6);
    l_gim.forw_inst_id                       := get_field(126, 8);
    l_gim.receiv_inst_id                     := get_field(134, 8);
    l_retrieval.response_type                := get_field(142, 1);

    begin
        l_gim.inst_id :=
            iss_api_bin_pkg.get_bin(
                i_bin        => get_field(12, 6)
              , i_mask_error => com_api_const_pkg.TRUE
            ).inst_id;
        l_gim.network_id :=
            ost_api_institution_pkg.get_inst_network(
                i_inst_id => l_gim.inst_id)
            ;
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error = 'BIN_IS_NOT_FOUND' then
                l_gim.inst_id     := null;
                l_gim.network_id  := null;
            else
                raise;
            end if;
    end;

    if l_gim.inst_id is null then
        l_gim.inst_id     := i_inst_id;
        l_gim.network_id  := i_network_id;
    end if;

    l_gim.status               := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

    l_currec := l_currec + 1;

    -- assign dispute id. if dispute found, then iss_inst and acq_inst taked from dispute.
    assign_dispute(
        io_gim            => l_gim
      , i_standard_id     => i_standard_id
      , o_iss_inst_id     => l_retrieval.iss_inst_id
      , o_iss_network_id  => l_iss_network_id
      , o_acq_inst_id     => l_retrieval.acq_inst_id
      , o_acq_network_id  => l_acq_network_id
      , o_sttl_type       => l_sttl_type
      , o_match_status    => l_match_status
    );

    -- if dispute not found, then iss_inst taked from network, acq = file receiver.
    if l_gim.dispute_id is null then
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => l_gim.card_number
          , o_iss_inst_id      => l_retrieval.iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_country_code
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );
        if l_retrieval.iss_inst_id is null then
            l_retrieval.iss_inst_id := net_api_network_pkg.get_inst_id(i_network_id);
        end if;

        begin
            l_retrieval.acq_inst_id :=
                cmn_api_standard_pkg.find_value_owner(
                    i_standard_id       => i_standard_id
                  , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_object_id         => i_host_id
                  , i_param_name        => cst_bof_gim_api_const_pkg.ACQ_BUSINESS_ID
                  , i_value_char        => i_originator_bin
                  , i_mask_error        => com_api_const_pkg.TRUE
                );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'NOT_FOUND_VALUE_OWNER' then
                    l_retrieval.acq_inst_id := null;
                else
                    raise;
                end if;
        end;

        if l_retrieval.acq_inst_id is null then
            l_retrieval.acq_inst_id := i_inst_id;
        end if;
    end if;

    l_gim.file_id       := i_file_id;
    l_gim.record_number := i_record_number;

    if l_gim.is_invalid = com_api_const_pkg.TRUE then
        g_error_flag  := com_api_const_pkg.TRUE;
        l_gim.status  := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
        l_oper_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
    end if;

    l_gim.id := cst_bof_gim_api_fin_msg_pkg.put_message(l_gim);

    l_retrieval.id := l_gim.id;

    cst_bof_gim_api_fin_msg_pkg.put_retrieval(l_retrieval);

    if nvl(i_create_operation, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
        cst_bof_gim_api_fin_msg_pkg.create_operation(
            i_fin_rec            => l_gim
          , i_standard_id        => i_standard_id
          , i_status             => l_oper_status
          , i_incom_sess_file_id => i_session_file_id
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_gim.id [#1]'
      , i_env_param1 => l_gim.id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED on i_tc_buffer[#1]'
          , i_env_param1 => l_currec
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
end process_retrieval_request;

-- Processing of Incoming clearing files
procedure process(
    i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_create_operation     in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_tc                          varchar2(2);
    l_first_tc                    varchar2(2);
    l_tcr                         varchar2(1);
    l_first_tcr                   varchar2(1);
    l_tc_buffer                   cst_bof_gim_api_type_pkg.t_tc_buffer;
    l_gim_file                    cst_bof_gim_api_type_pkg.t_gim_file_rec;
    l_host_id                     com_api_type_pkg.t_tiny_id;
    l_standard_id                 com_api_type_pkg.t_tiny_id;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_errors_count                com_api_type_pkg.t_long_id := 0;
    l_amount_tab                  t_amount_count_tab;
    l_create_operation            com_api_type_pkg.t_boolean;
    l_no_original_id_tab          cst_bof_gim_api_type_pkg.t_gim_fin_mes_tab;
    l_operation_id_tab            com_api_type_pkg.t_number_tab;
    l_original_id_tab             com_api_type_pkg.t_number_tab;
    l_logical_file                com_api_type_pkg.t_byte_char;
    l_trailer_found               com_api_type_pkg.t_boolean;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
                             || '], i_create_operation [' || i_create_operation
                             || ']'
    );
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count
    );

    -- get network communication standard
    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id   => i_network_id
        );
    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id => l_host_id
        );

    trc_log_pkg.debug(
        i_text => 'l_host_id [' || l_host_id || '], l_standard_id [' || l_standard_id || ']'
    );

    l_record_count := 0;
    g_errors_count := 0;

    l_create_operation := nvl(i_create_operation, com_api_const_pkg.TRUE);

    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id
                   || '], record_count [' || p.record_count || ']'
        );
        l_errors_count := 0;
        begin
            savepoint sp_gim_incoming_file;

            l_record_number := 1;
            l_tc_buffer.delete;

            for r in (
                select record_number
                     , raw_data
                     , substr(next_data, 1, 2) next_tc
                     , substr(next_data, 9, 1) next_tcr
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                from (
                      select record_number
                           , raw_data
                           , lead(raw_data) over (order by record_number) next_data
                        from prc_file_raw_data
                       where session_file_id = p.session_file_id
                     )
                order by
                      record_number
            ) loop
                g_error_flag    := com_api_const_pkg.FALSE;
                l_trailer_found := com_api_const_pkg.FALSE;
                l_tc_buffer(l_tc_buffer.count + 1) := r.raw_data;
                l_tc  := substr(r.raw_data, 1, 2);
                l_tcr := substr(r.raw_data, 9, 1);

                if l_gim_file.id is null and l_tc != cst_bof_gim_api_const_pkg.TC_FILE_HEADER then
                    com_api_error_pkg.raise_error(
                        i_error       => 'GIM_FILE_MISSING_HEADER'
                      , i_env_param1  => l_gim_file.id
                    );
                end if;

                -- if next TC record started, then process readed TC records
                if r.next_tc is null or l_tc != r.next_tc or (r.next_tcr < l_tcr or r.next_tcr = l_tcr) then
                    l_record_number := r.record_number;

                    l_first_tc  := substr(l_tc_buffer(1), 1, 2);
                    l_first_tcr := substr(l_tc_buffer(1), 9, 1);

                    -- process file header record
                    if l_first_tc = cst_bof_gim_api_const_pkg.TC_FILE_HEADER then
                        process_file_header(
                            i_header_data      => l_tc_buffer(1)
                          , i_network_id       => i_network_id
                          , i_standard_id      => l_standard_id
                          , i_session_file_id  => p.session_file_id
                          , o_gim_file         => l_gim_file
                        );

                    -- process currency convertional rate updates
                    elsif l_first_tc = cst_bof_gim_api_const_pkg.TC_FILE_TRAILER then
                        process_file_trailer(
                            i_tc_buffer         => l_tc_buffer
                          , io_gim_file         => l_gim_file
                        );
                        l_trailer_found  := com_api_const_pkg.TRUE;

                    -- process logical files headers and trailers
                    elsif l_first_tc in (cst_bof_gim_api_const_pkg.TC_FM_HEADER
                                       , cst_bof_gim_api_const_pkg.TC_FV_HEADER
                                       , cst_bof_gim_api_const_pkg.TC_FMC_HEADER
                                       , cst_bof_gim_api_const_pkg.TC_FL_HEADER
                                       , cst_bof_gim_api_const_pkg.TC_FSW_HEADER
                                       , cst_bof_gim_api_const_pkg.TC_FSW_TRAILER
                                       , cst_bof_gim_api_const_pkg.TC_FL_TRAILER
                                       , cst_bof_gim_api_const_pkg.TC_FMC_TRAILER
                                       , cst_bof_gim_api_const_pkg.TC_FV_TRAILER
                                       , cst_bof_gim_api_const_pkg.TC_FM_TRAILER) then
                        process_logic_file(
                            i_tc_buffer             => l_tc_buffer
                          , io_logical_file         => l_logical_file
                        );

                    -- process draft transactions
                    elsif l_first_tc in (cst_bof_gim_api_const_pkg.TC_SALES
                                       , cst_bof_gim_api_const_pkg.TC_VOUCHER
                                       , cst_bof_gim_api_const_pkg.TC_CASH
                                       , cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK
                                       , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK
                                       , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK
                                       , cst_bof_gim_api_const_pkg.TC_SALES_REVERSAL
                                       , cst_bof_gim_api_const_pkg.TC_VOUCHER_REVERSAL
                                       , cst_bof_gim_api_const_pkg.TC_CASH_REVERSAL
                                       , cst_bof_gim_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                       , cst_bof_gim_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                       , cst_bof_gim_api_const_pkg.TC_CASH_CHARGEBACK_REV
                                       , cst_bof_gim_api_const_pkg.TC_MONEY_TRANSFER
                                       , cst_bof_gim_api_const_pkg.TC_MONEY_TRANSFER2)
                    then
                        process_draft(
                            i_tc_buffer            => l_tc_buffer
                          , i_network_id           => i_network_id
                          , i_host_id              => l_host_id
                          , i_standard_id          => l_standard_id
                          , i_inst_id              => l_gim_file.inst_id
                          , i_proc_date            => l_gim_file.proc_date
                          , i_file_id              => l_gim_file.id
                          , i_session_file_id      => p.session_file_id
                          , i_record_number        => l_record_number
                          , i_proc_bin             => l_gim_file.proc_bin
                          , i_originator_bin       => l_gim_file.originator_bin
                          , io_amount_tab          => l_amount_tab
                          , i_create_operation     => l_create_operation
                          , io_no_original_id_tab  => l_no_original_id_tab
                          , i_logical_file         => l_logical_file
                        );

                    -- process fee collections and funds diburstment
                    elsif l_first_tc in (cst_bof_gim_api_const_pkg.TC_FEE_COLLECTION
                                       , cst_bof_gim_api_const_pkg.TC_FUNDS_DISBURSEMENT)
                    then
                        process_fee_funds(
                            i_tc_buffer        => l_tc_buffer
                          , i_network_id       => i_network_id
                          , i_standard_id      => l_standard_id
                          , i_inst_id          => l_gim_file.inst_id
                          , i_file_id          => l_gim_file.id
                          , i_session_file_id  => p.session_file_id
                          , i_record_number    => l_record_number
                          , i_create_operation => l_create_operation
                          , i_logical_file     => l_logical_file
                        );

                    -- process retrieval requests
                    elsif l_first_tc in (cst_bof_gim_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY) then
                        process_retrieval_request(
                            i_tc_buffer        => l_tc_buffer
                          , i_network_id       => i_network_id
                          , i_host_id          => l_host_id
                          , i_standard_id      => l_standard_id
                          , i_inst_id          => l_gim_file.inst_id
                          , i_file_id          => l_gim_file.id
                          , i_session_file_id  => p.session_file_id
                          , i_record_number    => l_record_number
                          , i_originator_bin   => l_gim_file.originator_bin
                          , i_create_operation => l_create_operation
                          , i_logical_file     => l_logical_file
                        );

                    -- process draft transactions
                    elsif l_first_tc in (cst_bof_gim_api_const_pkg.TC_TRANSACTION_ADVICE)
                    then
                        process_transaction_advice(
                            i_tc_buffer            => l_tc_buffer
                          , i_network_id           => i_network_id
                          , i_inst_id              => l_gim_file.inst_id
                          , i_proc_date            => l_gim_file.proc_date
                          , i_file_id              => l_gim_file.id
                          , i_record_number        => l_record_number
                          , i_proc_bin             => l_gim_file.proc_bin
                          , io_amount_tab          => l_amount_tab
                          , i_create_operation     => l_create_operation
                          , i_logical_file         => l_logical_file
                          , i_standard_id          => l_standard_id
                        );
                    end if;

                    -- cleanup buffer before loading next TC record(s)
                    l_tc_buffer.delete;
                end if;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;
/*
                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + r.rn
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;
*/
                if r.rn_desc = 1 then
                    g_errors_count := g_errors_count + l_errors_count;
                    l_errors_count := 0;
                    l_record_count := l_record_count + r.cnt;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count
                    );
                    if l_trailer_found = com_api_const_pkg.FALSE then
                        com_api_error_pkg.raise_error(
                            i_error       => 'GIM_FILE_MISSING_TRAILER'
                          , i_env_param1  => l_gim_file.id
                        );
                    end if;
                end if;
            end loop;

            -- It is case when original record is later than reversal record in the same file.
            if l_no_original_id_tab.count > 0 then
                for i in 1 .. l_no_original_id_tab.count loop
                    l_operation_id_tab(l_operation_id_tab.count + 1) := l_no_original_id_tab(i).id;
                    l_original_id_tab(l_original_id_tab.count + 1) :=
                        cst_bof_gim_api_fin_msg_pkg.get_original_id(
                            i_fin_rec => l_no_original_id_tab(i)
                          , i_fee_rec => null
                        );
                end loop;

                forall i in 1 .. l_operation_id_tab.count
                    update opr_operation
                       set original_id = l_original_id_tab(i)
                     where id          = l_operation_id_tab(i);
            end if;

            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_gim_incoming_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_record_count
      , i_excepted_total   => g_errors_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    info_amount(
        i_amount_tab  => l_amount_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with l_record_number [#3], l_tc [#1], l_tcr [#2], l_tc_buffer:'
                                       || get_tc_buffer_str(l_tc_buffer)
          , i_env_param1 => l_tc
          , i_env_param2 => l_tcr
          , i_env_param3 => l_record_number
        );

        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process;

end;
/
