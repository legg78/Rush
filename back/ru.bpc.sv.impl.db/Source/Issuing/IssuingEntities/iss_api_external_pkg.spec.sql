create or replace package iss_api_external_pkg is
/*************************************************************
*  API for cardholders & cards external integration <br />
*  Created by Gerbeev I. (gerbeev@bpcbt.com)  at 18.05.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ISS_API_EXTERNAL_PKG  <br />
*  @headcom
**************************************************************/

procedure create_cardholder(
    o_id                               out com_api_type_pkg.t_medium_id
  , i_customer_id                   in     com_api_type_pkg.t_medium_id
  , i_person_id                     in     com_api_type_pkg.t_person_id
  , i_cardholder_name               in     com_api_type_pkg.t_name
  , i_relation                      in     com_api_type_pkg.t_dict_value
  , i_resident                      in     com_api_type_pkg.t_boolean
  , i_nationality                   in     com_api_type_pkg.t_curr_code
  , i_marital_status                in     com_api_type_pkg.t_dict_value
  , io_cardholder_number            in out com_api_type_pkg.t_name
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
);

procedure issue_card(
    o_id                               out com_api_type_pkg.t_medium_id
  , io_card_number                  in out com_api_type_pkg.t_card_number
  , o_card_instance_id                 out com_api_type_pkg.t_medium_id
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
  , i_agent_id                      in     com_api_type_pkg.t_agent_id
  , i_contract_id                   in     com_api_type_pkg.t_medium_id
  , i_cardholder_id                 in     com_api_type_pkg.t_long_id
  , i_card_type_id                  in     com_api_type_pkg.t_tiny_id
  , i_customer_id                   in     com_api_type_pkg.t_long_id
  , i_category                      in     com_api_type_pkg.t_dict_value    default null
  , i_start_date                    in     date                             default null
  , io_expir_date                   in out date
  , i_cardholder_name               in     com_api_type_pkg.t_name          default null
  , i_company_name                  in     com_api_type_pkg.t_name          default null
  , i_perso_priority                in     com_api_type_pkg.t_dict_value    default null
  , i_service_id                    in     com_api_type_pkg.t_short_id      default null
  , i_icc_instance_id               in     com_api_type_pkg.t_medium_id     default null
  , i_delivery_channel              in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_seq_number                    in     com_api_type_pkg.t_tiny_id       default null
  , i_status                        in     com_api_type_pkg.t_dict_value    default null
  , i_state                         in     com_api_type_pkg.t_dict_value    default null
  , i_iss_date                      in     date                             default null
  , i_preceding_instance_id         in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_reason                in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                  in     date                             default null
  , i_pin_request                   in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request             in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_status               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname              in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name           in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_title                in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional      in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1          in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name     in     iss_api_type_pkg.t_file_name     default null
  , i_pin_mailer_request            in     com_api_type_pkg.t_dict_value    default null
);

procedure reissue_card(
    i_card_number                  in     com_api_type_pkg.t_card_number
  , io_seq_number                  in out com_api_type_pkg.t_tiny_id
  , io_card_number                 in out com_api_type_pkg.t_card_number
  , i_command                      in     com_api_type_pkg.t_dict_value    default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_contract_id                  in     com_api_type_pkg.t_medium_id     default null
  , i_card_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_category                     in     com_api_type_pkg.t_dict_value    default null
  , i_start_date                   in     date                             default null
  , i_start_date_rule              in     com_api_type_pkg.t_dict_value    default null
  , io_expir_date                  in out date
  , i_expir_date_rule              in     com_api_type_pkg.t_dict_value    default null
  , i_cardholder_name              in     com_api_type_pkg.t_name          default null
  , i_company_name                 in     com_api_type_pkg.t_name          default null
  , i_perso_priority               in     com_api_type_pkg.t_dict_value    default null
  , i_pin_request                  in     com_api_type_pkg.t_dict_value    default null
  , i_pin_mailer_request           in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request            in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_channel             in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                in     com_api_type_pkg.t_tiny_id       default null
  , i_reissue_reason               in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                 in     date                             default null
  , i_clone_optional_services      in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_delivery_status              in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname             in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name         in     com_api_type_pkg.t_name          default null
  , i_embossed_title               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional     in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1         in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name   in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_card_uid                     in     com_api_type_pkg.t_name          default null
);

end iss_api_external_pkg;
/
