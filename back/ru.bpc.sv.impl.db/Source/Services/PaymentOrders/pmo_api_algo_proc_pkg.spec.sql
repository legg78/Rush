create or replace package pmo_api_algo_proc_pkg is

procedure clear_shared_data;

function get_dpp            return dpp_api_type_pkg.t_dpp_program;

function get_instalments    return dpp_api_type_pkg.t_dpp_instalment_tab;

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

procedure process_amount_algorithm(
    i_amount_algorithm      in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date
  , i_template_id           in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_order_id              in      com_api_type_pkg.t_long_id
  , io_amount               in out  com_api_type_pkg.t_amount_rec
);

procedure calc_gross_net_order_amount; 

procedure get_entry_order_amount;

procedure calc_attached_oper_amount_sum;

procedure calc_order_amount_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , o_amount                   out  com_api_type_pkg.t_amount_rec
);

procedure calc_order_amount_tad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , o_amount                   out  com_api_type_pkg.t_amount_rec
);

procedure calc_order_amount_tad_ovd_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_eff_date              in      date
  , o_amount                   out  com_api_type_pkg.t_amount_rec
);

procedure calc_direct_debit_amount(
    i_object_id    in      com_api_type_pkg.t_long_id
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_split_hash   in      com_api_type_pkg.t_tiny_id
  , i_eff_date     in      date
  , o_amount          out  com_api_type_pkg.t_amount_rec
);

procedure calc_original_order_amount(
    i_original_order_rec    in      pmo_api_type_pkg.t_payment_order_rec
  , io_amount               in out  com_api_type_pkg.t_amount_rec
);

procedure calc_partial_oper_amount;

end;
/
