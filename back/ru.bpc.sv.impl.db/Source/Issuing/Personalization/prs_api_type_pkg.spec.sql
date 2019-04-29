create or replace package prs_api_type_pkg is
/*********************************************************
*  Personalization types
*  Created by Kopachev D.(kopachev@bpcbt.com) at 20.05.2010
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
*  Revision: $LastChangedRevision: 8281 $ <br /> 
*  Module: prs_api_type_pkg
*  @headcom
**********************************************************/    
    subtype t_track1              is varchar2(79);
    subtype t_track2              is varchar2(40);
    subtype t_track1_discr_data   is varchar2(24);
    subtype t_track2_discr_data   is varchar2(17);

    type            t_batch_rec is record (
        id                            com_api_type_pkg.t_short_id
        , seqnum                      com_api_type_pkg.t_seqnum
        , inst_id                     com_api_type_pkg.t_inst_id
        , agent_id                    com_api_type_pkg.t_agent_id
        , product_id                  com_api_type_pkg.t_short_id
        , card_type_id                com_api_type_pkg.t_tiny_id
        , blank_type_id               com_api_type_pkg.t_tiny_id
        , card_count                  com_api_type_pkg.t_short_id
        , hsm_device_id               com_api_type_pkg.t_tiny_id
        , status                      com_api_type_pkg.t_dict_value
        , status_date                 timestamp
        , sort_id                     com_api_type_pkg.t_tiny_id
    );
    type            t_batch_tab is table of t_batch_rec index by binary_integer;
    
    type            t_perso_method_rec is record (
        id                            com_api_type_pkg.t_short_id
        , inst_id                     com_api_type_pkg.t_inst_id
        , pvv_store_method            com_api_type_pkg.t_dict_value
        , pin_store_method            com_api_type_pkg.t_dict_value
        , pin_verify_method           com_api_type_pkg.t_dict_value
        , cvv_required                com_api_type_pkg.t_boolean
        , icvv_required               com_api_type_pkg.t_boolean
        , pvk_index                   com_api_type_pkg.t_tiny_id
        , key_schema_id               com_api_type_pkg.t_tiny_id
        , service_code                com_api_type_pkg.t_module_code
        , dda_required                com_api_type_pkg.t_boolean
        , imk_index                   com_api_type_pkg.t_tiny_id
        , icc_sk_component            com_api_type_pkg.t_dict_value
        , icc_sk_format               com_api_type_pkg.t_dict_value
        , icc_module_length           com_api_type_pkg.t_tiny_id
        , max_script                  com_api_type_pkg.t_tiny_id
        , decimalisation_table        com_api_type_pkg.t_pin_block
        , is_contactless              com_api_type_pkg.t_boolean
        , exp_date_format             com_api_type_pkg.t_dict_value
        , pin_length                  com_api_type_pkg.t_tiny_id
        , cvv2_required               com_api_type_pkg.t_boolean
    );
    type            t_perso_method_tab is table of t_perso_method_rec index by binary_integer;

    type            t_perso_rec is record (
        rows_number                   binary_integer
        , row_id                      rowid
        -- card_instance
        , card_instance_id            com_api_type_pkg.t_medium_id
        , card_id                     com_api_type_pkg.t_medium_id
        , seq_number                  com_api_type_pkg.t_tiny_id
        , reg_date                    date
        , iss_date                    date
        , start_date                  date
        , expir_date                  date
        , cardholder_name             com_api_type_pkg.t_short_desc
        , company_name                com_api_type_pkg.t_short_desc
        , pin_request                 com_api_type_pkg.t_dict_value
        , embossing_request           com_api_type_pkg.t_dict_value
        , pin_mailer_request          com_api_type_pkg.t_dict_value
        , status                      com_api_type_pkg.t_dict_value
        , perso_priority              com_api_type_pkg.t_dict_value
        , perso_method_id             com_api_type_pkg.t_tiny_id
        , bin_id                      com_api_type_pkg.t_short_id
        , blank_type_id               com_api_type_pkg.t_tiny_id
        , reissue_reason              com_api_type_pkg.t_dict_value
        -- card
        , card_mask                   com_api_type_pkg.t_card_number
        , inst_id                     com_api_type_pkg.t_inst_id
        , inst_name                   com_api_type_pkg.t_name
        , card_type_id                com_api_type_pkg.t_tiny_id
        , card_type_name              com_api_type_pkg.t_name
        , cardholder_id               com_api_type_pkg.t_medium_id
        , product_id                  com_api_type_pkg.t_short_id
        , product_number              com_api_type_pkg.t_name
        , product_name                com_api_type_pkg.t_name
        , contract_agent_id           com_api_type_pkg.t_agent_id
        , customer_id                 com_api_type_pkg.t_medium_id
        , customer_number             com_api_type_pkg.t_name
        , contract_id                 com_api_type_pkg.t_medium_id
        , category                    com_api_type_pkg.t_dict_value
        , split_hash                  com_api_type_pkg.t_tiny_id
        -- card_number
        , card_number                 com_api_type_pkg.t_card_number
        -- card_instance_data
        , pvv                         com_api_type_pkg.t_tiny_id
        , pin_block                   com_api_type_pkg.t_pin_block
        , pvv2                        com_api_type_pkg.t_tiny_id
        , pin_offset                  com_api_type_pkg.t_cmid
        -- com_person
        , person_id                   com_api_type_pkg.t_medium_id
        , first_name                  com_api_type_pkg.t_name
        , second_name                 com_api_type_pkg.t_name
        , surname                     com_api_type_pkg.t_name
        , suffix                      com_api_type_pkg.t_dict_value
        , gender                      com_api_type_pkg.t_dict_value
        , birthday                    date
        -- com_person_id
        , id_type                     com_api_type_pkg.t_name
        , id_number                   com_api_type_pkg.t_name
        , id_series                   com_api_type_pkg.t_name
        -- batch_card
        , hsm_device_id               com_api_type_pkg.t_tiny_id
        , card_count                  com_api_type_pkg.t_short_id
        -- batch_card_id
        , batch_card_id               com_api_type_pkg.t_medium_id
        -- cardholder address
        , street                      com_api_type_pkg.t_double_name
        , house                       com_api_type_pkg.t_double_name
        , apartment                   com_api_type_pkg.t_double_name
        , postal_code                 com_api_type_pkg.t_name
        , city                        com_api_type_pkg.t_double_name
        , country                     com_api_type_pkg.t_country_code
        , country_name                com_api_type_pkg.t_name
        , region_code                 com_api_type_pkg.t_dict_value
        , agent_id                    com_api_type_pkg.t_agent_id
        , agent_name                  com_api_type_pkg.t_name
        , agent_number                com_api_type_pkg.t_name
        , perso_state                 com_api_type_pkg.t_dict_value
        , emv_appl_scheme_id          com_api_type_pkg.t_tiny_id
        , icc_instance_id             com_api_type_pkg.t_medium_id
        , slave_count                 com_api_type_pkg.t_long_id
        , lang                        com_api_type_pkg.t_dict_value
        , card_account                com_api_type_pkg.t_account_number
        , is_renewal                  com_api_type_pkg.t_boolean
        , emv_scheme_type             com_api_type_pkg.t_dict_value
        , card_uid                    com_api_type_pkg.t_name
        , uid_format_id               com_api_type_pkg.t_tiny_id
        , embossed_surname            com_api_type_pkg.t_name
        , embossed_first_name         com_api_type_pkg.t_name
        , embossed_second_name        com_api_type_pkg.t_name
        , embossed_title              com_api_type_pkg.t_dict_value
        , embossed_line_additional    com_api_type_pkg.t_name
        , supplementary_info_1        com_api_type_pkg.t_name
        , cardholder_photo_file_name  iss_api_type_pkg.t_file_name
        , cardholder_sign_file_name   iss_api_type_pkg.t_file_name
        , preferred_lang              com_api_type_pkg.t_dict_value
    );
    type            t_perso_tab is table of t_perso_rec index by binary_integer;
    
    type            t_perso_data_rec is record (
        -- cvv
        cvv                           com_api_type_pkg.t_module_code
        , cvc2                        com_api_type_pkg.t_module_code
        , cvv2                        com_api_type_pkg.t_module_code
        , icvv                        com_api_type_pkg.t_module_code
        -- translate pinblock
        , tr_pin_block                com_api_type_pkg.t_pin_block
        -- embossing & chip data
        , embossing_data              raw(32767)
        , appl_data                   emv_api_type_pkg.t_appl_data_tab
        -- data on tracks
        , name_on_track1              com_api_type_pkg.t_name
        , track1                      t_track1
        , track2                      t_track2
        , track2_icc                  t_track2
        , track3                      com_api_type_pkg.t_name
        , tr1_discr_data              t_track1_discr_data
        , tr1_discr_data_icc          t_track1_discr_data
        , tr2_discr_data              t_track2_discr_data
        , tr2_discr_data_icc          t_track2_discr_data
        -- static appl data
        , sad                         com_api_type_pkg.t_lob2_tab
        -- signed static appl data
        , ssad                        com_api_type_pkg.t_lob2_tab
        -- icc derived keys
        , icc_derived_keys            prs_api_type_pkg.t_icc_derived_keys_rec
        -- icc rsa keys & cert
        , icc_rsa_keys                prs_api_type_pkg.t_icc_rsa_key_rec
        -- hsm device
        , hsm_device_id               com_api_type_pkg.t_tiny_id
        , afl_data                    com_api_type_pkg.t_param_tab
        -- track 1,2 contactless data
        , track1_contactless          com_api_type_pkg.t_raw_data
        , track2_contactless          com_api_type_pkg.t_raw_data
        -- pcvc3 track 1,2
        , track1_bitmask_pcvc3        com_api_type_pkg.t_name
        , track2_bitmask_pcvc3        com_api_type_pkg.t_name
        -- punatc track 1,2
        , track1_bitmask_punatc       com_api_type_pkg.t_name
        , track2_bitmask_punatc       com_api_type_pkg.t_name
        -- natc track 1,2
        , track1_natc                 com_api_type_pkg.t_tiny_id
        , track2_natc                 com_api_type_pkg.t_tiny_id
        -- ivcvc3 track 1,2
        , track1_ivcvc3               com_api_type_pkg.t_name
        , track2_ivcvc3               com_api_type_pkg.t_name
        -- dcvv and atc
        , dcvv_track2_pos             com_api_type_pkg.t_tiny_id
        , atc_exist                   com_api_type_pkg.t_boolean
        -- perso keys (3des & rsa)
        , perso_key                   prs_api_type_pkg.t_perso_key_rec
        --conversion
        , charset                     com_api_type_pkg.t_oracle_name
        -- custom perso data
        , cust_embossing_data         raw(32767)
    );
    type            t_perso_data_tab is table of t_perso_data_rec index by binary_integer;
    
    type t_print_field_rec is record (
        text                          com_api_type_pkg.t_text
        , is_pin_block                com_api_type_pkg.t_boolean
    );
    type            t_print_line_tab is table of t_print_field_rec index by pls_integer;
    type            t_print_data_tab is table of t_print_line_tab  index by pls_integer;

    type            t_des_key_rec is record (
        pvk                           sec_api_type_pkg.t_des_key_rec
        , pibk                        sec_api_type_pkg.t_des_key_rec
        , cvk                         sec_api_type_pkg.t_des_key_rec
        , cvk2                        sec_api_type_pkg.t_des_key_rec
        , kek                         sec_api_type_pkg.t_des_key_rec
        , pek_translation             sec_api_type_pkg.t_des_key_rec
        , ppk                         sec_api_type_pkg.t_des_key_rec
        , imk_ac                      sec_api_type_pkg.t_des_key_rec
        , imk_dac                     sec_api_type_pkg.t_des_key_rec
        , imk_idn                     sec_api_type_pkg.t_des_key_rec
        , imk_smc                     sec_api_type_pkg.t_des_key_rec
        , imk_smi                     sec_api_type_pkg.t_des_key_rec
        , imk_cvc3                    sec_api_type_pkg.t_des_key_rec
    );
    type            t_des_key_by_object_tab is table of sec_api_type_pkg.t_des_key_rec index by binary_integer;
    type            t_des_key_by_entity_tab is table of t_des_key_by_object_tab index by com_api_type_pkg.t_dict_value;
    type            t_des_key_by_key_type_tab is table of t_des_key_by_entity_tab index by com_api_type_pkg.t_dict_value;
    type            t_des_key_by_key_index_tab is table of t_des_key_by_key_type_tab index by binary_integer;
    type            t_des_key_by_hsm_tab is table of t_des_key_by_key_index_tab index by binary_integer;

    type            t_rsa_key_rec is record (
        issuer_key                    sec_api_type_pkg.t_rsa_key_rec
        , authority_key               sec_api_type_pkg.t_rsa_key_rec
        , issuer_certificate          sec_api_type_pkg.t_rsa_certificate_rec
    );
    type            t_rsa_key_by_object_tab is table of t_rsa_key_rec index by binary_integer;

    type            t_perso_key_rec is record (
        des_key                       t_des_key_rec
        , rsa_key                     t_rsa_key_rec
    );

    type            t_icc_derived_keys_rec is record (
        idk_ac                        sec_api_type_pkg.t_des_key_rec
        , idk_smc                     sec_api_type_pkg.t_des_key_rec
        , idk_smi                     sec_api_type_pkg.t_des_key_rec
        , idk_idn                     sec_api_type_pkg.t_des_key_rec
        , idk_cvc3                    sec_api_type_pkg.t_des_key_rec
    );

    type            t_icc_rsa_key_rec is record (
        public_key                    com_api_type_pkg.t_key
        , private_key                 com_api_type_pkg.t_key
        , public_key_mac              com_api_type_pkg.t_key
       
        -- private key exponent (d) and modulus(n)
        , private_exponent            com_api_type_pkg.t_key
        , private_modulus             com_api_type_pkg.t_key

        -- 5 chinese temainder theorem components
        , private_p                   com_api_type_pkg.t_key
        , private_q                   com_api_type_pkg.t_key
        , private_dp                  com_api_type_pkg.t_key
        , private_dq                  com_api_type_pkg.t_key
        , private_u                   com_api_type_pkg.t_key
        
        -- public key certificate and remainder
        , certificate                 com_api_type_pkg.t_lob2_tab
        , reminder                    com_api_type_pkg.t_lob2_tab
        
        -- data
        , clear_comp_format           com_api_type_pkg.t_dict_value
        , clear_comp_padding          com_api_type_pkg.t_dict_value
        , derivation_data             com_api_type_pkg.t_raw_data
        , encryption_mode             com_api_type_pkg.t_dict_value
    );

    type            t_session_file_rec is record (
        file_name                     com_api_type_pkg.t_name
        , format_id                   com_api_type_pkg.t_tiny_id
        , entity_type                 com_api_type_pkg.t_dict_value
        , session_file_id             com_api_type_pkg.t_long_id
        , record_number               binary_integer
    );
    type            t_session_file_tab is table of t_session_file_rec index by binary_integer;

    type            t_template_rec is record (
        id                            com_api_type_pkg.t_tiny_id
        , method_id                   com_api_type_pkg.t_tiny_id
        , entity_type                 com_api_type_pkg.t_dict_value
        , format_id                   com_api_type_pkg.t_tiny_id
        , mod_id                      com_api_type_pkg.t_tiny_id
    );
    type            t_template_tab is table of t_template_rec index by binary_integer;

    type t_batch_card_rec is record (
        -- card_instance
        card_instance_id              com_api_type_pkg.t_medium_id
      , card_id                       com_api_type_pkg.t_medium_id
      , seq_number                    com_api_type_pkg.t_tiny_id
      , reg_date                      date
      , iss_date                      date
      , start_date                    date
      , expir_date                    date
      , cardholder_name               com_api_type_pkg.t_short_desc
      , company_name                  com_api_type_pkg.t_short_desc
      , pin_request                   com_api_type_pkg.t_dict_value
      , embossing_request             com_api_type_pkg.t_dict_value
      , pin_mailer_request            com_api_type_pkg.t_dict_value
      , status                        com_api_type_pkg.t_dict_value
      , perso_priority                com_api_type_pkg.t_dict_value
      , perso_method_id               com_api_type_pkg.t_tiny_id
      , bin_id                        com_api_type_pkg.t_short_id
      , blank_type_id                 com_api_type_pkg.t_tiny_id
      , reissue_reason                com_api_type_pkg.t_dict_value
        -- card
      , card_mask                     com_api_type_pkg.t_card_number
      , inst_id                       com_api_type_pkg.t_inst_id
      , card_type_id                  com_api_type_pkg.t_tiny_id
      , cardholder_id                 com_api_type_pkg.t_medium_id
      , product_id                    com_api_type_pkg.t_short_id
      , contract_agent_id             com_api_type_pkg.t_agent_id
      , customer_id                   com_api_type_pkg.t_medium_id
      , contract_id                   com_api_type_pkg.t_medium_id
      , category                      com_api_type_pkg.t_dict_value
      , split_hash                    com_api_type_pkg.t_tiny_id
        -- card_number
      , card_number                   com_api_type_pkg.t_card_number
        -- batch_card
      , hsm_device_id                 com_api_type_pkg.t_tiny_id
      , card_count                    com_api_type_pkg.t_short_id
        -- prs_batch_card
      , batch_card_id                 com_api_type_pkg.t_medium_id
        -- other
      , agent_id                      com_api_type_pkg.t_agent_id
      , icc_instance_id               com_api_type_pkg.t_medium_id
      , lang                          com_api_type_pkg.t_dict_value
      , card_uid                      com_api_type_pkg.t_name
      , embossed_surname              com_api_type_pkg.t_name
      , embossed_first_name           com_api_type_pkg.t_name
      , embossed_second_name          com_api_type_pkg.t_name
      , embossed_title                com_api_type_pkg.t_dict_value
      , embossed_line_additional      com_api_type_pkg.t_name
      , supplementary_info_1          com_api_type_pkg.t_name
      , cardholder_photo_file_name    iss_api_type_pkg.t_file_name
      , cardholder_sign_file_name     iss_api_type_pkg.t_file_name
    );
    type t_batch_card_tab is table of t_batch_card_rec index by binary_integer;

    type t_card_info_rec is record (
          -- common
          product_number              com_api_type_pkg.t_name
        , product_name                com_api_type_pkg.t_name
          -- card_instance_data
        , pvv                         com_api_type_pkg.t_tiny_id
        , pin_block                   com_api_type_pkg.t_pin_block
        , pin_offset                  com_api_type_pkg.t_cmid
          -- com_person
        , person_id                   com_api_type_pkg.t_medium_id
        , first_name                  com_api_type_pkg.t_name
        , second_name                 com_api_type_pkg.t_name
        , surname                     com_api_type_pkg.t_name
        , suffix                      com_api_type_pkg.t_dict_value
        , gender                      com_api_type_pkg.t_dict_value
        , birthday                    date
        -- cardholder address
        , street                      com_api_type_pkg.t_double_name
        , house                       com_api_type_pkg.t_double_name
        , apartment                   com_api_type_pkg.t_double_name
        , postal_code                 com_api_type_pkg.t_name
        , city                        com_api_type_pkg.t_double_name
        , country                     com_api_type_pkg.t_country_code
        , country_name                com_api_type_pkg.t_name
        , region_code                 com_api_type_pkg.t_dict_value
        , region                      com_api_type_pkg.t_double_name
        , agent_number                com_api_type_pkg.t_name
        , card_account                com_api_type_pkg.t_account_number
        , uid_format_id               com_api_type_pkg.t_tiny_id
        , customer_number             com_api_type_pkg.t_name
        , preferred_lang              com_api_type_pkg.t_dict_value
        , customer_reg_date           date
    );
    type t_card_info_tab is table of t_card_info_rec index by binary_integer;

end prs_api_type_pkg;
/
