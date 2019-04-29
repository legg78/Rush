create or replace package svy_ui_param_entity_pkg is

procedure add(
    o_id               out com_api_type_pkg.t_medium_id
  , o_seqnum           out com_api_type_pkg.t_tiny_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_param_id      in     com_api_type_pkg.t_medium_id
);

procedure modify(
    i_id            in     com_api_type_pkg.t_medium_id
  , io_seqnum       in out com_api_type_pkg.t_tiny_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_param_id      in     com_api_type_pkg.t_medium_id
);

procedure remove(
    i_id            in     com_api_type_pkg.t_medium_id
);

end svy_ui_param_entity_pkg;
/
