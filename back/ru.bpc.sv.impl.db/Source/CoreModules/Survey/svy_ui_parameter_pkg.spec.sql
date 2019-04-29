create or replace package svy_ui_parameter_pkg is

procedure add(
    o_id                 out com_api_type_pkg.t_medium_id
  , o_seqnum             out com_api_type_pkg.t_tiny_id
  , i_param_name      in     com_api_type_pkg.t_oracle_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_display_order   in     com_api_type_pkg.t_tiny_id
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_is_multi_select in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id              in     com_api_type_pkg.t_medium_id
  , io_seqnum         in out com_api_type_pkg.t_tiny_id
  , i_param_name      in     com_api_type_pkg.t_oracle_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_display_order   in     com_api_type_pkg.t_tiny_id
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_is_multi_select in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id              in     com_api_type_pkg.t_medium_id
);

end svy_ui_parameter_pkg;
/
