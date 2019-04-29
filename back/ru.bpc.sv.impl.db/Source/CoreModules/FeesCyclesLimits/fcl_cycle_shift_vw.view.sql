create or replace force view fcl_cycle_shift_vw as
select a.id
     , a.seqnum
     , a.cycle_id
     , a.shift_type
     , a.priority
     , a.shift_sign
     , a.length_type
     , a.shift_length
  from fcl_cycle_shift a
/
