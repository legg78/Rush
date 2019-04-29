create or replace package iss_api_type_pkg is
/*********************************************************
*  Issuer types <br />
*  Created by Kopachev D.(kopachev@bpcbt.com)  at 20.05.2010 <br />
*  Last changed by $Author: necheukhin $ <br />
*  $LastChangedDate:: 2014-05-29 00:43:22 +0300#$ <br />
*  Revision: $LastChangedRevision: 175034 $ <br />
*  Module: ISS_API_TYPE_PKG <br />
*  @headcom
**********************************************************/
    subtype t_file_name          is varchar2(255);

    type t_product_card_type_rec is record (
        id                          com_api_type_pkg.t_short_id
      , product_id                  com_api_type_pkg.t_short_id
      , card_type_id                com_api_type_pkg.t_tiny_id
      , seq_number_low              com_api_type_pkg.t_tiny_id
      , seq_number_high             com_api_type_pkg.t_tiny_id
      , bin_id                      com_api_type_pkg.t_short_id
      , index_range_id              com_api_type_pkg.t_short_id
      , number_format_id            com_api_type_pkg.t_tiny_id
      , emv_appl_scheme_id          com_api_type_pkg.t_tiny_id
      , status                      com_api_type_pkg.t_dict_value
      , pin_request                 com_api_type_pkg.t_dict_value
      , embossing_request           com_api_type_pkg.t_dict_value
      , pin_mailer_request          com_api_type_pkg.t_dict_value
      , blank_type_id               com_api_type_pkg.t_tiny_id
      , perso_priority              com_api_type_pkg.t_dict_value
      , reiss_command               com_api_type_pkg.t_dict_value
      , reiss_start_date_rule       com_api_type_pkg.t_dict_value
      , reiss_expir_date_rule       com_api_type_pkg.t_dict_value
      , reiss_card_type_id          com_api_type_pkg.t_tiny_id
      , reiss_contract_id           com_api_type_pkg.t_medium_id
      , state                       com_api_type_pkg.t_dict_value
      , perso_method_id             com_api_type_pkg.t_tiny_id
      , service_id                  com_api_type_pkg.t_short_id
      , reiss_product_id            com_api_type_pkg.t_short_id
      , reiss_bin_id                com_api_type_pkg.t_short_id
      , uid_format_id               com_api_type_pkg.t_tiny_id  
    );

    type t_product_card_type_tab is
        table of t_product_card_type_rec index by binary_integer;

    type t_customer is record(
        id                          com_api_type_pkg.t_medium_id
      , entity_type                 com_api_type_pkg.t_dict_value
      , object_id                   com_api_type_pkg.t_long_id
      , customer_number             com_api_type_pkg.t_name
      , inst_id                     com_api_type_pkg.t_inst_id
      , product_id                  com_api_type_pkg.t_short_id
    );

    type t_cardholder is record(
        id                          com_api_type_pkg.t_long_id
      , person_id                   com_api_type_pkg.t_person_id
      , cardholder_number           com_api_type_pkg.t_name
      , cardholder_name             com_api_type_pkg.t_name
      , relation                    com_api_type_pkg.t_dict_value
      , resident                    com_api_type_pkg.t_boolean
      , nationality                 com_api_type_pkg.t_curr_code
      , marital_status              com_api_type_pkg.t_dict_value
      , inst_id                     com_api_type_pkg.t_inst_id
    );

    type t_card is record(
        id                          com_api_type_pkg.t_medium_id
      , inst_id                     com_api_type_pkg.t_inst_id
      , agent_id                    com_api_type_pkg.t_agent_id
      , delivery_agent_number       com_api_type_pkg.t_name
      , card_type_id                com_api_type_pkg.t_tiny_id
      , card_number                 com_api_type_pkg.t_card_number
      , cardholder_id               com_api_type_pkg.t_medium_id
      , cardholder_name             com_api_type_pkg.t_name
      , company_name                com_api_type_pkg.t_name
      , command                     com_api_type_pkg.t_dict_value
      , contract_id                 com_api_type_pkg.t_medium_id
      , start_date                  date
      , start_date_rule             com_api_type_pkg.t_dict_value
      , expir_date                  date
      , expir_date_rule             com_api_type_pkg.t_dict_value
      , iss_date                    date
      , customer_id                 com_api_type_pkg.t_medium_id
      , category                    com_api_type_pkg.t_dict_value
      , perso_priority              com_api_type_pkg.t_dict_value
      , reissue_reason              com_api_type_pkg.t_dict_value
      , reissue_command             com_api_type_pkg.t_dict_value
      , clone_optional_services     com_api_type_pkg.t_boolean
      , pin_request                 com_api_type_pkg.t_dict_value
      , pin_mailer_request          com_api_type_pkg.t_dict_value
      , embossing_request           com_api_type_pkg.t_dict_value
      , service_id                  com_api_type_pkg.t_short_id
      , icc_instance_id             com_api_type_pkg.t_medium_id
      , blank_type_id               com_api_type_pkg.t_tiny_id
      , delivery_channel            com_api_type_pkg.t_dict_value
      , sequential_number           com_api_type_pkg.t_tiny_id
      , status                      com_api_type_pkg.t_dict_value
      , status_reason               com_api_type_pkg.t_dict_value
      , state                       com_api_type_pkg.t_dict_value
      , delivery_status             com_api_type_pkg.t_dict_value
      , embossed_surname            com_api_type_pkg.t_name
      , embossed_first_name         com_api_type_pkg.t_name
      , embossed_second_name        com_api_type_pkg.t_name
      , embossed_title              com_api_type_pkg.t_dict_value
      , embossed_line_additional    com_api_type_pkg.t_name
      , supplementary_info_1        com_api_type_pkg.t_name
      , cardholder_photo_file_name  t_file_name
      , cardholder_sign_file_name   t_file_name
    );

    type t_department is record(
        id                          com_api_type_pkg.t_short_id
      , parent_id                   com_api_type_pkg.t_short_id
      , label                       com_api_type_pkg.t_name
      , customer_id                 com_api_type_pkg.t_medium_id
      , contract_id                 com_api_type_pkg.t_medium_id
      , inst_id                     com_api_type_pkg.t_inst_id
      , new_dept                    com_api_type_pkg.t_short_id
    );

    type t_card_instance is record(
        id                          com_api_type_pkg.t_medium_id
      , split_hash                  com_api_type_pkg.t_tiny_id
      , card_id                     com_api_type_pkg.t_medium_id
      , seq_number                  com_api_type_pkg.t_tiny_id
      , state                       com_api_type_pkg.t_dict_value
      , reg_date                    date
      , iss_date                    date
      , start_date                  date
      , expir_date                  date
      , cardholder_name             com_api_type_pkg.t_name
      , company_name                com_api_type_pkg.t_name
      , pin_request                 com_api_type_pkg.t_dict_value
      , pin_mailer_request          com_api_type_pkg.t_dict_value
      , embossing_request           com_api_type_pkg.t_dict_value
      , status                      com_api_type_pkg.t_dict_value
      , perso_priority              com_api_type_pkg.t_dict_value
      , perso_method_id             com_api_type_pkg.t_tiny_id
      , bin_id                      com_api_type_pkg.t_short_id
      , inst_id                     com_api_type_pkg.t_tiny_id
      , agent_id                    com_api_type_pkg.t_short_id
      , blank_type_id               com_api_type_pkg.t_tiny_id
      , reissue_reason              com_api_type_pkg.t_dict_value
      , reissue_date                date
      , preceding_card_instance_id  com_api_type_pkg.t_medium_id
      , delivery_channel            com_api_type_pkg.t_dict_value
      , icc_instance_id             com_api_type_pkg.t_medium_id
      , card_uid                    com_api_type_pkg.t_name
      , delivery_ref_number         com_api_type_pkg.t_name
      , delivery_status             com_api_type_pkg.t_name
      , embossed_surname            com_api_type_pkg.t_name
      , embossed_first_name         com_api_type_pkg.t_name
      , embossed_second_name        com_api_type_pkg.t_name
      , embossed_title              com_api_type_pkg.t_dict_value
      , embossed_line_additional    com_api_type_pkg.t_name
      , supplementary_info_1        com_api_type_pkg.t_name
      , cardholder_photo_file_name  t_file_name
      , cardholder_sign_file_name   t_file_name
      , is_last_seq_number          com_api_type_pkg.t_boolean
    );

    type t_bin_rec is record (
        id                          com_api_type_pkg.t_short_id
      , seqnum                      com_api_type_pkg.t_seqnum
      , bin                         com_api_type_pkg.t_bin
      , inst_id                     com_api_type_pkg.t_inst_id
      , network_id                  com_api_type_pkg.t_network_id
      , bin_currency                com_api_type_pkg.t_curr_code
      , sttl_currency               com_api_type_pkg.t_curr_code
      , pan_length                  com_api_type_pkg.t_tiny_id
      , card_type_id                com_api_type_pkg.t_tiny_id
      , country                     com_api_type_pkg.t_country_code
    );
    type t_bin_tab is table of t_bin_rec index by binary_integer;

    type t_card_rec is record (
        id                          com_api_type_pkg.t_medium_id
      , split_hash                  com_api_type_pkg.t_tiny_id
      , card_hash                   com_api_type_pkg.t_medium_id
      , card_mask                   com_api_type_pkg.t_card_number
      , inst_id                     com_api_type_pkg.t_inst_id
      , card_type_id                com_api_type_pkg.t_tiny_id
      , country                     com_api_type_pkg.t_country_code
      , customer_id                 com_api_type_pkg.t_medium_id
      , cardholder_id               com_api_type_pkg.t_medium_id
      , contract_id                 com_api_type_pkg.t_medium_id
      , reg_date                    date
      , category                    com_api_type_pkg.t_dict_value
      , card_number                 com_api_type_pkg.t_card_number
    );
    type t_card_tab is table of t_card_rec index by binary_integer;

    type t_limit_rec is record (
        id                          com_api_type_pkg.t_long_id
      , limit_short_name            com_api_type_pkg.t_name
      , limit_full_name             com_api_type_pkg.t_name
      , sum_limit                   com_api_type_pkg.t_money
      , sum_value                   com_api_type_pkg.t_money
      , limit_type                  com_api_type_pkg.t_dict_value
    );
    type t_limit_tab is table of t_limit_rec index by binary_integer;

    type t_phone_rec is record (
        card_id                     com_api_type_pkg.t_medium_id
      , phone_number                com_api_type_pkg.t_name
    );
    type t_phone_tab is table of t_phone_rec index by binary_integer;

    type t_card_token_rec is record (
        id                          com_api_type_pkg.t_medium_id
      , card_id                     com_api_type_pkg.t_medium_id
      , card_instance_id            com_api_type_pkg.t_medium_id
      , token                       com_api_type_pkg.t_card_number
      , status                      com_api_type_pkg.t_dict_value
      , split_hash                  com_api_type_pkg.t_tiny_id
      , init_oper_id                com_api_type_pkg.t_long_id
      , close_session_file_id       com_api_type_pkg.t_long_id
    );
    type t_card_token_tab is table of t_card_token_rec index by binary_integer;

end iss_api_type_pkg;
/
