create or replace package body mcw_api_file_pkg is

    function extract_file_date (
        i_p0105                 in mcw_api_type_pkg.t_p0105
    ) return date is
    begin
        return to_date(substr(i_p0105, 4, 6), mcw_api_const_pkg.P0105_DATE_FORMAT);
    end;
    
    function encode_p0105 (
        i_cmid                  in com_api_type_pkg.t_cmid
        , i_file_date           in date
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    ) return mcw_api_type_pkg.t_pds_body is
        l_file_seq              number;
        l_p0105                 mcw_api_type_pkg.t_pds_body;
        l_param_tab             com_api_type_pkg.t_param_tab;
    begin
        l_p0105 := (
            mcw_api_const_pkg.FILE_TYPE_OUT_CLEARING
            || to_char(i_file_date, mcw_api_const_pkg.P0105_DATE_FORMAT)
            || mcw_utl_pkg.pad_number(i_cmid, 11, 11)
        );

        select
            max(to_number(substr(f.p0105, 21)))
        into
            l_file_seq
        from
            mcw_file f

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


            if request_lock('ENTTP0105' || l_p0105 || mcw_utl_pkg.pad_number(l_file_seq, 5, 5)) = 0 then
                exit;
            end if;

            l_file_seq := l_file_seq + 1;
        end loop;


        l_p0105 := l_p0105 || mcw_utl_pkg.pad_number(l_file_seq, 5, 5);

        return l_p0105;
    end;

end;
/
