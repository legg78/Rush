create or replace force view asc_state_vw as 
select id
     , seqnum 
     , scenario_id
     , code
     , state_type
  from asc_state
/