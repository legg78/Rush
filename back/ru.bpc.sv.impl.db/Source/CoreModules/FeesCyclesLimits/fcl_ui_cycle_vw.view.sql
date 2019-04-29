create or replace force view fcl_ui_cycle_vw as
select a.id
     , a.seqnum
     , a.cycle_type
     , a.length_type
     , a.cycle_length
     , a.trunc_type
     , a.inst_id 
     , fcl_ui_cycle_pkg.get_cycle_desc(a.id) description
     , a.workdays_only
  from fcl_cycle a
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/
