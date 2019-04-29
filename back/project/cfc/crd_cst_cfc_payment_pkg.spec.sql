create or replace package crd_cst_cfc_payment_pkg as

procedure apply_balance_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_balance_type      in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , o_remainder_amount     out  com_api_type_pkg.t_money
);

end;
/
