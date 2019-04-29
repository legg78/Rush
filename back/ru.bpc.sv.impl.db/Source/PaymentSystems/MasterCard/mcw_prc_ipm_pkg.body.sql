create or replace package body mcw_prc_ipm_pkg is
/*********************************************************
 *  MasterCard incoming and outgoing files API  <br />
 *  Created by Khougaev (khougaev@bpcbt.com)  at 23.10.2009 <br />
 *  Module: MCW_PRC_IPM_PKG <br />
 *  @headcom
 **********************************************************/

    type            t_msg_count_tab is table of integer index by varchar2(8);
    type            t_amount_count_tab is table of integer index by com_api_type_pkg.t_curr_code;

    BULK_LIMIT      constant integer := 400;
    CRLF            constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);

    g_raw_data      com_api_type_pkg.t_raw_tab;
    g_record_number com_api_type_pkg.t_integer_tab;

    g_amount_tab    t_amount_count_tab;

    g_trim_bin      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE;

    type t_no_original_rec_rec is record (
        i_mes_rec               mcw_api_type_pkg.t_mes_rec
      , i_file_id               com_api_type_pkg.t_short_id
      , i_incom_sess_file_id    com_api_type_pkg.t_long_id
      , i_network_id            com_api_type_pkg.t_tiny_id
      , i_host_id               com_api_type_pkg.t_tiny_id
      , i_standard_id           com_api_type_pkg.t_tiny_id
      , i_local_message         com_api_type_pkg.t_boolean
      , i_create_operation      com_api_type_pkg.t_boolean
      , i_mes_rec_prev          mcw_api_type_pkg.t_mes_rec
      , i_inst_id               com_api_type_pkg.t_inst_id
      , io_fin_ref_id           com_api_type_pkg.t_long_id
    );
    type t_no_original_rec_tab is table of t_no_original_rec_rec index by binary_integer;
    g_no_original_rec_tab       t_no_original_rec_tab;

    procedure clear_global_data is
    begin
        g_raw_data.delete;
        g_record_number.delete;
    end;

    procedure set_trim_bin(
        i_trim_bin      in com_api_type_pkg.t_boolean
    )
    is
    begin
        g_trim_bin := nvl(i_trim_bin, com_api_const_pkg.FALSE);
    end;

    function get_trim_bin
    return com_api_type_pkg.t_boolean
    is
    begin
        return g_trim_bin;
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
            , i_file_type   => mcw_api_const_pkg.FILE_TYPE_CLEARING_MASTERCARD
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
        io_file_rec             in out nocopy mcw_api_type_pkg.t_file_rec
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
        , mti                   in mcw_api_type_pkg.t_mti
        , de024                 in mcw_api_type_pkg.t_de024
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
        i_file_rec              in out nocopy mcw_api_type_pkg.t_file_rec
    ) is
    begin
        insert into mcw_file (
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
            , local_file
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
            , i_file_rec.local_file
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'MCW_FILE_ALREADY_EXIST'
                , i_env_param1  => i_file_rec.p0105
                , i_env_param2  => i_file_rec.network_id
            );
    end;

    procedure generate_header(
        o_raw_data               out com_api_type_pkg.t_raw_data
      , o_file_rec               out mcw_api_type_pkg.t_file_rec
      , i_cmid                in     com_api_type_pkg.t_cmid
      , i_inst_id             in     com_api_type_pkg.t_inst_id
      , i_host_id             in     com_api_type_pkg.t_tiny_id
      , i_network_id          in     com_api_type_pkg.t_tiny_id
      , i_standard_id         in     com_api_type_pkg.t_tiny_id
      , i_charset             in     com_api_type_pkg.t_oracle_name
      , i_session_file_id     in     com_api_type_pkg.t_long_id
      , i_local_file          in     com_api_type_pkg.t_boolean
    ) is
        l_pds_tab                    mcw_api_type_pkg.t_pds_tab;
        l_param_tab                  com_api_type_pkg.t_param_tab;
    begin
        o_file_rec.id := mcw_file_seq.nextval;

        o_file_rec.inst_id := i_inst_id;
        o_file_rec.network_id := i_network_id;
        o_file_rec.is_incoming := com_api_const_pkg.FALSE;
        o_file_rec.proc_date := com_api_sttl_day_pkg.get_sysdate();

        if i_session_file_id is null then
            register_session_file(
                o_session_file_id   => o_file_rec.session_file_id
              , i_inst_id           => i_inst_id
              , i_network_id        => i_network_id
              , i_cmid              => i_cmid
            );
        else
            o_file_rec.session_file_id := i_session_file_id;
        end if;

        o_file_rec.is_rejected := com_api_const_pkg.FALSE;

        o_file_rec.p0105 :=
            mcw_api_file_pkg.encode_p0105(
                i_cmid        => i_cmid
              , i_file_date   => o_file_rec.proc_date
              , i_inst_id     => i_inst_id
              , i_network_id  => i_network_id
              , i_host_id     => i_host_id
              , i_standard_id => i_standard_id
            );

        o_file_rec.p0122 :=
            nvl(
                cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id           => i_inst_id
                  , i_standard_id     => i_standard_id
                  , i_object_id       => i_host_id
                  , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name      => mcw_api_const_pkg.CLEARING_MODE
                  , i_param_tab       => l_param_tab
                )
              , mcw_api_const_pkg.CLEARING_MODE_DEFAULT
            );

        o_file_rec.p0301 := 0;
        o_file_rec.p0306 := 0;

        o_file_rec.header_mti := mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        o_file_rec.header_de024 := mcw_api_const_pkg.FUNC_CODE_HEADER;

        inc_file_totals (
            io_file_rec     => o_file_rec
            , i_count       => 1
        );

        o_file_rec.header_de071 := o_file_rec.p0306;

        o_file_rec.local_file := i_local_file;

        insert_file (
            i_file_rec      => o_file_rec
        );

        l_pds_tab(105) := o_file_rec.p0105;
        l_pds_tab(122) := o_file_rec.p0122;

        mcw_api_msg_pkg.pack_message (
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
        , i_trailer_mti         in mcw_api_type_pkg.t_mti
        , i_trailer_de024       in mcw_api_type_pkg.t_de024
        , i_trailer_de071       in mcw_api_type_pkg.t_de071
    ) is
    begin
        update mcw_file
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
        o_raw_data               out        com_api_type_pkg.t_raw_data
      , i_charset             in            com_api_type_pkg.t_oracle_name
      , io_file_rec           in out nocopy mcw_api_type_pkg.t_file_rec
    ) is
        l_pds_tab                           mcw_api_type_pkg.t_pds_tab;
    begin
        if io_file_rec.id is not null then
            inc_file_totals (
                io_file_rec     => io_file_rec
                , i_count       => 1
            );

            io_file_rec.trailer_mti := mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
            io_file_rec.trailer_de024 := mcw_api_const_pkg.FUNC_CODE_TRAILER;
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

            mcw_api_msg_pkg.pack_message (
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
      , i_inst_id               in com_api_type_pkg.t_inst_id      default null
      , i_charset               in com_api_type_pkg.t_oracle_name  default null
      , i_use_institution       in com_api_type_pkg.t_dict_value   default null
      , i_start_date            in date                            default null
      , i_end_date              in date                            default null
      , i_record_format         in com_api_type_pkg.t_dict_value   default null
      , i_include_affiliate     in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_create_disp_case      in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
    ) is
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
        l_msg_count             t_msg_count_tab;
        l_cmid                  com_api_type_pkg.t_cmid;
        l_fin_cur               mcw_api_type_pkg.t_fin_cur;
        l_fin_tab               mcw_api_type_pkg.t_fin_tab;
        l_raw_data              com_api_type_pkg.t_raw_data;
        l_file_rec              mcw_api_type_pkg.t_file_rec;
        l_file_line_num         com_api_type_pkg.t_long_id :=0;
        l_add_tab               mcw_api_type_pkg.t_add_tab;
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
        l_curr_standard_version com_api_type_pkg.t_tiny_id;

        procedure register_ok_upload (
            i_rowid    in     rowid
          , i_id       in     number
          , i_de071    in     number
          , i_file_id  in     number
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
            mcw_api_fin_pkg.mark_ok_uploaded (
                i_id                => l_ok_id
                , i_rowid           => l_ok_rowid
                , i_de071           => l_de071
                , i_file_id         => l_file_id
            );

            mcw_api_add_pkg.mark_uploaded (
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
            mcw_api_fin_pkg.mark_error_uploaded (
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
            i_text          => 'Starting IPM export'
        );

        prc_api_stat_pkg.log_start;

        l_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);
        
        l_curr_standard_version :=  
            cmn_api_standard_pkg.get_current_version(
                i_standard_id  => nvl(l_standard_id, mcw_api_const_pkg.MCW_STANDARD_ID)
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => coalesce(
                                      l_host_id
                                    , net_api_network_pkg.get_default_host(
                                          i_network_id  => mcw_api_const_pkg.MCW_NETWORK_ID
                                      )
                                  )
              , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
            );

        l_cmid := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => i_inst_id
            , i_standard_id => l_standard_id
            , i_object_id   => l_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => case
                               when nvl(i_use_institution, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
                                   mcw_api_const_pkg.CMID
                               else
                                   mcw_api_const_pkg.FORW_INST_ID
                               end
            , i_param_tab   => l_param_tab
        );

        savepoint ipm_start_new_file;

        l_excepted_count := 0;
        l_processed_count := 0;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => mcw_api_fin_pkg.estimate_messages_for_upload(
                                     i_network_id        => i_network_id
                                   , i_cmid              => l_cmid
                                   , i_inst_code         => i_use_institution
                                   , i_start_date        => trunc(i_start_date)
                                   , i_end_date          => trunc(i_end_date)
                                   , i_include_affiliate => i_include_affiliate
                                   , i_inst_id           => i_inst_id
                                 )
        );

        init_msg_count_tab(
            msg_count_tab   => l_msg_count
        );

        trc_log_pkg.debug (
            i_text          => 'enumerating messages'
        );

        mcw_api_fin_pkg.enum_messages_for_upload(
            o_fin_cur           => l_fin_cur
          , i_network_id        => i_network_id
          , i_cmid              => l_cmid
          , i_inst_code         => i_use_institution
          , i_start_date        => trunc(i_start_date)
          , i_end_date          => trunc(i_end_date)
          , i_include_affiliate => i_include_affiliate
          , i_inst_id           => i_inst_id
        );

        loop
            fetch l_fin_cur bulk collect into l_fin_tab limit BULK_LIMIT;

            for i in 1 .. l_fin_tab.count loop

                if l_file_rec.id is not null and l_local_message != nvl(l_fin_tab(i).local_message, 0) then
                    finish_logical_file;
                end if;

                if l_file_rec.id is null then
                    trc_log_pkg.debug (
                        i_text          => 'generating header'
                    );

                    savepoint ipm_start_new_logical_file;

                    if i_include_affiliate = com_api_const_pkg.TRUE
                        and i_inst_id is not null
                    then
                        if nvl(i_use_institution, mcw_api_const_pkg.UPLOAD_FORWARDING) = mcw_api_const_pkg.UPLOAD_FORWARDING then
                            l_fin_rec_cmid := l_fin_tab(i).de033;
                        else
                            l_fin_rec_cmid := l_fin_tab(i).de094;
                        end if;

                        generate_header(
                            o_raw_data            => l_raw_data
                          , o_file_rec            => l_file_rec
                          , i_cmid                => l_fin_rec_cmid
                          , i_inst_id             => l_fin_tab(i).inst_id
                          , i_network_id          => i_network_id
                          , i_host_id             => l_host_id
                          , i_standard_id         => l_standard_id
                          , i_charset             => i_charset
                          , i_session_file_id     => l_session_file_id
                          , i_local_file          => nvl(l_fin_tab(i).local_message, 0)
                        );
                    else
                        generate_header(
                            o_raw_data            => l_raw_data
                          , o_file_rec            => l_file_rec
                          , i_cmid                => l_cmid
                          , i_inst_id             => i_inst_id
                          , i_network_id          => i_network_id
                          , i_host_id             => l_host_id
                          , i_standard_id         => l_standard_id
                          , i_charset             => i_charset
                          , i_session_file_id     => l_session_file_id
                          , i_local_file          => nvl(l_fin_tab(i).local_message, 0)
                        );
                    end if;

                    l_session_file_id := l_file_rec.session_file_id;
                    l_local_message   := nvl(l_fin_tab(i).local_message, 0);

                    put_line(
                        i_line             => l_raw_data
                      , i_session_file_id  => l_file_rec.session_file_id
                      , io_record_number   => l_file_line_num
                    );
                end if;

                begin
                    savepoint ipm_start_new_record;

                    l_add_tab.delete;

                    l_fin_tab(i).de071 := l_file_rec.p0306 + 1;

                    mcw_api_fin_pkg.pack_message(
                        i_fin_rec               => l_fin_tab(i)
                      , i_file_id               => l_file_rec.id
                      , i_de071                 => l_fin_tab(i).de071
                      , i_curr_standard_version => l_curr_standard_version
                      , o_raw_data              => l_raw_data
                      , i_charset               => i_charset
                    );

                    put_line(
                        i_line            => l_raw_data
                      , i_session_file_id => l_file_rec.session_file_id
                      , io_record_number  => l_file_line_num
                    );

                    if      l_fin_tab(i).mti         = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                        and l_fin_tab(i).de024       = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
                        and l_fin_tab(i).is_reversal = com_api_const_pkg.FALSE
                    then
                        mcw_api_add_pkg.enum_messages_for_upload(
                            i_fin_id          => l_fin_tab(i).id
                          , o_add_tab         => l_add_tab
                        );

                        for k in 1 .. l_add_tab.count loop
                            l_add_tab(k).de071 := l_fin_tab(i).de071 + k;

                            mcw_api_add_pkg.pack_message(
                                i_add_rec    => l_add_tab(k)
                              , i_file_id    => l_file_rec.id
                              , i_de071      => l_add_tab(k).de071
                              , i_fin_de071  => l_fin_tab(i).de071
                              , o_raw_data   => l_raw_data
                              , i_charset    => i_charset
                            );

                            put_line (
                                i_line              => l_raw_data
                              , i_session_file_id   => l_file_rec.session_file_id
                              , io_record_number    => l_file_line_num
                            );
                        end loop;
                    end if;

                    if i_create_disp_case = com_api_const_pkg.TRUE then
                        if       l_fin_tab(i).mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                            or ( 
                                 l_fin_tab(i).mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                             and l_fin_tab(i).de024 in (
                                     mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                   , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
                                 )
                            )
                            or (
                                 l_fin_tab(i).mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                             and l_fin_tab(i).de024 in (
                                     mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
                                   , mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_RQ_ACKNOWL
                                 )
                            )
                        then
                            mcw_api_dispute_pkg.change_case_status(
                                i_dispute_id     => l_fin_tab(i).dispute_id
                              , i_mti            => l_fin_tab(i).mti
                              , i_de024          => l_fin_tab(i).de024
                              , i_is_reversal    => l_fin_tab(i).is_reversal
                              , i_reason_code    => l_fin_tab(i).de025
                              , i_msg_status     => net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
                              , i_msg_type       => l_fin_tab(i).msg_type
                            );
                        end if;
                    end if;

                    inc_file_totals(
                        io_file_rec       => l_file_rec
                      , i_amount          => l_fin_tab(i).de004
                      , i_count           => 1
                    );

                    inc_file_totals(
                        io_file_rec       => l_file_rec
                      , i_amount          => 0
                      , i_count           => l_add_tab.count
                    );

                    count_msg(
                        msg_count_tab     => l_msg_count
                      , mti               => l_fin_tab(i).mti
                      , de024             => l_fin_tab(i).de024
                      , msg_count         => 1
                    );

                    count_msg(
                        msg_count_tab     => l_msg_count
                      , mti               => mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                      , de024             => mcw_api_const_pkg.FUNC_CODE_ADDENDUM
                      , msg_count         => l_add_tab.count
                    );

                    register_ok_upload(
                        i_rowid       => l_fin_tab(i).row_id
                      , i_id          => l_fin_tab(i).id
                      , i_de071       => l_fin_tab(i).de071
                      , i_file_id     => l_file_rec.id
                    );

                    for k in 1 .. l_add_tab.count loop
                        register_add_upload(
                            i_rowid       => l_add_tab(k).row_id
                          , i_de071       => l_add_tab(k).de071
                          , i_fin_de071   => l_fin_tab(i).de071
                          , i_file_id     => l_file_rec.id
                        );
                    end loop;
                exception
                    when others then
                        if is_fatal_error(sqlcode) then
                            raise;

                        else
                            rollback to savepoint ipm_start_new_record;
                            register_error_upload(
                                i_rowid  => l_fin_tab(i).row_id
                            );

                            l_excepted_count := l_excepted_count + 1;
                        end if;
                end;

                check_ok_upload;
                check_error_upload;
            end loop;

            l_processed_count := l_processed_count + l_fin_tab.count;

            prc_api_stat_pkg.log_current(
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );

            exit when l_fin_cur%notfound;
        end loop;

        mark_ok_upload;
        mark_error_upload;

        finish_logical_file;

        prc_api_stat_pkg.log_end(
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
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

            trc_log_pkg.error(
                i_text          => sqlerrm
            );

            raise;
    end;

    function check_file_type (
        i_file_type             in mcw_api_type_pkg.t_pds_body
    ) return com_api_type_pkg.t_boolean is
        l_result                com_api_type_pkg.t_boolean;
    begin
        select com_api_const_pkg.TRUE
          into l_result
          from mcw_clear_centre_file_type
         where file_type = i_file_type
           and local_clearing_centre in (
                   mcw_api_const_pkg.LOCAL_CLEARING_CENTRE_NO
                 , set_ui_value_pkg.get_system_param_v(i_param_name => mcw_api_const_pkg.LOCAL_CLEARING_CENTRE)
               )
           and incoming = com_api_const_pkg.TRUE;

        return l_result;
    exception
        when others then
            return com_api_const_pkg.FALSE;
    end;

    function is_local_file (
        i_file_type             in mcw_api_type_pkg.t_pds_body
    ) return com_api_type_pkg.t_boolean is
        l_result com_api_type_pkg.t_boolean;
    begin
        select case when local_clearing_centre = mcw_api_const_pkg.LOCAL_CLEARING_CENTRE_NO
                    then com_api_const_pkg.FALSE
                    else com_api_const_pkg.TRUE
                end
          into l_result
          from mcw_clear_centre_file_type
         where file_type = i_file_type
           and incoming = com_api_const_pkg.TRUE;

        return l_result;
    end;

    procedure create_incoming_header (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , io_file_rec           in out nocopy mcw_api_type_pkg.t_file_rec
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_session_file_id     in com_api_type_pkg.t_long_id
        , i_rejected_amount     in out com_api_type_pkg.t_money
    ) is
        l_file_type            mcw_api_type_pkg.t_pds_body;
        l_file_date            date;
        l_cmid                 com_api_type_pkg.t_cmid;
        l_p0122                mcw_api_type_pkg.t_p0122;
        l_pds_tab              mcw_api_type_pkg.t_pds_tab;
        l_param_tab            com_api_type_pkg.t_param_tab;

        procedure set_trim_bin_from_param(
            i_inst_id           in com_api_type_pkg.t_inst_id
          , i_standard_id       in com_api_type_pkg.t_tiny_id
          , i_host_id           in com_api_type_pkg.t_tiny_id
        )
        is
            l_trim_bin      com_api_type_pkg.t_boolean := null;
            l_param_tab     com_api_type_pkg.t_param_tab;
        begin
            begin
                cmn_api_standard_pkg.get_param_value(
                    i_inst_id     => i_inst_id
                  , i_standard_id => i_standard_id
                  , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_object_id   => i_host_id
                  , i_param_name  => mcw_api_const_pkg.TRIM_LEAD_ZEROS
                  , i_param_tab   => l_param_tab
                  , o_param_value => l_trim_bin
                );

                set_trim_bin(
                    i_trim_bin => l_trim_bin
                );
            exception
                when com_api_error_pkg.e_application_error then
                    null;
            end;
        end;

    begin
        if io_file_rec.id is not null then
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_PREVIOUS_FILE_NOT_CLOSED'
            );
        else
            i_rejected_amount := 0;
            io_file_rec := null;

            io_file_rec.id := mcw_file_seq.nextval;
            io_file_rec.network_id := i_network_id;
            io_file_rec.proc_date := com_api_sttl_day_pkg.get_sysdate;

            io_file_rec.session_file_id := i_session_file_id;
            io_file_rec.is_rejected := com_api_const_pkg.FALSE;

            io_file_rec.p0301 := 0;
            io_file_rec.p0306 := 0;

            io_file_rec.header_mti := i_mes_rec.mti;
            io_file_rec.header_de024 := i_mes_rec.de024;
            io_file_rec.header_de071 := i_mes_rec.de071;

            mcw_api_pds_pkg.extract_pds (
                de048       => i_mes_rec.de048
                , de062     => i_mes_rec.de062
                , de123     => i_mes_rec.de123
                , de124     => i_mes_rec.de124
                , de125     => i_mes_rec.de125
                , pds_tab   => l_pds_tab
            );

            io_file_rec.p0105 := mcw_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0105
            );

            mcw_api_pds_pkg.parse_p0105 (
                i_p0105            => io_file_rec.p0105
                , o_file_type      => l_file_type
                , o_file_date      => l_file_date
                , o_cmid           => l_cmid
            );
            l_cmid := mcw_utl_pkg.pad_number (
                i_data          => l_cmid
                , i_min_length  => 6
                , i_max_length  => 6
            );

            if check_file_type (l_file_type) = com_api_const_pkg.TRUE then
                io_file_rec.is_incoming := com_api_const_pkg.TRUE;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'MCW_FILE_NOT_INBOUND_FOR_MEMBER'
                    , i_env_param1  => 'P0105'
                    , i_env_param2  => io_file_rec.p0105
                );
            end if;

            io_file_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
                i_standard_id         => i_standard_id
                , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_object_id         => i_host_id
                , i_param_name        => mcw_api_const_pkg.CMID
                , i_value_char        => l_cmid
            );

            if io_file_rec.inst_id is null then
                com_api_error_pkg.raise_error(
                    i_error         => 'MCW_CMID_NOT_REGISTRED'
                    , i_env_param1  => l_cmid
                    , i_env_param2  => i_network_id
                );
            end if;

            io_file_rec.p0122 := mcw_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0122
            );

            set_trim_bin_from_param(
                i_inst_id     => io_file_rec.inst_id
              , i_standard_id => i_standard_id
              , i_host_id     => i_host_id
            );

            l_p0122 :=
                nvl(
                    cmn_api_standard_pkg.get_varchar_value(
                        i_inst_id         => io_file_rec.inst_id
                      , i_standard_id     => i_standard_id
                      , i_object_id       => i_host_id
                      , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_HOST
                      , i_param_name      => mcw_api_const_pkg.CLEARING_MODE
                      , i_param_tab       => l_param_tab
                    )
                  , mcw_api_const_pkg.CLEARING_MODE_DEFAULT
                );

            if io_file_rec.p0122 <> l_p0122 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MCW_SYSTEM_CLEARING_MODE_DIFFERS'
                    , i_env_param1  => l_p0122
                    , i_env_param2  => io_file_rec.p0122
                    , i_env_param3  => io_file_rec.p0105
                );
            end if;

            if i_mes_rec.de071 <> 1 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MCW_HEADER_MUST_BE_FIRST_IN_FILE'
                    , i_env_param1  => i_mes_rec.de071
                    , i_env_param2  => io_file_rec.p0105
                );
            end if;

            io_file_rec.local_file := is_local_file (l_file_type);

            inc_file_totals (
                io_file_rec     => io_file_rec
                , i_count       => 1
            );

            insert_file (
                i_file_rec      => io_file_rec
            );
        end if;
    end;

    procedure create_incoming_trailer (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , io_file_rec           in out nocopy mcw_api_type_pkg.t_file_rec
        , i_rejected_amount     in com_api_type_pkg.t_money
    ) is
        l_pds_tab               mcw_api_type_pkg.t_pds_tab;
        l_p0105                 mcw_api_type_pkg.t_p0105;
        l_p0301                 mcw_api_type_pkg.t_p0301;
        l_p0306                 mcw_api_type_pkg.t_p0306;
    begin
        if io_file_rec.id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_FILE_TRAILER_FOUND_WITHOUT_PREV_HEADER'
            );
        else
            mcw_api_pds_pkg.extract_pds (
                de048       => i_mes_rec.de048
                , de062     => i_mes_rec.de062
                , de123     => i_mes_rec.de123
                , de124     => i_mes_rec.de124
                , de125     => i_mes_rec.de125
                , pds_tab   => l_pds_tab
            );

            l_p0105 := mcw_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0105
            );

            if io_file_rec.p0105 <> l_p0105 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MCW_FILE_ID_IN_TRAILER_DIFFERS_HEADER'
                    , i_env_param1  => l_p0105
                    , i_env_param2  => io_file_rec.p0105
                );
            end if;

            inc_file_totals (
                io_file_rec     => io_file_rec
                , i_count       => 1
            );

            l_p0301 := mcw_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0301
            );

            if not (nvl(l_p0301, 0) = io_file_rec.p0301
                    or
                    nvl(l_p0301, 0) = io_file_rec.p0301 + i_rejected_amount)
            then
                com_api_error_pkg.raise_error(
                    i_error         => 'MCW_FILE_AMOUNTS_NOT_ACTUAL'
                    , i_env_param1  => l_p0301
                    , i_env_param2  => io_file_rec.p0301
                    , i_env_param3  => io_file_rec.p0105
                );
            end if;

            l_p0306 := mcw_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mcw_api_const_pkg.PDS_TAG_0306
            );

            if l_p0306 <> io_file_rec.p0306 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MCW_ROW_COUNT_NOT_ACTUAL'
                    , i_env_param1  => l_p0306
                    , i_env_param2  => io_file_rec.p0306
                    , i_env_param3  => io_file_rec.p0105
                );
            end if;

            io_file_rec.trailer_mti := i_mes_rec.mti;
            io_file_rec.trailer_de024 := i_mes_rec.de024;
            io_file_rec.trailer_de071 := i_mes_rec.de071;

            update_file_totals(
                i_id            => io_file_rec.id,
                i_p0301         => io_file_rec.p0301,
                i_p0306         => io_file_rec.p0306,
                i_trailer_mti   => io_file_rec.trailer_mti,
                i_trailer_de024 => io_file_rec.trailer_de024,
                i_trailer_de071 => io_file_rec.trailer_de071
            );

            io_file_rec := null;
        end if;
    end;

    procedure unpack_message (
        i_raw_data          in com_api_type_pkg.t_raw_data
        , o_mes_rec         out mcw_api_type_pkg.t_mes_rec
        , i_charset         in com_api_type_pkg.t_oracle_name
    ) is
    begin
        o_mes_rec := null;
        mcw_api_msg_pkg.unpack_message (
            i_raw_data          => i_raw_data
            , o_mti             => o_mes_rec.mti
            , o_de002           => o_mes_rec.de002
            , o_de003_1         => o_mes_rec.de003_1
            , o_de003_2         => o_mes_rec.de003_2
            , o_de003_3         => o_mes_rec.de003_3
            , o_de004           => o_mes_rec.de004
            , o_de005           => o_mes_rec.de005
            , o_de006           => o_mes_rec.de006
            , o_de009           => o_mes_rec.de009
            , o_de010           => o_mes_rec.de010
            , o_de012           => o_mes_rec.de012
            , o_de014           => o_mes_rec.de014
            , o_de022_1         => o_mes_rec.de022_1
            , o_de022_2         => o_mes_rec.de022_2
            , o_de022_3         => o_mes_rec.de022_3
            , o_de022_4         => o_mes_rec.de022_4
            , o_de022_5         => o_mes_rec.de022_5
            , o_de022_6         => o_mes_rec.de022_6
            , o_de022_7         => o_mes_rec.de022_7
            , o_de022_8         => o_mes_rec.de022_8
            , o_de022_9         => o_mes_rec.de022_9
            , o_de022_10        => o_mes_rec.de022_10
            , o_de022_11        => o_mes_rec.de022_11
            , o_de022_12        => o_mes_rec.de022_12
            , o_de023           => o_mes_rec.de023
            , o_de024           => o_mes_rec.de024
            , o_de025           => o_mes_rec.de025
            , o_de026           => o_mes_rec.de026
            , o_de030_1         => o_mes_rec.de030_1
            , o_de030_2         => o_mes_rec.de030_2
            , o_de031           => o_mes_rec.de031
            , o_de032           => o_mes_rec.de032
            , o_de033           => o_mes_rec.de033
            , o_de037           => o_mes_rec.de037
            , o_de038           => o_mes_rec.de038
            , o_de040           => o_mes_rec.de040
            , o_de041           => o_mes_rec.de041
            , o_de042           => o_mes_rec.de042
            , o_de043_1         => o_mes_rec.de043_1
            , o_de043_2         => o_mes_rec.de043_2
            , o_de043_3         => o_mes_rec.de043_3
            , o_de043_4         => o_mes_rec.de043_4
            , o_de043_5         => o_mes_rec.de043_5
            , o_de043_6         => o_mes_rec.de043_6
            , o_de048           => o_mes_rec.de048
            , o_de049           => o_mes_rec.de049
            , o_de050           => o_mes_rec.de050
            , o_de051           => o_mes_rec.de051
            , o_de054           => o_mes_rec.de054
            , o_de055           => o_mes_rec.de055
            , o_de062           => o_mes_rec.de062
            , o_de063           => o_mes_rec.de063
            , o_de071           => o_mes_rec.de071
            , o_de072           => o_mes_rec.de072
            , o_de073           => o_mes_rec.de073
            , o_de093           => o_mes_rec.de093
            , o_de094           => o_mes_rec.de094
            , o_de095           => o_mes_rec.de095
            , o_de100           => o_mes_rec.de100
            , o_de111           => o_mes_rec.de111
            , o_de123           => o_mes_rec.de123
            , o_de124           => o_mes_rec.de124
            , o_de125           => o_mes_rec.de125
            , o_de127           => o_mes_rec.de127
            , i_charset         => i_charset
        );
    end;

    procedure count_amount (
        i_sttl_amount           in com_api_type_pkg.t_money
        , i_sttl_currency       in com_api_type_pkg.t_curr_code
    ) is
    begin
        if g_amount_tab.exists(nvl(i_sttl_currency, '')) then
            g_amount_tab(nvl(i_sttl_currency, '')) := nvl(g_amount_tab(nvl(i_sttl_currency, '')), 0) + i_sttl_amount;
        else
            g_amount_tab(nvl(i_sttl_currency, '')) := i_sttl_amount;
        end if;
    end;

    procedure info_amount is
        l_result                com_api_type_pkg.t_name;
    begin
        l_result := g_amount_tab.first;
        loop
            exit when l_result is null;

            trc_log_pkg.info(
                i_text          => 'Settlement currency [#1] amount [#2]'
              , i_env_param1    => l_result
              , i_env_param2    => com_api_currency_pkg.get_amount_str(
                                       i_amount          => g_amount_tab(l_result)
                                     , i_curr_code       => l_result
                                     , i_mask_curr_code  => com_api_const_pkg.TRUE
                                     , i_mask_error      => com_api_const_pkg.TRUE
                                   )
            );

            l_result := g_amount_tab.next(l_result);
        end loop;
    end;

    function process_message_with_dispute(
        i_mes_rec                 in     mcw_api_type_pkg.t_mes_rec
      , i_file_id                 in     com_api_type_pkg.t_short_id
      , i_incom_sess_file_id      in     com_api_type_pkg.t_long_id
      , io_fin_ref_id             in out com_api_type_pkg.t_long_id
      , i_network_id              in     com_api_type_pkg.t_tiny_id
      , i_host_id                 in     com_api_type_pkg.t_tiny_id
      , i_standard_id             in     com_api_type_pkg.t_tiny_id
      , i_local_message           in     com_api_type_pkg.t_boolean
      , i_create_operation        in     com_api_type_pkg.t_boolean
      , i_mes_rec_prev            in     mcw_api_type_pkg.t_mes_rec
      , i_inst_id                 in     com_api_type_pkg.t_inst_id
      , i_validate_record         in     com_api_type_pkg.t_boolean
      , i_need_repeat             in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
      , i_create_disp_case        in     com_api_type_pkg.t_boolean
      , i_register_loading_event  in     com_api_type_pkg.t_boolean
      , i_create_rev_reject       in     com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_boolean
    is
        l_message_processed              com_api_type_pkg.t_boolean     := com_api_const_pkg.TRUE;
        l_need_event                     com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE;
    begin
        savepoint sp_message_with_dispute;

        -- process incoming first presentment
        if ( i_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
             and i_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
        ) then
            mcw_api_fin_pkg.create_incoming_first_pres (
                i_mes_rec            => i_mes_rec
              , i_file_id            => i_file_id
              , i_incom_sess_file_id => i_incom_sess_file_id
              , o_fin_ref_id         => io_fin_ref_id
              , i_network_id         => i_network_id
              , i_host_id            => i_host_id
              , i_standard_id        => i_standard_id
              , i_local_message      => i_local_message
              , i_create_operation   => i_create_operation
              , i_validate_record    => i_validate_record
              , i_need_repeat        => i_need_repeat
              , i_create_disp_case   => i_create_disp_case
              , i_create_rev_reject  => i_create_rev_reject
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );
            if i_register_loading_event = com_api_const_pkg.TRUE then
                l_need_event := com_api_const_pkg.TRUE;
            end if;

        -- process addendum messages
        elsif ( i_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                and i_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_ADDENDUM
        ) then
            if ( (i_mes_rec_prev.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                  and i_mes_rec_prev.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES)
                  or
                 (i_mes_rec_prev.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                  and i_mes_rec_prev.de024 = mcw_api_const_pkg.FUNC_CODE_ADDENDUM)
            ) then
                if io_fin_ref_id is null then
                    raise mcw_api_dispute_pkg.e_need_original_record;
                end if;

                mcw_api_add_pkg.create_incoming_addendum(
                    i_mes_rec     => i_mes_rec
                  , i_file_id     => i_file_id
                  , i_fin_id      => io_fin_ref_id
                  , i_network_id  => i_network_id
                );

            else
                com_api_error_pkg.raise_error(
                    i_error           => 'MCW_ADDENDUM_MUST_ASSOCIATED_PRESENTMENT'
                );
            end if;

        -- process incoming retrieval request
        elsif ( i_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                and i_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
        ) then
            mcw_api_fin_pkg.create_incoming_retrieval (
                i_mes_rec            => i_mes_rec
              , i_file_id            => i_file_id
              , i_incom_sess_file_id => i_incom_sess_file_id
              , i_network_id         => i_network_id
              , i_host_id            => i_host_id
              , i_standard_id        => i_standard_id
              , i_local_message      => i_local_message
              , i_create_operation   => i_create_operation
              , i_need_repeat        => i_need_repeat
              , i_create_disp_case   => i_create_disp_case
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process incoming retrieval request acknowledgement
        elsif ( i_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                and i_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_RQ_ACKNOWL
        ) then
            mcw_api_fin_pkg.create_incoming_req_acknowl (
                i_mes_rec            => i_mes_rec
              , i_file_id            => i_file_id
              , i_incom_sess_file_id => i_incom_sess_file_id
              , i_network_id         => i_network_id
              , i_host_id            => i_host_id
              , i_standard_id        => i_standard_id
              , i_local_message      => i_local_message
              , i_create_operation   => i_create_operation
              , i_need_repeat        => i_need_repeat
              , i_create_disp_case   => i_create_disp_case
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process incoming second presentment
        elsif (i_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
               and i_mes_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                       , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
        ) then
            mcw_api_fin_pkg.create_incoming_second_pres (
                i_mes_rec            => i_mes_rec
              , i_file_id            => i_file_id
              , i_incom_sess_file_id => i_incom_sess_file_id
              , o_fin_ref_id         => io_fin_ref_id
              , i_network_id         => i_network_id
              , i_host_id            => i_host_id
              , i_standard_id        => i_standard_id
              , i_local_message      => i_local_message
              , i_create_operation   => i_create_operation
              , i_validate_record    => i_validate_record
              , i_need_repeat        => i_need_repeat
              , i_create_disp_case   => i_create_disp_case
              , i_create_rev_reject  => i_create_rev_reject
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );
            if i_register_loading_event = com_api_const_pkg.TRUE then
                l_need_event := com_api_const_pkg.TRUE;
            end if;

        -- process incoming chargeback
        elsif ( i_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                and i_mes_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                        , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                        , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                        , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
        ) then
            mcw_api_fin_pkg.create_incoming_chargeback (
                i_mes_rec            => i_mes_rec
              , i_file_id            => i_file_id
              , i_incom_sess_file_id => i_incom_sess_file_id
              , i_network_id         => i_network_id
              , i_host_id            => i_host_id
              , i_standard_id        => i_standard_id
              , i_local_message      => i_local_message
              , i_create_operation   => i_create_operation
              , i_validate_record    => i_validate_record
              , i_need_repeat        => i_need_repeat
              , i_create_disp_case   => i_create_disp_case
              , i_create_rev_reject  => i_create_rev_reject
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process incoming fee collection
        elsif ( i_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
                and i_mes_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
                                        , mcw_api_const_pkg.FUNC_CODE_FEE_RETURN
                                        , mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION
                                        , mcw_api_const_pkg.FUNC_CODE_FEE_SECOND_RETURN
                                        , mcw_api_const_pkg.FUNC_CODE_SYSTEM_FEE
                                        , mcw_api_const_pkg.FUNC_CODE_FUNDS_TRANSFER
                                        , mcw_api_const_pkg.FUNC_CODE_FUNDS_TRANS_BACK)
        ) then
            mcw_api_fin_pkg.create_incoming_fee (
                i_mes_rec            => i_mes_rec
              , i_file_id            => i_file_id
              , i_incom_sess_file_id => i_incom_sess_file_id
              , i_network_id         => i_network_id
              , i_host_id            => i_host_id
              , i_standard_id        => i_standard_id
              , i_local_message      => i_local_message
              , i_create_operation   => i_create_operation
              , i_need_repeat        => i_need_repeat
              , i_create_disp_case   => i_create_disp_case
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        else
            l_message_processed := com_api_const_pkg.FALSE;

        end if;

        if l_need_event = com_api_const_pkg.TRUE then
            for r in (
                select f.status
                     , p.split_hash
                  from mcw_fin f
                     , opr_participant p
                 where f.id               = io_fin_ref_id
                   and p.oper_id          = f.id
                   and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            ) loop
                evt_api_event_pkg.register_event(
                    i_event_type        => case
                                               when r.status = mcw_api_const_pkg.MSG_STATUS_INVALID
                                               then opr_api_const_pkg.EVENT_LOADED_WITH_ERRORS
                                               else opr_api_const_pkg.EVENT_LOADED_SUCCESSFULLY
                                           end
                  , i_eff_date          => get_sysdate
                  , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id         => io_fin_ref_id
                  , i_inst_id           => i_inst_id
                  , i_split_hash        => r.split_hash
                );
            end loop;
        end if;

        return l_message_processed;
    exception
        when mcw_api_dispute_pkg.e_need_original_record then
            rollback to savepoint sp_message_with_dispute;

            -- Save unprocessed record into buffer.
            g_no_original_rec_tab(g_no_original_rec_tab.count + 1).i_mes_rec        := i_mes_rec;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_file_id            := i_file_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_incom_sess_file_id := i_incom_sess_file_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_network_id         := i_network_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_host_id            := i_host_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_standard_id        := i_standard_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_local_message      := i_local_message;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_create_operation   := i_create_operation;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_mes_rec_prev       := i_mes_rec_prev;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_inst_id            := i_inst_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).io_fin_ref_id        := io_fin_ref_id;

            l_message_processed := com_api_const_pkg.TRUE;
            return l_message_processed;
    end;

    procedure load (
        i_network_id              in com_api_type_pkg.t_tiny_id
      , i_charset                 in com_api_type_pkg.t_oracle_name  default null
      , i_record_format           in com_api_type_pkg.t_dict_value   default null
      , i_create_operation        in com_api_type_pkg.t_boolean      default null
      , i_validate_records        in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_create_disp_case        in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_register_loading_event  in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_create_rev_reject       in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
    ) is
        LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load: ';

        l_register_loading_event     com_api_type_pkg.t_boolean  := nvl(i_register_loading_event, com_api_const_pkg.FALSE);
        l_create_disp_case           com_api_type_pkg.t_boolean  := nvl(i_create_disp_case,       com_api_const_pkg.FALSE);

        l_host_id                    com_api_type_pkg.t_tiny_id;
        l_standard_id                com_api_type_pkg.t_tiny_id;

        l_mes_rec_prev               mcw_api_type_pkg.t_mes_rec;
        l_mes_rec                    mcw_api_type_pkg.t_mes_rec;
        l_file_rec                   mcw_api_type_pkg.t_file_rec;

        l_raw_data                   com_api_type_pkg.t_raw_data;
        l_record_number              com_api_type_pkg.t_long_id;

        l_rejected_amount            com_api_type_pkg.t_money;
        l_fin_ref_id                 com_api_type_pkg.t_long_id;
        l_rejected_msg_found         com_api_type_pkg.t_boolean;

        l_estimated_count            com_api_type_pkg.t_long_id := 0;
        l_excepted_count             com_api_type_pkg.t_long_id := 0;
        l_processed_count            com_api_type_pkg.t_long_id := 0;

        l_data_cur              sys_refcursor;

        l_cursor_stmt           com_api_type_pkg.t_text :=
          ' select record_number
                 , raw_data
              from prc_file_raw_data
             where session_file_id = :session_file_id
          order by record_number '
        ;

        l_session_files         com_api_type_pkg.t_number_tab;

        procedure init_record is
        begin
            l_mes_rec_prev := l_mes_rec;
            l_mes_rec := null;
            l_record_number := null;
        end;

    begin
        savepoint ipm_start_load;

        trc_log_pkg.debug (
            i_text          => 'starting loading IPM'
        );

        prc_api_stat_pkg.log_start;

        g_amount_tab.delete;
        g_no_original_rec_tab.delete;
        mcw_api_fin_pkg.init_no_original_id_tab;

        -- get network communication standard
        l_host_id     := net_api_network_pkg.get_default_host(
                             i_network_id => i_network_id
                         );
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id    => l_host_id
                         );

        trc_log_pkg.debug (
            i_text          => 'enumerating messages'
        );
        -- estimate records for load
        select count(1)
          into l_estimated_count
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
             , prc_file_raw_data d
         where a.id              = s.file_attr_id
           and f.id              = a.file_id
           and f.file_purpose    = prc_api_file_pkg.get_file_purpose_in
           and s.session_id      = get_session_id
           and d.session_file_id = s.id;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        trc_log_pkg.debug (
            i_text         => 'Estimate records for load [#1]'
            , i_env_param1 => l_estimated_count
        );

        select id
          bulk collect into l_session_files
          from prc_session_file
         where session_id = get_session_id
         order by id;

        for i in 1 .. l_session_files.count loop

            l_record_number := null;
            l_raw_data      := null;
            l_mes_rec_prev  := null;
            l_mes_rec       := null;
            l_file_rec      := null;

            open l_data_cur for l_cursor_stmt using l_session_files(i);

            loop
                if l_record_number is null then
                    fetch l_data_cur into l_record_number, l_raw_data;
                end if;

                exit when l_data_cur%notfound;

                begin
                    savepoint ipm_start_new_record;

                    -- unpack message
                    unpack_message (
                        i_raw_data          => l_raw_data
                        , o_mes_rec         => l_mes_rec
                        , i_charset         => i_charset
                    );

                    -- processing by message type

                    -- process incoming header
                    if      l_mes_rec.mti   = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                        and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_HEADER
                    then
                        create_incoming_header(
                            i_mes_rec             => l_mes_rec
                          , io_file_rec           => l_file_rec
                          , i_network_id          => i_network_id
                          , i_host_id             => l_host_id
                          , i_standard_id         => l_standard_id
                          , i_session_file_id     => l_session_files(i)
                          , i_rejected_amount     => l_rejected_amount
                        );
                        init_record;

                    -- process incoming trailer
                    elsif l_mes_rec.mti   = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                      and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_TRAILER
                    then
                        create_incoming_trailer(
                            i_mes_rec          => l_mes_rec
                          , io_file_rec        => l_file_rec
                          , i_rejected_amount  => l_rejected_amount
                        );
                        init_record;

                    else
                        inc_file_totals (
                            io_file_rec        => l_file_rec
                          , i_amount           => l_mes_rec.de004
                          , i_count            => 1
                        );

                        -- process text message 693/1644 messages
                        if ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                             and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_TEXT
                        ) then
                            mcw_api_text_pkg.create_incoming_text (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process currency update messages
                        elsif ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_CURR_UPDATE
                        ) then
                            mcw_api_currency_pkg.create_incoming_currency (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process message types with dispute feature
                        elsif process_message_with_dispute(
                                i_mes_rec                => l_mes_rec
                              , i_file_id                => l_file_rec.id
                              , i_incom_sess_file_id     => l_session_files(i)
                              , io_fin_ref_id            => l_fin_ref_id
                              , i_network_id             => i_network_id
                              , i_host_id                => l_host_id
                              , i_standard_id            => l_standard_id
                              , i_local_message          => l_file_rec.local_file
                              , i_create_operation       => i_create_operation
                              , i_mes_rec_prev           => l_mes_rec_prev
                              , i_inst_id                => l_file_rec.inst_id
                              , i_validate_record        => i_validate_records
                              , i_need_repeat            => com_api_const_pkg.TRUE
                              , i_create_disp_case       => l_create_disp_case
                              , i_register_loading_event => l_register_loading_event
                              , i_create_rev_reject      => i_create_rev_reject
                              ) = com_api_const_pkg.TRUE
                        then
                            init_record;

                        -- process incoming file reject
                        elsif ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FILE_REJECT
                        ) then
                            mcw_api_reject_pkg.create_incoming_file_reject (
                                i_mes_rec             => l_mes_rec
                                , i_file_id           => l_file_rec.id
                                , i_network_id        => i_network_id
                                , i_host_id           => l_host_id
                                , i_standard_id       => l_standard_id
                                , i_create_rev_reject => i_create_rev_reject
                            );
                            init_record;

                        -- process incoming message reject
                        elsif ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_MSG_REJECT
                        ) then
                            init_record;

                            fetch l_data_cur into l_record_number, l_raw_data;

                            -- unpack message
                            unpack_message (
                                i_raw_data          => l_raw_data
                                , o_mes_rec         => l_mes_rec
                                , i_charset         => i_charset
                            );

                            mcw_api_reject_pkg.create_incoming_msg_reject (
                                i_mes_rec               => l_mes_rec_prev
                                , i_next_mes_rec        => l_mes_rec
                                , i_file_id             => l_file_rec.id
                                , i_network_id          => i_network_id
                                , i_host_id             => l_host_id
                                , i_standard_id         => l_standard_id
                                , i_validate_record     => i_validate_records
                                , o_rejected_msg_found  => l_rejected_msg_found
                                , i_create_rev_reject   => i_create_rev_reject
                            );

                            if l_rejected_msg_found = com_api_const_pkg.TRUE then
                                inc_file_totals (
                                    io_file_rec     => l_file_rec
                                    , i_count       => 1
                                );
                                l_rejected_amount := l_rejected_amount + nvl(l_mes_rec.de004, 0);
                                init_record;
                            end if;

                            l_processed_count := l_processed_count + 1;

                        -- process incoming file summary
                        elsif ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FILE_SUMMARY
                        ) then
                            mcw_api_fpd_pkg.create_incoming_fsum (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process incoming financial detail position
                        elsif ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FPD
                        ) then
                            mcw_api_fpd_pkg.create_incoming_fpd (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process incoming settlement detail position
                        elsif ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_SPD
                        ) then
                            mcw_api_fpd_pkg.create_incoming_spd (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MCW_UNKNOWN_MESSAGE'
                                , i_env_param1  => l_mes_rec.mti
                                , i_env_param2  => l_mes_rec.de024
                            );
                        end if;
                    end if;

                exception
                    when others then
                        if is_fatal_error(sqlcode) then
                            -- As far as re-raising error erases information about exception point,
                            -- it is necessary to store this information before re-rasing an exception
                            trc_log_pkg.debug(
                                i_text       => LOG_PREFIX || 'FAILED with sqlerrm: ' || CRLF || sqlerrm
                            );
                            raise;
                        else
                            -- process incoming header
                            if ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                 and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_HEADER
                            ) or
                            -- process incoming trailer
                            ( l_mes_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                              and l_mes_rec.de024 = mcw_api_const_pkg.FUNC_CODE_TRAILER
                            ) then
                                raise;
                            end if;

                            raise;

                            rollback to savepoint ipm_start_new_record;
                            init_record;

                            l_excepted_count := l_excepted_count + 1;
                        end if;
                end;

                l_processed_count := l_processed_count + 1;

                if mod(l_processed_count, BULK_LIMIT) = 0 then
                    prc_api_stat_pkg.log_current (
                        i_current_count  => l_processed_count
                      , i_excepted_count => l_excepted_count
                    );
                end if;
            end loop;
            close l_data_cur;
            prc_api_file_pkg.close_file(
                i_sess_file_id => l_session_files(i)
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count => nvl(l_processed_count, 0) + nvl(l_excepted_count, 0)
            );
        end loop;

        trc_log_pkg.debug (
            i_text         => 'g_no_original_rec_tab.count [#1]'
            , i_env_param1 => g_no_original_rec_tab.count
        );

        -- It is case when original record is later than reversal record in the same file.
        if g_no_original_rec_tab.count > 0 then
            for i in 1 .. g_no_original_rec_tab.count loop
                -- process message types with dispute feature
                if process_message_with_dispute(
                       i_mes_rec                => g_no_original_rec_tab(i).i_mes_rec
                     , i_file_id                => g_no_original_rec_tab(i).i_file_id
                     , i_incom_sess_file_id     => g_no_original_rec_tab(i).i_incom_sess_file_id
                     , io_fin_ref_id            => g_no_original_rec_tab(i).io_fin_ref_id
                     , i_network_id             => g_no_original_rec_tab(i).i_network_id
                     , i_host_id                => g_no_original_rec_tab(i).i_host_id
                     , i_standard_id            => g_no_original_rec_tab(i).i_standard_id
                     , i_local_message          => g_no_original_rec_tab(i).i_local_message
                     , i_create_operation       => g_no_original_rec_tab(i).i_create_operation
                     , i_mes_rec_prev           => g_no_original_rec_tab(i).i_mes_rec_prev
                     , i_inst_id                => g_no_original_rec_tab(i).i_inst_id
                     , i_validate_record        => i_validate_records
                     , i_need_repeat            => com_api_const_pkg.FALSE
                     , i_create_disp_case       => l_create_disp_case
                     , i_register_loading_event => l_register_loading_event
                     , i_create_rev_reject      => i_create_rev_reject
                   ) = com_api_const_pkg.TRUE
                then
                    null;
                end if;
            end loop;
        end if;

        info_amount;

        mcw_api_fin_pkg.process_no_original_id_tab;

        trc_log_pkg.debug (
            i_text          => 'finished loading IPM'
        );
        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint ipm_start_load;

            if l_data_cur%isopen then
                close l_data_cur;
            end if;

            prc_api_stat_pkg.log_end(
                i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end if;

            raise;
    end;

end mcw_prc_ipm_pkg;
/
