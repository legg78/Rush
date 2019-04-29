create or replace package body sec_prc_rsa_certificate_pkg is
/************************************************************
 * RSA certificate process <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_sort_pkg <br />
 * @headcom
 ************************************************************/

    BEGIN_CERTIFICATE           constant com_api_type_pkg.t_name := '-----BEGIN CERTIFICATE-----';
    END_CERTIFICATE             constant com_api_type_pkg.t_name := '-----END CERTIFICATE-----';
    
    procedure make_certificate_request is
        l_estimated_count         com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;
        l_excepted_count          com_api_type_pkg.t_long_id := 0;
    begin
        savepoint request_process_start;

        trc_log_pkg.debug (
            i_text          => 'Generate Issuer RSA Key Set and make CA request'
        );
        
        prc_api_stat_pkg.log_start;

        -- get estimated count
        select
            count(*)
        into
            l_estimated_count
        from
            sec_rsa_key ik
            , sec_rsa_certificate_vw ic
            , sec_authority_vw ah
        where
            ik.key_type = sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET
            and ic.certified_key_id = ik.id
            and ic.certified_key_id = ic.authority_key_id
            and ic.state = sec_api_const_pkg.RSA_KEY_STATE_INIT
            and ah.id = ic.authority_id
            and ah.type in (sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD, sec_api_const_pkg.AUTHORITY_TYPE_VISA);

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        for rec in (
            select
                ic.id
                , ik.key_type
                , ik.key_index
                , ic.tracking_number
                , ic.subject_id
                , ah.type authority_type
                , ic.certificate certificate_data
                , ic.hash certificate_hash
            from
                sec_rsa_key ik
                , sec_rsa_certificate_vw ic
                , sec_authority_vw ah
            where
                ik.key_type = sec_api_const_pkg.SECURITY_RSA_ISS_KEYSET
                and ic.certified_key_id = ik.id
                and ic.certified_key_id = ic.authority_key_id
                and ic.state = sec_api_const_pkg.RSA_KEY_STATE_INIT
                and ah.id = ic.authority_id
                and ah.type in (sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD, sec_api_const_pkg.AUTHORITY_TYPE_VISA)
        ) loop
            begin
                savepoint processing_next_key;

                -- make certificate request
                sec_api_rsa_certificate_pkg.make_certificate_request (
                    i_key_index           => rec.key_index
                    , i_tracking_number   => rec.tracking_number
                    , i_subject_id        => rec.subject_id
                    , i_authority_type    => rec.authority_type
                    , i_certificate_data  => rec.certificate_data
                    , i_certificate_hash  => rec.certificate_hash
                );

                -- set state rsa key
                sec_api_rsa_certificate_pkg.set_certificate_state (
                    i_id       => rec.id
                    , i_state  => sec_api_const_pkg.RSA_KEY_STATE_ACTIVE
                );

            exception
                when others then
                    rollback to savepoint processing_next_key;
                            
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;
                    else
                        raise;
                    end if;
            end;
            
            l_processed_count := l_processed_count + 1;
                
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );

        end loop;
        
        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        
        trc_log_pkg.debug (
            i_text  => 'Generate Issuer RSA Key Set and make CA request finished...'
        );
    exception
        when others then
            rollback to savepoint request_process_start;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;

    procedure get_file_contents (
        i_file_name               in com_api_type_pkg.t_name
        , o_issuer_key_index      out com_api_type_pkg.t_tiny_id
        , o_authority_key_index   out com_api_type_pkg.t_tiny_id
        , o_authority_cert_data   out blob
        , o_authority_cert_hash   out blob
        , o_authority_type        out com_api_type_pkg.t_dict_value
        , o_tracking_number       out sec_api_type_pkg.t_tracking_number
    ) is
        l_authority_cert_name     com_api_type_pkg.t_name;
        l_authority_hash_name     com_api_type_pkg.t_name;
        
        procedure parsing_filenames (
            i_authority_type          in com_api_type_pkg.t_dict_value
        ) is
            l_issuer_index_string     com_api_type_pkg.t_text;
            l_key_index_string        com_api_type_pkg.t_text;
        begin
            trc_log_pkg.debug (
                i_text          => 'Parse Issuer Public Key Certificate filename [#1] authority [#2]'
                , i_env_param1  => i_file_name
                , i_env_param2  => i_authority_type
            );
        
            case i_authority_type
                when sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
                    l_issuer_index_string := substr(i_file_name, 8, 6);
                    l_key_index_string := substr(i_file_name, 16, 2);
                    
                    l_authority_cert_name := 'MCI' || l_key_index_string || '.sep';
                    l_authority_hash_name := 'MCI' || l_key_index_string || '.hep';

                    trc_log_pkg.debug (
                        i_text          => 'Self-certified Payment System Public Key [#1]'
                        , i_env_param1  => l_authority_cert_name
                    );

                    trc_log_pkg.debug (
                        i_text          => 'Hash-code calculated on a Payment System Public Key [#1]'
                        , i_env_param1  => l_authority_hash_name
                    );
                    
                when sec_api_const_pkg.AUTHORITY_TYPE_VISA then
                    l_issuer_index_string := null;
                    l_key_index_string := substr(i_file_name, 9, 2);
                    o_tracking_number := substr(i_file_name, 1, 6);

                    l_authority_cert_name := '%.' || 'V' || l_key_index_string;
                    l_authority_hash_name := null;

                    trc_log_pkg.debug (
                        i_text          => 'Self-certified Payment System Public Key [#1]'
                        , i_env_param1  => l_authority_cert_name
                    );
                    
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'UNKNOWN_CERTIFICATION_AUTHORITY'
                    , i_env_param1  => i_authority_type
                );

            end case;
            
            -- get key index
            o_issuer_key_index := prs_api_util_pkg.hex2dec (
                i_hex_string  => l_issuer_index_string
            );
            o_authority_key_index := prs_api_util_pkg.hex2dec (
                i_hex_string  => l_key_index_string
            );
            
            trc_log_pkg.debug (
                i_text          => 'CA Public Key index [#1]'
                , i_env_param1  => o_authority_key_index
            );
        end;
        
        function get_contents (
            i_file_name               in com_api_type_pkg.t_name
            , i_file_type             in com_api_type_pkg.t_dict_value
        ) return blob is
        begin
            trc_log_pkg.debug (
                i_text          => 'Getting file with name [#1] and type [#2]'
                , i_env_param1  => i_file_name
                , i_env_param2  => i_file_type
            );

            for rec in (
                select
                    s.file_name
                    , s.file_bcontents
                from
                    prc_session_file s
                    , prc_file_attribute_vw a
                    , prc_file_vw f
                where
                    s.session_id = prc_api_session_pkg.get_session_id
                    and lower(s.file_name) like lower(i_file_name)
                    and s.file_attr_id = a.id
                    and f.id = a.file_id
                    and f.file_type = i_file_type
                    and f.file_nature = prc_api_const_pkg.FILE_NATURE_BLOB
            ) loop
                trc_log_pkg.debug (
                    i_text          => 'File [#1] found'
                    , i_env_param1  => i_file_name
                    , i_env_param2  => rec.file_name
                );
                    
                return rec.file_bcontents;
            end loop;
                
            com_api_error_pkg.raise_error (
                i_error        => 'SEC_FILE_NOT_FOUND'
                , i_env_param1 => i_file_name
                , i_env_param2 => i_file_type
            );
            
            return empty_blob();
        end;
        
    begin
        -- parsing filenames
        case
            -- MasterCard
            when regexp_like(i_file_name, '^\d{6}-\d{4}[0-9A-Fa-f]{2}.c[0-9A-Fa-f]{2}+') then
                o_authority_type := sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD;
                
                parsing_filenames (
                    i_authority_type  => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
                );
                        
                -- get self-certified CA public key file contents
                o_authority_cert_data := get_contents (
                    i_file_name    => l_authority_cert_name
                    , i_file_type  => sec_api_const_pkg.FILE_TYPE_CA_PUBLIC_KEY
                );

                -- get hash-code calculated on a CA public key file contents
                o_authority_cert_hash := get_contents (
                    i_file_name    => l_authority_hash_name
                    , i_file_type  => sec_api_const_pkg.FILE_TYPE_HASH_CA_PUBLIC_KEY
                );

            -- Visa
            when regexp_like(i_file_name, '^\d{6}.i[0-9A-Fa-f]{2}+$') then
                o_authority_type := sec_api_const_pkg.AUTHORITY_TYPE_VISA;
                
                parsing_filenames (
                    i_authority_type  => sec_api_const_pkg.AUTHORITY_TYPE_VISA
                );
                        
                -- get self-certified payment CA key file contents
                o_authority_cert_data := get_contents (
                    i_file_name    => l_authority_cert_name
                    , i_file_type  => sec_api_const_pkg.FILE_TYPE_CA_PUBLIC_KEY
                );
                        
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_CA_FILE_NAME'
                , i_env_param1  => i_file_name
                , i_env_param2  => sec_api_const_pkg.FILE_TYPE_ISS_PUB_KEY_CERT
            );
        end case;
    end;
    
    procedure read_certificate_response is
    
        l_estimated_count             com_api_type_pkg.t_long_id := 0;
        l_excepted_count              com_api_type_pkg.t_long_id := 0;
        l_processed_count             com_api_type_pkg.t_long_id := 0;

        l_issuer_key_index            com_api_type_pkg.t_tiny_id;
        l_authority_key_index         com_api_type_pkg.t_tiny_id;
        
        l_tracking_number             sec_api_type_pkg.t_tracking_number;

        l_issuer_key                  sec_api_type_pkg.t_rsa_key_rec;
        l_authority_key               sec_api_type_pkg.t_rsa_key_rec;
        l_issuer_cert                 sec_api_type_pkg.t_rsa_certificate_rec;

        l_authority_type              com_api_type_pkg.t_dict_value;
        
        l_authority_cert_data         blob;
        l_authority_cert_hash         blob;
        
        l_hsm_device                  hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Read CA response'
        );
        
        prc_api_stat_pkg.log_start;
        
        savepoint read_process_start;

        -- get estimated count
        select
            count(s.id)
        into
            l_estimated_count
        from
            prc_session_file s
            , prc_file_attribute_vw a
            , prc_file_vw f
        where
            s.session_id = prc_api_session_pkg.get_session_id
            and s.file_attr_id = a.id
            and f.id = a.file_id
            and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
            and f.file_type = sec_api_const_pkg.FILE_TYPE_ISS_PUB_KEY_CERT
            and f.file_nature = prc_api_const_pkg.FILE_NATURE_BLOB;
            
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );
        
        -- get files
        for r in (
            select
                s.file_name
                , s.file_bcontents
            from
                prc_session_file s
                , prc_file_attribute_vw a
                , prc_file_vw f
            where
                s.session_id = prc_api_session_pkg.get_session_id
                and s.file_attr_id = a.id
                and f.id = a.file_id
                and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
                and f.file_type = sec_api_const_pkg.FILE_TYPE_ISS_PUB_KEY_CERT
                and f.file_nature = prc_api_const_pkg.FILE_NATURE_BLOB
            order by
                s.id
        ) loop
            begin
                savepoint processing_next_cert;
                
                -- get file contents
                get_file_contents (
                    i_file_name              => r.file_name
                    , o_issuer_key_index     => l_issuer_key_index
                    , o_authority_key_index  => l_authority_key_index
                    , o_authority_cert_data  => l_authority_cert_data
                    , o_authority_cert_hash  => l_authority_cert_hash
                    , o_authority_type       => l_authority_type
                    , o_tracking_number      => l_tracking_number
                );

                -- read certificates responce
                sec_api_rsa_certificate_pkg.read_certificate_response (
                    i_authority_type          => l_authority_type
                    , i_issuer_key_index      => l_issuer_key_index
                    , i_issuer_cert_data      => r.file_bcontents
                    , i_authority_key_index   => l_authority_key_index
                    , i_authority_cert_data   => l_authority_cert_data
                    , i_authority_cert_hash   => l_authority_cert_hash
                    , i_tracking_number       => l_tracking_number
                    , o_issuer_key            => l_issuer_key
                    , o_authority_key         => l_authority_key
                    , o_issuer_cert           => l_issuer_cert
                );

                -- get hsm device record
                l_hsm_device := hsm_api_device_pkg.get_hsm_device (
                    i_hsm_device_id  => null
                    , i_hsm_action   => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
                    , i_lmk_id       => l_issuer_key.lmk_id
                );

                -- verification of certificates
                sec_api_rsa_certificate_pkg.validate_iss_certificate (
                    i_issuer_key        => l_issuer_key
                    , io_authority_key  => l_authority_key
                    , i_issuer_cert     => l_issuer_cert
                    , i_hsm_device_id   => l_hsm_device.id
                );
                
                -- set authority rsa key
                sec_api_rsa_key_pkg.set_rsa_keypair (
                    io_id               => l_authority_key.id
                    , i_object_id       => l_authority_key.object_id
                    , i_entity_type     => l_authority_key.entity_type
                    , i_lmk_id          => l_hsm_device.lmk_id
                    , i_key_type        => l_authority_key.key_type
                    , i_key_index       => l_authority_key.key_index
                    , i_expir_date      => l_authority_key.expir_date
                    , i_sign_algorithm  => l_authority_key.sign_algorithm
                    , i_modulus_length  => l_authority_key.modulus_length
                    , i_exponent        => l_authority_key.exponent
                    , i_public_key      => l_authority_key.public_key
                    , i_private_key     => null
                    , i_public_key_mac  => l_authority_key.public_key_mac
                );

                -- set authority self certificate
                sec_api_rsa_certificate_pkg.set_certificate (
                    i_certified_key_id    => l_authority_key.id
                    , i_authority_key_id  => l_authority_key.id
                    , i_authority_id      => l_issuer_cert.authority_id
                    , i_state             => sec_api_const_pkg.RSA_KEY_STATE_ACTIVE
                    , i_certificate       => l_authority_key.certificate
                    , i_reminder          => l_authority_key.reminder
                    , i_hash              => l_authority_key.hash
                    , i_expir_date        => l_authority_key.expir_date
                    , i_tracking_number   => null
                    , i_subject_id        => l_authority_key.subject_id
                    , i_serial_number     => l_authority_key.serial_number
                    , i_visa_service_id   => l_authority_key.visa_service_id
                );
        
                -- set issuer certificates
                sec_api_rsa_certificate_pkg.set_certificate (
                    i_certified_key_id    => l_issuer_cert.certified_key_id
                    , i_authority_key_id  => l_issuer_cert.authority_key_id
                    , i_authority_id      => l_issuer_cert.authority_id
                    , i_state             => sec_api_const_pkg.RSA_KEY_STATE_ACTIVE
                    , i_certificate       => l_issuer_cert.certificate
                    , i_reminder          => l_issuer_cert.reminder
                    , i_hash              => l_issuer_cert.hash
                    , i_expir_date        => l_authority_key.expir_date
                    , i_tracking_number   => l_issuer_cert.tracking_number
                    , i_subject_id        => l_issuer_cert.subject_id
                    , i_serial_number     => l_issuer_cert.serial_number
                    , i_visa_service_id   => l_issuer_cert.visa_service_id
                );
                
            exception
                when others then
                    rollback to savepoint processing_next_cert;
                                
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;
                    else
                        raise;
                    end if;
            end;
            
            l_processed_count := l_processed_count + 1;
                
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );
        end loop;
        
        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        
        trc_log_pkg.debug (
            i_text  => 'Read CA response finished...'
        );

    exception
        when others then
            rollback to savepoint read_process_start;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;
    
    procedure load_ips_cert (
        i_inst_id                     in com_api_type_pkg.t_inst_id
        , i_network_id                in com_api_type_pkg.t_tiny_id
        , i_key_type                  in com_api_type_pkg.t_dict_value
    ) is
        l_excepted_count              com_api_type_pkg.t_long_id := 0;
        l_processed_count             com_api_type_pkg.t_long_id := 0;

        l_ips_cert                    sec_api_type_pkg.t_rsa_key_rec;
        
        l_host_id                     com_api_type_pkg.t_tiny_id;
        
    begin
        trc_log_pkg.debug (
            i_text          => 'Load ips certificate [#1]'
            , i_env_param1  => i_key_type
        );
        
        prc_api_stat_pkg.log_start;
        
        savepoint read_process_start;

        -- get files
        for session_file in (
            select
                s.id
                , s.file_name
                , count(*) over() cnt
                , row_number() over (order by s.id) rn
                , row_number() over (order by s.id desc) rn_desc
            from
                prc_session_file s
                , prc_file_attribute fa
                , prc_file f
            where
                fa.id = s.file_attr_id
                and f.id = fa.file_id
                and f.file_purpose = prc_api_file_pkg.get_file_purpose_in
                and s.session_id = get_session_id
            order by
                s.id
        ) loop
            -- set estimated count
            if session_file.rn = 1 then
                prc_api_stat_pkg.log_estimation (
                    i_estimated_count  => session_file.cnt
                );
                
                l_host_id := net_api_network_pkg.get_member_id (
                    i_inst_id       => i_inst_id
                    , i_network_id  => i_network_id
                );
            end if;
          
            trc_log_pkg.debug (
                i_text          => 'Process file name [#1]'
                , i_env_param1  => session_file.file_name
            );
            
            for cert in (
                select
                    public_key
                from (
                    select
                        replace(sys_connect_by_path(raw_data, '--DELIMER--'), '--DELIMER--') public_key
                    from (
                        select
                            record_number id
                            , lag(record_number) over (order by record_number) as prev_id
                            , raw_data
                        from
                            prc_file_raw_data
                        where
                            session_file_id = session_file.id
                            and raw_data not in (BEGIN_CERTIFICATE, END_CERTIFICATE)
                    )
                    start with
                        prev_id is null
                    connect by
                        prev_id = prior id
                    order by 1
                        desc
                )
                where
                    rownum = 1
            ) loop
                begin
                    savepoint processing_next_cert;
                    
                    -- get rsa key
                    l_ips_cert := sec_api_rsa_key_pkg.get_rsa_key (
                        i_id             => null
                        , i_object_id    => l_host_id
                        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                        , i_key_type     => i_key_type
                        , i_key_index    => null
                        , i_mask_error   => com_api_type_pkg.TRUE
                    );
            
                    -- set rsa key
                    sec_api_rsa_key_pkg.set_rsa_keypair (
                        io_id               => l_ips_cert.id
                        , i_object_id       => l_host_id
                        , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_HOST
                        , i_lmk_id          => null
                        , i_key_type        => i_key_type
                        , i_key_index       => null
                        , i_expir_date      => null
                        , i_sign_algorithm  => null
                        , i_modulus_length  => null
                        , i_exponent        => null
                        , i_public_key      => cert.public_key
                        , i_private_key     => null
                        , i_public_key_mac  => null
                    );
                    
                exception
                    when others then
                        rollback to savepoint processing_next_cert;
                                    
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            raise;
                        end if;
                end;
                
                l_processed_count := l_processed_count + 1;
                    
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                    , i_excepted_count  => l_excepted_count
                );
            end loop;
            
            if session_file.rn_desc = 1 then
                prc_api_stat_pkg.log_end (
                    i_excepted_total     => l_excepted_count
                    , i_processed_total  => l_processed_count
                    , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
                );
            end if;
        end loop;
        
        trc_log_pkg.debug (
            i_text  => 'Load ips certificate finished...'
        );

    exception
        when others then
            rollback to savepoint read_process_start;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;
    
    procedure load_ips_root_cert (
        i_inst_id                     in com_api_type_pkg.t_inst_id
        , i_network_id                in com_api_type_pkg.t_tiny_id
    ) is
    begin
        load_ips_cert (
            i_inst_id       => i_inst_id
            , i_network_id  => i_network_id
            , i_key_type    => sec_api_const_pkg.SECURITY_RSA_IPS_ROOT_CERT
        );
    end;
    
    procedure load_intermediate_cert (
        i_inst_id                     in com_api_type_pkg.t_inst_id
        , i_network_id                in com_api_type_pkg.t_tiny_id
    ) is
    begin
        load_ips_cert (
            i_inst_id       => i_inst_id
            , i_network_id  => i_network_id
            , i_key_type    => sec_api_const_pkg.SECURITY_RSA_INTERMED_CERT
        );
    end;
    
    procedure load_acs_cert (
        i_bin                         in com_api_type_pkg.t_bin
        , i_authority_id              in com_api_type_pkg.t_tiny_id
    ) is
        l_excepted_count              com_api_type_pkg.t_long_id := 0;
        l_processed_count             com_api_type_pkg.t_long_id := 0;

        l_acs_key                     sec_api_type_pkg.t_rsa_key_rec;
        l_bin                         iss_api_type_pkg.t_bin_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Load acs certificate'
        );

        prc_api_stat_pkg.log_start;

        savepoint read_process_start;

        -- get files
        for session_file in (
            select
                s.id
                , s.file_name
                , count(*) over() cnt
                , row_number() over (order by s.id) rn
                , row_number() over (order by s.id desc) rn_desc
            from
                prc_session_file s
                , prc_file_attribute fa
                , prc_file f
            where
                fa.id = s.file_attr_id
                and f.id = fa.file_id
                and f.file_purpose = prc_api_file_pkg.get_file_purpose_in
                and s.session_id = get_session_id
            order by
                s.id
        ) loop
            -- set estimated count
            if session_file.rn = 1 then
                prc_api_stat_pkg.log_estimation (
                    i_estimated_count  => session_file.cnt
                );
            end if;

            trc_log_pkg.debug (
                i_text          => 'Process file name [#1]'
                , i_env_param1  => session_file.file_name
            );

            for cert in (
                select
                    certificate
                from (
                    select
                        replace(sys_connect_by_path(raw_data, '--DELIMER--'), '--DELIMER--') certificate
                    from (
                        select
                            record_number id
                            , lag(record_number) over (order by record_number) as prev_id
                            , raw_data
                        from
                            prc_file_raw_data
                        where
                            session_file_id = session_file.id
                            and raw_data not in (BEGIN_CERTIFICATE, END_CERTIFICATE)
                    )
                    start with
                        prev_id is null
                    connect by
                        prev_id = prior id
                    order by 1
                        desc
                )
                where
                    rownum = 1
            ) loop
                begin
                    savepoint processing_next_cert;

                    l_bin := iss_api_bin_pkg.get_bin (
                        i_bin  => i_bin
                    );

                    -- get rsa key
                    l_acs_key := sec_api_rsa_key_pkg.get_rsa_key (
                        i_id             => null
                        , i_object_id    => l_bin.id
                        , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
                        , i_key_type     => sec_api_const_pkg.SECURITY_RSA_ACS_KEYSET
                        , i_key_index    => null
                        , i_mask_error   => com_api_type_pkg.FALSE
                    );

                    -- set acs certificate
                    sec_api_rsa_certificate_pkg.set_certificate (
                        i_certified_key_id    => l_acs_key.id
                        , i_authority_key_id  => l_acs_key.id
                        , i_authority_id      => i_authority_id
                        , i_state             => sec_api_const_pkg.RSA_KEY_STATE_ACTIVE
                        , i_certificate       => cert.certificate
                        , i_reminder          => null
                        , i_hash              => null
                        , i_expir_date        => null
                        , i_tracking_number   => null
                        , i_subject_id        => null
                        , i_serial_number     => null
                        , i_visa_service_id   => null
                    );

                exception
                    when others then
                        rollback to savepoint processing_next_cert;

                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            raise;
                        end if;
                end;

                l_processed_count := l_processed_count + 1;

                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                    , i_excepted_count  => l_excepted_count
                );
            end loop;

            if session_file.rn_desc = 1 then
                prc_api_stat_pkg.log_end (
                    i_excepted_total     => l_excepted_count
                    , i_processed_total  => l_processed_count
                    , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
                );
            end if;
        end loop;

        trc_log_pkg.debug (
            i_text  => 'Load acs certificate finished...'
        );

    exception
        when others then
            rollback to savepoint read_process_start;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;

end; 
/
