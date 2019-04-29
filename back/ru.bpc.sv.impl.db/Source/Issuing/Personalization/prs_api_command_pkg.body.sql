create or replace package body prs_api_command_pkg is
/************************************************************
 * API for crypto command <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 05.08.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_command_pkg <br />
 * @headcom
 ************************************************************/

    procedure gen_cvv_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_service_code        in com_api_type_pkg.t_module_code
        , o_cvv                 out com_api_type_pkg.t_module_code
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text          => 'Generating CVV... '
        );

        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.generate_cvv (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_lmk_id         => l_hsm_device.lmk_id
                , i_cvk            => nvl(i_perso_key.des_key.cvk.key_value, '')
                , i_key_prefix     => nvl(i_perso_key.des_key.cvk.key_prefix, '')
                , i_hpan           => i_perso_rec.card_number
                , i_exp_date_char  => to_char(i_perso_rec.expir_date, 'YYMM')
                , i_service_code   => i_service_code
                , o_result         => o_cvv
                , o_resp_mess      => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_CVV'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text          => 'Return CVV [#1]'
                , i_env_param1  => com_api_hash_pkg.get_param_mask(o_cvv)
            );
        end if;
    end;

    procedure gen_cvv2_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_exp_date_format     in com_api_type_pkg.t_dict_value
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_cvv                 out com_api_type_pkg.t_module_code
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Generating CVV2...'
        );
            
        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.generate_cvv (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_lmk_id         => l_hsm_device.lmk_id
                , i_cvk            => nvl(i_perso_key.des_key.cvk2.key_value, '')
                , i_key_prefix     => nvl(i_perso_key.des_key.cvk2.key_prefix, '')
                , i_hpan           => i_perso_rec.card_number
                , i_exp_date_char  => to_char( i_perso_rec.expir_date, i_exp_date_format )
                , i_service_code   => '000'
                , o_result         => o_cvv
                , o_resp_mess      => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_CVV2'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text          => 'Return CVV2 [#1]'
                , i_env_param1  => com_api_hash_pkg.get_param_mask(o_cvv)
            );
        end if;
    end;
    
    procedure gen_icvv_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_cvv                 out com_api_type_pkg.t_module_code
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Generating ICVV...'
        );

        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.generate_cvv (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_lmk_id         => l_hsm_device.lmk_id
                , i_cvk            => nvl(i_perso_key.des_key.cvk.key_value, '')
                , i_key_prefix     => nvl(i_perso_key.des_key.cvk.key_prefix, '')
                , i_hpan           => i_perso_rec.card_number
                , i_exp_date_char  => to_char( i_perso_rec.expir_date, 'YYMM' )
                , i_service_code   => '999'
                , o_result         => o_cvv
                , o_resp_mess      => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_ICVV'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text          => 'Return ICVV [#1]'
                , i_env_param1  => com_api_hash_pkg.get_param_mask(o_cvv)
            );
        end if;
    end;

    procedure gen_pvv_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_pin_block           in com_api_type_pkg.t_pin_block
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_pvv                 out com_api_type_pkg.t_tiny_id
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Generating PVV...'
        );
          
        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.generate_pvv (
                i_hsm_ip           => l_hsm_device.address
                , i_hsm_port       => l_hsm_device.port
                , i_lmk_id         => l_hsm_device.lmk_id
                , i_pvk            => nvl(i_perso_key.des_key.pvk.key_value, '')
                , i_key_prefix     => nvl(i_perso_key.des_key.pvk.key_prefix, '')
                , i_pin_block      => i_pin_block
                , i_hpan           => i_perso_rec.card_number
                , i_pvk_index      => i_perso_key.des_key.pvk.key_index
                , i_ppk            => case
                                          when l_hsm_device.manufacturer = hsm_api_const_pkg.HSM_MANUFACTURER_THALES then ''
                                          else nvl(i_perso_key.des_key.ppk.key_value, '')
                                      end
                , i_ppk_prefix     => case
                                          when l_hsm_device.manufacturer = hsm_api_const_pkg.HSM_MANUFACTURER_THALES then ''
                                          else nvl(i_perso_key.des_key.ppk.key_prefix, '')
                                      end
                , o_result         => o_pvv
                , o_resp_mess      => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_PVV'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text          => 'Return PVV [#1]'
                , i_env_param1  => com_api_hash_pkg.get_param_mask(o_pvv)
            );
        end if;
    end;

    procedure derive_ibm_3624_offset (
        i_perso_rec              in prs_api_type_pkg.t_perso_rec
        , i_pin_block            in com_api_type_pkg.t_pin_block
        , i_pin_verify_method    in com_api_type_pkg.t_dict_value
        , i_perso_key            in prs_api_type_pkg.t_perso_key_rec
        , i_decimalisation_table in com_api_type_pkg.t_pin_block
        , i_pin_length           in com_api_type_pkg.t_tiny_id
        , i_hsm_device_id        in com_api_type_pkg.t_tiny_id
        , o_pin_offset           out com_api_type_pkg.t_cmid
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_validation_data       com_api_type_pkg.t_raw_data;
        l_resp_message          com_api_type_pkg.t_name;
        l_pin_offset            com_api_type_pkg.t_name;
        l_pvk                   sec_api_type_pkg.t_des_key_rec;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Derive IBM 3624 offset...'
        );
          
        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            if i_pin_block is null then
                com_api_error_pkg.raise_error(
                    i_error  => 'PIN_BLOCK_NOT_FOUND'
                );
            end if;
            
            if i_pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED) then
                l_pvk := i_perso_key.des_key.pibk;
            else
                l_pvk := i_perso_key.des_key.pvk;
            end if;
            
            l_validation_data := 
                case when length(i_perso_rec.card_number) < 16 then
                    rpad(substr(i_perso_rec.card_number, 1, 10), 10, '0')
                else
                    substr(i_perso_rec.card_number, -16, 10)
                end;
            l_validation_data := l_validation_data ||'N'|| substr(i_perso_rec.card_number, -1, 1);
            
            l_result := hsm_api_hsm_pkg.derive_ibm_offset (
                i_hsm_ip                  => l_hsm_device.address
                , i_hsm_port              => l_hsm_device.port
                , i_lmk_id                => l_hsm_device.lmk_id
                , i_hpan                  => i_perso_rec.card_number
                , i_pvk                   => nvl(l_pvk.key_value, '')
                , i_key_prefix            => nvl(l_pvk.key_prefix, '')
                , i_decimalization_table  => nvl(i_decimalisation_table, '')
                , i_pinblock              => i_pin_block
                , i_pinblock_format       => prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
                , i_pin_length            => i_pin_length
                , i_validation_data       => l_validation_data
                , i_offset_length         => i_pin_length
                , i_ppk                   => nvl(i_perso_key.des_key.ppk.key_value, '')
                , i_ppk_prefix            => nvl(i_perso_key.des_key.ppk.key_prefix, '')
                , o_result                => l_pin_offset
                , o_resp_mess             => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_DERIVE_IBM3624_OFFSET'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );

            o_pin_offset := substr(l_pin_offset, 1, i_pin_length);

            trc_log_pkg.debug (
                i_text          => 'Return PIN offset [#1]'
                , i_env_param1  => o_pin_offset
            );
        end if;
    end;

    procedure derive_ibm_3624_pin (
        i_perso_rec              in prs_api_type_pkg.t_perso_rec
        , i_pin_verify_method    in com_api_type_pkg.t_dict_value
        , i_perso_key            in prs_api_type_pkg.t_perso_key_rec
        , i_decimalisation_table in com_api_type_pkg.t_pin_block
        , i_pin_length           in com_api_type_pkg.t_tiny_id
        , i_hsm_device_id        in com_api_type_pkg.t_tiny_id
        , o_pin_block            out com_api_type_pkg.t_pin_block
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_offset_char           com_api_type_pkg.t_pin_block;
        l_validation_data       com_api_type_pkg.t_raw_data;
        l_pvk                   sec_api_type_pkg.t_des_key_rec;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Derive IBM 3624 PIN block...'
        );
            
        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            if i_pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED) then
                l_pvk := i_perso_key.des_key.pibk;
            else
                l_pvk := i_perso_key.des_key.pvk;
            end if;
            l_offset_char := to_char( i_perso_rec.pvv, 'FM0009' ) || 'FFFFFFFF';
            
            l_validation_data := 
            case when length(i_perso_rec.card_number) < 16 then
                rpad(substr(i_perso_rec.card_number, 1, 10), 10, '0')
            else
                substr(i_perso_rec.card_number, -16, 10)
            end;
            l_validation_data := l_validation_data ||'N'|| substr(i_perso_rec.card_number, -1, 1);
            
            l_result := hsm_api_hsm_pkg.derive_ibm_pin (
                i_hsm_ip                  => l_hsm_device.address
                , i_hsm_port              => l_hsm_device.port
                , i_lmk_id                => l_hsm_device.lmk_id
                , i_hpan                  => i_perso_rec.card_number
                , i_pvk                   => nvl(l_pvk.key_value, '')
                , i_key_prefix            => nvl(l_pvk.key_prefix, '')
                , i_decimalization_table  => nvl(i_decimalisation_table, '')
                , i_offset                => l_offset_char
                , i_pin_length            => i_pin_length
                , i_validation_data       => l_validation_data
                , i_ppk                   => nvl(i_perso_key.des_key.ppk.key_value, '')
                , i_ppk_prefix            => nvl(i_perso_key.des_key.ppk.key_prefix, '')
                , o_result                => o_pin_block
                , o_resp_mess             => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_DERIVE_IBM3624_PIN'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text          => 'Return PIN block [#1]'
                , i_env_param1  => com_api_hash_pkg.get_param_mask(o_pin_block)
            );
        end if;
    end;

    procedure generate_random_pin (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_pin_length          in com_api_type_pkg.t_tiny_id
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_pin_block           out com_api_type_pkg.t_pin_block
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Generating random PIN block...'
        );

        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.generate_random_pin (
                i_hsm_ip              => l_hsm_device.address
                , i_hsm_port          => l_hsm_device.port
                , i_lmk_id            => l_hsm_device.lmk_id
                , i_hpan              => i_perso_rec.card_number
                , i_pin_length        => i_pin_length
                , i_pin_block_format  => prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
                , i_key_prefix        => nvl(i_perso_key.des_key.ppk.key_prefix, '')
                , i_key_length        => nvl(i_perso_key.des_key.ppk.key_length, 0)
                , i_key_value         => nvl(i_perso_key.des_key.ppk.key_value, '')
                , o_result            => o_pin_block
                , o_resp_mess         => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATION_RANDOM_PIN'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text          => 'Return PIN block [#1]'
                , i_env_param1  => com_api_hash_pkg.get_param_mask(o_pin_block)
            );
        end if;
    end;
    
    procedure gen_pin_block (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_pin_block           out com_api_type_pkg.t_pin_block
    ) is
    begin
        trc_log_pkg.debug (
            i_text  => 'Gen PIN block...'
        );
        
        if i_perso_method.pin_verify_method = prs_api_const_pkg.PIN_VERIFIC_METHOD_UNREQUIRED then
            trc_log_pkg.debug (
                i_text  => 'PIN not required...'
            );
            return;
        end if;
        
        if i_perso_rec.pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE then
            generate_random_pin (
                i_perso_rec        => i_perso_rec
                , i_perso_key      => i_perso_key
                , i_hsm_device_id  => i_hsm_device_id
                , i_pin_length     => i_perso_method.pin_length
                , o_pin_block      => o_pin_block
            );
            
        elsif i_perso_method.pin_store_method = prs_api_const_pkg.PIN_STORING_METHOD_YES 
              and i_perso_method.pin_verify_method = prs_api_const_pkg.PIN_VERIFIC_METHOD_PVV
        then
            if i_perso_rec.pin_block is not null then
                trc_log_pkg.debug (
                    i_text  => 'Getting storing pinblock'
                );

                o_pin_block := i_perso_rec.pin_block;

            else
                generate_random_pin (
                    i_perso_rec        => i_perso_rec
                    , i_perso_key      => i_perso_key
                    , i_hsm_device_id  => i_hsm_device_id
                    , i_pin_length     => i_perso_method.pin_length
                    , o_pin_block      => o_pin_block
                );

            end if;

        elsif i_perso_method.pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_IBM_3624
                                                 , prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED) then
            if i_perso_rec.pvv is not null then
                derive_ibm_3624_pin (
                    i_perso_rec               => i_perso_rec
                    , i_perso_key             => i_perso_key
                    , i_pin_verify_method     => i_perso_method.pin_verify_method
                    , i_decimalisation_table  => i_perso_method.decimalisation_table
                    , i_hsm_device_id         => i_hsm_device_id
                    , i_pin_length            => i_perso_method.pin_length
                    , o_pin_block             => o_pin_block
                );

            else
                generate_random_pin (
                    i_perso_rec        => i_perso_rec
                    , i_perso_key      => i_perso_key
                    , i_hsm_device_id  => i_hsm_device_id
                    , i_pin_length     => i_perso_method.pin_length
                    , o_pin_block      => o_pin_block
                );

            end if;

        else
            generate_random_pin (
                i_perso_rec        => i_perso_rec
                , i_perso_key      => i_perso_key
                , i_hsm_device_id  => i_hsm_device_id
                , i_pin_length     => i_perso_method.pin_length
                , o_pin_block      => o_pin_block
            );
            
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Gen PIN block - ok'
        );
    end;
    
    procedure translate_pinblock (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_pinblock_format     in com_api_type_pkg.t_dict_value
        , o_pin_block           out com_api_type_pkg.t_pin_block
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Translate PIN block from LMK to ZPK...'
        );
          
        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.translate_pinblock (
                i_hsm_ip                    => l_hsm_device.address
                , i_hsm_port                => l_hsm_device.port
                , i_lmk_id                  => l_hsm_device.lmk_id
                , i_input_key_type          => sec_api_const_pkg.SECURITY_DES_KEY_LMK
                , i_input_key_prefix        => ''--nvl(l_perso_key.des_key.ppk.key_prefix,'')
                , i_input_key_value         => ''--nvl(l_perso_key.des_key.ppk.key_value, '')
                , i_input_pinblock_format   => nvl(i_pinblock_format, '')
                , i_encrypted_pin_block     => nvl(i_perso_rec.pin_block, '')
                , i_output_key_type         => sec_api_const_pkg.SECURITY_DES_KEY_ZPK
                , i_output_key_prefix       => nvl(i_perso_key.des_key.pek_translation.key_prefix,'')
                , i_output_key_value        => nvl(i_perso_key.des_key.pek_translation.key_value, '')
                , i_output_pinblock_format  => nvl(i_pinblock_format, '')
                , i_hpan                    => nvl(i_perso_rec.card_number, '')
                , o_result                  => o_pin_block
                , o_resp_mess               => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_TRANSLATE_PINBLOCK'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            /*trc_log_pkg.info (
                i_text          => 'Translate pin block: key[#1] pinblock_encrypted[#2]'
                , i_env_param1  => nvl(i_perso_key.des_key.pek_translation.key_prefix,'')||nvl(i_perso_key.des_key.pek_translation.key_value, '')
                , i_env_param2  => o_pin_block
            );*/
            trc_log_pkg.debug (
                i_text          => 'Return translated PIN block [#1]'
                , i_env_param1  => com_api_hash_pkg.get_param_mask(o_pin_block)
            );
        end if;
    end;

    procedure hash_block_data (
        i_data                  in com_api_type_pkg.t_raw_data
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_hash                out com_api_type_pkg.t_raw_data
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Hash a block of data....'
        );
            
        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.hash_block_data (
                i_hsm_ip               => l_hsm_device.address
                , i_hsm_port           => l_hsm_device.port
                , i_hash_identifier    => sec_api_const_pkg.HASH_ALGORITHM_SHA1
                , i_data               => i_data
                , i_data_length        => nvl(length(i_data), 0)
                , i_secret_key         => ''
                , i_secret_key_length  => 0
                , o_hash_value         => o_hash
                , i_hash_value_length  => 4000
                , o_resp_message       => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_HASHING_DATA'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text  => 'Hash a block of data - ok'
            );
        end if;
    end;
    
    procedure sign_static_appl_data (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_static_data         in com_api_type_pkg.t_lob2_tab
        , o_signed_data         out nocopy com_api_type_pkg.t_lob2_tab
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
        l_data_auth_code        com_api_type_pkg.t_tiny_id;
        l_signed_data           com_api_type_pkg.t_raw_data;
        l_index                 com_api_type_pkg.t_name;
    begin
        trc_log_pkg.debug (
            i_text          => 'generate static data authentication signature...[#1]'
            , i_env_param1  => i_static_data.count
        );
            
        -- get HSM device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- set data authentication code
            case l_hsm_device.manufacturer
                when hsm_api_const_pkg.HSM_MANUFACTURER_THALES then
                    l_data_auth_code := 0;
                
                when hsm_api_const_pkg.HSM_MANUFACTURER_SAFENET then
                    l_data_auth_code := 0; -- need gen
                
                else
                    com_api_error_pkg.raise_error (
                        i_error         => 'UNKNOWN_HSM_DEVICE_MANUFACTURER'
                        , i_env_param1  => l_hsm_device.manufacturer
                    );
            
            end case;
            
            l_index := i_static_data.first;
            while l_index is not null loop
                if i_static_data(l_index) is not null then
                    l_result := hsm_api_hsm_pkg.sign_static_appl_data (
                        i_hsm_ip                => l_hsm_device.address
                        , i_hsm_port            => l_hsm_device.port
                        , i_hash_identifier     => sec_api_const_pkg.HASH_ALGORITHM_SHA1
                        , i_data_auth_code      => l_data_auth_code
                        , i_static_data         => nvl(i_static_data(l_index), '')
                        , i_private_key_flag    => prs_api_const_pkg.THALES_HOST_STORED_KEY
                        , i_private_key         => nvl(i_perso_key.rsa_key.issuer_key.private_key, '')
                        , i_imk_dac_prefix      => nvl(i_perso_key.des_key.imk_dac.key_prefix, '')
                        , i_imk_dac_length      => nvl(i_perso_key.des_key.imk_dac.key_length, 0)
                        , i_imk_dac             => nvl(i_perso_key.des_key.imk_dac.key_value, '')
                        , i_hpan                => substr(rul_api_name_pkg.pad_byte_len(i_perso_rec.card_number)
                                                       || rul_api_name_pkg.pad_byte_len(i_perso_rec.seq_number), -16, 16)
                        , o_sign_data           => l_signed_data
                        , o_resp_mess           => l_resp_message
                    );
                    -- if an error occurs then we should process it and raise some application error 
                    hsm_api_device_pkg.process_error(
                        i_hsm_devices_id => i_hsm_device_id
                      , i_result_code    => l_result
                      , i_error          => 'ERROR_SIGN_SDA' -- Can't sign static application data for SDA
                      , i_env_param1     => i_hsm_device_id
                      , i_env_param2     => l_resp_message
                    );
                end if;
                
                o_signed_data(l_index) := l_signed_data;
                l_index := i_static_data.next(l_index);
            end loop;

            trc_log_pkg.debug (
                i_text  => 'Generate static data authentication signature - ok'
            );
        end if;
    end;

    procedure derive_icc_3des_keys (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_result              out prs_api_type_pkg.t_icc_derived_keys_rec
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_idk_ac_lmk            com_api_type_pkg.t_key;
        l_idk_smi_lmk           com_api_type_pkg.t_key;
        l_idk_smc_lmk           com_api_type_pkg.t_key;
        l_idk_idn_lmk           com_api_type_pkg.t_key;
        l_idk_cvc3_lmk          com_api_type_pkg.t_key;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Derive ICC 3des keys...'
        );
         
        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.derive_icc_3des_keys (
                i_hsm_ip                => l_hsm_device.address
                , i_hsm_port            => l_hsm_device.port

                , i_mode_flag           => prs_api_const_pkg.THALES_GENERATE_OTS_DK_IDN
                , i_kek_prefix          => nvl(i_perso_key.des_key.kek.key_prefix,'')
                , i_kek                 => nvl(i_perso_key.des_key.kek.key_value, '')
                , i_hpan                => substr( rul_api_name_pkg.pad_byte_len(i_perso_rec.card_number)
                                           || rul_api_name_pkg.pad_byte_len(i_perso_rec.seq_number), -16, 16 )

                , i_imk_ac_prefix       => nvl(i_perso_key.des_key.imk_ac.key_prefix,'')
                , i_imk_ac              => nvl(i_perso_key.des_key.imk_ac.key_value, '')
                , i_imk_smi_prefix      => nvl(i_perso_key.des_key.imk_smi.key_prefix,'')
                , i_imk_smi             => nvl(i_perso_key.des_key.imk_smi.key_value, '')
                , i_imk_smc_prefix      => nvl(i_perso_key.des_key.imk_smc.key_prefix,'')
                , i_imk_smc             => nvl(i_perso_key.des_key.imk_smc.key_value, '')
                , i_imk_idn_prefix      => nvl(i_perso_key.des_key.imk_idn.key_prefix,'')
                , i_imk_idn             => nvl(i_perso_key.des_key.imk_idn.key_value, '')

                , o_idk_ac_lmk          => l_idk_ac_lmk
                , o_idk_smi_lmk         => l_idk_smi_lmk
                , o_idk_smc_lmk         => l_idk_smc_lmk
                , o_idk_idn_lmk         => l_idk_idn_lmk

                , i_idk_ac_kek_length   => 32
                , o_idk_ac_kek          => o_result.idk_ac.key_value
                , o_idk_ac_kek_kcv      => o_result.idk_ac.check_value
                , i_idk_smi_kek_length  => 32
                , o_idk_smi_kek         => o_result.idk_smi.key_value
                , o_idk_smi_kek_kcv     => o_result.idk_smi.check_value
                , i_idk_smc_kek_length  => 32
                , o_idk_smc_kek         => o_result.idk_smc.key_value
                , o_idk_smc_kek_kcv     => o_result.idk_smc.check_value
                , i_idk_idn_kek_length  => 32
                , o_idk_idn_kek         => o_result.idk_idn.key_value
                , o_idk_idn_kek_kcv     => o_result.idk_idn.check_value

                , o_resp_mess           => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
                --Can't generate ICC derived 3des keys
              , i_error          => 'ERROR_DERIVE_ICC_3DES_KEYS'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );

            trc_log_pkg.debug (
                i_text          => 'ICC IDK_AC(KEK)[#1] check_value[#2]'
                , i_env_param1  => o_result.idk_ac.key_value
                , i_env_param2  => o_result.idk_ac.check_value
            );
            trc_log_pkg.debug (
                i_text          => 'ICC IDK_SMI(KEK)[#1] check_value[#2]'
                , i_env_param1  => o_result.idk_smi.key_value
                , i_env_param2  => o_result.idk_smi.check_value
            );
            trc_log_pkg.debug (
                i_text          => 'ICC IDK_SMC(KEK)[#1] check_value[#2]]'
                , i_env_param1  => o_result.idk_smc.key_value
                , i_env_param2  => o_result.idk_smc.check_value
            );
            trc_log_pkg.debug (
                i_text          => 'ICC IDK_IDN(KEK)[#1] check_value[#2]'
                , i_env_param1  => o_result.idk_idn.key_value
                , i_env_param2  => o_result.idk_idn.check_value
            );

            if i_perso_method.is_contactless = com_api_type_pkg.TRUE then
                trc_log_pkg.debug (
                    i_text  => 'Derive ICC cvc3 key'
                );
                
                l_result := hsm_api_hsm_pkg.derive_icc_3des_keys (
                    i_hsm_ip                => l_hsm_device.address
                    , i_hsm_port            => l_hsm_device.port

                    , i_mode_flag           => prs_api_const_pkg.THALES_GENERATE_OTS_DK_IDN
                    , i_kek_prefix          => nvl(i_perso_key.des_key.kek.key_prefix,'')
                    , i_kek                 => nvl(i_perso_key.des_key.kek.key_value, '')
                    , i_hpan                => substr(
                                                   rul_api_name_pkg.pad_byte_len(i_perso_rec.card_number) 
                                                || rul_api_name_pkg.pad_byte_len(
                                                       case
                                                           when i_perso_rec.emv_scheme_type = emv_api_const_pkg.EMV_SCHEME_VISA then 0
                                                           else i_perso_rec.seq_number
                                                       end
                                                   )
                                                 , -16, 16
                                               )

                    , i_imk_ac_prefix       => nvl(i_perso_key.des_key.imk_ac.key_prefix,'')
                    , i_imk_ac              => nvl(i_perso_key.des_key.imk_ac.key_value, '')
                    , i_imk_smi_prefix      => nvl(i_perso_key.des_key.imk_smi.key_prefix,'')
                    , i_imk_smi             => nvl(i_perso_key.des_key.imk_smi.key_value, '')
                    , i_imk_smc_prefix      => nvl(i_perso_key.des_key.imk_smc.key_prefix,'')
                    , i_imk_smc             => nvl(i_perso_key.des_key.imk_smc.key_value, '')
                    , i_imk_idn_prefix      => nvl(i_perso_key.des_key.imk_cvc3.key_prefix,'')
                    , i_imk_idn             => nvl(i_perso_key.des_key.imk_cvc3.key_value, '')

                    , o_idk_ac_lmk          => l_idk_ac_lmk
                    , o_idk_smi_lmk         => l_idk_smi_lmk
                    , o_idk_smc_lmk         => l_idk_smc_lmk
                    , o_idk_idn_lmk         => l_idk_cvc3_lmk

                    , i_idk_ac_kek_length   => 32
                    , o_idk_ac_kek          => o_result.idk_ac.key_value
                    , o_idk_ac_kek_kcv      => o_result.idk_ac.check_value
                    , i_idk_smi_kek_length  => 32
                    , o_idk_smi_kek         => o_result.idk_smi.key_value
                    , o_idk_smi_kek_kcv     => o_result.idk_smi.check_value
                    , i_idk_smc_kek_length  => 32
                    , o_idk_smc_kek         => o_result.idk_smc.key_value
                    , o_idk_smc_kek_kcv     => o_result.idk_smc.check_value
                    , i_idk_idn_kek_length  => 32
                    , o_idk_idn_kek         => o_result.idk_cvc3.key_value
                    , o_idk_idn_kek_kcv     => o_result.idk_cvc3.check_value

                    , o_resp_mess           => l_resp_message
                );
                -- if an error occurs then we should process it and raise some application error 
                hsm_api_device_pkg.process_error(
                    i_hsm_devices_id => i_hsm_device_id
                  , i_result_code    => l_result
                    --Can't generate ICC derived 3des keys
                  , i_error          => 'ERROR_DERIVE_ICC_3DES_KEYS'
                  , i_env_param1     => i_hsm_device_id
                  , i_env_param2     => l_resp_message
                );
                trc_log_pkg.debug (
                    i_text          => 'ICC IDK_CVC3(KEK)[#1] check_value[#2]'
                    , i_env_param1  => o_result.idk_cvc3.key_value
                    , i_env_param2  => o_result.idk_cvc3.check_value
                );
            end if;
            
            trc_log_pkg.debug (
                i_text  => 'Derive ICC 3des keys - ok'
            );
        end if;
    end;
    
    procedure generate_icc_rsa_keys (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_static_data         in com_api_type_pkg.t_lob2_tab
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_result              out prs_api_type_pkg.t_icc_rsa_key_rec
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
        l_length_bytes          com_api_type_pkg.t_tiny_id;
        l_serial_number         com_api_type_pkg.t_medium_id;
        l_index                 com_api_type_pkg.t_name;
        
        function icc_next_serial_number (
            p_bin_id                in com_api_type_pkg.t_short_id
        ) return com_api_type_pkg.t_medium_id is
            l_result                com_api_type_pkg.t_medium_id;
            l_sequence_name         com_api_type_pkg.t_name;
        begin
            l_sequence_name := 'prs_icc_serial_no_'|| to_char(p_bin_id) ||'_seq';
        
            begin
                execute immediate 'select '||l_sequence_name||'.nextval from dual' into l_result;
            exception
                when com_api_error_pkg.e_sequence_does_not_exist then
                    execute immediate 
                        'create sequence '|| l_sequence_name ||'
                         minvalue 1
                         maxvalue 999999999999
                         start with 2
                         increment by 1
                         nocache';
                    l_result := 1;
            end;
        
            return l_result;
        end;
    begin
        trc_log_pkg.debug (
            i_text  => 'Generate ICC keypair...'
        );
            
        -- get HSM device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            o_result.clear_comp_format := i_perso_method.icc_sk_component;
            o_result.clear_comp_padding := prs_api_const_pkg.CLEAR_COMP_PAD_TO_8B_00;
            o_result.encryption_mode := sec_api_const_pkg.ENCRYPTION_METHOD_ECB;
            l_length_bytes := 0;
            
            l_serial_number := icc_next_serial_number (
                p_bin_id  => i_perso_rec.bin_id
            );
            
            if l_hsm_device.manufacturer = hsm_api_const_pkg.HSM_MANUFACTURER_THALES then
                case i_perso_method.icc_sk_format
                    when prs_api_const_pkg.RSA_FORMAT_CHINESE then
                        o_result.clear_comp_padding := prs_api_const_pkg.CLEAR_COMP_PAD_TO_8B_80;
                        o_result.encryption_mode := sec_api_const_pkg.ENCRYPTION_METHOD_CBC;

                        if i_perso_method.icc_sk_component != prs_api_const_pkg.CLEAR_COMP_FMT_LENGTH_IN_1BYTE then
                            -- private key component format not supported
                            com_api_error_pkg.raise_error(
                                i_error         => 'BAD_PRIVATE_KEY_COMPONENT_FORMAT'
                                , i_env_param1  => i_perso_method.icc_sk_format
                                , i_env_param2  => i_perso_method.icc_sk_component
                            );
                        end if;
                        
                        l_length_bytes := 0;
                    
                    when prs_api_const_pkg.RSA_FORMAT_EXPT_AND_MODULUS then
                        o_result.clear_comp_padding := prs_api_const_pkg.CLEAR_COMP_PAD_TO_8B_00;
                        o_result.encryption_mode := sec_api_const_pkg.ENCRYPTION_METHOD_ECB;
                        
                        l_length_bytes := case i_perso_method.icc_sk_component when prs_api_const_pkg.CLEAR_COMP_FMT_LENGTH_IN_1BYTE then 1 else 0 end;
                            
                else
                    -- RSA Private Key output format not supported
                    com_api_error_pkg.raise_error (
                        i_error         => 'UNKNOWN_PRIVATE_KEY_OUTPUT_FORMAT'
                        , i_env_param1  => i_perso_method.icc_sk_format
                    );
                    
                end case;
            end if;
            
            l_index := i_static_data.first;
            while l_index is not null loop
                trc_log_pkg.debug (
                    i_text          => 'Process [#1] profile'
                    , i_env_param1  => l_index
                );
                
                -- init
                o_result.certificate(l_index) := '';
                o_result.reminder(l_index) := '';

                -- generate icc rsa keypair for contact profile
                if l_index = emv_api_const_pkg.PROFILE_CONTACT then
                    l_result := hsm_api_hsm_pkg.generate_icc_rsa_keypair (
                        i_hsm_ip                => l_hsm_device.address
                        , i_hsm_port            => l_hsm_device.port
                        , i_mode_flag           => prs_api_const_pkg.THALES_EUROPAY_P_EATS_Q
                        , i_modulus_len         => i_perso_method.icc_module_length
                        , i_output_format       => i_perso_method.icc_sk_format
                        , i_kek_prefix          => nvl(i_perso_key.des_key.kek.key_prefix,'')
                        , i_kek                 => nvl(i_perso_key.des_key.kek.key_value, '')
                        , i_encrypt_mode        => o_result.encryption_mode
                        , i_init_vector         => 0
                        , i_key_data_len        => l_length_bytes
                        , i_public_exponent     => '03'
                        , i_private_key         => nvl(i_perso_key.rsa_key.issuer_key.private_key, '')
                        , i_pan                 => rul_api_name_pkg.pad_byte_len(i_perso_rec.card_number, 'PADTRGHT','F', 10)
                        , i_cert_expir_date     => to_char(i_perso_rec.expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
                        , i_cert_serial_number  => l_serial_number
                        , i_auth_data           => ''
                        , i_cert_data           => nvl(i_static_data(l_index), '')
                        , o_public_key          => o_result.public_key
                        , o_public_mac          => o_result.public_key_mac
                        , o_private_key         => o_result.private_key
                        , o_private_exp         => o_result.private_exponent
                        , o_private_mod         => o_result.private_modulus
                        , o_certificate         => o_result.certificate(l_index)
                        , o_remainder           => o_result.reminder(l_index)
                        , o_private_p           => o_result.private_p
                        , o_private_q           => o_result.private_q
                        , o_private_dp          => o_result.private_dp
                        , o_private_dq          => o_result.private_dq
                        , o_private_u           => o_result.private_u
                        , o_resp_mess           => l_resp_message
                    );
                    -- if an error occurs then we should process it and raise some application error 
                    hsm_api_device_pkg.process_error(
                        i_hsm_devices_id => i_hsm_device_id
                      , i_result_code    => l_result
                      , i_error          => 'ERROR_GENERATE_ICC_KEYPAIR' -- Can't generate ICC keypair
                      , i_env_param1     => i_hsm_device_id
                      , i_env_param2     => l_resp_message
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Public key[#1] mac[#2]'
                        , i_env_param1  => o_result.public_key
                        , i_env_param2  => o_result.public_key_mac
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key [#1]'
                        , i_env_param1  => o_result.private_key
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key Exponent[#1]'
                        , i_env_param1  => o_result.private_exponent
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key Modulus[#1]'
                        , i_env_param1  => o_result.private_modulus
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key Prime P[#1]'
                        , i_env_param1  => o_result.private_p
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key Prime Q[#1]'
                        , i_env_param1  => o_result.private_q
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key D1[#1]'
                        , i_env_param1  => o_result.private_dp
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key D2[#1]'
                        , i_env_param1  => o_result.private_dq
                    );
                    trc_log_pkg.debug (
                        i_text          => 'ICC Private key 1/Q MOD P[#1]'
                        , i_env_param1  => o_result.private_u
                    );
                end if;
            
            -- sign icc public key
                o_result.certificate(l_index) := '';
                o_result.reminder(l_index) := '';
                
                l_result := hsm_api_hsm_pkg.sign_icc_public_key (
                    i_hsm_ip                 => l_hsm_device.address
                    , i_hsm_port             => l_hsm_device.port
                    , i_icc_public_key       => o_result.public_key
                    , i_icc_public_exponent  => '03'
                    , i_icc_public_mac       => o_result.public_key_mac
                    , i_iss_private_key      => nvl(i_perso_key.rsa_key.issuer_key.private_key, '')
                    , i_auth_data            => ''
                    , i_cert_data            => case when l_index = emv_api_const_pkg.PROFILE_PAYWAVE_QVSDC then
                                                    ''
                                                else
                                                    nvl(i_static_data(l_index), '')
                                                end
                    , i_cert_expir_date      => to_char(i_perso_rec.expir_date, prs_api_const_pkg.EXP_DATE_CERT_FORMAT)
                    , i_cert_serial_number   => l_serial_number
                    , i_pan                  => rul_api_name_pkg.pad_byte_len(i_perso_rec.card_number, 'PADTRGHT','F', 10)
                    , o_certificate          => o_result.certificate(l_index)
                    , o_remainder            => o_result.reminder(l_index)
                    , o_resp_mess            => l_resp_message
                );
                -- if an error occurs then we should process it and raise some application error 
                hsm_api_device_pkg.process_error(
                    i_hsm_devices_id => i_hsm_device_id
                  , i_result_code    => l_result
                  , i_error          => 'ERROR_SIGN_ICC_PUBLIC_KEY' -- Can't sign ICC public key
                  , i_env_param1     => i_hsm_device_id
                  , i_env_param2     => l_resp_message
                );

                trc_log_pkg.debug (
                    i_text          => 'ICC Certificate [#1] Remainder[#2]'
                    , i_env_param1  => o_result.certificate(l_index)
                    , i_env_param2  => o_result.reminder(l_index)
                );
                
                l_index := i_static_data.next(l_index);
            end loop;
            
            trc_log_pkg.debug (
                i_text  => 'Generate ICC keypair - ok'
            );
        end if;
    end;

    procedure import_key_under_kek (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_kek                 in sec_api_type_pkg.t_des_key_rec
        , i_user_key            in sec_api_type_pkg.t_des_key_rec
        , o_new_key             out sec_api_type_pkg.t_des_key_rec
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Import key under KEK...'
        );

        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.import_key_under_kek (
                i_hsm_ip            => l_hsm_device.address
                , i_hsm_port        => l_hsm_device.port
                , i_kek_prefix      => nvl(i_kek.key_prefix,'')
                , i_kek_value       => nvl(i_kek.key_value,'')
                , i_user_key_type   => sec_api_const_pkg.SECURITY_DES_KEY_TAK
                , i_user_key_value  => nvl(i_user_key.key_value,'')
                , i_decrypt_mode    => sec_api_const_pkg.ENCRYPTION_METHOD_ECB
                , o_key_value       => o_new_key.key_value
                , o_resp_mess       => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_IMPORT_KEY_UNDER_KEK'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );

            o_new_key.key_type := sec_api_const_pkg.SECURITY_DES_KEY_TAK;
            o_new_key.key_length := nvl(length(o_new_key.key_value), 0);

            trc_log_pkg.debug (
                i_text  => 'Import key under KEK - ok'
            );
        end if;
    end;

    procedure translate_key_scheme (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key                 in sec_api_type_pkg.t_des_key_rec
        , o_new_key             out sec_api_type_pkg.t_des_key_rec
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Translate key scheme...'
        );

        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_result := hsm_api_hsm_pkg.translate_key_scheme (
                i_hsm_ip            => l_hsm_device.address
                , i_hsm_port        => l_hsm_device.port
                , i_key_type        => nvl(i_key.key_type, '')
                , i_key_value       => nvl(i_key.key_value, '')
                , i_key_prefix      => nvl(i_key.key_prefix, '')
                , i_new_key_scheme  => 'U'
                , o_new_key_value   => o_new_key.key_value
                , o_new_key_prefix  => o_new_key.key_prefix
                , o_resp_mess       => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_TRANSLATE_KEY_SCHEME'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );

            o_new_key.key_type := sec_api_const_pkg.SECURITY_DES_KEY_TAK;
            o_new_key.key_length := nvl(length(o_new_key.key_value), 0);

            sec_api_des_key_pkg.generate_key_check_value (
                i_key_type         => nvl(i_key.key_type, '')
                , i_hsm_device_id  => i_hsm_device_id
                , i_key_length     => nvl(o_new_key.key_length, 0)
                , i_key_value      => nvl(o_new_key.key_value, '')
                , i_key_prefix     => nvl(o_new_key.key_prefix, '')
                , o_check_value    => o_new_key.check_value
            );

            trc_log_pkg.debug (
                i_text  => 'Translate key scheme - ok'
            );
        end if;
    end;

    procedure generate_mac (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key                 in sec_api_type_pkg.t_des_key_rec
        , i_message_data        in com_api_type_pkg.t_raw_data
        , i_convert_message     in com_api_type_pkg.t_boolean
        , o_mac                 out com_api_type_pkg.t_name
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
        l_message_hex           com_api_type_pkg.t_raw_data;
        
        function pad_track_for_mac (
            i_hex               in com_api_type_pkg.t_raw_data 
        ) return com_api_type_pkg.t_raw_data is
            l_length            com_api_type_pkg.t_tiny_id;
            l_result            com_api_type_pkg.t_raw_data;
        begin
            l_result := i_hex || '80';
            l_length := floor(nvl(length(l_result), 0) / 16 ) * 16 + sign(mod(nvl(length(l_result ), 0), 16)) * 16;
            l_result := rpad(l_result, l_length, '0');
            return l_result;
        end;

    begin
        trc_log_pkg.debug (
            i_text  => 'Generate MAC...'
        );

        -- get HSM
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            if i_convert_message = com_api_type_pkg.TRUE then
                l_message_hex := prs_api_util_pkg.bin2hex(i_message_data);
            else
                l_message_hex := i_message_data;
            end if;
            l_message_hex := pad_track_for_mac(l_message_hex);

            l_result := hsm_api_hsm_pkg.generate_mac (
                i_hsm_ip            => l_hsm_device.address
                , i_hsm_port        => l_hsm_device.port
                , i_key_type        => nvl(i_key.key_type, '')
                , i_key_value       => nvl(i_key.key_value, '')
                , i_key_prefix      => nvl(i_key.key_prefix, '')
                , i_message_data    => nvl(l_message_hex, '')
                , i_message_length  => nvl(length(l_message_hex), 0)
                , o_mac             => o_mac
                , o_resp_mess       => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_GENERATE_MAC'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );
            trc_log_pkg.debug (
                i_text  => 'Generate MAC - ok'
            );
        end if;
    end;
    
end; 
/
