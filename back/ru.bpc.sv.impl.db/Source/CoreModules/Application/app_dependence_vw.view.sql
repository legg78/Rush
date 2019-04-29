create or replace force view app_dependence_vw as
select a.id
     , a.seqnum
     , a.struct_id
     , a.depend_struct_id
     , a.dependence
     , a.condition
     , a.affected_zone
  from app_dependence a
/

