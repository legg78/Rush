create or replace package dpp_api_payment_plan_pkg as
/*********************************************************
*  API for deferred payment plan <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_API_PAYMENT_PLAN_PKG <br />
*  @headcom
**********************************************************/

-- Exception is generated in the case of any error on calculating instalments by some algorithm
e_unable_to_calculate_dpp               exception;

-- Exception is generated in the case when acceleration/restructuring is actually full repayment,
-- it is not the error and used to stop further calculations
e_stop_on_full_repayment                exception;

procedure get_saved_attribute_value(
    i_attr_name               in     com_api_type_pkg.t_name
  , i_dpp_id                  in     com_api_type_pkg.t_long_id
  , o_value                      out number
  , i_mask_error              in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
);

procedure get_saved_attribute_value(
    i_attr_name               in     com_api_type_pkg.t_name
  , i_dpp_id                  in     com_api_type_pkg.t_long_id
  , o_value                      out varchar2
  , i_mask_error              in     com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
);

function get_days_in_year
return com_api_type_pkg.t_tiny_id;

function get_year_percent_in_fraction(
    i_fee_id                  in     com_api_type_pkg.t_short_id
) return          com_api_type_pkg.t_money;

function get_period_rate(
    i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_rate_algorithm          in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_rate;

/*
 * Function returns a collection with DPPs for specified account that are ordered by date of creation.
 */
function get_dpp(
    i_account_id              in     com_api_type_pkg.t_account_id
) return dpp_api_type_pkg.t_dpp_tab;

function get_dpp(
    i_dpp_id                  in      com_api_type_pkg.t_account_id
  , i_mask_error              in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return dpp_api_type_pkg.t_dpp;

function get_dpp(
    i_oper_id                 in      com_api_type_pkg.t_long_id
  , i_mask_error              in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return dpp_api_type_pkg.t_dpp;

procedure prepare_instalments(
    i_dpp                     in            dpp_api_type_pkg.t_dpp_program
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_eff_date                in            date
  , i_first_payment_date      in            date
);

/*
 * This procedure checks if a restructuring/acceleration leads to full instalment plan repayment,
 * on success check it processes this case and throws a special exception <e_stop_due_to_full_repayment>
 * to stop further calculations in instalment calculation algorithm-procedures;
 * in case of registering it does nothing because <i_debt_rest> is equal to DPP amount so always greater than 0.
 */
procedure check_full_repayment(
    io_dpp                    in out        dpp_api_type_pkg.t_dpp_program
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_debt_rest               in            com_api_type_pkg.t_money
);

procedure check_advanced_repayment(
    io_dpp                    in out nocopy dpp_api_type_pkg.t_dpp_program
  , i_amount                  in            com_api_type_pkg.t_money
  , i_eff_date                in            date
);

/*
 * Procedure calculates instalment payments by incoming parameters of DPP.
 * To calculate instalments the following DPP parameters should be always defined:
 * a) total DPP amount without fee (io_dpp.dpp_amount);
 * b) fee/interest percent rate (io_dpp.repcent_rate);
 * c) calculation algorithm - DPP_ALGORITHM_DIFFERENTIATED or DPP_ALGORITHM_ANNUITY.
 * Also it is necessary to define either COUNT of instalments (io_dpp.instalment_count)
 * or AMOUNT of an instalment (io_dpp.instalment_amount);
 * if a COUNT is defined, an AMOUNT may be calculated, and vise versa.
 * NOTE:
 * 3rd algorithm DPP_ALGORITHM_FIXED_AMOUNT is actually the special case of more general algorithm
 * DPP_ALGORITHM_ANNUITY, since it provides annuity calculation with a given AMOUNT only (COUNT
 * is calculated). At the same time algorithm DPP_ALGORITHM_ANNUITY allows to make annuity
 * calculation 2 different ways - with given AMOUNT or with given COUNT.
 * Therefore, DPP_ALGORITHM_FIXED_AMOUNT + AMOUNT == DPP_ALGORITHM_ANNUITY + AMOUNT
 * but combination DPP_ALGORITHM_FIXED_AMOUNT + COUNT is forbidden (and meaningless) so that
 * DPP_ALGORITHM_ANNUITY + COUNT should be used instead.
 * @i_first_amount - amount of the first instalment payment, it is used in case of DPP acceleration,
                     the rest instalments are calculated by given algorithm
 * @io_instalments - result array with amounts of instalment payments,
                     in case of DPP registration it is outgoing parameter only,
                     in case of DPP acceleration is contains pre-calculated lengths of instalment
                     periods in days
 */
procedure calc_instalments(
    io_dpp                    in out        dpp_api_type_pkg.t_dpp_program
  , i_first_amount            in            com_api_type_pkg.t_money
  , io_instalments            in out nocopy dpp_api_type_pkg.t_dpp_instalment_tab
  , i_first_payment_date      in            date default null
);

/*
 * Bulk registering a new DPP.
 * @i_dpp_tab   - collection-parameter: array of dpp_api_type_pkg.t_dpp_tab
 */
procedure register_dpp(
    i_dpp_tab                 in     dpp_api_type_pkg.t_dpp_tab
);

/*
 * Registering a new DPP.
 */
procedure register_dpp(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_dpp_algorithm           in     com_api_type_pkg.t_dict_value
  , i_instalment_count        in     com_api_type_pkg.t_tiny_id
  , i_instalment_amount       in     com_api_type_pkg.t_money
  , i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_percent_rate            in     com_api_type_pkg.t_money       default null
  , i_first_payment_date      in     date                           default null
  , i_dpp_amount              in     com_api_type_pkg.t_money
  , i_dpp_currency            in     com_api_type_pkg.t_curr_code
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_param_tab               in     com_api_type_pkg.t_param_tab
  , i_create_reg_oper         in     com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
);

/*
 * Bulk registering a new DPP via XML file.
 * @i_xml          - incoming XML file
 * @i_inst_id      - institution ID
 * @i_sess_file_id - session file ID
 * @o_result       - response XML file with the same structure
 */
procedure register_dpp(
    i_xml              in     xmltype
  , i_inst_id          in     com_api_type_pkg.t_inst_id default null
  , i_sess_file_id     in     com_api_type_pkg.t_long_id default null
  , o_result              out xmltype
);
/*
 * DPP acceleration (repayment).
 * @i_payment_amount    - amount of full/partial early repayment, this amount is used to pay DPP amount
                          partially or entirely;
                          in case of partial repayment, the rest of debt transfromed into new
                          (recalculated) installment payments;
 * @i_new_count         - new count of unpaid installment payments, see <i_acceleration_type>;
 * @i_acceleration_type - acceleraion algorithm that may be one of the following:
 *     DPP_ACCELERT_KEEP_INSTLMT_CNT - keep unchangeable count of unpaid installment payments,
                                       installment amount should be recalculate (reduced);
 *     DPP_ACCELERT_KEEP_INSTLMT_AMT - keep unchangeable installment payment amount,
                                       therefore, count of unpaid installment payments should be reduced;
                                       it is the only one acceleration type that may be used with
                                       algorithm DPP_ALGORITHM_FIXED_AMOUNT (since all others
                                       consider change of instalment payment amount);
 *     DPP_ACCELERT_NEW_INSTLMT_CNT  - change count of unpaid installment payments by <i_new_count> parameter,
                                       it should be less than current count of them (in current realization),
                                       installment amount should be recalculate (reduced);
                                       this algorithm allows undefined <i_payment_amount> so that
                                       DPP acceleration is actually DPP restructuring;
 *     DPP_RESTRUCTURIZATION         - a new (any!) count of unpaid instalment payments is set,
                                       the instalment amount is recalculated automatically,
                                       the amount of early repayment is optional;
 */
procedure accelerate_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_new_count               in     com_api_type_pkg.t_tiny_id        default null
  , i_payment_amount          in     com_api_type_pkg.t_money          default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
);

/*
 * DPP acceleration (repayment) with check absent indebtedness by credit
 * DPP is searched for operation with using external_auth_id field
 */
procedure accelerate_dpp(
    i_external_auth_id        in     com_api_type_pkg.t_attr_name
  , i_new_count               in     com_api_type_pkg.t_tiny_id       default null
  , i_payment_amount          in     com_api_type_pkg.t_money         default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
  , i_check_mad_aging_unpaid  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

/*
 * Accelerating active DPPs for a specified account from oldest to newest ones by spending incoming amount.
 */
procedure accelerate_dpps(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_payment_amount          in     com_api_type_pkg.t_money
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value    default null
);

/*
 * Cancelling a DPP.
 */
procedure cancel_dpp(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
);

procedure add_payment_plan(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_reg_oper_id             in     com_api_type_pkg.t_long_id
  , i_account_id              in     com_api_type_pkg.t_account_id
  , i_card_id                 in     com_api_type_pkg.t_medium_id
  , i_product_id              in     com_api_type_pkg.t_short_id
  , i_oper_date               in     date
  , i_oper_amount             in     com_api_type_pkg.t_money
  , i_oper_currency           in     com_api_type_pkg.t_curr_code
  , i_dpp_amount              in     com_api_type_pkg.t_money
  , i_dpp_currency            in     com_api_type_pkg.t_curr_code
  , i_interest_amount         in     com_api_type_pkg.t_money
  , i_status                  in     com_api_type_pkg.t_dict_value
  , i_instalment_amount       in     com_api_type_pkg.t_money
  , i_instalment_total        in     com_api_type_pkg.t_tiny_id
  , i_instalment_billed       in     com_api_type_pkg.t_tiny_id
  , i_next_instalment_date    in     date
  , i_debt_balance            in     com_api_type_pkg.t_money
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_split_hash              in     com_api_type_pkg.t_tiny_id
  , i_posting_date            in     date
  , i_oper_type               in     com_api_type_pkg.t_dict_value
);

procedure get_dpp_amount(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , o_dpp_amount                 out com_api_type_pkg.t_money
  , o_dpp_currency               out com_api_type_pkg.t_curr_code
);

function get_dpp_amount_only(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_macros_id               in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_money;

/*
 * Creating macroses with bunches on processing an instalment.
 * @i_is_credit_account           - if this flag is NULL, it is necessary to check all parameters <i_credit*>
                                    for compatibility because some combinations are impossible;
 * @i_credit_account_rec          - credit account for the case when there are 2 accounts: instalment and credit ones;
 * @i_credit_macros_type_id       - macros type for principal amount for the case of a separate credit account;
 * @i_credit_macros_intr_type_id  - macros type for interest amount for the case of a separate credit account;
 * @i_credit_repay_macros_type_id - macros type for early repayment amount for the case of a separate credit account;
 */
procedure put_instalment_macros(
    i_oper_id                       in     com_api_type_pkg.t_long_id
  , i_reg_oper_id                   in     com_api_type_pkg.t_long_id
  , i_amount                        in     com_api_type_pkg.t_money
  , i_interest_amount               in     com_api_type_pkg.t_money
  , i_repayment_amount              in     com_api_type_pkg.t_money       default null
  , i_currency                      in     com_api_type_pkg.t_curr_code
  , i_account_rec                   in     acc_api_type_pkg.t_account_rec
  , i_card_id                       in     com_api_type_pkg.t_medium_id
  , i_credit_bunch_type_id          in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_intr_bunch_type_id            in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERDRAFT_REGSTR
  , i_over_bunch_type_id            in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_OVERLIMIT_REGSTR
  , i_lending_bunch_type_id         in     com_api_type_pkg.t_tiny_id     default dpp_api_const_pkg.BUNCH_TYPE_ID_CREDIT_LENDING
  , i_posting_date                  in     date
  , i_eff_date                      in     date
  , i_macros_type_id                in     com_api_type_pkg.t_tiny_id
  , i_macros_intr_type_id           in     com_api_type_pkg.t_tiny_id
  , i_repay_macros_type_id          in     com_api_type_pkg.t_tiny_id     default null
  , i_is_credit_account             in     com_api_type_pkg.t_boolean     default null
  , i_credit_account_rec            in     acc_api_type_pkg.t_account_rec default null
  , i_credit_macros_type_id         in     com_api_type_pkg.t_tiny_id     default null
  , i_credit_macros_intr_type_id    in     com_api_type_pkg.t_tiny_id     default null
  , i_credit_repay_macros_type_id   in     com_api_type_pkg.t_tiny_id     default null
  , o_macros_id                        out com_api_type_pkg.t_long_id
  , o_macros_intr_id                   out com_api_type_pkg.t_long_id
);

procedure get_amount_to_cancel(
    i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_inst_id                 in     com_api_type_pkg.t_inst_id  default null
  , i_eff_date                in     date                        default null
  , i_rest_amount             in     com_api_type_pkg.t_money    default null
  , i_fee_id                  in     com_api_type_pkg.t_short_id default null
  , i_last_bill_date          in     date                        default null
  , o_amount                     out com_api_type_pkg.t_money
  , o_interest_amount            out com_api_type_pkg.t_money
);

/*
 * Function for calculation fee rate by rate algorithm, only for type
 * of the rate calculation: FEEM0001 - Percentage value;
 * only for base of calculation: FEEB0001 - Incoming amount;
 * only for incoming amount currency = fee amount currency;
 * only for having length type or cycle.
 * @params: i_nominal_rate_alg  - Value from dictionary DPPR;
 *          i_fee_id            - Fee identificator;
 *          i_incoming_amount   - Value of the incoming amount (optional);
 *          i_incoming_currency - Currency of the incoming amount (optional);
 *          i_mask_error        - Hide or not the application error;
 */
function get_year_percent_rate(
    i_rate_algorithm          in      com_api_type_pkg.t_dict_value
  , i_fee_id                  in      com_api_type_pkg.t_short_id
  , i_incoming_amount         in      com_api_type_pkg.t_money            default null
  , i_incoming_currency       in      com_api_type_pkg.t_curr_code        default null
  , i_mask_error              in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money;

function check_balances_exist(
    i_account_id              in     com_api_type_pkg.t_account_id
  , i_mask_error              in     com_api_type_pkg.t_boolean           default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean;

/*
 * Bulk registering a new DPP via XML file (CLOB).
 * @i_xml          - incoming XML file
 * @i_inst_id      - institution ID
 * @i_sess_file_id - session file ID
 * @o_result       - response XML file with the same structure (CLOB)
 */
procedure register_dpp(
    i_xml                     in     clob
  , i_inst_id                 in     com_api_type_pkg.t_inst_id default null
  , i_sess_file_id            in     com_api_type_pkg.t_long_id default null
  , o_result                     out clob
);

function get_dpp(
    i_reg_oper_id             in      com_api_type_pkg.t_long_id
  , i_mask_error              in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return dpp_api_type_pkg.t_dpp;

procedure get_period_rates(
    i_fee_id                  in     com_api_type_pkg.t_short_id
  , i_rate_algorithm          in     com_api_type_pkg.t_dict_value
  , o_period_percent_rate        out com_api_type_pkg.t_rate
  , o_day_percent_rate           out com_api_type_pkg.t_rate
);

/*
 * Function returns a separate credit account (different compared to <i_account>) of the same customer.
 */
function get_separate_credit_account(
    i_account                 in     acc_api_type_pkg.t_account_rec
) return acc_api_type_pkg.t_account_rec;

end;
/
