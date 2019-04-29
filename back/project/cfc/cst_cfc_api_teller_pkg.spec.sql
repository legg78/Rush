create or replace package cst_cfc_api_teller_pkg as

-- Prepaid contract types:
ACCT_TYPE_SAVING_VND            constant com_api_type_pkg.t_dict_value := 'ACTP0131';
ACCT_TYPE_PREPAID_VND           constant com_api_type_pkg.t_dict_value := 'ACTP0140';
MACROS_TYPE_ID_DEBIT_ON_OPER    constant com_api_type_pkg.t_dict_value := 1004;

procedure get_card_acct_link(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_app_id                in  com_api_type_pkg.t_name
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

procedure get_account(
    i_account_number        in  com_api_type_pkg.t_account_number
  , o_account_status        out com_api_type_pkg.t_dict_value
  , o_account_type          out com_api_type_pkg.t_dict_value
);

procedure get_account_balances(
    i_account_number        in  com_api_type_pkg.t_account_number
  , i_balance_type          in  com_api_type_pkg.t_dict_value
  , o_balance_amount        out com_api_type_pkg.t_money
  , o_balance_currency      out com_api_type_pkg.t_curr_code
  , o_aval_balance          out com_api_type_pkg.t_money
  , o_aval_balance_currency out com_api_type_pkg.t_curr_code
);

function get_reissue_reason(
    i_card_id               in  com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_dict_value;

procedure get_customer_marketing_info(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_customer_id           in  com_api_type_pkg.t_medium_id
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

procedure get_card_account_from_account(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_account_number        in  com_api_type_pkg.t_account_number
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

procedure get_customer_credit_account(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_customer_number       in  com_api_type_pkg.t_cmid
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

function get_collateral_account(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_account_number        in  com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_account_number;

function get_statement_delivery_method(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_account_number        in  com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_text;

procedure get_card_acct_for_sup_card(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_card_number           in  com_api_type_pkg.t_card_number
  , i_account_number        in  com_api_type_pkg.t_account_number
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

procedure get_customer_crd_invoice_info(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_customer_id           in  com_api_type_pkg.t_medium_id
  , o_ref_cursor            out com_api_type_pkg.t_ref_cur
);

procedure get_crd_invoice_payments_info(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_invoice_id            in  com_api_type_pkg.t_medium_id
  , o_ref_cursor            out com_api_type_pkg.t_ref_cur
);

function get_contract_by_card_number(
    i_card_number           in  com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_name;

procedure get_services_by_card_number(
    i_card_number           in  com_api_type_pkg.t_card_number
  , o_ref_cursor            out com_api_type_pkg.t_ref_cur
);

procedure get_contract_info(
    i_account_number        in  com_api_type_pkg.t_account_number
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);

procedure get_embosser_info(
    i_card_id               in  com_api_type_pkg.t_medium_id
  , i_lang                  in  com_api_type_pkg.t_dict_value
  , o_ref_cur               out com_api_type_pkg.t_ref_cur
);
end cst_cfc_api_teller_pkg;
/
