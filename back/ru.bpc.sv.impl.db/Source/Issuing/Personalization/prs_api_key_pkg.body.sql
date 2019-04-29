create or replace package body prs_api_key_pkg is
/************************************************************
 * The API for keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.ru) at 20.05.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-06-30 15:04:48 +0400#$ <br />
 * Revision: $LastChangedRevision: 0000 $ <br />
 * Module: PRS_API_KEY_PKG <br />
 * @headcom
 ************************************************************/

    g_des_keys          prs_api_type_pkg.t_des_key_by_hsm_tab;
    g_rsa_keys          prs_api_type_pkg.t_rsa_key_by_object_tab;

    procedure clear_global_data is
    begin
        g_des_keys.delete;
        g_rsa_keys.delete;
    end;
    
    function get_key_schema_entity (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_key_type                in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value is
        l_result                    com_api_type_pkg.t_dict_value;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting key schema entity [#1][#2][#3]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => i_key_schema_id
            , i_env_param3  => i_key_type
        );

        select
            se.entity_type
        into
            l_result
        from
            prs_key_schema sc
            , prs_key_schema_entity se
        where
            sc.id = i_key_schema_id
            and sc.inst_id = i_inst_id
            and se.key_schema_id = sc.id
            and se.key_type = i_key_type;
        
        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'ILLEGAL_KEY_TYPE_FOR_SCHEMA'
                , i_env_param1  => i_key_schema_id
                , i_env_param2  => i_key_type
            );
    end;
    
    function get_object_id (
        i_entity_type               in com_api_type_pkg.t_dict_value
        , i_perso_rec               in prs_api_type_pkg.t_perso_rec
    ) return com_api_type_pkg.t_long_id is
        l_object_id                 com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting object id [#1]'
            , i_env_param1  => i_entity_type
        );
        
        case i_entity_type
            when iss_api_const_pkg.ENTITY_TYPE_CARD then
                l_object_id := i_perso_rec.card_id;
            when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
                l_object_id := i_perso_rec.card_instance_id;
            when iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                l_object_id := i_perso_rec.customer_id;
            when iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then
                l_object_id := i_perso_rec.cardholder_id;
            when iss_api_const_pkg.ENTITY_TYPE_ISS_BIN then
                l_object_id := i_perso_rec.bin_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'NOT_SUPPORTED_ENTITY_TYPE'
                , i_env_param1  => i_entity_type
            );
        end case;
        
        return l_object_id;
    end;
        
    function get_perso_keys (
        i_perso_rec                 in prs_api_type_pkg.t_perso_rec
        , i_perso_method            in prs_api_type_pkg.t_perso_method_rec
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
    ) return prs_api_type_pkg.t_perso_key_rec is

        l_perso_key_rec             prs_api_type_pkg.t_perso_key_rec;
        l_hsm_device                hsm_api_type_pkg.t_hsm_device_rec;
        
        function get_des_key (
            i_key_type                  in com_api_type_pkg.t_dict_value
        ) return sec_api_type_pkg.t_des_key_rec is
            l_des_key                   sec_api_type_pkg.t_des_key_rec;
            l_key_index                 com_api_type_pkg.t_tiny_id;
            l_object_id                 com_api_type_pkg.t_long_id;
            l_entity_type               com_api_type_pkg.t_dict_value;
        begin
            trc_log_pkg.debug (
                i_text          => 'Getting des keys [#1]'
                , i_env_param1  => i_key_type
            );
            
            -- get key schema entity
            l_entity_type := get_key_schema_entity (
                i_inst_id          => i_perso_rec.inst_id
                , i_key_schema_id  => i_perso_method.key_schema_id
                , i_key_type       => i_key_type
            );
            
            -- get object identifier
            l_object_id := get_object_id (
                i_entity_type  => l_entity_type
                , i_perso_rec  => i_perso_rec
            );
            
            l_key_index := case
                when i_key_type = sec_api_const_pkg.SECURITY_DES_KEY_PVK then i_perso_method.pvk_index
                else 1
            end;

            -- find in cache
            if g_des_keys.exists(i_hsm_device_id) then
                if g_des_keys(i_hsm_device_id).exists(l_key_index) then
                    if g_des_keys(i_hsm_device_id)(l_key_index).exists(i_key_type) then
                        if g_des_keys(i_hsm_device_id)(l_key_index)(i_key_type).exists(l_entity_type) then
                            if g_des_keys(i_hsm_device_id)(l_key_index)(i_key_type)(l_entity_type).exists(l_object_id) then
                                trc_log_pkg.debug (
                                    i_text          => 'Keys [#1][#2] for hsm device[#3] entity type[#4] object id [#5] found in cache'
                                    , i_env_param1  => i_key_type
                                    , i_env_param2  => l_key_index
                                    , i_env_param3  => i_hsm_device_id
                                    , i_env_param4  => l_entity_type
                                    , i_env_param5  => l_object_id
                                );
                            
                                return g_des_keys(i_hsm_device_id)(l_key_index)(i_key_type)(l_entity_type)(l_object_id);
                            end if;
                        end if;
                    end if;
                end if;
            end if;
            
            -- get des key
            l_des_key := sec_api_des_key_pkg.get_key (
                i_object_id        => l_object_id
                , i_entity_type    => l_entity_type
                , i_hsm_device_id  => i_hsm_device_id
                , i_key_type       => i_key_type
                , i_key_index      => l_key_index
            );
            
            -- set cache
            g_des_keys(i_hsm_device_id)(l_key_index)(i_key_type)(l_entity_type)(l_object_id) := l_des_key;
            
            return l_des_key;
        end;
        
        function get_rsa_key return prs_api_type_pkg.t_rsa_key_rec
        is
            l_rsa_key                   prs_api_type_pkg.t_rsa_key_rec;
        begin
            -- find in cache
            if g_rsa_keys.exists(i_perso_rec.bin_id) then
                return g_rsa_keys(i_perso_rec.bin_id);
            end if;
            
            for key in (
                select
                    c.certified_key_id
                    , c.authority_key_id
                from
                    sec_rsa_key k
                    , sec_rsa_certificate c
                where
                    k.entity_type = iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
                    and k.object_id = i_perso_rec.bin_id
                    and c.certified_key_id = k.id
                    and c.certified_key_id != c.authority_key_id
            ) loop
                l_rsa_key.issuer_key.id := key.certified_key_id;
                l_rsa_key.authority_key.id := key.authority_key_id;
            end loop;
            
            -- issuer pk certificate
            l_rsa_key.issuer_certificate := sec_api_rsa_certificate_pkg.get_certificate (
                i_authority_key_id    => l_rsa_key.authority_key.id
                , i_certified_key_id  => l_rsa_key.issuer_key.id
            );

            -- issuer rsa key
            l_rsa_key.issuer_key := sec_api_rsa_key_pkg.get_rsa_key (
                i_id  => l_rsa_key.issuer_key.id
            );
            -- ca rsa key
            l_rsa_key.authority_key := sec_api_rsa_key_pkg.get_rsa_key (
                i_id             => l_rsa_key.authority_key.id
            );

            -- verification of certificates
            sec_api_rsa_certificate_pkg.validate_iss_certificate (
                i_issuer_key        => l_rsa_key.issuer_key
                , io_authority_key  => l_rsa_key.authority_key
                , i_issuer_cert     => l_rsa_key.issuer_certificate
                , i_hsm_device_id   => i_hsm_device_id
            );
            
            -- set cache
            g_rsa_keys(i_perso_rec.bin_id) := l_rsa_key;

            return l_rsa_key;
        end;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting personalization keys [#1][#2]'
            , i_env_param1  => i_perso_method.key_schema_id
            , i_env_param2  => i_hsm_device_id
        );
        
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if i_perso_method.pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_PVV, prs_api_const_pkg.PIN_VERIFIC_METHOD_IBM_3624, prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED) then
            -- pin verification key
            l_perso_key_rec.des_key.pvk := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_PVK
            );
        end if;
        if i_perso_method.pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED) then
            -- IBM pin offset key
            l_perso_key_rec.des_key.pibk := get_des_key (

                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_PIBK
            );
        end if;
          
        
        -- card verification key
        if i_perso_method.cvv_required = com_api_type_pkg.TRUE or i_perso_method.icvv_required = com_api_type_pkg.TRUE then
            l_perso_key_rec.des_key.cvk := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_CVK
            );
            if i_perso_method.cvv_required = com_api_type_pkg.TRUE then
                l_perso_key_rec.des_key.cvk2 := get_des_key (
                    i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_CVK2
                );
            end if;
        end if;

        if l_hsm_device.manufacturer = hsm_api_const_pkg.HSM_MANUFACTURER_SAFENET then
            l_perso_key_rec.des_key.ppk := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_PPK
            );
        end if;

        if i_perso_rec.emv_appl_scheme_id is not null then
            -- kek
            l_perso_key_rec.des_key.kek := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_KEK
            );
            -- pek for pin translation
            l_perso_key_rec.des_key.pek_translation := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_PEKT
            );
            -- imk ac
            l_perso_key_rec.des_key.imk_ac := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_IMK_AC
            );
            -- imk dac
            l_perso_key_rec.des_key.imk_dac := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_IMK_DAC
            );
            -- imk idn
            l_perso_key_rec.des_key.imk_idn := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_IMK_IDN
            );
            -- imk smc
            l_perso_key_rec.des_key.imk_smc := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_IMK_SMC
            );
            -- imk smi
            l_perso_key_rec.des_key.imk_smi := get_des_key (
                i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_IMK_SMI
            );
            if i_perso_method.is_contactless = com_api_type_pkg.TRUE then -- is contactless
                -- imk cvc3
                l_perso_key_rec.des_key.imk_cvc3 := get_des_key (
                    i_key_type  => sec_api_const_pkg.SECURITY_DES_KEY_IMK_CVC3
                );
            end if;
        
            -- rsa keys and certificate
            l_perso_key_rec.rsa_key := get_rsa_key;
        end if;
    
        return l_perso_key_rec;
    end;
    
end; 
/
