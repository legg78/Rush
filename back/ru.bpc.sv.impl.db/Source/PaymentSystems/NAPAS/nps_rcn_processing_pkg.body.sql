create or replace package body nps_rcn_processing_pkg is

-- Fields of a fin. message
G_COLUMN_LIST               constant com_api_type_pkg.t_text :=
   '  m.id'
|| ', m.mti'
|| ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
|| ', m.trans_code'
|| ', m.service_code'
|| ', m.channel_code'
|| ', m.oper_amount'
|| ', m.real_amount'
|| ', m.oper_currency'
|| ', m.sttl_amount'
|| ', m.sttl_currency'
|| ', m.sttl_exchange_rate'
|| ', m.bill_amount'
|| ', m.bill_real_amount'
|| ', m.bill_currency'
|| ', m.bill_exchange_rate'
|| ', m.sys_trace_number'
|| ', m.trans_date'
|| ', m.sttl_date'
|| ', m.mcc'
|| ', m.pos_entry_mode'
|| ', m.pos_condition_code'
|| ', m.terminal_number'
|| ', m.acq_inst_bin'
|| ', m.iss_inst_bin'
|| ', m.merchant_number'
|| ', m.bnb_inst_bin'
|| ', m.src_account_number'
|| ', m.dst_account_number'
|| ', m.iss_fee_napas'
|| ', m.iss_fee_acq'
|| ', m.iss_fee_bnb'
|| ', m.acq_fee_napas'
|| ', m.acq_fee_iss'
|| ', m.acq_fee_bnb'
|| ', m.bnb_fee_napas'
|| ', m.bnb_fee_acq'
|| ', m.bnb_fee_iss'
|| ', m.rrn'
|| ', m.auth_code'
|| ', m.transaction_id'
|| ', m.resp_code'
|| ', m.is_dispute'
|| ', m.status'
|| ', m.file_id'
|| ', m.record_number'
|| ', m.dispute_id'
|| ', f.inst_id'
|| ', f.network_id'
|| ', m.is_reversal'
;

procedure get_fin_message(
    i_id                 in     com_api_type_pkg.t_long_id
  , o_fin_rec               out nps_api_type_pkg.t_napas_fin_mes_rec
  , i_mask_error         in     com_api_type_pkg.t_boolean                 default com_api_const_pkg.FALSE
) is
    l_fin_cur                   sys_refcursor;
    l_statement                 com_api_type_pkg.t_text;
begin
    l_statement :=
    'select ' || G_COLUMN_LIST          ||
     ' from nps_fin_message m'    ||
         ', nps_card c'       ||
         ', nps_file f'   ||
    ' where m.id = :i_id'               ||
      ' and f.id = m.file_id'           ||
      ' and c.id(+) = m.id';

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
end get_fin_message;

procedure process_disputes(
    i_start_date         in date
  , i_end_date           in date
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_disputes: ';
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_fin_rec               nps_api_type_pkg.t_napas_fin_mes_rec;
    l_estimated_count       com_api_type_pkg.t_long_id                         := 0;
    l_processed_count       com_api_type_pkg.t_long_id                         := 0;
    l_excepted_count        com_api_type_pkg.t_long_id                         := 0;
begin
    savepoint sp_process_disputes;

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'Start'
    );

    prc_api_stat_pkg.log_start;

    select count(*)
      into l_estimated_count
      from nps_fin_message m
     where decode(m.status, 'CLMS0040', 'CLMS0040', null) = 'CLMS0040'
       and m.is_dispute = com_api_const_pkg.TRUE
       and m.dispute_id is null;

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'l_estimated_count [#1]'
      , i_env_param1      => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    for r_fin_mes in (
        select m.id 
             , f.network_id
             , f.session_file_id
          from nps_fin_message m
             , nps_file f
         where decode(status, 'CLMS0040', 'CLMS0040', null) = 'CLMS0040'
           and m.is_dispute = com_api_const_pkg.TRUE
           and m.dispute_id is null
           and f.id         = m.file_id
    ) loop
        -- get network communication standard
        l_host_id :=
            net_api_network_pkg.get_default_host(
                i_network_id   => r_fin_mes.network_id
            );
        l_standard_id :=
            net_api_network_pkg.get_offline_standard(
                i_host_id => l_host_id
            );

        get_fin_message(i_id      => r_fin_mes.id
                      , o_fin_rec => l_fin_rec);

        nps_api_fin_message_pkg.create_operation(
            i_fin_rec              => l_fin_rec
          , i_standard_id          => l_standard_id
          , i_status               => null
          , i_create_disp_case     => com_api_const_pkg.TRUE
          , i_incom_sess_file_id   => r_fin_mes.session_file_id
        );

        l_processed_count := l_processed_count + 1;

        if mod(l_processed_count, 100) = 0 then
            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => l_excepted_count
            );
        end if;
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'Finish'
    );

