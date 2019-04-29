create or replace package body prs_api_template_pkg is
/************************************************************
 * API for personalization template <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.10.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_template_pkg <br />
 * @headcom
 ************************************************************/

    procedure set_mod_params (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , o_param_tab           out com_api_type_pkg.t_param_tab
    ) is
    begin
        o_param_tab.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'PERSO_PRIORITY'
            , i_value    => i_perso_rec.perso_priority
            , io_params  => o_param_tab
        );
    end;
    
    procedure set_template_param (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_card_id             in com_api_type_pkg.t_medium_id
        , i_card_number         in com_api_type_pkg.t_card_number
        , i_rows_number         in pls_integer -- number record in batch
        , i_record_number       in pls_integer -- number of the embossing record within the file
        , i_seq_number          in com_api_type_pkg.t_tiny_id
        , i_cvv                 in com_api_type_pkg.t_module_code
        , i_cvv2                in com_api_type_pkg.t_module_code
        , i_icvv                in com_api_type_pkg.t_module_code
        , i_pvv                 in com_api_type_pkg.t_tiny_id
        , i_pvk_index           in com_api_type_pkg.t_tiny_id
        , i_pin_block           in com_api_type_pkg.t_pin_block
        , i_service_code        in com_api_type_pkg.t_module_code
        , i_track1              in prs_api_type_pkg.t_track1
        , i_track2              in prs_api_type_pkg.t_track2
        , i_track3              in com_api_type_pkg.t_name
        , i_iss_date            in date
        , i_expir_date          in date
        , i_cardholder_name     in com_api_type_pkg.t_short_desc
        , i_company_name        in com_api_type_pkg.t_short_desc
        , i_person_id           in com_api_type_pkg.t_medium_id
        , i_first_name          in com_api_type_pkg.t_name
        , i_second_name         in com_api_type_pkg.t_name
        , i_surname             in com_api_type_pkg.t_name
        , i_suffix              in com_api_type_pkg.t_dict_value
        , i_gender              in com_api_type_pkg.t_dict_value
        , i_birthday            in date
        , i_street              in com_api_type_pkg.t_double_name
        , i_house               in com_api_type_pkg.t_double_name
        , i_apartment           in com_api_type_pkg.t_double_name
        , i_postal_code         in com_api_type_pkg.t_name
        , i_city                in com_api_type_pkg.t_double_name
        , i_country             in com_api_type_pkg.t_country_code
        , i_country_name        in com_api_type_pkg.t_name
        , i_region_code         in com_api_type_pkg.t_dict_value
        , i_tr1_discr_data      in prs_api_type_pkg.t_track1_discr_data
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_inst_name           in com_api_type_pkg.t_name
        , i_agent_id            in com_api_type_pkg.t_agent_id
        , i_agent_name          in com_api_type_pkg.t_name
        , i_card_type_name      in com_api_type_pkg.t_name
        , i_id_type             in com_api_type_pkg.t_name
        , i_id_series           in com_api_type_pkg.t_name
        , i_id_number           in com_api_type_pkg.t_name
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_card_account        in com_api_type_pkg.t_account_number
        , i_customer_id         in com_api_type_pkg.t_medium_id
        , i_cardholder_id       in com_api_type_pkg.t_long_id
        , o_param_tab           out nocopy com_api_type_pkg.t_param_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text  => 'Set template param values...'
        );

        -- parameters
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARD_ID
            , i_value    => i_card_id
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARD_NUMBER
            , i_value    => i_card_number
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_ROWS_NUMBER
            , i_value    => i_rows_number
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_RECORD_NUMBER
            , i_value    => i_record_number
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_SEQ_NUMBER
            , i_value    => i_seq_number
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CVV
            , i_value    => i_cvv
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CVV2
            , i_value    => i_cvv2
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_ICVV
            , i_value    => i_icvv
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_PVV
            , i_value    => to_char(i_pvv)
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_PVK_INDEX
            , i_value    => to_char(i_pvk_index)
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_PIN_OFFSET
            , i_value    => i_pvv
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_PIN_BLOCK
            , i_value    => i_pin_block
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_SERVICE_CODE
            , i_value    => i_service_code
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK1
            , i_value    => i_track1
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK2
            , i_value    => i_track2
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK3
            , i_value    => i_track3
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_ISS_DATE
            , i_value    => i_iss_date
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_EXPIR_DATE
            , i_value    => i_expir_date
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARDHOLDER_NAME
            , i_value    => i_cardholder_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_COMPANY_NAME
            , i_value    => i_company_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_PERSON_ID
            , i_value    => i_person_id
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_FIRST_NAME
            , i_value    => i_first_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_SECOND_NAME
            , i_value    => i_second_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_SURNAME
            , i_value    => i_surname
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_SUFFIX
            , i_value    => i_suffix
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_GENDER
            , i_value    => i_gender
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_BIRTHDAY
            , i_value    => i_birthday
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_SYS_DATE
            , i_value    => get_sysdate
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_STREET
            , i_value    => i_street
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_HOUSE
            , i_value    => i_house
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_APARTMENT
            , i_value    => i_apartment
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_POSTAL_CODE
            , i_value    => i_postal_code
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CITY
            , i_value    => i_city
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_COUNTRY
            , i_value    => i_country
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_COUNTRY_NAME
            , i_value    => i_country_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_REGION_CODE
            , i_value    => i_region_code
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_DISCRETIONARY_DATA
            , i_value    => i_tr1_discr_data
            , io_params  => o_param_tab
        );
        /*rul_api_param_pkg.set_param (
            i_name      => prs_api_const_pkg.PARAM_CONVERT_NUMBER
            , i_value   => opr_operation_seq.currval;
            , io_params => o_param_tab
        );*/
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK1_BEGIN
            , i_value    => ''--%B
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK1_END
            , i_value    => ''--?
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK1_SEPARATOR
            , i_value    => ''--^
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK2_BEGIN
            , i_value    => ''--;
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK2_END
            , i_value    => ''--?
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK2_SEPARATOR
            , i_value    => ''--=
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK3_BEGIN
            , i_value    => ''--;
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK3_END
            , i_value    => ''--?
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_TRACK3_SEPARATOR
            , i_value    => ''--=
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_ATC_PLACEHOLDER
            , i_value    => ''
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CVC3_PLACEHOLDER
            , i_value    => ''
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_UN_PLACEHOLDER
            , i_value    => ''
            , io_params  => o_param_tab
        );
        
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_INST_ID
            , i_value    => i_inst_id
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_INST_NAME
            , i_value    => i_inst_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_AGENT_ID
            , i_value    => i_agent_id
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_AGENT_NAME
            , i_value    => i_agent_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARD_TYPE_NAME
            , i_value    => i_card_type_name
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_ID_TYPE
            , i_value    => i_id_type
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_ID_NUMBER
            , i_value    => i_id_series || ' ' || i_id_number
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARD_LABEL
            , i_value    => get_label_text('CARD_LABEL', i_lang)
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARD_ACCOUNT
            , i_value    => i_card_account
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CUSTOMER_ID
            , i_value    => i_customer_id
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARDHOLDER_ID
            , i_value    => i_cardholder_id
            , io_params  => o_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_END_OF_RECORD
            , i_value    => 'chr(13) || chr(10)'
            , io_params  => o_param_tab
        );

        trc_log_pkg.debug (
            i_text  => 'Set template param values - ok'
        );
    end;
    
    procedure set_template_param (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_record_number       in pls_integer
        , o_param_tab           out nocopy com_api_type_pkg.t_param_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text  => 'Set template param...'
        );
        
        set_template_param (
            i_format_id          => i_format_id
            , i_card_id          => i_perso_rec.card_id
            , i_card_number      => i_perso_rec.card_number
            , i_rows_number      => i_perso_rec.rows_number
            , i_record_number    => i_record_number
            , i_seq_number       => i_perso_rec.seq_number
            , i_cvv              => i_perso_data.cvv
            , i_cvv2             => i_perso_data.cvv2
            , i_icvv             => i_perso_data.icvv
            , i_pvv              => i_perso_rec.pvv
            , i_pvk_index        => i_perso_method.pvk_index
            , i_pin_block        => i_perso_rec.pin_block
            , i_service_code     => i_perso_method.service_code
            , i_track1           => i_perso_data.track1
            , i_track2           => i_perso_data.track2
            , i_track3           => i_perso_data.track3
            , i_iss_date         => i_perso_rec.iss_date
            , i_expir_date       => i_perso_rec.expir_date
            , i_cardholder_name  => i_perso_rec.cardholder_name
            , i_company_name     => i_perso_rec.company_name
            , i_person_id        => i_perso_rec.person_id
            , i_first_name       => i_perso_rec.first_name
            , i_second_name      => i_perso_rec.second_name
            , i_surname          => i_perso_rec.surname
            , i_suffix           => i_perso_rec.suffix
            , i_gender           => i_perso_rec.gender
            , i_birthday         => i_perso_rec.birthday
            , i_street           => i_perso_rec.street
            , i_house            => i_perso_rec.house
            , i_apartment        => i_perso_rec.apartment
            , i_postal_code      => i_perso_rec.postal_code
            , i_city             => i_perso_rec.city
            , i_country          => i_perso_rec.country
            , i_country_name     => i_perso_rec.country_name
            , i_region_code      => i_perso_rec.region_code
            , i_tr1_discr_data   => i_perso_data.tr1_discr_data
            , i_inst_id          => i_perso_rec.inst_id
            , i_inst_name        => i_perso_rec.inst_name
            , i_agent_id         => i_perso_rec.agent_id
            , i_agent_name       => i_perso_rec.agent_name
            , i_card_type_name   => i_perso_rec.card_type_name
            , i_id_type          => i_perso_rec.id_type
            , i_id_series        => i_perso_rec.id_series
            , i_id_number        => i_perso_rec.id_number
            , i_lang             => i_perso_rec.lang
            , i_card_account     => i_perso_rec.card_account
            , i_customer_id      => i_perso_rec.customer_id
            , i_cardholder_id    => i_perso_rec.cardholder_id
            , o_param_tab        => o_param_tab
        );
        
        trc_log_pkg.debug (
            i_text  => 'Set template param - ok'
        );
    end;

    procedure get_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
        l_record_number         pls_integer;
        l_param_tab             com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get template values...'
        );

        l_record_number := prs_api_file_pkg.get_record_number (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => prs_api_const_pkg.FILE_TYPE_EMBOSSING
        );

        set_template_param (
            i_format_id        => i_format_id
            , i_perso_rec      => i_perso_rec
            , i_perso_method   => i_perso_method
            , i_perso_data     => i_perso_data
            , i_entity_type    => i_entity_type
            , i_record_number  => l_record_number
            , o_param_tab      => l_param_tab
        );
        
        -- get params array
        o_params := rul_api_name_pkg.get_params_name (
            i_format_id    => i_format_id
            , i_param_tab  => l_param_tab
        );

        trc_log_pkg.debug (
            i_text  => 'Get template values - ok'
        );
    end;

    procedure get_emv_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
        l_params                com_api_type_pkg.t_param_tab;
        l_tak                   sec_api_type_pkg.t_des_key_rec;
        l_cvc3_tak              sec_api_type_pkg.t_des_key_rec;
        l_record_number         binary_integer;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get emv template values...'
        );

        -- generate icc 3des keys
        prs_api_command_pkg.derive_icc_3des_keys (
            i_perso_rec        => i_perso_rec
            , i_perso_method   => i_perso_method
            , i_perso_key      => io_perso_data.perso_key
            , i_hsm_device_id  => io_perso_data.hsm_device_id
            , o_result         => io_perso_data.icc_derived_keys
        );

        -- format translate pin block
        prs_api_command_pkg.translate_pinblock (
            i_perso_rec          => i_perso_rec
            , i_perso_key        => io_perso_data.perso_key
            , i_hsm_device_id    => io_perso_data.hsm_device_id
            , i_pinblock_format  => prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
            , o_pin_block        => io_perso_data.tr_pin_block
        );

        if i_perso_method.is_contactless = com_api_type_pkg.TRUE
           and i_perso_rec.emv_scheme_type = emv_api_const_pkg.EMV_SCHEME_MC then
            -- import icc cvc3 under lmk
            prs_api_command_pkg.import_key_under_kek (
                i_hsm_device_id  => io_perso_data.hsm_device_id
                , i_kek          => io_perso_data.perso_key.des_key.kek
                , i_user_key     => io_perso_data.icc_derived_keys.idk_cvc3
                , o_new_key      => l_tak
            );

            -- translate icc cvc3 in scheme u
            prs_api_command_pkg.translate_key_scheme (
                i_hsm_device_id  => io_perso_data.hsm_device_id
                , i_key          => l_tak
                , o_new_key      => l_cvc3_tak
            );
            if substr( io_perso_data.icc_derived_keys.idk_cvc3.check_value, 1, 6 ) != l_cvc3_tak.check_value then
                com_api_error_pkg.raise_error (
                    i_error         => 'ICC_DERIVED_CVC3_KCV_MISMATCH'
                    , i_env_param1  => io_perso_data.icc_derived_keys.idk_cvc3.check_value
                    , i_env_param2  => l_cvc3_tak.check_value
                );
            end if;

            -- ivcvc3 track1, ivcvc3 track2
            prs_api_command_pkg.generate_mac (
                i_hsm_device_id      => io_perso_data.hsm_device_id
                , i_key              => l_cvc3_tak
                , i_message_data     => io_perso_data.track1_contactless
                , i_convert_message  => com_api_type_pkg.TRUE
                , o_mac              => io_perso_data.track1_ivcvc3
            );
            io_perso_data.track1_ivcvc3 := substr(io_perso_data.track1_ivcvc3, -4);

            prs_api_command_pkg.generate_mac (
                i_hsm_device_id      => io_perso_data.hsm_device_id
                , i_key              => l_cvc3_tak
                , i_message_data     => io_perso_data.track2_contactless
                , i_convert_message  => com_api_type_pkg.FALSE
                , o_mac              => io_perso_data.track2_ivcvc3
            );
            io_perso_data.track2_ivcvc3 := substr(io_perso_data.track2_ivcvc3, -4);
        end if;

        -- parameters
        set_mod_params (
            i_perso_rec    => i_perso_rec
            , o_param_tab  => l_params
        );
        emv_api_application_pkg.process_application (
            i_appl_scheme_id  => i_perso_rec.emv_appl_scheme_id
            , i_perso_rec     => i_perso_rec
            , i_perso_method  => i_perso_method
            , io_perso_data   => io_perso_data
            , io_appl_data    => io_perso_data.appl_data
            , i_params        => l_params
        );

        if i_perso_rec.icc_instance_id is null then
            l_record_number := prs_api_file_pkg.get_record_number (
                i_perso_rec      => i_perso_rec
                , i_format_id    => i_format_id
                , i_entity_type  => prs_api_const_pkg.ENTITY_TYPE_CHIP
                , i_file_type    => prs_api_const_pkg.FILE_TYPE_EMBOSSING
            );
            -- parameters
            l_params.delete;
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_ROWS_NUMBER
                , i_value    => i_perso_rec.rows_number
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_RECORD_NUMBER
                , i_value    => l_record_number
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_EMBOSSING_DATA
                , i_value    => 'EMBOSSING_DATA'
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_TRACK1_DATA
                , i_value    => io_perso_data.track1
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_TRACK2_DATA
                , i_value    => io_perso_data.track2
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_CHIP_DATA
                , i_value    => 'CHIP_DATA'
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_END_OF_RECORD
                , i_value    => 'chr(13) || chr(10)'
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_CARD_ID
                , i_value    => i_perso_rec.card_id
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_SEQ_NUMBER
                , i_value    => i_perso_rec.seq_number
                , io_params  => l_params
            );

            -- get params array
            o_params := rul_api_name_pkg.get_params_name (
                i_format_id    => i_format_id
                , i_param_tab  => l_params
            );
        else
            trc_log_pkg.debug (
                i_text  => 'Doesn''t request for parent icc card instance'
            );

        end if;

        trc_log_pkg.debug (
            i_text  => 'Get emv template values - ok'
        );
    end;
    
    procedure get_p3_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
        l_params                com_api_type_pkg.t_param_tab;
        l_record_number         binary_integer;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get p3 template values...'
        );

        -- generate icc 3des keys
        prs_api_command_pkg.derive_icc_3des_keys (
            i_perso_rec        => i_perso_rec
            , i_perso_method   => i_perso_method
            , i_perso_key      => io_perso_data.perso_key
            , i_hsm_device_id  => io_perso_data.hsm_device_id
            , o_result         => io_perso_data.icc_derived_keys
        );

        -- format translate pin block
        prs_api_command_pkg.translate_pinblock (
            i_perso_rec          => i_perso_rec
            , i_perso_key        => io_perso_data.perso_key
            , i_hsm_device_id    => io_perso_data.hsm_device_id
            , i_pinblock_format  => prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
            , o_pin_block        => io_perso_data.tr_pin_block
        );

        emv_api_application_pkg.process_p3_application (
            i_appl_scheme_id  => i_perso_rec.emv_appl_scheme_id
            , i_perso_rec     => i_perso_rec
            , i_perso_method  => i_perso_method
            , io_perso_data   => io_perso_data
            , io_appl_data    => io_perso_data.appl_data
        );

        if i_perso_rec.icc_instance_id is null then
            l_record_number := prs_api_file_pkg.get_record_number (
                i_perso_rec      => i_perso_rec
                , i_format_id    => i_format_id
                , i_entity_type  => prs_api_const_pkg.ENTITY_TYPE_P3CHIP
                , i_file_type    => prs_api_const_pkg.FILE_TYPE_EMBOSSING
            );
            -- parameters
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_ROWS_NUMBER
                , i_value    => i_perso_rec.rows_number
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_RECORD_NUMBER
                , i_value    => l_record_number
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_EMBOSSING_DATA
                , i_value    => 'EMBOSSING_DATA'
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_TRACK1_DATA
                , i_value    => io_perso_data.track1
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_TRACK2_DATA
                , i_value    => io_perso_data.track2
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_P3CHIP_DATA
                , i_value    => 'P3CHIP_DATA'
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_END_OF_RECORD
                , i_value    => 'chr(13) || chr(10)'
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_CARD_ID
                , i_value    => i_perso_rec.card_id
                , io_params  => l_params
            );
            rul_api_param_pkg.set_param (
                i_name       => prs_api_const_pkg.PARAM_SEQ_NUMBER
                , i_value    => i_perso_rec.seq_number
                , io_params  => l_params
            );

            -- get params array
            o_params := rul_api_name_pkg.get_params_name (
                i_format_id    => i_format_id
                , i_param_tab  => l_params
            );
        else
            trc_log_pkg.debug (
                i_text  => 'Doesn''t request for parent icc card instance'
            );

        end if;

        trc_log_pkg.debug (
            i_text  => 'Get emv template values - ok'
        );
    end;

    procedure set_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
        l_param_tab             com_api_type_pkg.t_param_tab;
    begin
        set_template_param (
            i_format_id          => i_format_id
            , i_card_id          => 0
            , i_card_number      => ''
            , i_rows_number      => 0
            , i_record_number    => 0
            , i_seq_number       => 0
            , i_cvv              => '000'
            , i_cvv2             => '000'
            , i_icvv             => '000'
            , i_pvv              => 9999
            , i_pvk_index        => 0
            , i_pin_block        => ''
            , i_service_code     => '000'
            , i_track1           => ''
            , i_track2           => ''
            , i_track3           => ''
            , i_iss_date         => get_sysdate
            , i_expir_date       => get_sysdate
            , i_cardholder_name  => ''
            , i_company_name     => ''
            , i_person_id        => null
            , i_first_name       => ''
            , i_second_name      => ''
            , i_surname          => ''
            , i_suffix           => ''
            , i_gender           => ''
            , i_birthday         => get_sysdate
            , i_street           => ''
            , i_house            => ''
            , i_apartment        => ''
            , i_postal_code      => ''
            , i_city             => ''
            , i_country          => ''
            , i_country_name     => ''
            , i_region_code      => ''
            , i_tr1_discr_data   => ''
            , i_inst_id          => 0
            , i_inst_name        => ''
            , i_agent_id         => 0
            , i_agent_name       => ''
            , i_card_type_name   => ''
            , i_id_type          => ''
            , i_id_series        => ''
            , i_id_number        => ''
            , i_lang             => com_api_const_pkg.LANGUAGE_ENGLISH
            , i_card_account     => ''
            , i_customer_id      => null
            , i_cardholder_id    => null
            , o_param_tab        => l_param_tab
        );
        
        -- get params array
        o_params := rul_api_name_pkg.get_params_name (
            i_format_id    => i_format_id
            , i_param_tab  => l_param_tab
        );
    end;

    procedure format_track_contact (
        i_track_type            in com_api_type_pkg.t_dict_value
        , io_params             in out nocopy rul_api_type_pkg.t_param_tab
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
    ) is
        l_raw_data                com_api_type_pkg.t_raw_data;
        l_raw_data_icc            com_api_type_pkg.t_raw_data;
        l_discr_data              com_api_type_pkg.t_param_value;
        l_discr_data_icc          com_api_type_pkg.t_param_value;
        l_service_code_exist      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
        l_cvc3_placeholder_exist  com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

        l_value_icc               com_api_type_pkg.t_param_value;
        l_track_end               com_api_type_pkg.t_name;

        function check_length (
            i_parameter            in com_api_type_pkg.t_name
            , i_data               in com_api_type_pkg.t_raw_data
            , i_length             in com_api_type_pkg.t_tiny_id
        ) return com_api_type_pkg.t_raw_data is
        begin
            trc_log_pkg.debug (
                i_text          => 'Check length in format_track [#1][#2][#3]'
                , i_env_param1  => i_parameter
                , i_env_param2  => com_api_hash_pkg.get_param_mask(i_data)
                , i_env_param3  => i_length
            );
            if length(i_data) > i_length then
                -- The track length is too long
                com_api_error_pkg.raise_error(
                    i_error         => 'VALUE_IS_TOO_LONG'
                    , i_env_param1  => i_parameter
                    , i_env_param2  => i_length
                );
            end if;
            return i_data;
        end;
    begin
        trc_log_pkg.debug (
            i_text          => 'Format contact track #1 data...'
            , i_env_param1  => case i_track_type when prs_api_const_pkg.ENTITY_TYPE_TRACK1 then '1' when prs_api_const_pkg.ENTITY_TYPE_TRACK2 then '2' else '3' end
        );

        io_perso_data.atc_exist := com_api_const_pkg.FALSE;
        l_raw_data := '';
        l_raw_data_icc := '';
        l_track_end := case i_track_type
        when prs_api_const_pkg.ENTITY_TYPE_TRACK1 then
            prs_api_const_pkg.PARAM_TRACK1_END
        when prs_api_const_pkg.ENTITY_TYPE_TRACK2 then
            prs_api_const_pkg.PARAM_TRACK2_END
        else
            prs_api_const_pkg.PARAM_TRACK3_END
        end;

        for i in 1 .. io_params.count loop
            case io_params(i).param_name
                when prs_api_const_pkg.PARAM_CVC3_PLACEHOLDER then
                    if i_track_type = prs_api_const_pkg.ENTITY_TYPE_TRACK2 then
                        io_perso_data.dcvv_track2_pos := nvl(length(l_value_icc), 0) + 1;
                        l_cvc3_placeholder_exist := com_api_const_pkg.TRUE;
                    end if;
                    
                when prs_api_const_pkg.PARAM_ATC_PLACEHOLDER then
                    if i_track_type = prs_api_const_pkg.ENTITY_TYPE_TRACK2 then
                        io_perso_data.atc_exist := com_api_const_pkg.TRUE;
                    end if;
                    
                when prs_api_const_pkg.PARAM_CVV then
                    l_value_icc := io_params(i).param_value;
                    if io_perso_data.icvv is not null then
                        l_value_icc := replace( io_params(i).param_value, io_perso_data.cvv, io_perso_data.icvv );
                    end if;

                    if l_cvc3_placeholder_exist = com_api_type_pkg.FALSE and i_track_type = prs_api_const_pkg.ENTITY_TYPE_TRACK2 then
                        io_perso_data.dcvv_track2_pos := nvl(length(l_value_icc), 0) + 1;
                    end if;

                when prs_api_const_pkg.PARAM_TRACK2_BEGIN then
                    l_value_icc := '';

                when prs_api_const_pkg.PARAM_TRACK2_END then
                    l_value_icc := '';

                when prs_api_const_pkg.PARAM_TRACK2_SEPARATOR then
                    l_value_icc := 'D';
                else
                    if io_params(i).param_name = prs_api_const_pkg.PARAM_CARDHOLDER_NAME then
                        io_params(i).param_value := substr(io_params(i).param_value, 1, prs_api_const_pkg.NAME_TRACK1_MAX_LEN);
                        if i_track_type = prs_api_const_pkg.ENTITY_TYPE_TRACK1 then
                            io_perso_data.name_on_track1 := io_params(i).param_value;
                        end if;
                    end if;

                    l_value_icc := io_params(i).param_value;
            end case;

            l_raw_data := l_raw_data || io_params(i).param_value;
            l_raw_data_icc := l_raw_data_icc || l_value_icc;

            if l_service_code_exist = com_api_type_pkg.TRUE then
                if io_params(i).param_name <> l_track_end then
                    begin
                        l_discr_data := l_discr_data || io_params(i).param_value;
                        l_discr_data_icc := l_discr_data_icc || l_value_icc;
                    exception when others then
                        null;
                    end;
                end if;
            elsif io_params(i).param_name = prs_api_const_pkg.PARAM_SERVICE_CODE then
                l_service_code_exist := com_api_type_pkg.TRUE;
            end if;
        end loop;

        -- set track and discretionary data
        case i_track_type
        when prs_api_const_pkg.ENTITY_TYPE_TRACK1 then
            io_perso_data.track1 := check_length (
                i_parameter  => 'TRACK 1'
                , i_data     => l_raw_data
                , i_length   => 79
            );
            io_perso_data.tr1_discr_data := check_length (
                i_parameter  => 'Discretionary data on TRACK 1'
                , i_data     => l_discr_data
                , i_length   => 24
            );
            io_perso_data.tr1_discr_data_icc := check_length (
                i_parameter  => 'Discretionary data ICC on TRACK 1'
                , i_data     => l_discr_data_icc
                , i_length   => 24
            );
        when prs_api_const_pkg.ENTITY_TYPE_TRACK2 then
            io_perso_data.track2 := check_length (
                i_parameter  => 'TRACK 2'
                , i_data     => l_raw_data
                , i_length   => 40
            );
            io_perso_data.track2_icc := check_length (
                i_parameter  => 'ICC TRACK 2'
                , i_data     => l_raw_data_icc
                , i_length   => 40
            );
            io_perso_data.tr2_discr_data := check_length (
                i_parameter  => 'Discretionary data on TRACK 2'
                , i_data     => l_discr_data
                , i_length   => 17
            );
            io_perso_data.tr2_discr_data_icc := check_length (
                i_parameter  => 'Discretionary data ICC on TRACK 2'
                , i_data     => l_discr_data_icc
                , i_length   => 17
            );
        else
            io_perso_data.track3 := l_raw_data;
        end case;

        trc_log_pkg.debug (
            i_text          => 'Format contact track #1 data - ok'
            , i_env_param1  => case i_track_type when prs_api_const_pkg.ENTITY_TYPE_TRACK1 then '1' when prs_api_const_pkg.ENTITY_TYPE_TRACK2 then '2' else '3' end
        );
    end;

    procedure format_track_contactless (
        i_track_type            in com_api_type_pkg.t_dict_value
        , i_params              in rul_api_type_pkg.t_param_tab
        , o_track_contactless   out com_api_type_pkg.t_raw_data
        , o_bitmask_pcvc3       out com_api_type_pkg.t_name
        , o_bitmask_punatc      out com_api_type_pkg.t_name
        , o_natc                out com_api_type_pkg.t_tiny_id
    ) is
        l_service_code_exist      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
        l_atc_ph_length           com_api_type_pkg.t_tiny_id;
        l_binmask_cvc3            com_api_type_pkg.t_name;
        l_binmask_punatc          com_api_type_pkg.t_name;

        function check_length (
            i_parameter            in com_api_type_pkg.t_name
            , i_data               in com_api_type_pkg.t_raw_data
            , i_length             in com_api_type_pkg.t_tiny_id
        ) return com_api_type_pkg.t_raw_data is
        begin
            trc_log_pkg.debug (
                i_text          => 'Check length in format_track [#1][#2][#3]'
                , i_env_param1  => i_parameter
                , i_env_param2  => com_api_hash_pkg.get_param_mask(i_data)
                , i_env_param3  => i_length
            );
            if length(i_data) > i_length then
                -- The track length is too long
                com_api_error_pkg.raise_error(
                    i_error         => 'VALUE_IS_TOO_LONG'
                    , i_env_param1  => i_parameter
                    , i_env_param2  => i_length
                );
            end if;
            return i_data;
        end;
    begin
        trc_log_pkg.debug (
            i_text          => 'Format contactless track #1 data...'
            , i_env_param1  => case when i_track_type = prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK1 then '1' else '2' end
        );

        l_binmask_cvc3 := '';
        l_binmask_punatc := '';

        o_track_contactless := '';

        for i in 1 .. i_params.count loop
            case i_params(i).param_name
                when prs_api_const_pkg.PARAM_ATC_PLACEHOLDER then
                    l_atc_ph_length := nvl(length(i_params(i).param_value), 0);
            else
                null;
            end case;

            o_track_contactless := o_track_contactless || i_params(i).param_value;

            if l_service_code_exist = com_api_type_pkg.TRUE then
                case i_params(i).param_name
                    when prs_api_const_pkg.PARAM_ATC_PLACEHOLDER then
                      l_binmask_punatc := l_binmask_punatc
                                       || rpad('1', nvl(length(i_params(i).param_value), 0), '1');
                      l_binmask_cvc3 := l_binmask_cvc3
                                     || rpad('0', nvl(length(i_params(i).param_value), 0), '0');

                    when prs_api_const_pkg.PARAM_CVC3_PLACEHOLDER then
                      l_binmask_cvc3 := l_binmask_cvc3
                                     || rpad('1', nvl(length(i_params(i).param_value), 0), '1');
                      l_binmask_punatc := l_binmask_punatc
                                       || rpad('0', nvl(length(i_params(i).param_value), 0), '0');


                    when prs_api_const_pkg.PARAM_UN_PLACEHOLDER then
                      l_binmask_punatc := l_binmask_punatc
                                       || rpad('1', nvl(length(i_params(i).param_value), 0), '1');

                      l_binmask_cvc3 := l_binmask_cvc3
                                     || rpad('0', nvl(length(i_params(i).param_value), 0), '0');
                else
                    l_binmask_cvc3 := l_binmask_cvc3
                                   || rpad('0', nvl(length(i_params(i).param_value), 0), '0');
                    l_binmask_punatc := l_binmask_punatc
                                     || rpad('0', nvl(length(i_params(i).param_value), 0), '0');
                end case;
            
            elsif i_params(i).param_name = prs_api_const_pkg.PARAM_SERVICE_CODE then
                l_service_code_exist := com_api_type_pkg.TRUE;
            end if;
        end loop;

        -- set track data
        if i_track_type = prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK1 then
            o_natc := l_atc_ph_length;
            o_bitmask_pcvc3 := rul_api_name_pkg.pad_byte_len (
                i_src       => prs_api_util_pkg.bin2hex2(lpad(nvl(l_binmask_cvc3, '0'), 48, '0'))
                , i_length  => 6
            );
            o_bitmask_punatc := rul_api_name_pkg.pad_byte_len (
                i_src       => prs_api_util_pkg.bin2hex2(lpad(nvl(l_binmask_punatc, '0'), 48, '0'))
                , i_length  => 6
            );

        else
            o_natc := l_atc_ph_length;
            o_bitmask_pcvc3 := rul_api_name_pkg.pad_byte_len (
                i_src       => prs_api_util_pkg.bin2hex2(lpad(nvl(l_binmask_cvc3, '0'), 16, '0'))
                , i_length  => 2
            );
            o_bitmask_punatc := rul_api_name_pkg.pad_byte_len (
                i_src       => prs_api_util_pkg.bin2hex2(lpad(nvl(l_binmask_punatc, '0'), 16, '0'))
                , i_length  => 2
            );
            if mod(nvl(length(o_track_contactless), 0), 2) = 1 then
               o_track_contactless := o_track_contactless || 'F';
            end if;
        end if;

        trc_log_pkg.debug (
            i_text          => 'Format contactless track #1 data - ok'
            , i_env_param1  => case when i_track_type = prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK1 then '1' else '2' end
        );
    end;

    procedure parse_discr_data (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_discr_data          in com_api_type_pkg.t_name
        , o_pvv                 out com_api_type_pkg.t_name
        , o_pvk_index           out com_api_type_pkg.t_name
        , o_cvv                 out com_api_type_pkg.t_name
        , o_atc                 out com_api_type_pkg.t_name
    ) is
        l_params                rul_api_type_pkg.t_param_tab;
        l_service_code_exist    com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
        l_pos                   pls_integer := 1;
    begin
        trc_log_pkg.debug (
            i_text          => 'parse discretionary contact data [#1][#2]'
            , i_env_param1  => i_format_id
            , i_env_param2  => i_discr_data
        );

        set_template_values (
            i_format_id  => i_format_id
            , o_params   => l_params
        );
        
        for i in 1 .. l_params.count loop
            if l_service_code_exist = com_api_type_pkg.TRUE then
                case l_params(i).param_name
                    when prs_api_const_pkg.PARAM_ATC_PLACEHOLDER then
                        o_atc := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    when prs_api_const_pkg.PARAM_PVV then
                        o_pvv := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    when prs_api_const_pkg.PARAM_PVK_INDEX then
                        o_pvk_index := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    when prs_api_const_pkg.PARAM_CVV then
                        o_cvv := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    else
                        null;
                end case;

                l_pos := l_pos + nvl(length(l_params(i).param_value), 0);
            elsif l_params(i).param_name = prs_api_const_pkg.PARAM_SERVICE_CODE then
                l_service_code_exist := com_api_type_pkg.TRUE;
            end if;
        end loop;
    end;
    
    procedure parse_discr_data (
        i_perso_method_id       in com_api_type_pkg.t_short_id
        , i_discr_data          in com_api_type_pkg.t_name
        , o_pvv                 out com_api_type_pkg.t_name
        , o_pvk_index           out com_api_type_pkg.t_name
        , o_cvv                 out com_api_type_pkg.t_name
        , o_atc                 out com_api_type_pkg.t_name
        , i_discr_type          in     com_api_type_pkg.t_short_id := null        
    ) is
        l_format_id             com_api_type_pkg.t_tiny_id;
    begin
        trc_log_pkg.debug (
            i_text          => 'parse discretionary contact data [#1][#2]'
            , i_env_param1  => i_perso_method_id
            , i_env_param2  => i_discr_data
        );

        -- get perso template
        begin
            select
                format_id
            into
                l_format_id
            from
                prs_template_vw
            where
                method_id = i_perso_method_id
                and entity_type = decode(i_discr_type, 1, prs_api_const_pkg.ENTITY_TYPE_TRACK1,prs_api_const_pkg.ENTITY_TYPE_TRACK2);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error             => 'ILLEGAL_PERSO_METHOD'
                    , i_env_param1      => i_perso_method_id
                );
        end;
        
        parse_discr_data (
            i_format_id     => l_format_id
            , i_discr_data  => i_discr_data
            , o_pvv         => o_pvv
            , o_pvk_index   => o_pvk_index
            , o_cvv         => o_cvv
            , o_atc         => o_atc
        );
    end;
    
    procedure parse_discr_contactless_data (
        i_perso_method_id       in com_api_type_pkg.t_short_id
        , i_discr_data          in com_api_type_pkg.t_name
        , i_track_type          in com_api_type_pkg.t_dict_value
        , o_bitmask_pcvc3       out com_api_type_pkg.t_name
        , o_bitmask_punatc      out com_api_type_pkg.t_name
        , o_natc                out com_api_type_pkg.t_tiny_id
    ) is
        l_format_id             com_api_type_pkg.t_tiny_id;
        l_params                rul_api_type_pkg.t_param_tab;
        l_track_contactless     com_api_type_pkg.t_raw_data;
    begin
        trc_log_pkg.debug (
            i_text          => 'parse discretionary contactless data [#1][#2][#3]'
            , i_env_param1  => i_perso_method_id
            , i_env_param2  => i_track_type
            , i_env_param3  => i_discr_data
        );

        -- get perso template
        begin
            select
                format_id
            into
                l_format_id
            from
                prs_template_vw
            where
                method_id = i_perso_method_id
                and entity_type = i_track_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error             => 'ILLEGAL_PERSO_METHOD'
                    , i_env_param1      => i_perso_method_id
                );
        end;
        
        set_template_values (
            i_format_id  => l_format_id
            , o_params   => l_params
        );
        
        format_track_contactless (
            i_track_type           => i_track_type
            , i_params             => l_params
            , o_track_contactless  => l_track_contactless
            , o_bitmask_pcvc3      => o_bitmask_pcvc3
            , o_bitmask_punatc     => o_bitmask_punatc
            , o_natc               => o_natc
        );
        
        trc_log_pkg.debug (
            i_text          => 'o_bitmask_pcvc3[#1] o_bitmask_punatc[#2] o_natc[#3]'
            , i_env_param1  => o_bitmask_pcvc3
            , i_env_param2  => o_bitmask_punatc
            , i_env_param3  => o_natc
        );
    end;
    
    procedure parse_discr_contactless_data (
        i_perso_method_id       in com_api_type_pkg.t_short_id
        , i_discr_data          in com_api_type_pkg.t_name
        , o_atc                 out com_api_type_pkg.t_name
        , o_un_placeholder      out com_api_type_pkg.t_name
        , o_cvc3                out com_api_type_pkg.t_name
        , o_pvv                 out com_api_type_pkg.t_name
        , o_pvk_index           out com_api_type_pkg.t_name
    ) is
        l_format_id             com_api_type_pkg.t_tiny_id;
        l_params                rul_api_type_pkg.t_param_tab;
        l_service_code_exist    com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
        l_pos                   pls_integer := 1;
    begin
        trc_log_pkg.debug (
            i_text          => 'parse discretionary contactless data [#1][#2]'
            , i_env_param1  => i_perso_method_id
            , i_env_param2  => i_discr_data
        );

        -- get perso template
        begin
            select
                format_id
            into
                l_format_id
            from
                prs_template_vw
            where
                method_id = i_perso_method_id
                and entity_type = prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK2;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error             => 'ILLEGAL_PERSO_METHOD'
                    , i_env_param1      => i_perso_method_id
                );
        end;
        
        set_template_values (
            i_format_id  => l_format_id
            , o_params   => l_params
        );
        
        for i in 1 .. l_params.count loop
            if l_service_code_exist = com_api_type_pkg.TRUE then
                case l_params(i).param_name
                    when prs_api_const_pkg.PARAM_ATC_PLACEHOLDER then
                        o_atc := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    when prs_api_const_pkg.PARAM_UN_PLACEHOLDER then
                        o_un_placeholder := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    when prs_api_const_pkg.PARAM_CVC3_PLACEHOLDER then
                        o_cvc3 := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    when prs_api_const_pkg.PARAM_PVV then
                        o_pvv := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    when prs_api_const_pkg.PARAM_PVK_INDEX then
                        o_pvk_index := substr(i_discr_data, l_pos, nvl(length(l_params(i).param_value), 0));
                    else
                        null;
                end case;

                l_pos := l_pos + nvl(length(l_params(i).param_value), 0);
            elsif l_params(i).param_name = prs_api_const_pkg.PARAM_SERVICE_CODE then
                l_service_code_exist := com_api_type_pkg.TRUE;
            end if;
        end loop;
    end;
    
    procedure format_embossing_record (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
    ) is
        l_file_data             raw(32767);
        l_chip_exists           com_api_type_pkg.t_tiny_id;
    begin
        trc_log_pkg.debug (
            i_text         => 'Format embossing record...'
        );
      
        for i in 1 .. i_params.count loop
            l_file_data := l_file_data || case i_params(i).param_name
                                          when prs_api_const_pkg.PARAM_END_OF_RECORD then
                                              utl_raw.cast_to_raw (
                                                  prs_api_util_pkg.convert_data (i_params(i).param_value, io_perso_data.charset)
                                              )
                                          else
                                              utl_raw.cast_to_raw (
                                                  prs_api_util_pkg.convert_data (i_params(i).param_value, io_perso_data.charset)
                                              )
                                          end;
            
            io_perso_data.embossing_data := io_perso_data.embossing_data
             || case i_params(i).param_name
                when prs_api_const_pkg.PARAM_END_OF_RECORD then
                    null
                else
                    utl_raw.cast_to_raw (
                        prs_api_util_pkg.convert_data (i_params(i).param_value, io_perso_data.charset)
                    )
                end;
        end loop;

        select
            count(id)
        into
            l_chip_exists
        from
            prs_template_vw
        where
            method_id = i_perso_rec.perso_method_id
            and entity_type in (prs_api_const_pkg.ENTITY_TYPE_CHIP, prs_api_const_pkg.ENTITY_TYPE_P3CHIP);

        if l_chip_exists = 0 then
            prs_api_file_pkg.put_records (
                i_raw_data         => l_file_data
                , i_perso_rec      => i_perso_rec
                , i_format_id      => i_format_id
                , i_entity_type    => prs_api_const_pkg.ENTITY_TYPE_EMBOSSING
                , i_file_type      => prs_api_const_pkg.FILE_TYPE_EMBOSSING
            );
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Format embossing record - ok'
        );
    end;
    
    procedure format_pin_mailer (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_pin_length          in com_api_type_pkg.t_tiny_id
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
    ) is
        l_print_data            prs_api_type_pkg.t_print_data_tab;
    begin
        trc_log_pkg.debug (
            i_text  => 'Format pin mailer data...'
        );
        -- format print data array
        l_print_data := prs_api_print_pkg.format_print_data (
            i_params        => i_params
            , i_pin_length  => i_pin_length
        );

        -- print pin mailer
        prs_api_print_pkg.print_pin_mailer (
            i_print_data       => l_print_data
            , i_card_number    => i_perso_rec.card_number
            , i_pin_block      => i_perso_rec.pin_block
            , i_hsm_device_id  => i_hsm_device_id
            , i_perso_key      => i_perso_key
        );
        
        trc_log_pkg.debug (
            i_text  => 'Format pin mailer data - ok'
        );
    end;

    procedure format_emv_chip_data (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) is
        l_raw_data              raw(32767);
        l_chip_data             raw(32767);
    begin
        trc_log_pkg.debug (
            i_text  => 'Format emv chip data...'
        );
        
        if i_perso_rec.icc_instance_id is null then
            emv_api_application_pkg.format_chip_data (
                i_card_number  => i_perso_rec.card_number
                , i_appl_data  => i_perso_data.appl_data
                , o_chip_data  => l_chip_data
            );
            
            for i in 1 .. i_params.count loop
                l_raw_data := l_raw_data || case i_params(i).param_name
                                            when prs_api_const_pkg.PARAM_CHIP_DATA then
                                                l_chip_data
                                            when prs_api_const_pkg.PARAM_EMBOSSING_DATA then
                                                i_perso_data.embossing_data
                                            else
                                                utl_raw.cast_to_raw (
                                                   prs_api_util_pkg.convert_data (i_params(i).param_value, i_perso_data.charset)
                                                )
                                            end;
            end loop;

            prs_api_file_pkg.put_records (
                i_raw_data         => l_raw_data
                , i_perso_rec      => i_perso_rec
                , i_format_id      => i_format_id
                , i_entity_type    => prs_api_const_pkg.ENTITY_TYPE_CHIP
                , i_file_type      => prs_api_const_pkg.FILE_TYPE_EMBOSSING
            );
        
        else
            trc_log_pkg.debug (
                i_text  => 'Doesn''t request for parent icc card instance'
            );

        end if;
        
        trc_log_pkg.debug (
            i_text  => 'Format emv chip data - ok'
        );
    exception
        when others then
            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure format_p3chip_data (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) is
        l_p3chip_data           raw(32767);
        l_raw_data              raw(32767);
    begin
        trc_log_pkg.debug (
            i_text  => 'Format p3 chip data...'
        );

        if i_perso_rec.icc_instance_id is null then
            emv_api_application_pkg.format_p3chip_data (
                i_appl_data    => i_perso_data.appl_data
                , o_raw_data   => l_raw_data
            );

            for i in 1 .. i_params.count loop
                l_p3chip_data := l_p3chip_data || case i_params(i).param_name
                                                when prs_api_const_pkg.PARAM_P3CHIP_DATA then
                                                    l_raw_data
                                                when prs_api_const_pkg.PARAM_EMBOSSING_DATA then
                                                    i_perso_data.embossing_data
                                            else
                                                utl_raw.cast_to_raw (
                                                    prs_api_util_pkg.convert_data (i_params(i).param_value, i_perso_data.charset)
                                                )
                                            end;
                /*trc_log_pkg.info (
                    i_text          => 'param_name[#1] value[#2]'
                    , i_env_param1  => i_params(i).param_name
                    , i_env_param2  => i_params(i).param_value
                );*/
            end loop;

            prs_api_file_pkg.put_records (
                i_raw_data         => l_p3chip_data
                , i_perso_rec      => i_perso_rec
                , i_format_id      => i_format_id
                , i_entity_type    => prs_api_const_pkg.ENTITY_TYPE_P3CHIP
                , i_file_type      => prs_api_const_pkg.FILE_TYPE_EMBOSSING
            );

        else
            trc_log_pkg.debug (
                i_text  => 'Doesn''t request for parent icc card instance'
            );

        end if;

        trc_log_pkg.debug (
            i_text  => 'Format emv chip data - ok'
        );
    exception
        when others then
            dbms_output.put_line(sqlerrm);
            raise;
    end;

    procedure setup_templates (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
    ) is
        l_mod_params              com_api_type_pkg.t_param_tab;
        l_params                  rul_api_type_pkg.t_param_tab;
        l_templates_found         com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    begin
        trc_log_pkg.debug (
            i_text  => 'Setup templates...'
        );
        
        for template in (
            select
                id
                , method_id
                , entity_type
                , format_id
                , mod_id
            from (
                select
                    t.id
                    , t.method_id
                    , t.entity_type
                    , t.format_id
                    , t.mod_id
                    , a.element_number
                from
                    prs_template t
                    , com_array_element a
                where
                    t.method_id = i_perso_method.id
                    and a.array_id = prs_api_const_pkg.PERSO_TEMPLATE_ENTITY_ARRAY
                    and a.element_value = t.entity_type
            )
            order by
                element_number
        ) loop
            l_templates_found := com_api_type_pkg.TRUE;
            l_params.delete;
            
            if template.mod_id is not null and l_mod_params.count = 0 then
                set_mod_params (
                    i_perso_rec    => i_perso_rec
                    , o_param_tab  => l_mod_params
                );
            end if;
            
            if template.mod_id is null or rul_api_mod_pkg.check_condition (
                i_mod_id    => template.mod_id
                , i_params  => l_mod_params
            ) = com_api_const_pkg.TRUE then
            
                case template.entity_type
                    when prs_api_const_pkg.ENTITY_TYPE_TRACK1 then
                        trc_log_pkg.debug (
                            i_text  => 'TRACK1 template setup ...'
                        );
                        get_template_values (
                            i_format_id       => template.format_id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                            , i_entity_type   => prs_api_const_pkg.ENTITY_TYPE_TRACK1
                            , o_params        => l_params
                        );
                        
                        format_track_contact (
                            i_track_type     => prs_api_const_pkg.ENTITY_TYPE_TRACK1
                            , io_params      => l_params
                            , io_perso_data  => io_perso_data
                        );

                    when prs_api_const_pkg.ENTITY_TYPE_TRACK2 then
                        trc_log_pkg.debug (
                            i_text  => 'TRACK2 template setup ...'
                        );
                        get_template_values (
                            i_format_id       => template.format_id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                            , i_entity_type   => prs_api_const_pkg.ENTITY_TYPE_TRACK2
                            , o_params        => l_params
                        );
                        
                        format_track_contact (
                            i_track_type     => prs_api_const_pkg.ENTITY_TYPE_TRACK2
                            , io_params      => l_params
                            , io_perso_data  => io_perso_data
                        );

                    when prs_api_const_pkg.ENTITY_TYPE_TRACK3 then
                        trc_log_pkg.debug (
                            i_text  => 'TRACK3 template setup ...'
                        );
                        get_template_values (
                            i_format_id       => template.format_id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                            , i_entity_type   => prs_api_const_pkg.ENTITY_TYPE_TRACK3
                            , o_params        => l_params
                        );

                        format_track_contact (
                            i_track_type     => prs_api_const_pkg.ENTITY_TYPE_TRACK3
                            , io_params      => l_params
                            , io_perso_data  => io_perso_data
                        );

                    when prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK1 then
                        trc_log_pkg.debug (
                            i_text  => 'TRACK1 contactless template setup ...'
                        );
                        get_template_values (
                            i_format_id       => template.format_id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                            , i_entity_type   => prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK1
                            , o_params        => l_params
                        );

                        format_track_contactless (
                            i_track_type           => prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK1
                            , i_params             => l_params
                            , o_track_contactless  => io_perso_data.track1_contactless
                            , o_bitmask_pcvc3      => io_perso_data.track1_bitmask_pcvc3
                            , o_bitmask_punatc     => io_perso_data.track1_bitmask_punatc
                            , o_natc               => io_perso_data.track1_natc
                        );

                    when prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK2 then
                        trc_log_pkg.debug (
                            i_text  => 'TRACK2 contactless template setup ...'
                        );
                        get_template_values (
                            i_format_id       => template.format_id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                            , i_entity_type   => prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK2
                            , o_params        => l_params
                        );

                        format_track_contactless (
                            i_track_type           => prs_api_const_pkg.ENTITY_TYPE_CLESS_TRACK2
                            , i_params             => l_params
                            , o_track_contactless  => io_perso_data.track2_contactless
                            , o_bitmask_pcvc3      => io_perso_data.track2_bitmask_pcvc3
                            , o_bitmask_punatc     => io_perso_data.track2_bitmask_punatc
                            , o_natc               => io_perso_data.track2_natc
                        );
                        
                    when prs_api_const_pkg.ENTITY_TYPE_EMBOSSING then
                        trc_log_pkg.debug (
                            i_text  => 'KOMAC template setup ...'
                        );
                        if i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                            if i_perso_rec.icc_instance_id is null then
                                get_template_values (
                                    i_format_id       => template.format_id
                                    , i_perso_rec     => i_perso_rec
                                    , i_perso_method  => i_perso_method
                                    , i_perso_data    => io_perso_data
                                    , i_entity_type   => prs_api_const_pkg.ENTITY_TYPE_EMBOSSING
                                    , o_params        => l_params
                                );

                                format_embossing_record (
                                    i_params         => l_params
                                    , i_perso_rec    => i_perso_rec
                                    , i_format_id    => template.format_id
                                    , io_perso_data  => io_perso_data
                                );
                                
                            else
                                trc_log_pkg.debug (
                                    i_text  => 'Doesn''t request for parent icc card instance'
                                );
                            end if;

                        else
                            trc_log_pkg.debug (
                                i_text  => 'Generation type doesn''t request card generation ...'
                            );
                        end if;
                    
                    when prs_api_const_pkg.ENTITY_TYPE_CHIP then
                        trc_log_pkg.debug (
                            i_text  => 'EMV Chip template setup ...'
                        );
                        if i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                            if i_perso_rec.emv_appl_scheme_id is null then
                                com_api_error_pkg.raise_error (
                                    i_error         => 'EMV_TEMPLATE_NOT_SPECIFIED'
                                );
                            end if;

                            get_emv_template_values (
                                i_format_id       => template.format_id
                                , i_perso_rec     => i_perso_rec
                                , i_perso_method  => i_perso_method
                                , io_perso_data   => io_perso_data
                                , o_params        => l_params
                            );
                            
                            format_emv_chip_data (
                                i_params          => l_params
                                , i_perso_rec     => i_perso_rec
                                , i_format_id     => template.format_id
                                , i_perso_data    => io_perso_data
                            );

                        else
                            trc_log_pkg.debug (
                                i_text  => 'Generation type doesn''t request card generation ...'
                            );
                        end if;
      
                    when prs_api_const_pkg.ENTITY_TYPE_P3CHIP then
                        trc_log_pkg.debug (
                            i_text  => 'P3 Chip template setup ...'
                        );
                        if i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                            if i_perso_rec.emv_appl_scheme_id is null then
                                com_api_error_pkg.raise_error (
                                    i_error         => 'EMV_TEMPLATE_NOT_SPECIFIED'
                                );
                            end if;

                            get_p3_template_values (
                                i_format_id       => template.format_id
                                , i_perso_rec     => i_perso_rec
                                , i_perso_method  => i_perso_method
                                , io_perso_data   => io_perso_data
                                , o_params        => l_params
                            );

                            format_p3chip_data (
                                i_params          => l_params
                                , i_perso_rec     => i_perso_rec
                                , i_format_id     => template.format_id
                                , i_perso_data    => io_perso_data
                            );

                        else
                            trc_log_pkg.debug (
                                i_text  => 'Generation type doesn''t request card generation ...'
                            );
                        end if;

                    when prs_api_const_pkg.ENTITY_TYPE_PINMAILER then
                        trc_log_pkg.debug (
                            i_text  => 'PIN MAILER template setup ...'
                        );
                        if i_pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT then
                            get_template_values (
                                i_format_id       => template.format_id
                                , i_perso_rec     => i_perso_rec
                                , i_perso_method  => i_perso_method
                                , i_perso_data    => io_perso_data
                                , i_entity_type   => prs_api_const_pkg.ENTITY_TYPE_PINMAILER
                                , o_params        => l_params
                            );
                            
                            format_pin_mailer (
                                i_params           => l_params
                                , i_perso_rec      => i_perso_rec
                                , i_hsm_device_id  => io_perso_data.hsm_device_id
                                , i_pin_length     => i_perso_method.pin_length
                                , i_perso_key      => io_perso_data.perso_key
                            );
                            
                        else
                            trc_log_pkg.debug (
                                i_text  => 'Generation type doesn''t request mailer ...'
                            );
                        end if;
                        
                    else
                        prs_cst_perso_pkg.setup_templates (
                            i_template_rec          => template
                            , i_inst_id             => i_inst_id
                            , i_perso_rec           => i_perso_rec
                            , i_embossing_request   => i_embossing_request
                            , i_pin_mailer_request  => i_pin_mailer_request
                            , i_perso_method        => i_perso_method
                            , io_perso_data         => io_perso_data
                        );

                end case;
            end if;
            
        end loop;
        
        if l_templates_found = com_api_type_pkg.FALSE then
            if i_perso_method.pin_verify_method = prs_api_const_pkg.PIN_VERIFIC_METHOD_UNREQUIRED then
                trc_log_pkg.debug (
                    i_text          => 'Unable determine template for personalization method [#1]'
                    , i_env_param1  => i_perso_method.id
                );
             else
                com_api_error_pkg.raise_error (
                    i_error         => 'NO_TEMPLATE_FOR_PERSO_METHOD'
                    , i_env_param1  => i_perso_method.id
                );
             end if;
        end if;
        
        trc_log_pkg.debug (
            i_text  => 'Setup templates - ok'
        );
    end;

end prs_api_template_pkg;
/
