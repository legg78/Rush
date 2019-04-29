create or replace force view asc_ui_parameter_vw as
select p.id
     , p.param_name
     , p.data_type
     , p.lov_id
     , get_text('asc_parameter', 'description', p.id, c.lang) description
     , c.lang 
  from asc_parameter p
     , com_language_vw c
/