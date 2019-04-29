create or replace package body sec_ui_rsa_key_pkg is
/************************************************************
 * User interface for RSA keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: sec_ui_rsa_key_pkg <br />
 * @headcom
 ************************************************************/
    
    procedure generate_rsa_keypair (
        o_id                    out com_api_type_pkg.t_medium_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_type            in com_api_type_pkg.t_dict_value
        , i_key_index           in com_api_type_pkg.t_tiny_id := null
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value := null
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date := null
    ) is
        l_public_key            com_api_type_pkg.t_key;
        l_private_key           com_api_type_pkg.t_key;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
        
    begin
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
        
        -- generate issuer key pair
        sec_api_rsa_key_pkg.generate_rsa_keypair (
            i_hsm_device_id     => i_hsm_device_id
            , i_modulus_length  => i_modulus_length
            , i_exponent        => i_exponent
            , o_public_key      => l_public_key
            , o_private_key     => l_private_key
        );
        
        begin
            select
                id
                , seqnum
            into
                o_id
                , o_seqnum
            from
                sec_rsa_key_vw
            where
                key_type = i_key_type
                and (key_index = i_key_index or i_key_index is null)
                and entity_type = i_entity_type
                and object_id = i_object_id;

            delete from
                sec_rsa_certificate_vw
            where
                certified_key_id = o_id
                or authority_key_id = o_id;
                
            update
                sec_rsa_key_vw
            set
                lmk_id = l_hsm_device.lmk_id
                , modulus_length = i_modulus_length
                , exponent = i_exponent
                , public_key = l_public_key
                , private_key = l_private_key
                , public_key_mac = null
                , key_type = i_key_type
                , key_index = i_key_index
                , expir_date = i_expir_date
                , sign_algorithm = i_sign_algorithm
                , generate_date = get_sysdate
                , generate_user_id = get_user_id
            where
                id = o_id;
            
            o_seqnum := o_seqnum + 1;
        exception
            when no_data_found then
                o_id := sec_rsa_key_seq.nextval;
                o_seqnum := 1;
                    
                begin
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
                        , generate_date
                        , generate_user_id
                    ) values (
                        o_id
                        , o_seqnum
                        , i_object_id
                        , i_entity_type
                        , l_hsm_device.lmk_id
                        , i_key_type
                        , i_key_index
                        , i_expir_date
                        , i_sign_algorithm
                        , i_modulus_length
                        , i_exponent
                        , l_public_key
                        , l_private_key
                        , null
                        , get_sysdate
                        , get_user_id
                    );
                exception
                    when dup_val_on_index then
                        com_api_error_pkg.raise_error (
                            i_error         => 'DUPLICATE_RSA_KEY'
                            , i_env_param1  => i_key_index
                            , i_env_param2  => i_key_type
                            , i_env_param3  => i_entity_type
                            , i_env_param4  => i_object_id
                        );
                end;
        end;
    end;
    
    procedure generate_rsa_keypair (
        o_id                    out com_api_type_pkg.t_medium_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_authority_id        in com_api_type_pkg.t_tiny_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in sec_api_type_pkg.t_subject_id
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_description         in com_api_type_pkg.t_full_desc
        , i_authority_key_index in com_api_type_pkg.t_tiny_id
    ) is
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
        l_authority             sec_api_type_pkg.t_authority_rec;
        l_rsa_key               sec_api_type_pkg.t_rsa_key_rec;
        l_certificate           com_api_type_pkg.t_key;
        l_hash                  com_api_type_pkg.t_key;
    begin
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        begin
            select
                id
                , seqnum
            into
                o_id
                , o_seqnum
            from
                sec_rsa_key_vw
            where
                key_type = sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET
                and key_index = i_key_index
                and entity_type = i_entity_type
                and object_id = i_object_id;
        exception
            when no_data_found then
                o_id := sec_rsa_key_seq.nextval;
                o_seqnum := 1;
        end;
        
        -- get authority
        l_authority := sec_api_authority_pkg.get_authority (
            i_id  => i_authority_id
        );

        -- generate issuer key pair
        sec_api_rsa_key_pkg.generate_rsa_keypair (
            i_hsm_device_id       => i_hsm_device_id
            , i_key_index         => i_key_index
            , i_modulus_length    => i_modulus_length
            , i_exponent          => i_exponent
            , i_expir_date        => i_expir_date
            , i_sign_algorithm    => i_sign_algorithm
            , i_tracking_number   => i_tracking_number
            , i_subject_id        => i_subject_id
            , i_serial_number     => o_id
            , i_visa_service_id   => i_visa_service_id
            , i_authority_type    => l_authority.authority_type
            , o_key               => l_rsa_key
            , o_certificate       => l_certificate
            , o_hash              => l_hash
        );
        
        update
            sec_rsa_key_vw
        set
            seqnum = o_seqnum
            , expir_date = i_expir_date
            , sign_algorithm = i_sign_algorithm
            , modulus_length = l_rsa_key.modulus_length
            , exponent = l_rsa_key.exponent
            , public_key = l_rsa_key.public_key
            , private_key = l_rsa_key.private_key
            , public_key_mac = l_rsa_key.public_key_mac
            , generate_date = get_sysdate
            , generate_user_id = get_user_id
        where
            id = o_id;
        
        if sql%rowcount > 0 then
            o_seqnum := o_seqnum + 1;
        
        else
            begin
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
                    , generate_date
                    , generate_user_id
                ) values (
                    o_id
                    , o_seqnum
                    , i_object_id
                    , i_entity_type
                    , l_hsm_device.lmk_id
                    , sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET
                    , i_key_index
                    , i_expir_date
                    , i_sign_algorithm
                    , l_rsa_key.modulus_length
                    , l_rsa_key.exponent
                    , l_rsa_key.public_key
                    , l_rsa_key.private_key
                    , l_rsa_key.public_key_mac
                    , get_sysdate
                    , get_user_id
                );
            exception
                when dup_val_on_index then
                    com_api_error_pkg.raise_error (
                        i_error         => 'DUPLICATE_RSA_KEY'
                        , i_env_param1  => i_key_index
                        , i_env_param2  => sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET
                        , i_env_param3  => i_entity_type
                        , i_env_param4  => i_object_id
                    );
            end;
            
        end if;

        com_api_i18n_pkg.add_text (
            i_table_name     => 'sec_rsa_key'
            , i_column_name  => 'description'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_description
        );
        
        -- set certified rsa self certificate
        sec_api_rsa_certificate_pkg.set_certificate (
            i_certified_key_id    => o_id
            , i_authority_key_id  => o_id
            , i_authority_id      => i_authority_id -- ??? SYSTEM
            , i_state             => sec_api_const_pkg.RSA_KEY_STATE_INIT
            , i_certificate       => l_certificate
            , i_reminder          => null
            , i_hash              => l_hash
            , i_expir_date        => l_rsa_key.expir_date
            , i_tracking_number   => i_tracking_number
            , i_subject_id        => i_subject_id
            , i_serial_number     => o_id
            , i_visa_service_id   => i_visa_service_id
        );
        
        -- link authority key
        if i_authority_key_index is not null then
            sec_ui_rsa_key_pkg.link_authority_key_index (
                i_certified_key_id       => o_id
                , i_authority_key_index  => i_authority_key_index
            );
        end if;
    end;

    procedure remove_rsa_keypair (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        delete from
            sec_rsa_certificate_vw
        where
            certified_key_id = i_id
            or authority_key_id = i_id;

        com_api_i18n_pkg.remove_text (
            i_table_name   => 'sec_rsa_key'
            , i_object_id  => i_id
        );

        update
            sec_rsa_key_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            sec_rsa_key_vw
        where
            id = i_id;
    end;
    
    procedure link_authority_key_index (
        i_certified_key_id      in com_api_type_pkg.t_medium_id
        , i_authority_key_index in com_api_type_pkg.t_tiny_id
    ) is
        l_authority_key         sec_api_type_pkg.t_rsa_key_rec;
        l_id                    com_api_type_pkg.t_medium_id;
    begin
        for certified_key in (
            select
                k.id
                , k.seqnum
                , k.object_id
                , k.entity_type
                , k.lmk_id
                , k.key_type
                , k.key_index
                , k.expir_date
                , k.sign_algorithm
                , k.modulus_length
                , k.exponent
                , k.public_key
                , k.private_key
                , k.public_key_mac
                , c.authority_id
            from
                sec_rsa_key_vw k
                , sec_rsa_certificate_vw c
            where
                k.id = i_certified_key_id
                and c.certified_key_id = k.id
                and c.authority_key_id = k.id
        ) loop
            -- remove issuer public key certificate
            for certificate in (
                select
                    c.id
                    , c.seqnum
                from
                    sec_rsa_certificate_vw c
                where
                    c.certified_key_id = certified_key.id
                    and c.authority_key_id != c.certified_key_id
            ) loop
                -- remove certificate
                sec_ui_rsa_certificate_pkg.remove_certificate (
                    i_id        => certificate.id
                    , i_seqnum  => certificate.seqnum
                );
            end loop;
            
            l_authority_key := sec_api_rsa_key_pkg.get_authority_key (
                i_key_index       => i_authority_key_index
                , i_authority_id  => certified_key.authority_id
                , i_mask_error    => com_api_type_pkg.true
            );

            -- set authority rsa keypair
            if l_authority_key.id is null then
                sec_api_rsa_key_pkg.set_rsa_keypair (
                    io_id               => l_authority_key.id
                    , i_object_id       => certified_key.authority_id
                    , i_entity_type     => sec_api_const_pkg.ENTITY_TYPE_AUTHORITY
                    , i_lmk_id          => certified_key.lmk_id
                    , i_key_type        => sec_api_const_pkg.SECURITY_RSA_CA_KEYSET
                    , i_key_index       => i_authority_key_index
                    , i_expir_date      => null
                    , i_sign_algorithm  => null
                    , i_modulus_length  => null
                    , i_exponent        => null
                    , i_public_key      => null
                    , i_private_key     => null
                    , i_public_key_mac  => null
                );
            end if;

            -- set authority rsa certificate
            sec_api_rsa_certificate_pkg.set_certificate (
                io_id                 => l_id
                , i_certified_key_id  => certified_key.id
                , i_authority_key_id  => l_authority_key.id
                , i_authority_id      => certified_key.authority_id
                , i_state             => sec_api_const_pkg.RSA_KEY_STATE_INIT
                , i_certificate       => null
                , i_reminder          => null
                , i_hash              => null
                , i_expir_date        => null
                , i_tracking_number   => null
                , i_subject_id        => null
                , i_serial_number     => null
                , i_visa_service_id   => null
            );
            
            return;
        end loop;
        
        com_api_error_pkg.raise_error (
            i_error         => 'RSA_KEY_NOT_FOUND'
            , i_env_param1  => i_certified_key_id
            , i_env_param2  => null
            , i_env_param3  => null
        );
    end;
    
    procedure set_rsa_keypair (
        io_id                   in out com_api_type_pkg.t_medium_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_lmk_id              in com_api_type_pkg.t_tiny_id
        , i_key_type            in com_api_type_pkg.t_dict_value
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_expir_date          in date := null
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_public_key          in com_api_type_pkg.t_key
        , i_private_key         in com_api_type_pkg.t_key
        , i_public_key_mac      in com_api_type_pkg.t_pin_block
    ) is
    begin
        sec_api_rsa_key_pkg.set_rsa_keypair (
            io_id               => io_id
            , i_object_id       => i_object_id
            , i_entity_type     => i_entity_type
            , i_lmk_id          => i_lmk_id
            , i_key_type        => i_key_type
            , i_key_index       => i_key_index
            , i_expir_date      => i_expir_date
            , i_sign_algorithm  => i_sign_algorithm
            , i_modulus_length  => i_modulus_length
            , i_exponent        => i_exponent
            , i_public_key      => i_public_key
            , i_private_key     => i_private_key
            , i_public_key_mac  => i_public_key_mac
        );
    end;

end;
/
