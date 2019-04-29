create or replace package body cst_bnv_napas_prc_incoming_pkg as

g_filedate                  date                       := null;
g_error_flag                com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
g_errors_count              com_api_type_pkg.t_long_id := 0;

function get_value(
    i_line                  in     com_api_type_pkg.t_text
  , i_tag                   in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_text
is
    l_value       com_api_type_pkg.t_text;
    l_position    com_api_type_pkg.t_tiny_id;
begin
    l_value    := substr(i_line,  instr(i_line, i_tag) + length(i_tag));
    l_position := instr(l_value, '[');
    if l_position > 0 then
        l_value := substr(l_value, 1, l_position - 1);
    end if;
    return trim(l_value);
end get_value;

function get_inst_id_by_proc_bin(
    i_proc_bin              in     com_api_type_pkg.t_name
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id is
    l_proc_bin                com_api_type_pkg.t_name;
    l_result                  com_api_type_pkg.t_inst_id;
    l_param_tab               com_api_type_pkg.t_param_tab;
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_inst_id_by_proc_bin: ';
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
              , i_param_name   => cst_bnv_napas_api_const_pkg.CMID
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

function date_mmdd(
    p_date                  in     varchar2
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
        l_dt      := to_date(l_century || p_date, 'YYYYMMDD');
        if abs(months_between(l_dt, g_filedate)) > 11 then
            l_century := to_char(g_filedate, 'YYYY');
            l_dt      := to_date(l_century || p_date, 'YYYYMMDD');
        end if;
    end if;

    return l_dt;
end;

function date_mmddhhmiss(
    p_date                  in     varchar2
) return date is
    l_century                 varchar2(4) := to_char(g_filedate, 'YYYY');
    l_dt                      date;
begin
    if trim(p_date) is null or substr(p_date, 1, 4) = '0000' then
        return null;
    end if;
    l_dt := to_date(l_century || p_date, 'YYYYMMDDHH24MISS');
    if trunc(l_dt) > g_filedate then
        l_century := to_char(to_number(l_century) - 1);
        l_dt      := to_date(l_century || p_date, 'YYYYMMDDHH24MISS');
        if abs(months_between(l_dt, g_filedate)) > 11 then
            l_century := to_char(g_filedate, 'YYYY');
            l_dt      := to_date(l_century || p_date, 'YYYYMMDDHH24MISS');
        end if;
    end if;

    return l_dt;
end;

function prepare_amount(
    i_amount_str              in     com_api_type_pkg.t_original_data
  , i_curr_code               in     com_api_type_pkg.t_curr_code
  , i_exponent                in     com_api_type_pkg.t_tiny_id       default null
  , i_amount_desc             in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_money
is
    l_file_currency_exponent         com_api_type_pkg.t_tiny_id;
    l_table_currency_exponent        com_api_type_pkg.t_tiny_id;
    l_result                         com_api_type_pkg.t_money;
begin
    l_result := to_number(i_amount_str);

    if l_result != 0 then
        l_table_currency_exponent := com_api_currency_pkg.get_currency_exponent(
                                         i_curr_code => i_curr_code
                                     );

        l_file_currency_exponent  := coalesce(i_exponent, l_table_currency_exponent);

        l_result := l_result / power(10, l_file_currency_exponent) * power(10, l_table_currency_exponent);
    end if;

    return l_result;
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_invalid_number then
        com_api_error_pkg.raise_error(
            i_error      => 'BNV_NAPAS_WRONG_AMOUNT_VALUE'
          , i_env_param1 => i_amount_str
          , i_env_param2 => i_curr_code
          , i_env_param3 => i_amount_desc
        );
end;

function prepare_exchange_rate(
    i_rate_str              in     com_api_type_pkg.t_original_data
  , i_exponent              in     com_api_type_pkg.t_tiny_id
  , i_exchange_desc         in     com_api_type_pkg.t_name
) return number
is
    l_result                  number;
begin
    begin
        -- String <i_rate_str> contains an rate in format NXXXXXXX,
        -- where N : number of decimal digits. XXXXXXX : exchange rate
        l_result := to_number(i_rate_str) * power(10, -i_exponent);
    exception
        when com_api_error_pkg.e_application_error or com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error      => 'BNV_NAPAS_WRONG_EXCHANGE_VALUE'
              , i_env_param1 => i_rate_str
              , i_env_param2 => i_exponent
              , i_env_param3 => i_exchange_desc
            );
    end;

    return l_result;
end;

procedure assign_dispute(
    io_bnv_napas_fin_mes    in out nocopy cst_bnv_napas_api_type_pkg.t_bnv_napas_fin_mes_rec
) is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.assign_dispute: ';
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_card_number             com_api_type_pkg.t_card_number;

    cursor match_cur is
        select min(m.id)            as id
             , min(m.dispute_id)    as dispute_id
          from cst_bnv_napas_fin_msg m
             , cst_bnv_napas_card c
         where m.sys_trace_number     = io_bnv_napas_fin_mes.sys_trace_number
           and m.trans_date           = io_bnv_napas_fin_mes.trans_date
           and m.oper_amount          = io_bnv_napas_fin_mes.oper_amount
           and m.oper_currency        = io_bnv_napas_fin_mes.oper_currency
           and c.id                   = m.id
           and reverse(c.card_number) = reverse(l_card_number);
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'sys_trace_number [#1], trans_date [#2], oper_amount [#3], oper_currency [#4], card_number [#5]'
      , i_env_param1  => io_bnv_napas_fin_mes.sys_trace_number
      , i_env_param2  => to_char(io_bnv_napas_fin_mes.trans_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3  => io_bnv_napas_fin_mes.oper_amount
      , i_env_param4  => io_bnv_napas_fin_mes.oper_currency
      , i_env_param5  => iss_api_card_pkg.get_card_mask(io_bnv_napas_fin_mes.card_number)
    );

    l_card_number := iss_api_token_pkg.encode_card_number(
                         i_card_number => io_bnv_napas_fin_mes.card_number
                     );

    for rec in match_cur loop

        if rec.id is not null then

            io_bnv_napas_fin_mes.dispute_id  := rec.id;
            l_dispute_id                     := rec.dispute_id;

            trc_log_pkg.debug (
                i_text        => 'Original message found. id = [#1], dispute_id = [#2]'
              , i_env_param1  => rec.id
              , i_env_param2  => rec.dispute_id
            );
        end if;

        exit;
    end loop;

    if io_bnv_napas_fin_mes.dispute_id is null then
        trc_log_pkg.warn (
            i_text           => 'CST_BNV_ORIGINAL_OPERATION_IS_NOT_FOUND'
            , i_env_param1   => io_bnv_napas_fin_mes.id
            , i_env_param2   => io_bnv_napas_fin_mes.sys_trace_number
            , i_env_param3   => com_api_type_pkg.convert_to_char(io_bnv_napas_fin_mes.trans_date)
            , i_env_param4   => io_bnv_napas_fin_mes.oper_amount
            , i_env_param5   => io_bnv_napas_fin_mes.oper_currency
            , i_env_param6   => iss_api_card_pkg.get_card_mask(io_bnv_napas_fin_mes.card_number)
            , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            , i_object_id    => io_bnv_napas_fin_mes.id
        );
    end if;

    -- assign a new dispute id
    if l_dispute_id is null then
        update cst_bnv_napas_fin_msg
           set dispute_id = io_bnv_napas_fin_mes.dispute_id
         where id         = io_bnv_napas_fin_mes.dispute_id;

        update opr_operation
           set dispute_id = io_bnv_napas_fin_mes.dispute_id
         where id         = io_bnv_napas_fin_mes.dispute_id;
    end if;
end assign_dispute;

procedure process_file_header(
    i_header_data           in     varchar2
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_session_file_id       in     com_api_type_pkg.t_long_id
  , i_file_participant_type in     varchar2
  , o_bnv_napas_file           out cst_bnv_napas_api_type_pkg.t_bnv_napas_file_rec
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_file_header: ';
    l_count                        pls_integer;
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'network_id[#1], standard_id[#2], session_file_id[#3]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_standard_id
      , i_env_param3  => i_session_file_id
    );
    o_bnv_napas_file.is_incoming     := com_api_const_pkg.TRUE;
    o_bnv_napas_file.network_id      := i_network_id;
    o_bnv_napas_file.proc_bin        := to_char(to_number(substr(i_header_data, instr(i_header_data, '[REV]') + 5, 8)));
    o_bnv_napas_file.proc_date       := to_date(substr(i_header_data, instr(i_header_data, '[DATE]') + 6, 8), 'DDMMYYYY');
    g_filedate                       := o_bnv_napas_file.proc_date;

    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'UNKNOWN_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;

    -- determine internal institution number
    o_bnv_napas_file.inst_id :=
        get_inst_id_by_proc_bin(
            i_proc_bin       => o_bnv_napas_file.proc_bin
          , i_network_id     => i_network_id
          , i_standard_id    => i_standard_id
        );

    if o_bnv_napas_file.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'BNV_NAPAS_BIN_NOT_REGISTERED'
          , i_env_param1  => o_bnv_napas_file.proc_bin
          , i_env_param2  => i_network_id
          , i_env_param3  => o_bnv_napas_file.inst_id
        );
    end if;

    o_bnv_napas_file.session_file_id  := i_session_file_id;
    o_bnv_napas_file.id               := cst_bnv_napas_file_seq.nextval;
    o_bnv_napas_file.participant_type := i_file_participant_type;

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
    i_tc_buffer             in     cst_bnv_napas_api_type_pkg.t_tc_buffer
  , io_bnv_napas_file       in out cst_bnv_napas_api_type_pkg.t_bnv_napas_file_rec
) is
begin
    io_bnv_napas_file.total_records := get_value(i_tc_buffer(1), '[NOT]');

    insert into cst_bnv_napas_fin_file (
        id
      , is_incoming
      , is_returned
      , network_id
      , proc_bin
      , proc_date
      , inst_id
      , session_file_id
      , total_records
      , participant_type
    ) values (
        io_bnv_napas_file.id
      , io_bnv_napas_file.is_incoming
      , io_bnv_napas_file.is_returned
      , io_bnv_napas_file.network_id
      , io_bnv_napas_file.proc_bin
      , io_bnv_napas_file.proc_date
      , io_bnv_napas_file.inst_id
      , io_bnv_napas_file.session_file_id
      , io_bnv_napas_file.total_records
      , io_bnv_napas_file.participant_type
    );
end;

procedure process_draft(
    i_tc_buffer             in     cst_bnv_napas_api_type_pkg.t_tc_buffer
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_host_id               in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_proc_date             in     date
  , i_file_id               in     com_api_type_pkg.t_long_id
  , i_session_file_id       in     com_api_type_pkg.t_long_id
  , i_record_number         in     com_api_type_pkg.t_short_id
  , i_proc_bin              in     com_api_type_pkg.t_bin
  , i_is_dispute            in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_draft ';
    l_bnv_napas_fin_mes            cst_bnv_napas_api_type_pkg.t_bnv_napas_fin_mes_rec;
    l_tc_buffer                    com_api_type_pkg.t_text;
    l_recnum                       pls_integer := 1;
    l_exchange_rate                com_api_type_pkg.t_name;
    l_bill_exchange_rate           com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_tc_buffer.count() = ' || i_tc_buffer.count()
                                   ||  ', i_inst_id [' || i_inst_id
                                   || '], i_file_id [' || i_file_id
                                   || '], i_record_number [' || i_record_number
                                   || '], i_proc_date [#1], i_proc_bin [#2]'
      , i_env_param1 => to_char(i_proc_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param2 => i_proc_bin
    );

    l_tc_buffer := i_tc_buffer(l_recnum);

    -- Message fields
    l_bnv_napas_fin_mes.id                 := opr_api_create_pkg.get_id;
    l_bnv_napas_fin_mes.mti                := get_value(l_tc_buffer, '[MTI]');
    l_bnv_napas_fin_mes.card_number        := trim(get_value(l_tc_buffer, '[F2]'));
    l_bnv_napas_fin_mes.trans_code         := trim(get_value(l_tc_buffer, '[F3]'));
    l_bnv_napas_fin_mes.file_id            := i_file_id;
    l_bnv_napas_fin_mes.record_number      := i_record_number;
    l_bnv_napas_fin_mes.service_code       := trim(get_value(l_tc_buffer, '[SVC]'));
    l_bnv_napas_fin_mes.channel_code       := trim(get_value(l_tc_buffer, '[TCC]'));
    l_bnv_napas_fin_mes.oper_currency      := trim(get_value(l_tc_buffer, '[F49]'));

    l_bnv_napas_fin_mes.oper_amount        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[F4]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Transaction amount'
                                              );

    l_bnv_napas_fin_mes.real_amount        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[RTA]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Real transaction amount'
                                              );

    l_bnv_napas_fin_mes.sttl_currency      := trim(get_value(l_tc_buffer, '[F50]'));
    l_bnv_napas_fin_mes.sttl_amount        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[F5]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.sttl_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Settlement amount'
                                              );


    l_exchange_rate                        := get_value(l_tc_buffer, '[F9]');
    l_bnv_napas_fin_mes.sttl_exchange_rate := prepare_exchange_rate(
                                                  i_rate_str       => substr(l_exchange_rate, 2) 
                                                , i_exponent       => substr(l_exchange_rate, 1, 1) 
                                                , i_exchange_desc  => 'Settlement exchange rate'
                                              );

    l_bnv_napas_fin_mes.bill_currency      := trim(get_value(l_tc_buffer, '[F51]'));
    l_bnv_napas_fin_mes.bill_amount        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[F6]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.bill_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Billing amount'
                                              );
    l_bnv_napas_fin_mes.bill_real_amount   := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[RCA]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.bill_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Billing real amount'
                                              );

    l_bill_exchange_rate                   := get_value(l_tc_buffer, '[F10]');
    l_bnv_napas_fin_mes.bill_exchange_rate := prepare_exchange_rate(
                                                  i_rate_str       => substr(l_bill_exchange_rate, 2) 
                                                , i_exponent       => substr(l_bill_exchange_rate, 1, 1) 
                                                , i_exchange_desc  => 'Cardholder billing exchange rate'
                                              );

    l_bnv_napas_fin_mes.sys_trace_number   := to_number(get_value(l_tc_buffer, '[F11]'));
    l_bnv_napas_fin_mes.trans_date         := date_mmddhhmiss(
                                                  get_value(l_tc_buffer, '[F13]') 
                                               || get_value(l_tc_buffer, '[F12]') 
                                              );

    l_bnv_napas_fin_mes.sttl_date          := date_mmdd(        get_value(l_tc_buffer, '[F15]' ));
    l_bnv_napas_fin_mes.mcc                := trim(             get_value(l_tc_buffer, '[F18]' ));
    l_bnv_napas_fin_mes.pos_entry_mode     := to_number(        get_value(l_tc_buffer, '[F22]' ));
    l_bnv_napas_fin_mes.pos_condition_code := to_number(        get_value(l_tc_buffer, '[F25]' ));
    l_bnv_napas_fin_mes.terminal_number    := trim(             get_value(l_tc_buffer, '[F41]' ));
    l_bnv_napas_fin_mes.acq_inst_bin       := to_char(to_number(get_value(l_tc_buffer, '[ACQ]' )));
    l_bnv_napas_fin_mes.iss_inst_bin       := to_char(to_number(get_value(l_tc_buffer, '[ISS]' )));
    l_bnv_napas_fin_mes.merchant_number    := trim(             get_value(l_tc_buffer, '[MID]' ));
    l_bnv_napas_fin_mes.bnb_inst_bin       := to_char(to_number(get_value(l_tc_buffer, '[BNB]' )));
    l_bnv_napas_fin_mes.src_account_number := trim(             get_value(l_tc_buffer, '[F102]'));
    l_bnv_napas_fin_mes.dst_account_number := trim(             get_value(l_tc_buffer, '[F103]'));

    l_bnv_napas_fin_mes.iss_fee_napas      := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[SVFISSNP]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of Issuer for NAPAS'
                                              );

    l_bnv_napas_fin_mes.iss_fee_acq        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[IRFISSACQ]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of Issuer for Acquirer'
                                              );

    l_bnv_napas_fin_mes.iss_fee_bnb        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[IRFISSBNB]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of Issuer for BNB'
                                              );

    l_bnv_napas_fin_mes.acq_fee_napas      := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[SVFACQNP]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of Acquirer for NAPAS'
                                              );

    l_bnv_napas_fin_mes.acq_fee_iss        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[IRFACQISS]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of Acquirer for Issuer'
                                              );

    l_bnv_napas_fin_mes.acq_fee_bnb        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[IRFACQBNB]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of Acquirer for BNB'
                                              );

    l_bnv_napas_fin_mes.bnb_fee_napas      := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[SVFBNBNP]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of BNB for NAPAS'
                                              );

    l_bnv_napas_fin_mes.bnb_fee_iss        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[IRFBNBISS]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of BNB for Issuer'
                                              );

    l_bnv_napas_fin_mes.bnb_fee_acq        := prepare_amount(
                                                  i_amount_str     => get_value(l_tc_buffer, '[IRFBNBACQ]')
                                                , i_curr_code      => l_bnv_napas_fin_mes.oper_currency
                                                , i_exponent       => 2
                                                , i_amount_desc    => 'Service fee of BNB for Acquirer'
                                              );

    l_bnv_napas_fin_mes.rrn                := trim(     get_value(l_tc_buffer, '[F37]'));
    l_bnv_napas_fin_mes.auth_code          := trim(     get_value(l_tc_buffer, '[F38]'));
    l_bnv_napas_fin_mes.transaction_id     := trim(     get_value(l_tc_buffer, '[TRN]'));
    l_bnv_napas_fin_mes.resp_code          := to_number(get_value(l_tc_buffer, '[RRC]'));

    if l_bnv_napas_fin_mes.oper_amount  != l_bnv_napas_fin_mes.real_amount and l_bnv_napas_fin_mes.oper_amount != 0 then
        l_bnv_napas_fin_mes.is_reversal := com_api_const_pkg.TRUE;
    else
        l_bnv_napas_fin_mes.is_reversal := com_api_const_pkg.FALSE;
    end if;

    l_bnv_napas_fin_mes.inst_id         := i_inst_id;
    l_bnv_napas_fin_mes.network_id      := i_network_id;
    l_bnv_napas_fin_mes.is_dispute      := i_is_dispute;
    l_bnv_napas_fin_mes.status          := cst_bnv_napas_api_const_pkg.MSG_STATUS_LOADED;

    if l_bnv_napas_fin_mes.is_dispute    = com_api_const_pkg.TRUE then
        assign_dispute(
            io_bnv_napas_fin_mes => l_bnv_napas_fin_mes
        );
    end if;

    l_bnv_napas_fin_mes.id := cst_bnv_napas_api_fin_msg_pkg.put_message(
                                  i_fin_rec => l_bnv_napas_fin_mes
                              );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> l_bnv_napas_fin_mes.id [#1]'
      , i_env_param1 => l_bnv_napas_fin_mes.id
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

-- Processing of Incoming files
procedure process(
    i_network_id            in     com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_tc                           com_api_type_pkg.t_byte_char;
    l_first_tc                     com_api_type_pkg.t_byte_char;
    l_tc_buffer                    cst_bnv_napas_api_type_pkg.t_tc_buffer;
    l_bnv_napas_file               cst_bnv_napas_api_type_pkg.t_bnv_napas_file_rec;
    l_host_id                      com_api_type_pkg.t_tiny_id;
    l_standard_id                  com_api_type_pkg.t_tiny_id;
    l_record_number                com_api_type_pkg.t_long_id := 0;
    l_record_count                 com_api_type_pkg.t_long_id := 0;
    l_errors_count                 com_api_type_pkg.t_long_id := 0;
    l_trailer_found                com_api_type_pkg.t_boolean;
    l_is_dispute                   com_api_type_pkg.t_boolean;
    l_file_participant_type        varchar2(3);

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
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

    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id
                   || '], record_count [' || p.record_count || ']'
        );
        l_errors_count := 0;
        if substr(p.file_name, 25, 2) = 'SL' then
            l_is_dispute := 1;
        else
            l_is_dispute := 0;
        end if;
        l_file_participant_type := substr(p.file_name, 8, 3);
        
        begin
            savepoint sp_bnv_napas_incoming_file;

            l_record_number := 1;
            l_tc_buffer.delete;

            for r in (
                select record_number
                     , raw_data
                     , substr(next_data, 1, 2) next_tc
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

                if l_bnv_napas_file.id is null and l_tc != cst_bnv_napas_api_const_pkg.TC_FILE_HEADER then
                    com_api_error_pkg.raise_error(
                        i_error       => 'BNV_NAPAS_FILE_MISSING_HEADER'
                      , i_env_param1  => l_bnv_napas_file.id
                    );
                end if;

                l_record_number := r.record_number;

                l_first_tc  := substr(l_tc_buffer(1), 1, 2);

                -- process file header record
                if l_first_tc = cst_bnv_napas_api_const_pkg.TC_FILE_HEADER then
                    process_file_header(
                        i_header_data           => l_tc_buffer(1)
                      , i_network_id            => i_network_id
                      , i_standard_id           => l_standard_id
                      , i_session_file_id       => p.session_file_id
                      , i_file_participant_type => l_file_participant_type
                      , o_bnv_napas_file        => l_bnv_napas_file
                    );

                -- process currency convertional rate updates
                elsif l_first_tc = cst_bnv_napas_api_const_pkg.TC_FILE_TRAILER then
                    process_file_trailer(
                        i_tc_buffer         => l_tc_buffer
                      , io_bnv_napas_file   => l_bnv_napas_file
                    );
                    l_trailer_found  := com_api_const_pkg.TRUE;

                -- process draft transactions
                elsif l_first_tc = cst_bnv_napas_api_const_pkg.TC_DRAFT then
                    process_draft(
                        i_tc_buffer            => l_tc_buffer
                      , i_network_id           => i_network_id
                      , i_host_id              => l_host_id
                      , i_standard_id          => l_standard_id
                      , i_inst_id              => l_bnv_napas_file.inst_id
                      , i_proc_date            => l_bnv_napas_file.proc_date
                      , i_file_id              => l_bnv_napas_file.id
                      , i_session_file_id      => p.session_file_id
                      , i_record_number        => l_record_number
                      , i_proc_bin             => l_bnv_napas_file.proc_bin
                      , i_is_dispute           => l_is_dispute
                    );
                end if;

                -- cleanup buffer before loading next TC record(s)
                l_tc_buffer.delete;

                if g_error_flag = com_api_const_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

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
                            i_error       => 'BNV_NAPAS_FILE_MISSING_TRAILER'
                          , i_env_param1  => l_bnv_napas_file.id
                        );
                    end if;
                end if;
            end loop;

            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_bnv_napas_incoming_file;

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

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with l_record_number [#3], l_tc [#1]'
          , i_env_param1 => l_tc
          , i_env_param3 => l_record_number
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
