create or replace package cst_cfc_com_pkg as
/************************************************************
 * Common functions for CFC bank                            <br />
 * Created by: Chau Huynh (huynh@bpcbt.com) at 2017-11-21   $ <br />
 * Module: CST_CFC_COM_PKG                                  <br />
 * @headcom
 *************************************************************/

function get_substr(
    i_string                in  com_api_type_pkg.t_text
  , i_position              in  com_api_type_pkg.t_tiny_id
  , i_delimiter             in  com_api_type_pkg.t_tag default ','
) return com_api_type_pkg.t_text;

/*
* Get account register date
*/
function get_account_reg_date(
    i_account_id            in  com_api_type_pkg.t_account_id
) return date deterministic;

/*
* Get first transacrion date
*/
function get_first_trx_date(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
)return date deterministic;

/*
* Get limit valid from-to date
* i_is_start, if true return start_date, else return end_date
*/
function get_card_limit_valid_date(
    i_card_id               in  com_api_type_pkg.t_medium_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_is_start              in  com_api_type_pkg.t_boolean
  , i_limit_type            in  com_api_type_pkg.t_dict_value
) return date;

/*
* Get last invoice of input object
* If account has not run invoice, credit service start date will replace invoice_date
*/
function get_last_invoice(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return crd_invoice_tpt;

/*
 * Get number of transactions in a specific period
 * @param  i_entity_type        object's entity type
 * @param  i_object_id          object id
 * @param  i_split_hash         split hash value
 * @param  i_transaction_type   if null, then all trx will be get
 * @param  i_terminal_type      if null, then all terminal will be get
 * @param  i_start_date         if null, then daily
 * @param  i_end_date           if null, then daily
 */
function get_total_trans_count(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
  , i_terminal_type         in  com_api_type_pkg.t_dict_value    default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
) return com_api_type_pkg.t_long_id;

/*
 * Get total amount of transactions in a specific period
 * @param  i_entity_type        object's entity type
 * @param  i_object_id          object id
 * @param  i_split_hash         split hash value
 * @param  i_transaction_type   if null, then all trx will be get
 * @param  i_terminal_type      if null, then all terminal will be get
 * @param  i_start_date         if null, then daily
 * @param  i_end_date           if null, then daily
 */
function get_total_trans_amount(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
  , i_terminal_type         in  com_api_type_pkg.t_dict_value    default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
) return com_api_type_pkg.t_money;

/*
 * Get total payment in a specific period
 * @param  i_account_id     account ID
 * @param  i_spent          1: spent -- 0 not yet
 */
function get_total_payment(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_spent                 in  com_api_type_pkg.t_boolean  default null
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
) return com_api_type_pkg.t_money;

/*
* Get highest bucket in specific period
* @param  i_customer_id        customer id
* @param  i_account_id         if null, will get highest bucket at customer level
* @param  i_split_hash         split hash value
* @param  i_start_date         if null, then current cycle
* @param  i_end_date           if null, then current cycle
*/
function get_highest_bucket(
    i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id   default null
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
) return com_api_type_pkg.t_byte_char;

function get_current_revised_bucket(
    i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id
) return scr_api_type_pkg.t_scr_bucket_rec;

function get_revised_bucket_attr(
    i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id
  , i_attr                  in  varchar2
)return varchar2;

/*
 * Get first valid overdue date
 * @param  i_account_id     account ID
 * @param  i_split_hash
 */
 function get_first_overdue_date(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
) return date;

/*
 * Get total debt of an account
 * @param  i_account_id     account ID
 */
function get_total_debt(
    i_account_id            in  com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money;

/*
 * Get overdue amount
 * For CFC, when an account is overdue, total overdue amount = overdue balance + overdraft balance
 * @param  i_account_id     account ID
 * @param  i_split_hash
 */
function get_overdue_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money;

/* Get total debit amount
* @param  i_start_date         if null, then current cycle
* @param  i_end_date           if null, then current cycle
*/
function get_debit_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
)return com_api_type_pkg.t_money;

/* Get the payment applied on the balance
* @param  i_pay_id
* @param  i_balance_type        if null, then payment on debts
*/
function get_applied_payment(
    i_pay_id                in  com_api_type_pkg.t_long_id
  , i_balance_type          in  com_api_type_pkg.t_dict_value   default null
)return com_api_type_pkg.t_money;

function get_card_expire_date(
    i_card_id               in  com_api_type_pkg.t_medium_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id      default null
)return date;

function get_app_element_v(
    i_appl_id               in com_api_type_pkg.t_long_id
  , i_element_name          in com_api_type_pkg.t_name
)return com_api_type_pkg.t_full_desc;

function get_main_card_id(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id     default null
)return com_api_type_pkg.t_medium_id;

function get_charged_interest(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_debt_id               in  com_api_type_pkg.t_long_id  default null
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
)return com_api_type_pkg.t_money;

function get_total_waived_interest(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_start_date            in  date    default null
  , i_end_date              in  date    default null
)return com_api_type_pkg.t_money;

function get_tran_fee(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
)return com_api_type_pkg.t_money;

function get_service_start_date(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id      default null
  , i_service_type_id       in  com_api_type_pkg.t_short_id
)return date;

function get_balance_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_balance_type          in  com_api_type_pkg.t_dict_value
  , i_is_abs                in  com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
)return com_api_type_pkg.t_money;

function get_total_outstanding_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_money;

