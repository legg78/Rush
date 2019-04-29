create or replace force view app_flow_transition_vw as
select a.id
     , a.seqnum
     , a.stage_id
     , a.transition_stage_id
     , a.reason_code
     , a.stage_result
     , a.event_type
  from app_flow_transition a
/
