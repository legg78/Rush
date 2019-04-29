create or replace package body mup_prc_incoming_pkg is
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
    g_amount_tab    t_amount_count_tab;

    type t_no_original_rec_rec is record (
        i_mes_rec               mup_api_type_pkg.t_mes_rec
        , i_file_id             com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  com_api_type_pkg.t_long_id
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
          , is_returned
          , proc_bin
          , sttl_date
          , release_number
          , security_code
          , visa_file_id
          , batch_total
          , monetary_total
          , tcr_total
          , trans_total
          , src_amount
          , dst_amount
          , report_type
          , endpoint
          , de094
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
          , i_file_rec.is_returned
          , i_file_rec.proc_bin
          , i_file_rec.sttl_date
          , i_file_rec.release_number
          , i_file_rec.security_code
          , i_file_rec.visa_file_id
          , i_file_rec.batch_total
          , i_file_rec.monetary_total
          , i_file_rec.tcr_total
          , i_file_rec.trans_total
          , i_file_rec.src_amount
          , i_file_rec.dst_amount
          , i_file_rec.report_type
          , i_file_rec.endpoint
          , i_file_rec.de094
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'MUP_FILE_ALREADY_EXIST'
                , i_env_param1  => i_file_rec.p0105
                , i_env_param2  => i_file_rec.network_id
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

    function check_file_type (
        i_file_type             in mup_api_type_pkg.t_pds_body
    ) return com_api_type_pkg.t_boolean is
        l_result com_api_type_pkg.t_boolean;
    begin
        if i_file_type in (mup_api_const_pkg.FILE_TYPE_INC_CLEARING_MUP
                         , mup_api_const_pkg.FILE_TYPE_INC_EARLY_REJECT_MUP
                         , mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_CUP
                         , mup_api_const_pkg.FILE_TYPE_INC_EARLY_REJECT_CUP
                         , mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_JCB
                         , mup_api_const_pkg.FILE_TYPE_INC_EARLY_REJECT_JCB
                         , mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_AMX
                         , mup_api_const_pkg.FILE_TYPE_INC_EARLY_REJECT_AMX
                        ) then
            l_result := com_api_const_pkg.TRUE;
        else                
            l_result := com_api_const_pkg.FALSE;
        end if;    
        
        return l_result;
    exception
        when others then
            return com_api_const_pkg.FALSE;
    end;

    procedure create_incoming_header (
        i_mes_rec               in mup_api_type_pkg.t_mes_rec
        , io_file_rec           in out nocopy mup_api_type_pkg.t_file_rec
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_session_file_id     in com_api_type_pkg.t_long_id
        , i_rejected_amount     in out com_api_type_pkg.t_money
        , i_use_inst            in com_api_type_pkg.t_dict_value
    ) is
        l_file_type            mup_api_type_pkg.t_pds_body;
        l_file_date            date;
        l_cmid                 com_api_type_pkg.t_cmid;
        l_p0122                mup_api_type_pkg.t_p0122;
        l_pds_tab              mup_api_type_pkg.t_pds_tab;
        l_param_tab            com_api_type_pkg.t_param_tab;
    begin
        if io_file_rec.id is not null then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_PREVIOUS_FILE_NOT_CLOSED'
            );
        else
            i_rejected_amount           := 0;
            io_file_rec                 := null;

            io_file_rec.id              := mup_file_seq.nextval;
            io_file_rec.network_id      := i_network_id;
            io_file_rec.proc_date       := com_api_sttl_day_pkg.get_sysdate;

            io_file_rec.session_file_id := i_session_file_id;
            io_file_rec.is_rejected     := com_api_type_pkg.false;

            io_file_rec.p0301           := 0;
            io_file_rec.p0306           := 0;

            io_file_rec.header_mti      := i_mes_rec.mti;
            io_file_rec.header_de024    := i_mes_rec.de024;
            io_file_rec.header_de071    := i_mes_rec.de071;

            mup_api_pds_pkg.extract_pds (
                de048       => i_mes_rec.de048
                , de062     => i_mes_rec.de062
                , de123     => i_mes_rec.de123
                , de124     => i_mes_rec.de124
                , de125     => i_mes_rec.de125
                , pds_tab   => l_pds_tab
            );

            io_file_rec.p0105 := mup_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0105
            );

            mup_api_pds_pkg.parse_p0105 (
                i_p0105            => io_file_rec.p0105
                , o_file_type      => l_file_type
                , o_file_date      => l_file_date
                , o_cmid           => l_cmid
            );
            l_cmid := mup_utl_pkg.pad_number (
                i_data          => l_cmid
                , i_min_length  => 11
                , i_max_length  => 11
            );

            if check_file_type (l_file_type) = com_api_const_pkg.TRUE then
                io_file_rec.is_incoming := com_api_type_pkg.true;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_FILE_NOT_INBOUND_FOR_MEMBER'
                    , i_env_param1  => 'P0105'
                    , i_env_param2  => io_file_rec.p0105
                );
            end if;

            io_file_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
                i_standard_id         => i_standard_id
                , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_object_id         => i_host_id
                , i_param_name        => case
                                         when nvl(i_use_inst, mup_api_const_pkg.UPLOAD_FORWARDING) = mup_api_const_pkg.UPLOAD_FORWARDING then
                                             mup_api_const_pkg.FORW_INST_ID
                                         else
                                             mup_api_const_pkg.CMID
                                         end
                , i_value_char        => l_cmid
            );

            if io_file_rec.inst_id is null then
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_CMID_NOT_REGISTRED'
                    , i_env_param1  => l_cmid
                    , i_env_param2  => i_network_id
                );
            end if;

            io_file_rec.p0122 := mup_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0122
            );

            l_p0122 := nvl(cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id           => io_file_rec.inst_id
                    , i_standard_id     => i_standard_id
                    , i_object_id       => i_host_id
                    , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_HOST
                    , i_param_name      => mup_api_const_pkg.CLEARING_MODE
                    , i_param_tab       => l_param_tab
                ), mup_api_const_pkg.CLEARING_MODE_DEFAULT
            );

            if io_file_rec.p0122 <> l_p0122 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_SYSTEM_CLEARING_MODE_DIFFERS'
                    , i_env_param1  => l_p0122
                    , i_env_param2  => io_file_rec.p0122
                    , i_env_param3  => io_file_rec.p0105
                );
            end if;

            if i_mes_rec.de071 <> 1 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_HEADER_MUST_BE_FIRST_IN_FILE'
                    , i_env_param1  => i_mes_rec.de071
                    , i_env_param2  => io_file_rec.p0105
                );
            end if;

            --io_file_rec.local_file := is_local_file (l_file_type);

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
        i_mes_rec               in mup_api_type_pkg.t_mes_rec
        , io_file_rec           in out nocopy mup_api_type_pkg.t_file_rec
        , i_rejected_amount     in com_api_type_pkg.t_money
    ) is
        l_pds_tab               mup_api_type_pkg.t_pds_tab;
        l_p0105                 mup_api_type_pkg.t_p0105;
        l_p0301                 mup_api_type_pkg.t_p0301;
        l_p0306                 mup_api_type_pkg.t_p0306;
    begin
        if io_file_rec.id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_FILE_TRAILER_FOUND_WITHOUT_PREV_HEADER'
            );
        else
            mup_api_pds_pkg.extract_pds (
                de048       => i_mes_rec.de048
                , de062     => i_mes_rec.de062
                , de123     => i_mes_rec.de123
                , de124     => i_mes_rec.de124
                , de125     => i_mes_rec.de125
                , pds_tab   => l_pds_tab
            );

            l_p0105 := mup_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0105
            );

            if io_file_rec.p0105 <> l_p0105 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_FILE_ID_IN_TRAILER_DIFFERS_HEADER'
                    , i_env_param1  => l_p0105
                    , i_env_param2  => io_file_rec.p0105
                );
            end if;

            inc_file_totals (
                io_file_rec     => io_file_rec
                , i_count       => 1
            );

            l_p0301 := mup_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0301
            );

            if not (nvl(l_p0301, 0) = io_file_rec.p0301
                    or (nvl(l_p0301, 0) = io_file_rec.p0301 + i_rejected_amount)) then
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_FILE_AMOUNTS_NOT_ACTUAL'
                    , i_env_param1  => l_p0301
                    , i_env_param2  => io_file_rec.p0301
                    , i_env_param3  => io_file_rec.p0105
                );
            end if;

            l_p0306 := mup_api_pds_pkg.get_pds_body (
                i_pds_tab         => l_pds_tab
                , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0306
            );

            if l_p0306 <> io_file_rec.p0306 then
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_ROW_COUNT_NOT_ACTUAL'
                    , i_env_param1  => l_p0306
                    , i_env_param2  => io_file_rec.p0306
                    , i_env_param3  => io_file_rec.p0105
                );
            end if;

            io_file_rec.trailer_mti := i_mes_rec.mti;
            io_file_rec.trailer_de024 := i_mes_rec.de024;
            io_file_rec.trailer_de071 := i_mes_rec.de071;

            update_file_totals
            (   i_id            => io_file_rec.id,
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
        , o_mes_rec         out mup_api_type_pkg.t_mes_rec
        , i_charset         in com_api_type_pkg.t_oracle_name
    ) is
    begin
        o_mes_rec := null;
        mup_api_msg_pkg.unpack_message (
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
            , o_de123           => o_mes_rec.de123
            , o_de124           => o_mes_rec.de124
            , o_de125           => o_mes_rec.de125
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

            trc_log_pkg.info (
                i_text          => 'Settlement currency [#1] amount [#2]'
                , i_env_param1  => l_result
                , i_env_param2  =>
                    com_api_currency_pkg.get_amount_str (
                        i_amount            => g_amount_tab(l_result)
                        , i_curr_code       => l_result
                        , i_mask_curr_code  => get_true
                        , i_mask_error      => get_true
                    )
            );

            l_result := g_amount_tab.next(l_result);
        end loop;
    end;

    function process_message_with_dispute(
        i_mes_rec               in     mup_api_type_pkg.t_mes_rec
        , i_file_id             in     com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  in     com_api_type_pkg.t_long_id
        , io_fin_ref_id         in out com_api_type_pkg.t_long_id
        , i_network_id          in     com_api_type_pkg.t_tiny_id
        , i_host_id             in     com_api_type_pkg.t_tiny_id
        , i_standard_id         in     com_api_type_pkg.t_tiny_id
        , i_local_message       in     com_api_type_pkg.t_boolean
        , i_create_operation    in     com_api_type_pkg.t_boolean
        , i_mes_rec_prev        in     mup_api_type_pkg.t_mes_rec
        , i_need_repeat         in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_boolean
    is
        l_message_processed  com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE;
    begin
        savepoint sp_message_with_dispute;

        -- process incoming first presentment
        if (i_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
            and i_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES
        ) then
            mup_api_fin_pkg.create_incoming_first_pres (
                i_mes_rec             => i_mes_rec
              , i_file_id             => i_file_id
              , i_incom_sess_file_id  => i_incom_sess_file_id
              , o_fin_ref_id          => io_fin_ref_id
              , i_network_id          => i_network_id
              , i_host_id             => i_host_id
              , i_standard_id         => i_standard_id
              , i_local_message       => i_local_message
              , i_create_operation    => i_create_operation
              , i_need_repeat         => i_need_repeat
            );
            count_amount (
                i_sttl_amount        => i_mes_rec.de005
              , i_sttl_currency      => i_mes_rec.de050
            );

        -- process addendum messages
        elsif ( i_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                and i_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_ADDENDUM
        ) then
            if ( (i_mes_rec_prev.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
                  and i_mes_rec_prev.de024 = mup_api_const_pkg.FUNC_CODE_FIRST_PRES)
                  or
                 (i_mes_rec_prev.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                  and i_mes_rec_prev.de024 = mup_api_const_pkg.FUNC_CODE_ADDENDUM)
            ) then
                if io_fin_ref_id is null then
                    raise mup_api_dispute_pkg.e_need_original_record;
                end if;

                mup_api_add_pkg.create_incoming_addendum  (
                    i_mes_rec       => i_mes_rec
                    , i_file_id     => i_file_id
                    , i_fin_id      => io_fin_ref_id
                    , i_network_id  => i_network_id
                );

            else
                com_api_error_pkg.raise_error(
                    i_error           => 'MUP_ADDENDUM_MUST_ASSOCIATED_PRESENTMENT'
                );
            end if;

        -- process incoming retrieval request
        elsif ( i_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                and i_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
        ) then
            mup_api_fin_pkg.create_incoming_retrieval (
                i_mes_rec             => i_mes_rec
              , i_file_id             => i_file_id
              , i_incom_sess_file_id  => i_incom_sess_file_id
              , i_network_id          => i_network_id
              , i_host_id             => i_host_id
              , i_standard_id         => i_standard_id
              , i_local_message       => i_local_message
              , i_create_operation    => i_create_operation
              , i_need_repeat         => i_need_repeat
            );
            count_amount (
                i_sttl_amount         => i_mes_rec.de005
                , i_sttl_currency     => i_mes_rec.de050
            );

        -- process incoming second presentment
        elsif (i_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
               and i_mes_rec.de024 in (mup_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                       , mup_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
        ) then
            mup_api_fin_pkg.create_incoming_second_pres (
                i_mes_rec             => i_mes_rec
              , i_file_id             => i_file_id
              , i_incom_sess_file_id  => i_incom_sess_file_id
              , i_network_id          => i_network_id
              , i_host_id             => i_host_id
              , i_standard_id         => i_standard_id
              , i_local_message       => i_local_message
              , i_create_operation    => i_create_operation
              , i_need_repeat         => i_need_repeat
            );
            count_amount (
                i_sttl_amount         => i_mes_rec.de005
                , i_sttl_currency     => i_mes_rec.de050
            );

        -- process incoming adjustment
        elsif i_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
          and i_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
        then
            mup_api_fin_pkg.create_incoming_adjustment(
                i_mes_rec            => i_mes_rec
              , i_file_id            => i_file_id
              , i_incom_sess_file_id => i_incom_sess_file_id
              , o_fin_ref_id         => io_fin_ref_id
              , i_network_id         => i_network_id
              , i_host_id            => i_host_id
              , i_standard_id        => i_standard_id
              , i_local_message      => i_local_message
              , i_create_operation   => i_create_operation
              , i_need_repeat        => i_need_repeat
            );
            count_amount (
                i_sttl_amount        => i_mes_rec.de005
              , i_sttl_currency      => i_mes_rec.de050
            );

        -- process incoming chargeback
        elsif ( i_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_CHARGEBACK
                and i_mes_rec.de024 in (mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                        , mup_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                        , mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                        , mup_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
        ) then
            mup_api_fin_pkg.create_incoming_chargeback (
                i_mes_rec             => i_mes_rec
              , i_file_id             => i_file_id
              , i_incom_sess_file_id  => i_incom_sess_file_id
              , i_network_id          => i_network_id
              , i_host_id             => i_host_id
              , i_standard_id         => i_standard_id
              , i_local_message       => i_local_message
              , i_create_operation    => i_create_operation
              , i_need_repeat         => i_need_repeat
            );
            count_amount (
                i_sttl_amount         => i_mes_rec.de005
                , i_sttl_currency     => i_mes_rec.de050
            );

        -- process incoming fee collection
        elsif ( i_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_FEE
                and i_mes_rec.de024 in (mup_api_const_pkg.FUNC_CODE_MEMBER_FEE
                                        , mup_api_const_pkg.FUNC_CODE_FEE_RETURN
                                        , mup_api_const_pkg.FUNC_CODE_SYSTEM_FEE
                                        )
        ) then
            mup_api_fin_pkg.create_incoming_fee (
                i_mes_rec             => i_mes_rec
              , i_file_id             => i_file_id
              , i_incom_sess_file_id  => i_incom_sess_file_id
              , i_network_id          => i_network_id
              , i_host_id             => i_host_id
              , i_standard_id         => i_standard_id
              , i_local_message       => i_local_message
              , i_create_operation    => i_create_operation
              , i_need_repeat         => i_need_repeat
            );
            count_amount (
                i_sttl_amount         => i_mes_rec.de005
                , i_sttl_currency     => i_mes_rec.de050
            );

        else
            l_message_processed := com_api_type_pkg.FALSE;

        end if;
            
        return l_message_processed;
    exception
        when mup_api_dispute_pkg.e_need_original_record then
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
            g_no_original_rec_tab(g_no_original_rec_tab.count).io_fin_ref_id        := io_fin_ref_id;

            l_message_processed := com_api_type_pkg.TRUE;
            return l_message_processed;
    end;

    procedure load (
        i_network_id            in com_api_type_pkg.t_tiny_id
      , i_charset               in com_api_type_pkg.t_oracle_name := null
      , i_use_inst              in com_api_type_pkg.t_dict_value  := null
      , i_create_operation      in com_api_type_pkg.t_boolean     := null
    ) is
        LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load: ';
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;

        l_mes_rec_prev          mup_api_type_pkg.t_mes_rec;
        l_mes_rec               mup_api_type_pkg.t_mes_rec;
        l_file_rec              mup_api_type_pkg.t_file_rec;

        l_raw_data              com_api_type_pkg.t_raw_data;
        l_record_number         com_api_type_pkg.t_long_id;

        l_rejected_amount       com_api_type_pkg.t_money;
        l_fin_ref_id            com_api_type_pkg.t_long_id;
        l_rejected_msg_found    com_api_type_pkg.t_boolean;

        l_estimated_count       com_api_type_pkg.t_long_id := 0;
        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;

        l_data_cur              sys_refcursor;

        l_cursor_stmt           com_api_type_pkg.t_text :=
          ' select
                record_number
                , raw_data
            from
                prc_file_raw_data
            where
                session_file_id = :session_file_id
            order by
                record_number '
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
            i_text          => 'starting loading MUP'
        );

        prc_api_stat_pkg.log_start;

        g_amount_tab.delete;
        g_no_original_rec_tab.delete;
        mup_api_fin_pkg.init_no_original_id_tab;

        -- get network communication standard
        l_host_id     := net_api_network_pkg.get_default_host(
                             i_network_id => i_network_id
                         );
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id           => l_host_id
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
                    if ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                         and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_HEADER
                    ) then
                        create_incoming_header (
                            i_mes_rec               => l_mes_rec
                            , io_file_rec           => l_file_rec
                            , i_network_id          => i_network_id
                            , i_host_id             => l_host_id
                            , i_standard_id         => l_standard_id
                            , i_session_file_id     => l_session_files(i)
                            , i_rejected_amount     => l_rejected_amount
                            , i_use_inst            => i_use_inst
                        );
                        init_record;

                    -- process incoming trailer
                    elsif ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                            and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_TRAILER
                    ) then
                        create_incoming_trailer (
                            i_mes_rec            => l_mes_rec
                            , io_file_rec        => l_file_rec
                            , i_rejected_amount  => l_rejected_amount
                        );
                        init_record;

                    else
                        inc_file_totals (
                            io_file_rec         => l_file_rec
                            , i_amount          => l_mes_rec.de004
                            , i_count           => 1
                        );

                        -- process text message 693/1644 messages
                        if ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                             and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_TEXT
                        ) then
                            mup_api_text_pkg.create_incoming_text (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process message types with dispute feature
                        elsif process_message_with_dispute(
                                i_mes_rec              => l_mes_rec
                                , i_file_id            => l_file_rec.id
                                , i_incom_sess_file_id => l_session_files(i)
                                , io_fin_ref_id        => l_fin_ref_id
                                , i_network_id         => i_network_id
                                , i_host_id            => l_host_id
                                , i_standard_id        => l_standard_id
                                , i_local_message      => null--l_file_rec.local_file
                                , i_create_operation   => i_create_operation
                                , i_mes_rec_prev       => l_mes_rec_prev
                                , i_need_repeat        => com_api_type_pkg.TRUE
                              ) = com_api_type_pkg.TRUE
                        then
                            init_record;

                        -- process incoming file reject
                        elsif ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_FILE_REJECT
                        ) then
                            mup_api_reject_pkg.create_incoming_file_reject (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process incoming message reject
                        elsif ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_MSG_REJECT
                        ) then
                            init_record;

                            fetch l_data_cur into l_record_number, l_raw_data;

                            -- unpack message
                            unpack_message (
                                i_raw_data          => l_raw_data
                                , o_mes_rec         => l_mes_rec
                                , i_charset         => i_charset
                            );

                            mup_api_reject_pkg.create_incoming_msg_reject (
                                i_mes_rec               => l_mes_rec_prev
                                , i_next_mes_rec        => l_mes_rec
                                , i_file_id             => l_file_rec.id
                                , i_network_id          => i_network_id
                                , i_host_id             => l_host_id
                                , i_standard_id         => l_standard_id
                                , o_rejected_msg_found  => l_rejected_msg_found
                            );

                            if l_rejected_msg_found = com_api_type_pkg.TRUE then
                                l_rejected_amount := l_rejected_amount + nvl(l_mes_rec.de004, 0);
                                init_record;
                            end if;

                            l_processed_count := l_processed_count + 1;
                       
                        -- process incoming file summary
                        elsif ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_FILE_SUMMARY
                        ) then
                            mup_api_fpd_pkg.create_incoming_fsum (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process incoming financial detail position
                        elsif ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_FPD
                        ) then
                            mup_api_fpd_pkg.create_incoming_fpd (
                                i_mes_rec        => l_mes_rec
                                , i_file_id      => l_file_rec.id
                                , i_network_id   => i_network_id
                                , i_host_id      => l_host_id
                                , i_standard_id  => l_standard_id
                            );
                            init_record;

                        -- process incoming settlement detail position
                        elsif ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_NOTIFICATION
                                and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_SYSTEM_NTF
                        ) then
                            mup_api_fin_pkg.create_incoming_ntf (
                                i_mes_rec              => l_mes_rec
                                , i_file_id            => l_file_rec.id
                                , i_incom_sess_file_id => l_session_files(i)
                                , o_fin_ref_id         => l_fin_ref_id
                                , i_network_id         => i_network_id
                                , i_host_id            => l_host_id
                                , i_standard_id        => l_standard_id
                                , i_create_operation   => i_create_operation
                            );
                            init_record;
                        else
                          
                            com_api_error_pkg.raise_error(
                                i_error         => 'MUP_UNKNOWN_MESSAGE'
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
                            if ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                 and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_HEADER
                            ) or
                            -- process incoming trailer
                            ( l_mes_rec.mti = mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                              and l_mes_rec.de024 = mup_api_const_pkg.FUNC_CODE_TRAILER
                            ) then
                                raise;
                            end if;

                            rollback to savepoint ipm_start_new_record;
                            init_record;

                            l_excepted_count := l_excepted_count + 1;

                            raise;

                        end if;
                end;

                l_processed_count := l_processed_count + 1;

                if mod(l_processed_count, BULK_LIMIT) = 0 then
                    prc_api_stat_pkg.log_current (
                        i_current_count    => l_processed_count
                        , i_excepted_count => l_excepted_count
                    );
                end if;
            end loop;
            close l_data_cur;
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
                     i_mes_rec              => g_no_original_rec_tab(i).i_mes_rec
                     , i_file_id            => g_no_original_rec_tab(i).i_file_id
                     , i_incom_sess_file_id => g_no_original_rec_tab(i).i_incom_sess_file_id
                     , io_fin_ref_id        => g_no_original_rec_tab(i).io_fin_ref_id
                     , i_network_id         => g_no_original_rec_tab(i).i_network_id
                     , i_host_id            => g_no_original_rec_tab(i).i_host_id
                     , i_standard_id        => g_no_original_rec_tab(i).i_standard_id
                     , i_local_message      => g_no_original_rec_tab(i).i_local_message
                     , i_create_operation   => g_no_original_rec_tab(i).i_create_operation
                     , i_mes_rec_prev       => g_no_original_rec_tab(i).i_mes_rec_prev
                     , i_need_repeat        => com_api_type_pkg.FALSE
                   ) = com_api_type_pkg.TRUE
                 then
                     null;
                 end if;
            end loop;
        end if;

        info_amount;

        mup_api_fin_pkg.process_no_original_id_tab;

        trc_log_pkg.debug (
            i_text          => 'finished loading MUP'
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

procedure insert_trans_report(
    i_fin_rec        in     mup_api_type_pkg.t_fin_rec
  , i_file_rec       in     mup_api_type_pkg.t_file_rec
  , i_record_number  in     com_api_type_pkg.t_short_id
  , i_de022          in     com_api_type_pkg.t_name
  , i_p2158          in     com_api_type_pkg.t_name
  , i_p2159          in     com_api_type_pkg.t_name
) is
begin
    insert into mup_trans_rpt(
        id
      , inst_id
      , file_id
      , record_number
      , status
      , report_type
      , activity_type
      , de094
      , mti
      , de002
      , de003
      , de004
      , de005
      , de009
      , de012
      , de022
      , de024
      , de025
      , de026
      , de031
      , de037
      , de038
      , de040
      , de041
      , de042
      , de043_123
      , de043_4
      , de043_5
      , de043_6
      , p0025_1
      , p0105
      , p0146
      , p0148
      , p0165
      , p2158
      , orig_transfer_agent_id
      , p2159
      , de049
      , de050
      , de054
      , de063
      , de072
    ) values(
        i_fin_rec.id
      , i_fin_rec.inst_id
      , i_file_rec.id
      , i_record_number
      , i_fin_rec.status
      , i_file_rec.report_type
      , i_fin_rec.activity_type
      , i_fin_rec.de094
      , i_fin_rec.mti
      , i_fin_rec.de002
      , i_fin_rec.de003_1 || i_fin_rec.de003_2 || i_fin_rec.de003_3
      , i_fin_rec.de004
      , i_fin_rec.de005
      , i_fin_rec.de009
      , i_fin_rec.de012
      , i_de022
      , i_fin_rec.de024
      , i_fin_rec.de025
      , i_fin_rec.de026
      , i_fin_rec.de031
      , i_fin_rec.de037
      , i_fin_rec.de038
      , i_fin_rec.de040
      , i_fin_rec.de041
      , i_fin_rec.de042
      , i_fin_rec.de043_1 || i_fin_rec.de043_2 || i_fin_rec.de043_3
      , i_fin_rec.de043_4
      , i_fin_rec.de043_5
      , i_fin_rec.de043_6
      , i_fin_rec.p0025_1
      , to_date(i_fin_rec.p0105, 'yymmdd')
      , i_fin_rec.p0146
      , i_fin_rec.p0148
      , i_fin_rec.p0165
      , i_p2158
      , i_fin_rec.orig_transfer_agent_id
      , i_p2159
      , i_fin_rec.de049
      , i_fin_rec.de050
      , i_fin_rec.de054
      , i_fin_rec.de063
      , i_fin_rec.de072
    );
end;

procedure load_participant_trans_report(
    i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_network_id  in     com_api_type_pkg.t_network_id
) is
    LOG_PREFIX   constant  com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load_participant_trans_report: ';
    l_session_files        com_api_type_pkg.t_number_tab;
    l_estimated_count      com_api_type_pkg.t_long_id;
    l_raw_data             com_api_type_pkg.t_raw_data;
    l_file_rec             mup_api_type_pkg.t_file_rec;
    l_fin_rec              mup_api_type_pkg.t_fin_rec;
    l_processed_count      com_api_type_pkg.t_long_id;
    l_total_count          com_api_type_pkg.t_long_id;    
    l_data_rec_count       com_api_type_pkg.t_long_id;
    l_de022                com_api_type_pkg.t_name;
    l_p2158                com_api_type_pkg.t_name;
    l_p2159                com_api_type_pkg.t_name;
    l_trailer_record_count com_api_type_pkg.t_long_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_cmid                 com_api_type_pkg.t_cmid;
    l_acquirer_bin         com_api_type_pkg.t_bin;
    l_host_id              com_api_type_pkg.t_tiny_id;
    l_standard_id          com_api_type_pkg.t_tiny_id;
    l_auth                 aut_api_type_pkg.t_auth_rec;
    l_original_fin_rec     mup_api_type_pkg.t_fin_rec;

    function get_field_v (
        i_start   in     pls_integer
      , i_length  in     pls_integer
    ) return varchar2 is
    begin
        return aci_api_util_pkg.get_field_char (
            i_raw_data     => l_raw_data
            , i_start_pos  => i_start
            , i_length     => i_length
        );
    end;

    function get_field_n (
        i_start   in     pls_integer
      , i_length  in     pls_integer
    ) return number is
    begin
        return trim(to_number(substr(l_raw_data, i_start, i_length), com_api_const_pkg.XML_NUMBER_FORMAT) );
    end;

    function get_field_d (
        i_start   in     pls_integer
      , i_length  in     pls_integer
    ) return date is
    begin
        return trim(to_date(substr(l_raw_data, i_start, i_length), 'ddmmyyhh24miss') );
    end;

    function get_field_d (
        i_start   in     pls_integer
      , i_length  in     pls_integer
      , i_fmt     in     com_api_type_pkg.t_name
    ) return date is
    begin
        trc_log_pkg.debug('get_field_d: '|| substr(l_raw_data, i_start, i_length));
        return aci_api_util_pkg.get_field_date (
            i_raw_data   => l_raw_data
          , i_start_pos  => i_start
          , i_length     => i_length
          , i_fmt        => i_fmt
        );
    end;
begin
    savepoint trans_start_load;
    l_host_id := net_api_network_pkg.get_default_host(i_network_id => i_network_id);

    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    trc_log_pkg.debug (
        i_text          => LOG_PREFIX|| ' starting loading MUP participant trans report, host_id= '
    );

    trc_log_pkg.debug (
        i_text       => LOG_PREFIX|| ' inst_id [#1], network_id [#2] host_id [#3] standard_id [#4]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_network_id
      , i_env_param3 => l_host_id
      , i_env_param4 => l_standard_id
    );
    
   prc_api_stat_pkg.log_start;

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

    trc_log_pkg.debug( i_text => LOG_PREFIX|| 'get_session_id='||get_session_id||', purp='||prc_api_file_pkg.get_file_purpose_in);

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    trc_log_pkg.debug (
        i_text         => LOG_PREFIX|| 'Estimate records for load [#1]'
        , i_env_param1 => l_estimated_count
    );

    select id
      bulk collect into l_session_files
      from prc_session_file
     where session_id = get_session_id
     order by id;

    trc_log_pkg.debug( i_text => LOG_PREFIX|| l_session_files.count||' session files found');

    for i in 1..l_session_files.count loop
        l_raw_data      := null;
        l_fin_rec       := null;
        l_file_rec      := null;
        trc_log_pkg.debug(LOG_PREFIX || 'process file '||l_session_files(i));

        l_processed_count := 0;
        l_data_rec_count  := 0;
        for rec in (
            select record_number
                 , raw_data
              from prc_file_raw_data
             where session_file_id = l_session_files(i)
          order by record_number 
        )loop
            l_raw_data := rec.raw_data;

            trc_log_pkg.debug(LOG_PREFIX || 'process line ' || rec.record_number);

            l_processed_count := nvl(l_processed_count, 0) + 1;
            l_total_count     := nvl(l_total_count, 0) + 1;
            if l_raw_data like 'H%' then
              -- header record
                l_file_rec      := null;
                l_file_rec.id               := mup_file_seq.nextval;
                l_file_rec.report_type      := get_field_v(1, 7);
                l_file_rec.de094            := get_field_v(8, 11);
                
                l_cmid := 
                    cmn_api_standard_pkg.get_varchar_value (
                        i_inst_id     => i_inst_id
                      , i_standard_id => l_standard_id
                      , i_object_id   => l_host_id
                      , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                      , i_param_name  => mup_api_const_pkg.CMID
                      , i_param_tab   => l_param_tab
                  );

                l_acquirer_bin := 
                      cmn_api_standard_pkg.get_varchar_value (
                        i_inst_id     => i_inst_id
                      , i_standard_id => l_standard_id
                      , i_object_id   => l_host_id
                      , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                      , i_param_name  => mup_api_const_pkg.ACQUIRER_BIN
                      , i_param_tab   => l_param_tab
                  );

                if l_file_rec.de094 not in (l_cmid, l_acquirer_bin) then
                    com_api_error_pkg.raise_error(
                        i_error => 'MUP_ERROR_WRONG_VALUE'
                      , i_env_param1 => 'de094'
                      , i_env_param2 => l_file_rec.de094
                      , i_env_param3 => l_cmid||','||l_acquirer_bin
                    );
                end if;

                l_file_rec.endpoint         := get_field_v(19, 7);
                l_file_rec.inst_id          := i_inst_id;
                l_file_rec.network_id       := i_network_id;
                l_file_rec.proc_date        := com_api_sttl_day_pkg.get_sysdate;
                l_file_rec.session_file_id  := l_session_files(i);
                l_file_rec.is_rejected      := com_api_type_pkg.FALSE;
                l_file_rec.is_incoming      := com_api_type_pkg.TRUE;

                insert_file(i_file_rec => l_file_rec);

            elsif l_raw_data like 'T%' then
              -- footer record
                l_trailer_record_count := get_field_n(26, 12);

                if l_trailer_record_count != l_data_rec_count then
                    com_api_error_pkg.raise_error(
                        i_error      => 'MUP_ROW_COUNT_NOT_ACTUAL'
                      , i_env_param1 => l_trailer_record_count
                      , i_env_param2 => l_data_rec_count
                      , i_env_param3 => l_fin_rec.p0105
                    );
                   
                end if;
            else
                l_data_rec_count          := nvl(l_data_rec_count, 0) + 1;
                l_fin_rec                 := null;
                -- main record
                l_fin_rec.id              := opr_api_create_pkg.get_id(i_host_date => get_sysdate);
                l_fin_rec.inst_id         := i_inst_id;
                l_fin_rec.file_id         := l_file_rec.id;
                l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;

                l_fin_rec.activity_type   := get_field_v(1,   2);
                l_fin_rec.de094           := get_field_n(3,   11);
                l_fin_rec.mti             := get_field_n(14,  4);
                l_fin_rec.de002           := get_field_v(18,  19);
                l_fin_rec.de003_1         := get_field_n(37,  2);
                l_fin_rec.de003_2         := get_field_n(39,  2);
                l_fin_rec.de003_3         := get_field_n(41,  2);
                l_fin_rec.de004           := get_field_n(43,  12);
                l_fin_rec.de005           := get_field_n(55,  12);
                l_fin_rec.de009           := get_field_v(67,  11);
                l_fin_rec.de012           := get_field_d(78,  12, 'yymmddhh24miss');
                l_de022                   := get_field_v(90,  12);
                l_fin_rec.de024           := get_field_n(102, 3);
                l_fin_rec.de025           := get_field_n(105, 4);
                l_fin_rec.de026           := get_field_n(109, 4);
                l_fin_rec.de031           := get_field_v(113, 23);
                l_fin_rec.de037           := get_field_v(136, 12);
                l_fin_rec.de038           := get_field_v(148, 6);
                l_fin_rec.de040           := get_field_n(154, 3);
                l_fin_rec.de041           := get_field_v(157, 8);
                l_fin_rec.de042           := get_field_v(165, 15);
                l_fin_rec.de043_1         := get_field_v(180, 85);
                l_fin_rec.de043_4         := get_field_v(265, 10);
                l_fin_rec.de043_5         := get_field_v(275, 3);
                l_fin_rec.de043_6         := get_field_v(278, 3);
                l_fin_rec.p0025_1         := get_field_v(281, 1);
                l_fin_rec.p0105           := get_field_n(282, 6);
                l_fin_rec.p0146           := get_field_v(288, 36);
                l_fin_rec.p0148           := get_field_v(324, 4);
                l_fin_rec.p0165           := get_field_v(328, 30);
                l_p2158                   := get_field_v(358, 18);
                l_fin_rec.orig_transfer_agent_id := get_field_n(376, 11);
                l_p2159                   := get_field_v(387, 25);
                l_fin_rec.de049           := get_field_n(412, 3);
                l_fin_rec.de050           := get_field_n(415, 3);
                l_fin_rec.de054           := get_field_v(418, 20);
                l_fin_rec.de063           := get_field_v(438, 16);
                l_fin_rec.de072           := get_field_v(454, 100);

                if      l_raw_data like 'A%'
                    and l_fin_rec.mti = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
                    and l_fin_rec.de024 = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
                then
                    l_fin_rec.p0375           := l_fin_rec.de031;
                    l_fin_rec.status          := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
                    l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
                    l_fin_rec.is_reversal     := com_api_const_pkg.FALSE;

                    l_fin_rec.is_rejected     := com_api_const_pkg.FALSE;
                    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
                    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;

                    mup_api_dispute_pkg.assign_dispute_id(
                        io_fin_rec => l_fin_rec
                      , o_auth     => l_auth
                    );

                    trc_log_pkg.debug(
                        i_text          => LOG_PREFIX || 'dispute_id [#1] l_auth.id[#2]'
                      , i_env_param1    => l_fin_rec.dispute_id
                      , i_env_param2    => l_auth.id
                    );

                    mup_api_fin_pkg.put_message(
                        i_fin_rec       => l_fin_rec
                    );

                    mup_api_fin_pkg.create_operation(
                        i_fin_rec       => l_fin_rec
                       ,i_standard_id   => l_standard_id
                       ,i_auth          => l_auth
                       ,i_host_id       => l_host_id
                   );
                end if;

                insert_trans_report(
                    i_fin_rec       => l_fin_rec
                  , i_file_rec      => l_file_rec
                  , i_record_number => rec.record_number
                  , i_de022         => l_de022
                  , i_p2158         => l_p2158
                  , i_p2159         => l_p2159
                );
            end if;
        end loop;

        prc_api_file_pkg.close_file(
            i_sess_file_id => l_session_files(i)
          , i_status       =>  prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count => l_processed_count
        );

    end loop;

    if l_estimated_count is null then
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => 0
        );
    end if;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => 0
      , i_processed_total   => l_total_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to savepoint trans_start_load;

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

end;
/
