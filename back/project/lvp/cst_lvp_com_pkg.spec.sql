create or replace package cst_lvp_com_pkg as

function get_debt_level(
    i_account_id            in com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_tiny_id;

function get_main_card_id (
    i_account_id  in     com_api_type_pkg.t_account_id
  , i_split_hash  in     com_api_type_pkg.t_tiny_id     default null
) return com_api_type_pkg.t_medium_id;

function current_fee_debt (
    i_account_id  in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec;

function current_interest_debt (
    i_account_id  in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec;

function current_main_debt (
    i_account_id  in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec;

procedure get_cash_limit_value(
    i_account_id       in     com_api_type_pkg.t_account_id
  , i_split_hash       in     com_api_type_pkg.t_tiny_id
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_date             in     date default get_sysdate
  , o_value               out com_api_type_pkg.t_money
  , o_current_sum         out com_api_type_pkg.t_money
);

procedure get_card_credit_limits_current(
    i_card_id          in     com_api_type_pkg.t_account_id
  , i_split_hash       in     com_api_type_pkg.t_tiny_id    default null
  , i_mask_error       in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , o_value               out com_api_type_pkg.t_money
  , o_current_sum         out com_api_type_pkg.t_money
  , o_value_cash          out com_api_type_pkg.t_money
  , o_current_sum_cash    out com_api_type_pkg.t_money
);

function check_set_product_attr(
    i_product_id       in     com_api_type_pkg.t_short_id
  , i_attr_name        in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean;

function check_reversal_oper 
return com_api_type_pkg.t_boolean;

function check_reversal_orn_oper 
return com_api_type_pkg.t_boolean;

function format_amount (
    i_amount              in     com_api_type_pkg.t_money
  , i_curr_code           in     com_api_type_pkg.t_curr_code
  , i_add_curr_name       in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator       in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name;

end cst_lvp_com_pkg;
/
