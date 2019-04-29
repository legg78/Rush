create or replace package body cmp_prc_outgoing_pkg as

BULK_LIMIT      constant integer := 1000;

procedure process_file_header(
    i_network_id             in com_api_type_pkg.t_tiny_id
    , i_inst_id              in com_api_type_pkg.t_inst_id
    , i_action_code          in com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
    , i_session_file_id      in com_api_type_pkg.t_long_id
    , i_host_id              in com_api_type_pkg.t_inst_id
    , i_standard_id          in com_api_type_pkg.t_inst_id
    , i_charset              in com_api_type_pkg.t_attr_name
    , o_file                 out cmp_api_type_pkg.t_cmp_file_rec
) is
    l_line                   com_api_type_pkg.t_text;
    l_param_tab              com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug (
        i_text         => 'cmp_prc_outgoing_pkg.process_file_header start'
    );
    o_file.id           := i_session_file_id;
    o_file.is_incoming  := com_api_type_pkg.FALSE;
    o_file.is_rejected  := com_api_type_pkg.FALSE;
    o_file.network_id   := i_network_id;
    o_file.trans_date   := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.inst_id      := i_inst_id;
    o_file.action_code  := i_action_code;
    o_file.file_number  := 0;
    o_file.pack_no      := substr(i_session_file_id, -9);
    o_file.encoding     := nvl(i_charset, 'UTF8');
    o_file.file_type    := 'CS';

    trc_log_pkg.debug (
        i_text         => 'cmp_prc_outgoing_pkg.process_file_header fill o_file - ok'
    ); 

    o_file.inst_name := cmn_api_standard_pkg.get_varchar_value(
                            i_inst_id       => i_inst_id
                          , i_standard_id   => i_standard_id
                          , i_object_id     => i_host_id
                          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                          , i_param_name    => cmp_api_const_pkg.COMPASS_ACQUIRER_NAME
                          , i_param_tab     => l_param_tab
                        );

    o_file.version := cmn_api_standard_pkg.get_number_value(
                          i_inst_id       => i_inst_id
                        , i_standard_id   => i_standard_id
                        , i_object_id     => i_host_id
                        , i_entity_type   => cmn_api_const_pkg.ENTITY_TYPE_CMN_STANDARD_VERS
                        , i_param_name    => cmp_api_const_pkg.COMPASS_PROTOCOL_VERSION
                        , i_param_tab     => l_param_tab
                      );

    if o_file.inst_name is null then

        com_api_error_pkg.raise_error(
            i_error       => 'CMP_INSTITUTION_NOT_FOUND'
        );
    end if;

    if o_file.version is null then

        com_api_error_pkg.raise_error(
            i_error       => 'CMP_VERSION_PARAM_NOT_FOUND'
          , i_env_param1  => o_file.inst_id
          , i_env_param2  => i_standard_id
          , i_env_param3  => i_host_id
          , i_env_param4  => cmp_api_const_pkg.COMPASS_PROTOCOL_VERSION
        );

    end if;

    l_line := l_line || cmp_api_const_pkg.IDENT_FILETYPE || '=' || o_file.file_type            || cmp_api_const_pkg.DELIM_FIELD;
    l_line := l_line || cmp_api_const_pkg.IDENT_INSTNAME || '=' || o_file.inst_name            || cmp_api_const_pkg.DELIM_FIELD;
    l_line := l_line || cmp_api_const_pkg.IDENT_PACKNO   || '=' || o_file.pack_no              || cmp_api_const_pkg.DELIM_FIELD;
    l_line := l_line || cmp_api_const_pkg.IDENT_VERSION  || '=' || o_file.version              || cmp_api_const_pkg.DELIM_FIELD;
    l_line := l_line || cmp_api_const_pkg.IDENT_TEST     || '=' || to_char(nvl(o_file.action_code, '0')) || cmp_api_const_pkg.DELIM_FIELD;
    l_line := l_line || cmp_api_const_pkg.IDENT_ENCODING || '=' || o_file.encoding;

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'cmp_prc_outgoing_pkg.process_file_header end'
    );
end;

