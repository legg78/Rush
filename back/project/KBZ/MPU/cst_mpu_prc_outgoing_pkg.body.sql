create or replace package body cst_mpu_prc_outgoing_pkg as

BULK_LIMIT      constant integer := 1000;

function char_pad(i_value varchar2, i_length number) return varchar2 is
begin
    return rpad(nvl(i_value, ' '), i_length);
end;

function numb_pad(i_value number, i_length number) return varchar2 is
begin
    return lpad(nvl(i_value, 0), i_length, '0');
end;

procedure register_session_file (
    i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_network_id       in      com_api_type_pkg.t_tiny_id
  , i_host_inst_id     in      com_api_type_pkg.t_inst_id
  , o_session_file_id     out  com_api_type_pkg.t_long_id
) is
    l_params                  com_api_type_pkg.t_param_tab;
begin
    l_params.delete;
    rul_api_param_pkg.set_param (
        i_name     => 'INST_ID'
      , i_value    => to_char(i_inst_id)
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'NETWORK_ID'
      , i_value    => i_network_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'HOST_INST_ID'
      , i_value    => i_host_inst_id
      , io_params  => l_params
    );
    prc_api_file_pkg.open_file (
        o_sess_file_id  => o_session_file_id
      , i_file_type     => cst_mpu_api_const_pkg.FILE_TYPE_CLEARING_MPU
      , io_params       => l_params
    );
end;

procedure mark_fin_messages (
    i_id       in     com_api_type_pkg.t_number_tab
  , i_file_id  in     com_api_type_pkg.t_number_tab
  , i_rec_num  in     com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug (i_text => 'Mark financial messages start');

    forall i in 1 .. i_id.count
    update cst_mpu_fin_msg_vw m
       set file_id          = i_file_id(i)
         , m.message_number = i_rec_num(i)
         , status           = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
     where id               = i_id(i);

    trc_log_pkg.debug (i_text => 'Mark financial messages end');
end;

-- Writes header of file
procedure process_file_header(
    i_network_id       in     com_api_type_pkg.t_tiny_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_max_trans_date   in     date
  , i_session_file_id  in     com_api_type_pkg.t_long_id
  , o_file                out cst_mpu_api_type_pkg.t_mpu_file_rec
) is
    l_line                    com_api_type_pkg.t_text;
    l_sysdate                 date;
    l_iin                     com_api_type_pkg.t_region_code;
begin
    trc_log_pkg.debug (
        i_text         => 'cst_mpu_prc_outgoing_pkg.process_file_header start'
    );

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    o_file.id              := cup_file_seq.nextval;
    o_file.is_incoming     := com_api_const_pkg.FALSE;
    o_file.network_id      := i_network_id;
    o_file.trans_date      := trunc(l_sysdate);
    o_file.inst_id         := i_inst_id;
    o_file.file_number     := 0;
    o_file.file_type       := 'C';
    o_file.session_file_id := i_session_file_id;

    trc_log_pkg.debug (i_text => 'cst_mpu_prc_outgoing_pkg.process_file_header fill o_file - ok');

    l_line := l_line || '000'; -- Type of record   000=Header Record.
    l_line := l_line || rpad(l_iin, 11, ' '); --Indicate IIN of member institution that sends or receives the file. Right justified and filled up with leading spaces if the length is less than 11 characters.

    l_line := l_line || to_char(i_max_trans_date, 'yymmdd'); -- Last trans date in the file (YYMMDD)

    l_line := l_line || chr(13);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'cst_mpu_prc_outgoing_pkg.process_file_header end'
    );
end;

-- Writes trailer of file
procedure process_file_trailer(
    i_session_file_id  in     com_api_type_pkg.t_long_id
  , i_file             in     cst_mpu_api_type_pkg.t_mpu_file_rec
) is
    l_line                    com_api_type_pkg.t_text;
    l_sysdate    date := com_api_sttl_day_pkg.get_sysdate();
begin
    trc_log_pkg.debug (i_text => 'cst_mpu_prc_outgoing_pkg.process_file_trailer start, session_file_id='||i_session_file_id);
    l_line  := l_line || lpad('001', 3); --Record Type   001 = Trailer Record
    l_line  := l_line || lpad(to_char(i_file.trans_total + 2, com_api_const_pkg.XML_NUMBER_FORMAT), 9, ' ');  --Indicate the number of transaction records in the file, including the header and trailer records. Right justified, with leading spaces.
    l_line  := l_line || lpad(user, 20, ' '); --User code of the extraction system when performing file extraction. If the user code is less than 20, leading space characters shall be padded.
    l_line  := l_line || to_char(l_sysdate, 'hh24miss'); --File generation time is according to the time of file extraction system. Format: hhmmss for hours, minutes, and seconds
    l_line  := l_line || to_char(l_sysdate, 'ddmmyyyy'); --File generation date is according to the time of file extraction system. Format: ddMMyyyy for date, month and year
 
    l_line := l_line || chr(13);

    trc_log_pkg.debug('l_line='|| l_line);
    prc_api_file_pkg.put_line(
        i_raw_data      => l_line
      , i_sess_file_id  => i_session_file_id
    );

    trc_log_pkg.debug (i_text => 'cst_mpu_prc_outgoing_pkg.process_file_trailer end');
