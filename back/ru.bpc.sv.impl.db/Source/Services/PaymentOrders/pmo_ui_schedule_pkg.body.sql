create or replace package body pmo_ui_schedule_pkg as
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
) is
begin
    o_id     := com_api_id_pkg.get_id(pmo_schedule_seq.nextval, to_date(substr(to_char(i_order_id),1,6),'yymmdd'));
    o_seqnum := 1;

    insert into pmo_schedule_vw(
        id
      , seqnum
      , order_id
      , event_type
      , entity_type
      , object_id
      , attempt_limit
      , amount_algorithm
      , cycle_id
    ) values (
        o_id
      , o_seqnum
      , i_order_id
      , i_event_type
      , i_entity_type
      , i_object_id
      , i_attempt_limit
      , i_amount_algorithm
      , i_cycle_id
    );

end;

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
) is
begin
    update pmo_schedule_vw a
       set a.seqnum           = io_seqnum
         , a.order_id         = i_order_id
         , a.event_type       = i_event_type
         , a.entity_type      = i_entity_type
         , a.object_id        = i_object_id
         , a.attempt_limit    = i_attempt_limit
         , a.amount_algorithm = i_amount_algorithm
         , a.cycle_id         = i_cycle_id
     where a.id               = i_id;

    io_seqnum := io_seqnum + 1;

end;

procedure remove(
    i_id                in     com_api_type_pkg.t_long_id
  , i_seqnum            in     com_api_type_pkg.t_seqnum
) is
begin
    update pmo_schedule_vw a
       set a.seqnum = i_seqnum
     where a.id     = i_id;

    delete pmo_schedule_vw a
     where a.id     = i_id;
end;

procedure get_orders(
    o_refcursor            out sys_refcursor
) is
begin
    open o_refcursor for
    select o.id as payment_order_id
         , o.amount
         , o.currency
         , e.eff_date
    from pmo_order o
       , evt_event_object e
    where e.procedure_name = 'PMO_PRC_SHEDULE_PKG.PROCESS'
      and e.entity_type    = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER 
      and e.object_id      = o.id;

end;

end pmo_ui_schedule_pkg;
/