exception
    when others then
        rollback to savepoint sp_process_disputes;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;

        raise;

end process_disputes;

function md5hash(
    i_line               in com_api_type_pkg.t_text
  , i_password           in com_api_type_pkg.t_name
)
    return com_api_type_pkg.t_md5
is
    l_result                com_api_type_pkg.t_md5;
    l_password              com_api_type_pkg.t_name;
    l_buffer                com_api_type_pkg.t_text;
    l_num                   com_api_type_pkg.t_tiny_id;
    l_pos                   com_api_type_pkg.t_tiny_id;
    l_length                com_api_type_pkg.t_tiny_id;
begin
    l_result    := lower(to_char(rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(i_line)))));    
    l_password  := '5' || i_password || '5';
    l_num       := length(l_password) - 1;

    for i in 1 .. l_num
    loop
        l_pos       := to_number(substr(l_password, i, 1)) + 1;
        l_length    := 20 - to_number(substr(l_password, i + 1, 1));
        l_buffer    := l_buffer || substr(l_result, l_pos, l_length);
    end loop;

    l_result := lower(to_char(rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(l_buffer)))));

    return l_result;
end md5hash;

procedure reconciliation(
    i_start_date         in date
  , i_end_date           in date
  , i_network_id         in com_api_type_pkg.t_network_id
  , i_is_reconcile_bnb   in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
)
is
    l_start_id              com_api_type_pkg.t_long_id;
    l_end_id                com_api_type_pkg.t_long_id;
    l_status                com_api_type_pkg.t_dict_value;

    l_iss_session_file_id   com_api_type_pkg.t_long_id;
    l_acq_session_file_id   com_api_type_pkg.t_long_id;
    l_bnb_session_file_id   com_api_type_pkg.t_long_id;
    
    l_iss_count             com_api_type_pkg.t_count := 0;
    l_acq_count             com_api_type_pkg.t_count := 0;
    l_bnb_count             com_api_type_pkg.t_count := 0;

    l_operation             opr_api_type_pkg.t_oper_rec;
    l_participant_iss       opr_api_type_pkg.t_oper_part_rec;
    l_participant_acq       opr_api_type_pkg.t_oper_part_rec;
    l_participant_dst       opr_api_type_pkg.t_oper_part_rec;
    
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_tiny_id;
    
    l_proc_bin              com_api_type_pkg.t_name;
    l_param_tab             com_api_type_pkg.t_param_tab;
    
    l_fin_rec               nps_api_type_pkg.t_napas_fin_mes_rec;
    l_line                  com_api_type_pkg.t_text;
    l_start_date            date;
    l_end_date              date;
    l_report_date           date;
    l_last_file_name        com_api_type_pkg.t_name;
    l_tag_id                com_api_type_pkg.t_short_id;

    DATE_OFFSET    constant com_api_type_pkg.t_tiny_id := 3;
    
    procedure open_file(
        io_sess_file_id    in  out  com_api_type_pkg.t_long_id
      , i_file_type             in  com_api_type_pkg.t_dict_value    default null
    ) 
    as
        l_line         com_api_type_pkg.t_text;
        l_params       com_api_type_pkg.t_param_tab;
    begin
        rul_api_param_pkg.set_param(
            i_name     => 'ACQ_BIN'
          , i_value    => l_proc_bin
          , io_params  => l_params
        );
        
        rul_api_param_pkg.set_param(
            i_name     => 'REPORT_DATE'
          , i_value    => l_report_date
          , io_params  => l_params
        );
        
        prc_api_file_pkg.open_file(
            o_sess_file_id  => io_sess_file_id
          , i_file_type     => i_file_type
          , io_params       => l_params
        );
    
        l_line := 'HR';
        l_line := l_line || '[REV]'  || lpad(l_proc_bin, 8, ' '); 
        l_line := l_line || '[DATE]' || to_char(l_report_date, 'DDMMYYYY');
        
        prc_api_file_pkg.put_line(
             i_raw_data      => l_line
           , i_sess_file_id  => io_sess_file_id
         );
    end;
    
    function get_line(
        i_fin_rec                nps_api_type_pkg.t_napas_fin_mes_rec
    ) return com_api_type_pkg.t_text as
        l_line      com_api_type_pkg.t_text;
    begin
        l_line := 'DR';
        l_line := l_line || '[MTI]'  || '0210';
        l_line := l_line || '[F2]'   || lpad(nvl(i_fin_rec.card_number     , ' ')  , 19);
        l_line := l_line || '[F3]'   || lpad(nvl(i_fin_rec.trans_code      , ' ')  ,  6);
        l_line := l_line || '[SVC]'  || lpad(nvl(i_fin_rec.service_code    , ' ')  , 10);
        l_line := l_line || '[TCC]'  || lpad(nvl(i_fin_rec.channel_code    , ' ')  ,  2);
        l_line := l_line || '[F4]'   || lpad(nvl(i_fin_rec.oper_amount     , 0) || '00', 12, '0');
        l_line := l_line || '[RTA]'  || lpad(nvl(i_fin_rec.real_amount     , 0) || '00', 12, '0');
        l_line := l_line || '[F49]'  || lpad(nvl(i_fin_rec.oper_currency   , ' ')  ,  3);
        l_line := l_line || '[F5]'   || lpad(nvl(i_fin_rec.sttl_amount     , 0) || '00', 12, '0');
        l_line := l_line || '[F50]'  || lpad(nvl(i_fin_rec.sttl_currency   , nps_api_const_pkg.NAPAS_CURRENCY_CODE), 3);
        l_line := l_line || '[F9]'   || lpad('1'                                   ,  8, '0');
        l_line := l_line || '[F6]'   || lpad(nvl(i_fin_rec.oper_amount     , 0) || '00', 12, '0');
        l_line := l_line || '[RCA]'  || lpad(nvl(i_fin_rec.real_amount     , 0) || '00', 12, '0');
        l_line := l_line || '[F51]'  || lpad(nvl(i_fin_rec.oper_currency   , ' ')  ,  3);
        l_line := l_line || '[F10]'  || lpad('1'                                   ,  8, '0');
        l_line := l_line || '[F11]'  || lpad(nvl(i_fin_rec.sys_trace_number, 0)    ,  6, '0');
        l_line := l_line || '[F12]'  || nvl(to_char(i_fin_rec.trans_date, 'hh24miss'), '00000');
        l_line := l_line || '[F13]'  || nvl(to_char(i_fin_rec.trans_date, 'mmdd')  , '0000');
        l_line := l_line || '[F15]'  || nvl(to_char(i_fin_rec.sttl_date , 'mmdd')  , '0000');

        l_line := l_line || '[F18]'  || lpad(nvl(i_fin_rec.mcc             , ' ')  , 4);
        l_line := l_line || '[F22]'  || lpad(nvl(to_char(i_fin_rec.pos_entry_mode)  , '0')  , 3, '0');
        l_line := l_line || '[F25]'  || lpad(nvl(to_char(i_fin_rec.pos_condition_code),'0') , 2, '0');
        
        l_line := l_line || '[F41]'  || lpad(nvl(substr(i_fin_rec.terminal_number, 1, 8), ' '),  8);
        l_line := l_line || '[ACQ]'  || lpad(nvl(i_fin_rec.acq_inst_bin, ' ')      ,  8);
        l_line := l_line || '[ISS]'  || lpad(nvl(i_fin_rec.iss_inst_bin, ' ')      ,  8);
        l_line := l_line || '[MID]'  || lpad(nvl(substr(i_fin_rec.merchant_number, 1, 8), ' '),  15);
        l_line := l_line || '[BNB]'  || lpad(nvl(i_fin_rec.bnb_inst_bin, ' ')      ,  8);
        l_line := l_line || '[F102]' || lpad(nvl(i_fin_rec.src_account_number, ' '), 28);
        l_line := l_line || '[F103]' || lpad(nvl(i_fin_rec.dst_account_number, ' '), 28);
        l_line := l_line || '[F37]'  || lpad(nvl(i_fin_rec.rrn, ' ')               , 12);
        l_line := l_line || '[F38]'  || lpad(nvl(i_fin_rec.auth_code, ' ')         ,  6);
        l_line := l_line || '[TRN]'  || lpad(nvl(i_fin_rec.transaction_id, ' ')    , 16);
        l_line := l_line || '[RRC]'  || lpad(nvl(to_char(i_fin_rec.resp_code), '0'),  4, '0');
        l_line := l_line || '[RSV1]' || lpad(' ', 100);
        l_line := l_line || '[RSV2]' || lpad(' ', 100);
        l_line := l_line || '[RSV3]' || lpad(' ', 100);
        l_line := l_line || '[CSR]';
        l_line := l_line || md5hash(
                                i_line      => l_line
                              , i_password  => l_proc_bin
                            );

        return l_line;
    end;
    
    function get_trailer(
        i_count   com_api_type_pkg.t_count
    ) return com_api_type_pkg.t_text as
        l_line          com_api_type_pkg.t_text;
        l_current_date  date := com_api_sttl_day_pkg.get_sysdate;
    begin
        l_line := 'TR';
        l_line := l_line || '[NOT]'  || lpad(nvl(to_char(i_count), '0'), 9, '0');
        l_line := l_line || '[CRE]'  || lpad(acm_api_user_pkg.get_user_name, 20, ' ');
        l_line := l_line || '[TIME]' || to_char(l_current_date, 'HH24MISS');
        l_line := l_line || '[DATE]' || to_char(l_current_date, 'DDMMYYYY');
        l_line := l_line || '[CSF]';
        l_line := l_line || md5hash(
                                i_line      => l_line
                              , i_password  => l_proc_bin
                            );
        
        return l_line;
    end;
    
    procedure close_file(
        i_sess_file_id    in  com_api_type_pkg.t_long_id
      , i_count           in  com_api_type_pkg.t_count
    ) as
    begin
        prc_api_file_pkg.put_line(
            i_raw_data      => get_trailer(i_count => i_count)
          , i_sess_file_id  => i_sess_file_id
        );
        
        prc_api_file_pkg.close_file(
            i_sess_file_id  => i_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end;
    
    procedure choose_file_and_write( 
        i_fin_rec               in  nps_api_type_pkg.t_napas_fin_mes_rec
      , i_acq_inst_id           in  com_api_type_pkg.t_tiny_id
      , i_participant_type      in  varchar2
      , i_oper_type             in  com_api_type_pkg.t_dict_value
      , i_card_number           in  com_api_type_pkg.t_card_number
    ) as
        l_card_inst_id        com_api_type_pkg.t_inst_id;
        l_card_network_id     com_api_type_pkg.t_tiny_id;
        l_card_type_id        com_api_type_pkg.t_tiny_id;
        l_card_country        com_api_type_pkg.t_curr_code;
        l_session_file_id     com_api_type_pkg.t_long_id;
        l_fin_rec             nps_api_type_pkg.t_napas_fin_mes_rec;
    begin
        l_fin_rec := i_fin_rec;

        if i_oper_type = opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL_CREDI then
            if l_fin_rec.acq_inst_bin = l_proc_bin then
                l_session_file_id    := l_iss_session_file_id;
                l_iss_count          := l_iss_count + 1;
                if i_participant_type is null then
                    -- not exist in NAPAS
                    l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0116');
                else
                    -- not exist in SV
                    l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0117');
                end if;
                
                trc_log_pkg.debug(
                    i_text            => 'Operation ' || l_fin_rec.id || '; ISS file, response_code = ' ||l_fin_rec.resp_code
                );
            end if;
        else
            iss_api_bin_pkg.get_bin_info(
                  i_card_number      => i_card_number
                , o_card_inst_id     => l_card_inst_id
                , o_card_network_id  => l_card_network_id
                , o_card_type        => l_card_type_id
                , o_card_country     => l_card_country
                , i_raise_error      => com_api_const_pkg.FALSE
            );
            
            if i_participant_type = nps_api_const_pkg.PARTICIPANT_TYPE_ISS or l_card_inst_id is not null then
                l_session_file_id    := l_iss_session_file_id;
                l_iss_count          := l_iss_count + 1;
                if i_participant_type is null then
                    -- not exist in NAPAS
                    l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0116');
                else
                    -- not exist in SV
                    l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0117');
                end if;
                
                trc_log_pkg.debug(
                    i_text            => 'Operation ' || l_fin_rec.id || '; ISS file, response_code = ' ||l_fin_rec.resp_code
                );
            end if;
        end if;
        
        if l_session_file_id is null then
            if i_participant_type = nps_api_const_pkg.PARTICIPANT_TYPE_ACQ or i_acq_inst_id = l_inst_id then
                l_session_file_id := l_acq_session_file_id;
                l_acq_count := l_acq_count + 1;
                if i_participant_type is null then 
                    -- not exist in NAPAS
                    l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0117');
                else 
                    -- not exist in SV
                    l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0115');
                end if;
                
                trc_log_pkg.debug(
                    i_text            => 'Operation ' || l_fin_rec.id || '; ACQ file, response_code = ' ||l_fin_rec.resp_code
                );
            end if;
        end if;
        
        if l_session_file_id is null and i_is_reconcile_bnb = com_api_const_pkg.TRUE then
            l_session_file_id := l_bnb_session_file_id;
            l_bnb_count := l_bnb_count + 1;
            if i_participant_type is null then 
                -- not exist in NAPAS
                l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0117');
            else 
                -- not exist in SV
                l_fin_rec.resp_code := nvl(l_fin_rec.resp_code, '0115');
            end if;
        end if;

        if l_session_file_id is not null then
            prc_api_file_pkg.put_line(
                i_raw_data      => get_line(i_fin_rec => l_fin_rec)
              , i_sess_file_id  => l_session_file_id
            );
        end if;
    end;
    
begin
    trc_log_pkg.debug(
        i_text            => 'reconciliation started'
    );
    
    l_start_date := coalesce(i_start_date, com_api_sttl_day_pkg.get_sysdate);
    l_end_date   := coalesce(i_end_date  , trunc(l_start_date) + 1);
    l_start_id   := com_api_id_pkg.get_from_id(l_start_date - DATE_OFFSET);
    l_end_id     := com_api_id_pkg.get_till_id(l_end_date + DATE_OFFSET);
    
    select max(file_name) keep (dense_rank first order by f.file_date desc)
      into l_last_file_name
      from prc_session_file f
     where f.file_type = nps_api_const_pkg.FILE_TYPE_RECON_INCOMING
       and f.id       >= l_start_id;
        
    if l_last_file_name is not null then
        l_report_date := to_date(substr(l_last_file_name, 1, 6), 'MMDDYY');
        trc_log_pkg.debug(
            i_text            => 'Last incoming filename ' || l_last_file_name
        );
    else
        l_report_date := l_start_date;
    end if;

    begin
        select m.id host_id
             , r.inst_id
             , s.standard_id
          into l_host_id
             , l_inst_id
             , l_standard_id
          from net_network n
             , net_member m
             , net_interface i
             , net_member r
             , cmn_standard_object s
         where n.id             = i_network_id
           and n.id             = m.network_id
           and n.inst_id        = m.inst_id
           and s.object_id      = m.id
           and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
           and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
           and r.id             = i.consumer_member_id
           and i.host_member_id = m.id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error             => 'NO_NETWORK_DEFAULT_HOST'
                , i_env_param1      => i_network_id
            );
    end;
        
    cmn_api_standard_pkg.get_param_value(
        i_inst_id      => l_inst_id
      , i_standard_id  => l_standard_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id    => l_host_id
      , i_param_name   => nps_api_const_pkg.CMID
      , o_param_value  => l_proc_bin
      , i_param_tab    => l_param_tab
    );
    
    open_file(
        io_sess_file_id  => l_iss_session_file_id
      , i_file_type      => nps_api_const_pkg.FILE_TYPE_RECON_ISS
    );
    open_file(
        io_sess_file_id  => l_acq_session_file_id
      , i_file_type      => nps_api_const_pkg.FILE_TYPE_RECON_ACQ
    );
    open_file(
        io_sess_file_id  => l_bnb_session_file_id
      , i_file_type      => nps_api_const_pkg.FILE_TYPE_RECON_BNB
    );
    
    for r in (            
        with t as (
            select oper_id
                 , oper_type
                 , card_number as opr_card_number
                 , case 
                       when oper_type = opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL_CREDI 
                       then second_card_number
                       else card_number
                   end as src_card_number
                 , case 
                       when oper_type = opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL_CREDI 
                       then card_number
                   end as dst_card_number
                 , oper_date
                 , oper_amount
                 , oper_currency
                 , trace_number
                 , auth_code
                 , terminal_number
                 , pos_entry_mode
                 , pos_cond_code
             from (
                select o.id as oper_id
                     , o.oper_type
                     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                     , iss_api_token_pkg.decode_card_number(i_card_number => nvl(atcn.tag_value, c.card_number)) as second_card_number
                     , nvl(to_date(atd.tag_value,'YYMMDDHH24MISS'), o.oper_date) as oper_date
                     , o.oper_amount
                     , o.oper_currency
                     , atn.tag_value as trace_number
                     , pi.auth_code
                     , o.terminal_number
                     , a.pos_entry_mode
                     , a.pos_cond_code
                  from opr_operation o
            inner join opr_participant pi on pi.oper_id  = o.id and pi.participant_type   = com_api_const_pkg.PARTICIPANT_ISSUER
            inner join opr_participant pa on pa.oper_id  = o.id and pa.participant_type   = com_api_const_pkg.PARTICIPANT_ACQUIRER
            inner join opr_card c         on c.oper_id   = o.id and c.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER
            inner join aut_auth a         on a.id        = o.id
             left join aup_tag_value atd  on atd.auth_id = o.id and atd.tag_id  = aup_api_const_pkg.TAG_ACQ_SWITCH_DATW     and  atd.seq_number = 1
             left join aup_tag_value atn  on atn.auth_id = o.id and atn.tag_id  = aup_api_const_pkg.TAG_TRACE_NUMBER        and  atn.seq_number = 1
             left join aup_tag_value atcn on atcn.auth_id = o.id and atcn.tag_id = aup_api_const_pkg.TAG_SECOND_CARD_NUMBER and atcn.seq_number = 1
                 where o.id            between l_start_id and l_end_id
                   and nvl(to_date(atd.tag_value,'YYMMDDHH24MISS'), o.oper_date) between l_start_date and l_end_date
                   and i_network_id in (pi.network_id, pa.network_id)
                   and o.is_reversal = com_api_const_pkg.FALSE
                   and not exists (select 1 from opr_operation op where o.id = op.original_id and op.is_reversal = com_api_const_pkg.TRUE)
            )
        )
        , f as (
            select f.id
                 , f.status
                 , f.file_id
                 , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                 , o.oper_type
                 , f.trans_date
                 , o.oper_amount
                 , o.oper_currency
                 , f.auth_code
                 , f.sys_trace_number
                 , o.terminal_number
                 , fl.participant_type
              from nps_fin_message f
        inner join nps_card c       on (c.id      = f.id)
        inner join nps_file fl      on (f.file_id = fl.id)
        inner join opr_operation o  on (o.id      = f.id)
             where decode(f.status, 'CLMS0040', 'CLMS0040', null) = 'CLMS0040'
               and f.is_dispute          = com_api_const_pkg.FALSE
        )
        select f.id
             , f.trans_date
             , f.oper_amount as trans_amount
             , f.oper_currency as trans_currency
             , f.sys_trace_number
             , f.participant_type as file_participant_type
             , t.oper_id
             , t.oper_date
             , t.oper_amount
             , t.oper_currency
             , t.trace_number
             , t.pos_entry_mode
             , t.pos_cond_code
             , t.src_card_number
             , t.dst_card_number
             , nvl(t.opr_card_number, f.card_number) as opr_card_number
             , nvl(t.oper_type, f.oper_type) as oper_type
          from t full join f on (
                f.oper_type        = t.oper_type
            and f.trans_date       = t.oper_date
            and f.card_number      = t.src_card_number
            and f.sys_trace_number = t.trace_number
            and f.terminal_number  = t.terminal_number
        )
    )
    loop
        l_line   := null;
        l_status := null;
        l_fin_rec := null;
        
        if r.id is not null and r.oper_id is not null then
            if r.trans_amount = r.oper_amount and r.trans_currency = r.oper_currency then
                l_status     := nps_api_const_pkg.MSG_STATUS_RECONCILED;
            else
                l_status     := nps_api_const_pkg.MSG_STATUS_DIFFERENCE;
            end if;
        elsif r.id is not null then
            l_status         := nps_api_const_pkg.MSG_STATUS_NOT_FOUND_IN_SV;
        end if;
        
        if r.id is not null then
            update nps_fin_message f
               set f.status        = l_status
                 , f.match_oper_id = r.oper_id
             where f.id = r.id;
        end if;
        
        if l_status is null or l_status != nps_api_const_pkg.MSG_STATUS_RECONCILED then
            -- use operation data if avaliable
            if r.oper_id is not null then
                opr_api_operation_pkg.get_operation(
                    i_oper_id   => r.oper_id
                  , o_operation => l_operation
                );
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_operation.id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
                  , o_participant       => l_participant_iss
                );
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_operation.id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
                  , o_participant       => l_participant_acq
                );
                
                l_fin_rec.card_number        := r.src_card_number;
                l_fin_rec.sys_trace_number   := r.trace_number;
                l_fin_rec.trans_date         := r.oper_date;
                l_fin_rec.sttl_date          := l_operation.sttl_date;
                l_fin_rec.oper_amount        := l_operation.oper_amount;
                l_fin_rec.oper_currency      := l_operation.oper_currency;
                
                if nvl(l_operation.sttl_amount,0) = 0 then
                    l_fin_rec.sttl_amount        := l_operation.oper_amount;
                    l_fin_rec.sttl_currency      := l_operation.oper_currency;
                else
                    l_fin_rec.sttl_amount        := l_operation.sttl_amount;
                    l_fin_rec.sttl_currency      := l_operation.sttl_currency;
                end if;

                l_fin_rec.merchant_number    := l_operation.merchant_number;
                l_fin_rec.terminal_number    := l_operation.terminal_number;
                l_fin_rec.rrn                := l_operation.originator_refnum;
                l_fin_rec.mcc                := l_operation.mcc;
                l_fin_rec.auth_code          := l_participant_iss.auth_code;
                l_fin_rec.pos_entry_mode     := r.pos_entry_mode;
                l_fin_rec.pos_condition_code := r.pos_cond_code;
                l_fin_rec.iss_inst_bin       := substr(l_participant_iss.card_number, 1, 6);
                l_fin_rec.trans_code         := aup_api_tag_pkg.get_tag_value(
                                                    i_auth_id   => r.oper_id
                                                  , i_tag_id    => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'DF8635')
                                                );
                l_fin_rec.bnb_inst_bin       := aup_api_tag_pkg.get_tag_value(
                                                    i_auth_id   => r.oper_id
                                                  , i_tag_id    => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'DF8483')
                                                );
                
                if r.oper_type = opr_api_const_pkg.OPER_TYPE_FT_TO_EXTERNAL_CREDI then
                    if l_fin_rec.trans_code like '91__00' then
                        l_fin_rec.dst_account_number := r.dst_card_number;
                    elsif l_fin_rec.trans_code like '91__20' then
                        l_fin_rec.dst_account_number := l_participant_iss.account_number;
                    end if;
                    
                    opr_api_operation_pkg.get_participant(
                        i_oper_id           => l_operation.id
                      , i_participaint_type => com_api_const_pkg.PARTICIPANT_DEST
                      , o_participant       => l_participant_dst
                    );
                    
                    if l_participant_dst.client_id_value is not null then
                        l_fin_rec.src_account_number := l_participant_dst.client_id_value;
                    else
                        l_tag_id := aup_api_tag_pkg.find_tag_by_reference('DF824D');
                        l_fin_rec.src_account_number := aup_api_tag_pkg.get_tag_value(i_auth_id => l_operation.id, i_tag_id => l_tag_id);
                    end if;
                end if;
                
                if l_fin_rec.trans_code is null then
                    l_fin_rec.trans_code := lpad(substr(net_api_map_pkg.get_network_type(
                                                            i_oper_type     => l_operation.oper_type
                                                          , i_standard_id   => nps_api_const_pkg.NAPAS_STANDARD_ID
                                                          , i_mask_error    => com_api_type_pkg.TRUE
                                                        )
                                                   , 1
                                                   , 2
                                                 ) || '0000'
                                               , 6
                                               , '0'
                                            );
                end if;
                l_fin_rec.service_code       := null;
                l_fin_rec.channel_code       := null;
                l_fin_rec.transaction_id     := null;
                l_fin_rec.acq_inst_bin       := l_operation.acq_inst_bin;
                
            elsif r.id is not null then
                get_fin_message(i_id      => r.id
                              , o_fin_rec => l_fin_rec);
                l_fin_rec.sys_trace_number := r.sys_trace_number;
                l_fin_rec.resp_code        := null;
            end if;
            
            if l_status  = nps_api_const_pkg.MSG_STATUS_DIFFERENCE then
                l_fin_rec.real_amount := r.oper_amount;
            else
                l_fin_rec.real_amount := 0;
            end if;

            -- response code for amount mismatch
            if l_status  = nps_api_const_pkg.MSG_STATUS_DIFFERENCE then
                l_fin_rec.resp_code  := '0114';
            end if;

            choose_file_and_write(
                i_fin_rec          => l_fin_rec
              , i_acq_inst_id      => l_participant_acq.inst_id
              , i_participant_type => r.file_participant_type
              , i_oper_type        => r.oper_type
              , i_card_number      => r.opr_card_number
            );
        end if;
    end loop;
    
    close_file(
        i_sess_file_id  => l_iss_session_file_id
      , i_count         => l_iss_count
    );
    
    close_file(
        i_sess_file_id  => l_acq_session_file_id
      , i_count         => l_acq_count
    );
    
    close_file(
        i_sess_file_id  => l_bnb_session_file_id
      , i_count         => l_bnb_count
    );
