create or replace package acc_cst_balance_pkg is

function get_aval_balance_amount (
    i_account_id            in com_api_type_pkg.t_account_id
  , i_date                  in date
  , i_date_type             in com_api_type_pkg.t_dict_value
  , i_aval_algorithm        in com_api_type_pkg.t_dict_value
  , i_split_hash            in com_api_type_pkg.t_tiny_id      
  , i_currency              in com_api_type_pkg.t_curr_code
  , i_mask_error            in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE      
) return com_api_type_pkg.t_amount_rec;

function get_aval_balance_amount (
    i_account_id            in com_api_type_pkg.t_account_id
    , i_aval_algorithm      in com_api_type_pkg.t_dict_value
    , i_split_hash          in com_api_type_pkg.t_tiny_id      
    , i_currency            in com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_amount_rec;

function get_balance_amount (
    i_account_id            in com_api_type_pkg.t_account_id
    , i_balance_algorithm   in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_money;

procedure get_account_balances (
    i_account_id            in com_api_type_pkg.t_account_id
    , o_balances            out com_api_type_pkg.t_amount_by_name_tab
    , o_account_balance     out com_api_type_pkg.t_money
    , o_account_currency    out com_api_type_pkg.t_curr_code
    , i_lock_balances       in com_api_type_pkg.t_boolean
);

end;
/
