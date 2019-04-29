create or replace force view acm_ui_action_value_vw as
select c.id
     , a.id as action_id
     , b.id as param_id
     , b.name
     , b.data_type
     , b.label
     , b.lov_id
     , b.lang
     , c.param_function
     , c.param_value
  from acm_action a
  join acm_ui_section_parameter_vw b on a.section_id = b.section_id 
  left join acm_action_value c on c.action_id = a.id and b.id = c.param_id 
/ 