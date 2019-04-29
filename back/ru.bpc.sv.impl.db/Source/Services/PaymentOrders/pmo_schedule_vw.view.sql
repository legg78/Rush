create or replace force view pmo_schedule_vw as
select a.id
     , a.seqnum
     , a.order_id
     , a.event_type
     , a.entity_type
     , a.object_id
     , a.attempt_limit
     , a.amount_algorithm
     , a.cycle_id
  from pmo_schedule a
/
