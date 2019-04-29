create or replace package cst_lvp_debt_level_pkg as

procedure set_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
  , i_debt_level          com_api_type_pkg.t_dict_value
  , i_eff_date            date
  , i_reason_event        com_api_type_pkg.t_dict_value
  , i_force               com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
);

procedure incr_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
  , i_eff_date            date
  , i_reason_event        com_api_type_pkg.t_dict_value
);

procedure decr_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
  , i_eff_date            date
  , i_reason_event        com_api_type_pkg.t_dict_value
);

function get_additional_credit_info(
    i_account_id          com_api_type_pkg.t_account_id
)
return  com_api_type_pkg.t_lob_data;

function get_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
)
return  com_api_type_pkg.t_tiny_id;

function get_prev_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
)
return  com_api_type_pkg.t_tiny_id;

function get_debt_level_start_date(
    i_account_id          com_api_type_pkg.t_account_id
)
return date;

end;
/
