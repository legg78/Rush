create or replace package crd_interest_pkg as

procedure set_interest(
    i_debt_id           in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_is_forced         in      com_api_type_pkg.t_tiny_id          default com_api_const_pkg.FALSE
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
);

procedure charge_interest(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_period_date       in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
);

procedure grace_period(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure recalc_interest_on_fix_period(
    i_invoice_id               in      com_api_type_pkg.t_long_id
  , i_interest_calc_start_date in      date                         default null
  , i_interest_calc_end_date   in      date                         default null
  , o_recalculation_interest      out  com_api_type_pkg.t_money
  , o_current_interest            out  com_api_type_pkg.t_money
  , o_currency                    out  com_api_type_pkg.t_curr_code
);

function get_interest_start_date(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_posting_date      in      date
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return date;

function get_interest_calc_end_date(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_service_id        in      com_api_type_pkg.t_short_id         default null
) return com_api_type_pkg.t_dict_value;

procedure waive_interest(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

function calculate_accrued_interest(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr     in      com_api_type_pkg.t_dict_value
  , o_interest_tab         out  crd_api_type_pkg.t_interest_tab
) return com_api_type_pkg.t_money;

procedure interest_change(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure change_interest_rate(
    i_account_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure change_interest_rate(
    i_product_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_event_type        in      com_api_type_pkg.t_dict_value
);

end crd_interest_pkg;
/
