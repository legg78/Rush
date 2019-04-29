create or replace package body jcb_prc_incoming_pkg is
/********************************************************* 
 *  JCB incoming and outgoing files API  <br /> 
 *  Created by Khougaev (khougaev@bpcbt.com)  at 23.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: jcb_prc_ipm_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

    type            t_amount_count_tab is table of integer index by com_api_type_pkg.t_curr_code;

    BULK_LIMIT      constant integer := 400;
    CRLF            constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);

    g_amount_tab    t_amount_count_tab;

    type t_no_original_rec_rec is record (
        i_mes_rec               jcb_api_type_pkg.t_mes_rec
        , i_file_id             com_api_type_pkg.t_short_id
        , i_incom_sess_file_id  com_api_type_pkg.t_long_id
        , i_network_id          com_api_type_pkg.t_tiny_id
        , i_host_id             com_api_type_pkg.t_tiny_id
        , i_standard_id         com_api_type_pkg.t_tiny_id
        , i_create_operation    com_api_type_pkg.t_boolean
        , i_mes_rec_prev        jcb_api_type_pkg.t_mes_rec
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
    
    function check_file_type (
        i_p3901_1             in jcb_api_type_pkg.t_pds_body
    ) return com_api_type_pkg.t_boolean is
        l_result com_api_type_pkg.t_boolean;
    begin
        if i_p3901_1 in (jcb_api_const_pkg.FILE_TYPE_INC_CLEARING
                       , jcb_api_const_pkg.FILE_TYPE_VERIFICATION_RESULT
                       , jcb_api_const_pkg.FILE_TYPE_SETTLEMENT_RESULT) then
                       
           l_result := com_api_const_pkg.TRUE;
        else
           l_result := com_api_const_pkg.FALSE;
                       
        end if;
        
        return l_result;
    end;

    procedure create_incoming_header (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , io_file_rec           in out nocopy jcb_api_type_pkg.t_file_rec
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_session_file_id     in com_api_type_pkg.t_long_id
    ) is
        l_pds_tab              jcb_api_type_pkg.t_pds_tab;
        l_param_tab            com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
            i_text          => 'create header start'
        );
        if io_file_rec.id is not null then
        
            com_api_error_pkg.raise_error(
                i_error         => 'JCB_PREVIOUS_FILE_NOT_CLOSED'
            );
        else
            io_file_rec := null;

            io_file_rec.id              := jcb_file_seq.nextval;
            io_file_rec.network_id      := i_network_id;
            io_file_rec.proc_date       := com_api_sttl_day_pkg.get_sysdate;

            io_file_rec.session_file_id := i_session_file_id;
            io_file_rec.is_rejected     := com_api_type_pkg.false;

            io_file_rec.header_mti      := i_mes_rec.mti;
            io_file_rec.header_de024    := i_mes_rec.de024;
            io_file_rec.header_de071    := i_mes_rec.de071;
            io_file_rec.header_de100    := i_mes_rec.de100;
            io_file_rec.header_de033    := i_mes_rec.de033;

            jcb_api_pds_pkg.extract_pds (
                de048       => i_mes_rec.de048
                , de062     => i_mes_rec.de062
                , de123     => i_mes_rec.de123
                , de124     => i_mes_rec.de124
                , de125     => i_mes_rec.de125
                , de126     => i_mes_rec.de126
                , pds_tab   => l_pds_tab
            );
            
            io_file_rec.p3901 := jcb_api_pds_pkg.get_pds_body (
                i_pds_tab   => l_pds_tab
                , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3901
            );            
            
            jcb_api_pds_pkg.parse_p3901 (   
                i_p3901      => io_file_rec.p3901
                , o_p3901_1  => io_file_rec.p3901_1
                , o_p3901_2  => io_file_rec.p3901_2
                , o_p3901_3  => io_file_rec.p3901_3
                , o_p3901_4  => io_file_rec.p3901_4
            );
            
            io_file_rec.p3901_3 := jcb_utl_pkg.pad_number (
                i_data          => io_file_rec.p3901_3
                , i_min_length  => 11
                , i_max_length  => 11
            );
            
            if check_file_type (i_p3901_1 => io_file_rec.p3901_1) = com_api_const_pkg.TRUE then
                io_file_rec.is_incoming := com_api_type_pkg.true;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'JCB_FILE_NOT_INBOUND_FOR_MEMBER'
                    , i_env_param1  => 'P3901'
                    , i_env_param2  => io_file_rec.p3901
                );
            end if;            
            
            io_file_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
                i_standard_id         => i_standard_id
                , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_object_id         => i_host_id
                , i_param_name        => jcb_api_const_pkg.CMID
                , i_value_char        => trim(leading '0' from io_file_rec.p3901_3)
            );

            if io_file_rec.inst_id is null then
            
                com_api_error_pkg.raise_error(
                    i_error         => 'JCB_CMID_NOT_REGISTRED'
                    , i_env_param1  => io_file_rec.p3901_3
                    , i_env_param2  => i_network_id
                );
            end if;
            
            if i_mes_rec.de071 <> 1 then
            
                com_api_error_pkg.raise_error(
                    i_error         => 'JCB_HEADER_MUST_BE_FIRST_IN_FILE'
                    , i_env_param1  => i_mes_rec.de071
                );
            end if;
            
            io_file_rec.p3902 := 0;
            io_file_rec.p3903 := 0;
            
            inc_file_totals (
                io_file_rec     => io_file_rec
                , i_count       => 1
            );

            insert_file (
                i_file_rec      => io_file_rec
            );
            
        end if;
        
        trc_log_pkg.debug (
            i_text          => 'create header end'
        );
    end;

    procedure create_incoming_trailer (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , io_file_rec           in out nocopy jcb_api_type_pkg.t_file_rec
    ) is
        l_pds_tab               jcb_api_type_pkg.t_pds_tab;
        l_p3901                 jcb_api_type_pkg.t_p3901;
        l_p3902                 jcb_api_type_pkg.t_p3902;
        l_p3903                 jcb_api_type_pkg.t_p3903;
    begin
        trc_log_pkg.debug (
            i_text          => 'create trailer start'
        );

        if io_file_rec.id is null then
        
            com_api_error_pkg.raise_error(
                i_error         => 'JCB_FILE_TRAILER_FOUND_WITHOUT_PREV_HEADER'
            );
        else
            jcb_api_pds_pkg.extract_pds (
                de048       => i_mes_rec.de048
                , de062     => i_mes_rec.de062
                , de123     => i_mes_rec.de123
                , de124     => i_mes_rec.de124
                , de125     => i_mes_rec.de125
                , de126     => i_mes_rec.de126
                , pds_tab   => l_pds_tab
            );

            l_p3901 := jcb_api_pds_pkg.get_pds_body (
                i_pds_tab   => l_pds_tab
                , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3901
            );            
            
            if io_file_rec.p3901 <> l_p3901 then
            
                com_api_error_pkg.raise_error(
                    i_error         => 'JCB_FILE_ID_IN_TRAILER_DIFFERS_HEADER'
                    , i_env_param1  => l_p3901
                    , i_env_param2  => io_file_rec.p3901
                );
            end if;

            inc_file_totals (
                io_file_rec => io_file_rec
                , i_count   => 1
            );

            l_p3902 := jcb_api_pds_pkg.get_pds_body (
                i_pds_tab   => l_pds_tab
                , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3902
            );

            if nvl(l_p3902, 0) != io_file_rec.p3902 then --without rejects!
                com_api_error_pkg.raise_error(
                    i_error         => 'JCB_FILE_AMOUNTS_NOT_ACTUAL'
                    , i_env_param1  => l_p3902
                    , i_env_param2  => io_file_rec.p3902
                    , i_env_param3  => io_file_rec.p3901
                );
            end if;
            
            l_p3903 := jcb_api_pds_pkg.get_pds_body (
                i_pds_tab   => l_pds_tab
                , i_pds_tag => jcb_api_const_pkg.PDS_TAG_3903
            );

            if l_p3903 <> io_file_rec.p3903 then
                com_api_error_pkg.raise_error(
                    i_error         => 'JCB_ROW_COUNT_NOT_ACTUAL'
                    , i_env_param1  => l_p3903
                    , i_env_param2  => io_file_rec.p3903
                    , i_env_param3  => io_file_rec.p3901
                );
            end if;            
            
            io_file_rec.trailer_mti   := i_mes_rec.mti;
            io_file_rec.trailer_de024 := i_mes_rec.de024;
            io_file_rec.trailer_de071 := i_mes_rec.de071;
            io_file_rec.trailer_de100 := i_mes_rec.de100;
            io_file_rec.trailer_de033 := i_mes_rec.de033;

            update_file_totals (
                i_id              => io_file_rec.id
                , i_p3902         => io_file_rec.p3902
                , i_p3903         => io_file_rec.p3903
                , i_trailer_mti   => io_file_rec.trailer_mti
                , i_trailer_de024 => io_file_rec.trailer_de024
                , i_trailer_de071 => io_file_rec.trailer_de071
            );

            io_file_rec := null;
            
        end if;

        trc_log_pkg.debug (
            i_text          => 'create trailer end'
        );
        
    end;

    procedure unpack_message (
        i_file              in blob
        , i_with_rdw        in com_api_type_pkg.t_boolean    default null
        , io_curr_pos       in out nocopy com_api_type_pkg.t_long_id
        , o_mes_rec         out jcb_api_type_pkg.t_mes_rec
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'io_curr_pos [#1]'
            , i_env_param1  => io_curr_pos
        );
        o_mes_rec := null;
        jcb_api_msg_pkg.unpack_message (
            i_file              => i_file
            , i_with_rdw        => i_with_rdw
            , io_curr_pos       => io_curr_pos
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
            , o_de016           => o_mes_rec.de016
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
            , o_de071           => o_mes_rec.de071
            , o_de072           => o_mes_rec.de072
            , o_de093           => o_mes_rec.de093
            , o_de094           => o_mes_rec.de094
            , o_de097           => o_mes_rec.de097
            , o_de100           => o_mes_rec.de100    
            , o_de123           => o_mes_rec.de123    
            , o_de124           => o_mes_rec.de124    
            , o_de125           => o_mes_rec.de125    
            , o_de126           => o_mes_rec.de126    
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
                        , i_mask_curr_code  => com_api_type_pkg.TRUE
                        , i_mask_error      => com_api_type_pkg.TRUE
                    )
            );

            l_result := g_amount_tab.next(l_result);
        end loop;
    end;

    function process_message_with_dispute(
        i_mes_rec                   in jcb_api_type_pkg.t_mes_rec
        , i_file_id                 in com_api_type_pkg.t_short_id
        , i_incom_sess_file_id      in com_api_type_pkg.t_long_id
        , io_fin_ref_id         in out com_api_type_pkg.t_long_id
        , i_network_id              in com_api_type_pkg.t_tiny_id
        , i_host_id                 in com_api_type_pkg.t_tiny_id
        , i_standard_id             in com_api_type_pkg.t_tiny_id
        , i_create_operation        in com_api_type_pkg.t_boolean
        , i_mes_rec_prev            in jcb_api_type_pkg.t_mes_rec
        , i_need_repeat             in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_boolean
    is
        l_message_processed  com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE;
    begin
        trc_log_pkg.debug (
            i_text          => 'process message start: i_need_repeat='|| i_need_repeat
        );
        savepoint sp_message_with_dispute;

        -- process incoming first presentment
        if i_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT and i_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES then

            jcb_api_fin_pkg.create_incoming_first_pres (
                i_mes_rec              => i_mes_rec
                , i_file_id            => i_file_id
                , i_incom_sess_file_id => i_incom_sess_file_id
                , o_fin_ref_id         => io_fin_ref_id
                , i_network_id         => i_network_id
                , i_host_id            => i_host_id
                , i_standard_id        => i_standard_id
                , i_create_operation   => i_create_operation
                , i_need_repeat        => i_need_repeat
            );
                       
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process addendum messages
        elsif i_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE and i_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_ADDENDUM then
        
            if ( 
                 (i_mes_rec_prev.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT and i_mes_rec_prev.de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES)
                  or
                 (i_mes_rec_prev.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE and i_mes_rec_prev.de024 = jcb_api_const_pkg.FUNC_CODE_ADDENDUM)
            ) then
            
                if io_fin_ref_id is null then

                    raise jcb_api_dispute_pkg.e_need_original_record;
                end if;

                jcb_api_add_pkg.create_incoming_addendum  (
                    i_mes_rec       => i_mes_rec
                    , i_file_id     => i_file_id
                    , i_fin_id      => io_fin_ref_id
                    , i_network_id  => i_network_id
                );
                null;

            else
                com_api_error_pkg.raise_error(
                    i_error           => 'JCB_ADDENDUM_MUST_ASSOCIATED_PRESENTMENT'
                );
            end if;

        -- process incoming retrieval request
        elsif i_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE and i_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST then
        
            jcb_api_fin_pkg.create_incoming_retrieval (
                i_mes_rec              => i_mes_rec
                , i_file_id            => i_file_id
                , i_incom_sess_file_id => i_incom_sess_file_id
                , i_network_id         => i_network_id
                , i_host_id            => i_host_id
                , i_standard_id        => i_standard_id
                , i_create_operation   => i_create_operation
                , i_need_repeat        => i_need_repeat
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process incoming acknowledgement
        elsif i_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_ACKNOWLEDGMENT and i_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_ACKNOWLEDGMENT then
        
            jcb_api_fin_pkg.create_incoming_req_acknowl (
                i_mes_rec              => i_mes_rec
                , i_file_id            => i_file_id
                , i_incom_sess_file_id => i_incom_sess_file_id
                , i_network_id         => i_network_id
                , i_host_id            => i_host_id
                , i_standard_id        => i_standard_id
                , i_create_operation   => i_create_operation
                , i_need_repeat        => i_need_repeat
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process incoming second presentment
        elsif i_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT 
              and i_mes_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL, jcb_api_const_pkg.FUNC_CODE_SECOND_PRES_PART) then
              
            jcb_api_fin_pkg.create_incoming_second_pres (
                i_mes_rec              => i_mes_rec
                , i_file_id            => i_file_id
                , i_incom_sess_file_id => i_incom_sess_file_id
                , i_network_id         => i_network_id
                , i_host_id            => i_host_id
                , i_standard_id        => i_standard_id
                , i_create_operation   => i_create_operation
                , i_need_repeat        => i_need_repeat
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process incoming chargeback
        elsif i_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_CHARGEBACK
              and i_mes_rec.de024 in (jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                    , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                    , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                                    , jcb_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART) then
                                        
            jcb_api_fin_pkg.create_incoming_chargeback (
                i_mes_rec              => i_mes_rec
                , i_file_id            => i_file_id
                , i_incom_sess_file_id => i_incom_sess_file_id
                , i_network_id         => i_network_id
                , i_host_id            => i_host_id
                , i_standard_id        => i_standard_id
                , i_create_operation   => i_create_operation
                , i_need_repeat        => i_need_repeat
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        -- process incoming fee collection
        elsif i_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_FEE and i_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FEE_COLLECTION then
        
            jcb_api_fin_pkg.create_incoming_fee (
                i_mes_rec              => i_mes_rec
                , i_file_id            => i_file_id
                , i_incom_sess_file_id => i_incom_sess_file_id
                , i_network_id         => i_network_id
                , i_host_id            => i_host_id
                , i_standard_id        => i_standard_id
                , i_create_operation   => i_create_operation
                , i_need_repeat        => i_need_repeat
            );
            count_amount (
                i_sttl_amount      => i_mes_rec.de005
                , i_sttl_currency  => i_mes_rec.de050
            );

        else
            l_message_processed := com_api_type_pkg.FALSE;

        end if;
            
        trc_log_pkg.debug (
            i_text          => 'process message end'
        );

        return l_message_processed;

    exception
        when jcb_api_dispute_pkg.e_need_original_record then
            rollback to savepoint sp_message_with_dispute;

            -- Save unprocessed record into buffer.
            g_no_original_rec_tab(g_no_original_rec_tab.count + 1).i_mes_rec        := i_mes_rec;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_file_id            := i_file_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_incom_sess_file_id := i_incom_sess_file_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_network_id         := i_network_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_host_id            := i_host_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_standard_id        := i_standard_id;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_create_operation   := i_create_operation;
            g_no_original_rec_tab(g_no_original_rec_tab.count).i_mes_rec_prev       := i_mes_rec_prev;
            g_no_original_rec_tab(g_no_original_rec_tab.count).io_fin_ref_id        := io_fin_ref_id;

            l_message_processed := com_api_type_pkg.TRUE;
            
            trc_log_pkg.debug (
                i_text          => 'Message saved for repeat searching dispute id'
            );
            
            return l_message_processed;
    end;

    procedure process (
        i_network_id            in com_api_type_pkg.t_tiny_id
      , i_create_operation      in com_api_type_pkg.t_boolean     := null
      , i_with_rdw              in com_api_type_pkg.t_boolean     := null
    ) is
        LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load: ';
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;

        l_mes_rec_prev          jcb_api_type_pkg.t_mes_rec;
        l_mes_rec               jcb_api_type_pkg.t_mes_rec;
        l_file_rec              jcb_api_type_pkg.t_file_rec;

        l_fin_ref_id            com_api_type_pkg.t_long_id;

        l_estimated_count       com_api_type_pkg.t_long_id := 0;
        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;

        l_file                  blob;
        l_curr_pos              com_api_type_pkg.t_long_id := 1;
        l_file_length           com_api_type_pkg.t_long_id := 0;

        l_session_files         com_api_type_pkg.t_number_tab;

        procedure init_record is
        begin
            l_mes_rec_prev := l_mes_rec;
            l_mes_rec := null;
        end;

    begin
        savepoint ipm_start_load;

        trc_log_pkg.debug (
            i_text          => 'starting loading JCB with Parameters: network [#1], create operation [#2], Record with rdw [#3]'
            , i_env_param1  => i_network_id
            , i_env_param2  => i_create_operation
            , i_env_param3  => i_with_rdw
        );

        prc_api_stat_pkg.log_start;

        g_amount_tab.delete;
        g_no_original_rec_tab.delete;
        jcb_api_fin_pkg.init_no_original_id_tab;

        -- get network communication standard
        l_host_id     := net_api_network_pkg.get_default_host(
                             i_network_id => i_network_id
                         );
        l_standard_id := net_api_network_pkg.get_offline_standard(
                             i_host_id    => l_host_id
                         );

        trc_log_pkg.debug (
            i_text          => 'enumerating files'
        );

        select id
          bulk collect into l_session_files
          from prc_session_file
         where session_id = get_session_id
         order by id;

        trc_log_pkg.debug (
            i_text          => 'Files for loading [#1]'
            , i_env_param1  => l_session_files.count
        );

        for i in 1 .. l_session_files.count loop
        
            l_mes_rec_prev := null;
            l_mes_rec      := null;
            l_file_rec     := null;

            -- read file for l_session_files(i);
            select file_bcontents
              into l_file
              from prc_session_file 
             where id = l_session_files(i);
            
            l_file_length := dbms_lob.getlength(l_file);
            l_curr_pos    := 1;
              
            trc_log_pkg.debug (
                i_text          => 'Length of opened file [#1]'
                , i_env_param1  => l_file_length
            );
            
            while l_curr_pos < l_file_length loop              
                
                begin
                    savepoint ipm_start_new_record;
                    -- unpack message
                    -- return current message from file, when we have come to end of message
                    trc_log_pkg.debug (
                        i_text          => 'l_curr_pos before unpack [#1]'
                        , i_env_param1  => l_curr_pos
                    );
                    unpack_message (
                          i_file            => l_file
                        , i_with_rdw        => i_with_rdw
                        , io_curr_pos       => l_curr_pos
                        , o_mes_rec         => l_mes_rec
                    );
                    trc_log_pkg.debug (
                        i_text          => 'l_curr_pos after unpack [#1]'
                        , i_env_param1  => l_curr_pos
                    );

                    -- processing by message type

                    -- process incoming header
                    if ( l_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                         and l_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_HEADER
                    ) then
                        create_incoming_header (
                            i_mes_rec               => l_mes_rec
                            , io_file_rec           => l_file_rec
                            , i_network_id          => i_network_id
                            , i_host_id             => l_host_id
                            , i_standard_id         => l_standard_id
                            , i_session_file_id     => l_session_files(i)
                        );
                        init_record;

                    -- process incoming trailer
                    elsif ( l_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                            and l_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_TRAILER
                    ) then
                        create_incoming_trailer (
                            i_mes_rec            => l_mes_rec
                            , io_file_rec        => l_file_rec
                        );
                        init_record;

                    else
                        inc_file_totals (
                            io_file_rec         => l_file_rec
                            , i_amount          => l_mes_rec.de004
                            , i_count           => 1
                        );

                        -- process message types with dispute feature
                        if process_message_with_dispute(
                              i_mes_rec            => l_mes_rec
                            , i_file_id            => l_file_rec.id
                            , i_incom_sess_file_id => l_session_files(i)
                            , io_fin_ref_id        => l_fin_ref_id
                            , i_network_id         => i_network_id
                            , i_host_id            => l_host_id
                            , i_standard_id        => l_standard_id
                            , i_create_operation   => i_create_operation
                            , i_mes_rec_prev       => l_mes_rec_prev
                            , i_need_repeat        => com_api_type_pkg.TRUE
                          ) = com_api_type_pkg.TRUE
                        then
                            init_record;
                        
                        --elsif reject, summry, spd, fpd
                        
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'JCB_UNKNOWN_MESSAGE'
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
                            if ( l_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                                 and l_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_HEADER
                            ) or
                            -- process incoming trailer
                            ( l_mes_rec.mti = jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                              and l_mes_rec.de024 = jcb_api_const_pkg.FUNC_CODE_TRAILER
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

        jcb_api_fin_pkg.process_no_original_id_tab;

        trc_log_pkg.debug (
            i_text          => 'finished loading JCB'
        );

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_processed_count + l_excepted_count
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint ipm_start_load;

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
