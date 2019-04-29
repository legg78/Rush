create or replace package body cup_prc_outgoing_pkg as

BULK_LIMIT      constant integer := 1000;

function char_pad(i_value varchar2, i_length number) return varchar2 is
begin
    return rpad(nvl(i_value, ' '), i_length);
end;

function numb_pad(i_value number, i_length number) return varchar2 is
begin
    return lpad(nvl(i_value, 0), i_length, '0');
end;

-- Writes header of file
procedure process_file_header(
    i_network_id             in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_test_mode            in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , i_host_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_charset              in com_api_type_pkg.t_attr_name
    , o_file                out cup_api_type_pkg.t_cup_file_rec
) is
    l_line                      com_api_type_pkg.t_text;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_sysdate                   date;
begin

    trc_log_pkg.debug (
        i_text         => 'cup_prc_outgoing_pkg.process_file_header start'
    );

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    o_file.id              := cup_file_seq.nextval;
    o_file.is_incoming     := com_api_const_pkg.FALSE;
    o_file.is_rejected     := com_api_const_pkg.FALSE;
    o_file.network_id      := i_network_id;
    o_file.trans_date      := trunc(l_sysdate);
    o_file.inst_id         := i_inst_id;
    o_file.action_code     := i_test_mode;
    o_file.file_number     := 0;
    o_file.pack_no         := substr(i_session_file_id, -9);
    o_file.version         := '16.2';
    o_file.encoding        := nvl(i_charset, 'UTF8');
    o_file.file_type       := 'CS';
    o_file.session_file_id := i_session_file_id;

    trc_log_pkg.debug (
        i_text         => 'cup_prc_outgoing_pkg.process_file_header fill o_file - ok'
    );

    o_file.inst_name := cmn_api_standard_pkg.get_varchar_value(
         i_inst_id       => i_inst_id
       , i_standard_id   => i_standard_id
       , i_object_id     => i_host_id
       , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
       , i_param_name    => cup_api_const_pkg.CUP_ACQUIRER_NAME
       , i_param_tab     => l_param_tab
    );

    if o_file.inst_name is null then
        com_api_error_pkg.raise_error(
            i_error       => 'CUP_INSTITUTION_NOT_FOUND'
          , i_env_param1  => o_file.inst_id
        );
    end if;

    l_line := l_line || '000';                                        -- Transaction Code for file header
    l_line := l_line || '8000';                                       -- Block bitmap
    l_line := l_line || char_pad(o_file.inst_name, 11);               -- IIN
    l_line := l_line || char_pad(to_char(l_sysdate, 'yyyymmdd'), 8);  -- Batch Date
    l_line := l_line || char_pad(' ', 8);                             -- CUPS reserved
    if i_test_mode = com_api_const_pkg.TRUE then
        l_line := l_line || 'TEST';                                   -- Version Tag for test mode
    else
        l_line := l_line || 'PROD';                                   -- Version Tag for production mode
    end if;
    l_line := l_line || '00000001';                                   -- Version Number
    l_line := l_line || chr(13);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'cup_prc_outgoing_pkg.process_file_header end'
    );
end;

-- Writes trailer of file
procedure process_file_trailer(
    i_rec_number             in     com_api_type_pkg.t_short_id
    , i_session_file_id      in     com_api_type_pkg.t_long_id
    , io_file                in out cup_api_type_pkg.t_cup_file_rec
) is
    l_line                   com_api_type_pkg.t_text;

begin

    trc_log_pkg.debug (
        i_text         => 'cup_prc_outgoing_pkg.process_file_trailer start'
    );

    l_line := l_line || '001';                          -- Transaction Code for file trailer
    l_line := l_line || '8000';                         -- Block bitmap
    l_line := l_line || numb_pad(i_rec_number, 10);     -- Total Records
    l_line := l_line || char_pad(' ', 16);              -- MAK
    l_line := l_line || char_pad(' ', 16);              -- MAC
    l_line := l_line || chr(13);

    prc_api_file_pkg.put_line(
        i_raw_data      => l_line
      , i_sess_file_id  => i_session_file_id
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
        io_file.id
        , io_file.is_incoming
        , io_file.is_rejected
        , io_file.network_id
        , io_file.trans_date
        , io_file.inst_id
        , io_file.inst_name
        , io_file.action_code
        , io_file.file_number
        , io_file.pack_no
        , io_file.version
        , io_file.crc
        , io_file.encoding
        , io_file.file_type
        , io_file.session_file_id
    );

    trc_log_pkg.debug (
        i_text         => 'cup_prc_outgoing_pkg.process_file_trailer end'
    );
