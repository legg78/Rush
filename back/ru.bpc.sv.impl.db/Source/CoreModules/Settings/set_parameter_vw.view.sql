create or replace force view set_parameter_vw as
select id
     , module_code
     , name
     , lowest_level
     , default_value
     , data_type
     , lov_id
     , parent_id
     , display_order
  from set_parameter a
/