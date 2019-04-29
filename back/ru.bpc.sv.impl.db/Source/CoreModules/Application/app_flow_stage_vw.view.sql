create or replace force view app_flow_stage_vw as
select a.id
     , a.seqnum
     , a.flow_id
     , a.appl_status
     , a.handler
     , a.handler_type
     , a.reject_code
     , a.role_id
  from app_flow_stage a
/
