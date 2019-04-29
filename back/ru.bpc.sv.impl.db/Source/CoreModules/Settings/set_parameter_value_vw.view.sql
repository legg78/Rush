create or replace force view set_parameter_value_vw as
select a.param_id
     , a.param_level
     , a.level_value
     , a.param_value
     , b.module_code
     , b.name
     , b.lowest_level
     , b.default_value
     , b.data_type
     , b.lov_id
     , b.parent_id
     , b.display_order
     , a.id
  from set_parameter_value a
     , set_parameter b
where a.param_id = b.id
/
