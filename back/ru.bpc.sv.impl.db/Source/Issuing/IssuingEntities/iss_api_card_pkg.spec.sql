create or replace package iss_api_card_pkg as
/*********************************************************
*  Issuer application - types <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 14.10.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate: 2010-04-27 17:29:49 +0400#$ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ISS_API_CARD_PKG <br />
*  @headcom
**********************************************************/

function get_card (
    i_card_number             in     com_api_type_pkg.t_card_number
  , i_inst_id                 in     com_api_type_pkg.t_inst_id       default null
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec;

function get_card (
    i_card_id                 in     com_api_type_pkg.t_medium_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id       default null
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec;

/*
 * Function searches and returns a card by <i_card_id> if it isn't NULL (<i_card_number> is ignored in this case),
 * otherwise it use <i_card_number> to locate a card.
 * Exception CARD_NOT_FOUND is raised when searching is failed and <i_mask_error> is FALSE.
 */
function get_card (
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , i_card_number               in     com_api_type_pkg.t_card_number
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
  , i_mask_error                in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec;

function get_card_id (
    i_card_number               in     com_api_type_pkg.t_card_number
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
)return com_api_type_pkg.t_medium_id;

function get_card_id_by_uid(
    i_card_uid                  in     com_api_type_pkg.t_name
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
)return com_api_type_pkg.t_medium_id;

function get_card_uid_by_id(
    i_card_id                   in     com_api_type_pkg.t_medium_id
)return com_api_type_pkg.t_name;

function get_customer_id (
    i_card_number               in     com_api_type_pkg.t_card_number
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_medium_id;

function get_customer_id (
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_medium_id;

function get_seq_number (
    i_card_number               in     com_api_type_pkg.t_card_number
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_tiny_id;

function get_card_number (
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
  , i_mask_error                in com_api_type_pkg.t_boolean           default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_card_number;

function get_card_number 
    return  com_api_type_pkg.t_card_number;

/*
 * Function returns undecoded card number. It should be used to prevent
 * useless sequential decoding & encoding of card number with enabled
 * tokenization. For example, if card number is requested by its identifier
 * card_id for successive saving in a table. 
 */
function get_raw_card_number (
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , i_split_hash                in     com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_card_number;

procedure set_card_number(
    i_card_number               in     com_api_type_pkg.t_card_number
);

procedure issue (
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

procedure issue(
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
  , i_need_postponed_event          in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , io_postponed_event_tab          in out nocopy evt_api_type_pkg.t_postponed_event_tab
);

procedure reissue(
    i_card_number                   in     com_api_type_pkg.t_card_number
  , io_seq_number                   in out com_api_type_pkg.t_tiny_id
  , io_card_number                  in out com_api_type_pkg.t_card_number
  , i_command                       in     com_api_type_pkg.t_dict_value    default null
  , i_agent_id                      in     com_api_type_pkg.t_agent_id      default null
  , i_contract_id                   in     com_api_type_pkg.t_medium_id     default null
  , i_card_type_id                  in     com_api_type_pkg.t_tiny_id       default null
  , i_category                      in     com_api_type_pkg.t_dict_value    default null
  , i_start_date                    in     date                             default null
  , i_start_date_rule               in     com_api_type_pkg.t_dict_value    default null
  , io_expir_date                   in out date
  , i_expir_date_rule               in     com_api_type_pkg.t_dict_value    default null
  , i_cardholder_name               in     com_api_type_pkg.t_name          default null
  , i_company_name                  in     com_api_type_pkg.t_name          default null
  , i_perso_priority                in     com_api_type_pkg.t_dict_value    default null
  , i_pin_request                   in     com_api_type_pkg.t_dict_value    default null
  , i_pin_mailer_request            in     com_api_type_pkg.t_dict_value    default null
  , i_embossing_request             in     com_api_type_pkg.t_dict_value    default null
  , i_delivery_channel              in     com_api_type_pkg.t_dict_value    default null
  , i_blank_type_id                 in     com_api_type_pkg.t_tiny_id       default null
  , i_reissue_reason                in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_date                  in     date                             default null
  , i_clone_optional_services       in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_delivery_status               in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_surname              in     com_api_type_pkg.t_name          default null
  , i_embossed_first_name           in     com_api_type_pkg.t_name          default null
  , i_embossed_second_name          in     com_api_type_pkg.t_name          default null
  , i_embossed_title                in     com_api_type_pkg.t_dict_value    default null
  , i_embossed_line_additional      in     com_api_type_pkg.t_name          default null
  , i_supplementary_info_1          in     com_api_type_pkg.t_name          default null
  , i_cardholder_photo_file_name    in     iss_api_type_pkg.t_file_name     default null
  , i_cardholder_sign_file_name     in     iss_api_type_pkg.t_file_name     default null
  , i_card_uid                      in     com_api_type_pkg.t_name          default null
  , i_inherit_pin_offset            in     com_api_type_pkg.t_boolean       default null
);

procedure reissue(
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
  , i_inherit_pin_offset           in     com_api_type_pkg.t_boolean       default null
  , i_need_postponed_event         in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , io_postponed_event_tab         in out nocopy evt_api_type_pkg.t_postponed_event_tab
);

procedure get_card (
    i_card_number               in     com_api_type_pkg.t_card_number
  , i_inst_id                   in     com_api_type_pkg.t_inst_id           default null
  , io_seq_number               in out com_api_type_pkg.t_tiny_id
  , io_expir_date               in out date
  , o_card_id                      out com_api_type_pkg.t_medium_id
  , o_card_type_id                 out com_api_type_pkg.t_tiny_id
  , o_card_country                 out com_api_type_pkg.t_curr_code
  , o_card_inst_id                 out com_api_type_pkg.t_tiny_id
  , o_card_network_id              out com_api_type_pkg.t_tiny_id
  , o_split_hash                   out com_api_type_pkg.t_tiny_id
);

procedure activate_card(
    i_card_instance_id          in     com_api_type_pkg.t_medium_id
  , i_initial_status            in     com_api_type_pkg.t_dict_value
  , i_status                    in     com_api_type_pkg.t_dict_value
);

procedure activate_card(
    i_card_instance_id          in     com_api_type_pkg.t_medium_id
  , i_initial_status            in     com_api_type_pkg.t_dict_value
  , i_status                    in     com_api_type_pkg.t_dict_value
  , i_params                    in     com_api_type_pkg.t_param_tab
);

procedure deactivate_card (
    i_card_instance_id          in     com_api_type_pkg.t_medium_id
  , i_status                    in     com_api_type_pkg.t_dict_value
);

procedure get_card_limits (
    i_card_id                   in     com_api_type_pkg.t_medium_id
    , i_lang                    in     com_api_type_pkg.t_dict_value
    , o_card_limits                out iss_api_type_pkg.t_limit_tab 
);

procedure get_card_phones (
    i_card_id                   in     com_api_type_pkg.t_medium_id
    , o_phone_tab                  out iss_api_type_pkg.t_phone_tab 
);

/*
 * Function returns number of visible digits from beginning of a card number in according to current system settings.
 */
function get_begin_visible_char return com_api_type_pkg.t_tiny_id;
    
/*
 * Function returns number of visible digits from ending of a card number in according to current system settings.
 */
function get_end_visible_char return com_api_type_pkg.t_tiny_id;

function get_card_mask(
    i_card_number               in     com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_card_number;

function get_short_card_mask(
    i_card_number               in     com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_card_number;

procedure reload_settings;

function get_card_limit_balance(
    i_card_id                   in     com_api_type_pkg.t_medium_id
    , i_eff_date                in     date 
    , i_inst_id                 in     com_api_type_pkg.t_inst_id
    , i_currency                in     com_api_type_pkg.t_curr_code 
    , o_array_id                   out com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_money;

function get_card_limit_balance(
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , i_eff_date                  in     date 
  , i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_currency                  in     com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money;

function get_card_agent_number(
    i_card_id                   in     com_api_type_pkg.t_medium_id     default null
  , i_card_number               in     com_api_type_pkg.t_card_number   default null
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
  , i_mask_error                in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_name;

function get_card (
    i_card_uid                  in     com_api_type_pkg.t_name
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
  , i_mask_error                in     com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return iss_api_type_pkg.t_card_rec;

function get_card(
    i_card_instance_id          in     com_api_type_pkg.t_long_id
  , i_mask_error                in     com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_rec;

function get_card_number (
    i_card_uid                  in     com_api_type_pkg.t_name
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
  , o_card_id                      out com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_card_number;

function get_card_number (
    i_card_uid                  in     com_api_type_pkg.t_name
  , i_inst_id                   in     com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_card_number;

function is_instant_card(
    i_contract_id               in     com_api_type_pkg.t_medium_id
  , i_customer_id               in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_boolean;

function is_customer_agent(
    i_agent_id                  in      com_api_type_pkg.t_agent_id
  , i_appl_contract_type        in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

function get_card(
    i_account_id                in      com_api_type_pkg.t_medium_id
  , i_split_hash                in      com_api_type_pkg.t_tiny_id       default null
  , i_state                     in      com_api_type_pkg.t_dict_value    default iss_api_const_pkg.CARD_STATE_ACTIVE
) return iss_api_type_pkg.t_card_tab;

function is_pool_card(
    i_customer_id  in      com_api_type_pkg.t_medium_id
  , i_card_status  in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

procedure reconnect_card(
    i_card_id                      in    com_api_type_pkg.t_long_id
  , i_customer_id                  in    com_api_type_pkg.t_medium_id
  , i_contract_id                  in    com_api_type_pkg.t_long_id
  , i_cardholder_id                in    com_api_type_pkg.t_long_id
  , i_cardholder_photo_file_name   in    iss_api_type_pkg.t_file_name
  , i_cardholder_sign_file_name    in    iss_api_type_pkg.t_file_name
  , i_expir_date                   in    date                          default null
  , i_card_category                in    com_api_type_pkg.t_dict_value default null
);

function is_merchant_card(
    i_service_id                   in    com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

end iss_api_card_pkg;
/
