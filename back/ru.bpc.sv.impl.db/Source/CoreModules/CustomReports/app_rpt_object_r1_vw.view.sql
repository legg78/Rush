create or replace force view app_rpt_object_r1_vw as
select appl_id 
     , entity_type
     , object_id
     , seqnum
  from app_object
/

