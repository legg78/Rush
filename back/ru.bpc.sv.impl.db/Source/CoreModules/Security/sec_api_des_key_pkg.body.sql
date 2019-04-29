create or replace package body sec_api_des_key_pkg as
/**********************************************************
 * API for 3DES keys
 * Created by Kopachev D.(kopachev@bpcbt.com) at 21.05.2010
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br /> 
 * Module: sec_api_des_key_pkg
 * @headcom
 **********************************************************/    

    procedure add_des_key (
        o_key_id              out com_api_type_pkg.t_medium_id
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_check_value       in sec_api_type_pkg.t_check_value
    ) is
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
    begin
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        o_key_id := sec_des_key_seq.nextval;

        insert into sec_des_key_vw(
            id
            , seqnum
            , object_id
            , entity_type
            , lmk_id
            , key_type
            , key_index
            , key_length
            , key_value
            , key_prefix
            , check_value
            , generate_date
            , generate_user_id
        ) values (
            o_key_id
            , 1
            , i_object_id
            , i_entity_type
            , l_hsm_device.lmk_id
            , i_key_type
            , i_key_index
            , i_key_length
            , i_key_value
            , i_key_prefix
            , i_check_value
            , get_sysdate
            , get_user_id
        );
    end;

    procedure modify_des_key (
        i_entity_type         in com_api_type_pkg.t_dict_value
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_check_value       in sec_api_type_pkg.t_check_value
        , i_key_value         in sec_api_type_pkg.t_key_value
    ) is
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
    begin
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
        update
            sec_des_key_vw
        set
            key_prefix = i_key_prefix
            , key_length = i_key_length
            , check_value = i_check_value
            , key_value = i_key_value
            , lmk_id = l_hsm_device.lmk_id
            , seqnum = seqnum + 1
        where
            entity_type = i_entity_type
            and object_id = i_object_id
            and key_type = i_key_type
            and key_index = i_key_index;
    end;

    procedure remove_des_key (
        i_key_id              in com_api_type_pkg.t_medium_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            sec_des_key_vw
        set
            seqnum = i_seqnum
        where
            id = i_key_id;
         
        delete from
            sec_des_key_vw
        where
            id = i_key_id;
    end;
    
    procedure get_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , o_key_length        out com_api_type_pkg.t_tiny_id
        , o_key_value         out sec_api_type_pkg.t_key_value
        , o_key_prefix        out sec_api_type_pkg.t_key_prefix
        , o_check_value       out sec_api_type_pkg.t_check_value
    ) is
        l_des_key_rec         sec_api_type_pkg.t_des_key_rec;
    begin
        l_des_key_rec := get_key (
            i_object_id        => i_object_id
            , i_entity_type    => i_entity_type
            , i_hsm_device_id  => i_hsm_device_id
            , i_key_type       => i_key_type
            , i_key_index      => i_key_index
        );
        o_key_length := l_des_key_rec.key_length;
        o_key_value := l_des_key_rec.key_value;
        o_key_prefix := l_des_key_rec.key_prefix;
        o_check_value := l_des_key_rec.check_value;
    end;
    
    function get_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_mask_error        in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_des_key_rec is
        l_result              sec_api_type_pkg.t_des_key_rec;
    begin
        begin
            select
                n.id
                , n.key_type
                , n.key_index
                , n.key_length
                , n.key_value
                , n.key_prefix
                , n.check_value
                , n.lmk_id
            into
                l_result
            from
                sec_des_key_vw n
                , hsm_device_vw d
            where
                n.object_id = i_object_id
                and n.entity_type = i_entity_type
                and n.key_type = i_key_type
                and n.key_index = i_key_index
                and n.lmk_id = d.lmk_id
                and d.id = i_hsm_device_id
                and d.is_enabled = com_api_type_pkg.TRUE;
        exception
            when no_data_found then
                if i_mask_error = com_api_type_pkg.FALSE then
                    com_api_error_pkg.raise_error (
                        i_error         => 'KEY_NOT_FOUND'
                        , i_env_param1  => i_entity_type
                        , i_env_param2  => i_object_id
                        , i_env_param3  => i_key_type
                        , i_env_param4  => i_key_index
                    );
                else
                    trc_log_pkg.error (
                        i_text          => 'Key [#3] with key index [#4] for [#1] [#2] not found'
                        , i_env_param1  => i_entity_type
                        , i_env_param2  => i_object_id
                        , i_env_param3  => i_key_type
                        , i_env_param4  => i_key_index
                    );
                    l_result := null;
                end if;
        end;
        
        return l_result;
    end;
    
    function get_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_mask_error        in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_des_key_rec is
        l_result              sec_api_type_pkg.t_des_key_rec;
    begin
        begin
            select
                *
            into
                l_result
            from (
                select
                    n.id
                    , n.key_type
                    , n.key_index
                    , n.key_length
                    , n.key_value
                    , n.key_prefix
                    , n.check_value
                    , n.lmk_id
                from
                    sec_des_key_vw n
                where
                    n.object_id = i_object_id
                    and n.entity_type = i_entity_type
                    and n.key_type = i_key_type
                    and (n.key_index = i_key_index or i_key_index is null)
                order by
                    n.key_index desc
            ) where
                rownum = 1;
        exception
            when no_data_found then
                if i_mask_error = com_api_type_pkg.FALSE then
                    com_api_error_pkg.raise_error (
                        i_error         => 'KEY_NOT_FOUND'
                        , i_env_param1  => i_entity_type
                        , i_env_param2  => i_object_id
                        , i_env_param3  => i_key_type
                        , i_env_param4  => i_key_index
                    );
                else
                    trc_log_pkg.error (
                        i_text          => 'Key [#3] with key index [#4] for [#1] [#2] not found'
                        , i_env_param1  => i_entity_type
                        , i_env_param2  => i_object_id
                        , i_env_param3  => i_key_type
                        , i_env_param4  => i_key_index
                    );
                    l_result := null;
                end if;
        end;

        return l_result;
    end;

    procedure generate_key_check_value (
        i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , o_check_value       out sec_api_type_pkg.t_check_value
    ) is
        l_result              com_api_type_pkg.t_tiny_id;
        l_resp_message        com_api_type_pkg.t_name;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
    begin
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- generate kcv
            l_result := hsm_api_hsm_pkg.generate_key_check_value (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_key_type       => i_key_type
                , i_key_length     => nvl(i_key_length, nvl(length(i_key_value), 0))
                , i_key_value      => nvl(i_key_value, '')
                , i_key_prefix     => nvl(i_key_prefix, '')
                , o_check_value    => o_check_value
                , o_resp_mess      => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'KCV_GENERATION_FAILED'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => i_key_type
              , i_env_param3     => l_resp_message
            );
        end if;
    end;
    
    function validate_key_check_value (
        i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_check_value       in sec_api_type_pkg.t_check_value
    ) return com_api_type_pkg.t_boolean is
        l_result              com_api_type_pkg.t_tiny_id;
        l_valid_kcv           com_api_type_pkg.t_tiny_id;
        l_resp_message        com_api_type_pkg.t_name;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
    begin
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
        
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- validate kcv
            l_result := hsm_api_hsm_pkg.validate_key_check_value (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_key_type       => i_key_type
                , i_key_length     => nvl(i_key_length, nvl(length(i_key_value), 0))
                , i_key_value      => nvl(i_key_value, '')
                , i_key_prefix     => nvl(i_key_prefix, '')
                , i_check_value    => nvl(i_check_value, '')
                , o_result         => l_valid_kcv
                , o_resp_mess      => l_resp_message
            );
        else
            l_result := hsm_api_const_pkg.RESULT_CODE_OK;
            l_valid_kcv := 1;
        end if;

        -- if an error occurs then we should process it and raise some application error 
        hsm_api_device_pkg.process_error(
            i_hsm_devices_id => i_hsm_device_id
          , i_result_code    => l_result
          , i_error          => 'KCV_VALIDATION_FAILED'
          , i_env_param1     => i_hsm_device_id
          , i_env_param2     => i_key_type
          , i_env_param3     => l_resp_message
        );

        if l_valid_kcv > 0 then -- kcv valid
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;

end;
/
