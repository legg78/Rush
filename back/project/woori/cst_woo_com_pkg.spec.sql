create or replace package cst_woo_com_pkg as
/************************************************************
 * Common functions for batch files of Woori bank  <br />
 * Created by:
    Chau Huynh (huynh@bpcbt.com)
    Man Do     (m.do@bpcbt.com)  at 2017-03-03   $ <br />
 * Last changed by $Author: Man Do               $ <br />
 * $LastChangedDate:        2017-09-01 15:00     $ <br />
 * Revision: $LastChangedRevision:  455          $ <br />
 * Module: cst_woo_com_pkg                         <br />
 * @headcom
 *************************************************************/

/*
 * Get the start day and end day of the input month
 * @param  i_date           i_date is null, current month will be get
 */
function get_cur_month(
    i_date                  in      date    default null
) return com_api_type_pkg.t_date_tab        deterministic;

/*
 * Get first valid overdue date
 * @param  i_account_id     account ID
 * @param  i_split_hash
 */
function get_first_overdue_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return date;

/*
 * Get payment date
 * @param  i_account_id     account ID
 * @param  i_split_hash
 */
function get_payment_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return date;

/*
 * Get payment date for a specific debt
 * @param  i_debt_id     debt ID
 * @param  i_balance_type
 */
function get_debt_payment_date(
    i_debt_id               in com_api_type_pkg.t_long_id
  , i_balance_type          in com_api_type_pkg.t_dict_value    default null
) return date;

