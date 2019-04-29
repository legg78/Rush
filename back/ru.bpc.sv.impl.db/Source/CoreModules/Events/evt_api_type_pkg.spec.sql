create or replace package evt_api_type_pkg as

type t_event_object is record(
    event_object_id com_api_type_pkg.t_long_id
  , event_type      com_api_type_pkg.t_dict_value
  , event_id        com_api_type_pkg.t_tiny_id
  , procedure_name  com_api_type_pkg.t_name
  , entity_type     com_api_type_pkg.t_dict_value
  , object_id       com_api_type_pkg.t_long_id
  , eff_date        date
  , inst_id         com_api_type_pkg.t_inst_id
  , split_hash      com_api_type_pkg.t_tiny_id
  , rule_set_id     com_api_type_pkg.t_tiny_id
  , status          com_api_type_pkg.t_dict_value
  , session_id      com_api_type_pkg.t_long_id
  , container_id    com_api_type_pkg.t_short_id
);

type t_event_object_tab is table of t_event_object index by binary_integer;

type t_postponed_event is record(
    event_type    com_api_type_pkg.t_dict_value
  , eff_date      date
  , entity_type   com_api_type_pkg.t_dict_value
  , object_id     com_api_type_pkg.t_long_id
  , inst_id       com_api_type_pkg.t_inst_id
  , split_hash    com_api_type_pkg.t_tiny_id
  , param_tab     com_api_type_pkg.t_param_tab
  , status        com_api_type_pkg.t_dict_value
);

type t_postponed_event_tab is table of t_postponed_event index by binary_integer;

end evt_api_type_pkg;
/
