create or replace package cst_cab_com_pkg as

function get_main_card_id (
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
) return com_api_type_pkg.t_medium_id;

function format_amount (
    i_amount            in      com_api_type_pkg.t_money
  , i_curr_code         in      com_api_type_pkg.t_curr_code
  , i_add_curr_name     in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_use_separator     in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name;

function get_overdue_days(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
) return com_api_type_pkg.t_tiny_id;

function get_card_fee_tier(
    i_card_id           in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_dict_value;

end cst_cab_com_pkg;
/
