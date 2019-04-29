create or replace force view asc_parameter_vw as
select id
     , param_name
     , data_type
     , lov_id
  from asc_parameter
/