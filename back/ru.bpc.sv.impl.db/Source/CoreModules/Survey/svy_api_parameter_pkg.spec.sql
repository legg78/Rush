create or replace package svy_api_parameter_pkg as

type t_parameter_value is record(
    id               com_api_type_pkg.t_medium_id
  , seqnum           com_api_type_pkg.t_tiny_id
  , param_name       com_api_type_pkg.t_oracle_name
  , data_type        com_api_type_pkg.t_dict_value
  , display_order    com_api_type_pkg.t_tiny_id
  , lov_id           com_api_type_pkg.t_tiny_id
  , is_multi_select  com_api_type_pkg.t_boolean
  , is_system_param  com_api_type_pkg.t_boolean
  , table_name       com_api_type_pkg.t_oracle_name
);

function get_parameter_rec(
    i_param_name         in com_api_type_pkg.t_oracle_name
  , i_is_system_param    in com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
  , i_table_name         in com_api_type_pkg.t_attr_name           default null
) return t_parameter_value;

function get_parameter_name_lang(
    i_param_name               in com_api_type_pkg.t_oracle_name
  , i_is_system_param          in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_table_name               in com_api_type_pkg.t_attr_name     default null
  , i_lang                     in com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_name;

end svy_api_parameter_pkg;
/
