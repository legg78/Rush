create or replace package body ecm_api_acs_pkg is
/************************************************************
 * API interface for 3D security <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 17.04.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: ecm_api_acs_pkg <br />
 * @headcom
 ************************************************************/
 
    /*
     * Generate AAV using CVC2 or HASH algorithm
     */
    procedure generate_aav (
        i_aav_method               in com_api_type_pkg.t_dict_value
        , i_card_number            in com_api_type_pkg.t_card_number
        , i_merchant_name          in com_api_type_pkg.t_name
        , i_control_byte           in com_api_type_pkg.t_long_id
        , i_id_acs                 in com_api_type_pkg.t_long_id
        , i_auth_method            in com_api_type_pkg.t_long_id
        , o_aav                    out sec_api_type_pkg.t_key_value
    ) is
        l_result                   com_api_type_pkg.t_tiny_id;
        l_resp_message             com_api_type_pkg.t_name;
        l_hsm_device               hsm_api_type_pkg.t_hsm_device_rec;
        l_bin                      iss_api_type_pkg.t_bin_rec;
        l_cvk                      sec_api_type_pkg.t_des_key_rec;
        l_tsn                      com_api_type_pkg.t_long_id;
    begin
        l_bin := iss_api_bin_pkg.get_bin (
            i_card_number  => i_card_number
        );
            
        l_cvk := sec_api_des_key_pkg.get_key (
            i_object_id        => l_bin.id
            , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
            , i_key_type       => sec_api_const_pkg.SECURITY_DES_KEY_CVK
        );
            
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => null
            , i_hsm_action   => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
            , i_lmk_id       => l_cvk.id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- transaction sequence number 
            l_tsn := ecm_transaction_seq.nextval;

            -- generate
            l_result := hsm_api_hsm_pkg.generate_aav (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_lmk_id         => l_hsm_device.lmk_id
                , i_aav_method     => i_aav_method
                , i_key            => nvl(l_cvk.key_value, '')
                , i_key_prefix     => nvl(l_cvk.key_prefix, '')
                , i_pan            => i_card_number
                , i_merchant_name  => nvl(i_merchant_name, '')
                , i_control_byte   => i_control_byte
                , i_id_acs         => i_id_acs
                , i_auth_method    => i_auth_method
                , i_bin_key_id     => l_bin.id
                , i_tsn            => l_tsn
                , o_aav            => o_aav
                , o_resp_mess      => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => l_hsm_device.id
              , i_result_code    => l_result
              , i_error          => 'AAV_GENERATION_FAILED'
              , i_env_param1     => l_hsm_device.id
              , i_env_param2     => l_resp_message
            );
        end if;
    end;

    /*
     * Generate CAVV
     */
    procedure generate_caav (
        i_auth_res_code            in com_api_type_pkg.t_name
        , i_sec_factor_auth_code   in com_api_type_pkg.t_name
        , i_key_indicator          in com_api_type_pkg.t_name
        , i_card_number            in com_api_type_pkg.t_card_number
        , i_unpredictable_number   in com_api_type_pkg.t_long_id
        , o_cavv                   out sec_api_type_pkg.t_key_value
    ) is
        l_result                   com_api_type_pkg.t_tiny_id;
        l_resp_message             com_api_type_pkg.t_name;
        l_hsm_device               hsm_api_type_pkg.t_hsm_device_rec;
        l_bin                      iss_api_type_pkg.t_bin_rec;
        l_cvk                      sec_api_type_pkg.t_des_key_rec;
        l_atn                      com_api_type_pkg.t_long_id;
    begin
        l_bin := iss_api_bin_pkg.get_bin (
            i_card_number  => i_card_number
        );
            
        l_cvk := sec_api_des_key_pkg.get_key (
            i_object_id        => l_bin.id
            , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
            , i_key_type       => sec_api_const_pkg.SECURITY_DES_KEY_CVK
        );
            
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => null
            , i_hsm_action   => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
            , i_lmk_id       => l_cvk.id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- authentication tacking number
            l_atn := ecm_auth_tracking_seq.nextval;

            -- generate
            l_result := hsm_api_hsm_pkg.generate_cavv (
                i_hsm_ip                  => l_hsm_device.address
                , i_hsm_port              => l_hsm_device.port
                , i_lmk_id                => l_hsm_device.lmk_id
                , i_key                   => nvl(l_cvk.key_value, '')
                , i_key_prefix            => nvl(l_cvk.key_prefix, '')
                , i_auth_res_code         => i_auth_res_code
                , i_sec_factor_auth_code  => i_sec_factor_auth_code
                , i_key_indicator         => i_key_indicator
                , i_pan                   => i_card_number
                , i_unpredictable_number  => i_unpredictable_number
                , i_atn                   => to_char(l_atn)
                , o_cavv                  => o_cavv
                , o_resp_mess             => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => l_hsm_device.id
              , i_result_code    => l_result
              , i_error          => 'CAAV_GENERATION_FAILED'
              , i_env_param1     => l_hsm_device.id
              , i_env_param2     => l_resp_message
            );
        end if;
    end;

    procedure sign_data (
        i_bin                      in iss_api_type_pkg.t_bin_rec
        , i_host_id                in com_api_type_pkg.t_tiny_id
        , i_data                   in com_api_type_pkg.t_text
        , o_signed_data            out com_api_type_pkg.t_text
        , o_certificate            out com_api_type_pkg.t_key
        , o_root_certificate       out com_api_type_pkg.t_key
        , o_intermediate_cert      out com_api_type_pkg.t_key
    ) is
        l_result                   com_api_type_pkg.t_tiny_id;
        l_resp_message             com_api_type_pkg.t_name;
        l_hsm_device               hsm_api_type_pkg.t_hsm_device_rec;
        l_acs_key                  sec_api_type_pkg.t_rsa_key_rec;
        l_root_cert_key            sec_api_type_pkg.t_rsa_key_rec;
        l_intermediate_cert_key    sec_api_type_pkg.t_rsa_key_rec;
    begin
        -- get rsa key
        l_acs_key := sec_api_rsa_key_pkg.get_rsa_key (
            i_id             => null
            , i_object_id    => i_bin.id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
            , i_key_type     => sec_api_const_pkg.SECURITY_RSA_ACS_KEYSET
            , i_key_index    => null
            , i_mask_error   => com_api_type_pkg.FALSE
        );
            
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => null
            , i_hsm_action   => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
            , i_lmk_id       => l_acs_key.lmk_id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.generate_rsa_signature (
                i_hsm_ip                => l_hsm_device.address
                , i_hsm_port            => l_hsm_device.port
                , i_lmk_id              => l_hsm_device.lmk_id
                , i_data                => nvl(i_data, '')
                , i_data_length         => length(nvl(i_data, ''))
                , i_private_key         => nvl(l_acs_key.private_key, '')
                , i_private_key_length  => length(nvl(l_acs_key.private_key, ''))
                , o_sign_data           => o_signed_data
                , o_resp_mess           => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => l_hsm_device.id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_SIGNATURE_ON_MESSAGE'
              , i_env_param1     => l_hsm_device.id
              , i_env_param2     => l_resp_message
            );

            o_certificate := l_acs_key.certificate;
            
            -- get rsa key
            l_root_cert_key := sec_api_rsa_key_pkg.get_rsa_key (
                i_id             => null
                , i_object_id    => i_host_id
                , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_key_type     => sec_api_const_pkg.SECURITY_RSA_IPS_ROOT_CERT
                , i_key_index    => null
                , i_mask_error   => com_api_type_pkg.FALSE
            );
            
            -- get rsa key
            l_intermediate_cert_key := sec_api_rsa_key_pkg.get_rsa_key (
                i_id             => null
                , i_object_id    => i_host_id
                , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_key_type     => sec_api_const_pkg.SECURITY_RSA_INTERMED_CERT
                , i_key_index    => null
                , i_mask_error   => com_api_type_pkg.FALSE
            );
            
            o_root_certificate := l_root_cert_key.public_key;
            o_intermediate_cert := l_intermediate_cert_key.public_key;
        end if;
    end;
    
    procedure sign_data (
        i_bin_id                   in com_api_type_pkg.t_short_id
        , i_data                   in com_api_type_pkg.t_text
        , o_signed_data            out com_api_type_pkg.t_text
        , o_certificate            out com_api_type_pkg.t_key
        , o_root_certificate       out com_api_type_pkg.t_key
        , o_intermediate_cert      out com_api_type_pkg.t_key
    ) is
        l_bin                      iss_api_type_pkg.t_bin_rec;
        l_network_id               com_api_type_pkg.t_tiny_id;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_host_id                  com_api_type_pkg.t_tiny_id;
        l_card_inst_id             com_api_type_pkg.t_inst_id;
        l_card_network_id          com_api_type_pkg.t_network_id;
        l_card_type_id             com_api_type_pkg.t_tiny_id;
        l_card_country             com_api_type_pkg.t_country_code;
        l_pan_length               com_api_type_pkg.t_tiny_id;
    begin
        l_bin := iss_api_bin_pkg.get_bin (
            i_bin_id  => i_bin_id
        );
        
        net_api_bin_pkg.get_bin_info (
            i_card_number        => l_bin.bin
            , o_iss_inst_id      => l_inst_id
            , o_iss_network_id   => l_network_id
            , o_iss_host_id      => l_host_id
            , o_card_type_id     => l_card_type_id
            , o_card_country     => l_card_country
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_pan_length       => l_pan_length
        );
        
        sign_data (
            i_bin                  => l_bin
            , i_host_id            => l_host_id
            , i_data               => i_data
            , o_signed_data        => o_signed_data
            , o_certificate        => o_certificate
            , o_root_certificate   => o_root_certificate
            , o_intermediate_cert  => o_intermediate_cert
        );
    end;
    
    procedure sign_data (
        i_card_number              in com_api_type_pkg.t_card_number
        , i_data                   in com_api_type_pkg.t_text
        , o_signed_data            out com_api_type_pkg.t_text
        , o_certificate            out com_api_type_pkg.t_key
        , o_root_certificate       out com_api_type_pkg.t_key
        , o_intermediate_cert      out com_api_type_pkg.t_key
    ) is
        l_bin                      iss_api_type_pkg.t_bin_rec;
        l_network_id               com_api_type_pkg.t_tiny_id;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_host_id                  com_api_type_pkg.t_tiny_id;
        l_card_inst_id             com_api_type_pkg.t_inst_id;
        l_card_network_id          com_api_type_pkg.t_network_id;
        l_card_type_id             com_api_type_pkg.t_tiny_id;
        l_card_country             com_api_type_pkg.t_country_code;
        l_pan_length               com_api_type_pkg.t_tiny_id;
    begin
        l_bin := iss_api_bin_pkg.get_bin (
            i_card_number  => i_card_number
        );
        
        net_api_bin_pkg.get_bin_info (
            i_card_number        => i_card_number
            , o_iss_inst_id      => l_inst_id
            , o_iss_network_id   => l_network_id
            , o_iss_host_id      => l_host_id
            , o_card_type_id     => l_card_type_id
            , o_card_country     => l_card_country
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_pan_length       => l_pan_length
        );
        
        sign_data (
            i_bin                  => l_bin
            , i_host_id            => l_host_id
            , i_data               => i_data
            , o_signed_data        => o_signed_data
            , o_certificate        => o_certificate
            , o_root_certificate   => o_root_certificate
            , o_intermediate_cert  => o_intermediate_cert
        );
    end;
    
    function get_acs_public_key (
        i_bin_id                   in com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_key is
    begin
        return sec_api_rsa_key_pkg.get_rsa_key (
            i_id             => null
            , i_object_id    => i_bin_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
            , i_key_type     => sec_api_const_pkg.SECURITY_RSA_ACS_KEYSET
            , i_key_index    => null
            , i_mask_error   => com_api_type_pkg.TRUE
        ).public_key;
    end;

end;
/
