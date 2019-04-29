create or replace force view cln_stage_transition_vw as
select t.id
     , t.seqnum
     , t.stage_id
     , t.transition_stage_id
     , t.reason_code
  from cln_stage_transition t
/
