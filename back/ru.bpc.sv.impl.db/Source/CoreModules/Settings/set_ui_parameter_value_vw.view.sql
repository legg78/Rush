create or replace force view set_ui_parameter_value_vw as
select b.id as param_id
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
     , get_text('set_parameter', 'description', a.param_id, c.lang) description
     , get_number_value(b.data_type, a.param_value) param_number_value
     , get_char_value  (b.data_type, a.param_value) param_char_value
     , get_date_value  (b.data_type, a.param_value) param_date_value
     , get_lov_value   (b.data_type, a.param_value, b.lov_id) param_lov_value
     , c.lang
     , a.id
  from set_parameter_value a
     , set_parameter b
     , com_language_vw c
 where b.id = a.param_id(+)
/
