create or replace force view app_ui_online_object_vw as
select a.appl_id
     , a.entity_type
     , a.object_id
     , a.seqnum
  from app_object a
     , adt_entity n
 where n.entity_type = a.entity_type
   and n.synch_needed = 1
/