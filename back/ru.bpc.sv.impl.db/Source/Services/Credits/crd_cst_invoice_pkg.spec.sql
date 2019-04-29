create or replace package crd_cst_invoice_pkg as

procedure get_aging_period(
    i_last_invoice_id       in      com_api_type_pkg.t_medium_id
  , o_aging_period             out  com_api_type_pkg.t_tiny_id
  , o_serial_number            out  com_api_type_pkg.t_tiny_id
  , i_aging_algorithm       in      com_api_type_pkg.t_dict_value default null
);

end;
/