/*
 * Get latest payment amount
 * @param  i_account_id     account ID
 */
function get_latest_payment_amount(
    i_account_id            in      com_api_type_pkg.t_long_id
)return com_api_type_pkg.t_money;

/*
 * Get latest date that acct peform payment
 */
function get_latest_payment_dt(
    i_account_id            in  com_api_type_pkg.t_long_id
)return date;

function get_last_trx_date(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_transaction_type      in  com_api_type_pkg.t_dict_value   default null
)return date;

function get_cycle_date(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_cycle_type            in  com_api_type_pkg.t_dict_value
  , i_is_next_date          in  com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
)return date;

function get_interest_rate(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_operation_type        in  com_api_type_pkg.t_dict_value
  , i_is_add_int_rate       in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_is_welcome_rate       in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
)return com_api_type_pkg.t_short_desc;

/*
 * Get lastest change status
 * @param  i_event_type_tab
 * @param  i_object_id
 * @param  o_status
 * @param  o_eff_date
 */
function get_latest_change_status_dt(
    i_event_type_tab        in  com_dict_tpt
  , i_object_id             in  com_api_type_pkg.t_long_id
) return date;

/*
 * Get penalty fee when overdue
 * @param  i_account_id     account ID
 * @param  i_split_hash
 * @param  i_is_dom         1: dom - 0: oversea - null: all
 * @param  i_is_dpp         1: dpp - 0: non_dpp - null: all
 * @param  i_trx_type
 */
function get_overdue_fee(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_is_dom                in  com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in  com_api_type_pkg.t_boolean       default null
  , i_trx_type              in  com_api_type_pkg.t_dict_value    default null
  , i_bill_date             in  date                             default null
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
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_is_dom                in  com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in  com_api_type_pkg.t_boolean       default null
  , i_trx_type              in  com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money;

function get_latest_tran_amt
(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_trx_type              in  com_api_type_pkg.t_dict_value    default null
)return com_api_type_pkg.t_money;

/*
 * Get transaction fee per account/transaction/fee type/ domestic or intenational/ period of date
 * @param  i_account_num
 * @param  i_split_hash
 * @param  i_oper_typ
 * @param  i_fee_typ
 * @param  i_start_date
 * @param  i_end_date
 */
function get_tran_fee(
    i_account_id            in  com_api_type_pkg.t_account_number
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_oper_typ              in  com_dict_tpt                     default null
  , i_fee_typ               in  com_dict_tpt                     default null
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
)return com_api_type_pkg.t_money;

/*
 * Get daily MAD of a specific account
 */
function get_daily_mad(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_use_rounding          in  com_api_type_pkg.t_boolean       default null
)return com_api_type_pkg.t_money;

/*
 * Highest TAD in a period
 */
function get_highest_tad(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_bill_num              in  com_api_type_pkg.t_tiny_id
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
)return com_api_type_pkg.t_money;

/*
* Pricipal amount includes Overdraft and Overdue
*/
function get_principal_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
)return com_api_type_pkg.t_money;

/*
* Get md5hash for input text
* @param i_password  if null, will get based on network
*/
function get_md5hash(
    i_text                  in  com_api_type_pkg.t_text
  , i_password              in  com_api_type_pkg.t_name         default null
  , i_network_id            in  com_api_type_pkg.t_network_id   default cst_cfc_api_const_pkg.NAPAS_NETWORK_ID
)return com_api_type_pkg.t_md5;

/*
* Get limit value of input entity
* @param  i_attr_name type of limit attribute
*/
function get_limit_value(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_attr_name             in  com_api_type_pkg.t_name
)return com_api_type_pkg.t_money;

/*
* Get direct debit info
*/
function get_direct_debit_info(
    i_customer_id           in  com_api_type_pkg.t_medium_id
)return com_api_type_pkg.t_name;

/*
* Get previous contact info
*/
function get_prev_contact_info(
    i_contact_id            in  com_api_type_pkg.t_medium_id
  , i_commun_method         in  com_api_type_pkg.t_dict_value
  , i_start_date            in  date  default null
)return com_api_type_pkg.t_full_desc;

function get_unbill_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_money;

procedure change_event_status(
    i_event_object_id_tab   in  com_api_type_pkg.t_number_tab
  , i_event_status          in  com_api_type_pkg.t_dict_value
);

function get_extra_due_date(
    i_account_id            in  com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_byte_char;

function get_delinquency_str(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_serial_number         in  com_api_type_pkg.t_tiny_id
  , i_month_period          in  com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_name;

/*
 * Get product overdue date
 * @param  i_product_id     Product ID
 */
function get_contract_due_date(
    i_product_id            in  com_api_type_pkg.t_short_id
 ) return date;

 /*
 * Get customer primary phone number
 * @param  i_product_id     Product ID
 */
function get_phone_number(
    i_customer_id           in  com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name;

function get_cycle_prev_date(
    i_start_date            in  date
  , i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_cycle_type            in  com_api_type_pkg.t_dict_value
) return date;

procedure get_total_trans(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
  , i_terminal_type         in  com_api_type_pkg.t_dict_value    default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
  , o_count                out  com_api_type_pkg.t_long_id
  , o_total_amount         out  com_api_type_pkg.t_money
);

function is_link_application(
    i_object_id             in  com_api_type_pkg.t_medium_id
  , i_entity_type           in  com_api_type_pkg.t_dict_value
)return com_api_type_pkg.t_boolean;

end cst_cfc_com_pkg;
/
