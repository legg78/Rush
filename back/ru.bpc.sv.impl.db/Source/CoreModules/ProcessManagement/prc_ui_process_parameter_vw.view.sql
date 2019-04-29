create or replace force view prc_ui_process_parameter_vw as
select c.id
     , b.id as param_id
     , a.id as process_id
     , b.param_name
     , get_text('prc_parameter', 'label', b.id, d.lang) as label
     , get_text('prc_process_parameter', 'description', c.id, d.lang) as description
     , d.lang
     , b.data_type
     , nvl(c.lov_id, b.lov_id) as lov_id
     , c.default_value
     , c.is_format
     , c.is_mandatory
     , c.display_order
     , a.procedure_name
     , get_number_value(b.data_type, c.default_value) default_number_value
     , get_char_value  (b.data_type, c.default_value) default_char_value
     , get_date_value  (b.data_type, c.default_value) default_date_value
     , get_lov_value   (b.data_type, c.default_value, b.lov_id) default_lov_value
     , b.parent_id
  from prc_process a
     , prc_parameter b
     , prc_process_parameter c
     , com_language_vw d
 where a.id = c.process_id
   and b.id = c.param_id
/