end;

procedure process_transactions(
    i_start_date         in date
  , i_end_date           in date
  , i_network_id         in com_api_type_pkg.t_network_id
  , i_is_reconcile_bnb   in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_transactions: ';
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_fin_rec               nps_api_type_pkg.t_napas_fin_mes_rec;
    l_estimated_count       com_api_type_pkg.t_long_id                         := 0;
    l_processed_count       com_api_type_pkg.t_long_id                         := 0;
    l_excepted_count        com_api_type_pkg.t_long_id                         := 0;
begin
    savepoint sp_process_transactions;

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'Start'
    );

    prc_api_stat_pkg.log_start;

    select count(*)
      into l_estimated_count
      from nps_fin_message m
     where decode(m.status, 'CLMS0040', 'CLMS0040', null) = 'CLMS0040'
       and m.is_dispute = com_api_const_pkg.FALSE;

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'l_estimated_count [#1]'
      , i_env_param1      => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    for r_fin_mes in (
        select m.id 
             , f.network_id
             , f.session_file_id
          from nps_fin_message m
             , nps_file f
         where decode(m.status, 'CLMS0040', 'CLMS0040', null) = 'CLMS0040'
           and m.is_dispute = com_api_const_pkg.FALSE
           and f.id         = m.file_id
    ) loop
        -- get network communication standard
        l_host_id :=
            net_api_network_pkg.get_default_host(
                i_network_id   => r_fin_mes.network_id
            );
        l_standard_id :=
            net_api_network_pkg.get_offline_standard(
                i_host_id => l_host_id
            );

        get_fin_message(i_id       => r_fin_mes.id
                      , o_fin_rec  => l_fin_rec);

        nps_api_fin_message_pkg.create_operation(
            i_fin_rec              => l_fin_rec
          , i_standard_id          => l_standard_id
          , i_status               => null
          , i_create_disp_case     => com_api_const_pkg.TRUE
          , i_incom_sess_file_id   => r_fin_mes.session_file_id
        );

        l_processed_count := l_processed_count + 1;

        if mod(l_processed_count, 100) = 0 then
            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => l_excepted_count
            );
        end if;
    end loop;

    reconciliation(
        i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_network_id        => i_network_id
      , i_is_reconcile_bnb  => i_is_reconcile_bnb
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text              => LOG_PREFIX || 'Finish'
    );

exception
    when others then
        rollback to savepoint sp_process_transactions;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;

        raise;

end process_transactions;

end nps_rcn_processing_pkg;
/
