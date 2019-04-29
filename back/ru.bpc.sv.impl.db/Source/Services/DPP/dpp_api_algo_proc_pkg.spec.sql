create or replace package dpp_api_algo_proc_pkg is

procedure clear_shared_data;

function get_dpp            return dpp_api_type_pkg.t_dpp_program;

function get_instalments    return dpp_api_type_pkg.t_dpp_instalment_tab;

function get_param_num(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return number;

function get_param_date(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return date;

function get_param_char(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_param_value;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            com_api_type_pkg.t_name
);

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            number
);

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            date
);

procedure set_dpp(
    i_dpp                 in            dpp_api_type_pkg.t_dpp_program
);

procedure set_instalments(
    i_instalments         in            dpp_api_type_pkg.t_dpp_instalment_tab
);

procedure process_algorithm(
    io_dpp                in out        dpp_api_type_pkg.t_dpp_program
  , io_instalments        in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_eff_date            in            date
  , i_first_payment_date  in            date
  , i_debt_rest           in            com_api_type_pkg.t_money
);

-- Algorithms procedures

procedure calc_gih;

procedure calc_balloon;

end;
/
