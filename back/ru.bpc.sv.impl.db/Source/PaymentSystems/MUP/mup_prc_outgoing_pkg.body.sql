CREATE OR REPLACE package body mup_prc_outgoing_pkg is
/********************************************************* 
 *  MasterCard incoming and outgoing files API  <br /> 
 *  Created by Khougaev (khougaev@bpcbt.com)  at 23.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: mup_prc_ipm_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    type            t_msg_count_tab is table of integer index by varchar2(8);
    type            t_amount_count_tab is table of integer index by com_api_type_pkg.t_curr_code;

    BULK_LIMIT      constant integer := 400;
    CRLF            constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);

    g_raw_data      com_api_type_pkg.t_raw_tab;
    g_record_number com_api_type_pkg.t_integer_tab;

    --g_amount_tab    t_amount_count_tab;

    type t_no_original_rec_rec is record (
        i_mes_rec               mup_api_type_pkg.t_mes_rec
        , i_file_id             com_api_type_pkg.t_short_id
        , i_network_id          com_api_type_pkg.t_tiny_id
        , i_host_id             com_api_type_pkg.t_tiny_id
        , i_standard_id         com_api_type_pkg.t_tiny_id
        , i_local_message       com_api_type_pkg.t_boolean
        , i_create_operation    com_api_type_pkg.t_boolean
        , i_mes_rec_prev        mup_api_type_pkg.t_mes_rec
        , io_fin_ref_id         com_api_type_pkg.t_long_id
    );

    type t_no_original_rec_tab is table of t_no_original_rec_rec index by binary_integer;
    g_no_original_rec_tab       t_no_original_rec_tab;

    procedure clear_global_data is
    begin
        g_raw_data.delete;
        g_record_number.delete;
    end;

    procedure flush_file (
        i_session_file_id       in com_api_type_pkg.t_long_id
    ) is
    begin
        prc_api_file_pkg.put_bulk(
            i_sess_file_id  => i_session_file_id
          , i_raw_tab       => g_raw_data
          , i_num_tab       => g_record_number
        );

        clear_global_data;
    end;

    procedure put_line (
        i_line                  in com_api_type_pkg.t_raw_data
      , i_session_file_id       in com_api_type_pkg.t_long_id
      , io_record_number        in out com_api_type_pkg.t_long_id
    ) is
        i                       binary_integer;
    begin
        i := g_record_number.count + 1;

        g_raw_data(i) := i_line;
        g_record_number(i) := io_record_number;

        io_record_number := io_record_number+1;

        if i >= BULK_LIMIT then
            flush_file(i_session_file_id);
        end if;
    end;

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
            , i_file_type   => mup_api_const_pkg.FILE_TYPE_CLEARING_MUP
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
        io_file_rec             in out nocopy mup_api_type_pkg.t_file_rec
        , i_amount              in number := 0
        , i_count               in number := 1
    ) is
    begin
        if io_file_rec.id is not null then
            io_file_rec.p0306 := nvl(io_file_rec.p0306, 0) + nvl(i_count, 0);
            io_file_rec.p0301 := nvl(io_file_rec.p0301, 0) + nvl(i_amount, 0);
        end if;
    end;

    procedure count_msg (
        msg_count_tab           in out nocopy t_msg_count_tab
        , mti                   in mup_api_type_pkg.t_mti
        , de024                 in mup_api_type_pkg.t_de024
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
        i_file_rec              in out nocopy mup_api_type_pkg.t_file_rec
    ) is
    begin
        insert into mup_file (
            id
            , inst_id
            , network_id
            , is_incoming
            , proc_date
            , session_file_id
            , is_rejected
            , reject_id
            , p0026
            , p0105
            , p0110
            , p0122
            , p0301
            , p0306
            , header_mti
            , header_de024
            , header_de071
            , trailer_mti
            , trailer_de024
            , trailer_de071
        ) values (
            i_file_rec.id
            , i_file_rec.inst_id
            , i_file_rec.network_id
            , i_file_rec.is_incoming
            , i_file_rec.proc_date
            , i_file_rec.session_file_id
            , i_file_rec.is_rejected
            , i_file_rec.reject_id
            , i_file_rec.p0026
            , i_file_rec.p0105
            , i_file_rec.p0110
            , i_file_rec.p0122
            , i_file_rec.p0301
            , i_file_rec.p0306
            , i_file_rec.header_mti
            , i_file_rec.header_de024
            , i_file_rec.header_de071
            , i_file_rec.trailer_mti
            , i_file_rec.trailer_de024
            , i_file_rec.trailer_de071
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'MUP_FILE_ALREADY_EXIST'
                , i_env_param1  => i_file_rec.p0105
                , i_env_param2  => i_file_rec.network_id
            );
    end;

    procedure generate_header
    (   o_raw_data              out com_api_type_pkg.t_raw_data
        , o_file_rec            out mup_api_type_pkg.t_file_rec
        , i_cmid                in com_api_type_pkg.t_cmid
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_charset             in com_api_type_pkg.t_oracle_name
        , i_session_file_id     in com_api_type_pkg.t_long_id
        , i_collection_only     in com_api_type_pkg.t_boolean   := null
    ) is
        l_pds_tab               mup_api_type_pkg.t_pds_tab;
        l_param_tab             com_api_type_pkg.t_param_tab;
    begin
        o_file_rec.id := mup_file_seq.nextval;

        o_file_rec.inst_id := i_inst_id;
        o_file_rec.network_id := i_network_id;
        o_file_rec.is_incoming := com_api_type_pkg.false;
        o_file_rec.proc_date := com_api_sttl_day_pkg.get_sysdate();

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

        o_file_rec.p0105 := mup_api_file_pkg.encode_p0105 (
            i_cmid              => i_cmid
            , i_file_date       => o_file_rec.proc_date
            , i_inst_id         => i_inst_id
            , i_network_id      => i_network_id
            , i_host_id         => i_host_id
            , i_standard_id     => i_standard_id
            , i_collection_only => i_collection_only
        );

        o_file_rec.p0122 := nvl(cmn_api_standard_pkg.get_varchar_value(
                i_inst_id           => i_inst_id
                , i_standard_id     => i_standard_id
                , i_object_id       => i_host_id
                , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_param_name      => mup_api_const_pkg.CLEARING_MODE
                , i_param_tab       => l_param_tab
            ), mup_api_const_pkg.CLEARING_MODE_DEFAULT
        );

        o_file_rec.p0301 := 0;
        o_file_rec.p0306 := 0;

        o_file_rec.header_mti := mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        o_file_rec.header_de024 := mup_api_const_pkg.FUNC_CODE_HEADER;

        inc_file_totals (
            io_file_rec     => o_file_rec
            , i_count       => 1
        );

        o_file_rec.header_de071 := o_file_rec.p0306;

        insert_file (
            i_file_rec      => o_file_rec
        );

        l_pds_tab(105) := o_file_rec.p0105;
        l_pds_tab(122) := o_file_rec.p0122;

        mup_api_msg_pkg.pack_message (
            o_raw_data          => o_raw_data
            , i_pds_tab         => l_pds_tab
            , i_mti             => o_file_rec.header_mti
            , i_de024           => o_file_rec.header_de024
            , i_de071           => o_file_rec.header_de071
            , i_charset         => i_charset
        );
    end;

    procedure update_file_totals (
        i_id                    in com_api_type_pkg.t_short_id
        , i_p0301               in number
        , i_p0306               in number
        , i_trailer_mti         in mup_api_type_pkg.t_mti
        , i_trailer_de024       in mup_api_type_pkg.t_de024
        , i_trailer_de071       in mup_api_type_pkg.t_de071
    ) is
    begin
        update mup_file
        set
            p0301 = i_p0301
            , p0306 = i_p0306
            , trailer_mti = i_trailer_mti
            , trailer_de024 = i_trailer_de024
            , trailer_de071 = i_trailer_de071
        where
            id = i_id;
    end;

    procedure generate_trailer (
        o_raw_data              out com_api_type_pkg.t_raw_data
        , i_charset             in com_api_type_pkg.t_oracle_name
        , io_file_rec           in out nocopy mup_api_type_pkg.t_file_rec
    ) is
        l_pds_tab               mup_api_type_pkg.t_pds_tab;
    begin
        if io_file_rec.id is not null then
            inc_file_totals (
                io_file_rec     => io_file_rec
                , i_count       => 1
            );

            io_file_rec.trailer_mti := mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
            io_file_rec.trailer_de024 := mup_api_const_pkg.FUNC_CODE_TRAILER;
            io_file_rec.trailer_de071 := io_file_rec.p0306;

            update_file_totals
            (   i_id            => io_file_rec.id,
                i_p0301         => io_file_rec.p0301,
                i_p0306         => io_file_rec.p0306,
                i_trailer_mti   => io_file_rec.trailer_mti,
                i_trailer_de024 => io_file_rec.trailer_de024,
                i_trailer_de071 => io_file_rec.trailer_de071
            );

            l_pds_tab(105) := io_file_rec.p0105;
            l_pds_tab(301) := io_file_rec.p0301;
            l_pds_tab(306) := io_file_rec.p0306;

            mup_api_msg_pkg.pack_message (
                o_raw_data          => o_raw_data
                , i_pds_tab         => l_pds_tab
                , i_mti             => io_file_rec.trailer_mti
                , i_de024           => io_file_rec.trailer_de024
                , i_de071           => io_file_rec.trailer_de071
                , i_charset         => i_charset
            );
        end if;

    end;

    procedure upload (
        i_network_id            in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id     := null
      , i_charset               in com_api_type_pkg.t_oracle_name := null
      , i_use_inst              in com_api_type_pkg.t_dict_value  := null
      , i_start_date            in date default null
      , i_end_date              in date default null
      , i_include_affiliate     in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
      , i_collection_only       in com_api_type_pkg.t_boolean     := null
    ) is
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
        l_msg_count             t_msg_count_tab;
        l_cmid                  com_api_type_pkg.t_cmid;
        l_fin_cur               mup_api_type_pkg.t_fin_cur;
        l_fin_tab               mup_api_type_pkg.t_fin_tab;
        l_raw_data              com_api_type_pkg.t_raw_data;
        l_file_rec              mup_api_type_pkg.t_file_rec;
        l_file_line_num         com_api_type_pkg.t_long_id :=0;
        l_add_tab               mup_api_type_pkg.t_add_tab;
        l_param_tab             com_api_type_pkg.t_param_tab;

        l_ok_rowid              com_api_type_pkg.t_rowid_tab;
        l_ok_id                 com_api_type_pkg.t_number_tab;
        l_de071                 com_api_type_pkg.t_number_tab;
        l_file_id               com_api_type_pkg.t_number_tab;
        l_add_rowid             com_api_type_pkg.t_rowid_tab;
        l_add_de071             com_api_type_pkg.t_number_tab;
        l_add_fin_de071         com_api_type_pkg.t_number_tab;
        l_add_file_id           com_api_type_pkg.t_number_tab;
        l_error_rowid           com_api_type_pkg.t_rowid_tab;

        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;

        l_session_file_id       com_api_type_pkg.t_long_id;
        l_local_message         com_api_type_pkg.t_boolean;
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
        ) is
        begin
            l_add_rowid(l_add_rowid.count + 1) := i_rowid;
            l_add_de071(l_add_de071.count + 1) := i_de071;
            l_add_fin_de071(l_add_fin_de071.count + 1) := i_fin_de071;
            l_add_file_id(l_add_file_id.count + 1) := i_file_id;
        end;

        procedure register_error_upload (
            i_rowid             in rowid
        ) is
        begin
            l_error_rowid(l_error_rowid.count + 1) := i_rowid;
        end;

        procedure mark_ok_upload is
        begin
            mup_api_fin_pkg.mark_ok_uploaded (
                i_id                => l_ok_id
                , i_rowid           => l_ok_rowid
                , i_de071           => l_de071
                , i_file_id         => l_file_id
            );

            mup_api_add_pkg.mark_uploaded (
                i_rowid             => l_add_rowid
                , i_file_id         => l_add_file_id
                , i_de071           => l_add_de071
                , i_fin_de071       => l_add_fin_de071
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
            mup_api_fin_pkg.mark_error_uploaded (
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

        procedure finish_logical_file is
        begin
            if l_file_rec.p0306 > 1 then
                generate_trailer (
                    o_raw_data      => l_raw_data
                    , i_charset     => i_charset
                    , io_file_rec   => l_file_rec
                );

                put_line (
                    i_line              => l_raw_data
                  , i_session_file_id   => l_file_rec.session_file_id
                  , io_record_number    => l_file_line_num
                );

                flush_file(l_file_rec.session_file_id);

            elsif l_file_rec.id is not null then
                rollback to savepoint ipm_start_new_logical_file;
                clear_global_data;
            end if;

            l_file_rec := null;
        end;

    begin
        savepoint ipm_start_upload;

        trc_log_pkg.debug (
            i_text          => 'starting uploading MUP'
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
            , i_param_name  => case
                               when nvl(i_use_inst, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
                                   mup_api_const_pkg.FORW_INST_ID
                               else
                                   mup_api_const_pkg.CMID
                               end
            , i_param_tab   => l_param_tab
        );

        savepoint ipm_start_new_file;

        l_excepted_count := 0;
        l_processed_count := 0;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => mup_api_fin_pkg.estimate_messages_for_upload (
                i_network_id          => i_network_id
                , i_cmid              => l_cmid
                , i_inst_code         => i_use_inst  
                , i_start_date        => trunc(i_start_date)
                , i_end_date          => trunc(i_end_date)
                , i_include_affiliate => i_include_affiliate
                , i_inst_id           => i_inst_id
                , i_collection_only   => i_collection_only
            )
        );

        init_msg_count_tab(
            msg_count_tab   => l_msg_count
        );

        trc_log_pkg.debug (
            i_text          => 'enumerating messages'
        );

        mup_api_fin_pkg.enum_messages_for_upload (
            o_fin_cur             => l_fin_cur
            , i_network_id        => i_network_id
            , i_cmid              => l_cmid
            , i_inst_code         => i_use_inst  
            , i_start_date        => trunc(i_start_date)
            , i_end_date          => trunc(i_end_date)
            , i_include_affiliate => i_include_affiliate
            , i_inst_id           => i_inst_id
            , i_collection_only   => i_collection_only
        );

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
                        if nvl(i_use_inst, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
                            l_fin_rec_cmid := l_fin_tab(i).de033;
                        else
                            l_fin_rec_cmid := l_fin_tab(i).de094;
                        end if;
                        
                        generate_header(
                            o_raw_data              => l_raw_data
                          , o_file_rec              => l_file_rec
                          , i_cmid                  => l_fin_rec_cmid
                          , i_inst_id               => l_fin_tab(i).inst_id
                          , i_network_id            => i_network_id
                          , i_host_id               => l_host_id
                          , i_standard_id           => l_standard_id
                          , i_charset               => i_charset
                          , i_session_file_id       => l_session_file_id
                          , i_collection_only       => i_collection_only
                        );
                    else
                        generate_header(
                            o_raw_data              => l_raw_data
                            , o_file_rec            => l_file_rec
                            , i_cmid                => l_cmid
                            , i_inst_id             => i_inst_id
                            , i_network_id          => i_network_id
                            , i_host_id             => l_host_id
                            , i_standard_id         => l_standard_id
                            , i_charset             => i_charset
                            , i_session_file_id     => l_session_file_id
                            , i_collection_only     => i_collection_only
                        );
                    end if;

                    l_session_file_id := l_file_rec.session_file_id;

                    put_line (
                        i_line                  => l_raw_data
                        , i_session_file_id     => l_file_rec.session_file_id
                        , io_record_number       => l_file_line_num
                    );
                end if;

                begin
                    savepoint ipm_start_new_record;

                    l_add_tab.delete;

                    l_fin_tab(i).de071 := l_file_rec.p0306 + 1;

                    mup_api_fin_pkg.pack_message (
                        i_fin_rec           => l_fin_tab(i)
                        , i_file_id         => l_file_rec.id
                        , i_de071           => l_fin_tab(i).de071
                        , o_raw_data        => l_raw_data
                        , i_charset         => i_charset
                    );

                    put_line (
                        i_line              => l_raw_data
                      , i_session_file_id   => l_file_rec.session_file_id
                      , io_record_number    => l_file_line_num
                    );

                    if (
                        l_fin_tab(i).mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
                        and l_fin_tab(i).de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
                        and l_fin_tab(i).is_reversal = com_api_type_pkg.false
                    ) then

                        mup_api_add_pkg.enum_messages_for_upload (
                            i_fin_id            => l_fin_tab(i).id
                            , o_add_tab         => l_add_tab
                        );

                        for k in 1 .. l_add_tab.count loop
                            l_add_tab(k).de071 := l_fin_tab(i).de071 + k;

                            mup_api_add_pkg.pack_message (
                                i_add_rec       => l_add_tab(k)
                                , i_file_id     => l_file_rec.id
                                , i_de071       => l_add_tab(k).de071
                                , i_fin_de071   => l_fin_tab(i).de071
                                , o_raw_data    => l_raw_data
                                , i_charset     => i_charset
                            );

                            put_line (
                                i_line              => l_raw_data
                              , i_session_file_id   => l_file_rec.session_file_id
                              , io_record_number     => l_file_line_num
                            );
                        end loop;
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
                        , mti               => mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                        , de024             => mup_api_const_pkg.FUNC_CODE_ADDENDUM
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

        mark_ok_upload;
        mark_error_upload;

        finish_logical_file;

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
            , i_processed_total  => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        
        trc_log_pkg.debug (
            i_text          => 'end uploading MUP'
        );
        
    exception
        when others then
            rollback to savepoint ipm_start_upload;

            clear_global_data;

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
