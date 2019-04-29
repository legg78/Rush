create or replace package body sec_api_rsa_key_pkg is
/**********************************************************
 * API for RSA crypto keys
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_rsa_key_pkg
 * @headcom
 **********************************************************/    

    function get_rsa_key (
        i_id                    in com_api_type_pkg.t_medium_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_key_type            in com_api_type_pkg.t_dict_value
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_mask_error          in com_api_type_pkg.t_boolean
    ) return sec_api_type_pkg.t_rsa_key_rec is
        l_result                    sec_api_type_pkg.t_rsa_key_rec;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting RSA key set [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_id
            , i_env_param2  => i_object_id
            , i_env_param3  => i_entity_type
            , i_env_param4  => i_key_type
            , i_env_param5  => i_key_index
        );
        
        select
            k.id
            , k.seqnum
            , k.object_id
            , k.entity_type
            , k.lmk_id
            , k.key_type
            , k.key_index
            , c.expir_date
            , k.sign_algorithm
            , k.modulus_length
            , k.exponent
            , k.public_key
            , k.private_key
            , k.public_key_mac
            , c.certificate
            , c.reminder
            , c.hash
            , c.subject_id
            , c.serial_number
            , c.visa_service_id
        into
            l_result
        from
            sec_rsa_key_vw k
            , sec_rsa_certificate_vw c
        where
            ((k.id = i_id and i_id is not null) or
             (k.key_type = i_key_type
              and (k.key_index = i_key_index or i_key_index is null)
              and k.entity_type = i_entity_type
              and k.object_id = nvl(i_object_id, k.object_id)
              and i_id is null)
            )
            and c.certified_key_id(+) = k.id
            and c.authority_key_id(+) = k.id;

        return l_result;
    exception
        when no_data_found then
            if i_mask_error = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error (
                    i_error         => 'RSA_KEY_NOT_FOUND'
                    , i_env_param1  => i_id
                    , i_env_param2  => i_key_type
                    , i_env_param3  => i_key_index
                );
            else
                trc_log_pkg.error (
                    i_text          => 'RSA_KEY_NOT_FOUND'
                    , i_env_param1  => i_id
                    , i_env_param2  => i_key_type
                    , i_env_param3  => i_key_index
                );
                return null;
            end if;
    end;

    function get_authority_key (
        i_key_index             in com_api_type_pkg.t_tiny_id
        , i_authority_id        in com_api_type_pkg.t_tiny_id
        , i_mask_error          in com_api_type_pkg.t_boolean
    ) return sec_api_type_pkg.t_rsa_key_rec is
    begin
        return get_rsa_key (
            i_id             => null
            , i_object_id    => i_authority_id
            , i_entity_type  => sec_api_const_pkg.ENTITY_TYPE_AUTHORITY
            , i_key_type     => sec_api_const_pkg.SECURITY_RSA_CA_KEYSET
            , i_key_index    => i_key_index
            , i_mask_error   => i_mask_error
        );
    end;
        
    function get_issuer_key (
        i_key_index             in com_api_type_pkg.t_tiny_id
        , i_mask_error          in com_api_type_pkg.t_boolean
    ) return sec_api_type_pkg.t_rsa_key_rec is
    begin
        return get_rsa_key (
            i_id             => null
            , i_object_id    => null
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
            , i_key_type     => sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET
            , i_key_index    => i_key_index
            , i_mask_error   => i_mask_error
        );
    end;

    procedure set_rsa_keypair (
        io_id                   in out com_api_type_pkg.t_medium_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_lmk_id              in com_api_type_pkg.t_tiny_id
        , i_key_type            in com_api_type_pkg.t_dict_value
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_expir_date          in date
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_public_key          in com_api_type_pkg.t_key
        , i_private_key         in com_api_type_pkg.t_key
        , i_public_key_mac      in com_api_type_pkg.t_pin_block
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Going to flush RSA key set [#1][#2]'
            , i_env_param1  => i_key_type
            , i_env_param2  => i_key_index
        );
        
        if io_id is null then
            io_id := sec_rsa_key_seq.nextval;
          
            insert into sec_rsa_key_vw (
                id
                , seqnum
                , object_id
                , entity_type
                , lmk_id
                , key_type
                , key_index
                , expir_date
                , sign_algorithm
                , modulus_length
                , exponent
                , public_key
                , private_key
                , public_key_mac
            ) values (
                io_id
                , 1
                , i_object_id
                , i_entity_type
                , i_lmk_id
                , i_key_type
                , i_key_index
                , i_expir_date
                , i_sign_algorithm
                , i_modulus_length
                , i_exponent
                , i_public_key
                , i_private_key
                , i_public_key_mac
            );
        else    
            update sec_rsa_key_vw
            set
                object_id = i_object_id
                , entity_type = i_entity_type
                , expir_date = i_expir_date
                , sign_algorithm = i_sign_algorithm
                , modulus_length = i_modulus_length
                , exponent = i_exponent
                , public_key = i_public_key
                , private_key = i_private_key
                , public_key_mac = i_public_key_mac
            where
                id = io_id;
        end if;
            
        trc_log_pkg.debug (
            i_text          => 'RSA key set saved'
        );
    end;

    procedure generate_rsa_keypair_mc (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_serial_number       in sec_api_type_pkg.t_tracking_number
        , o_key                 out sec_api_type_pkg.t_rsa_key_rec
        , o_certificate         out com_api_type_pkg.t_key
        , o_hash                out com_api_type_pkg.t_key
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_public_key            com_api_type_pkg.t_key;
        l_private_key           com_api_type_pkg.t_key;
        l_public_key_mac        com_api_type_pkg.t_pin_block;
        l_certificate_data      com_api_type_pkg.t_key;
        l_certificate_hash      com_api_type_pkg.t_key;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text      => 'Generate issuer RSA key set (MasterCard)'
        );
        
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            if i_serial_number is null then
                com_api_error_pkg.raise_error (
                    i_error  => 'CERT_SERIAL_NO_NOT_FOUND'
                );
            end if;

            l_result := hsm_api_hsm_pkg.generate_rsa_keypair_mc (
                i_hsm_ip             => l_hsm_device.address
                , i_hsm_port         => l_hsm_device.port
                , i_key_index        => i_key_index
                , i_modulus_length   => i_modulus_length
                , i_exponent         => i_exponent
                , i_expir_date       => to_char(i_expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
                , i_subject_id       => i_subject_id
                , i_serial_number    => i_serial_number
                , o_public_key       => l_public_key
                , o_private_key      => l_private_key
                , o_public_key_mac   => l_public_key_mac
                , o_cert_data        => l_certificate_data
                , o_cert_hash        => l_certificate_hash
                , o_resp_mess        => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_RSA_KEYPAIR_CERT'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
              , i_env_param3     => l_resp_message
            );

            o_key.key_type := sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET;
            o_key.key_index := i_key_index;
            o_key.expir_date := i_expir_date;
            o_key.modulus_length := i_modulus_length;
            o_key.exponent := i_exponent;
            o_key.public_key := l_public_key;
            o_key.private_key := l_private_key;
            o_key.public_key_mac := l_public_key_mac;
            o_certificate := l_certificate_data;
            o_hash := l_certificate_hash;

            trc_log_pkg.debug (
                i_text      => 'Generate issuer RSA key set (MasterCard) - ok'
            );
        end if;
    end;

    procedure generate_rsa_keypair_visa (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date
        , i_sign_algorithm      in com_api_type_pkg.t_tiny_id
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
        , o_key                 out sec_api_type_pkg.t_rsa_key_rec
        , o_certificate         out com_api_type_pkg.t_key
        , o_hash                out com_api_type_pkg.t_key
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_public_key            com_api_type_pkg.t_key;
        l_private_key           com_api_type_pkg.t_key;
        l_public_key_mac        com_api_type_pkg.t_pin_block;
        l_certificate_data      com_api_type_pkg.t_key;
        l_certificate_hash      com_api_type_pkg.t_key;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text      => 'Generate issuer RSA key set (Visa)'
        );
        
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            if i_tracking_number is null then
                com_api_error_pkg.raise_error (
                    i_error  => 'TRACKING_NUMBER_NOT_FOUND'
                );
            end if;
            if i_visa_service_id is null then
                com_api_error_pkg.raise_error (
                    i_error  => 'SERVICE_IDENTIFIER_NOT_FOUND'
                );
            end if;

            l_result := hsm_api_hsm_pkg.generate_rsa_keypair_visa (
                i_hsm_ip             => l_hsm_device.address
                , i_hsm_port         => l_hsm_device.port
                , i_modulus_length   => i_modulus_length
                , i_exponent         => i_exponent
                , i_expir_date       => to_char(i_expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
                , i_tracking_number  => i_tracking_number
                , i_subject_id       => i_subject_id
                , i_service_id       => i_visa_service_id
                , i_sign_algorithm   => i_sign_algorithm
                , o_public_key       => l_public_key
                , o_private_key      => l_private_key
                , o_public_key_mac   => l_public_key_mac
                , o_cert_data        => l_certificate_data
                , o_cert_hash        => l_certificate_hash
                , o_resp_mess        => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_RSA_KEYPAIR_CERT'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => sec_api_const_pkg.AUTHORITY_TYPE_VISA
              , i_env_param3     => l_resp_message
            );

            o_key.key_type := sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET;
            o_key.key_index := i_key_index;
            o_key.expir_date := i_expir_date;
            o_key.modulus_length := i_modulus_length;
            o_key.exponent := i_exponent;
            o_key.public_key := l_public_key;
            o_key.private_key := l_private_key;
            o_key.public_key_mac := l_public_key_mac;
            o_certificate := l_certificate_data;
            o_hash := l_certificate_hash;

            trc_log_pkg.debug (
                i_text      => 'Generate issuer RSA key set (Visa) - ok'
            );
        end if;
    end;

    procedure generate_rsa_keypair (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_serial_number       in sec_api_type_pkg.t_tracking_number
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
        , i_authority_type      in com_api_type_pkg.t_dict_value
        , o_key                 out sec_api_type_pkg.t_rsa_key_rec
        , o_certificate         out com_api_type_pkg.t_key
        , o_hash                out com_api_type_pkg.t_key
    ) is
        l_sign_algorithm        com_api_type_pkg.t_tiny_id;
    begin
        trc_log_pkg.debug (
            i_text      => 'Generate issuer RSA key set'
        );
        
        trc_log_pkg.debug (
            i_text          => 'i_sign_algorithm [#1]'
            , i_env_param1  => i_sign_algorithm
        );
        l_sign_algorithm := to_number(substr(i_sign_algorithm, 5));
        
        case i_authority_type
            when sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
                generate_rsa_keypair_mc (
                    i_hsm_device_id       => i_hsm_device_id
                    , i_key_index         => i_key_index
                    , i_modulus_length    => i_modulus_length
                    , i_exponent          => i_exponent
                    , i_expir_date        => i_expir_date
                    , i_subject_id        => i_subject_id
                    , i_serial_number     => i_serial_number
                    , o_key               => o_key
                    , o_certificate       => o_certificate
                    , o_hash              => o_hash
                );

            when sec_api_const_pkg.AUTHORITY_TYPE_VISA then
                generate_rsa_keypair_visa (
                    i_hsm_device_id       => i_hsm_device_id
                    , i_key_index         => i_key_index
                    , i_modulus_length    => i_modulus_length
                    , i_exponent          => i_exponent
                    , i_expir_date        => i_expir_date
                    , i_sign_algorithm    => l_sign_algorithm
                    , i_tracking_number   => i_tracking_number
                    , i_subject_id        => i_subject_id
                    , i_visa_service_id   => i_visa_service_id
                    , o_key               => o_key
                    , o_certificate       => o_certificate
                    , o_hash              => o_hash
                );

        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_CERTIFICATION_AUTHORITY'
                , i_env_param1  => i_authority_type
            );

        end case;
        
        trc_log_pkg.debug (
            i_text      => 'Generate issuer RSA key set - ok'
        );
    end;
    
    procedure generate_rsa_keypair (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , o_public_key          out com_api_type_pkg.t_key
        , o_private_key         out com_api_type_pkg.t_key
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text      => 'Generate RSA key set'
        );

        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );          
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.generate_rsa_keypair (
                i_hsm_ip             => l_hsm_device.address
                , i_hsm_port         => l_hsm_device.port
                , i_lmk_id           => l_hsm_device.lmk_id
                , i_modulus_length   => i_modulus_length
                , i_exponent_length  => nvl(length(i_exponent), 0)
                , i_exponent         => i_exponent
                , o_public_key       => o_public_key
                , o_private_key      => o_private_key
                , o_resp_mess        => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_RSA_KEYPAIR_CERT'
              , i_env_param1     => i_hsm_device_id
              , i_env_param3     => l_resp_message
            );

            trc_log_pkg.debug (
                i_text      => 'Generate RSA key set - ok'
            );
        end if;
    end;

    procedure remove_rsa_key (
        i_key_id              in com_api_type_pkg.t_medium_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            sec_rsa_key_vw
        set
            seqnum = i_seqnum
        where
            id = i_key_id;

        delete from
            sec_rsa_key_vw
        where
            id = i_key_id;
    end;
end;
/
