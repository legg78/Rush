create or replace package ntf_ui_custom_pkg is

procedure set_custom_event (
    io_id                   in out  com_api_type_pkg.t_medium_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_channel_id            in      com_api_type_pkg.t_tiny_id
  , i_delivery_address      in      com_api_type_pkg.t_full_desc
  , i_delivery_time         in      com_api_type_pkg.t_name
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_mod_id                in      com_api_type_pkg.t_tiny_id
  , i_start_date            in      date
  , i_end_date              in      date
  , i_customer_id           in      com_api_type_pkg.t_long_id
  , i_contact_type          in      com_api_type_pkg.t_dict_value
);
    
procedure remove_custom_event (
    i_id                    in      com_api_type_pkg.t_medium_id
);

procedure set_custom_object (
    io_id                   in out  com_api_type_pkg.t_long_id
  , i_custom_event_id       in      com_api_type_pkg.t_medium_id
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_is_active             in      com_api_type_pkg.t_boolean
  , i_entity_type           in      com_api_type_pkg.t_dict_value    default null
);

procedure remove_custom_object (
    i_id                    in      com_api_type_pkg.t_long_id
);

end; 
/
