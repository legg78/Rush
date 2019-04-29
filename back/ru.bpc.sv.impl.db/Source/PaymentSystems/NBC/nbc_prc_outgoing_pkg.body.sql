create or replace package body nbc_prc_outgoing_pkg as

BULK_LIMIT      constant integer := 1000;
C_CRLF          constant  com_api_type_pkg.t_name := chr(13)||chr(10);

procedure process_file_header(
    i_network_id             in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , i_host_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_participant_type     in com_api_type_pkg.t_dict_value
    , i_file_number          in com_api_type_pkg.t_inst_id
    , o_file                 out nbc_api_type_pkg.t_nbc_file_rec
) is
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug (
        i_text         => 'nbc_prc_outgoing_pkg.process_file_header start'
    );
    o_file.id               := nbc_file_seq.nextval;
    if i_participant_type = 'DSP' then
        o_file.file_type    := 'DF';
    else
        o_file.file_type    := 'RF';
    end if;    
    o_file.is_incoming      := com_api_type_pkg.FALSE;
    o_file.inst_id          := i_inst_id;
    o_file.network_id       := i_network_id;
    o_file.sttl_date        := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.proc_date        := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.participant_type := i_participant_type;
    o_file.file_number      := i_file_number;
    o_file.session_file_id  := i_session_file_id;
    
    o_file.bin_number := cmn_api_standard_pkg.get_varchar_value(
         i_inst_id       => i_inst_id
       , i_standard_id   => i_standard_id
       , i_object_id     => i_host_id
       , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
       , i_param_name    => nbc_api_const_pkg.NBC_BANK_CODE
       , i_param_tab     => l_param_tab
    );    
    
    l_line := nbc_api_const_pkg.RECORD_TYPE_HEADER;
    l_line := l_line || lpad(nvl(o_file.bin_number, ' '), 7, ' '); 
    l_line := l_line || to_char(o_file.proc_date, 'yymmdd');
    
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'nbc_prc_outgoing_pkg.process_file_header end'
    );
end;

procedure process_file_trailer(
    i_rec_number             in     com_api_type_pkg.t_short_id
    , i_session_file_id      in     com_api_type_pkg.t_long_id
    , io_file                in out nbc_api_type_pkg.t_nbc_file_rec
    , i_last_line            in     com_api_type_pkg.t_text
) is
    l_line                   com_api_type_pkg.t_text;
    l_md5                    com_api_type_pkg.t_account_number := null;

