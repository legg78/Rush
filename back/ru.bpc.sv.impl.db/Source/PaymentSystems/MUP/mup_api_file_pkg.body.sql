create or replace package body mup_api_file_pkg is
 
    function extract_file_date (
        i_p0105                 in mup_api_type_pkg.t_p0105
    ) return date is
    begin
        return to_date(substr(i_p0105, 4, 6), mup_api_const_pkg.P0105_DATE_FORMAT);
    end;
    
    --file type may be other: jcb, cup, amex
    function encode_p0105 (
        i_cmid                  in com_api_type_pkg.t_cmid
        , i_file_date           in date
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_collection_only     in com_api_type_pkg.t_boolean    := null
    ) return mup_api_type_pkg.t_pds_body is
        l_file_seq              number;
        l_p0105                 mup_api_type_pkg.t_pds_body;
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_file_type             com_api_type_pkg.t_curr_code;
        l_standart_version_id   com_api_type_pkg.t_tiny_id;
    begin

        l_standart_version_id :=
            cmn_api_standard_pkg.get_current_version(
                i_standard_id  => i_standard_id 
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => i_host_id
              , i_eff_date     => com_api_sttl_day_pkg.get_sysdate()
            );

        l_file_type := case i_network_id
                        when mup_api_const_pkg.MUP_NETWORK_ID then mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_MUP
                        when mup_api_const_pkg.CUP_NETWORK_ID then mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_CUP
                        when mup_api_const_pkg.JCB_NETWORK_ID then mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_JCB
                        when amx_api_const_pkg.TARGET_NETWORK then mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_AMX
                        else mup_api_const_pkg.FILE_TYPE_OUT_CLEARING_MUP
                       end;

        if i_collection_only = com_api_const_pkg.TRUE
            and l_standart_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4
        then 
            l_file_type := mup_api_const_pkg.FILE_TYPE_OUT_COLLECTION_ONLY;
        end if;

        l_p0105 := (
            l_file_type
            || to_char(i_file_date, mup_api_const_pkg.P0105_DATE_FORMAT)
            || mup_utl_pkg.pad_number(i_cmid, 11, 11)
        );

        select
            max(to_number(substr(f.p0105, 21)))
        into
            l_file_seq
        from
            mup_file f

        where
            f.p0105 like l_p0105 || '%'
            and f.network_id = i_network_id;

        l_file_seq := nvl (
            l_file_seq + 1,
            cmn_api_standard_pkg.get_number_value(
                i_inst_id       => i_inst_id
              , i_standard_id   => i_standard_id
              , i_object_id     => i_host_id
              , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name    => 'START_FILE_NUMBER'
              , i_param_tab     => l_param_tab
            )
        );

        l_file_seq := nvl(l_file_seq, 1);

        loop
            if l_file_seq > 99999 then
                com_api_error_pkg.raise_error(
                    i_error         => 'UNABLE_ALLOCATE_FILE_NUMBER'
                    , i_env_param1  => i_cmid
                    , i_env_param2  => i_network_id
                    , i_env_param3  => i_file_date
                );
            end if;


            if request_lock('ENTTP0105' || l_p0105 || mup_utl_pkg.pad_number(l_file_seq, 5, 5)) = 0 then
                exit;
            end if;

            l_file_seq := l_file_seq + 1;
        end loop;


        l_p0105 := l_p0105 || mup_utl_pkg.pad_number(l_file_seq, 5, 5);

        return l_p0105;
    end;

end;
/
