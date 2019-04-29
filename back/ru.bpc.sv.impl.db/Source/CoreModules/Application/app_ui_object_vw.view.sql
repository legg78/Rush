create or replace force view app_ui_object_vw as
select a.appl_id
     , a.entity_type
     , a.object_id
     , a.seqnum
  from app_object a
/