begin
    trc_log_pkg.debug (
        i_text         => 'nbc_prc_outgoing_pkg.process_file_trailer start , last line [' || i_last_line || ']'
    );
    
    io_file.records_total  := i_rec_number - 2;    

    l_md5 := dbms_crypto.hash(
                 src => utl_i18n.string_to_raw(i_last_line, 'AL32UTF8')
               , typ => 2
             );
             
    trc_log_pkg.debug (
        i_text         => 'md5 [' || l_md5 || ']'
    );
           
    l_line := nbc_api_const_pkg.RECORD_TYPE_TRAILER;
    l_line := l_line || lpad(nvl(to_char(io_file.records_total), '0'), 9, '0'); 
    l_line := l_line || l_md5;       
    
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    insert into nbc_file (
        id
      , file_type
      , is_incoming
      , inst_id    
      , network_id 
      , bin_number 
      , sttl_date  
      , proc_date  
      , file_number
      , participant_type
      , session_file_id 
      , records_total      
      , md5
    )
    values(
        io_file.id
      , io_file.file_type
      , io_file.is_incoming
      , io_file.inst_id    
      , io_file.network_id 
      , io_file.bin_number 
      , io_file.sttl_date  
      , io_file.proc_date  
      , io_file.file_number
      , io_file.participant_type
      , io_file.session_file_id 
      , io_file.records_total
      , io_file.md5            
    );
    
    trc_log_pkg.debug (
        i_text         => 'nbc_prc_outgoing_pkg.process_file_trailer end'
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
    
    forall i in 1..i_id.count
        update
            nbc_fin_message--_vw
        set
            file_id         = i_file_id(i)
            , record_number = i_rec_num(i)
            , status        = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
        where
            id = i_id(i);
            
    trc_log_pkg.debug (
        i_text         => 'Mark financial messages end'
    );
end;

procedure register_session_file (
    i_inst_id               in  com_api_type_pkg.t_inst_id
    , i_network_id          in  com_api_type_pkg.t_tiny_id
    , i_host_inst_id        in  com_api_type_pkg.t_inst_id
    , i_acq_bin             in  com_api_type_pkg.t_name
    , i_participant_type    in  com_api_type_pkg.t_dict_value 
    , o_session_file_id     out com_api_type_pkg.t_long_id
    , o_file_number         out com_api_type_pkg.t_inst_id
) is
    l_params                  com_api_type_pkg.t_param_tab;
    l_file_number             com_api_type_pkg.t_tiny_id;  
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
    rul_api_param_pkg.set_param (
        i_name       => 'ACQ_BIN'
        , i_value    => i_acq_bin
        , io_params  => l_params
    );
    
    select nvl(max(file_number), 0) + 1 
      into l_file_number
      from nbc_file 
     where trunc(proc_date) = trunc(get_sysdate)
       and participant_type = substr(i_participant_type, -3)
       and is_incoming      = com_api_type_pkg.FALSE;
        
    rul_api_param_pkg.set_param (
        i_name       => 'FILE_NUMBER'
        , i_value    => l_file_number
        , io_params  => l_params
    );
    o_file_number := l_file_number;

    prc_api_file_pkg.open_file (
        o_sess_file_id  => o_session_file_id
        , i_file_type   => i_participant_type
        , io_params     => l_params
    );   
end;

procedure process_presentment(
    i_fin_rec                in     nbc_api_type_pkg.t_nbc_fin_mes_rec    
    , io_file                in out nbc_api_type_pkg.t_nbc_file_rec
    , i_session_file_id      in     com_api_type_pkg.t_long_id
    , o_line                    out com_api_type_pkg.t_text
) is
    l_line                   com_api_type_pkg.t_text;
    l_oper_currency_exponent com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text         => 'nbc_prc_outgoing_pkg.process_presentment start'
    );   
        
    l_line := l_line || lpad(nvl(i_fin_rec.record_type,         ' '),  4, ' ');
    l_line := l_line || lpad(nvl(i_fin_rec.card_number,         '0'), 19, '0');     
    l_line := l_line || lpad(nvl(i_fin_rec.proc_code,           ' '),  6, ' ');

    -- if currency exponent equal to zero then append two zeros in accordance with NBC rules
    l_oper_currency_exponent := com_api_currency_pkg.get_currency_exponent(i_fin_rec.trans_currency);
    if l_oper_currency_exponent = 0 then
        l_line := l_line || lpad(nvl(i_fin_rec.trans_amount, 0), 10, '0') || '00';
    else
        l_line := l_line || lpad(nvl(i_fin_rec.trans_amount, 0), 12, '0');
    end if;

    l_line := l_line || lpad(nvl(i_fin_rec.sttl_amount,         '0'), 12, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.crdh_bill_amount,    '0'), 12, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.crdh_bill_fee,       '0'),  8, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.settl_rate,          '0'),  8, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.crdh_bill_rate,      '0'),  8, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.system_trace_number, '0'),  6, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.local_trans_time,    '0'),  6, '0');
    l_line := l_line || lpad(nvl(to_char(i_fin_rec.local_trans_date, 'mmdd'), ' '), 4, ' ');
    l_line := l_line || lpad(nvl(to_char(i_fin_rec.settlement_date,  'mmdd'), ' '), 4, ' ');
    l_line := l_line || lpad(nvl(i_fin_rec.merchant_type,       '0'),  4, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.trans_fee_amount,    '0'),  8, '0');
    
    l_line := l_line || lpad(nvl(i_fin_rec.acq_inst_code,       ' '),  7, ' ');
    l_line := l_line || lpad(nvl(i_fin_rec.iss_inst_code,       ' '),  7, ' ');
    l_line := l_line || lpad(nvl(i_fin_rec.bnb_inst_code,       ' '),  7, ' ');

    l_line := l_line || lpad(nvl(i_fin_rec.rrn,                 '0'), 12, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.auth_number,         '0'),  6, '0');
    
    if io_file.participant_type = 'DSP' then
    
        l_line := l_line || lpad(nvl(i_fin_rec.nbc_resp_code,   ' '), 2, ' ');
        l_line := l_line || lpad(nvl(i_fin_rec.acq_resp_code,   ' '), 2, ' ');
        l_line := l_line || lpad(nvl(i_fin_rec.iss_resp_code,   ' '), 2, ' ');
        l_line := l_line || lpad(nvl(i_fin_rec.bnb_resp_code,   ' '), 2, ' ');
    else 
        l_line := l_line || lpad(nvl(i_fin_rec.resp_code,       ' '), 2, ' ');
    end if;
    
    l_line := l_line || lpad(nvl(i_fin_rec.terminal_id,        '0'),  8, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.trans_currency,     '0'),  3, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.settl_currency,     '0'),  3, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.crdh_bill_currency, '0'),  3, '0');
    
    l_line := l_line || lpad(nvl(i_fin_rec.from_account_id,    '0'), 28, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.to_account_id,      '0'), 28, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.nbc_fee,            '0'),  8, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.acq_fee,            '0'),  8, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.iss_fee,            '0'),  8, '0');
    l_line := l_line || lpad(nvl(i_fin_rec.bnb_fee,            '0'),  8, '0');

    l_line := l_line || lpad(nvl(i_fin_rec.mti,                ' '),  4, ' ');
    
    if io_file.participant_type = 'DSP' then
    
        l_line := l_line || lpad(nvl(i_fin_rec.dispute_trans_result, ' '), 2, ' ');
    end if;
        
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        o_line := l_line;      -- set up 'last' record
    end if;    
    
    trc_log_pkg.debug (
        i_text         => 'nbc_prc_outgoing_pkg.process_presentment end'
    );
    