/*
 * Get total tad/mad repayment for a specific invoice
 * @param  i_invoice_id
 * @param  i_is_tad
*/
function get_mad_tad_payment(
    i_invoice_id            in com_api_type_pkg.t_long_id
  , i_is_tad                in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_money;

/*
 * Get billing date before the first overdue date
 * @param  i_account_id     account ID
 * @param  i_split_hash
 */
function get_fist_request_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return date;

/*
 * Get annual fee
 * @param  i_account_id     account ID
 * @param  i_split_hash
 */
function get_annual_fee(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money;

/*
 * Get penalty fee when overdue
 * @param  i_account_id     account ID
 * @param  i_split_hash
 * @param  i_is_dom         1: dom - 0: oversea - null: all
 * @param  i_is_dpp         1: dpp - 0: non_dpp - null: all
 * @param  i_trx_type
 */
function get_overdue_fee(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in      com_api_type_pkg.t_boolean       default null
  , i_trx_type              in      com_api_type_pkg.t_dict_value    default null
  , i_bill_date             in      date                             default null
) return com_api_type_pkg.t_money;

/*
 * Get overdue amount per account/transaction/ domestic or intenational
 * @param  i_account_id     account ID
 * @param  i_split_hash
 * @param  i_is_dom         1: dom - 0: oversea - null: all
 * @param  i_trx_type       transaction type
 */
function get_overdue_amt(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_trx_type              in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money;

/*
 * Get transaction fee per account/transaction/fee type/ domestic or intenational/ period of date
 * @param  i_account_num
 * @param  i_split_hash
 * @param  i_oper_typ
 * @param  i_fee_typ
 * @param  i_is_dom         1: dom - 0: oversea - null: all
 * @param  i_start_date
 * @param  i_end_date
 */
function get_tran_fee(
    i_account_num           in      com_api_type_pkg.t_account_number
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_oper_typ              in      com_dict_tpt
  , i_fee_typ               in      com_api_type_pkg.t_dict_value
  , i_is_dom                in      com_api_type_pkg.t_boolean
  , i_start_date            in      date                             default null
  , i_end_date              in      date                             default null
) return com_api_type_pkg.t_money;

/*
 * Get total debt of an account
 * @param  i_account_id     account ID
 */
function get_total_debt(
    i_account_id            in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money;

/*
 * Get overdue interest per account/ domestic or intenational/ dpp/ trnx type
 * @param  i_account_id     account ID
 * @param  i_split_hash
 * @param  i_is_dom         1: dom - 0: oversea - null: all
 * @param  i_is_dpp         1: dpp - 0: non_dpp - null: all
 * @param  i_trx_type
 */
function get_overdue_interest(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in      com_api_type_pkg.t_boolean       default null
  , i_trx_type              in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money;

 /*
  * Get principal of Domestic non DPP to be billed, by default current month
  * @param  i_account_id
  * @param  i_split_hash
  * @param  i_is_dom        1: dom - 0: oversea - null: all
  * @param  i_is_dpp        1: dpp - 0: non_dpp - null: all
  * @param  i_start_date
  * @param  i_end_date
  */
function get_bill_amt(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in      com_api_type_pkg.t_boolean       default null
  , i_start_date            in      date                             default null
  , i_end_date              in      date                             default null
) return com_api_type_pkg.t_money;

/*
 * Get principal of Domestic cash advance to be billed,  by default current month
 * @param  i_account_id     account ID
 * @param  i_split_hash
 * @param  i_is_dom         1: dom - 0: oversea - null: all
 * @param  i_start_date
 * @param  i_end_date
 */
function get_cash_advance(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_is_dom                in      com_api_type_pkg.t_boolean       default null
  , i_start_date            in      date                             default null
  , i_end_date              in      date                             default null
) return com_api_type_pkg.t_money;

/*
 * Get partner id of loyalty card
 * @param  i_account_id     account ID
 * @param  i_split_hash
 */
function get_loyalty_external_num(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name;

/*
 * Get lastest change status
 * @param  i_event_type_tab
 * @param  i_object_id
 * @param  o_status
 * @param  o_eff_date
 */
procedure get_latest_change_status(
    i_event_type_tab        in      com_dict_tpt
  , i_object_id             in      com_api_type_pkg.t_long_id
  , o_status                    out com_api_type_pkg.t_dict_value
  , o_eff_date                  out date
);

/*
 * Get lastest change status
 * @param  i_event_type_tab
 * @param  i_object_id
 * @param  o_status
 * @param  o_eff_date
 */
function get_latest_change_status_dt(
    i_event_type_tab        in      com_dict_tpt
  , i_object_id             in      com_api_type_pkg.t_long_id
) return date;

/*
 * Get date from string yymm
 * @param  i_date
 */
function date_yymm(
    i_date                  in      com_api_type_pkg.t_date_short
) return date;

/*
 * Get date from string yymmdd
 * @param  i_date
 */
function date_yymmdd(
    i_date                  in      com_api_type_pkg.t_date_short
) return date;

/*
 * Get date from string yymmddhhmmss
 * @param  i_date
 */
function date_yymmddhhmmss(
    i_date                  in      com_api_type_pkg.t_date_long
) return date;

/*
 * Mapping value between CBS to SV
 * @param  i_code           input SV or CBS code
 * @param  i_array_id       defined map array in UI
 * @param  i_in_out         1 -> get SV value from CBS, 0 -> get CBS value from SV
 * @param  i_language
 */
function get_mapping_code(
    i_code                  in      com_api_type_pkg.t_attr_name
  , i_array_id              in      com_api_type_pkg.t_short_id
  , i_in_out                in      com_api_type_pkg.t_boolean       default 1
  , i_language              in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_name;

/*
 * Get customer type ENTTPERS or ENTTCORP
 * @param  i_customer_num   Customer number
 */
function get_customer_type(
    i_customer_num          in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value;

/*
 * Get product overdue date
 * @param  i_product_id     Product ID
 */
function get_contract_due_date(
    i_product_id            in      com_api_type_pkg.t_short_id
 ) return date;

/*
 * Get product bill date
 * @param  i_product_id     Product ID
 */
function get_contract_bill_date(
    i_product_id            in      com_api_type_pkg.t_short_id
) return date;

/*
 * Get contact type
 * @param  i_customer_id    Customer iD
 * @param  i_commun_method
 */
function get_contact_type(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_commun_method         in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value;

/*
 * Get list of card_uid of customer
 * @param  i_customer_num   Customer number
 */
function get_card_uid(
    i_customer_num          in      com_api_type_pkg.t_cmid
) return num_tab_tpt;

/*
 * Temporary block all cards of customer
 * @param  i_customer_num   Customer number
 */
procedure temp_block_cus_cards(
    i_cus_number            in      com_api_type_pkg.t_cmid
);

/*
 * Permanent block all cards of customer
 * @param  i_customer_num   Customer number
 */
procedure permanent_block_cus_cards(
    i_cus_number            in      com_api_type_pkg.t_cmid
);

/*
 * Get latest credit limit change date
 * @param  i_entity_type
 * @param  i_obj_entity
 */
function get_latest_crd_limit_dt(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_obj_entity            in      com_api_type_pkg.t_name
) return date;

/*
 * Calculate interest on daily basic
 */
function calculate_interest(
    i_account_id            in      com_api_type_pkg.t_long_id
  , i_debt_id               in      com_api_type_pkg.t_long_id      default null
  , i_eff_date              in      date
  , i_period_date           in      date                            default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
  , i_service_id            in      com_api_type_pkg.t_short_id
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_alg_calc_intr         in      com_api_type_pkg.t_dict_value   default crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD
) return com_api_type_pkg.t_money;

/*
 * Get total interest
 */
function get_total_interest(
    i_account_id            in      com_api_type_pkg.t_long_id
  , i_debt_id               in      com_api_type_pkg.t_long_id      default null
  , i_eff_date              in      date
) return com_api_type_pkg.t_money;

/*
 * Get charged interest
 * @param  i_account_id     charged interest per specific account
 * @param  i_debt_id        charged interest per specific debt
 * @param  i_date           charged interest to this date
 */
function get_charged_interest(
    i_account_id            in      com_api_type_pkg.t_long_id      default null
  , i_debt_id               in      com_api_type_pkg.t_long_id      default null
  , i_date                  in      date                            default null
) return com_api_type_pkg.t_money;

/*
 * Get total payment of input bill date cycle
 * @param  i_account_id     account ID
 * @param  i_bill_date      bill date
 * @param  i_spent          1: spent -- 0 not yet
 */
function get_total_payment(
    i_account_id            in      com_api_type_pkg.t_long_id
  , i_bill_date             in      date
  , i_spent                 in      com_api_type_pkg.t_boolean default 1
) return com_api_type_pkg.t_money;

/*
 * Get payment for a specific debt
 * @param  i_debt_id        debt ID
 * @param  i_eff_date       payment effect date
 * @param  i_balance_type   paid balance type
 */
function get_debt_payment(
    i_debt_id               in com_api_type_pkg.t_long_id
  , i_eff_date              in date                             default null
  , i_balance_type          in com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money;

/*
 * Get batch time to get data by time for each batch file
 * @param  i_file_id        file_id defined in package cst_woo_const_pkg
 * @param  o_from_date
 * @param  o_to_date
 */
procedure get_batch_time(
    i_file_id               in      com_api_type_pkg.t_short_id
  , o_from_date                 out date
  , o_to_date                   out date
);

/*
 * Get substring from a raw text data
 * @param  i_string         source string
 * @param  i_position       position of the string
 */
function get_substr(
    i_string                in      com_api_type_pkg.t_text
  , i_position              in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_text;

/*
 * Get limit sum withdraw
 */
function get_limit_sum_withdraw(
    i_object_id             in      com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money;

/*
 * Get latest date that acct peform payment
 */
function get_latest_payment_dt(
    i_account_id            in      com_api_type_pkg.t_long_id
) return date;

/*
 * Set batch time
 * @param  i_file_id         file_id defined in package cst_woo_const_pkg
 * @param  i_status          0=Failed, 1=Successful
 */
procedure set_batch_time (
    i_file_id               in      com_api_type_pkg.t_name
  , i_status                in      com_api_type_pkg.t_sign     default null
);

/*
 * Get fee rate
 * @param  i_fee_id
 */
function get_fee_rate(
    i_fee_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_rate;

/*
 * Get cycle start/end date
 */
function get_cycle_date(
    i_cycle_type            in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
  , i_from_date             in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_to_date               in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return date;

/*
 * Get previous bill tad, mad
 * @param   i_is_tad        FALSE - MAD will be got
 */
function get_previous_mad_tad(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
  , i_is_tad                in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_money;

/*
 * Get previous invoice
 * @param   i_invoice_id    null the second latest invoice will be got
 */
function get_previous_invoice(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_invoice_id            in      com_api_type_pkg.t_medium_id    default null
)  return com_api_type_pkg.t_medium_id;

/*
 * Get application element id
 */
function get_element_id(
    i_element_name          in      com_api_type_pkg.t_name
  , i_appl_id               in      com_api_type_pkg.t_long_id
  , i_serial_number         in      com_api_type_pkg.t_tiny_id       default 1
  , i_language              in      com_api_type_pkg.t_dict_value    default com_api_const_pkg.LANGUAGE_ENGLISH
)return com_api_type_pkg.t_long_id;

/*
 * ATM transaction reconciliation between SV and CBS
 */
procedure reconcile_atm_trans(
    i_start_date            in      date
  , i_end_date              in      date
);

/*
 * Update file header data
 */
procedure update_file_header(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_raw_data              in      com_api_type_pkg.t_raw_data
);

/*
 * Get file attribute ID
 */
function get_file_attribute_id(
    i_file_id               in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id;

/*
 * Get interest latest start caculate date for a debt
 */
function get_interest_start_date(
    i_debt_id               in      com_api_type_pkg.t_long_id  
)return date;

/*
 * Get card expire period via account number
 * @param   account_number 
 */
function get_card_expire_period(
    i_account_number        in      com_api_type_pkg.t_account_number
)return com_api_type_pkg.t_tag;

/*
 * Get customer agent number
 * @param   i_customer_id
 */
function get_agent_number(
    i_customer_id           in      com_api_type_pkg.t_medium_id
)return com_api_type_pkg.t_name;

/*
 * Get customer addr home is first priority, business is second priority
 */
function get_customer_address(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_language              in      com_api_type_pkg.t_dict_value    default null
)return com_api_type_pkg.t_full_desc;

/*
 * Reconcile offline fees file 137, 138
 * @param   i_file_name: loading file name from CBS
 */
procedure reconcile_offline_fees(
    i_file_name             in      com_api_type_pkg.t_name
)
;
/*
 * Start batch file processing
 * @param   i_file_id: batch file ID
 * @param   i_start_date: start date of batch file processing, it equals to end date of data range plus one second, it equals sysdate if empty
 * @param   o_from_date: beginning date of data range
 */
procedure start_batch_process (
    i_file_id       in     com_api_type_pkg.t_short_id
  , i_start_date    in out date
  , o_from_date        out date
);

/*
 * Stop batch file processing
 * @param   i_file_id: batch file ID
 * @param   i_stop_date: stop date of batch file processing, it equals sysdate if empty
 * @param   i_status: final status of processing
 */
procedure stop_batch_process (
    i_file_id       in     com_api_type_pkg.t_short_id
  , i_stop_date     in     date
  , i_status        in     com_api_type_pkg.t_boolean
);

/*
 * Get projected interest of an invoice
 * @param   i_invoice_id: Invoice ID
 */
function get_invoice_project_interest(
    i_invoice_id    in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_money;

/*
 * Get CIC city code (2 digits) by customer ID
 * @param   i_customer_id: Customer ID
 * @param   i_lang: Language 
 */
function get_customer_city_code(
    i_customer_id   in      com_api_type_pkg.t_medium_id
  , i_lang          in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_dict_value;

/*
 * Get daily interest after invoice
 * @param   i_invoice_id: Invoice ID
 * @param   i_split_hash 
 */
function get_interest_after_invoice(
    i_invoice_id  in com_api_type_pkg.t_medium_id
  , i_split_hash  in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money;

/*
 * Get daily interest information via deb_id
 * @param   i_debt_id: debt ID
 * @param   i_intr_type: interest type
                1: interest of overdraft
                2: interest of overdue
 * @param   i_info_type: 
                1: interest start date
                2: interest end date
                3: debt amount
                4: interest amount
                5: interest balance amount
                6: sum of interest amount from start date to end date
                7: fee_id
 * @param   i_end_date: interest end date
 */
function get_daily_interest_by_debt(
    i_debt_id       in      com_api_type_pkg.t_medium_id
  , i_intr_type     in      com_api_type_pkg.t_tiny_id    
  , i_info_type     in      com_api_type_pkg.t_tiny_id
  , i_end_date      in      date    default null
) return com_api_type_pkg.t_text;

/*
 * Get dispute amount via invoice ID
 * @param   i_invoice_id: invoice ID
 * @param   i_is_tad: true(1) return TAD amount
                      false(0) return MAD amount
 */
function get_dispute_amount(
    i_invoice_id            in  com_api_type_pkg.t_long_id
  , i_is_tad                in  com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_money;

/*
 * Get TAD amount via invoice ID as Woori bank's requirement
 * @param   i_invoice_id: invoice ID
 * @param   i_to_date   : To date
 */
function get_tad_by_invoice(
    i_invoice_id    in      com_api_type_pkg.t_medium_id
  , i_to_date       in      date    default null
) return com_api_type_pkg.t_money;

/*
 * Get MAD amount via invoice ID as Woori bank's requirement
 * @param   i_invoice_id: invoice ID
 * @param   i_to_date   : To date
 */
function get_mad_by_invoice(
    i_invoice_id    in      com_api_type_pkg.t_medium_id
  , i_to_date       in      date    default null
) return com_api_type_pkg.t_money;

/*
 * Get overdue date as Woori bank's requirement
 * @param   i_account_id: Account ID
 * @param   i_split_hash: Split hash value
 */
function get_overdue_date(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
) return date;

-- Returns com_api_const_pkg.TRUE if invoice consists only of fees FETP0102 (annual card fee) and FETP1003 (penalty rate fee),
-- com_api_const_pkg.FALSE in other case
function check_invoice_has_only_fees (
    i_account_id    in  com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

end cst_woo_com_pkg;
/
