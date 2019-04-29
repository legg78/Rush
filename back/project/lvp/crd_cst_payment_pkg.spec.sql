create or replace package crd_cst_payment_pkg as

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , io_payment_amount   in out  com_api_type_pkg.t_money
);

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_payment_amount    in      com_api_type_pkg.t_money
);

procedure enum_debt_order(
    io_cur_debts        in out  com_api_type_pkg.t_ref_cur
  , io_query            in out  com_api_type_pkg.t_text
  , io_order_by         in out  com_api_type_pkg.t_text
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date
  , i_original_oper_id  in      com_api_type_pkg.t_long_id
  , i_payment_condition in      com_api_type_pkg.t_dict_value
  , i_repay_mad_first   in      com_api_type_pkg.t_boolean
);

end;
/
