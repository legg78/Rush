create or replace package body hsm_api_device_pkg is
/************************************************************
 * API for HSM device <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.07.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: hsm_api_device_pkg <br />
 * @headcom
 ************************************************************/

    function get_hsm_device (
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
        , i_hsm_action              in     com_api_type_pkg.t_dict_value
        , i_lmk_id                  in     com_api_type_pkg.t_tiny_id
    ) return hsm_api_type_pkg.t_hsm_device_rec is
        l_result                    hsm_api_type_pkg.t_hsm_device_rec;
    begin
        if i_hsm_device_id is not null then
            select
                a.id device_id
                , a.is_enabled
                , a.seqnum
                , a.comm_protocol
                , a.plugin
                , a.manufacturer
                , a.serial_number
                , a.lmk_id
                , b.address
                , b.port
                , nvl(s.max_connection, 0) max_connection
                , a.model_number
                , s.firmware
                , l.check_value
            into
                l_result
            from
                hsm_device_vw a
                , hsm_tcp_ip_vw b
                , ( select
                        hsm_device_id, firmware, sum(max_connection) over(partition by hsm_device_id) max_connection
                    from
                        hsm_selection
                    where
                        action = i_hsm_action
                        or i_hsm_action is null
                    order by
                        hsm_device_id, decode(firmware, 'HSMF0050', 1, 2)
                ) s
                , hsm_lmk_vw l
            where
                a.id = i_hsm_device_id
                and b.id(+) = a.id
                and s.hsm_device_id(+) = a.id
                and l.id = a.lmk_id
                and rownum < 2;
        else
            select
                a.id device_id
                , a.is_enabled
                , a.seqnum
                , a.comm_protocol
                , a.plugin
                , a.manufacturer
                , a.serial_number
                , a.lmk_id
                , b.address
                , b.port
                , s.max_connection
                , a.model_number
                , s.firmware
                , l.check_value
            into
                l_result
            from
                hsm_device_vw a
                , hsm_tcp_ip_vw b
                , ( select
                        hsm_device_id, firmware, sum(max_connection) over(partition by hsm_device_id) max_connection
                    from
                        hsm_selection
                    where
                        action = i_hsm_action
                        or i_hsm_action is null
                    order by
                        hsm_device_id, decode(firmware, 'HSMF0050', 1, 2)
                ) s
                , hsm_lmk_vw l
            where
                a.lmk_id = i_lmk_id
                and b.id(+) = a.id
                and s.hsm_device_id = a.id
                and a.is_enabled = com_api_type_pkg.TRUE
                and l.id = a.lmk_id
                and rownum < 2;
        end if;

        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'HSM_DEVICE_NOT_FOUND'
                , i_env_param1  => i_hsm_device_id
            );
    end;
    
    /*
     * Disabling HSM device, it relates to DB only because HSM API may be unavailable;
     * after this an exception with HSM error is raised, so autonomous_transaction is required.
     */
    procedure disable_hsm_device(
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
    ) is
    pragma autonomous_transaction;
    begin
        trc_log_pkg.debug('Disable HSM device [' || i_hsm_device_id || ']');

        update hsm_device
           set is_enabled = com_api_type_pkg.FALSE
         where id = i_hsm_device_id;
         
        trc_log_pkg.debug('updated records: ' || sql%rowcount);

        -- All active connections should be closed if they exist
        hsm_api_connection_pkg.remove_connection(
            i_hsm_device_id => i_hsm_device_id
        );

        trc_log_pkg.debug('HSM device [' || i_hsm_device_id || '] was disabled');

        commit;
    end;

    procedure init_hsm_devices (
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
        , o_connect_status             out com_api_type_pkg.t_name
    ) is
        l_perso_device              hsm_api_type_pkg.t_hsm_device_rec;
        l_auth_device               hsm_api_type_pkg.t_hsm_device_rec;
        l_result                    com_api_type_pkg.t_tiny_id;
        l_resp_message              com_api_type_pkg.t_name;
        l_connect_status            com_api_type_pkg.t_name;
    begin
        trc_log_pkg.debug (
            i_text          => 'Init HSM device [#1]'
            , i_env_param1  => i_hsm_device_id
        );

        hsm_api_connection_pkg.remove_connection (
            i_hsm_device_id  => i_hsm_device_id
        );

        -- get HSM with personalization action
        l_perso_device := get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
            , i_hsm_action   => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
        );

        trc_log_pkg.debug (
            i_text          => 'Personalization action [#1]'
            , i_env_param1  => l_perso_device.max_connection
        );

        if l_perso_device.max_connection > 0 then
            if g_use_hsm = com_api_type_pkg.TRUE then
                -- init HSM
                begin
                    l_result := hsm_api_hsm_pkg.init_hsm_devices (
                        i_hsm_ip                   => l_perso_device.address
                        , i_hsm_port               => l_perso_device.port
                        , i_lmk_id                 => l_perso_device.lmk_id
                        , i_model_number           => l_perso_device.model_number
                        , i_firmware               => l_perso_device.firmware
                        , i_plugin                 => l_perso_device.plugin
                        , i_max_connection         => l_perso_device.max_connection
                        , o_connect_status         => l_connect_status
                        , i_connect_status_length  => l_perso_device.max_connection
                        , o_resp_mess              => l_resp_message
                    );
                exception
                    when com_api_error_pkg.e_external_library_not_found then
                        com_api_error_pkg.raise_error (
                            i_error         => 'HSM_LIBRARY_NOT_FOUND'
                        );
                    when others then
                        com_api_error_pkg.raise_error (
                            i_error         => 'HSM_FATAL_ERROR'
                        );
                end;
            else
                l_result := hsm_api_const_pkg.RESULT_CODE_OK;
                l_connect_status := lpad('1', l_perso_device.max_connection, '1');
            end if;
            trc_log_pkg.debug (
                i_text          => 'Init HSM - result[#1] message[#2] connect status[#3]'
                , i_env_param1  => l_result
                , i_env_param2  => l_resp_message
                , i_env_param3  => l_connect_status
            );

            if l_result < hsm_api_const_pkg.RESULT_CODE_OK or l_connect_status is null then
                com_api_error_pkg.raise_error (
                    i_error         => 'ERROR_INIT_HSM_DEVICE'
                    , i_env_param1  => l_resp_message
                );
            end if;

            -- set device dynamic status
            hsm_api_connection_pkg.set_connection (
                i_hsm_device_id     => i_hsm_device_id
                , i_connect_status  => substr(l_connect_status, 1, l_perso_device.max_connection)
                , i_action          => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
            );
            
            for i in 1..l_perso_device.max_connection loop
                o_connect_status := 
                    case substr(l_connect_status, i, 1)
                        when '1' then hsm_api_const_pkg.HSM_CONN_STATUS_ACTIVE
                        when '2' then hsm_api_const_pkg.HSM_CONN_STATUS_COMM_ERROR
                        when '3' then hsm_api_const_pkg.HSM_CONN_STATUS_CONF_ERROR
                        else hsm_api_const_pkg.HSM_CONN_STATUS_UNDEFINED
                    end;
                if o_connect_status = hsm_api_const_pkg.HSM_CONN_STATUS_ACTIVE then
                    exit;
                end if;
            end loop;
        end if;

        -- get HSM with authorization action
        l_auth_device := get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
            , i_hsm_action   => hsm_api_const_pkg.ACTION_HSM_AUTHORIZATION
        );

        trc_log_pkg.debug (
            i_text          => 'Authorization action [#1]'
            , i_env_param1  => l_auth_device.max_connection
        );

        for i in 1..l_auth_device.max_connection loop
            -- set device dynamic status
            hsm_api_connection_pkg.set_connection (
                i_hsm_device_id     => i_hsm_device_id
                , i_connect_number  => l_perso_device.max_connection + i
                , i_status          => substr(l_connect_status, 1, l_auth_device.max_connection)
                , i_action          => hsm_api_const_pkg.ACTION_HSM_AUTHORIZATION
            );
        end loop;
        
    end;

    procedure deinit_hsm_devices (
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
    ) is
        l_result                    com_api_type_pkg.t_tiny_id;
        l_resp_message              com_api_type_pkg.t_name;
        l_hsm_device                hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text          => 'De-init HSM device [#1]'
            , i_env_param1  => i_hsm_device_id
        );

        -- get HSM
        l_hsm_device := get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
            , i_hsm_action   => null--hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
        );

        if  g_use_hsm = com_api_type_pkg.TRUE then
            -- deinit HSM
            l_result := hsm_api_hsm_pkg.deinit_hsm_devices (
                i_hsm_ip            => l_hsm_device.address
                , i_hsm_port        => l_hsm_device.port
                , o_resp_mess       => l_resp_message
            );
        else
            l_result := hsm_api_const_pkg.RESULT_CODE_OK;
        end if;

        trc_log_pkg.debug (
            i_text          => 'De-init HSM - result[#1] message[#2]'
            , i_env_param1  => l_result
            , i_env_param2  => l_resp_message
        );

        if l_result < hsm_api_const_pkg.RESULT_CODE_OK then
            com_api_error_pkg.raise_error (
                i_error         => 'ERROR_DEINIT_HSM_DEVICE'
                , i_env_param1  => l_resp_message
            );
        end if;

        -- clear device dynamic status
        hsm_api_connection_pkg.remove_connection (
            i_hsm_device_id  => i_hsm_device_id
        );
    end;

    function get_hsm_standard (
        i_hsm_device_id             in      com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id
    is
        l_result            com_api_type_pkg.t_tiny_id;
    begin
        select
            standard_id
        into
            l_result
        from
            cmn_standard_object s
        where
            s.object_id = i_hsm_device_id
            and s.entity_type = hsm_api_const_pkg.ENTITY_TYPE_HSM
            and s.standard_type = cmn_api_const_pkg.STANDART_TYPE_HSM;

        if l_result is null then
            raise no_data_found;
        end if;

        return l_result;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error             => 'NO_HSM_STANDARD_FOR_DEVICE'
                , i_env_param1      => i_hsm_device_id
            );
    end;

    /*
     * Procedure executes some additional actions with HSM device and
     * raises an error if passed result code is not RESULT_CODE_OK.
     */
    procedure process_error(
        i_hsm_devices_id            in     com_api_type_pkg.t_tiny_id
      , i_result_code               in     com_api_type_pkg.t_tiny_id
      , i_error                     in     com_api_type_pkg.t_name
      , i_env_param1                in     com_api_type_pkg.t_full_desc default null
      , i_env_param2                in     com_api_type_pkg.t_name      default null
      , i_env_param3                in     com_api_type_pkg.t_name      default null
      , i_env_param4                in     com_api_type_pkg.t_name      default null
      , i_env_param5                in     com_api_type_pkg.t_name      default null
      , i_env_param6                in     com_api_type_pkg.t_name      default null
    ) is
    begin
        if i_result_code < hsm_api_const_pkg.RESULT_CODE_OK then
            -- On connection error HSM device should be disabled
            -- but it should be done inside DB only, HSM API isn't available
            if i_result_code = hsm_api_const_pkg.RESULT_CODE_CONNECTION_ERROR then
                disable_hsm_device(
                    i_hsm_device_id => i_hsm_devices_id
                );
            end if;
            com_api_error_pkg.raise_error(
                i_error      => i_error
              , i_env_param1 => i_env_param1
              , i_env_param2 => i_env_param2
              , i_env_param3 => i_env_param3
              , i_env_param4 => i_env_param4
              , i_env_param5 => i_env_param5
              , i_env_param6 => i_env_param6
            );
        end if;
    end process_error;

    procedure reload_settings
    is
    begin
        g_use_hsm := set_ui_value_pkg.get_system_param_n(i_param_name => 'USE_HSM');
    end;

begin
    reload_settings;
end;
/
