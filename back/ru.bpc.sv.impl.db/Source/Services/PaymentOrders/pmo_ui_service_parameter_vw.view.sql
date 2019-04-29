create or replace force view pmo_ui_service_parameter_vw as
select a.service_id
     , b.param_id
     , c.param_name
     , c.label
     , c.description
     , c.data_type
     , c.lov_id
     , c.pattern
     , b.order_stage
     , b.display_order
     , b.is_mandatory
     , b.is_template_fixed
     , b.is_editable
     , b.default_value
     , c.lang
     , get_number_value(c.data_type, b.default_value) default_number_value
     , get_char_value  (c.data_type, b.default_value) default_char_value
     , get_date_value  (c.data_type, b.default_value) default_date_value
     , get_lov_value   (c.data_type, b.default_value, c.lov_id) default_lov_value
  from pmo_purpose a
     , pmo_purpose_parameter b
     , pmo_ui_parameter_vw c
 where a.id = b.purpose_id
   and b.param_id = c.id
/
