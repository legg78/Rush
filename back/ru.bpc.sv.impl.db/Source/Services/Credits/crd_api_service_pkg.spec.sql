create or replace package crd_api_service_pkg as

procedure activate_service(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_eff_date          in      date
);

procedure deactivate_service(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_eff_date          in      date
);

function get_active_service(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

end;
/
