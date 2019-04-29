create or replace package acq_ui_account_customer_pkg as

procedure add_account_customer(
    i_customer_id  in   com_api_type_pkg.t_medium_id
  , i_scheme_id    in   com_api_type_pkg.t_tiny_id
);

procedure modify_account_customer(
    i_customer_id  in   com_api_type_pkg.t_medium_id
  , i_scheme_id    in   com_api_type_pkg.t_tiny_id
);

procedure remove_account_customer(
    i_customer_id  in   com_api_type_pkg.t_medium_id
  , i_scheme_id    in   com_api_type_pkg.t_tiny_id
);

end;
/
