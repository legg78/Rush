create or replace package crd_cst_report_pkg as

function get_additional_amounts(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_service_id            in      com_api_type_pkg.t_short_id
  , i_eff_date              in      date
) return xmltype;

function get_subject(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
) return com_api_type_pkg.t_name;

function credit_statement_invoice_data(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
  , i_currency              in      com_api_type_pkg.t_curr_code
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return xmltype;

end;
/
