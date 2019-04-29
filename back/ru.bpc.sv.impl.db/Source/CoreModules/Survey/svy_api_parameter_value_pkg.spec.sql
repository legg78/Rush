create or replace package svy_api_parameter_value_pkg as

procedure set_parameter_value(
    i_param_name            in  com_api_type_pkg.t_name
  , i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_questionary_id        in  com_api_type_pkg.t_long_id
  , i_seq_number            in  com_api_type_pkg.t_tiny_id
  , i_seqnum                in  com_api_type_pkg.t_tiny_id      default 1
  , i_param_value_c         in  varchar2                        default null
  , i_param_value_n         in  number                          default null
  , i_param_value_d         in  date                            default null
);

procedure set_parameter_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_questionary_id    in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default null
  , i_seqnum            in      com_api_type_pkg.t_tiny_id          default 1
  , i_param_value       in      varchar2
);

procedure set_parameter_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_questionary_id    in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default null
  , i_seqnum            in      com_api_type_pkg.t_tiny_id          default 1
  , i_param_value       in      number
);

procedure set_parameter_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_questionary_id    in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default null
  , i_seqnum            in      com_api_type_pkg.t_tiny_id          default 1
  , i_param_value       in      date
);


function get_parameter_value(
    i_param_name           in com_api_type_pkg.t_oracle_name
  , i_is_system_param      in com_api_type_pkg.t_boolean           default com_api_const_pkg.FALSE
  , i_table_name           in com_api_type_pkg.t_attr_name         default null
  , i_questionary_id       in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name;

end svy_api_parameter_value_pkg;
/
