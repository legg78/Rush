create or replace force view pmo_ui_purpose_parameter_vw as
select a.id
     , a.seqnum
     , a.param_id
     , b.param_name
     , b.label
     , b.description
     , b.data_type
     , b.lov_id
     , a.purpose_id
     , c.host_algorithm
     , a.order_stage
     , a.display_order
     , a.is_mandatory
     , a.is_template_fixed
     , a.is_editable
     , a.default_value
     , a.param_function
     , b.tag_id
     , b.lang
     , get_number_value(b.data_type, a.default_value) default_number_value
     , get_char_value  (b.data_type, a.default_value) default_char_value
     , get_date_value  (b.data_type, a.default_value) default_date_value
     , get_lov_value   (b.data_type, a.default_value, b.lov_id) default_lov_value
  from pmo_purpose_parameter a
     , pmo_ui_parameter_vw b
     , pmo_purpose c
 where a.param_id = b.id
   and a.purpose_id = c.id
/