end;

procedure mark_fin_messages (
    i_id                    in com_api_type_pkg.t_number_tab
    , i_file_id             in com_api_type_pkg.t_number_tab
    , i_rec_num             in com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug (
        i_text         => 'Mark financial messages start'
    );

    forall i in 1 .. i_id.count
        update cup_fin_message_vw
           set file_id = i_file_id(i)
             , msg_number = i_rec_num(i)
             , status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
         where id = i_id(i);

    trc_log_pkg.debug (
        i_text         => 'Mark financial messages end'
    );
end;

procedure register_session_file (
    i_inst_id               in  com_api_type_pkg.t_inst_id
    , i_network_id          in  com_api_type_pkg.t_tiny_id
    , i_host_inst_id        in  com_api_type_pkg.t_inst_id
    , o_session_file_id     out com_api_type_pkg.t_long_id
) is
    l_params                  com_api_type_pkg.t_param_tab;
begin
    l_params.delete;
    rul_api_param_pkg.set_param (
        i_name       => 'INST_ID'
        , i_value    => to_char(i_inst_id)
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'NETWORK_ID'
        , i_value    => i_network_id
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'HOST_INST_ID'
        , i_value    => i_host_inst_id
        , io_params  => l_params
    );
    prc_api_file_pkg.open_file (
        o_sess_file_id  => o_session_file_id
        , i_file_type   => cup_api_const_pkg.FILE_TYPE_CLEARING_CUP
        , io_params     => l_params
    );
end;

-- Converts authorization from DB to outgoing clearing file line
procedure process_presentment(
    i_fin_rec                in     cup_api_type_pkg.t_cup_fin_mes_rec
  , io_file                  in out cup_api_type_pkg.t_cup_file_rec
  , i_rec_number             in     com_api_type_pkg.t_short_id
  , i_session_file_id        in     com_api_type_pkg.t_long_id
  , i_acquiring_iin          in     com_api_type_pkg.t_name
  , i_forwarding_iin         in     com_api_type_pkg.t_name
  , i_receiving_iin          in     com_api_type_pkg.t_name
  , i_network_id             in     com_api_type_pkg.t_tiny_id
) is
    l_line                   com_api_type_pkg.t_text;
    l_bitmap                 com_api_type_pkg.t_name;
    l_num                    com_api_type_pkg.t_long_id := power(2, 15) + power(2, 14);
    l_curr_standard_version  com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text         => 'cup_prc_outgoing_pkg.process_presentment: start'
    );

    l_curr_standard_version :=
        cmn_api_standard_pkg.get_current_version(
            i_network_id => nvl(i_network_id, cup_api_const_pkg.UPI_NETWORK_ID)
        );
    trc_log_pkg.debug(
        i_text         => 'cup_prc_outgoing_pkg.process_presentment standard version [#1]'
      , i_env_param1   => l_curr_standard_version
    );

    -- block 0
    l_line := l_line || numb_pad(i_fin_rec.trans_code, 3);

    if i_fin_rec.appl_crypt is not null then
        l_num := l_num + power(2, 13);
    end if;

    if l_curr_standard_version >= cup_api_const_pkg.STANDARD_VERSION_ID_19Q2 then
        if i_fin_rec.payment_facilitator_id is not null then
            l_num := l_num + power(2, 12);
        end if;
    end if;

    l_bitmap := to_char(l_num, 'XXXXXXXXXXXXXXXX');

    trc_log_pkg.debug(
        i_text       => 'cup_prc_outgoing_pkg.process_presentment: l_bitmap [#1]'
      , i_env_param1 => l_bitmap
    );
    
    l_line := l_line || l_bitmap;
    --
    l_line := l_line || char_pad(i_fin_rec.card_number      , 19);
    l_line := l_line || numb_pad(i_fin_rec.trans_amount     , 12);
    l_line := l_line || char_pad(i_fin_rec.trans_currency   ,  3);
    l_line := l_line || char_pad(to_char(i_fin_rec.transmission_date_time,  'mmddhh24miss'), 10);
    l_line := l_line || numb_pad(i_fin_rec.sys_trace_num    ,  6);
    l_line := l_line || char_pad(i_fin_rec.auth_resp_code   ,  6);
    l_line := l_line || char_pad(i_fin_rec.trans_date       ,  4);
    l_line := l_line || char_pad(i_fin_rec.rrn              , 12);
    l_line := l_line || char_pad(i_acquiring_iin            , 11);  -- i_fin_rec.acquirer_iin
    l_line := l_line || char_pad(i_forwarding_iin           , 11);  -- i_fin_rec.forwarding_iin
    l_line := l_line || numb_pad(i_fin_rec.mcc              ,  4);
    l_line := l_line || char_pad(i_fin_rec.terminal_number  ,  8);
    l_line := l_line || rpad(trim(i_fin_rec.merchant_number), 15, ' ');
    l_line := l_line || char_pad(i_fin_rec.merchant_name    , 40);

    -- original transaction info
    if i_fin_rec.trans_code != cup_api_const_pkg.TC_ONLINE_REFUND
       or i_fin_rec.original_id is null
    then
        l_line := l_line || numb_pad('0', 23);
    else
        l_line := l_line || numb_pad(i_fin_rec.orig_trans_code   , 3);
        l_line := l_line || char_pad(to_char(i_fin_rec.orig_transmission_date_time, 'mmddhh24miss'), 10);
        l_line := l_line || numb_pad(i_fin_rec.orig_sys_trace_num, 6);
        l_line := l_line || char_pad(to_char(i_fin_rec.orig_trans_date, 'mmdd'), 4);
    end if;

    --
    l_line := l_line || '0000';                  -- Message reason code: it is constant.
    l_line := l_line || '1';                     -- dual message
    l_line := l_line || '000000000';             -- CUPS serial Number: it is constant.
    --
    l_line := l_line || char_pad(i_receiving_iin           , 11);  -- i_fin_rec.acquirer_iin
    l_line := l_line || char_pad(' ', 11);                         -- i_fin_rec.forwarding_iin
    l_line := l_line || '0';                     -- Identifier of CUPS Notice. To be filled by CUPS.
    l_line := l_line || numb_pad(i_fin_rec.trans_init_channel, 2);
    l_line := l_line || ' ';                     -- Identifier of Transaction Features. space = other transaction.
    l_line := l_line || char_pad(' ', 8);        -- Reserved for CUPS
    l_line := l_line || char_pad(' ', 3);        -- Installment payment terms and Stand-in authorization identifier
    l_line := l_line || numb_pad(i_fin_rec.pos_cond_code    , 2);
    l_line := l_line || numb_pad(i_fin_rec.merchant_country , 3);
    l_line := l_line || char_pad(' ', 5);        -- Other information
    l_line := l_line || '00';                    -- Code of pricing scheme
    l_line := l_line || char_pad(' ', 10);       -- Other information
    l_line := l_line || char_pad(i_fin_rec.b2b_business_type, 2); -- B2B Business type
    l_line := l_line || char_pad(i_fin_rec.b2b_payment_medium, 1); -- B2B payment medium, 1 char
    l_line := l_line || char_pad(' ', 2);        -- Reserved

    -- block 1
    l_line := l_line || numb_pad(i_fin_rec.pos_entry_mode   , 3);
    l_line := l_line || char_pad(' ', 1);
    l_line := l_line || char_pad(' ', 2);
    l_line := l_line || '000000000000';
    l_line := l_line || char_pad(' ', 3);
    l_line := l_line || '00000000';
    l_line := l_line || '000000000000';
    l_line := l_line || char_pad(' ', 3);
    l_line := l_line || '00000000';
    l_line := l_line || 'D00000000000';
    l_line := l_line || char_pad(' ', 3);
    l_line := l_line || '00000000';
    l_line := l_line || char_pad(' ', 3);
    l_line := l_line || char_pad(' ', 1);
    l_line := l_line || char_pad(' ', 12);
    l_line := l_line || char_pad(nvl(i_fin_rec.qrc_voucher_number, ' '), 20);
    l_line := l_line || char_pad(' ', 7);

    if i_fin_rec.appl_crypt is not null then
        -- block 2
        l_line := l_line || char_pad(i_fin_rec.appl_crypt            , 16);
        l_line := l_line || numb_pad(i_fin_rec.pos_entry_mode        ,  3);
        l_line := l_line || numb_pad(i_fin_rec.card_serial_num       ,  3);
        l_line := l_line || char_pad(i_fin_rec.terminal_entry_capab  ,  1);
        l_line := l_line || char_pad(i_fin_rec.ic_card_cond_code     ,  1);
        l_line := l_line || char_pad(i_fin_rec.terminal_capab        ,  6);
        l_line := l_line || char_pad(i_fin_rec.terminal_verif_result , 10);
        l_line := l_line || char_pad(i_fin_rec.unpred_num            ,  8);
        l_line := l_line || char_pad(i_fin_rec.interface_serial      ,  8);
        l_line := l_line || char_pad(i_fin_rec.iss_bank_app_data     , 64);
        l_line := l_line || char_pad(i_fin_rec.trans_counter         ,  4);
        l_line := l_line || char_pad(i_fin_rec.appl_charact          ,  4);
        l_line := l_line || char_pad(to_char(i_fin_rec.terminal_auth_date, 'yymmdd'),  6);
        l_line := l_line || char_pad(i_fin_rec.terminal_country      ,  3);
        l_line := l_line || char_pad(i_fin_rec.script_result_of_card_issuer, 42);  -- tag DF31 in spec, tag 9F5B in code - it's mismatch (!!!)
        l_line := l_line || char_pad(i_fin_rec.trans_resp_code       ,  2);
        l_line := l_line || numb_pad(i_fin_rec.trans_category        ,  2);
        l_line := l_line || numb_pad(i_fin_rec.auth_amount           , 12);
        l_line := l_line || numb_pad(i_fin_rec.auth_currency         ,  3);
        l_line := l_line || char_pad(i_fin_rec.cipher_text_inf_data  ,  2);
        l_line := l_line || numb_pad(i_fin_rec.other_amount          , 12);
        l_line := l_line || char_pad(i_fin_rec.auth_method           ,  6);
        l_line := l_line || char_pad(i_fin_rec.terminal_category     ,  2);
        l_line := l_line || char_pad(i_fin_rec.dedic_doc_name        , 32);
        l_line := l_line || char_pad(i_fin_rec.app_version_no        ,  4);
        l_line := l_line || char_pad(i_fin_rec.trans_serial_counter  ,  8);
        l_line := l_line || char_pad(' ', 30);      -- Reserved for use
    end if;

    if l_curr_standard_version >= cup_api_const_pkg.STANDARD_VERSION_ID_19Q2 then
        -- block 3
        if i_fin_rec.payment_facilitator_id is not null then
            l_line := l_line || char_pad(' ', 19);
            l_line := l_line || char_pad(' ', 8);
            l_line := l_line || char_pad(i_fin_rec.payment_facilitator_id, 8);
            l_line := l_line || char_pad(' ', 265);     -- Reserved for use
        end if;
    end if;

    l_line := l_line || chr(13);

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'cup_prc_outgoing_pkg.process_presentment end'
    );