procedure process_file_trailer(
    i_rec_number             in     com_api_type_pkg.t_short_id
    , i_session_file_id      in     com_api_type_pkg.t_long_id
    , io_file                in out cmp_api_type_pkg.t_cmp_file_rec
) is
    l_line                   com_api_type_pkg.t_text;

begin
    trc_log_pkg.debug (
        i_text         => 'cmp_prc_outgoing_pkg.process_file_trailer start'
    );
    io_file.crc := 0;
       
    l_line := l_line || cmp_api_const_pkg.IDENT_CRC || '=' || to_char(io_file.crc);

    prc_api_file_pkg.put_line(
        i_raw_data      => l_line
      , i_sess_file_id  => i_session_file_id
    );

    insert into cmp_file (
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
    );
    
    trc_log_pkg.debug (
        i_text         => 'cmp_prc_outgoing_pkg.process_file_trailer end'
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
            cmp_fin_message_vw
        set
            file_id = i_file_id(i)
            , msg_number = i_rec_num(i)
            --, status = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
            , status = case 
                            when status = net_api_const_pkg.CLEARING_MSG_STATUS_READY and collect_only_flag is null then net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED -- uploaded
                            when status = net_api_const_pkg.CLEARING_MSG_STATUS_READY and collect_only_flag = 'C' then cmp_api_const_pkg.CLEARING_COLLECT_STATUS_READY  -- ready to upload collection
                            when status = cmp_api_const_pkg.CLEARING_COLLECT_STATUS_READY then net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED   -- uploaded
                            else net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED -- uploaded
                       end            
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
    , o_session_file_id     out com_api_type_pkg.t_long_id
) is
    l_params                  com_api_type_pkg.t_param_tab;
begin
    l_params.delete;
    rul_api_param_pkg.set_param (
        i_name       => 'INST_ID'
        --, i_value    => i_inst_id
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
        , i_file_type   => cmp_api_const_pkg.FILE_TYPE_CLEARING_CMP
        , io_params     => l_params
    );
end;

procedure process_presentment(
    i_fin_rec                in     cmp_api_type_pkg.t_cmp_fin_mes_rec    
    , io_file                in out cmp_api_type_pkg.t_cmp_file_rec
    , i_rec_number           in     com_api_type_pkg.t_short_id
    , i_session_file_id      in     com_api_type_pkg.t_long_id
) is
    l_line                   com_api_type_pkg.t_text;
    l_amount                 com_api_type_pkg.t_name;   

