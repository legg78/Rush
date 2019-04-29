create or replace package acq_api_terminal_pkg as
/*************************************************************
* API procedures for ACQ Terminal
* Created by Filimonov A.(filimonov@bpcbt.com)  at 17.11.2009
* Module: ACQ_API_TERMINAL_PKG
* @headcom
*************************************************************/

procedure add_terminal(
    io_terminal_id           in out  com_api_type_pkg.t_short_id
  , i_terminal_number        in      com_api_type_pkg.t_terminal_number
  , i_merchant_id            in      com_api_type_pkg.t_short_id
  , i_mcc                    in      com_api_type_pkg.t_mcc
  , i_contract_id            in      com_api_type_pkg.t_medium_id
  , i_plastic_number         in      com_api_type_pkg.t_card_number
  , i_terminal_type          in      com_api_type_pkg.t_dict_value
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
  , i_inst_id                in      com_api_type_pkg.t_inst_id
  , i_device_id              in      com_api_type_pkg.t_short_id
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      pls_integer
  , i_standard_id            in      com_api_type_pkg.t_tiny_id
  , i_version_id             in      com_api_type_pkg.t_tiny_id
  , i_split_hash             in      com_api_type_pkg.t_tiny_id
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id   default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value  default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value  default null
);

procedure modify_terminal(
    i_terminal_id            in      com_api_type_pkg.t_short_id
  , i_terminal_number        in      varchar2
  , i_merchant_id            in      com_api_type_pkg.t_short_id
  , i_mcc                    in      com_api_type_pkg.t_mcc
  , i_plastic_number         in      com_api_type_pkg.t_card_number
  , i_contract_id            in      com_api_type_pkg.t_medium_id
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
  , i_device_id              in      com_api_type_pkg.t_short_id
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      pls_integer
  , i_version_id             in      com_api_type_pkg.t_tiny_id
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id   default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value  default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value  default null
);

procedure remove_terminal(
    i_terminal_id           in      com_api_type_pkg.t_short_id
);

procedure get_terminal (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_merchant_number       in      varchar2
  , i_terminal_number       in      varchar2
  , o_merchant_id              out  com_api_type_pkg.t_short_id
  , o_terminal_id              out  com_api_type_pkg.t_short_id
);

procedure get_terminal(
    i_merchant_id           in      com_api_type_pkg.t_short_id
  , i_terminal_number       in      varchar2
  , o_terminal_id              out  com_api_type_pkg.t_short_id
);

procedure get_merchant(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , o_merchant_number          out  com_api_type_pkg.t_merchant_number
  , o_merchant_id              out  com_api_type_pkg.t_short_id
  , o_terminal_id              out  com_api_type_pkg.t_short_id
  , i_mask_error            in      com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
);

function get_merchant_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id;

function get_merchant_number(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_merchant_number;

function get_product_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id;

function get_terminal_number(
    i_terminal_id       in      com_api_type_pkg.t_short_id
  , i_mask_error        in      com_api_type_pkg.t_boolean                 default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_name;

function get_inst_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id;

-- This function returns ID of terminal address.
-- If it does not exists, it try to find address in terminal's merchant hierarchy
function get_terminal_address_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
    , i_lang                in      com_api_type_pkg.t_dict_value          default null
) return com_api_type_pkg.t_long_id;

function get_pos_batch_method (
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value;

function get_partial_approval (
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function get_purchase_amount (
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

procedure close_terminal;

procedure set_status(
    i_terminal_id  in     com_api_type_pkg.t_short_id
  , i_status       in     com_api_type_pkg.t_dict_value
);

function get_terminal(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id             default null
  , i_mask_error            in      com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
) return acq_api_type_pkg.t_terminal;

end;
/