end;

procedure process_settlement(
    i_fin_rec          in     cst_mpu_api_type_pkg.t_mpu_fin_mes_rec
  , i_session_file_id  in     com_api_type_pkg.t_long_id
  , i_network_id       in     com_api_type_pkg.t_tiny_id
) is
   l_line                     com_api_type_pkg.t_text;
   l_curr_standard_version    com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (i_text => 'cst_mpu_prc_outgoing_pkg.process_presentment: start');
    l_curr_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id => nvl(i_network_id, cup_api_const_pkg.UPI_NETWORK_ID)
        );
    trc_log_pkg.debug(
        i_text         => 'cst_mpu_prc_outgoing_pkg.process_presentment standard version [#1]'
      , i_env_param1   => l_curr_standard_version
    );

    l_line := l_line || char_pad(i_fin_rec.record_type, 3);
    l_line := l_line || char_pad(i_fin_rec.card_number, 19);
    l_line := l_line || char_pad(i_fin_rec.proc_code, 6);
    l_line := l_line || numb_pad(i_fin_rec.trans_amount, 12);
    l_line := l_line || char_pad(i_fin_rec.trans_currency, 3);
    l_line := l_line || char_pad(to_char(i_fin_rec.transmit_date, 'mmddhh24miss'), 10);
    l_line := l_line || char_pad(i_fin_rec.sys_trace_num, 6);
    l_line := l_line || char_pad(i_fin_rec.auth_number, 6);
    l_line := l_line || char_pad(to_char(i_fin_rec.sttl_date, 'mmdd'), 4);
    l_line := l_line || char_pad(i_fin_rec.rrn, 12);
    l_line := l_line || char_pad(i_fin_rec.acq_inst_code, 11);
    l_line := l_line || char_pad(i_fin_rec.forw_inst_code, 11);
    l_line := l_line || char_pad(i_fin_rec.mcc, 4);
    l_line := l_line || char_pad(i_fin_rec.terminal_number, 8);
    l_line := l_line || char_pad(i_fin_rec.merchant_number, 15);
    l_line := l_line || char_pad(i_fin_rec.merchant_name, 40);
    l_line := l_line || char_pad(i_fin_rec.orig_trans_info, 23);
    l_line := l_line || char_pad(i_fin_rec.reason_code, 4);
    l_line := l_line || char_pad(i_fin_rec.trans_features, 1);
    l_line := l_line || char_pad(i_fin_rec.pos_cond_code, 2);
    l_line := l_line || char_pad(i_fin_rec.merchant_country, 3);
    l_line := l_line || char_pad(i_fin_rec.auth_type, 3);
    l_line := l_line || char_pad(' ', 5); -- reserved

----------------
    l_line := l_line || chr(13);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug (i_text => 'cst_mpu_prc_outgoing_pkg.process_presentment end');
end;

