create or replace force view cmn_ui_parameter_vw as
select a.id
     , a.standard_id
     , a.name
     , a.entity_type
     , a.data_type
     , a.lov_id
     , a.default_value
     , a.scale_id
     , get_text('rul_mod_scale', 'name', a.scale_id, b.lang) scale_name
     , get_text('cmn_parameter', 'caption', a.id, b.lang) caption
     , get_text('cmn_parameter', 'description', a.id, b.lang) description
     , b.lang
     , get_number_value(a.data_type, a.default_value) default_number_value
     , get_char_value  (a.data_type, a.default_value) default_char_value
     , get_date_value  (a.data_type, a.default_value) default_date_value
     , get_lov_value   (a.data_type, a.default_value, a.lov_id) default_lov_value
     , a.xml_default_value
     , a.pattern
     , get_text('cmn_parameter', 'pattern_desc', a.id, b.lang) pattern_desc
  from cmn_parameter a
     , com_language_vw b
/