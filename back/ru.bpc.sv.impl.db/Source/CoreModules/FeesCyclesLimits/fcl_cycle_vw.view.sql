create or replace force view fcl_cycle_vw as
select a.id
     , a.seqnum
     , a.cycle_type
     , a.length_type
     , a.cycle_length
     , a.trunc_type
     , a.inst_id 
     , a.workdays_only
from fcl_cycle a
/
