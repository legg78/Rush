create or replace package body hsm_api_connection_pkg is

    procedure set_connection (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_connect_number          in com_api_type_pkg.t_tiny_id
        , i_status                  in com_api_type_pkg.t_dict_value
        , i_action                  in com_api_type_pkg.t_dict_value
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Going to flush device dynamic status. hsm_device_id[#1] connect_number[#2] status[#3] action[#4]'
            , i_env_param1  => i_hsm_device_id
            , i_env_param2  => i_connect_number
            , i_env_param3  => i_status
            , i_env_param4  => i_action
        );
        
        merge into hsm_connection_vw dst
        using (
            select
                i_hsm_device_id hsm_device_id
                , i_connect_number connect_number
                , decode(substr(i_status, 1, 1), '1', hsm_api_const_pkg.HSM_CONN_STATUS_ACTIVE 
                                               , '2', hsm_api_const_pkg.HSM_CONN_STATUS_COMM_ERROR 
                                               , '3', hsm_api_const_pkg.HSM_CONN_STATUS_CONF_ERROR 
                                                    , hsm_api_const_pkg.HSM_CONN_STATUS_UNDEFINED) as status
                , i_action action
            from
                dual
        ) src
        on (
            src.hsm_device_id = dst.hsm_device_id
            and src.connect_number = dst.connect_number
            and src.action = dst.action
        )
        when matched then
            update
            set
                dst.status = src.status
        when not matched then
            insert (
                dst.hsm_device_id
                , dst.connect_number
                , dst.status
                , dst.action
            ) values (
                src.hsm_device_id
                , src.connect_number
                , src.status
                , src.action
            );
        
        trc_log_pkg.debug (
            i_text          => 'Device dynamic status saved [#1]'
            , i_env_param1  => sql%rowcount
        );
    end;

    procedure set_connection (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_connect_status          in com_api_type_pkg.t_name
        , i_action                  in com_api_type_pkg.t_dict_value
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Going to flush device dynamic status. hsm_device_id[#1] i_connect_status[#2]'
            , i_env_param1  => i_hsm_device_id
            , i_env_param2  => i_connect_status
        );

        insert into hsm_connection_vw (
            hsm_device_id
            , connect_number
            , status
            , action
        )
        select
            i_hsm_device_id
            , level
            , decode(substr(t.status, level, 1), '1', hsm_api_const_pkg.HSM_CONN_STATUS_ACTIVE 
                                               , '2', hsm_api_const_pkg.HSM_CONN_STATUS_COMM_ERROR 
                                               , '3', hsm_api_const_pkg.HSM_CONN_STATUS_CONF_ERROR 
                                               , hsm_api_const_pkg.HSM_CONN_STATUS_UNDEFINED)            
            , i_action
        from (
            select
                i_connect_status status
            from
                dual
            ) t
        where
            t.status is not null
        connect by level <= length(t.status);

        trc_log_pkg.debug (
            i_text          => 'Device dynamic status saved [#1]'
            , i_env_param1  => sql%rowcount
        );

    end;

    procedure remove_connection (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_action                  in com_api_type_pkg.t_dict_value
    ) is
    begin
        delete from
            hsm_connection_vw
        where
            hsm_device_id = i_hsm_device_id
            and (action = i_action
            or i_action is null
            );
    end;

    procedure remove_connection is
    begin
        delete from
            hsm_connection_vw;
    end;
    
end;
/
