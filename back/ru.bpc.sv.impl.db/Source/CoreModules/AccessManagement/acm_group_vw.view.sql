create or replace force view acm_group_vw as
select g.id
     , g.inst_id
     , g.seqnum
     , g.creation_date
  from acm_group g
/

