create or replace package frp_api_online_pkg as

procedure check_legality(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_external_id           in      com_api_type_pkg.t_name         default null
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_suite_id              in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , io_resp_code            in out  com_api_type_pkg.t_dict_value
);

procedure register_auth(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_external_id           in      com_api_type_pkg.t_name         default null
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_resp_code             in      com_api_type_pkg.t_dict_value   default null
);

end;
/
    