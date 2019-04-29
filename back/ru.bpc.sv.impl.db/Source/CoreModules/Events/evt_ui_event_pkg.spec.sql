create or replace package evt_ui_event_pkg as
/********************************************************* 
 *  User Interface procedures for events <br /> 
 *  Created by Filiminov A.(filimonov@bpcbt.com)  at 10.05.2011
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: evt_ui_event_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

function check_process_priority(
  i_procedure_name      in      com_api_type_pkg.t_name 
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean;

procedure add_event_type(
    o_event_type_id        out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_reason_lov_id     in      com_api_type_pkg.t_tiny_id
);

procedure modify_event_type(
    i_event_type_id     in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_reason_lov_id     in      com_api_type_pkg.t_tiny_id
);

procedure remove_event_type(
    i_event_type_id     in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_subscriber(
    o_subscr_id            out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_procedure_name    in      com_api_type_pkg.t_name 
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
);

procedure modify_subscriber(
    i_subscr_id         in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_priority          in      com_api_type_pkg.t_tiny_id
);

procedure remove_subscriber(
    i_subscr_id         in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_event(
    o_event_id             out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_scale_id          in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
);

procedure modify_event(
    i_event_id          in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_scale_id          in      com_api_type_pkg.t_tiny_id
);

procedure remove_event(
    i_event_id          in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_subscription(
    o_subscript_id         out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_id          in      com_api_type_pkg.t_tiny_id
  , i_subscr_id         in      com_api_type_pkg.t_tiny_id
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_container_id      in      com_api_type_pkg.t_short_id    default null  
);

procedure modify_subscription(
    i_subscript_id      in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_container_id      in      com_api_type_pkg.t_short_id    default null  
);

procedure remove_subscription(
    i_subscript_id      in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_event_rule_set(
    o_event_rule_set_id    out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_id          in      com_api_type_pkg.t_tiny_id
  , i_rule_set_id       in      com_api_type_pkg.t_tiny_id
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
);

procedure modify_event_rule_set(
    i_event_rule_set_id in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
);

procedure remove_event_rule_set(
    i_event_rule_set_id in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure register_event(
    i_event_type                   in      com_api_type_pkg.t_dict_value
  , i_eff_date                     in      date                           default null
  , i_entity_type                  in      com_api_type_pkg.t_dict_value
  , i_object_id                    in      com_api_type_pkg.t_long_id
  , i_inst_id                      in      com_api_type_pkg.t_inst_id     default null
  , i_split_hash                   in      com_api_type_pkg.t_tiny_id     default null
  , i_event_object_status          in      com_api_type_pkg.t_dict_value  default null
);

end;
/
