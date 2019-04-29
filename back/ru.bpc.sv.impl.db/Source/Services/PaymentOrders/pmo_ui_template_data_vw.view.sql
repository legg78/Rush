create or replace force view pmo_ui_template_data_vw as
select a.id
     , a.order_id
     , a.param_id
     , a.param_value
     , get_number_value(b.data_type, a.param_value) param_number_value
     , get_char_value  (b.data_type, a.param_value) param_char_value
     , get_date_value  (b.data_type, a.param_value) param_date_value
     , get_lov_value   (b.data_type, a.param_value, b.lov_id) param_lov_value
  from pmo_order_data a
     , pmo_parameter b
 where a.param_id    = b.id
/
