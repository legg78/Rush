create or replace force view svy_tag_vw as
select t.id
     , t.seqnum
     , t.inst_id
     , t.entity_type
     , t.condition
  from svy_tag t
/
