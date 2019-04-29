create or replace force view scr_evaluation_vw
as
select id
     , seqnum
     , inst_id
  from scr_evaluation
/
