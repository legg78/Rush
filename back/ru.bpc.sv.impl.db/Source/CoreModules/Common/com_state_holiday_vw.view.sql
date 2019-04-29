create or replace force view com_state_holiday_vw as 
select a.id
     , a.cycle_id
     , a.inst_id
     , a.seqnum
  from com_state_holiday a
/