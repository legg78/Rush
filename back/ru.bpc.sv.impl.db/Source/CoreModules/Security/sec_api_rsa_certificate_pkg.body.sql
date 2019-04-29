create or replace package body sec_api_rsa_certificate_pkg is
/**********************************************************
 * API for RSA certificate
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_rsa_certificate_pkg
 * @headcom
 **********************************************************/    

    function get_certificate (
        i_authority_key_id          in com_api_type_pkg.t_medium_id
        , i_certified_key_id        in com_api_type_pkg.t_medium_id
        , i_mask_error              in com_api_type_pkg.t_boolean
    ) return sec_api_type_pkg.t_rsa_certificate_rec is
        l_result                    sec_api_type_pkg.t_rsa_certificate_rec;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting RSA certificate [#1][#2]'
            , i_env_param1  => i_authority_key_id
            , i_env_param2  => i_certified_key_id
        );

        begin
            select
                c.id
                , c.state
                , c.authority_id
                , a.type
                , c.certified_key_id
                , c.authority_key_id
                , c.certificate
                , c.reminder
                , c.hash
                , c.expir_date
                , c.tracking_number
                , c.subject_id
                , c.serial_number
                , c.visa_service_id
            into
                l_result
            from
                sec_rsa_certificate_vw c
                , sec_authority_vw a
            where
                c.authority_key_id = i_authority_key_id
                and c.certified_key_id = i_certified_key_id
                and a.id = c.authority_id;
        exception
            when no_data_found then
                if i_mask_error = com_api_type_pkg.FALSE then
                    com_api_error_pkg.raise_error (
                        i_error         => 'RSA_CERTIFICATE_KEYS_NOT_FOUND'
                        , i_env_param1  => i_authority_key_id
                        , i_env_param2  => i_certified_key_id
                    );
                else
                    trc_log_pkg.error (
                        i_text          => 'RSA key [#1][#2] not found'
                        , i_env_param1  => i_authority_key_id
                        , i_env_param2  => i_certified_key_id
                    );
                    l_result := null;
                end if;
        end;
        
        return l_result;
    end;

    procedure set_certificate (
        i_certified_key_id          in com_api_type_pkg.t_medium_id
        , i_authority_key_id        in com_api_type_pkg.t_medium_id
        , i_authority_id            in com_api_type_pkg.t_tiny_id
        , i_state                   in com_api_type_pkg.t_dict_value
        , i_certificate             in com_api_type_pkg.t_key
        , i_reminder                in com_api_type_pkg.t_key
        , i_hash                    in com_api_type_pkg.t_key
        , i_expir_date              in date
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_serial_number           in sec_api_type_pkg.t_serial_number
        , i_visa_service_id         in com_api_type_pkg.t_dict_value
    ) is
    begin
        trc_log_pkg.debug (
            i_text  => 'Going to flush RSA certificate'
        );

        merge into sec_rsa_certificate dst
        using (
            select
                i_certified_key_id certified_key_id
                , i_authority_key_id authority_key_id
                , i_authority_id authority_id
                , i_state state
                , i_certificate certificate
                , i_reminder reminder
                , i_hash hash
                , i_expir_date expir_date
                , i_tracking_number tracking_number
                , i_subject_id subject_id
                , i_serial_number serial_number
                , i_visa_service_id visa_service_id
            from
                dual
        ) src
        on (
            src.certified_key_id = dst.certified_key_id
            and src.authority_key_id = dst.authority_key_id
        )
        when matched then
            update
            set
                dst.certificate = src.certificate
                , dst.reminder = src.reminder
                , dst.hash = src.hash
                , dst.expir_date = src.expir_date
                , dst.tracking_number = src.tracking_number
                , dst.subject_id = src.subject_id
                , dst.serial_number = src.serial_number
                , dst.visa_service_id = src.visa_service_id
                , dst.state = src.state
        when not matched then
            insert (
                dst.id
                , dst.seqnum
                , dst.state
                , dst.authority_id
                , dst.certified_key_id
                , dst.authority_key_id
                , dst.certificate
                , dst.reminder
                , dst.hash
                , dst.expir_date
                , dst.tracking_number
                , dst.subject_id
                , dst.serial_number
                , dst.visa_service_id
            ) values (
                sec_rsa_certificate_seq.nextval
                , 1
                , src.state
                , src.authority_id
                , src.certified_key_id
                , src.authority_key_id
                , src.certificate
                , src.reminder
                , src.hash
                , src.expir_date
                , src.tracking_number
                , src.subject_id
                , src.serial_number
                , src.visa_service_id
            );

        trc_log_pkg.debug (
            i_text  => 'RSA certificate saved'
        );
    end;
    
    procedure set_certificate (
        io_id                       in out com_api_type_pkg.t_medium_id
        , i_certified_key_id        in com_api_type_pkg.t_medium_id
        , i_authority_key_id        in com_api_type_pkg.t_medium_id
        , i_authority_id            in com_api_type_pkg.t_tiny_id
        , i_state                   in com_api_type_pkg.t_dict_value
        , i_certificate             in com_api_type_pkg.t_key
        , i_reminder                in com_api_type_pkg.t_key
        , i_hash                    in com_api_type_pkg.t_key
        , i_expir_date              in date
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_serial_number           in sec_api_type_pkg.t_serial_number
        , i_visa_service_id         in com_api_type_pkg.t_dict_value
    ) is
    begin
        trc_log_pkg.debug (
            i_text  => 'Going to flush certificate'
        );

        if io_id is null then
            io_id := sec_rsa_certificate_seq.nextval;
            
            insert into sec_rsa_certificate_vw (
                id
                , seqnum
                , state
                , authority_id
                , certified_key_id
                , authority_key_id
                , certificate
                , reminder
                , hash
                , expir_date
                , tracking_number
                , subject_id
                , serial_number
                , visa_service_id
            ) values (
                io_id
                , 1
                , i_state
                , i_authority_id
                , i_certified_key_id
                , i_authority_key_id
                , i_certificate
                , i_reminder
                , i_hash
                , i_expir_date
                , i_tracking_number
                , i_subject_id
                , i_serial_number
                , i_visa_service_id
            );
            
        else
            update sec_rsa_certificate_vw
            set
                certificate = i_certificate
                , reminder = i_reminder
                , hash = i_hash
                , expir_date = i_expir_date
                , tracking_number = i_tracking_number
                , subject_id = i_subject_id
                , serial_number = i_serial_number
                , visa_service_id = i_visa_service_id
                , state = i_state
            where
                id = io_id;

        end if;

        trc_log_pkg.debug (
            i_text  => 'Certificate saved'
        );
    end;
    
    procedure set_certificate_state (
        i_id                      in com_api_type_pkg.t_medium_id
        , i_state                 in com_api_type_pkg.t_dict_value
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Going to set state[#1] certificate [#2]'
            , i_env_param1  => i_state
            , i_env_param2  => i_id
        );

        update
            sec_rsa_certificate_vw
        set
            state = i_state
        where
            id = i_id;

        trc_log_pkg.debug (
            i_text          => 'Certificate set saved'
        );
    end;
    
    procedure get_ca_pk_hash_data (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_key_index               in com_api_type_pkg.t_tiny_id
        , i_exponent                in com_api_type_pkg.t_exponent
        , i_public_key              in com_api_type_pkg.t_key
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , o_hash                    out com_api_type_pkg.t_key
    ) is
        l_data                      com_api_type_pkg.t_text;
    begin
        trc_log_pkg.debug (
           i_text  => 'Getting certification authority public key hash data'
        );
        
        l_data := -- rid
                  i_subject_id
                  -- ca public key index
                  || prs_api_util_pkg.dec2hex(
                         i_dec_number  => i_key_index
                     )
                  -- ca public key modulus
                  || i_public_key
                  -- ca public exponent
                  || i_exponent;
        
        prs_api_command_pkg.hash_block_data (
            i_data             => l_data
            , i_hsm_device_id  => i_hsm_device_id
            , o_hash           => o_hash
        );
         
        trc_log_pkg.debug (
           i_text  => 'Get certification authority public key hash data - ok'
        );
    end;
    
    procedure make_certificate_request_mc (
        i_key_index                 in com_api_type_pkg.t_tiny_id
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_certificate_data        in com_api_type_pkg.t_key
        , i_certificate_hash        in com_api_type_pkg.t_key
    ) is
        l_session_file_id           com_api_type_pkg.t_long_id;
        l_binary_cert_data          blob;--com_api_type_pkg.t_lob_data;
        l_binary_cert_hash          blob;--com_api_type_pkg.t_lob_data;
        l_params                    com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
           i_text  => 'Make certificate request (Mastercard)'
        );
         
        trc_log_pkg.debug (
           i_text          => 'key_index[#1] tracking_number [#2] subject_id[#3]'
           , i_env_param1  => i_key_index
           , i_env_param2  => i_tracking_number
           , i_env_param3  => i_subject_id
        );
        
        l_binary_cert_data := -- clear public key data and self-certified public key
                              hextoraw(i_certificate_data)
                              ;
        
        l_binary_cert_hash := -- certificate subject id
                              hextoraw(rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_subject_id
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                                  , i_pad_string  => 'F'
                                  , i_length      => 4
                              )
                              -- issuer public key index
                              || 
                              rul_api_name_pkg.pad_byte_len (
                                  i_src           => prs_api_util_pkg.dec2hex( i_dec_number  => i_key_index )
                                  , i_length      => 3
                              )
                              -- public key algorithm id
                              || '01'--HASH_ALGORITHM_RSA
                              -- hash
                              || i_certificate_hash
                              );
        
        rul_api_param_pkg.set_param (
            i_name       => 'TRACKING_NUMBER'
            , i_value    => i_tracking_number
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'KEY_INDEX'
            , i_value    => i_key_index
            , io_params  => l_params
        );
        
        -- public key file (extension '.sip')
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , i_file_type   => sec_api_const_pkg.FILE_TYPE_ISS_PUBLIC_KEY_MC
            , io_params     => l_params
        );
        
        prc_api_file_pkg.put_file (
            i_sess_file_id  => l_session_file_id
            , i_blob_content  => l_binary_cert_data
        );
        
        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
         
        -- hash-code file (extension '.hip')
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , i_file_type   => sec_api_const_pkg.FILE_TYPE_HASH_ISS_PUBLIC_KEY
            , io_params     => l_params
        );
        
        prc_api_file_pkg.put_file (
            i_sess_file_id  => l_session_file_id
            , i_blob_content  => l_binary_cert_hash
        );
        
        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        
        trc_log_pkg.debug (
            i_text  => 'Make certificate request (Mastercard) - ok'
        );   
        
    end;
    
    procedure make_certificate_request_visa (
        i_key_index                 in com_api_type_pkg.t_tiny_id
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_certificate_data        in com_api_type_pkg.t_key
    ) is
        l_session_file_id           com_api_type_pkg.t_long_id;
        l_binary_cert_data          blob;--com_api_type_pkg.t_lob_data;
        l_params                    com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
            i_text  => 'Make certification authority request (Visa)'
        );
        
        trc_log_pkg.debug (
           i_text          => 'key_index[#1] tracking_number [#2]'
           , i_env_param1  => i_key_index
           , i_env_param2  => i_tracking_number
        );
        
        l_binary_cert_data := -- clear public key data and self-certified public key
                              hextoraw(i_certificate_data)
                              ;

        rul_api_param_pkg.set_param (
            i_name       => 'TRACKING_NUMBER'
            , i_value    => i_tracking_number
            , io_params  => l_params
        );
        
        -- public key file (extension '.inp')
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , i_file_type   => sec_api_const_pkg.FILE_TYPE_ISS_PUBLIC_KEY_VISA
            , io_params     => l_params
        );
        
        prc_api_file_pkg.put_file (
            i_sess_file_id  => l_session_file_id
            , i_blob_content  => l_binary_cert_data
        );
        
        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        
        trc_log_pkg.debug (
            i_text  => 'Make certification authority request (Visa) - ok'
        );   
        
    end;

    procedure make_certificate_request (
        i_key_index                 in com_api_type_pkg.t_tiny_id
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_authority_type          in com_api_type_pkg.t_dict_value
        , i_certificate_data        in com_api_type_pkg.t_key
        , i_certificate_hash        in com_api_type_pkg.t_key
    ) is
    begin
        trc_log_pkg.debug (
            i_text      => 'Make certificate request'
        );
        
        case i_authority_type
            when sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
                make_certificate_request_mc (
                    i_key_index           => i_key_index
                    , i_tracking_number   => i_tracking_number
                    , i_subject_id        => i_subject_id
                    , i_certificate_data  => i_certificate_data
                    , i_certificate_hash  => i_certificate_hash
                );
                
            when sec_api_const_pkg.AUTHORITY_TYPE_VISA then
                make_certificate_request_visa (
                    i_key_index           => i_key_index
                    , i_tracking_number   => i_tracking_number
                    , i_certificate_data  => i_certificate_data
                );
                
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_CERTIFICATION_AUTHORITY'
                , i_env_param1  => i_authority_type
            );

        end case;
        
        trc_log_pkg.debug (
            i_text      => 'Make certificate request - ok'
        );
    end;

    procedure read_certificate_response_mc (
        i_issuer_cert_data          in blob
        , i_authority_cert_data     in blob
        , i_authority_cert_hash     in blob
        , i_issuer_key_index        in com_api_type_pkg.t_tiny_id
        , i_authority_key_index     in com_api_type_pkg.t_tiny_id
        , o_issuer_key              out sec_api_type_pkg.t_rsa_key_rec
        , o_issuer_cert             out sec_api_type_pkg.t_rsa_certificate_rec
        , o_authority_key           out sec_api_type_pkg.t_rsa_key_rec
    ) is
        l_authority                 sec_api_type_pkg.t_authority_rec;
        
        l_ca_pk_idx_hex_ca          com_api_type_pkg.t_dict_value;
        l_ca_pk_idx_hex_iss         com_api_type_pkg.t_dict_value;
        l_ca_pk_idx_hex_hash        com_api_type_pkg.t_dict_value;
                  
        l_ca_key_index_hex          com_api_type_pkg.t_dict_value;
        l_ca_modulus_length_bytes   com_api_type_pkg.t_tiny_id;
        l_ca_exponent_length        com_api_type_pkg.t_tiny_id;
        
        l_iss_key_index_hex         com_api_type_pkg.t_dict_value;
        l_iss_remainder_length      com_api_type_pkg.t_tiny_id;
        l_iss_exponent              com_api_type_pkg.t_exponent;
        
        l_hash_subject_id           sec_api_type_pkg.t_subject_id;
        l_hash_ca_algorithm         com_api_type_pkg.t_dict_value;
        
        l_pos                       pls_integer := 1;
        
        l_issuer_cert_data          com_api_type_pkg.t_lob_data;
        l_authority_cert_data       com_api_type_pkg.t_lob_data;
        l_authority_cert_hash       com_api_type_pkg.t_lob_data;
    begin
        trc_log_pkg.debug (
            i_text      => 'Read certificate responce (Mastercard)'
        );
        
        if i_issuer_cert_data is null or i_authority_cert_data is null or i_authority_cert_hash is null then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATE_FILES_EMPTY'
            );           
        end if;
    
        -- get authority
        l_authority := sec_api_authority_pkg.get_authority (
            i_authority_type  => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
        );
        -- get authority key
        o_authority_key := sec_api_rsa_key_pkg.get_authority_key (
            i_key_index       => i_authority_key_index
            , i_authority_id  => l_authority.id
        );
        -- get issuer key
        o_issuer_key := sec_api_rsa_key_pkg.get_issuer_key (
            i_key_index  => i_issuer_key_index
        );
        -- get issuer public key certificates
        o_issuer_cert := get_certificate (
            i_authority_key_id    => o_authority_key.id
            , i_certified_key_id  => o_issuer_key.id
        );
        
        -- check authority type
        if o_issuer_cert.authority_type != sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATION_AUTHORITY_MISMATCH'
                , i_env_param1  => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
                , i_env_param2  => o_issuer_cert.authority_type
            );
        end if;

        l_issuer_cert_data := rawtohex(i_issuer_cert_data);
        l_authority_cert_data := rawtohex(i_authority_cert_data);
        l_authority_cert_hash := rawtohex(i_authority_cert_hash);

        l_ca_key_index_hex := prs_api_util_pkg.dec2hex (
            i_dec_number  => o_authority_key.key_index
        );
        
        -- sep
        trc_log_pkg.debug (
            i_text      => 'Parsing self-certified payment system public key'
        );
    
        -- id of certificate subject
        o_authority_key.subject_id := substr(l_authority_cert_data, l_pos, 10);
        l_pos := l_pos + 10;
        trc_log_pkg.debug (
            i_text          => 'Certificate subject id [#1]'
            , i_env_param1  => o_authority_key.subject_id
        );
        
        -- Mastercard public key index
        l_ca_pk_idx_hex_ca := substr(l_authority_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key index hex [#1]'
            , i_env_param1  => l_ca_pk_idx_hex_ca
        );
    
        -- Mastercard public key algorithm indicator
        o_authority_key.sign_algorithm := sec_api_const_pkg.SIGNATURE_ALGORITHM || substr(l_authority_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key algorithm indicator [#1]'
            , i_env_param1  => o_authority_key.sign_algorithm
        );
    
        -- Mastercard public key length
        l_ca_modulus_length_bytes := prs_api_util_pkg.hex2dec (
            i_hex_string  => substr(l_authority_cert_data, l_pos, 2)
        );
        o_authority_key.modulus_length := l_ca_modulus_length_bytes * 8;
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key length [#1]'
            , i_env_param1  => o_authority_key.modulus_length
        );

        -- Mastercard public key exponent length
        l_ca_exponent_length := prs_api_util_pkg.hex2dec (
            i_hex_string  => substr(l_authority_cert_data, l_pos, 2)
        );
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key exponent length  [#1]'
            , i_env_param1  => l_ca_exponent_length
        );
    
        -- leftmost digits of mastercard public key
        o_authority_key.public_key := substr(l_authority_cert_data, l_pos, l_ca_modulus_length_bytes * 2);
        l_pos := l_pos + l_ca_modulus_length_bytes * 2;
        trc_log_pkg.debug (
            i_text          => 'Leftmost digits of Mastercard public key [#1]'
            , i_env_param1  => o_authority_key.public_key
        );
        -- ?????
        /*io_authority_key.public_key := substr(l_authority_cert_data, l_pos, (l_ca_modulus_length_bytes - 37) * 2);
        l_pos := l_pos + (l_ca_modulus_length_bytes - 37) * 2;
        trc_log_pkg.debug (
            i_text          => 'Leftmost Digits of Mastercard Public Key [#1]'
            , i_env_param1  => io_authority_key.public_key
        );
    
        -- Mastercard Public Key Remainder
        io_authority_key.reminder := substr(l_authority_cert_data, l_pos, 37 * 2);
        l_pos := l_pos + 37 * 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard Public Key Remainder [#1]'
            , i_env_param1  => io_ca_rsa_key.reminder
        );*/
    
        -- mastercard public key exponent
        o_authority_key.exponent := substr(l_authority_cert_data, l_pos, l_ca_exponent_length * 2);
        l_pos := l_pos + l_ca_exponent_length * 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key exponent [#1]'
            , i_env_param1  => o_authority_key.exponent
        );
    
        -- mastercard public key certificate
        o_authority_key.certificate := substr(l_authority_cert_data, l_pos, l_ca_modulus_length_bytes * 2);
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key certificate [#1]'
            , i_env_param1  => o_authority_key.certificate
        );

        -- hep
        trc_log_pkg.debug (
            i_text      => 'Parsing hash-code calculated on a payment system public key'
        );
    
        l_pos := 1;
        -- id of certificate subject
        l_hash_subject_id := substr(l_authority_cert_hash, l_pos, 10);
        l_pos := l_pos + 10;
        trc_log_pkg.debug (
            i_text          => 'ID of certificate subject [#1]'
            , i_env_param1  => l_hash_subject_id
        );

        -- mastercard public key index
        l_ca_pk_idx_hex_hash := substr(l_authority_cert_hash, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key index hex [#1]'
            , i_env_param1  => l_ca_pk_idx_hex_hash
        );
        
        -- mastercard public key algorithm indicator
        l_hash_ca_algorithm := sec_api_const_pkg.SIGNATURE_ALGORITHM || substr(l_authority_cert_hash, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key algorithm indicator [#1]'
            , i_env_param1  => l_hash_ca_algorithm
        );
        
        -- certification authority public key check sum
        o_authority_key.hash := substr(l_authority_cert_hash, l_pos, 40);
        trc_log_pkg.debug (
            i_text          => 'Certification authority public key check sum [#1]'
            , i_env_param1  => o_authority_key.hash
        );
    
        -- cFF
        trc_log_pkg.debug (
            i_text      => 'Parsing issuer public key certificate'
        );
        
        l_pos := 1;
        -- id of certificate subject hexadecimal 'F' characters
        o_issuer_cert.subject_id := substr(l_issuer_cert_data, l_pos, 8);
        l_pos := l_pos + 8;
        trc_log_pkg.debug (
            i_text          => 'ID of certificate subject hexadecimal F characters [#1]'
            , i_env_param1  => o_issuer_cert.subject_id
        );
        o_issuer_cert.subject_id := rtrim(o_issuer_cert.subject_id, 'F');
        
        -- issuer public key file index
        l_iss_key_index_hex := substr(l_issuer_cert_data, l_pos, 6);
        l_pos := l_pos + 6;
        trc_log_pkg.debug (
            i_text          => 'Issuer public key file index hex [#1]'
            , i_env_param1  => l_iss_key_index_hex
        );
        
        -- mastercard public key index
        l_ca_pk_idx_hex_iss := substr(l_issuer_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Mastercard public key index hex [#1]'
            , i_env_param1  => l_ca_pk_idx_hex_iss
        );
        
        -- issuer public key remainder
        l_iss_remainder_length := o_issuer_key.modulus_length / 8 - l_ca_modulus_length_bytes + 36;
        if l_iss_remainder_length > 0 then
            o_issuer_cert.reminder := substr(l_issuer_cert_data, l_pos, l_iss_remainder_length * 2);
            l_pos := l_pos + l_iss_remainder_length * 2;
            trc_log_pkg.debug (
                i_text          => 'Issuer public key remainder [#1]'
                , i_env_param1  => o_issuer_cert.reminder
            );
        else
            o_issuer_cert.reminder := null;
            trc_log_pkg.debug (
                i_text          => 'Issuer public key remainder not present'
            );
        end if;
        
        -- issuer public key exponent
        l_iss_exponent := substr(l_issuer_cert_data, l_pos, nvl(length(o_issuer_key.exponent), 0));
        l_pos := l_pos + nvl(length(o_issuer_key.exponent), 0);
        trc_log_pkg.debug (
            i_text          => 'Issuer public key exponent [#1]'
            , i_env_param1  => l_iss_exponent
        );
        
        -- Issuer public key certificate
        o_issuer_cert.certificate := substr(l_issuer_cert_data, l_pos, l_ca_modulus_length_bytes * 2);
        trc_log_pkg.debug (
            i_text          => 'Issuer Public Key Certificate [#1]'
            , i_env_param1  => o_issuer_cert.certificate
        );
        
        -- checks
    
        -- check mastercard public key index
        if l_ca_key_index_hex != l_ca_pk_idx_hex_ca
          or l_ca_key_index_hex != l_ca_pk_idx_hex_iss
          or l_ca_key_index_hex != l_ca_pk_idx_hex_hash then
            com_api_error_pkg.raise_error (
                i_error         => 'CA_PUBLIC_KEY_INDEX_MISMATCH'
                , i_env_param1  => l_ca_key_index_hex
                , i_env_param2  => l_ca_pk_idx_hex_ca
                , i_env_param3  => l_ca_pk_idx_hex_iss
                , i_env_param4  => l_ca_pk_idx_hex_hash
            );
        end if;
        
        -- check id of certificate subject
        if l_hash_subject_id != o_authority_key.subject_id then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATE_SUBJECT_ID_MISMATCH'
                , i_env_param1  => l_hash_subject_id
                , i_env_param2  => o_issuer_cert.subject_id
            );
        end if;
        
        -- check mastercard public key algorithm indicator
        if l_hash_ca_algorithm != o_authority_key.sign_algorithm then
            com_api_error_pkg.raise_error (
                i_error         => 'CA_PUBLIC_KEY_ALGORITHM_MISMATCH'
                , i_env_param1  => l_hash_ca_algorithm
                , i_env_param2  => o_authority_key.sign_algorithm
            );
        end if;
        
        -- check cert subject
        if o_issuer_cert.subject_id != o_issuer_key.subject_id then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATE_SUBJECT_ID_MISMATCH'
                , i_env_param1  => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
                , i_env_param2  => o_issuer_cert.subject_id
                , i_env_param3  => o_issuer_key.subject_id
            );
        end if;
    
        trc_log_pkg.debug (
            i_text      => 'Read certificate responce (Mastercard) - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Read certificate responce (Mastercard) [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;

    procedure read_certificate_response_visa (
        i_issuer_cert_data         in blob
        , i_authority_cert_data    in blob
        , i_authority_key_index     in com_api_type_pkg.t_tiny_id
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , o_issuer_key              out sec_api_type_pkg.t_rsa_key_rec
        , o_issuer_cert             out sec_api_type_pkg.t_rsa_certificate_rec
        , o_authority_key           out sec_api_type_pkg.t_rsa_key_rec
    ) is
        l_authority                 sec_api_type_pkg.t_authority_rec;
        
        l_ca_cert_header            com_api_type_pkg.t_dict_value;
        l_iss_cert_header           com_api_type_pkg.t_dict_value;
        
        l_serial_number             com_api_type_pkg.t_dict_value;
        l_iss_exponent_length       com_api_type_pkg.t_tiny_id;
        l_iss_exponent              com_api_type_pkg.t_exponent;
        l_iss_remainder_length      com_api_type_pkg.t_tiny_id;
        
        l_ca_pk_idx_hex_ca          com_api_type_pkg.t_dict_value;
        l_ca_pk_idx_hex_iss         com_api_type_pkg.t_dict_value;
        
        l_ca_key_index_hex          com_api_type_pkg.t_dict_value;
        l_ca_modulus_length_bytes   com_api_type_pkg.t_tiny_id;
        l_ca_exponent_length        com_api_type_pkg.t_tiny_id;
        
        l_pos                       pls_integer := 1;
        l_issuer_cert_data          com_api_type_pkg.t_lob_data;
        l_authority_cert_data       com_api_type_pkg.t_lob_data;
    begin
        trc_log_pkg.debug (
            i_text      => 'Read certificate responce (Visa)'
        );
        
        if i_issuer_cert_data is null or i_authority_cert_data is null then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATE_FILES_EMPTY'
            );           
        end if;
    
        -- get authority
        l_authority := sec_api_authority_pkg.get_authority (
            i_authority_type  => sec_api_const_pkg.AUTHORITY_TYPE_VISA
        );
        -- get authority key
        o_authority_key := sec_api_rsa_key_pkg.get_authority_key (
            i_key_index       => i_authority_key_index
            , i_authority_id  => l_authority.id
        );
        for key in (
            select
                r.certified_key_id
            from
                sec_rsa_certificate r
                , sec_rsa_certificate c
            where
                r.authority_key_id = o_authority_key.id
                and r.certified_key_id != r.authority_key_id
                and c.certified_key_id = r.certified_key_id
                and c.tracking_number = i_tracking_number
                and c.certified_key_id = c.authority_key_id
        ) loop
            o_issuer_key.id := key.certified_key_id;
        end loop;
        -- get issuer key
        o_issuer_key := sec_api_rsa_key_pkg.get_rsa_key (
            i_id  => o_issuer_key.id
        );
        -- get issuer public key certificates
        o_issuer_cert := get_certificate (
            i_authority_key_id    => o_authority_key.id
            , i_certified_key_id  => o_issuer_key.id
        );
        
        -- check authority type
        if o_issuer_cert.authority_type != sec_api_const_pkg.AUTHORITY_TYPE_VISA then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATION_AUTHORITY_MISMATCH'
                , i_env_param1  => sec_api_const_pkg.AUTHORITY_TYPE_VISA
                , i_env_param2  => o_issuer_cert.authority_type
            );
        end if;

        l_issuer_cert_data := rawtohex(i_issuer_cert_data);
        l_authority_cert_data := rawtohex(i_authority_cert_data);

        l_ca_key_index_hex := prs_api_util_pkg.dec2hex (
            i_dec_number  => o_authority_key.key_index
        );
        
        -- VFF
        trc_log_pkg.debug (
            i_text      => 'Parsing self-certified payment system public key'
        );
        
        --dbms_output.put_line(i_authority_cert_data);
        --dbms_output.put_line(i_issuer_cert_data);
        -- header
        l_ca_cert_header := substr(l_authority_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'header [#1]'
            , i_env_param1  => l_ca_cert_header
        );
        
        -- service identifier
        o_authority_key.visa_service_id := substr(l_authority_cert_data, l_pos, 8);
        l_pos := l_pos + 8;
        trc_log_pkg.debug (
            i_text          => 'Visa service identifier [#1]'
            , i_env_param1  => o_authority_key.visa_service_id
        );
        
        -- length of visa ca public key modulus
        l_ca_modulus_length_bytes := prs_api_util_pkg.hex2dec (
            i_hex_string => substr(l_authority_cert_data, l_pos, 4)
        );
        o_authority_key.modulus_length := l_ca_modulus_length_bytes * 8;
        l_pos := l_pos + 4;
        trc_log_pkg.debug (
            i_text          => 'Length of visa ca public key modulus hex [#1]'
            , i_env_param1  => l_ca_modulus_length_bytes
        );

        -- visa ca public key algorithm indicator
        o_authority_key.sign_algorithm := sec_api_const_pkg.SIGNATURE_ALGORITHM || substr(l_authority_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Visa ca public key algorithm indicator [#1]'
            , i_env_param1  => o_authority_key.sign_algorithm
        );
        
        -- length of visa ca public key exponent
        l_ca_exponent_length := prs_api_util_pkg.hex2dec (
            i_hex_string  => substr(l_authority_cert_data, l_pos, 2)
        );
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Length of visa ca public key exponent [#1]'
            , i_env_param1  => l_ca_exponent_length
        );
        
        -- registered application provider identifier (RID)
        o_authority_key.subject_id := substr(l_authority_cert_data, l_pos, 10);
        l_pos := l_pos + 10;
        trc_log_pkg.debug (
            i_text          => 'Registered application provider identifier (RID) [#1]'
            , i_env_param1  => o_authority_key.subject_id
        );
        
        -- visa ca public key index
        l_ca_pk_idx_hex_ca := substr(l_authority_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Visa ca public key index hex [#1]'
            , i_env_param1  => l_ca_pk_idx_hex_ca
        );
        
        -- visa ca public key modulus
        o_authority_key.public_key := substr(l_authority_cert_data, l_pos, l_ca_modulus_length_bytes * 2);
        l_pos := l_pos + l_ca_modulus_length_bytes * 2;
        trc_log_pkg.debug (
            i_text          => 'Visa ca public key modulus [#1]'
            , i_env_param1  => o_authority_key.public_key
        );
        
        -- visa ca public key exponent
        o_authority_key.exponent := substr(l_authority_cert_data, l_pos, l_ca_exponent_length * 2);
        l_pos := l_pos + l_ca_exponent_length * 2;
        trc_log_pkg.debug (
            i_text          => 'Visa ca public key exponent [#1]'
            , i_env_param1  => o_authority_key.exponent
        );
        
        -- hash results
        o_authority_key.hash := substr(l_authority_cert_data, l_pos, 40);
        l_pos := l_pos + 40;
        trc_log_pkg.debug (
            i_text          => 'Hash results [#1]'
            , i_env_param1  => o_authority_key.hash
        );
        
        -- certificate
        o_authority_key.certificate := substr(l_authority_cert_data, l_pos, l_ca_modulus_length_bytes * 2);
        trc_log_pkg.debug (
            i_text          => 'Self-signed visa ca public key certificate [#1]'
            , i_env_param1  => o_authority_key.certificate
        );
        
        
        -- iFF
        trc_log_pkg.debug (
            i_text      => 'Parsing issuer public key certificate'
        );
        
        l_pos := 1;
        -- header
        l_iss_cert_header := substr(l_issuer_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'header [#1]'
            , i_env_param1  => l_iss_cert_header
        );
        
        -- visa service identifier
        o_issuer_cert.visa_service_id := substr(l_issuer_cert_data, l_pos, 8);
        l_pos := l_pos + 8;
        trc_log_pkg.debug (
            i_text          => 'Visa service identifier [#1]'
            , i_env_param1  => o_issuer_cert.visa_service_id
        );
        
        -- issuer identification number padded on the right with hex. 'F'
        o_issuer_cert.subject_id := substr(l_issuer_cert_data, l_pos, 8);
        l_pos := l_pos + 8;
        trc_log_pkg.debug (
            i_text          => 'Issuer identification number [#1]'
            , i_env_param1  => o_issuer_cert.subject_id
        );
        o_issuer_cert.subject_id := rtrim(o_issuer_cert.subject_id, 'F');
        
        -- certificate serial number
        l_serial_number := substr(l_issuer_cert_data, l_pos, 6);
        l_pos := l_pos + 6;
        trc_log_pkg.debug (
            i_text          => 'Certificate serial number [#1]'
            , i_env_param1  => l_serial_number
        );
        o_issuer_cert.serial_number := l_serial_number;
        
        -- certificate expiration date
        o_issuer_cert.expir_date := to_date (
            substr(l_issuer_cert_data, l_pos, 4)
            , prs_api_const_pkg.EXP_DATE_CERT_FORMAT
        );
        l_pos := l_pos + 4;
        trc_log_pkg.debug (
            i_text          => 'Certificate expiration date [#1]'
            , i_env_param1  => to_char(o_issuer_cert.expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
        );
        
        -- issuer public key remainder length
        l_iss_remainder_length := o_issuer_key.modulus_length / 8 - l_ca_modulus_length_bytes + 36;
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Issuer public key remainder length [#1]'
            , i_env_param1  => l_iss_remainder_length
        );
        if l_iss_remainder_length > 0 then
            o_issuer_cert.reminder := substr(l_issuer_cert_data, l_pos, l_iss_remainder_length * 2);
            l_pos := l_pos + l_iss_remainder_length * 2;
            trc_log_pkg.debug (
                i_text          => 'Issuer public key modulus remainder [#1]'
                , i_env_param1  => o_issuer_cert.reminder
            );
        else
            trc_log_pkg.debug (
                i_text          => 'Issuer public key modulus remainder'
            );
        end if;
        
        -- issuer public key exponent length
        l_iss_exponent_length := prs_api_util_pkg.hex2dec (
            i_hex_string => substr(l_issuer_cert_data, l_pos, 2)
        );
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'Issuer public key exponent length [#1]'
            , i_env_param1  => l_iss_exponent_length
        );
        
        -- issuer public key exponent
        l_iss_exponent := substr(l_issuer_cert_data, l_pos, l_iss_exponent_length * 2);
        l_pos := l_pos + l_iss_exponent_length * 2;
        trc_log_pkg.debug (
            i_text          => 'Issuer public key exponent [#1]'
            , i_env_param1  => l_iss_exponent
        );
        
        -- ca public key index
        l_ca_pk_idx_hex_iss := substr(l_issuer_cert_data, l_pos, 2);
        l_pos := l_pos + 2;
        trc_log_pkg.debug (
            i_text          => 'CA public key index hex [#1]'
            , i_env_param1  => l_ca_pk_idx_hex_iss
        );
        
        -- certificate
        o_issuer_cert.certificate := substr(l_issuer_cert_data, l_pos, l_ca_modulus_length_bytes * 2);
        l_pos := l_pos + l_ca_modulus_length_bytes * 2;
        trc_log_pkg.debug (
            i_text          => 'Issuer public key certificate [#1]'
            , i_env_param1  => o_issuer_cert.certificate
        );
        
        -- detached Signature
        o_issuer_cert.hash := substr(l_issuer_cert_data, l_pos, l_ca_modulus_length_bytes * 2);
        trc_log_pkg.debug (
            i_text          => 'Issuer public key detached signature [#1]'
            , i_env_param1  => o_issuer_cert.hash
        );
    
        -- checks
        
        -- check ca pk file header
        if l_ca_cert_header != '20' then
            com_api_error_pkg.raise_error (
                i_error         => 'CA_PUBLIC_KEY_CERTIFICATE_FILE_HEADER_MISMATCH'
                , i_env_param1  => l_ca_cert_header
                , i_env_param2  => '20'
            );
        end if;
        
        -- check visa public key index
        if l_ca_key_index_hex != l_ca_pk_idx_hex_ca
          or l_ca_key_index_hex != l_ca_pk_idx_hex_iss then
            com_api_error_pkg.raise_error (
                i_error         => 'CA_PUBLIC_KEY_INDEX_MISMATCH'
                , i_env_param1  => l_ca_key_index_hex
                , i_env_param2  => l_ca_pk_idx_hex_ca
                , i_env_param3  => l_ca_pk_idx_hex_iss
            );
        end if;
        
        -- check visa service identifiers
        if o_authority_key.visa_service_id not like o_issuer_key.visa_service_id || '%'
           or o_issuer_cert.visa_service_id not like o_issuer_key.visa_service_id || '%' then
            com_api_error_pkg.raise_error (
                i_error         => 'VISA_SERVICE_IDENTIFIER_MISMATCH'
                , i_env_param1  => o_authority_key.visa_service_id
                , i_env_param2  => o_issuer_cert.visa_service_id
                , i_env_param3  => o_issuer_key.visa_service_id
            );
        end if;
        
        -- check issuer pk certificate file header
        if l_iss_cert_header != '24' then
            com_api_error_pkg.raise_error (
                i_error         => 'ISS_PUBLIC_KEY_CERTIFICATE_FILE_HEADER_MISMATCH'
                , i_env_param1  => l_iss_cert_header
                , i_env_param2  => '24'
            );
        end if;
        
        -- check issuer public exponent length
        if nvl(length(o_issuer_key.exponent), 0) / 2 != l_iss_exponent_length then
            com_api_error_pkg.raise_error (
                i_error         => 'ISSUER_PUBLIC_EXPONENT_MISMATCH'
                , i_env_param1  => nvl(length(o_issuer_key.exponent), 0) / 2
                , i_env_param2  => l_iss_exponent_length
            );
        end if;
        
        -- check expiration date
        if last_day(o_issuer_cert.expir_date) != last_day(o_issuer_cert.expir_date) then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATE_EXPIRATION_DATE_MISMATCH'
                , i_env_param1  => to_char(o_issuer_key.expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
                , i_env_param2  => to_char(o_issuer_cert.expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
            );
        end if;
        
        -- check cert subject
        if o_issuer_key.subject_id != o_issuer_cert.subject_id then
            com_api_error_pkg.raise_error (
                i_error         => 'CERTIFICATE_SUBJECT_ID_MISMATCH'
                , i_env_param1  => sec_api_const_pkg.AUTHORITY_TYPE_VISA
                , i_env_param2  => o_issuer_cert.subject_id
                , i_env_param3  => o_issuer_key.subject_id
            );
        end if;
        
        trc_log_pkg.debug (
            i_text      => 'Read certificate responce (Visa) - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Read certificate responce (Visa) [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure read_certificate_response (
        i_authority_type            in com_api_type_pkg.t_dict_value
        , i_issuer_cert_data        in blob
        , i_authority_cert_data     in blob
        , i_authority_cert_hash     in blob
        , i_issuer_key_index        in com_api_type_pkg.t_tiny_id
        , i_authority_key_index     in com_api_type_pkg.t_tiny_id
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , o_issuer_key              out sec_api_type_pkg.t_rsa_key_rec
        , o_authority_key           out sec_api_type_pkg.t_rsa_key_rec
        , o_issuer_cert             out sec_api_type_pkg.t_rsa_certificate_rec
    ) is
    begin
        trc_log_pkg.debug (
            i_text      => 'Read certificate responce'
        );
        
        case i_authority_type
            when sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
                read_certificate_response_mc (
                    i_issuer_cert_data        => i_issuer_cert_data
                    , i_authority_cert_data   => i_authority_cert_data
                    , i_authority_cert_hash   => i_authority_cert_hash
                    , i_issuer_key_index     => i_issuer_key_index
                    , i_authority_key_index  => i_authority_key_index
                    , o_issuer_key           => o_issuer_key
                    , o_issuer_cert          => o_issuer_cert
                    , o_authority_key        => o_authority_key
                );
                
            when sec_api_const_pkg.AUTHORITY_TYPE_VISA then
                read_certificate_response_visa (
                    i_issuer_cert_data        => i_issuer_cert_data
                    , i_authority_cert_data   => i_authority_cert_data
                    , i_authority_key_index  => i_authority_key_index
                    , i_tracking_number      => i_tracking_number
                    , o_issuer_key           => o_issuer_key
                    , o_issuer_cert          => o_issuer_cert
                    , o_authority_key        => o_authority_key
                );

        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_CERTIFICATION_AUTHORITY'
                , i_env_param1  => i_authority_type
            );

        end case;
        
        trc_log_pkg.debug (
            i_text      => 'Read certificate responce - ok'
        );
    end;
    
    function construct_authority_cert (
        i_authority_type            in com_api_type_pkg.t_dict_value
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_visa_service_id         in com_api_type_pkg.t_dict_value
        , i_key_index               in com_api_type_pkg.t_tiny_id
        , i_sign_algorithm          in com_api_type_pkg.t_dict_value
        , i_modulus_length          in com_api_type_pkg.t_tiny_id
        , i_exponent                in com_api_type_pkg.t_exponent
        , i_public_key              in com_api_type_pkg.t_key
        , i_certificate             in com_api_type_pkg.t_key
        , i_reminder                in com_api_type_pkg.t_key
        , i_hash                    in com_api_type_pkg.t_key
    ) return com_api_type_pkg.t_text is
        l_cert_data                 com_api_type_pkg.t_text;
    begin
        trc_log_pkg.debug (
            i_text      => 'Construct of self-certified payment system public keys'
        );
        
        case i_authority_type
            when sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
                l_cert_data := -- ID of Certificate Subject
                               rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_subject_id
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                                  , i_pad_string  => 'F'
                                  , i_length      => 5
                               )
                               -- Mastercard Public Key Index
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => i_key_index
                               )
                               -- Mastercard Public Key Algorithm Indicator
                            || substr(i_sign_algorithm, 5, 2)
                               -- Mastercard Public Key Length
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => i_modulus_length / 8
                               )
                               -- Mastercard Public Key Exponent Length
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => nvl(length(i_exponent), 0) / 2
                               )
                               -- Leftmost Digits of Mastercard Public Key
                            || i_public_key
                               -- Mastercard Public Key Remainder
                            || i_reminder
                               -- Mastercard Public Key Exponent
                            || i_exponent
                               -- Mastercard Public Key Certificate
                            || i_certificate;
                               
            when sec_api_const_pkg.AUTHORITY_TYPE_VISA then
                l_cert_data := -- header
                               '20'
                               -- service identifier
                            || rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_visa_service_id
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                                  , i_length      => 4
                               )
                               -- Length of Visa CA Public Key Modulus
                            || rul_api_name_pkg.pad_byte_len (
                                  i_src           => prs_api_util_pkg.dec2hex (i_modulus_length / 8)
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_LEFT
                                  , i_length      => 2
                               )
                               -- Visa CA Public Key Algorithm Indicator
                            || substr(i_sign_algorithm, 5, 2)
                               -- Length of Visa CA Public Key Exponent
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => nvl(length(i_exponent), 0) / 2
                               )
                               -- Registered Application Provider Identifier (RID)
                            || rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_subject_id
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                                  , i_pad_string  => 'F'
                                  , i_length      => 5
                               )
                               -- Visa CA Public Key Index
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => i_key_index
                               )
                               -- Visa CA Public Key Modulus
                            || i_public_key
                               -- Visa CA Public Key Exponent
                            || i_exponent
                               -- Hash Results
                            || i_hash
                               -- Certificate
                            || i_certificate;
                
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_CERTIFICATION_AUTHORITY'
                , i_env_param1  => i_authority_type
            );

        end case;
        
        trc_log_pkg.debug (
            i_text      => 'Construct of self-certified payment system public keys - ok'
        );
        
        return l_cert_data;
    end;
    
    function construct_issuer_cert (
        i_authority_type            in com_api_type_pkg.t_dict_value
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_serial_number           in sec_api_type_pkg.t_serial_number
        , i_visa_service_id         in com_api_type_pkg.t_dict_value
        , i_cert_expir_date         in date
        , i_ca_key_index            in com_api_type_pkg.t_tiny_id
        , i_iss_key_index           in com_api_type_pkg.t_tiny_id
        , i_exponent                in com_api_type_pkg.t_exponent
        , i_certificate             in com_api_type_pkg.t_key
        , i_reminder                in com_api_type_pkg.t_key
        , i_hash                    in com_api_type_pkg.t_key
    ) return com_api_type_pkg.t_text is
        l_cert_data                 com_api_type_pkg.t_text;
    begin
        trc_log_pkg.debug (
            i_text      => 'Construct of issuer public key certificates'
        );
      
        case i_authority_type
            when sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
                l_cert_data := -- ID of Certificate Subject hexadecimal 'F' characters
                               rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_subject_id
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                                  , i_pad_string  => 'F'
                                  , i_length      => 4
                               )
                               -- Issuer Public Key File Index
                            || rul_api_name_pkg.pad_byte_len (
                                  i_src           => prs_api_util_pkg.dec2hex(i_iss_key_index)
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_LEFT
                                  , i_length      => 3
                               )
                               -- Mastercard Public Key Index
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => i_ca_key_index
                               )
                               -- Issuer Public Key Remainder
                            || i_reminder
                               -- Issuer Public Key Exponent
                            || i_exponent
                               -- Issuer Public Key Certificate
                            || i_certificate;
                
            when sec_api_const_pkg.AUTHORITY_TYPE_VISA then
                l_cert_data := -- header
                               '24'
                               -- Visa service identifier
                            || rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_visa_service_id
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                                  , i_length      => 4
                               )
                               -- Issuer Identification Number padded on the right with hex. 'F'
                            || rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_subject_id
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_RIGHT
                                  , i_pad_string  => 'F'
                                  , i_length      => 4
                               )
                               -- Certificate Serial Number
                            || rul_api_name_pkg.pad_byte_len (
                                  i_src           => i_serial_number
                                  , i_pad_type    => rul_api_const_pkg.PAD_TYPE_LEFT
                                  , i_length      => 3
                               )
                               -- Certificate Expiration Date
                            || to_char(i_cert_expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
                               -- Issuer Public Key Remainder Length
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => nvl(length(i_reminder), 0) / 2
                               )
                               -- Issuer Public Key Remainder
                            || i_reminder
                               -- Issuer Public Key Exponent Length
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => nvl(length(i_exponent), 0) / 2
                               )
                               -- Issuer Public Key Exponent
                            || i_exponent
                               -- CA Public Key Index
                            || prs_api_util_pkg.dec2hex (
                                   i_dec_number => i_ca_key_index
                               )
                            || -- Certificate
                               i_certificate
                               -- Detached Signature
                            || i_hash;
                
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_CERTIFICATION_AUTHORITY'
                , i_env_param1  => i_authority_type
            );

        end case;
        
        trc_log_pkg.debug (
            i_text      => 'Construct of issuer public key certificates - ok'
        );
        
        return l_cert_data;
    end;
    
    procedure validate_authority_cert_mc (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , io_authority_key             in out sec_api_type_pkg.t_rsa_key_rec
    ) is
        l_result                    com_api_type_pkg.t_tiny_id;
        l_resp_message              com_api_type_pkg.t_name;
        l_expir_date                com_api_type_pkg.t_name;
        l_serial_number             com_api_type_pkg.t_name;
        l_ca_rsa_key                sec_api_type_pkg.t_rsa_key_rec;
        l_cert_data                 com_api_type_pkg.t_text;
        l_hsm_device                hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text      => 'Validate a certification authority self-signed certificate (Mastercard)'
        );
        
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- construct authority certificate
            l_cert_data := construct_authority_cert (
                i_authority_type     => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
                , i_subject_id       => io_authority_key.subject_id
                , i_visa_service_id  => null
                , i_key_index        => io_authority_key.key_index
                , i_sign_algorithm   => io_authority_key.sign_algorithm
                , i_modulus_length   => io_authority_key.modulus_length
                , i_exponent         => io_authority_key.exponent
                , i_public_key       => io_authority_key.public_key
                , i_certificate      => io_authority_key.certificate
                , i_reminder         => io_authority_key.reminder
                , i_hash             => io_authority_key.hash
            );
        
            begin
                l_result := hsm_api_hsm_pkg.validate_ca_pk_cert_mc (
                    i_hsm_ip                => l_hsm_device.address
                    , i_hsm_port            => l_hsm_device.port
                    , i_cert_data           => l_cert_data
                    , io_cert_hash          => io_authority_key.hash
                    , o_cert_expir_date     => l_expir_date
                    , o_cert_serial_number  => l_serial_number
                    , o_ca_exponent         => l_ca_rsa_key.exponent
                    , o_ca_public_key       => l_ca_rsa_key.public_key
                    , o_ca_public_key_mac   => l_ca_rsa_key.public_key_mac
                    , o_resp_mess           => l_resp_message
                );
            exception
                when com_api_error_pkg.e_fetched_value_is_null then
                    -- Wrapper hsm_api_hsm_pkg.validate_ca_pk_cert_mc for C function doesn't use indicator, so if some 
                    -- of parameters are empty (NULL) then an exception "ORA-01405: fetched column value is NULL" is raised  
                    trc_log_pkg.debug(
                        i_text => 'validate_iss_pk_cert_visa FAILED: '
                               || 'l_hsm_device [' || l_hsm_device.address || ':' || l_hsm_device.port
                               || '], io_authority_key.hash [' || io_authority_key.hash
                               || '], l_cert_data [' || l_cert_data || ']'
                    );
                    l_result := hsm_api_const_pkg.RESULT_CODE_COMMON_ERROR;
            end;

            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
                -- validate a Certification Authority Self-Signed Certificate (Mastercard)
              , i_error          => 'ERROR_VALIDATE_CA_PK_CERT'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
              , i_env_param3     => l_resp_message
            );

            io_authority_key.expir_date := to_date(l_expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT);
            io_authority_key.exponent := l_ca_rsa_key.exponent;
            io_authority_key.public_key := l_ca_rsa_key.public_key;
            io_authority_key.public_key_mac := l_ca_rsa_key.public_key_mac;
            io_authority_key.serial_number := l_serial_number;
            
            trc_log_pkg.debug (
                i_text      => 'Validate a certification authority self-signed certificate (Mastercard) - ok'
            );
        end if;
    exception
        when others then
            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure validate_authority_cert_visa (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , io_authority_key          in out sec_api_type_pkg.t_rsa_key_rec
    ) is
        l_result                    com_api_type_pkg.t_tiny_id;
        l_resp_message              com_api_type_pkg.t_name;
        l_expir_date                com_api_type_pkg.t_name;
        l_ca_rsa_key                sec_api_type_pkg.t_rsa_key_rec;
        l_cert_data                 com_api_type_pkg.t_text;
        l_hsm_device                hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text      => 'Validate a certification authority self-signed certificate (Visa)'
        );
        
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- construct authority certificate
            l_cert_data := construct_authority_cert (
                i_authority_type     => sec_api_const_pkg.AUTHORITY_TYPE_VISA
                , i_subject_id       => io_authority_key.subject_id
                , i_visa_service_id  => io_authority_key.visa_service_id
                , i_key_index        => io_authority_key.key_index
                , i_sign_algorithm   => io_authority_key.sign_algorithm
                , i_modulus_length   => io_authority_key.modulus_length
                , i_exponent         => io_authority_key.exponent
                , i_public_key       => io_authority_key.public_key
                , i_certificate      => io_authority_key.certificate
                , i_reminder         => io_authority_key.reminder
                , i_hash             => io_authority_key.hash
            );
            
            begin
                l_result := hsm_api_hsm_pkg.validate_ca_pk_cert_visa (
                    i_hsm_ip               => l_hsm_device.address
                    , i_hsm_port           => l_hsm_device.port
                    , i_cert_data          => l_cert_data
                    , o_ca_exponent        => l_ca_rsa_key.exponent
                    , o_ca_public_key      => l_ca_rsa_key.public_key
                    , o_ca_public_key_mac  => l_ca_rsa_key.public_key_mac
                    , o_cert_expir_date    => l_expir_date
                    , o_resp_mess          => l_resp_message
                );
            exception
                when com_api_error_pkg.e_fetched_value_is_null then
                    -- Wrapper hsm_api_hsm_pkg.validate_ca_pk_cert_visa for C function doesn't use indicator, so if some 
                    -- of parameters are empty (NULL) then an exception "ORA-01405: fetched column value is NULL" is raised  
                    trc_log_pkg.debug(
                        i_text => 'validate_iss_pk_cert_visa FAILED: '
                               || 'l_hsm_device [' || l_hsm_device.address || ':' || l_hsm_device.port
                               || '], l_cert_data [' || l_cert_data || ']'
                    );
                    l_result := hsm_api_const_pkg.RESULT_CODE_COMMON_ERROR;
            end;

            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_VALIDATE_CA_PK_CERT'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => sec_api_const_pkg.AUTHORITY_TYPE_VISA
              , i_env_param3     => l_resp_message
            );

            io_authority_key.expir_date := to_date(l_expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT);
            io_authority_key.exponent := l_ca_rsa_key.exponent;
            io_authority_key.public_key := l_ca_rsa_key.public_key;
            io_authority_key.public_key_mac := l_ca_rsa_key.public_key_mac;
            
            trc_log_pkg.debug (
                i_text      => 'Validate a certification authority self-signed certificate (Visa) - ok'
            );
        end if;
    exception
        when others then
            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure validate_issuer_cert_mc (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_issuer_key              in sec_api_type_pkg.t_rsa_key_rec
        , i_authority_key           in sec_api_type_pkg.t_rsa_key_rec
        , i_issuer_certificate      in sec_api_type_pkg.t_rsa_certificate_rec
    ) is
        l_result                    com_api_type_pkg.t_tiny_id;
        l_resp_message              com_api_type_pkg.t_name;
        l_public_key_mac            com_api_type_pkg.t_pin_block;
        l_expir_date                com_api_type_pkg.t_name;
        l_serial_number             sec_api_type_pkg.t_serial_number;
        l_cert_hash                 com_api_type_pkg.t_key;
        l_cert_data                 com_api_type_pkg.t_text;
        l_hsm_device                hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text      => 'Validate an issuer public key certificate (Mastercard)'
        );
        
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- construct certificate
            l_cert_data := construct_issuer_cert (
                i_authority_type     => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
                , i_subject_id       => i_issuer_certificate.subject_id
                , i_serial_number    => i_issuer_certificate.serial_number
                , i_visa_service_id  => i_issuer_certificate.visa_service_id
                , i_cert_expir_date  => i_issuer_certificate.expir_date
                , i_ca_key_index     => i_authority_key.key_index
                , i_iss_key_index    => i_issuer_key.key_index
                , i_exponent         => i_issuer_key.exponent
                , i_certificate      => i_issuer_certificate.certificate
                , i_reminder         => i_issuer_certificate.reminder
                , i_hash             => ''
            );
        
            begin
                l_result := hsm_api_hsm_pkg.validate_iss_pk_cert_mc (
                    i_hsm_ip                => l_hsm_device.address
                    , i_hsm_port            => l_hsm_device.port
                    , i_ca_public_key       => i_authority_key.public_key
                    , i_ca_public_key_mac   => i_authority_key.public_key_mac
                    , i_ca_exponent         => i_authority_key.exponent
                    , i_iss_public_key      => i_issuer_key.public_key
                    , i_iss_private_key     => i_issuer_key.private_key
                    , i_iss_exponent        => i_issuer_key.exponent
                    , i_iss_cert_data       => l_cert_data
                    , o_expir_date          => l_expir_date
                    , o_serial_number       => l_serial_number
                    , o_iss_public_key_mac  => l_public_key_mac
                    , o_iss_cert_hash       => l_cert_hash
                    , o_resp_mess           => l_resp_message
                );
            exception
                when com_api_error_pkg.e_fetched_value_is_null then
                    -- Wrapper hsm_api_hsm_pkg.validate_iss_pk_cert_mc for C function doesn't use indicator, so if some 
                    -- of parameters are empty (NULL) then an exception "ORA-01405: fetched column value is NULL" is raised  
                    trc_log_pkg.debug(
                        i_text => 'validate_iss_pk_cert_visa FAILED: '
                               || 'l_hsm_device [' || l_hsm_device.address || ':' || l_hsm_device.port
                               || '], i_authority_key [' || i_authority_key.public_key
                               || '][' || i_authority_key.public_key_mac || '][' || i_authority_key.exponent
                               || '], i_issuer_key [' || i_issuer_key.public_key
                               || '][' || i_issuer_key.private_key || '][' || i_issuer_key.exponent
                               || '], l_cert_data [' || l_cert_data || ']'
                    );
                    l_result := hsm_api_const_pkg.RESULT_CODE_COMMON_ERROR;
            end;

            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_VALIDATE_ISSUER_CERT'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD
              , i_env_param3     => l_resp_message
            );

            trc_log_pkg.debug (
                i_text      => 'Validate an issuer public key certificate (Mastercard) - ok'
            );
        end if;
    exception
        when others then
            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure validate_issuer_cert_visa (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_issuer_key              in sec_api_type_pkg.t_rsa_key_rec
        , i_authority_key           in sec_api_type_pkg.t_rsa_key_rec
        , i_issuer_certificate      in sec_api_type_pkg.t_rsa_certificate_rec
    ) is
        l_result                    com_api_type_pkg.t_tiny_id;
        l_resp_message              com_api_type_pkg.t_name;
        
        l_public_key                com_api_type_pkg.t_key;
        l_public_key_mac            com_api_type_pkg.t_pin_block;
        l_cert_hash                 com_api_type_pkg.t_key;
        l_cert_data                 com_api_type_pkg.t_text;
        l_hsm_device                hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text      => 'Validate an issuer public key certificate (Visa)'
        );
        
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- construct certificate
            l_cert_data := construct_issuer_cert (
                i_authority_type     => sec_api_const_pkg.AUTHORITY_TYPE_VISA
                , i_subject_id       => i_issuer_certificate.subject_id
                , i_serial_number    => i_issuer_certificate.serial_number
                , i_visa_service_id  => i_issuer_certificate.visa_service_id
                , i_cert_expir_date  => i_issuer_certificate.expir_date
                , i_ca_key_index     => i_authority_key.key_index
                , i_iss_key_index    => i_issuer_key.key_index
                , i_exponent         => i_issuer_key.exponent
                , i_certificate      => i_issuer_certificate.certificate
                , i_reminder         => i_issuer_certificate.reminder
                , i_hash             => ''
            );
            
            l_public_key_mac := nvl(i_issuer_key.public_key_mac, '');

            begin
                l_result := hsm_api_hsm_pkg.validate_iss_pk_cert_visa (
                    i_hsm_ip                => l_hsm_device.address
                    , i_hsm_port            => l_hsm_device.port
                    , i_ca_public_key       => i_authority_key.public_key
                    , i_ca_public_key_mac   => i_authority_key.public_key_mac
                    , i_ca_exponent         => i_authority_key.exponent
                    , i_iss_public_key      => i_issuer_key.public_key
                    , i_iss_private_key     => i_issuer_key.private_key
                    , i_iss_cert_data       => l_cert_data
                    , i_signature           => ''
                    , o_iss_public_key      => l_public_key
                    , io_iss_public_key_mac => l_public_key_mac
                    , o_iss_cert_hash       => l_cert_hash
                    , o_resp_mess           => l_resp_message
                );
            exception
                when com_api_error_pkg.e_fetched_value_is_null then
                    -- Wrapper hsm_api_hsm_pkg.validate_iss_pk_cert_visa for C function doesn't use indicator, so if some 
                    -- of parameters are empty (NULL) then an exception "ORA-01405: fetched column value is NULL" is raised  
                    trc_log_pkg.debug(
                        i_text => 'validate_iss_pk_cert_visa FAILED: '
                               || 'l_hsm_device [' || l_hsm_device.address || ':' || l_hsm_device.port
                               || '], i_authority_key [' || i_authority_key.public_key
                               || '][' || i_authority_key.public_key_mac || '][' || i_authority_key.exponent
                               || '], i_issuer_key [' || i_issuer_key.public_key || '][' || i_issuer_key.private_key
                               || '], l_cert_data [' || l_cert_data
                               || '], l_public_key_mac [' || l_public_key_mac || ']'
                    );
                    l_result := hsm_api_const_pkg.RESULT_CODE_COMMON_ERROR;
            end;

            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_VALIDATE_ISSUER_CERT'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => sec_api_const_pkg.AUTHORITY_TYPE_VISA
              , i_env_param3     => l_resp_message
            );

            trc_log_pkg.debug (
                i_text      => 'Validate an issuer public key certificate (Visa) - ok'
            );
        end if;
    exception
        when others then
            dbms_output.put_line(l_resp_message);
            raise;
    end;
    
    procedure validate_iss_certificate (
        i_issuer_key                in sec_api_type_pkg.t_rsa_key_rec
        , io_authority_key          in out sec_api_type_pkg.t_rsa_key_rec
        , i_issuer_cert             in sec_api_type_pkg.t_rsa_certificate_rec
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
    ) is
    begin
        trc_log_pkg.debug (
            i_text      => 'Validate certificates'
        );
        
        case i_issuer_cert.authority_type
            when sec_api_const_pkg.AUTHORITY_TYPE_MASTERCARD then
                validate_authority_cert_mc (
                    i_hsm_device_id     => i_hsm_device_id
                    , io_authority_key  => io_authority_key
                );
                
                validate_issuer_cert_mc (
                    i_hsm_device_id         => i_hsm_device_id
                    , i_issuer_key          => i_issuer_key
                    , i_authority_key       => io_authority_key
                    , i_issuer_certificate  => i_issuer_cert
                );

            when sec_api_const_pkg.AUTHORITY_TYPE_VISA then
                validate_authority_cert_visa (
                    i_hsm_device_id      => i_hsm_device_id
                    , io_authority_key   => io_authority_key
                );

                validate_issuer_cert_visa (
                    i_hsm_device_id         => i_hsm_device_id
                    , i_issuer_key          => i_issuer_key
                    , i_authority_key       => io_authority_key
                    , i_issuer_certificate  => i_issuer_cert
                );

        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_CERTIFICATION_AUTHORITY'
                , i_env_param1  => i_issuer_cert.authority_type
            );
        end case;

        trc_log_pkg.debug (
            i_text      => 'Validate certificates - ok'
        );
    end;
    
end;
/
