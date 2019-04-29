create or replace package evt_api_event_pkg as
/************************************************************
 * Events API. <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 10.05.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: EVT_API_EVENT_PKG <br />
 * @headcom
 *************************************************************/

type t_subscriber_rec is record (
    event_id        com_api_type_pkg.t_tiny_id
  , mod_id          com_api_type_pkg.t_tiny_id
  , procedure_name  com_api_type_pkg.t_name
  , container_id    com_api_type_pkg.t_short_id
);
type t_subscriber_tab is table of t_subscriber_rec index by binary_integer;

type t_rule_set_rec is record (
    mod_id          com_api_type_pkg.t_tiny_id
  , rule_set_id     com_api_type_pkg.t_tiny_id
  , is_cached       com_api_type_pkg.t_boolean
);
type t_rule_set_tab is table of t_rule_set_rec index by binary_integer;


procedure register_event(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_status            in      com_api_type_pkg.t_dict_value  default null
  , i_is_used_cache     in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
);

procedure register_event(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_status            in      com_api_type_pkg.t_dict_value  default null
);

procedure flush_events;

procedure cancel_events;

procedure remove_event_object(
    i_event_type   in      com_api_type_pkg.t_dict_value
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_object_id    in      com_api_type_pkg.t_long_id
  , i_inst_id      in      com_api_type_pkg.t_inst_id
);

procedure register_event(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_map         in      com_param_map_tpt
  , i_status            in      com_api_type_pkg.t_dict_value  default null
);

--changes status of event to i_event_object_status
procedure change_event_object_status(
    i_event_object_id_tab    in    com_api_type_pkg.t_number_tab
  , i_event_object_status    in    com_api_type_pkg.t_dict_value
);

--changes status of event to i_event_object_status
procedure change_event_object_status(
    i_event_object_id_tab    in    num_tab_tpt
  , i_event_object_status    in    com_api_type_pkg.t_dict_value
);

--changes status of event to processed
procedure process_event_object(
    i_event_object_id   in      com_api_type_pkg.t_long_id
);

--changes status of event to processed
procedure process_event_object(
    i_event_object_id_tab in    com_api_type_pkg.t_number_tab
);

procedure process_event_object(
    i_event_object_id_tab    in    num_tab_tpt
);

procedure register_event_autonomous(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_status            in      com_api_type_pkg.t_dict_value  default null
);

procedure register_event_autonomous(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_status            in      com_api_type_pkg.t_dict_value  default null
);

procedure rollback_event_object(
    i_session_id        in      com_api_type_pkg.t_long_id
);

function get_subscriber_tab(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return t_subscriber_tab result_cache;

function get_rule_set_tab(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return t_rule_set_tab result_cache;

procedure change_split_hash(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
);

procedure register_event(
    i_event_type            in     com_api_type_pkg.t_dict_value
  , i_eff_date              in     date
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_param_tab             in     com_api_type_pkg.t_param_tab
  , i_status                in     com_api_type_pkg.t_dict_value  default null
  , i_is_used_cache         in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_need_postponed_event  in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , io_postponed_event_tab  in out nocopy evt_api_type_pkg.t_postponed_event_tab
);

procedure add_postponed_event(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_status            in      com_api_type_pkg.t_dict_value  default null
  , o_postponed_event      out  evt_api_type_pkg.t_postponed_event
);

procedure register_postponed_event(
    i_postponed_event   in      evt_api_type_pkg.t_postponed_event
);

procedure register_postponed_event(
    io_postponed_event_tab   in out nocopy evt_api_type_pkg.t_postponed_event_tab
);

function check_event_type(
    i_action            in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean;

end evt_api_event_pkg;
/