begin
    trc_log_pkg.debug (
        i_text         => 'cmp_prc_outgoing_pkg.process_presentment start'
    );   
    l_line := l_line || cmp_api_const_pkg.IDENT_ID                   || '=' || to_char(i_fin_rec.id)  || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_NETWORK              || '=' || i_fin_rec.network      || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_HOSTNETID            || '=' || i_fin_rec.host_net_id  || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_EXTTRANATTR          || '=' || i_fin_rec.ext_tran_attr|| cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TRANSTYPE            || '=' || i_fin_rec.tran_type    || cmp_api_const_pkg.DELIM_FIELD;
    l_line := l_line || cmp_api_const_pkg.IDENT_TRANCLASS            || '=' || i_fin_rec.tran_class   || cmp_api_const_pkg.DELIM_FIELD;
    l_line := l_line || cmp_api_const_pkg.IDENT_TRANCODE             || '=' || i_fin_rec.tran_code    || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMZIP              || '=' || i_fin_rec.term_zip     || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMCOUNTRY          || '=' || i_fin_rec.term_country || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMCITY             || '=' || substr(i_fin_rec.term_city, 1, 30)   || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMINSTCOUNTRY      || '=' || i_fin_rec.term_inst_country || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_POSCONDITION         || '=' || i_fin_rec.pos_condition || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_POSENTRYMODE         || '=' || i_fin_rec.pos_entry_mode|| cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_PIN                  || '=' || to_char(i_fin_rec.pin_presence)  || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMENTRYCAPS        || '=' || i_fin_rec.term_entry_caps || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_ORIGTIME             || '=' || to_char(round((i_fin_rec.orig_time - cmp_api_const_pkg.GC_OLD_DATE) * 60 * 60 * 24)) || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TIME                 || '=' || to_char(round((i_fin_rec.host_time - cmp_api_const_pkg.GC_OLD_DATE) * 60 * 60 * 24)) || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_PAN                  || '=' || i_fin_rec.card_number  || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_EXPDATE              || '=' || i_fin_rec.exp_date     || cmp_api_const_pkg.DELIM_FIELD; 
    l_amount := com_api_currency_pkg.get_amount_str(
        i_amount         => i_fin_rec.amount
      , i_curr_code      => i_fin_rec.currency
      , i_mask_curr_code => 1
    );
    l_line := l_line || cmp_api_const_pkg.IDENT_AMOUNT               || '=' || l_amount                || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_EXTPSFIELDS          || '=' || i_fin_rec.ext_ps_fields || cmp_api_const_pkg.DELIM_FIELD; 

    if i_fin_rec.emv_data_exists = com_api_type_pkg.TRUE then
        trc_log_pkg.debug (
            i_text         => 'EMV: icc_term_caps=' || i_fin_rec.icc_term_caps || ', icc_app_tran_count='||i_fin_rec.icc_app_tran_count
                              ||', icc_app_profile='||i_fin_rec.icc_app_profile|| ', icc_tran_date='||i_fin_rec.icc_tran_date 
                              || ', icc_crypt_inform_data='||i_fin_rec.icc_crypt_inform_data || ', icc_cvm_res='||i_fin_rec.icc_cvm_res 
                              ||', icc_card_member='||i_fin_rec.icc_card_member || ', card_member='||i_fin_rec.card_member 
                              ||', to_char(icc_tran_date)=' || to_char(i_fin_rec.icc_tran_date)
        );

        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_TERMCAPS     || '=' || to_char(to_number(i_fin_rec.icc_term_caps, 'XXXXXXXXXXXXXXXX')) || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_TVR          || '=' || i_fin_rec.icc_tvr            || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_RANDOM       || '=' || i_fin_rec.icc_random         || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_TERMSN       || '=' || i_fin_rec.icc_term_sn        || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_ISSUERDATA   || '=' || i_fin_rec.icc_issuer_data    || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_CRYPTOGRAM   || '=' || i_fin_rec.icc_cryptogram     || cmp_api_const_pkg.DELIM_FIELD;    
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_APPTRANCOUNT || '=' || to_char(to_number(i_fin_rec.icc_app_tran_count, 'XXXXXXXXXXXXXXXX')) || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_TERMTRANCOUNT|| '=' || i_fin_rec.icc_term_tran_count|| cmp_api_const_pkg.DELIM_FIELD;    
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_APPPROFILE   || '=' || to_char(to_number(i_fin_rec.icc_app_profile, 'XXXXXXXXXXXXXXXX')) || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_IAD          || '=' || i_fin_rec.icc_iad            || cmp_api_const_pkg.DELIM_FIELD;    
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_TRANTYPE     || '=' || i_fin_rec.icc_tran_type      || cmp_api_const_pkg.DELIM_FIELD;    
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_TERMCOUNTRY  || '=' || i_fin_rec.icc_term_country   || cmp_api_const_pkg.DELIM_FIELD;  
          
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_TRANDATE     || '=' || round((i_fin_rec.icc_tran_date - cmp_api_const_pkg.GC_OLD_DATE) * 60 * 60 * 24) || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_AMOUNT       || '=' || lpad(i_fin_rec.icc_amount, 12, '0') || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_CURRENCY     || '=' || i_fin_rec.icc_currency  || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_CBAMOUNT     || '=' || lpad('0', 12, '0')      || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_CRYPTINFORMDATA   || '=' || to_char(to_number(i_fin_rec.icc_crypt_inform_data, 'XXXXXXXXXXXXXXXX')) || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_CVMRES       || '=' || to_char(to_number(i_fin_rec.icc_cvm_res, 'XXXXXXXXXXXXXXXX')) || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_ICC_CARDMEMBER   || '=' || to_char(to_number(i_fin_rec.icc_card_member, 'XXXXXXXXXXXXXXXX')) || cmp_api_const_pkg.DELIM_FIELD; 
        l_line := l_line || cmp_api_const_pkg.IDENT_CARDMEMBER       || '=' || to_char(to_number(i_fin_rec.card_member, 'XXXXXXXXXXXXXXXX')) || cmp_api_const_pkg.DELIM_FIELD; 

    else
        l_line := l_line || cmp_api_const_pkg.IDENT_CARDMEMBER       || '=' || i_fin_rec.card_member || cmp_api_const_pkg.DELIM_FIELD; 
    end if;

    l_line := l_line || cmp_api_const_pkg.IDENT_SERVICECODE          || '=' || i_fin_rec.service_code || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_ICC_RESPCODE         || '=' || i_fin_rec.icc_respcode || cmp_api_const_pkg.DELIM_FIELD; 

    l_line := l_line || cmp_api_const_pkg.IDENT_TERMCONTACTLESSCAPABLE || '=' || i_fin_rec.term_contactless_capable || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_EXTSTAN              || '=' || i_fin_rec.ext_stan || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMSIC              || '=' || i_fin_rec.mcc || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMCLASS            || '=' || i_fin_rec.term_class || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_EXTFID               || '=' || i_fin_rec.ext_fid || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_EXTRRN               || '=' || i_fin_rec.tran_number || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_FINALRRN             || '=' || i_fin_rec.final_rrn || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_APPROVALCODE         || '=' || i_fin_rec.approval_code || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMNAME             || '=' || i_fin_rec.term_name || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMRETAILERNAME     || '=' || i_fin_rec.term_retailer_name || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMLOCATION         || '=' || i_fin_rec.term_location || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMOWNER            || '=' || i_fin_rec.term_owner || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_EXTTERMOWNER         || '=' || i_fin_rec.term_owner || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_CURRENCY             || '=' || i_fin_rec.currency || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TERMINSTID           || '=' || i_fin_rec.term_inst_id || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_FROMACCTTYPE         || '=' || i_fin_rec.from_acct_type || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_AID                  || '=' || substr(i_fin_rec.arn, 2, 6) || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_ARN                  || '=' || i_fin_rec.arn || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_ORIGFINAME           || '=' || i_fin_rec.orig_fi_name || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_DESTFINAME           || '=' || i_fin_rec.dest_fi_name || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_CLEARDATE            || '=' || to_char(round((get_sysdate - cmp_api_const_pkg.GC_OLD_DATE) * 60 * 60 * 24)) || cmp_api_const_pkg.DELIM_FIELD; 
    l_line := l_line || cmp_api_const_pkg.IDENT_TRANNUMBER           || '=' || i_fin_rec.tran_number; 

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;    
    
    trc_log_pkg.debug (
        i_text         => 'cmp_prc_outgoing_pkg.process_presentment end'
    );
    
