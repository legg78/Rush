create or replace force view cmn_ui_parameter_value_vw as
select a.id
     , a.param_id
     , a.standard_id
     , a.version_id
     , a.entity_type
     , a.object_id
     , a.param_value
     , a.xml_value
     , a.mod_id
     , get_text('rul_mod', 'name', a.mod_id, c.lang) mod_name
     , b.name
     , b.data_type
     , b.lov_id
     , get_text('cmn_standard_param', 'caption', b.id, c.lang) caption
     , get_text('cmn_standard_param', 'description', b.id, c.lang) description
     , c.lang
     , get_number_value(b.data_type, a.param_value) param_number_value
     , get_char_value  (b.data_type, a.param_value) param_char_value
     , get_date_value  (b.data_type, a.param_value) param_date_value
     , get_lov_value   (b.data_type, a.param_value, b.lov_id) param_lov_value
     , b.scale_id
     , get_text('rul_mod_scale', 'name', b.scale_id, c.lang) scale_name
  from cmn_parameter b
     , cmn_parameter_value a
     , com_language_vw c
 where b.id = a.param_id
/
