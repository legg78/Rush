create or replace package body cst_api_credit_pkg as

procedure modify_mandatory_amount_due(
    i_mandatory_amount_due      in      com_api_type_pkg.t_money
  , i_total_amount_due          in      com_api_type_pkg.t_money
  , i_product_id                in      com_api_type_pkg.t_short_id
  , i_account_id                in      com_api_type_pkg.t_medium_id
  , i_currency                  in      com_api_type_pkg.t_curr_code
  , i_service_id                in      com_api_type_pkg.t_short_id
  , i_eff_date                  in      date
  , o_modified_amount_due          out  com_api_type_pkg.t_money
  , i_overdraft_balance         in      com_api_type_pkg.t_money
  , i_aging_period              in      com_api_type_pkg.t_tiny_id
) is
begin
    null;
end;

end;
/
