create or replace force view com_ui_flexible_data_vw as
select b.id
     , b.field_id
     , b.seq_number
     , b.object_id
     , b.field_value
     , a.entity_type
     , a.object_type
     , a.name
     , a.data_type
     , a.data_format
     , a.lov_id
     , a.is_user_defined
     , a.inst_id
     , get_text ('com_flexible_field', 'description', a.id, c.lang) description
     , c.lang
     , get_number_value(a.data_type, b.field_value, a.data_format) field_number_value
     , get_char_value  (a.data_type, b.field_value) field_char_value
     , get_date_value  (a.data_type, b.field_value) field_date_value
     , get_lov_value   (a.data_type, b.field_value, a.lov_id) field_lov_value
  from com_flexible_field a
     , com_flexible_data b
     , com_language_vw c
 where b.field_id = a.id 
   and a.inst_id in (select inst_id from acm_cu_inst_vw) 
/ 