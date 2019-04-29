create or replace package body amx_prc_atm_rcn_pkg is

g_error_flag        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
g_errors_count      com_api_type_pkg.t_long_id := 0;

procedure process_file_header(
    i_header_data         in     com_api_type_pkg.t_raw_data
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id  in     com_api_type_pkg.t_long_id
  , o_amx_file               out amx_api_type_pkg.t_amx_file_rec
) is
    l_file_date    com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text          => 'amx_prc_atm_rcn_pkg.process_file_header start'
    );

    o_amx_file.session_file_id     := i_incom_sess_file_id;
    o_amx_file.is_incoming         := com_api_type_pkg.TRUE;
    o_amx_file.is_rejected         := com_api_type_pkg.FALSE;
    o_amx_file.network_id          := i_network_id;
    l_file_date                    := substr(i_header_data, 18, 10) || substr(i_header_data, 29, 8);
    o_amx_file.transmittal_date    := to_date(substr(l_file_date, 3), amx_api_const_pkg.FORMAT_RCN_HEADER_DATE);
    o_amx_file.file_number         := substr(i_header_data, 11, 6);

    -- checks
    amx_api_file_pkg.check_file_processed(
        i_amx_file      => o_amx_file
    );

    o_amx_file.id := amx_file_seq.nextval;

    trc_log_pkg.debug (
        i_text          => 'o_amx_file.id = ' || o_amx_file.id
    );

    trc_log_pkg.debug (
        i_text          => 'amx_prc_atm_rcn_pkg.process_file_header end'
    );
end;

procedure process_detail(
    i_raw_data         in     com_api_type_pkg.t_raw_data
  , i_amx_file         in     amx_api_type_pkg.t_amx_file_rec
)
is
    l_atm_rcn_rec             amx_api_type_pkg.t_amx_atm_rcn_rec;
    l_date                    com_api_type_pkg.t_name;
    l_terminal                acq_api_type_pkg.t_terminal;
begin
    l_atm_rcn_rec.file_id                             := i_amx_file.id;
    l_atm_rcn_rec.status                              := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_atm_rcn_rec.file_id                             := i_amx_file.id;

    l_atm_rcn_rec.record_type                         := substr(i_raw_data, 1, 1);       -- Record Type
    l_atm_rcn_rec.msg_seq_number                      := substr(i_raw_data, 2, 5);       -- Record Sequence Number

    l_atm_rcn_rec.card_number                         := substr(i_raw_data, 7, 19);      -- Primary Account Number (PAN)

    l_date := substr(i_raw_data, 26, 8) || substr(i_raw_data, 34, 6);                    -- Transaction Date & Time
    l_atm_rcn_rec.trans_date := to_date(substr(l_date, 3), amx_api_const_pkg.FORMAT_RCN_DATE);

    l_date := substr(i_raw_data, 40, 8) || substr(i_raw_data, 48, 6);                    -- System Date & Time
    l_atm_rcn_rec.system_date := to_date(substr(l_date, 3), amx_api_const_pkg.FORMAT_RCN_DATE);

    l_date := substr(i_raw_data, 54, 8);                                                 -- Settlement Date
    l_atm_rcn_rec.sttl_date                           := to_date(substr(l_date, 3), 'YYMMDD');

    l_atm_rcn_rec.terminal_number                     := substr(i_raw_data, 62, 8);      -- Card Acceptor Terminal Identification
    l_atm_rcn_rec.system_trace_audit_number           := substr(i_raw_data, 70, 6);      -- Systems Trace Audit Number
    l_atm_rcn_rec.dispensed_currency                  := substr(i_raw_data, 76, 3);      -- Dispensed Currency
    l_atm_rcn_rec.amount_requested                    := substr(i_raw_data, 79, 15);     -- Amount Requested
    l_atm_rcn_rec.amount_ind                          := substr(i_raw_data, 94, 15);     -- Amount Indicator
    l_atm_rcn_rec.sttl_rate                           := substr(i_raw_data, 109, 12);    -- Settlement Conversion Rate
    l_atm_rcn_rec.sttl_currency                       := substr(i_raw_data, 121, 3);     -- Settlement Currency Code
    l_atm_rcn_rec.sttl_amount_requested               := substr(i_raw_data, 124, 15);    -- Settlement Amount Requested
    l_atm_rcn_rec.sttl_amount_approved                := substr(i_raw_data, 139, 15);    -- Settlement Amount Approved
    l_atm_rcn_rec.sttl_amount_dispensed               := substr(i_raw_data, 154, 15);    -- Settlement Amount Dispensed
    l_atm_rcn_rec.sttl_network_fee                    := substr(i_raw_data, 169, 11);    -- Settlement Network Fee
    l_atm_rcn_rec.sttl_other_fee                      := substr(i_raw_data, 180, 11);    -- Settlement Fee Other
    l_atm_rcn_rec.terminal_country_code               := substr(i_raw_data, 277, 2);     -- Terminal Country Code
    l_atm_rcn_rec.merchant_country_code               := substr(i_raw_data, 279, 2);     -- Card Acceptor Country Code
    l_atm_rcn_rec.card_billing_country_code           := substr(i_raw_data, 281, 2);     -- Cardmember Billing Country Code
    l_atm_rcn_rec.terminal_location                   := substr(i_raw_data, 283, 40);    -- Terminal Location
    l_atm_rcn_rec.auth_status                         := substr(i_raw_data, 363, 1);     -- Authorization Status
    l_atm_rcn_rec.trans_indicator                     := substr(i_raw_data, 363, 1);     -- Transaction Indicator
    l_atm_rcn_rec.orig_action_code                    := substr(i_raw_data, 378, 3);     -- Original Action Code
    l_atm_rcn_rec.approval_code                       := substr(i_raw_data, 385, 6);     -- Approval Code
    l_atm_rcn_rec.add_ref_number                      := substr(i_raw_data, 391, 8);     -- Additional Reference Number
    l_atm_rcn_rec.trans_id                            := substr(i_raw_data, 400, 15);    -- Transaction Identifier (TID)

    l_terminal :=
        acq_api_terminal_pkg.get_terminal(
            i_terminal_number       => l_atm_rcn_rec.terminal_number
          , i_inst_id               => null
          , i_mask_error            => com_api_const_pkg.TRUE
        );

    if l_terminal.id is not null then
        l_atm_rcn_rec.inst_id := l_terminal.inst_id;
    else
        l_atm_rcn_rec.is_invalid := com_api_type_pkg.TRUE;
        trc_log_pkg.warn(
            i_text          => 'Terminal [#1] not found'
          , i_env_param1    => l_atm_rcn_rec.terminal_number
        );
    end if;

    if l_atm_rcn_rec.is_invalid = com_api_type_pkg.TRUE then
        g_error_flag := com_api_type_pkg.TRUE;
        l_atm_rcn_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;

    amx_api_fin_message_pkg.put_atm_rcn_message(i_atm_rcn_rec => l_atm_rcn_rec);
