create or replace package body mcw_prc_mdes_pkg is

    BULK_LIMIT         constant integer := 400;

    g_record_number             com_api_type_pkg.t_integer_tab;
    g_raw_data                  com_api_type_pkg.t_raw_tab;

    type t_rec_r311 is record
    (   
        mti                     mcw_api_type_pkg.t_mti
      , de002                   mcw_api_type_pkg.t_de002
      , de007                   varchar2(10)
      , de011                   varchar2(6)
      , de033                   mcw_api_type_pkg.t_de033
      , de063                   mcw_api_type_pkg.t_de063
      , de091                   varchar2(1)
      , de096                   com_api_type_pkg.t_dict_value
      , de101                   varchar2(17)
      , de120                   varchar2(999)
      , de127                   mcw_api_type_pkg.t_de127
      , card_id                 com_api_type_pkg.t_medium_id
      , token_id                com_api_type_pkg.t_medium_id
      , event_object_id         com_api_type_pkg.t_long_id
      , event_type              com_api_type_pkg.t_dict_value
    );

    type t_cur_r311 is ref cursor return t_rec_r311;

    procedure upload_bulk_r311 (
        i_inst_id            in com_api_type_pkg.t_inst_id
    ) is

        LOG_PREFIX              constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || ': ';                
    
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
        l_cmid                  com_api_type_pkg.t_cmid;
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;
        l_r311_cur              t_cur_r311;
        l_r311_rec              t_rec_r311;
        l_raw_data              com_api_type_pkg.t_raw_data;
        l_file_rec              mcw_api_type_pkg.t_file_rec;
        l_network_id            com_api_type_pkg.t_tiny_id;
        l_session_file_id       com_api_type_pkg.t_long_id;
        l_file_line_num         com_api_type_pkg.t_long_id :=0;
        l_sysdate               date;

        function estimate_messages_for_upload (
            i_inst_id               in com_api_type_pkg.t_inst_id
        ) return number is
            l_result                number;
        begin
            select count(*)
              into l_result
              from evt_event_object eo
                 , iss_card_token ct
                 , iss_card c 
             where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'MCW_PRC_MDES_PKG.UPLOAD_BULK_R311'
               and eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN
               and eo.eff_date   <= l_sysdate
               and eo.split_hash in (select split_hash from com_api_split_map_vw)
               and ct.id          = eo.object_id + 0
               and c.id           = ct.card_id
               and c.inst_id      = i_inst_id;
               
            return l_result;
        end estimate_messages_for_upload;

        procedure enum_messages_for_upload (
            o_fin_cur                  out sys_refcursor
          , i_inst_id               in     com_api_type_pkg.t_inst_id
          , i_cmid                  in     com_api_type_pkg.t_cmid
        ) is
        begin
            open o_fin_cur for 
                select null         as mti
                     , iss_api_token_pkg.decode_card_number(c.card_number) as de002
                     , null         as de007
                     , rownum       as de011
                     , i_cmid       as de033
                     , null         as de063
                     , null         as de091
                     , null         as de096
                     , null         as de101
                     , null         as de120
                     , null         as de127
                     , c.id         as card_id
                     , eo.object_id as token_id
                     , eo.id        as event_object_id
                     , ct.event_type
                  from evt_event_object eo
                     , iss_card_token ct
                     , iss_card_vw c 
                 where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'MCW_PRC_MDES_PKG.UPLOAD_BULK_R311'
                   and eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN
                   and eo.eff_date   <= l_sysdate
                   and eo.split_hash in (select split_hash from com_api_split_map_vw)
                   and ct.id          = eo.object_id + 0
                   and c.id           = ct.card_id
                   and c.inst_id      = i_inst_id;
                   
        end enum_messages_for_upload;

        procedure register_session_file (
            o_session_file_id      out com_api_type_pkg.t_long_id
          , i_inst_id           in     com_api_type_pkg.t_inst_id
          , i_network_id        in     com_api_type_pkg.t_tiny_id
          , i_cmid              in     com_api_type_pkg.t_cmid
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
                , i_file_type   => mcw_api_const_pkg.FILE_TYPE_MDES_BULK_R311
                , io_params     => l_params
            );
        end register_session_file;
        
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
        end insert_file;

        procedure update_file_totals (
            i_id                    in com_api_type_pkg.t_short_id
          , i_p0301                 in number
          , i_p0306                 in number
          , i_trailer_mti           in mcw_api_type_pkg.t_mti
          , i_trailer_de024         in mcw_api_type_pkg.t_de024
          , i_trailer_de071         in mcw_api_type_pkg.t_de071
        ) is
        begin
            update mcw_file
               set p0301         = i_p0301
                 , p0306         = i_p0306
                 , trailer_mti   = i_trailer_mti
                 , trailer_de024 = i_trailer_de024
                 , trailer_de071 = i_trailer_de071
             where id = i_id;
        end;

        procedure inc_file_totals (
            io_file_rec             in out nocopy mcw_api_type_pkg.t_file_rec
          , i_amount                in number := 0
          , i_count                 in number := 1
        ) is
        begin
            if io_file_rec.id is not null then
                io_file_rec.p0306 := nvl(io_file_rec.p0306, 0) + nvl(i_count, 0);
                io_file_rec.p0301 := nvl(io_file_rec.p0301, 0) + nvl(i_amount, 0);
            end if;
        end inc_file_totals;  

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
        end flush_file;
        
        function bin2hex(i_bin varchar2) return varchar2 as
            l_bin    varchar2(2000) := i_bin;
            l_return varchar2(2000);
            l_len    integer;
            l_char   char(1);
            l_ival   integer;
            l_bitval integer;
            digits   varchar2(16) := '0123456789ABCDEF';
        begin
            l_len := length(i_bin) / 4;
            for i in 0 .. l_len - 1 loop
                l_bin    := substr(i_bin, i * 4 + 1, 4);
                l_ival   := 0;
                l_bitval := 8;
                for bit in 1 .. 4 loop
                    l_char := substr(l_bin, bit, 1);
                    if l_char = '1' then
                        l_ival := l_ival + l_bitval;
                    end if;
                    l_bitval := l_bitval / 2;
                end loop;
                l_return := l_return || substr(digits, l_ival + 1, 1);
            end loop;
            return l_return;
        end bin2hex;

        procedure put_line (
            i_line                  in     com_api_type_pkg.t_raw_data
          , i_session_file_id       in     com_api_type_pkg.t_long_id
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
        end put_line;

        procedure generate_header
        (   o_raw_data                 out com_api_type_pkg.t_raw_data
          , o_file_rec                 out mcw_api_type_pkg.t_file_rec
          , i_cmid                  in     com_api_type_pkg.t_cmid
          , i_inst_id               in     com_api_type_pkg.t_inst_id
          , i_host_id               in     com_api_type_pkg.t_tiny_id
          , i_network_id            in     com_api_type_pkg.t_tiny_id
          , i_standard_id           in     com_api_type_pkg.t_tiny_id
          , i_session_file_id       in     com_api_type_pkg.t_long_id
        ) is
            LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_header: ';
            l_line                  com_api_type_pkg.t_raw_data;
        begin
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'start with cmid [#1], inst_id [#2], host_id [#3], network_id [#4], standard_id [#5], session_file_id [#6]'
              , i_env_param1 => i_cmid
              , i_env_param2 => i_inst_id
              , i_env_param3 => i_host_id
              , i_env_param4 => i_network_id
              , i_env_param5 => i_standard_id
              , i_env_param6 => i_session_file_id
            );
            
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
        
            o_file_rec.id          := mcw_file_seq.nextval;

            o_file_rec.header_mti  := '0001';
            o_file_rec.inst_id     := i_inst_id;
            o_file_rec.network_id  := i_network_id;
            o_file_rec.is_incoming := com_api_type_pkg.false;
            o_file_rec.proc_date   := get_sysdate;
            
            o_file_rec.p0301 := 0;
            o_file_rec.p0306 := 0;

            inc_file_totals (
                io_file_rec   => o_file_rec
              , i_count       => 1
            );

            o_file_rec.header_de071 := o_file_rec.p0306;

            o_file_rec.is_rejected  := com_api_type_pkg.false;

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
                        i_inst_id         => i_inst_id
                      , i_standard_id     => i_standard_id
                      , i_object_id       => i_host_id
                      , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_HOST
                      , i_param_name      => mcw_api_const_pkg.CLEARING_MODE
                      , i_param_tab       => l_param_tab
                    )
                  , mcw_api_const_pkg.CLEARING_MODE_DEFAULT
                );
            
            insert_file (
                i_file_rec      => o_file_rec
            );
            
            l_line := l_line || '0001';                            -- record type id
            l_line := l_line || lpad(ltrim(l_cmid, '0'), 6, '0');  -- customer id
            l_line := l_line || to_char(get_sysdate, 'YYMMDD');    -- transmition date
            l_line := l_line || to_char(get_sysdate, 'HH24MM');    -- transmition time
            l_line := l_line || 'U';                               -- input file type: U - update
            l_line := l_line || rpad(' ', 279, ' ');               -- filler
            
            o_raw_data := l_line;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'finish!'
            );
        end generate_header;
        
        procedure generate_record(
            o_raw_data                 out com_api_type_pkg.t_raw_data
          , i_r311_rec              in     t_rec_r311
          , io_file_rec             in out nocopy mcw_api_type_pkg.t_file_rec
        ) is
            LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_record: ';
            l_r311_rec              t_rec_r311;
            l_mapping_file_ind      varchar2(1)  := 'A';   -- Mapping File Indicator
            l_action_required       varchar2(1);           -- Action Required (S = Suspend token, D = Deactivate token, C = Resume token) 
            l_nwsp_ind              number(1)    := 0;     -- Notify Wallet Service Provider indicator
            l_token                 varchar2(19) := null;  -- Token - if updating a specific token
            l_bit_mask              com_api_type_pkg.t_raw_data;
        begin
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'start uploading evt_event_object.id [#1]!'
              , i_env_param1 => i_r311_rec.event_object_id
            );

            l_action_required := case i_r311_rec.event_type
                                     when iss_api_const_pkg.EVENT_TYPE_TOKEN_SUSPEND then
                                         'S'
                                     when iss_api_const_pkg.EVENT_TYPE_TOKEN_DEACTIVEATE then
                                         'D'
                                     when iss_api_const_pkg.EVENT_TYPE_TOKEN_RESUME then
                                         'C'
                                     else
                                         'D'
                                 end;

            l_r311_rec.mti   := '0302';
            l_r311_rec.de002 := i_r311_rec.de002;
            l_r311_rec.de007 := to_char(get_sysdate, 'YYMMDDHH24MM');
            l_r311_rec.de011 := i_r311_rec.de011;
            l_r311_rec.de033 := lpad(ltrim(i_r311_rec.de033, '0'), 6, '0');
            l_r311_rec.de063 := i_r311_rec.de063;
            l_r311_rec.de091 := 2;
            l_r311_rec.de096 := '00000000';
            l_r311_rec.de101 := 'MCC106';

            -- DE 120 Layout for MCC106 MasterCard Digital Enablement Service (PAN Update - Deactivate/Suspend/Resume Token)
            l_r311_rec.de120 := l_mapping_file_ind || l_action_required || l_nwsp_ind || l_token;
            l_r311_rec.de127 := i_r311_rec.de127;
            
            l_bit_mask := '1100001000100000000000000000000010000000000000000000000000000010000000000000000000000000001000010000100000000000000000010000001';
            l_bit_mask := bin2hex(l_bit_mask);
            l_bit_mask := utl_raw.cast_to_varchar2(l_bit_mask);

            o_raw_data := null;
            o_raw_data := o_raw_data || l_r311_rec.mti;
            o_raw_data := o_raw_data || l_bit_mask;
            o_raw_data := o_raw_data || l_r311_rec.de002;
            o_raw_data := o_raw_data || l_r311_rec.de007;
            o_raw_data := o_raw_data || l_r311_rec.de011;
            o_raw_data := o_raw_data || l_r311_rec.de033;
            o_raw_data := o_raw_data || l_r311_rec.de063;
            o_raw_data := o_raw_data || l_r311_rec.de091;
            o_raw_data := o_raw_data || l_r311_rec.de096;
            o_raw_data := o_raw_data || l_r311_rec.de101;
            o_raw_data := o_raw_data || l_r311_rec.de120;
            o_raw_data := o_raw_data || l_r311_rec.de127;

            inc_file_totals (
                io_file_rec     => io_file_rec
              , i_count         => 1
            );
            
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'o_raw_data [#1]'
              , i_env_param1 => o_raw_data
            );
            
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'finish!'
            );
        end generate_record;
        
        procedure generate_trailer (
            o_raw_data               out com_api_type_pkg.t_raw_data
          , io_file_rec           in out nocopy mcw_api_type_pkg.t_file_rec
        ) is
            LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_trailer: ';
            l_line                  com_api_type_pkg.t_raw_data;
        begin
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'start!'
            );

            inc_file_totals (
                io_file_rec     => io_file_rec
              , i_count         => 1
            );
            
            io_file_rec.trailer_mti   := '9999';
            io_file_rec.trailer_de071 := io_file_rec.p0306;

            update_file_totals(
                i_id            => io_file_rec.id
              , i_p0301         => io_file_rec.p0301
              , i_p0306         => io_file_rec.p0306
              , i_trailer_mti   => io_file_rec.trailer_mti
              , i_trailer_de024 => io_file_rec.trailer_de024
              , i_trailer_de071 => io_file_rec.trailer_de071
            );
            
            l_line := l_line || io_file_rec.trailer_mti;           -- record type id
            l_line := l_line || lpad(ltrim(l_cmid, '0'), 6, '0');  -- customer id
            l_line := l_line || lpad(io_file_rec.p0306,  6, '0');  -- number or detail records in file
            l_line := l_line || rpad(' ', 284, ' ');               -- filler
            
            o_raw_data := l_line;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'finish!'
            );
        end generate_trailer;

        procedure finish_file is
        begin
            if l_file_rec.p0306 > 1 then
                generate_trailer (
                    o_raw_data    => l_raw_data
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
        savepoint r311_start_upload;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'starting uploading bulk R311 with inst_id [#1]'
          , i_env_param1 => i_inst_id
        );

        prc_api_stat_pkg.log_start;

        l_sysdate     := get_sysdate;

        l_network_id  := mcw_api_const_pkg.MCW_NETWORK_ID;
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_network_id);
        l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

        l_cmid := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id       => i_inst_id
            , i_standard_id => l_standard_id
            , i_object_id   => l_host_id
            , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_param_name  => mcw_api_const_pkg.CMID
            , i_param_tab   => l_param_tab
        ); 

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => estimate_messages_for_upload (
                                     i_inst_id     => i_inst_id
                                 )
        );
        
        trc_log_pkg.debug (
            i_text          => 'enumerating messages'
        );
        
        enum_messages_for_upload (
            o_fin_cur       => l_r311_cur
          , i_inst_id       => i_inst_id
          , i_cmid          => l_cmid
        );
        
        if l_r311_cur%isopen then
            loop
                fetch l_r311_cur into l_r311_rec;
                exit when l_r311_cur%notfound;
                
                if l_file_rec.id is null then
                    generate_header(
                        o_raw_data            => l_raw_data
                      , o_file_rec            => l_file_rec
                      , i_cmid                => l_cmid
                      , i_inst_id             => i_inst_id
                      , i_network_id          => l_network_id
                      , i_host_id             => l_host_id
                      , i_standard_id         => l_standard_id
                      , i_session_file_id     => l_session_file_id
                    );
                    
                    l_session_file_id := l_file_rec.session_file_id;
                    l_file_line_num := 1;

                    put_line (
                        i_line                => l_raw_data
                      , i_session_file_id     => l_file_rec.session_file_id
                      , io_record_number      => l_file_line_num
                    );
                end if;
                
                begin
                    generate_record(
                        o_raw_data            => l_raw_data
                      , i_r311_rec            => l_r311_rec
                      , io_file_rec           => l_file_rec
                    );

                    put_line (
                        i_line                => l_raw_data
                      , i_session_file_id     => l_file_rec.session_file_id
                      , io_record_number      => l_file_line_num
                    );
                    
                    l_processed_count := l_processed_count + 1;
                    
                    evt_api_event_pkg.process_event_object(
                        i_event_object_id    => l_r311_rec.event_object_id
                    );
                exception
                    when com_api_error_pkg.e_application_error then
                        trc_log_pkg.debug(
                            i_text       => 'generate_record FAILED for card_number [#1], card_id [#2]'
                          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => l_r311_rec.de002)
                          , i_env_param2 => l_r311_rec.card_id
                        );

                        l_excepted_count := l_excepted_count + 1;
                end;

            end loop;
        end if;
        
        finish_file;

        prc_api_stat_pkg.log_end(
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'finish!'
        ); 

    exception
        when others then
            rollback to savepoint r311_start_upload;

            prc_api_stat_pkg.log_end(
                i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
                or
                com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            then
                raise;
            else
                com_api_error_pkg.raise_fatal_error(
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;
    end upload_bulk_r311;

end;
/
