create or replace package com_api_currency_pkg is

EURO        constant com_api_type_pkg.t_curr_code := '978';
USDOLLAR    constant com_api_type_pkg.t_curr_code := '840';
RUBLE       constant com_api_type_pkg.t_curr_code := '643';

procedure apply_currency_update (
    i_code_tab           in      com_api_type_pkg.t_curr_code_tab
  , i_name_tab           in      com_api_type_pkg.t_curr_code_tab
  , i_exponent_tab       in      com_api_type_pkg.t_tiny_tab
);

function get_currency_exponent(
    i_curr_code          in      com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_tiny_id;

function get_amount_str(
    i_amount             in      com_api_type_pkg.t_money
  , i_curr_code          in      com_api_type_pkg.t_curr_code
  , i_mask_curr_code     in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_format_mask        in      com_api_type_pkg.t_name         default null
  , i_mask_error         in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_user_dig_separator in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_name;

function get_currency_name(
    i_curr_code          in      com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_curr_name
result_cache;

function get_currency_code(
    i_curr_name          in      com_api_type_pkg.t_curr_name
) return com_api_type_pkg.t_curr_code
result_cache;

function get_currency_full_name(
    i_curr_code          in      com_api_type_pkg.t_curr_name
  , i_lang               in      com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name
result_cache;

function get_multiplier(
    i_curr_code          in      com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money
result_cache;

end;
/
