create or replace package body crd_cst_report_pkg as

function get_additional_amounts(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_service_id            in      com_api_type_pkg.t_short_id
  , i_eff_date              in      date
) return xmltype
is
    l_result                        xmltype;
begin
    return l_result;
end;

function get_subject(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
) return com_api_type_pkg.t_name
is
    l_result                        com_api_type_pkg.t_name;
    l_account_number                com_api_type_pkg.t_account_number;
begin
    select account_number
      into l_account_number
      from acc_account
     where id = i_account_id;

    l_result := 'Credit statement of ' || l_account_number;

    return l_result;
end;

function credit_statement_invoice_data(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
  , i_currency              in      com_api_type_pkg.t_curr_code
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml                           xmltype;
begin
    return l_xml;
end;

end;
/
