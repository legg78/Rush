create or replace package ecm_api_merchant_pkg as

procedure auth_merchant (
    i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_merchant_login        in      com_api_type_pkg.t_name
  , i_merchant_password     in      com_api_type_pkg.t_name
  , o_merchant_id              out  com_api_type_pkg.t_short_id
);

end ecm_api_merchant_pkg;
/
