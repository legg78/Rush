create or replace force view cln_stage_vw as
select s.id
     , s.seqnum
     , s.status
     , s.resolution
  from cln_stage s
/
