create or replace package acc_api_balance_pkg is
/*********************************************************
 *  API for account balances <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 28.10.2010 <br />
 *  Module: acc_api_balance_pkg  <br />
 *  @headcom
 **********************************************************/

procedure get_account_balances(
    i_account_id          in     com_api_type_pkg.t_account_id
  , o_balances               out com_api_type_pkg.t_amount_by_name_tab
  , i_lock_balances       in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
);

procedure get_account_balances(
    i_account_id          in     com_api_type_pkg.t_account_id
  , o_balances               out com_api_type_pkg.t_amount_by_name_tab
  , o_balance                out com_api_type_pkg.t_money
  , i_lock_balances       in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
);

procedure get_account_balance(
    i_account_id          in     com_api_type_pkg.t_account_id
  , o_account_balance        out com_api_type_pkg.t_money
  , o_account_currency       out com_api_type_pkg.t_curr_code
);

function get_balance_amount (
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_balance_type        in     com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
  , i_lock_balance        in     com_api_type_pkg.t_boolean     := com_api_type_pkg.TRUE
) return com_api_type_pkg.t_amount_rec;

function get_balance_amount(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_balance_type        in     com_api_type_pkg.t_dict_value
  , i_date                in     date
  , i_date_type           in     com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
  , i_inst_id             in     com_api_type_pkg.t_inst_id     := null
) return com_api_type_pkg.t_amount_rec;

function get_aval_balance_amount(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_date                in     date
  , i_date_type           in     com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) return com_api_type_pkg.t_amount_rec;

procedure get_object_accounts_balance(
    i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_rate_type           in     com_api_type_pkg.t_dict_value
  , i_conversion_type     in     com_api_type_pkg.t_dict_value
  , o_available              out com_api_type_pkg.t_money
);

function get_update_macros_type (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_balance_type        in     com_api_type_pkg.t_dict_value
  , i_raise_error         in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) return com_api_type_pkg.t_tiny_id;

function get_aval_balance_amount_only (
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_date                in     date
  , i_date_type           in     com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) return com_api_type_pkg.t_money;

function get_aval_balance_amount(
    i_account_id          in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec;

function get_aval_balance_amount_only(
    i_account_id          in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money;

end;
/
