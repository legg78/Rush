CREATE OR REPLACE package ntf_ui_scheme_event_pkg is

procedure add_scheme_event (
    o_id                       out  com_api_type_pkg.t_short_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_scheme_id             in      com_api_type_pkg.t_tiny_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_contact_type          in      com_api_type_pkg.t_dict_value
  , i_notif_id              in      com_api_type_pkg.t_tiny_id
  , i_channel_id            in      com_api_type_pkg.t_tiny_id
  , i_delivery_time         in      com_api_type_pkg.t_name
  , i_is_customizable       in      com_api_type_pkg.t_boolean
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_is_batch_send         in      com_api_type_pkg.t_boolean
  , i_scale_id              in      com_api_type_pkg.t_tiny_id
  , i_priority              in      com_api_type_pkg.t_tiny_id
);

procedure modify_scheme_event (
    i_id                    in      com_api_type_pkg.t_short_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_scheme_id             in      com_api_type_pkg.t_tiny_id
  , i_notif_id              in      com_api_type_pkg.t_tiny_id
  , i_contact_type          in      com_api_type_pkg.t_dict_value
  , i_channel_id            in      com_api_type_pkg.t_tiny_id
  , i_delivery_time         in      com_api_type_pkg.t_name
  , i_is_customizable       in      com_api_type_pkg.t_boolean
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_is_batch_send         in      com_api_type_pkg.t_boolean
  , i_scale_id              in      com_api_type_pkg.t_tiny_id
  , i_priority              in      com_api_type_pkg.t_tiny_id
);

procedure remove_scheme_event (
    i_id                    in      com_api_type_pkg.t_short_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
  , i_scheme_id             in      com_api_type_pkg.t_tiny_id
);

end;
/

