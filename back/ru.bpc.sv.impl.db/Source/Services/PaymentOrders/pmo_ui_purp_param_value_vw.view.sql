create or replace force view pmo_ui_purp_param_value_vw as
select a.id
     , b.purpose_id
     , a.purp_param_id
     , c.param_name
     , c.label
     , c.description
     , c.data_type
     , c.lov_id
     , a.entity_type
     , a.object_id
     , a.param_value
     , c.lang
     , get_number_value(c.data_type, a.param_value) param_number_value
     , get_char_value  (c.data_type, a.param_value) param_char_value
     , get_date_value  (c.data_type, a.param_value) param_date_value
     , get_lov_value   (c.data_type, a.param_value, c.lov_id) param_lov_value
  from pmo_purp_param_value a
     , pmo_purpose_parameter b
     , pmo_ui_parameter_vw c
 where a.purp_param_id = b.id
   and b.param_id = c.id
/
