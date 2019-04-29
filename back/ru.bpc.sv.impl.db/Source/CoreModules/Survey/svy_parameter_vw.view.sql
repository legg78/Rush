create or replace force view svy_parameter_vw as
select p.id
     , p.seqnum
     , p.param_name
     , p.data_type
     , p.display_order
     , p.lov_id
     , p.is_multi_select
     , p.is_system_param
     , p.table_name
  from svy_parameter p
/
