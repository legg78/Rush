create or replace package acq_ui_terminal_templ_pkg as
/********************************************************* 
 *  Acquiring application API  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 26.07.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: vis_api_incoming_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_template(
    o_template_id               out  com_api_type_pkg.t_short_id
  , i_terminal_type          in      com_api_type_pkg.t_dict_value
  , i_standard_id            in      com_api_type_pkg.t_tiny_id
  , i_card_data_input_cap    in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_cap          in      com_api_type_pkg.t_dict_value
  , i_card_capture_cap       in      com_api_type_pkg.t_dict_value
  , i_term_operating_env     in      com_api_type_pkg.t_dict_value
  , i_crdh_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_input_mode   in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_method       in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_entity       in      com_api_type_pkg.t_dict_value
  , i_card_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_term_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_pin_capture_cap        in      com_api_type_pkg.t_dict_value
  , i_cat_level              in      com_api_type_pkg.t_dict_value
  , i_status                 in      com_api_type_pkg.t_dict_value
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      com_api_type_pkg.t_tiny_id
  , i_name                   in      com_api_type_pkg.t_full_desc    default null
  , i_description            in      com_api_type_pkg.t_full_desc    default null
  , i_lang                   in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id                in      com_api_type_pkg.t_boolean
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id    default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value   default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value   default null
);

procedure modify_template(
    i_template_id            in      com_api_type_pkg.t_short_id
  , i_standard_id            in      com_api_type_pkg.t_tiny_id
  , i_card_data_input_cap    in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_cap          in      com_api_type_pkg.t_dict_value
  , i_card_capture_cap       in      com_api_type_pkg.t_dict_value
  , i_term_operating_env     in      com_api_type_pkg.t_dict_value
  , i_crdh_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_input_mode   in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_method       in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_entity       in      com_api_type_pkg.t_dict_value
  , i_card_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_term_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_pin_capture_cap        in      com_api_type_pkg.t_dict_value
  , i_cat_level              in      com_api_type_pkg.t_dict_value
  , i_status                 in      com_api_type_pkg.t_dict_value
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      com_api_type_pkg.t_tiny_id
  , i_name                   in      com_api_type_pkg.t_full_desc    default null
  , i_description            in      com_api_type_pkg.t_full_desc    default null
  , i_lang                   in      com_api_type_pkg.t_dict_value   default null
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id    default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value   default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value   default null
);

procedure remove_template(
    i_template_id           in      com_api_type_pkg.t_short_id
);

end;
/