end;

procedure process_rf (
    i_network_id             in com_api_type_pkg.t_tiny_id default null
    , i_inst_id              in com_api_type_pkg.t_inst_id default null
)is    
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_record_count            com_api_type_pkg.t_long_id;

    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id            com_api_type_pkg.t_inst_id_tab;
    l_network_id              com_api_type_pkg.t_network_tab;
    l_host_id                 com_api_type_pkg.t_number_tab;
    l_standard_id             com_api_type_pkg.t_number_tab;

    l_fin_cur                 nbc_api_type_pkg.t_nbc_fin_cur;
    l_fin_message             nbc_api_type_pkg.t_nbc_fin_mes_tab;

    l_ok_mess_id              com_api_type_pkg.t_number_tab;
    l_file_id                 com_api_type_pkg.t_number_tab;
    l_rec_num                 com_api_type_pkg.t_number_tab;

    l_session_file_id         com_api_type_pkg.t_long_id;

    l_header_writed           com_api_type_pkg.t_boolean;
    l_file                    nbc_api_type_pkg.t_nbc_file_rec;
    l_rec_number              com_api_type_pkg.t_short_id;
    
    l_participant_tab         com_api_type_pkg.t_name_tab;
    l_sf_file                 clob;
    l_acq_bin                 com_api_type_pkg.t_name;
    l_param_tab               com_api_type_pkg.t_param_tab;
    l_file_number             pls_integer;  

    l_last_line               com_api_type_pkg.t_text;

    type    t_intersect_tab   is table of com_api_type_pkg.t_boolean index by varchar2(16);
    l_ok_intersect_id         t_intersect_tab;

    procedure register_ok_message (
        i_mess_id               com_api_type_pkg.t_long_id
        , i_file_id             com_api_type_pkg.t_long_id
        , i_add_party_type      com_api_type_pkg.t_dict_value
    ) is
        i                       binary_integer;
    begin
        if i_add_party_type is null then
        
            i := l_ok_mess_id.count + 1;
            l_ok_mess_id(i) := i_mess_id;
            l_file_id(i) := i_file_id;
            l_rec_num(i) := prc_api_file_pkg.get_record_number(i_sess_file_id => l_session_file_id);
        else
            if l_ok_intersect_id.exists(i_mess_id) then
             
                i := l_ok_mess_id.count + 1;
                l_ok_mess_id(i) := i_mess_id;
                l_file_id(i) := i_file_id;
                l_rec_num(i) := prc_api_file_pkg.get_record_number(i_sess_file_id => l_session_file_id);
            else        
                l_ok_intersect_id(i_mess_id) := com_api_const_pkg.TRUE;
            end if;            
        end if;
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

    procedure generate_sf_file is
    l_params               com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
            i_text  => 'generate_sf_file start'
        );
    
         select
              xmlelement("statistics",
                  xmlelement("total_file", count(1))
                  , xmlelement("list_file",
                      xmlagg(xmlelement("file_name", f.file_name)
                      )
                  )    
               ).getclobval()
          into l_sf_file
          from prc_session_file f
         where f.session_id = prc_api_session_pkg.get_session_id;
         
        rul_api_param_pkg.set_param (
            i_name       => 'ACQ_BIN'
            , i_value    => l_acq_bin
            , io_params  => l_params
        );
        
        select count(1) + 1
          into l_file_number
          from prc_session_file f
             , prc_file_attribute a
         where a.container_id = prc_api_session_pkg.get_container_id
           and f.file_attr_id = a.id
           and f.file_type    = nbc_api_const_pkg.FILE_TYPE_NBC_SF
           and f.id between com_api_id_pkg.get_from_id(prc_api_session_pkg.get_session_id) and com_api_id_pkg.get_till_id(prc_api_session_pkg.get_session_id);
                
        rul_api_param_pkg.set_param (
            i_name       => 'FILE_NUMBER'
            , i_value    => l_file_number
            , io_params  => l_params
        );
                    
        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_type    => nbc_api_const_pkg.FILE_TYPE_NBC_SF
          , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params      => l_params
        );
                            
        l_sf_file := com_api_const_pkg.XML_HEADER || C_CRLF || l_sf_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_sf_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        trc_log_pkg.debug('file saved, length = ' || length(l_sf_file));
                 
    end; 
