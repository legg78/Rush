create or replace force view rul_algorithm_vw as
select id
     , seqnum
     , algorithm
     , entry_point
     , proc_id
  from rul_algorithm
/
