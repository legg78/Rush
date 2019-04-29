create or replace package cst_bsm_api_svgate_pkg as

procedure get_auto_debit_cycles(
    i_service_id            in      com_api_type_pkg.t_short_id
  , o_ref_cur                   out com_api_type_pkg.t_ref_cur
);

procedure get_cust_payment_cycles(
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_cycle_order_id        in      com_api_type_pkg.t_tiny_id
  , i_row_start             in      com_api_type_pkg.t_tiny_id
  , i_row_count             in      com_api_type_pkg.t_tiny_id
  , o_ref_cur                   out com_api_type_pkg.t_ref_cur
);

end;
/
