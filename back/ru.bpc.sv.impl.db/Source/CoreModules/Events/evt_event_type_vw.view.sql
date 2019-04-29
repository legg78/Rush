create or replace force view evt_event_type_vw as
select id
     , seqnum
     , event_type
     , entity_type
     , reason_lov_id
  from evt_event_type
/