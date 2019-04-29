create or replace package lty_api_algo_proc_pkg is

procedure clear_shared_data;

function get_param_num(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return number;

function get_param_date(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return date;

function get_param_char(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_name;

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

procedure check_promo_level_turnover;

end;
/
