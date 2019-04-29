create or replace package dpp_ui_payment_plan_pkg as
/*********************************************************
*  User interface for instalment plan (DPP). <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_UI_PAYMENT_PLAN_PKG <br />
*  @headcom
**********************************************************/

procedure accelerate_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_new_count               in     com_api_type_pkg.t_tiny_id            default null
  , i_payment_amount          in     com_api_type_pkg.t_money              default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
);

procedure cancel_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
);

procedure register_dpp(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id
  , i_fee_id                  in     com_api_type_pkg.t_money
  , i_dpp_amount              in     com_api_type_pkg.t_money
  , i_dpp_currency            in     com_api_type_pkg.t_curr_code          default null
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_dpp_algorithm           in     com_api_type_pkg.t_dict_value         default null
);

procedure get_dpp_amount(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , o_dpp_amount                 out com_api_type_pkg.t_money
  , o_dpp_currency               out com_api_type_pkg.t_curr_code
);

function get_amount_to_cancel(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , i_eff_date                in     date                                  default null
  , i_rest_amount             in     com_api_type_pkg.t_money              default null
  , i_fee_id                  in     com_api_type_pkg.t_short_id           default null
  , i_last_bill_date          in     date                                  default null
) return com_api_type_pkg.t_money;

/*
 * Calculate instalment payments for some specified fee ID.
 */
procedure calculate_dpp(
    i_dpp_amount              in     com_api_type_pkg.t_money
  , i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id            default null
  , i_instalment_period       in     com_api_type_pkg.t_tiny_id            default null
  , i_instalment_amount       in     com_api_type_pkg.t_money              default null
  , i_first_instalment_date   in     date                                  default null
  , i_calc_algorithm          in     com_api_type_pkg.t_dict_value         default null
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , i_first_cycle_id          in     com_api_type_pkg.t_short_id           default null
  , i_main_cycle_id           in     com_api_type_pkg.t_short_id           default null
  , o_dpp                        out dpp_api_type_pkg.t_dpp_program
  , o_instalments                out dpp_api_type_pkg.t_dpp_instalment_tab
);

/*
 * Calculate instalment payments for specified merchant using interest rate from fee
 * dpp_api_const_pkg.ATTR_MERCHANT_FEE_ID of service "Deferred payment plan (merchant)".
 */
procedure calculate_dpp(
    i_dpp_amount              in     com_api_type_pkg.t_money
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id            default null
  , i_instalment_amount       in     com_api_type_pkg.t_money              default null
  , i_instalment_period       in     com_api_type_pkg.t_tiny_id            default null
  , i_first_instalment_date   in     date                                  default null
  , i_interest_amount         in     com_api_type_pkg.t_money              default null
  , i_calc_algorithm          in     com_api_type_pkg.t_dict_value         default null
  , i_merchant_number         in     com_api_type_pkg.t_merchant_number    default null
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , o_installment_plan           out clob
);

/*
 * Calculate instalment payments for specified account.
 */
procedure calculate_dpp(
    i_dpp_amount              in     com_api_type_pkg.t_money
  , i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_first_instalment_date   in     date                                  default null
  , io_instalment_count       in out com_api_type_pkg.t_tiny_id
  , io_instalment_amount      in out com_api_type_pkg.t_money
  , io_calc_algorithm         in out com_api_type_pkg.t_dict_value
  , i_account_number          in     com_api_type_pkg.t_account_number
  , i_account_id              in     com_api_type_pkg.t_medium_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id            default null
  , o_interest_rate              out com_api_type_pkg.t_money
  , o_instalments                out sys_refcursor
);

end;
/
