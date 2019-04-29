create or replace package body crd_cst_overdue_pkg as

procedure collect_penalty(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_account_number    in      com_api_type_pkg.t_account_number
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_customer_id       in      com_api_type_pkg.t_medium_id
  , i_last_invoice_id   in      com_api_type_pkg.t_medium_id
  , i_eff_date          in      date
  , i_overdue_date      in      date
  , i_overdue_amount    in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_alg_calc_penalty  in      com_api_type_pkg.t_dict_value
) is
begin
    null;
end;

end;
/