end;

procedure unload_clearing(
    i_network_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id  default null
  , i_host_inst_id         in     com_api_type_pkg.t_inst_id  default null
  , i_action_code          in     varchar2                    default null
  , i_include_affiliate    in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) is
    l_estimated_count             com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id;

    l_inst_id                     com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id                com_api_type_pkg.t_inst_id_tab;
    l_network_id                  com_api_type_pkg.t_network_tab;
    l_host_id                     com_api_type_pkg.t_number_tab;
    l_standard_id                 com_api_type_pkg.t_number_tab;

    l_fin_cur                     cup_api_type_pkg.t_cup_fin_cur;
    l_fin_message                 cup_api_type_pkg.t_cup_fin_mes_tab;

    l_ok_mess_id                  com_api_type_pkg.t_number_tab;
    l_file_id                     com_api_type_pkg.t_number_tab;
    l_rec_num                     com_api_type_pkg.t_number_tab;

    l_session_file_id             com_api_type_pkg.t_long_id;
    l_test_mode                   com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;

    l_header_writed               com_api_type_pkg.t_boolean;
    l_file                        cup_api_type_pkg.t_cup_file_rec;
    l_rec_number                  com_api_type_pkg.t_short_id;
    l_charset                     com_api_type_pkg.t_attr_name;
    l_container_id                com_api_type_pkg.t_short_id;

    procedure register_ok_message (
        i_mess_id               com_api_type_pkg.t_long_id
        , i_file_id             com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        i := l_ok_mess_id.count + 1;
        l_ok_mess_id(i) := i_mess_id;
        l_file_id(i) := i_file_id;
        l_rec_num(i) := prc_api_file_pkg.get_record_number(i_sess_file_id => l_session_file_id);
    end;

    procedure mark_ok_message is
    begin
        mark_fin_messages (
            i_id          => l_ok_mess_id
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

    if i_action_code = com_api_const_pkg.TRUE then
        l_test_mode := com_api_const_pkg.TRUE;
    end if;

    -- fetch parameters
    select
        m.id host_id
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
    from
        net_network n
        , net_member m
        , net_interface i
        , net_member r
        , cmn_standard_object s
    where
        (n.id = i_network_id or i_network_id is null)
        and n.id = m.network_id
        and n.inst_id = m.inst_id
        and (m.inst_id = i_host_inst_id or i_host_inst_id is null)
        and s.object_id = m.id
        and s.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
        and s.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
        and (r.inst_id = i_inst_id or i_inst_id is null
             or (i_include_affiliate = com_api_const_pkg.TRUE
                 and i_inst_id is not null
                 and r.inst_id in (select m.inst_id
                                     from net_interface i
                                        , net_member m
                                    where i.msp_member_id in (select id
                                                                from net_member
                                                               where network_id = i_network_id
                                                                 and inst_id    = i_inst_id
                                                             )
                                      and m.id = i.consumer_member_id
                                   )
                )
            )
        and r.id = i.consumer_member_id
        and i.host_member_id = m.id;


    -- make estimated count
    for i in 1 .. l_host_id.count loop
        trc_log_pkg.debug(
            i_text => 'unload clearing: net=' || l_network_id(i) || ' inst=' || l_inst_id(i)
                || ' host inst id=' || l_host_inst_id(i)
        );
        l_record_count := cup_api_fin_message_pkg.estimate_messages_for_upload (
            i_network_id        => l_network_id(i)
          , i_inst_id           => l_inst_id(i)
          , i_host_inst_id      => l_host_inst_id(i)
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
               and f.file_type    = cup_api_const_pkg.FILE_TYPE_CLEARING_CUP
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
            l_rec_number    := 0;

            cup_api_fin_message_pkg.enum_messages_for_upload (
                o_fin_cur         => l_fin_cur
                , i_network_id    => l_network_id(i)
                , i_inst_id       => l_inst_id(i)
                , i_host_inst_id  => l_host_inst_id(i)
            );
            loop
                fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;

                for j in 1 .. l_fin_message.count loop
                    -- if first record create new file and put file header
                    if l_header_writed = com_api_const_pkg.FALSE then
                        register_session_file (
                            i_inst_id           => l_inst_id(i)
                            , i_network_id      => l_network_id(i)
                            , i_host_inst_id    => l_host_inst_id(i)
                            , o_session_file_id => l_session_file_id
                        );

                        process_file_header (
                            i_network_id         => l_network_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_test_mode        => l_test_mode
                            , i_session_file_id  => l_session_file_id
                            , i_host_id          => l_host_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_charset          => l_charset
                            , o_file             => l_file
                        );

                        l_rec_number := 1;
                        l_header_writed := com_api_const_pkg.TRUE;
                    end if;

                    -- process presentment
                    if l_fin_message(j).trans_code in (cup_api_const_pkg.TC_PRESENTMENT
                                                     , cup_api_const_pkg.TC_ONLINE_REFUND
                                                     , cup_api_const_pkg.TC_CASH_WITHDRAWAL)
                    then
                        -- process presentment
                        l_rec_number := l_rec_number + 1;

                        process_presentment(
                            i_fin_rec                => l_fin_message(j)
                            , io_file                => l_file
                            , i_rec_number           => l_rec_number
                            , i_session_file_id      => l_session_file_id
                            , i_acquiring_iin        => l_file.inst_name
                            , i_forwarding_iin       => l_file.inst_name
                            , i_receiving_iin        => l_file.inst_name
                          , i_network_id             => l_network_id(i)
                        );
                    end if;

                    register_ok_message (
                        i_mess_id     => l_fin_message(j).id
                        , i_file_id   => l_file.id
                    );

                    check_ok_message;
                end loop;

                l_processed_count := l_processed_count + l_fin_message.count;

                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                    , i_excepted_count  => 0
                );

                exit when l_fin_cur%notfound;
            end loop;
            close l_fin_cur;

            mark_ok_message;

            if l_header_writed = com_api_const_pkg.TRUE then
                --process trailer
                l_rec_number := l_rec_number + 1;
                process_file_trailer(
                    i_rec_number         => l_rec_number
                    , i_session_file_id  => l_session_file_id
                    , io_file            => l_file
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

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
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