-- unload outgoing messages
procedure unload_clearing(
    i_network_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id  default null
) is
    l_estimated_count             com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id;

    l_inst_id                     com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id                com_api_type_pkg.t_inst_id_tab;
    l_network_id                  com_api_type_pkg.t_network_tab;
    l_host_id                     com_api_type_pkg.t_number_tab;
    l_standard_id                 com_api_type_pkg.t_number_tab;

    l_fin_cur                     cst_mpu_api_type_pkg.t_mpu_fin_cur;
    l_fin_message                 cst_mpu_api_type_pkg.t_mpu_fin_mes_tab;

    l_ok_mess_id                  com_api_type_pkg.t_number_tab;
    l_file_id                     com_api_type_pkg.t_number_tab;
    l_rec_num                     com_api_type_pkg.t_number_tab;

    l_header_writed               com_api_type_pkg.t_boolean;
    l_mpu_file                    cst_mpu_api_type_pkg.t_mpu_file_rec;
    l_charset                     com_api_type_pkg.t_attr_name;
    l_container_id                com_api_type_pkg.t_short_id;
    l_session_file_id             com_api_type_pkg.t_long_id;

    procedure register_ok_message (
        i_mess_id   in    com_api_type_pkg.t_long_id
      , i_file_id   in    com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        i               := l_ok_mess_id.count + 1;
        l_ok_mess_id(i) := i_mess_id;
        l_file_id(i)    := i_file_id;
        l_rec_num(i)    := prc_api_file_pkg.get_record_number(i_sess_file_id => l_mpu_file.session_file_id);
    end;

    procedure mark_ok_message is
    begin
        mark_fin_messages (
            i_id        => l_ok_mess_id
          , i_file_id   => l_file_id
          , i_rec_num   => l_rec_num
        );

        opr_api_clearing_pkg.mark_uploaded (
            i_id_tab  => l_ok_mess_id
        );

        l_ok_mess_id.delete;
        l_file_id.delete;
        l_rec_num.delete;
    end;

    procedure check_ok_message is
    begin
        if l_ok_mess_id.count >= BULK_LIMIT then
            mark_ok_message;
        end if;
    end;
begin
   prc_api_stat_pkg.log_start();

    -- fetch parameters
    select m.id host_id
         , m.inst_id host_inst_id
         , n.id network_id
         , r.inst_id
         , s.standard_id
      bulk collect into
           l_host_id
         , l_host_inst_id
         , l_network_id
         , l_inst_id
         , l_standard_id
      from net_network n
         , net_member m
         , net_interface i
         , net_member r
         , cmn_standard_object s
     where (n.id = i_network_id or i_network_id is null)
       and n.id             = m.network_id
       and n.inst_id        = m.inst_id
       and s.object_id      = m.id
       and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
       and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
       and (r.inst_id       = i_inst_id or i_inst_id is null )
       and r.id             = i.consumer_member_id
       and i.host_member_id = m.id;
    -- make estimated count
    for i in 1 .. l_host_id.count loop
        trc_log_pkg.debug(
            i_text => 'unload clearing: net=' || l_network_id(i) || ' inst=' || l_inst_id(i)
                || ' host inst id=' || l_host_inst_id(i)
        );
        l_record_count := 
            cst_mpu_api_fin_message_pkg.estimate_messages_for_upload(
                i_network_id => l_network_id(i)
              , i_inst_id => l_inst_id(i)
            );

        l_estimated_count := l_estimated_count + l_record_count;
    end loop;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        -- get encoding for output file
        l_container_id := prc_api_session_pkg.get_container_id;

        begin
            select a.characterset
              into l_charset
              from prc_file_attribute a
                 , prc_file f
             where a.container_id = l_container_id
               and f.id           = a.file_id
               and f.file_type    = cst_mpu_api_const_pkg.FILE_TYPE_CLEARING_MPU
               and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_OUT;

        exception
            when no_data_found then
                l_charset := 'UTF8';
        end;

        trc_log_pkg.debug (
            i_text  => 'l_charset = ' || l_charset
        );

        for i in 1 .. l_host_id.count loop
            -- init
            l_header_writed := com_api_const_pkg.FALSE;
            l_mpu_file.trans_total := 0;

            cst_mpu_api_fin_message_pkg.enum_messages_for_upload(
                o_fin_cur    => l_fin_cur
              , i_network_id => l_network_id(i)
              , i_inst_id    => l_inst_id(i)
            );

            loop
                fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;

                for j in 1 .. l_fin_message.count loop
                    -- if first record create new file and put file header
                    if l_header_writed = com_api_const_pkg.FALSE then
                        register_session_file(
                            i_inst_id         => l_inst_id(i)
                          , i_network_id      => l_network_id(i)
                          , i_host_inst_id    => l_host_inst_id(i)
                          , o_session_file_id => l_session_file_id
                        );

                        l_mpu_file.session_file_id := l_session_file_id;

                        process_file_header(
                            i_session_file_id  => l_session_file_id
                          , i_network_id       => l_network_id(i)
                          , i_inst_id          => l_inst_id(i)
                          , i_max_trans_date   => l_fin_message(1).max_trans_date
                          , o_file             => l_mpu_file
                        );
                       
                        l_mpu_file.trans_total := 0;
                        l_header_writed := com_api_const_pkg.TRUE;
                    end if;

                    -- process presentment
                    if l_fin_message(j).record_type in (
                        cst_mpu_api_const_pkg.RECORD_TYPE_SETTLEMENT
                      , cst_mpu_api_const_pkg.RECORD_TYPE_SETTL_REFUND
                    ) then
                        -- process presentment
                        l_mpu_file.trans_total := l_mpu_file.trans_total + 1;

                        process_settlement(
                            i_fin_rec          => l_fin_message(j)
                          , i_session_file_id  => l_session_file_id
                          , i_network_id       => l_network_id(i)
                        );
                    end if;

                    register_ok_message (
                        i_mess_id   => l_fin_message(j).id
                      , i_file_id   => l_mpu_file.id
                    );

                    check_ok_message;
                end loop;

                l_processed_count := l_processed_count + l_fin_message.count;

                prc_api_stat_pkg.log_current (
                    i_current_count   => l_processed_count
                  , i_excepted_count  => 0
                );

                exit when l_fin_cur%notfound;
            end loop;
            close l_fin_cur;

            mark_ok_message;

            if l_header_writed = com_api_const_pkg.TRUE then
                --process trailer
                l_mpu_file.trans_total := l_mpu_file.trans_total + 1;
                process_file_trailer(
                    i_session_file_id  => l_session_file_id
                  , i_file             => l_mpu_file
                );

                prc_api_file_pkg.close_file (
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );

            end if;
        end loop;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total  => l_processed_count
    );
    
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_mpu_file.session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_mpu_file.session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end unload_clearing;

end;
/
