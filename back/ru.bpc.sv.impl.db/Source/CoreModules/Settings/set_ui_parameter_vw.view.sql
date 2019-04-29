create or replace force view set_ui_parameter_vw as
select a.id
     , a.module_code
     , a.name
     , a.lowest_level
     , a.default_value
     , a.data_type
     , a.lov_id
     , a.parent_id
     , a.display_order
     , get_text('set_parameter', 'caption', a.id, b.lang) caption
     , get_text('set_parameter', 'description', a.id, b.lang) description
     , get_number_value(a.data_type, a.default_value) default_number_value
     , get_char_value  (a.data_type, a.default_value) default_char_value
     , get_date_value  (a.data_type, a.default_value) default_date_value
     , get_lov_value   (a.data_type, a.default_value, a.lov_id) default_lov_value
     , b.lang
     , a.is_encrypted
  from set_parameter a
     , com_language_vw b
/