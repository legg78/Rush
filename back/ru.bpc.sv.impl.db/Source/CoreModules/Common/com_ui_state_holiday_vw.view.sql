create or replace force view com_ui_state_holiday_vw as 
select a.id
     , a.cycle_id
     , a.inst_id
     , a.seqnum
     , fcl_api_cycle_pkg.calc_next_date(a.cycle_id, sysdate, 1, 0) day
     , get_text('com_state_holiday', 'name', a.id) name
  from com_state_holiday a
/