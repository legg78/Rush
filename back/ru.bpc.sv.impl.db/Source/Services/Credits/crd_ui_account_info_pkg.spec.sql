create or replace package crd_ui_account_info_pkg as
/************************************************************
* UI-procedures for credit service <br />
* Created by Kolodkina Y.(kolodkina@bpcbt.com) at 30.03.2015 <br />
* Module: CRD_UI_ACCOUNT_INFO_PKG <br />
* @headcom
************************************************************/

/***********************************************************************
 * Returns cursor for credit's state info.
 * @param o_ref_cur       Opened cursor with data
 * @param i_account_id    Account ID
 ***********************************************************************/
procedure get_credit_info(
    o_ref_cur               out com_api_type_pkg.t_ref_cur
  , i_account_id         in     com_api_type_pkg.t_account_id
);

procedure total_debt_calculation(
    i_account_id         in     com_api_type_pkg.t_account_id
  , i_payoff_date        in     date
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

procedure close_credit(
    i_account_id         in     com_api_type_pkg.t_account_id
  , i_eff_date           in     date
);

procedure restructure_to_dpp(
    i_account_id         in     com_api_type_pkg.t_medium_id
  , i_fee_id             in     com_api_type_pkg.t_short_id
  , i_eff_date           in     date
  , i_dpp_algorithm      in     com_api_type_pkg.t_dict_value
  , i_instalments_count  in     com_api_type_pkg.t_tiny_id
);

procedure interest_calculation(
    i_account_id         in     com_api_type_pkg.t_account_id
  , i_start_date         in     date
  , i_end_date           in     date
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

function get_aging_period_name(
    i_aging_period      in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name;

procedure get_operation_debt(
    i_oper_id            in     com_api_type_pkg.t_long_id
  , o_debt_amount           out com_api_type_pkg.t_money
  , o_debt_currency         out com_api_type_pkg.t_curr_code
);

end crd_ui_account_info_pkg;
/
