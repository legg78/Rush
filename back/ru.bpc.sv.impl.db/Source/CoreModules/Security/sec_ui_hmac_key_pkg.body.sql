create or replace package body sec_ui_hmac_key_pkg as
/************************************************************
* User interface for HMAC crypto keys <br />
* Created by Kopachev D.(kopachev@bpcbt.com) at 22.01.2013 <br />
* Last changed by $Author$ <br />
* $LastChangedDate::                           $ <br />
* Revision: $LastChangedRevision$ <br />
* Module: sec_ui_hmac_key_pkg <br />
* @headcom
************************************************************/

    procedure add_hmac_key (
        o_id                  out com_api_type_pkg.t_medium_id
        , o_seqnum            out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
    ) is
        l_key_index           com_api_type_pkg.t_tiny_id;
        l_key_length          com_api_type_pkg.t_tiny_id;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
    begin
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        l_key_index := nvl(i_key_index, 1);
        l_key_length := nvl(i_key_length, nvl(length(i_key_value), 0));

        o_id := sec_des_key_seq.nextval;
        o_seqnum := 1;

        -- insert key
        begin
            insert into sec_hmac_key_vw (
                id
                , seqnum
                , object_id
                , entity_type
                , lmk_id
                , key_index
                , key_length
                , key_value
                , generate_date
                , generate_user_id
            ) values (
                o_id
                , o_seqnum
                , i_object_id
                , i_entity_type
                , l_hsm_device.lmk_id
                , l_key_index
                , l_key_length
                , i_key_value
                , get_sysdate
                , get_user_id
            );
        exception
            when dup_val_on_index then
                com_api_error_pkg.raise_error (
                    i_error         => 'DUPLICATE_SEC_HMAC_KEY'
                );
        end;
    end;

    procedure generate_hmac_key (
        o_id                  out com_api_type_pkg.t_medium_id
        , o_seqnum            out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_length        in com_api_type_pkg.t_tiny_id
    ) is
        l_result              com_api_type_pkg.t_tiny_id;
        l_key_length          com_api_type_pkg.t_tiny_id;
        l_key_value           sec_api_type_pkg.t_key_value;
        l_resp_message        com_api_type_pkg.t_name;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text          => 'Request to generate key [#1][#2][#3]'
            , i_env_param1  => i_key_length
            , i_env_param2  => i_key_index
            , i_env_param3  => i_hsm_device_id
        );

        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_key_length := nvl(i_key_length, nvl(length(l_key_value), 0));

            -- generate key
            l_result := hsm_api_hsm_pkg.generate_hmac_secret_key (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_lmk_id         => l_hsm_device.lmk_id
                , o_secret_key     => l_key_value
                , o_resp_mess      => l_resp_message
            );

            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'KEY_GENERATION_FAILED'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => sec_api_const_pkg.SECURITY_DES_KEY_HMAC
              , i_env_param3     => l_resp_message
            );

            trc_log_pkg.debug (
                i_text          => 'Going to save key [#1][#2]'
                , i_env_param1  => l_key_value
                , i_env_param2  => l_resp_message
            );

            -- save key
            add_hmac_key (
                o_id               => o_id
                , o_seqnum         => o_seqnum
                , i_object_id      => i_object_id
                , i_entity_type    => i_entity_type
                , i_hsm_device_id  => i_hsm_device_id
                , i_key_index      => i_key_index
                , i_key_length     => l_key_length
                , i_key_value      => l_key_value
            );

            trc_log_pkg.debug (
                i_text  => 'Key added'
            );
        end if;
    end;

    procedure remove_hmac_key (
        i_id                  in com_api_type_pkg.t_medium_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            sec_hmac_key_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            sec_hmac_key_vw
        where
            id = i_id;
    end;

end;
/
