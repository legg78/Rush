create or replace package body cmn_api_device_connection_pkg is

    procedure set_device_connection (
        i_device_id                 in com_api_type_pkg.t_short_id
        , i_connect_number          in com_api_type_pkg.t_tiny_id
        , i_status                  in com_api_type_pkg.t_dict_value
    ) is
    begin
        merge into cmn_device_connection_vw dst
        using (
            select
                i_device_id device_id
                , i_connect_number connect_number
                , i_status status
            from
                dual
        ) src
        on (
            src.device_id = dst.device_id
            and src.connect_number = dst.connect_number
        )
        when matched then
            update
            set
                dst.status = src.status
        when not matched then
            insert (
                dst.device_id
                , dst.connect_number
                , dst.status
            ) values (
                src.device_id
                , src.connect_number
                , src.status
            );
    end;

    procedure set_device_connection (
        i_device_id                 in com_api_type_pkg.t_short_id
        , i_connect_status          in com_api_type_pkg.t_name
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Going to flush device connection status. device_id[#1] i_connect_status[#2]'
            , i_env_param1  => i_device_id
            , i_env_param2  => i_connect_status
        );
        
        delete from
            cmn_device_connection_vw
        where
            device_id = i_device_id;
        
        insert into cmn_device_connection_vw (
            device_id
            , connect_number
            , status
        )
        select
            i_device_id
            , level
            , decode(substr(t.status, level, 1), '1', 'DCNSGOOD', 'DCNSSUDFN')
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
            i_text          => 'Device connection status saved [#1]'
            , i_env_param1  => sql%rowcount
        );
    end;
    
    procedure remove_device_connection (
        i_device_id                 in com_api_type_pkg.t_short_id
    ) is
    begin
        delete from
            cmn_device_connection_vw
        where
            device_id = i_device_id;
    end;

end;
/
