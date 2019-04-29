create or replace force view app_ui_flow_transition_vw as
select a.id
     , b.flow_id
     , b.appl_status previous_status
     , c.appl_status appl_status
     , get_article_text(b.appl_status) as previous_status_name
     , get_article_text(c.appl_status) as appl_status_name
     , b.reject_code previous_reject_code
     , c.reject_code appl_reject_code
     , get_article_text (b.reject_code) AS previous_reject_name
     , get_article_text (c.reject_code) AS appl_reject_name
     , a.seqnum
     , a.stage_id
     , a.transition_stage_id
     , a.reason_code
     , a.stage_result
     , a.event_type
     , get_article_text(a.event_type) as event_type_name
  from app_flow_transition a
     , app_flow_stage b
     , app_flow_stage c
 where b.id = a.stage_id
   and c.id = a.transition_stage_id
/
