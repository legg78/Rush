create or replace package cst_apc_crd_algo_proc_pkg as
/*********************************************************
*  Asia Pacific specific credit algorithms procedures and related API <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 20.12.2018 <br />
*  Module: CST_APC_CRD_ALGO_PROC_PKG <br />
*  @headcom
**********************************************************/

/*
 * Function returns an Extra MAD for the last invoice.
 */
function get_extra_mad(
    i_invoice_id            in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_money;

/*
 * Procedure sets new skip MAD date.
 * @i_invoice_date - date is used for calculating the following invoice date I;
 * @i_cycle_type   - is used to calculate next date S from date I;
 * @i_skip_mad_window - window in days, it is used to set skip MAD date as (S - i_skip_mad_window).
 */
procedure set_skip_mad_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_invoice_date          in      date                             default null
  , i_cycle_type            in      com_api_type_pkg.t_dict_value
  , i_skip_mad_window       in      com_api_type_pkg.t_tiny_id
);

/*
 * Returns current Extra due date, it is applicable for MAD algotithm ALGORITHM_MAD_CALC_TWO_MADS only.
 */
function get_extra_due_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
) return date;

procedure switch_extra_due_cycle(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date                             default null
  , i_start_date            in      date                             default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id       default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id       default null
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
  , o_new_extra_due_date       out  date
);

/*
 * Procedure calculates value of Daily MAD, it is applicable for MAD algotithm ALGORITHM_MAD_CALC_TWO_MADS only.
 */
procedure calculate_daily_mad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date                             default null
  , i_product_id            in      com_api_type_pkg.t_short_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id      default null
  , i_check_mad_algorithm   in      com_api_type_pkg.t_boolean       default null
  , i_use_rounding          in      com_api_type_pkg.t_boolean       default null
  , o_daily_mad                out  com_api_type_pkg.t_money
  , o_skip_mad                 out  com_api_type_pkg.t_boolean
  , o_extra_due_date           out  date
);

-- Algorithms procedures

/*
 * MAD modification procedure, it is intended to be used as a algorithm procedure
 * with MAD calculation algorithm ALGORITHM_MAD_CALC_TWO_MADS.
 */
procedure mad_algorithm_two_mad;

/*
 * Implement specific actions for algorithm ALGORITHM_MAD_CALC_TWO_MADS:
 * a) if Extra MAD (MAD 1) is being repaid, make MAD equal to Extra MAD to force its repayment on checking overdue;
 * b) for overdue account, if total outstanding is repaid, register an event to allow reset of current aging period;
 * c) if daily MAD is repaid within a single day in specified time interval, check the account for skipping MAD.
 */
procedure check_mad_repayment;

/*
 * For algorithm MAD 1/MAD 2 it is necessary to repay entire current TAD to reset aging period,
 * that's why MAD_REPAYMENT_EVENT should be ignored, and aging period is reseted by TAD_REPAYMENT_EVENT.
 */
procedure check_reset_aging;

/*
 * MAD modification procedure, it is intended to be used as an algorithm procedure
 * with MAD calculation algorithm ALGORITHM_MAD_CALC_TWO_MADS on checking overdue.
 */
procedure recalculate_mad;

/*
 * Additional information for using on GUI (form Account, tab Credit details) due to specific MAD algorithm.
 */
procedure get_additional_ui_info;

end;
/