end;

procedure process_file_trailer(
    io_amx_file           in  out amx_api_type_pkg.t_amx_file_rec
)
is
begin
    insert into amx_file(
        id
      , is_incoming
      , network_id
      , transmittal_date
      , file_number
      , session_file_id
    )
    values(
        io_amx_file.id
      , io_amx_file.is_incoming
      , io_amx_file.network_id
      , io_amx_file.transmittal_date
      , io_amx_file.file_number
      , io_amx_file.session_file_id
    );

    trc_log_pkg.debug (
        i_text          => 'amx_prc_atm_rcn_pkg.process_file_trailer end'
    );
end;

procedure process
is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';

    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_network_id            com_api_type_pkg.t_tiny_id;
    l_amx_file              amx_api_type_pkg.t_amx_file_rec;
    l_record_type           com_api_type_pkg.t_one_char;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Start loading Amex ATM reconciliation file'
    );

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'enumerating messages'
    );
    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count
    );

    trc_log_pkg.debug(
        i_text          => 'estimation record = ' || l_record_count
    );

    l_network_id := amx_api_const_pkg.TARGET_NETWORK;

    l_record_count := 0;
    g_errors_count := 0;

    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop

        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id || '], record_count [' || p.record_count || ']'
        );

        begin
            savepoint sp_amx_atm_rcn_file;

            l_errors_count := 0;

            for r in (
                select record_number
                     , raw_data
                     , count(*) over() cnt
                from prc_file_raw_data
               where session_file_id = p.session_file_id
               order by record_number
            )
            loop
                g_error_flag  := com_api_type_pkg.FALSE;
                l_record_type := substr(r.raw_data, 1, 1);

                if l_record_type = amx_api_const_pkg.ATM_RCN_HEADER then
                    process_file_header(
                        i_header_data         => r.raw_data
                      , i_network_id          => l_network_id
                      , i_incom_sess_file_id  => p.session_file_id
                      , o_amx_file            => l_amx_file
                    );
                elsif l_record_type = amx_api_const_pkg.ATM_RCN_DETAIL then
                    process_detail(
                        i_raw_data            => r.raw_data
                      , i_amx_file            => l_amx_file
                    );
                elsif l_record_type = amx_api_const_pkg.ATM_RCN_TRAILER then
                    process_file_trailer(
                        io_amx_file           => l_amx_file
                    );
                else
                    trc_log_pkg.debug(
                        i_text => 'Not supported record_type [' || l_record_type || ']'
                    );
                end if;

                l_record_count  := l_record_count + 1;

                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;

                -- last record of file
                if r.record_number = r.cnt then
                    g_errors_count := g_errors_count + l_errors_count;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count
                    );
                end if;
            end loop;
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_amx_atm_rcn_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
                );
        end;
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => g_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

end;
/
