create or replace force view cmn_ui_version_parameter_vw as
select p.version_id 
     , p.standard_id
     , p.param_id
     , p.param_name
     , p.param_entity_type
     , p.data_type
     , p.lov_id
     , p.default_value
     , p.param_value
     , p.id
     , p.object_id
     , p.entity_type
     , get_text('cmn_parameter', 'caption', p.param_id, l.lang)      caption
     , get_text('cmn_parameter', 'description', p.param_id, l.lang)  description
     , p.scale_id
     , get_text('rul_mod_scale', 'name', p.scale_id, l.lang) scale_name
     , p.mod_id
     , get_text('rul_mod', 'name', p.mod_id, l.lang) mod_name
     , l.lang                                                        lang
     , get_number_value(p.data_type, p.default_value) default_number_value
     , get_char_value  (p.data_type, p.default_value) default_char_value
     , get_date_value  (p.data_type, p.default_value) default_date_value
     , get_lov_value   (p.data_type, p.default_value, p.lov_id) default_lov_value
     , get_number_value(p.data_type, p.param_value) param_number_value
     , get_char_value  (p.data_type, p.param_value) param_char_value
     , get_date_value  (p.data_type, p.param_value) param_date_value
     , get_lov_value   (p.data_type, p.param_value, p.lov_id) param_lov_value
     , xml_value
     , xml_default_value
     , p.pattern
  from cmn_api_version_parameter_vw p
     , com_language_vw l
/