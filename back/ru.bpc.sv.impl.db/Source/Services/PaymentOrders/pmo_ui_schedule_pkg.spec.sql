create or replace package pmo_ui_schedule_pkg as
/************************************************************
 * UI for Payment Order shedule<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_SCHEDULE_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_long_id
  , o_seqnum               out com_api_type_pkg.t_seqnum
  , i_order_id          in     com_api_type_pkg.t_long_id
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_attempt_limit     in     com_api_type_pkg.t_tiny_id
  , i_amount_algorithm  in     com_api_type_pkg.t_dict_value
  , i_cycle_id          in     com_api_type_pkg.t_long_id
);

procedure modify(
    i_id                in     com_api_type_pkg.t_long_id
  , io_seqnum           in out com_api_type_pkg.t_seqnum
  , i_order_id          in     com_api_type_pkg.t_medium_id
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_attempt_limit     in     com_api_type_pkg.t_tiny_id
  , i_amount_algorithm  in     com_api_type_pkg.t_dict_value
  , i_cycle_id          in     com_api_type_pkg.t_long_id
);

procedure remove(
    i_id                in     com_api_type_pkg.t_long_id
  , i_seqnum            in     com_api_type_pkg.t_seqnum
);

procedure get_orders(
    o_refcursor            out sys_refcursor
);

end pmo_ui_schedule_pkg;
/
