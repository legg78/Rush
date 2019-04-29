create or replace package cst_woo_api_teller_pkg as

-- Prepaid contract types:
C_PREPAID_ANONYMOUS        constant com_api_type_pkg.t_dict_value := 'CNTPPRPD';
C_PREPAID_NON_ANONYMOUS    constant com_api_type_pkg.t_dict_value := 'CNTPNOAN';

procedure get_card_acct_link(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_app_id                in      com_api_type_pkg.t_name
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure get_account(
    i_account_number        in      com_api_type_pkg.t_account_number
  , o_account_status        out     com_api_type_pkg.t_dict_value
  , o_account_type          out     com_api_type_pkg.t_dict_value
);

procedure get_account_balances(
    i_account_number        in      com_api_type_pkg.t_account_number
  , i_balance_type          in      com_api_type_pkg.t_dict_value
  , o_balance_amount        out     com_api_type_pkg.t_money
  , o_balance_currency      out     com_api_type_pkg.t_curr_code
  , o_aval_balance          out     com_api_type_pkg.t_money
  , o_aval_balance_currency out     com_api_type_pkg.t_curr_code
);

function get_reissue_reason(
    i_card_id               in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_dict_value;

procedure get_customer_marketing_info(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_customer_id           in      com_api_type_pkg.t_medium_id
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure get_card_account_from_account(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure get_customer_credit_account(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_customer_number       in      com_api_type_pkg.t_cmid
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

function get_dpp_threshold(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id;

function get_collateral_account(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_account_number;

function get_statement_delivery_method(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_text;

procedure get_card_acct_for_sup_card(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_card_number           in      com_api_type_pkg.t_card_number 
  , i_account_number        in      com_api_type_pkg.t_account_number  
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure get_customer_crd_invoice_info(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_customer_id           in      com_api_type_pkg.t_medium_id
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
);

procedure get_crd_invoice_payments_info(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
);

function check_special_card_number(
    i_card_number           in      com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_boolean;

procedure update_card_number_used(
    i_card_number           in      com_api_type_pkg.t_card_number
);

function get_contract_by_card_number(
    i_card_number           in      com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_name;

procedure get_services_by_card_number(
    i_card_number           in      com_api_type_pkg.t_card_number
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
);

procedure get_dpp_intr_rate_by_account(
    i_account_id            in      com_api_type_pkg.t_medium_id
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
);

procedure get_dpp_opr_selection(
    i_account_number        in      com_api_type_pkg.t_account_number
  , i_from_date             in      date
  , i_to_date               in      date
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure get_dpp_registration(   
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_account_number        in      com_api_type_pkg.t_account_number
  , i_from_date             in      date
  , i_to_date               in      date
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure get_dpp_installment_detail(
    i_dpp_id                in      com_api_type_pkg.t_long_id
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure get_dpp_amount_detail(
    i_dpp_id                in     com_api_type_pkg.t_long_id
  , o_dpp_amount            out    com_api_type_pkg.t_money
  , o_dpp_adv_amount        out    com_api_type_pkg.t_money
  , o_dpp_remain_amount     out    com_api_type_pkg.t_money
);

procedure accelerate_dpp(
    i_dpp_id                in     com_api_type_pkg.t_long_id
  , i_new_count             in     com_api_type_pkg.t_tiny_id    default null
  , i_payment_amount        in     com_api_type_pkg.t_money      default null
  , i_acceleration_type     in     com_api_type_pkg.t_dict_value
);

procedure get_dpp_early_payment_his(
    i_dpp_id                in      com_api_type_pkg.t_long_id
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
);

procedure change_card_status(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_reason                in      com_api_type_pkg.t_dict_value
  , o_result                out     com_api_type_pkg.t_boolean
);

procedure get_repayment_priorities(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_lang                  in      com_api_type_pkg.t_dict_value       default null
  , o_ref_cur                  out  sys_refcursor
);

procedure get_debts_prioritize(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_low_repay_priority    in      com_api_type_pkg.t_dict_value       default null
  , o_ref_cur                  out  sys_refcursor
);

procedure get_projected_debt_repayment(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_payment_amount        in      com_api_type_pkg.t_money        default null
  , o_ref_cur                  out  sys_refcursor
);

end;
/
