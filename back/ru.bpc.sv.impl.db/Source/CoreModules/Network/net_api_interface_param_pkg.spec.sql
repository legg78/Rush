create or replace package net_api_interface_param_pkg as

procedure get_param_value(
    i_device_id             in      com_api_type_pkg.t_short_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_param_name            in      com_api_type_pkg.t_name
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_standart_type         in      com_api_type_pkg.t_dict_value default null
  , o_param_value              out  com_api_type_pkg.t_param_value
);

procedure get_xml_param_value(
    i_device_id             in      com_api_type_pkg.t_short_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_param_name            in      com_api_type_pkg.t_name
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_standart_type         in      com_api_type_pkg.t_dict_value default null
  , o_xml_param_value          out  clob
);

end;
/