begin
    trc_log_pkg.debug (
        i_text  => 'NBC outgoing clearing start'
    );

    prc_api_stat_pkg.log_start;

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
        (n.id                = i_network_id or i_network_id is null)
        and n.id             = m.network_id
        and n.inst_id        = m.inst_id
        and s.object_id      = m.id
        and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
        and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
        and (r.inst_id       = i_inst_id or i_inst_id is null)
        and r.id             = i.consumer_member_id
        and i.host_member_id = m.id;

    -- make estimated count
    l_participant_tab(1) := nbc_api_const_pkg.FILE_TYPE_NBC_ISS;
    l_participant_tab(2) := nbc_api_const_pkg.FILE_TYPE_NBC_ACQ;
    l_participant_tab(3) := nbc_api_const_pkg.FILE_TYPE_NBC_BNB;
    
    for i in 1..l_host_id.count loop
        for k in 1..l_participant_tab.count loop
    
            l_record_count := nbc_api_fin_message_pkg.estimate_messages_for_upload (
                i_network_id         => l_network_id(i)
                , i_inst_id          => l_inst_id(i)
                , i_participant_type => substr(l_participant_tab(k), -3)
            );

            l_estimated_count := l_estimated_count + l_record_count;
        end loop;
    end loop;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
    
        for i in 1..l_host_id.count loop
            -- init
            l_header_writed := com_api_type_pkg.FALSE;
            l_rec_number    := 0;
            l_acq_bin := cmn_api_standard_pkg.get_varchar_value (
                    i_inst_id     => l_inst_id(i)
                  , i_standard_id => l_standard_id(i)
                  , i_object_id   => l_host_id(i)
                  , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name  => nbc_api_const_pkg.NBC_BANK_CODE
                  , i_param_tab   => l_param_tab
               );

            for k in 1..l_participant_tab.count loop
            
                -- for every new file
                l_rec_number := 0;
                l_header_writed := com_api_type_pkg.FALSE;
                
                nbc_api_fin_message_pkg.enum_messages_for_upload (
                    o_fin_cur            => l_fin_cur
                    , i_network_id       => l_network_id(i)
                    , i_inst_id          => l_inst_id(i)
                    , i_participant_type => substr(l_participant_tab(k), -3)
                );

                loop
                    fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;
                    
                    for j in 1..l_fin_message.count loop
                        -- if first record create new file and put file header
                        if l_header_writed = com_api_type_pkg.FALSE then
                        
                            register_session_file (
                                i_inst_id            => l_inst_id(i)
                                , i_network_id       => l_network_id(i)
                                , i_host_inst_id     => l_host_inst_id(i)
                                , i_acq_bin          => l_acq_bin
                                , i_participant_type => l_participant_tab(k)
                                , o_file_number      => l_file_number
                                , o_session_file_id  => l_session_file_id
                            );
                            process_file_header(
                                i_network_id         => l_network_id(i)
                                , i_inst_id          => l_inst_id(i)
                                , i_session_file_id  => l_session_file_id
                                , i_host_id          => l_host_id(i)
                                , i_standard_id      => l_standard_id(i)
                                , i_file_number      => l_file_number
                                , i_participant_type => substr(l_participant_tab(k), -3)
                                , o_file             => l_file
                            );
                            l_rec_number := 1;
                            l_header_writed := com_api_type_pkg.TRUE;
                        end if;

                        -- process presentment
                        if l_fin_message(j).record_type = nbc_api_const_pkg.RECORD_TYPE_DETAIL then
                            -- process presentment
                            process_presentment(
                                i_fin_rec                => l_fin_message(j)
                                , io_file                => l_file
                                , i_session_file_id      => l_session_file_id
                                , o_line                 => l_last_line
                            );
                            l_rec_number := l_rec_number + 1;
                        end if;

                        register_ok_message (
                            i_mess_id          => l_fin_message(j).id
                            , i_file_id        => l_file.id
                            , i_add_party_type => l_fin_message(j).add_party_type
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

                if l_header_writed = com_api_type_pkg.TRUE then
                    --process trailer
                    l_rec_number := l_rec_number + 1;
                    process_file_trailer(
                        i_rec_number         => l_rec_number
                        , i_session_file_id  => l_session_file_id
                        , io_file            => l_file
                        , i_last_line        => l_last_line
                    );

                    prc_api_file_pkg.close_file (
                        i_sess_file_id  => l_session_file_id
                      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                    );

                end if;
                        
            end loop;
        end loop;
    end if;

    generate_sf_file;

    l_ok_intersect_id.delete;
    
    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => 'NBC outgoing clearing end'
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
    
end process_rf;

procedure process_df (
    i_network_id             in com_api_type_pkg.t_tiny_id default null
    , i_inst_id              in com_api_type_pkg.t_inst_id default null
) is
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_record_count            com_api_type_pkg.t_long_id;

    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id            com_api_type_pkg.t_inst_id_tab;
    l_network_id              com_api_type_pkg.t_network_tab;
    l_host_id                 com_api_type_pkg.t_number_tab;
    l_standard_id             com_api_type_pkg.t_number_tab;

    l_fin_cur                 nbc_api_type_pkg.t_nbc_fin_cur;
    l_fin_message             nbc_api_type_pkg.t_nbc_fin_mes_tab;

    l_ok_mess_id              com_api_type_pkg.t_number_tab;
    l_file_id                 com_api_type_pkg.t_number_tab;
    l_rec_num                 com_api_type_pkg.t_number_tab;

    l_session_file_id         com_api_type_pkg.t_long_id;

    l_header_writed           com_api_type_pkg.t_boolean;
    l_file                    nbc_api_type_pkg.t_nbc_file_rec;
    l_rec_number              com_api_type_pkg.t_short_id;
    l_file_number             pls_integer;  

    l_last_line               com_api_type_pkg.t_text;
    
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
    trc_log_pkg.debug (
        i_text  => 'NBC outgoing clearing start'
    );

    prc_api_stat_pkg.log_start;

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
        (n.id                = i_network_id or i_network_id is null)
        and n.id             = m.network_id
        and n.inst_id        = m.inst_id
        and s.object_id      = m.id
        and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
        and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
        and (r.inst_id       = i_inst_id or i_inst_id is null)
        and r.id             = i.consumer_member_id
        and i.host_member_id = m.id;

    -- make estimated count
    for i in 1..l_host_id.count loop
        l_record_count := nbc_api_fin_message_pkg.estimate_messages_for_upload (
            i_network_id         => l_network_id(i)
            , i_inst_id          => l_inst_id(i)
            , i_participant_type => substr(nbc_api_const_pkg.FILE_TYPE_NBC_DSP, -3)
        );

        l_estimated_count := l_estimated_count + l_record_count;
    end loop;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
    
        for i in 1..l_host_id.count loop
            -- init
            l_header_writed := com_api_type_pkg.FALSE;
            l_rec_number    := 0;

            nbc_api_fin_message_pkg.enum_messages_for_upload (
                o_fin_cur            => l_fin_cur
                , i_network_id       => l_network_id(i)
                , i_inst_id          => l_inst_id(i)
                , i_participant_type => substr(nbc_api_const_pkg.FILE_TYPE_NBC_DSP, -3)
            );

            loop
                fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;
                    
                for j in 1..l_fin_message.count loop
                    -- if first record create new file and put file header
                    if l_header_writed = com_api_type_pkg.FALSE then
                        
                        register_session_file (
                            i_inst_id            => l_inst_id(i)
                            , i_network_id       => l_network_id(i)
                            , i_host_inst_id     => l_host_inst_id(i)
                            , i_acq_bin          => l_fin_message(j).iss_inst_code
                            , i_participant_type => nbc_api_const_pkg.FILE_TYPE_NBC_DSP
                            , o_file_number      => l_file_number
                            , o_session_file_id  => l_session_file_id
                        );

                        process_file_header(
                            i_network_id         => l_network_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_session_file_id  => l_session_file_id
                            , i_host_id          => l_host_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_participant_type => substr(nbc_api_const_pkg.FILE_TYPE_NBC_DSP, -3)
                            , i_file_number      => l_file_number
                            , o_file             => l_file
                        );
                        
                        l_rec_number := 1;
                        l_header_writed := com_api_type_pkg.TRUE;
                    end if;

                    -- process presentment
                    if l_fin_message(j).record_type = nbc_api_const_pkg.RECORD_TYPE_DETAIL then
                        -- process presentment
                        process_presentment(
                            i_fin_rec                => l_fin_message(j)
                            , io_file                => l_file
                            , i_session_file_id      => l_session_file_id
                            , o_line                 => l_last_line
                        );
                        l_rec_number := l_rec_number + 1;
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

            if l_header_writed = com_api_type_pkg.TRUE then
                --process trailer
                l_rec_number := l_rec_number + 1;
                process_file_trailer(
                    i_rec_number         => l_rec_number
                    , i_session_file_id  => l_session_file_id
                    , io_file            => l_file
                    , i_last_line        => l_last_line
                );
                
                prc_api_file_pkg.close_file (
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );

            end if;
            
        end loop;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => 'NBC outgoing clearing end'
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
    
end process_df;

end;
/
