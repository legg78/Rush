create or replace package evt_api_status_pkg as
/*********************************************************
*  API for status events<br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 04.04.2011 <br />
*  Module: EVT_API_STATUS_PKG <br />
*  @headcom
**********************************************************/

procedure add_status_log(
    i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_reason                in      com_api_type_pkg.t_dict_value
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_event_date            in      date                             default null
);

procedure add_status_log (
    i_event_type            in      com_api_type_pkg.t_dict_tab
  , i_initiator             in      com_api_type_pkg.t_dict_tab
  , i_entity_type           in      com_api_type_pkg.t_dict_tab
  , i_object_id             in      com_api_type_pkg.t_number_tab
  , i_reason                in      com_api_type_pkg.t_dict_tab
  , i_status                in      com_api_type_pkg.t_dict_tab
  , i_eff_date              in      com_api_type_pkg.t_date_tab
  , i_event_date            in      com_api_type_pkg.t_date_tab
);

function get_result_status(
    i_initiator             in      com_api_type_pkg.t_dict_value
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initial_status        in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_dict_value
result_cache;

procedure change_status(
    i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_new_status            in      com_api_type_pkg.t_dict_value
  , i_reason                in      com_api_type_pkg.t_dict_value
  , o_status                   out  com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_register_event        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_params                in      com_api_type_pkg.t_param_tab
  , i_inst_id               in      com_api_type_pkg.t_tiny_id       default null
  , i_event_date            in      date                             default null
);

procedure change_status(
    i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_reason                in      com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_params                in      com_api_type_pkg.t_param_tab
  , i_register_event        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id               in      com_api_type_pkg.t_tiny_id       default null
  , i_event_date            in      date                             default null
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
);

/*
 * Procedure changes status of an event in table EVT_EVENT_OBJECT.
 * @i_id           - PK vaue for table EVT_EVENT_OBJECT
 * @i_event_status - new status of event
 */
procedure change_event_status(
    i_id                    in      com_api_type_pkg.t_long_id
  , i_event_status          in      com_api_type_pkg.t_dict_value
);

/*
 * Function searches and returns event type that is associated with a transition
 * from specified initial status to result one.
 */
function get_event_type(
    i_initiator             in      com_api_type_pkg.t_dict_value
  , i_initial_status        in      com_api_type_pkg.t_dict_value
  , i_result_status         in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_dict_value;

procedure change_status_event_date (
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_medium_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_event_date            in      date
);

function get_status_reason(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_dict_value;

end;
/
