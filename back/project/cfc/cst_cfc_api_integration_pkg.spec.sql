create or replace package cst_cfc_api_integration_pkg is

procedure get_payment_due(
    i_short_card_mask   in     com_api_type_pkg.t_card_number
  , i_id_type           in     com_api_type_pkg.t_dict_value
  , i_id_series         in     com_api_type_pkg.t_name              default null
  , i_id_number         in     com_api_type_pkg.t_name
  , o_customer_id          out com_api_type_pkg.t_long_id
  , o_cardholder_name      out com_api_type_pkg.t_name
  , o_account_number       out com_api_type_pkg.t_account_number
  , o_currency             out com_api_type_pkg.t_curr_code
  , o_tad                  out com_api_type_pkg.t_money
  , o_last_payment_flag    out com_api_type_pkg.t_boolean
  , o_due_date             out date
  , o_daily_mad            out com_api_type_pkg.t_money
);

procedure get_payment_due(
    i_account_number    in     com_api_type_pkg.t_account_number
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , o_customer_id          out com_api_type_pkg.t_long_id
  , o_customer_name        out com_api_type_pkg.t_full_desc
  , o_account_number       out com_api_type_pkg.t_account_number
  , o_currency             out com_api_type_pkg.t_curr_code
  , o_tad                  out com_api_type_pkg.t_money
  , o_last_payment_flag    out com_api_type_pkg.t_boolean
  , o_due_date             out date
  , o_daily_mad            out com_api_type_pkg.t_money
);

end;
/
