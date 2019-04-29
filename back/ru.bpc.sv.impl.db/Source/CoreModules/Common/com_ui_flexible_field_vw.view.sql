create or replace force view com_ui_flexible_field_vw as
select a.id
     , a.entity_type
     , a.object_type
     , a.name
     , a.data_type
     , a.data_format
     , a.lov_id
     , a.is_user_defined
     , a.inst_id
     , a.default_value
     , b.lang
     , get_text('com_flexible_field', 'label', a.id, b.lang) label 
     , get_text('com_flexible_field', 'description', a.id, b.lang) description
     , get_number_value(a.data_type, a.default_value, a.data_format) default_number_value
     , get_char_value  (a.data_type, a.default_value) default_char_value
     , get_date_value  (a.data_type, a.default_value) default_date_value
     , get_lov_value   (a.data_type, a.default_value, a.lov_id) default_lov_value
  from com_flexible_field a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/ 