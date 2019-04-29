create or replace package body jcb_prc_outgoing_pkg is
/********************************************************* 
 *  JCB incoming and outgoing files API  <br /> 
 *  Created by Khougaev (khougaev@bpcbt.com)  at 23.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: jcb_prc_ipm_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    type            t_msg_count_tab is table of integer index by varchar2(8);

    BULK_LIMIT      constant integer := 400;

    procedure register_session_file (
        o_session_file_id      out com_api_type_pkg.t_long_id
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_cmid                in com_api_type_pkg.t_cmid
    ) is
        l_params                   com_api_type_pkg.t_param_tab;
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
            i_name       => 'ACQ_BIN'
            , i_value    => i_cmid
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'KEY_INDEX'
            , i_value    => i_cmid
            , io_params  => l_params
        );
        prc_api_file_pkg.open_file(
            o_sess_file_id  => o_session_file_id
            , i_file_type   => jcb_api_const_pkg.FILE_TYPE_CLEARING_JCB
            , io_params     => l_params
        );
    end;

    function is_fatal_error(code in number) return boolean is
    begin
        if code between -20999 and -20000 then
            return false;
        else
            return true;
        end if;
    end;

    procedure init_msg_count_tab (
        msg_count_tab           in out nocopy t_msg_count_tab
    ) is
    begin
        msg_count_tab.delete;
    end;

    procedure inc_file_totals (
        io_file_rec             in out nocopy jcb_api_type_pkg.t_file_rec
        , i_amount              in number := 0
        , i_count               in number := 1
    ) is
    begin
        if io_file_rec.id is not null then
            io_file_rec.p3903 := nvl(io_file_rec.p3903, 0) + nvl(i_count, 0);
            io_file_rec.p3902 := nvl(io_file_rec.p3902, 0) + nvl(i_amount, 0);
        end if;
    end;

    procedure count_msg (
        msg_count_tab           in out nocopy t_msg_count_tab
        , mti                   in jcb_api_type_pkg.t_mti
        , de024                 in jcb_api_type_pkg.t_de024
        , msg_count             in integer := 1
    ) is
        table_index             varchar2(8) := mti || de024;
    begin
        if msg_count_tab.exists(table_index) then
            msg_count_tab(table_index) := msg_count_tab(table_index) + msg_count;
        else
            msg_count_tab(table_index) := msg_count;
        end if;
    end;

    procedure insert_file (
        i_file_rec              in out nocopy jcb_api_type_pkg.t_file_rec
    ) is
    begin
        insert into jcb_file (
            id               
            , inst_id        
            , network_id     
            , is_incoming    
            , proc_date      
            , session_file_id
            , is_rejected    
            , reject_id          
            , header_mti     
            , header_de024   
            , p3901        
            , p3901_1        
            , p3901_2        
            , p3901_3         
            , p3901_4          
            , header_de071   
            , header_de100
            , header_de033
            , trailer_mti    
            , trailer_de024  
            , p3902          
            , p3903          
            , trailer_de071  
            , trailer_de100
            , trailer_de033
        ) values (
            i_file_rec.id               
            , i_file_rec.inst_id        
            , i_file_rec.network_id     
            , i_file_rec.is_incoming    
            , i_file_rec.proc_date      
            , i_file_rec.session_file_id
            , i_file_rec.is_rejected    
            , i_file_rec.reject_id          
            , i_file_rec.header_mti     
            , i_file_rec.header_de024   
            , i_file_rec.p3901        
            , i_file_rec.p3901_1        
            , i_file_rec.p3901_2        
            , i_file_rec.p3901_3         
            , i_file_rec.p3901_4          
            , i_file_rec.header_de071   
            , i_file_rec.header_de100
            , i_file_rec.header_de033
            , i_file_rec.trailer_mti    
            , i_file_rec.trailer_de024  
            , i_file_rec.p3902          
            , i_file_rec.p3903          
            , i_file_rec.trailer_de071  
            , i_file_rec.trailer_de100
            , i_file_rec.trailer_de033
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'JCB_FILE_ALREADY_EXIST'
                , i_env_param1  => i_file_rec.p3901
                , i_env_param2  => i_file_rec.network_id
            );
    end;

    function get_p3901_4(
          i_p3901_1     in jcb_api_type_pkg.t_p3901_1
        , i_p3901_2     in jcb_api_type_pkg.t_p3901_2
        , i_p3901_3     in jcb_api_type_pkg.t_p3901_3
        , i_network_id  in com_api_type_pkg.t_tiny_id
    ) return jcb_api_type_pkg.t_p3901_4 is
        l_file_seq              number;
        l_p3901                 jcb_api_type_pkg.t_p3901;
    begin
        l_p3901 := i_p3901_1 || to_char(i_p3901_2, jcb_api_const_pkg.P3901_DATE_FORMAT) || i_p3901_3;

        select nvl(max(to_number(p3901_4)), 0)
          into l_file_seq
          from jcb_file f
         where f.p3901 like l_p3901 || '%'
           and f.network_id = i_network_id;
         
        if l_file_seq > 99999 then
            com_api_error_pkg.raise_error(
                i_error         => 'UNABLE_ALLOCATE_FILE_NUMBER'
                , i_env_param1  => i_p3901_3
                , i_env_param2  => i_network_id
                , i_env_param3  => to_char(i_p3901_2, jcb_api_const_pkg.P3901_DATE_FORMAT)
            );
        end if;         

        l_file_seq := l_file_seq + 1;
        
        return jcb_utl_pkg.pad_number(to_char(l_file_seq), 5, 5);
         
    end;

    function generate_header (
        o_file_rec              out jcb_api_type_pkg.t_file_rec
        , i_cmid                in com_api_type_pkg.t_cmid
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_session_file_id     in com_api_type_pkg.t_long_id
        , i_with_rdw            in com_api_type_pkg.t_boolean     := null
    ) return blob is
        l_pds_tab               jcb_api_type_pkg.t_pds_tab;
        l_param_tab             com_api_type_pkg.t_param_tab;
    begin
        o_file_rec.id          := jcb_file_seq.nextval;

        o_file_rec.inst_id     := i_inst_id;
        o_file_rec.network_id  := i_network_id;
        o_file_rec.is_incoming := com_api_type_pkg.false;
        o_file_rec.proc_date   := com_api_sttl_day_pkg.get_sysdate();

        if i_session_file_id is null then
            register_session_file (
                o_session_file_id   => o_file_rec.session_file_id
              , i_inst_id           => i_inst_id
              , i_network_id        => i_network_id
              , i_cmid              => i_cmid
            );
        else
            o_file_rec.session_file_id := i_session_file_id;
        end if;

        o_file_rec.is_rejected := com_api_type_pkg.false;

        o_file_rec.p3902 := 0;
        o_file_rec.p3903 := 0;

        o_file_rec.p3901_1 := jcb_api_const_pkg.FILE_TYPE_OUT_CLEARING;
        o_file_rec.p3901_2 := o_file_rec.proc_date;
        o_file_rec.p3901_3 := jcb_utl_pkg.pad_number(i_cmid, 11, 11);
        o_file_rec.p3901_4 := 
            get_p3901_4(
                  i_p3901_1    => o_file_rec.p3901_1
                , i_p3901_2    => o_file_rec.p3901_2
                , i_p3901_3    => o_file_rec.p3901_3
                , i_network_id => i_network_id
            );
        o_file_rec.p3901 := o_file_rec.p3901_1 || to_char(o_file_rec.p3901_2, jcb_api_const_pkg.P3901_DATE_FORMAT) || o_file_rec.p3901_3 || o_file_rec.p3901_4;
        
        trc_log_pkg.debug (
            i_text          => 'p3901 = ' || o_file_rec.p3901
        );
        
        o_file_rec.header_mti   := jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        o_file_rec.header_de024 := jcb_api_const_pkg.FUNC_CODE_HEADER;
        
        o_file_rec.header_de100 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => i_inst_id
            , i_standard_id => i_standard_id
            , i_object_id   => i_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => jcb_api_const_pkg.RECV_INST_ID
            , i_param_tab   => l_param_tab
        );
        o_file_rec.trailer_de100 := o_file_rec.header_de100;
        
        trc_log_pkg.debug (
            i_text          => 'o_file_rec.trailer_de100 = ' || o_file_rec.trailer_de100
        );

        o_file_rec.header_de033 := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => i_inst_id
            , i_standard_id => i_standard_id
            , i_object_id   => i_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => jcb_api_const_pkg.CMID
            , i_param_tab   => l_param_tab
        );
        o_file_rec.trailer_de033 := o_file_rec.header_de033;
        
        trc_log_pkg.debug (
            i_text          => 'o_file_rec.header_de033 = ' || o_file_rec.header_de033
        );

        inc_file_totals (
            io_file_rec     => o_file_rec
            , i_count       => 1
        );

        o_file_rec.header_de071 := o_file_rec.p3903;
        
        insert_file (
            i_file_rec      => o_file_rec
        );

        l_pds_tab(jcb_api_const_pkg.PDS_TAG_3901) := o_file_rec.p3901;

        return 
            jcb_api_msg_pkg.pack_message (
                  i_pds_tab         => l_pds_tab
                , i_mti             => o_file_rec.header_mti
                , i_de024           => o_file_rec.header_de024
                , i_de071           => o_file_rec.header_de071
                , i_de033           => o_file_rec.header_de033
                , i_de100           => o_file_rec.header_de100   
                , i_with_rdw        => i_with_rdw 
            );
    end;

    procedure update_file_totals (
        i_id                    in com_api_type_pkg.t_short_id
        , i_p3902               in number
        , i_p3903               in number
        , i_trailer_mti         in jcb_api_type_pkg.t_mti
        , i_trailer_de024       in jcb_api_type_pkg.t_de024
        , i_trailer_de071       in jcb_api_type_pkg.t_de071
    ) is
    begin
        update jcb_file
        set
            p3902           = i_p3902
            , p3903         = i_p3903
            , trailer_mti   = i_trailer_mti
            , trailer_de024 = i_trailer_de024
            , trailer_de071 = i_trailer_de071
        where
            id = i_id;
    end;

    function generate_trailer (
        io_file_rec           in out nocopy jcb_api_type_pkg.t_file_rec
      , i_with_rdw            in com_api_type_pkg.t_boolean     := null
    ) return blob is
        l_pds_tab               jcb_api_type_pkg.t_pds_tab;
    begin
        if io_file_rec.id is not null then
        
            inc_file_totals (
                io_file_rec     => io_file_rec
                , i_count       => 1
            );

            io_file_rec.trailer_mti   := jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
            io_file_rec.trailer_de024 := jcb_api_const_pkg.FUNC_CODE_TRAILER;
            io_file_rec.trailer_de071 := io_file_rec.p3903;

            update_file_totals (
                i_id              => io_file_rec.id
                , i_p3902         => io_file_rec.p3902
                , i_p3903         => io_file_rec.p3903
                , i_trailer_mti   => io_file_rec.trailer_mti
                , i_trailer_de024 => io_file_rec.trailer_de024
                , i_trailer_de071 => io_file_rec.trailer_de071
            );

            l_pds_tab(jcb_api_const_pkg.PDS_TAG_3901) := io_file_rec.p3901;
            l_pds_tab(jcb_api_const_pkg.PDS_TAG_3902) := io_file_rec.p3902;
            l_pds_tab(jcb_api_const_pkg.PDS_TAG_3903) := io_file_rec.p3903;

            return
                jcb_api_msg_pkg.pack_message (
                      i_pds_tab         => l_pds_tab
                    , i_mti             => io_file_rec.trailer_mti
                    , i_de024           => io_file_rec.trailer_de024
                    , i_de071           => io_file_rec.trailer_de071
                    , i_de033           => io_file_rec.trailer_de033
                    , i_de100           => io_file_rec.trailer_de100   
                    , i_with_rdw        => i_with_rdw
                );
        end if;

    end;

    procedure process (
        i_network_id            in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id     := null
      , i_start_date            in date default null
      , i_end_date              in date default null
      , i_with_rdw              in com_api_type_pkg.t_boolean     := null
      , i_include_affiliate     in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
    ) is
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
        l_msg_count             t_msg_count_tab;
        l_cmid                  com_api_type_pkg.t_cmid;
        l_fin_cur               jcb_api_type_pkg.t_fin_cur;
        l_fin_tab               jcb_api_type_pkg.t_fin_tab;
        l_raw_data              blob;
        l_file_rec              jcb_api_type_pkg.t_file_rec;
        l_add_tab               jcb_api_type_pkg.t_add_tab;
        l_param_tab             com_api_type_pkg.t_param_tab;

        l_ok_rowid              com_api_type_pkg.t_rowid_tab;
        l_ok_id                 com_api_type_pkg.t_number_tab;
        l_de071                 com_api_type_pkg.t_number_tab;
        l_file_id               com_api_type_pkg.t_number_tab;
        l_add_rowid             com_api_type_pkg.t_rowid_tab;
        l_add_de071             com_api_type_pkg.t_number_tab;
        l_add_fin_de071         com_api_type_pkg.t_number_tab;
        l_add_file_id           com_api_type_pkg.t_number_tab;
        l_add_seqnum            com_api_type_pkg.t_number_tab;
        l_error_rowid           com_api_type_pkg.t_rowid_tab;

        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;
        
        l_session_file_id       com_api_type_pkg.t_long_id;
        l_file_length           com_api_type_pkg.t_long_id;
        
        l_file                  blob;
        l_fin_rec_cmid          com_api_type_pkg.t_cmid;

        procedure register_ok_upload (
            i_rowid             in rowid
            , i_id              in number
            , i_de071           in number
            , i_file_id         in number
        ) is
        begin
            l_ok_rowid(l_ok_rowid.count + 1) := i_rowid;
            l_ok_id(l_ok_id.count + 1) := i_id;
            l_de071(l_de071.count + 1) := i_de071;
            l_file_id(l_file_id.count + 1) := i_file_id;
        end;

        procedure register_add_upload (
            i_rowid             in rowid
            , i_de071           in number
            , i_fin_de071       in number
            , i_file_id         in number
            , i_add_seqnum      in number
        ) is
        begin
            l_add_rowid(l_add_rowid.count + 1) := i_rowid;
            l_add_de071(l_add_de071.count + 1) := i_de071;
            l_add_fin_de071(l_add_fin_de071.count + 1) := i_fin_de071;
            l_add_file_id(l_add_file_id.count + 1) := i_file_id;
            l_add_seqnum(l_add_seqnum.count + 1) := i_add_seqnum;
        end;

        procedure register_error_upload (
            i_rowid             in rowid
        ) is
        begin
            l_error_rowid(l_error_rowid.count + 1) := i_rowid;
        end;

        procedure mark_ok_upload is
        begin
            jcb_api_fin_pkg.mark_ok_uploaded (
                i_id                => l_ok_id
                , i_rowid           => l_ok_rowid
                , i_de071           => l_de071
                , i_file_id         => l_file_id
            );

            jcb_api_add_pkg.mark_uploaded (
                i_rowid             => l_add_rowid
                , i_file_id         => l_add_file_id
                , i_de071           => l_add_de071
                , i_fin_de071       => l_add_fin_de071
               , i_add_seqnum       => l_add_seqnum
            );

            l_ok_rowid.delete;
            l_ok_id.delete;
            l_de071.delete;
            l_add_rowid.delete;
            l_add_de071.delete;
            l_add_fin_de071.delete;
            l_file_id.delete;
        end;

        procedure mark_error_upload is
        begin
            jcb_api_fin_pkg.mark_error_uploaded (
                i_rowid             => l_error_rowid
            );

            l_error_rowid.delete;
        end;

        procedure check_ok_upload is
        begin
            if l_ok_rowid.count >= BULK_LIMIT then
                mark_ok_upload;
            end if;
        end;

        procedure check_error_upload is
        begin
            if l_error_rowid.count >= BULK_LIMIT then
                mark_error_upload;
            end if;
        end;

        procedure append_file is
        begin

            trc_log_pkg.debug (
                i_text          => 'try append raw_data'
            );
            dbms_lob.append(l_file, l_raw_data);
            dbms_lob.freetemporary(l_raw_data);

            trc_log_pkg.debug (
                i_text          => 'success append raw_data'
            );
        end;

    begin
        savepoint ipm_start_upload;

        trc_log_pkg.debug (
            i_text          => 'starting uploading JCB with Parameters: network [#1], inst_id [#2], Record with rdw [#3]'
            , i_env_param1  => i_network_id
            , i_env_param2  => i_inst_id
            , i_env_param3  => i_with_rdw
        );

        prc_api_stat_pkg.log_start;

        l_host_id := net_api_network_pkg.get_default_host(i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(
            i_host_id       => l_host_id
        );

        l_cmid := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => i_inst_id
            , i_standard_id => l_standard_id
            , i_object_id   => l_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => jcb_api_const_pkg.CMID
            , i_param_tab   => l_param_tab
        );
        trc_log_pkg.debug (
            i_text          => 'l_cmid = ' ||l_cmid
        );

        savepoint ipm_start_new_file;

        l_excepted_count  := 0;
        l_processed_count := 0;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => jcb_api_fin_pkg.estimate_messages_for_upload (
                i_network_id        => i_network_id
              , i_cmid              => l_cmid
              , i_start_date        => trunc(i_start_date)
              , i_end_date          => trunc(i_end_date)
              , i_inst_id           => i_inst_id
              , i_include_affiliate => i_include_affiliate
            )
        );

        init_msg_count_tab
        (   msg_count_tab   => l_msg_count
        );

        trc_log_pkg.debug (
            i_text          => 'enumerating messages'
        );

        jcb_api_fin_pkg.enum_messages_for_upload (
            o_fin_cur           => l_fin_cur
          , i_network_id        => i_network_id
          , i_cmid              => l_cmid
          , i_start_date        => trunc(i_start_date)
          , i_end_date          => trunc(i_end_date)
          , i_inst_id           => i_inst_id
          , i_include_affiliate => i_include_affiliate
        );
        dbms_lob.createtemporary(l_raw_data, true);
        dbms_lob.createtemporary(l_file, true);

        loop
            fetch l_fin_cur bulk collect into l_fin_tab limit BULK_LIMIT;

            for i in 1 .. l_fin_tab.count loop

                if l_file_rec.id is null then
                
                    trc_log_pkg.debug (
                        i_text          => 'generating header'
                    );

                    savepoint ipm_start_new_logical_file;
                    
                    if i_include_affiliate = com_api_const_pkg.TRUE
                        and i_inst_id is not null
                    then
                        l_fin_rec_cmid := l_fin_tab(i).de033;

                        l_raw_data := generate_header(
                            o_file_rec            => l_file_rec
                          , i_cmid                => l_fin_rec_cmid
                          , i_inst_id             => l_fin_tab(i).inst_id
                          , i_network_id          => i_network_id
                          , i_host_id             => l_host_id
                          , i_standard_id         => l_standard_id
                          , i_session_file_id     => l_session_file_id
                          , i_with_rdw            => i_with_rdw
                        );
                    else
                        l_raw_data := generate_header(
                            o_file_rec            => l_file_rec
                          , i_cmid                => l_cmid
                          , i_inst_id             => i_inst_id
                          , i_network_id          => i_network_id
                          , i_host_id             => l_host_id
                          , i_standard_id         => l_standard_id
                          , i_session_file_id     => l_session_file_id
                          , i_with_rdw            => i_with_rdw
                        );
                    end if;

                    l_session_file_id := l_file_rec.session_file_id;

                    append_file;

                    trc_log_pkg.debug (
                        i_text          => 'header append'
                    );
                end if;

                begin
                    savepoint ipm_start_new_record;

                    l_add_tab.delete;

                    l_fin_tab(i).de071 := l_file_rec.p3903 + 1;

                    trc_log_pkg.debug (
                        i_text          => 'generate message'
                    );

                    l_raw_data := jcb_api_fin_pkg.pack_message (
                        i_fin_rec           => l_fin_tab(i)
                        , i_file_id         => l_file_rec.id
                        , i_de071           => l_fin_tab(i).de071
                        , i_with_rdw        => i_with_rdw
                    );

                    append_file;

                    if (
                        l_fin_tab(i).mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
                        and l_fin_tab(i).de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
                        and l_fin_tab(i).is_reversal = com_api_type_pkg.false
                    ) then

                        jcb_api_add_pkg.enum_messages_for_upload (
                            i_fin_id            => l_fin_tab(i).id
                            , o_add_tab         => l_add_tab
                        );

                        for k in 1 .. l_add_tab.count loop
                        
                            l_add_tab(k).de071 := l_fin_tab(i).de071 + k;

                            trc_log_pkg.debug(
                                i_text  => 'pack addendum start '
                            );
                        
                            l_raw_data := jcb_api_add_pkg.pack_message (
                                i_add_rec       => l_add_tab(k)
                                , i_file_id     => l_file_rec.id
                                , i_de071       => l_add_tab(k).de071 -- number addendum in file
                                , i_fin_de071   => l_fin_tab(i).de071 -- number of presentment in file
                                , i_add_seqnum  => k                  -- number of addendum in presentment   
                                , i_with_rdw    => i_with_rdw
                            );
                            
                            trc_log_pkg.debug(
                                i_text  => 'pack addendum end '
                            );
                            
                            append_file;

                        end loop;
                        
                        trc_log_pkg.debug (
                            i_text          => 'addendums append'
                        );
                    end if;

                    inc_file_totals (
                        io_file_rec         => l_file_rec
                        , i_amount          => l_fin_tab(i).de004
                        , i_count           => 1
                    );

                    inc_file_totals (
                        io_file_rec         => l_file_rec
                        , i_amount          => 0
                        , i_count           => l_add_tab.count
                    );

                    count_msg (
                        msg_count_tab       => l_msg_count
                        , mti               => l_fin_tab(i).mti
                        , de024             => l_fin_tab(i).de024
                        , msg_count         => 1
                    );

                    count_msg (
                        msg_count_tab       => l_msg_count
                        , mti               => jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                        , de024             => jcb_api_const_pkg.FUNC_CODE_ADDENDUM
                        , msg_count         => l_add_tab.count
                    );

                    register_ok_upload (
                        i_rowid         => l_fin_tab(i).row_id
                        , i_id          => l_fin_tab(i).id
                        , i_de071       => l_fin_tab(i).de071
                        , i_file_id     => l_file_rec.id
                    );

                    for k in 1 .. l_add_tab.count loop
                        register_add_upload (
                            i_rowid         => l_add_tab(k).row_id
                            , i_de071       => l_add_tab(k).de071
                            , i_fin_de071   => l_fin_tab(i).de071
                            , i_file_id     => l_file_rec.id
                            , i_add_seqnum  => k
                        );
                    end loop;

                    l_add_tab.delete;
                exception
                    when others then
                        if is_fatal_error(sqlcode) then
                            raise;

                        else
                            rollback to savepoint ipm_start_new_record;
                            register_error_upload (
                                i_rowid         => l_fin_tab(i).row_id
                            );

                            l_excepted_count := l_excepted_count + 1;
                        end if;
                end;

                check_ok_upload;
                check_error_upload;
            end loop;

            l_processed_count := l_processed_count + l_fin_tab.count;

            prc_api_stat_pkg.log_current (
                i_current_count       => l_processed_count
                , i_excepted_count    => l_excepted_count
            );

            exit when l_fin_cur%notfound;
        end loop;
        
        close l_fin_cur;

        mark_ok_upload;
        mark_error_upload;

        if l_file_rec.p3903 > 1 then

            trc_log_pkg.debug (
                i_text          => 'generate trailer'
            );

            l_raw_data := generate_trailer (
                io_file_rec   => l_file_rec
              , i_with_rdw    => i_with_rdw
            );

            append_file;

            trc_log_pkg.debug (
                i_text          => 'trailer append'
            );

            prc_api_file_pkg.put_file (
                i_sess_file_id   => l_file_rec.session_file_id
              , i_blob_content   => l_file
              , i_add_to         => com_api_type_pkg.FALSE
            );

            l_file_length := dbms_lob.getlength(l_file);
            trc_log_pkg.debug (
                i_text          => 'l_file_length = ' || l_file_length
            );
            
            dbms_lob.freetemporary(l_file);
            --dbms_lob.freetemporary(l_raw_data);
            
        end if;
        
        l_file_rec := null;

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
            , i_processed_total => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint ipm_start_upload;

            if l_fin_cur%isopen then
                close l_fin_cur;
            end if;

            prc_api_stat_pkg.log_end(
                i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            trc_log_pkg.error (
                i_text          => sqlerrm
            );

            raise;
    end;
    
end;
/
