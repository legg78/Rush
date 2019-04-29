create or replace package crd_invoice_pkg as

procedure create_invoice(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_calculate_apr     in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

function get_last_invoice_id(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_eff_date          in      date
) return com_api_type_pkg.t_medium_id;

function get_last_invoice_id(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id;

function get_last_invoice(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return crd_api_type_pkg.t_invoice_rec;

function get_last_invoice(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return crd_api_type_pkg.t_invoice_rec;

function get_last_invoice_date(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return date;

function get_account_id(
    i_invoice_id        in      com_api_type_pkg.t_account_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id;

/*
 * Function returns minimum MAD, if a minimum threshold is specified and incoming MAD is under this threshold.
 */
function get_min_mad(
    i_mandatory_amount_due  in            com_api_type_pkg.t_money
  , i_total_amount_due      in            com_api_type_pkg.t_money
  , i_account_id            in            com_api_type_pkg.t_medium_id
  , i_eff_date              in            date
  , i_currency              in            com_api_type_pkg.t_curr_code
  , i_product_id            in            com_api_type_pkg.t_short_id
  , i_service_id            in            com_api_type_pkg.t_short_id
  , i_param_tab             in out nocopy com_api_type_pkg.t_param_tab
  , i_split_hash            in            com_api_type_pkg.t_tiny_id       default null
  , i_inst_id               in            com_api_type_pkg.t_inst_id       default null
) return com_api_type_pkg.t_money;

/*
 * Procedure calculates difference between actual MAD (i_mandatory_amount_due) and new MAD (i_modified_mad),
 * then it redistibutes this difference (+/-) among all debts in order of repayment priority.
 */
procedure recalculate_mad(
    i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_mandatory_amount_due  in      com_api_type_pkg.t_money
  , i_modified_mad          in      com_api_type_pkg.t_money
  , i_update_invoice        in      com_api_type_pkg.t_boolean
);

/*
 * Procedure returns total outstanding (instant TAD) on the specified date.
 */
procedure calculate_total_outstanding(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_payoff_date           in      date
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
  , i_apply_exponent        in      com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
  , o_due_balance              out  com_api_type_pkg.t_money
  , o_accrued_interest         out  com_api_type_pkg.t_money
  , o_closing_balance          out  com_api_type_pkg.t_money
  , o_own_funds_balance        out  com_api_type_pkg.t_money
  , o_unsettled_amount         out  com_api_type_pkg.t_money
  , o_interest_tab             out  crd_api_type_pkg.t_interest_tab
);

function calculate_total_outstanding(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_payoff_date           in      date
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
  , i_apply_exponent        in      com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_money;

function round_up_mad(
    i_account               in      acc_api_type_pkg.t_account_rec
  , i_mad                   in      com_api_type_pkg.t_money
  , i_tad                   in      com_api_type_pkg.t_money         default null
  , i_eff_date              in      date                             default null
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
) return com_api_type_pkg.t_money;

function round_up_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_mad                   in      com_api_type_pkg.t_money
  , i_tad                   in      com_api_type_pkg.t_money         default null
  , i_eff_date              in      date                             default null
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
) return com_api_type_pkg.t_money;

function calc_next_invoice_due_date(
    i_service_id        in      com_api_type_pkg.t_short_id      default null
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return date;

function get_invoice(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return crd_api_type_pkg.t_invoice_rec;

function get_aging_period(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_tiny_id;

function get_converted_aging_period(
    i_aging_period          com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name;

procedure update_invoice_aging(
    i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_aging_period      in      com_api_type_pkg.t_tiny_id
);

procedure add_aging_history(
    i_invoice           in      crd_api_type_pkg.t_invoice_rec
  , i_eff_date          in      date
);

procedure calculate_agings(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_invoice_id        in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_aging_algorithm   in      com_api_type_pkg.t_dict_value default null
);

procedure switch_aging_cycle(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

/*
 * Function returns MAD threshold.
 */
function get_mad_threshold(
    i_account           in     acc_api_type_pkg.t_account_rec
  , i_product_id        in     com_api_type_pkg.t_short_id
  , i_service_id        in     com_api_type_pkg.t_short_id
  , i_params            in     com_api_type_pkg.t_param_tab
  , i_eff_date          in     date
) return com_api_type_pkg.t_money;

end;
/
