create or replace package evt_ui_status_pkg as

procedure change_status(
    i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_reason                in      com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_event_date            in      date                             default null
);

function get_object_status (
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value;

procedure change_event_status_date(
    i_status_log_id         in      com_api_type_pkg.t_long_id
  , i_date                  in      date
);

function get_status_reason(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value;

end;
/