end;

procedure process (
    i_network_id             in com_api_type_pkg.t_tiny_id default null
    , i_inst_id              in com_api_type_pkg.t_inst_id default null
    , i_host_inst_id         in com_api_type_pkg.t_inst_id default null
    , i_action_code          in varchar2 default null
    , i_collect_only_upload_type in com_api_type_pkg.t_dict_value default null
)is
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_record_count            com_api_type_pkg.t_long_id;

    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id            com_api_type_pkg.t_inst_id_tab;
    l_network_id              com_api_type_pkg.t_network_tab;
    l_host_id                 com_api_type_pkg.t_number_tab;
    l_standard_id             com_api_type_pkg.t_number_tab;

    l_fin_cur                 cmp_api_type_pkg.t_cmp_fin_cur;
    l_fin_message             cmp_api_type_pkg.t_cmp_fin_mes_tab;

    l_ok_mess_id              com_api_type_pkg.t_number_tab;
    l_file_id                 com_api_type_pkg.t_number_tab;
    l_rec_num                 com_api_type_pkg.t_number_tab;

    l_session_file_id         com_api_type_pkg.t_long_id;

    l_header_writed           com_api_type_pkg.t_boolean;
    l_file                    cmp_api_type_pkg.t_cmp_file_rec;
    l_rec_number              com_api_type_pkg.t_short_id;
    l_collect_only_upload_type com_api_type_pkg.t_dict_value;
    l_charset                 com_api_type_pkg.t_attr_name;
    l_container_id            com_api_type_pkg.t_short_id;

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
        i_text  => 'CompassPlus outgoing clearing start'
    );

    prc_api_stat_pkg.log_start;

    l_collect_only_upload_type := nvl(i_collect_only_upload_type, cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_ALL);
                
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
        and (r.inst_id = i_inst_id or i_inst_id is null)
        and r.id = i.consumer_member_id
        and i.host_member_id = m.id;


    -- make estimated count
    for i in 1..l_host_id.count loop
        l_record_count := cmp_api_fin_message_pkg.estimate_messages_for_upload (
            i_network_id      => l_network_id(i)
            , i_inst_id       => l_inst_id(i)
            , i_host_inst_id  => l_host_inst_id(i)
            , i_collect_only  => l_collect_only_upload_type  
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
               and f.file_type    = cmp_api_const_pkg.FILE_TYPE_CLEARING_CMP
               and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_OUT;
        
        exception
            when no_data_found then 
                l_charset := 'UTF8';        
        end;
        
        trc_log_pkg.debug (
            i_text  => 'l_charset = ' || l_charset
        );
    
        for i in 1..l_host_id.count loop
            -- init
            l_header_writed := com_api_type_pkg.FALSE;
            l_rec_number    := 0;

            cmp_api_fin_message_pkg.enum_messages_for_upload (
                o_fin_cur         => l_fin_cur
                , i_network_id    => l_network_id(i)
                , i_inst_id       => l_inst_id(i)
                , i_host_inst_id  => l_host_inst_id(i)
                , i_collect_only  => l_collect_only_upload_type  
            );
            loop
                fetch l_fin_cur bulk collect into l_fin_message limit BULK_LIMIT;
                
                for j in 1..l_fin_message.count loop
                    -- if first record create new file and put file header
                    if l_header_writed = com_api_type_pkg.FALSE then
                        register_session_file (
                            i_inst_id           => l_inst_id(i)
                            , i_network_id      => l_network_id(i)
                            , i_host_inst_id    => l_host_inst_id(i)
                            , o_session_file_id => l_session_file_id
                        );

                        process_file_header (
                            i_network_id         => l_network_id(i)
                            , i_inst_id          => l_inst_id(i)
                            , i_action_code      => i_action_code
                            , i_session_file_id  => l_session_file_id
                            , i_host_id          => l_host_id(i)
                            , i_standard_id      => l_standard_id(i)
                            , i_charset          => l_charset
                            , o_file             => l_file
                        );
                        
                        l_rec_number := 1;
                        l_header_writed := com_api_type_pkg.TRUE;
                    end if;

                    -- process presentment
                    if l_fin_message(j).tran_type in (cmp_api_const_pkg.MTID_PRESENTMENT
                                                    , cmp_api_const_pkg.MTID_PRESENTMENT_REV
                                                    , cmp_api_const_pkg.MTID_COLLECT_ONLY
                                                    , cmp_api_const_pkg.MTID_COLLECT_ONLY_REV) then
                        -- process presentment
                        l_rec_number := l_rec_number + 1;
                        
                        cmp_cst_outgoing_pkg.process_presentment(
                            io_fin_rec    => l_fin_message(j)    
                          , i_network_id  => l_network_id(i)
                          , i_host_id     => l_host_id(i)
                          , i_inst_id     => l_inst_id(i)
                          , i_standard_id => l_standard_id(i)                        
                        );
                        
                        process_presentment(
                            i_fin_rec                => l_fin_message(j)
                            , io_file                => l_file
                            , i_rec_number           => l_rec_number
                            , i_session_file_id      => l_session_file_id
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

            if l_header_writed = com_api_type_pkg.TRUE then
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
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_processed_count
    );

    trc_log_pkg.debug (
        i_text  => 'CompassPlus outgoing clearing end'
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
    
end;

end;
/
