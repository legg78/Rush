create or replace force view rul_proc_param_vw as
select p.id
     , p.proc_id
     , p.param_name
     , p.lov_id
     , p.display_order
     , p.is_mandatory
     , p.param_id
  from rul_proc_param p
/
