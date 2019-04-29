create or replace package app_api_appl_object_pkg as

procedure add_object(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_tiny_id
);

end;
/