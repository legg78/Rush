create or replace force view pmo_ui_order_data_vw as
select
    a.id
  , a.order_id
  , a.param_id
  , b.param_name
  , b.label
  , b.description
  , b.lang
  , b.data_type
  , b.lov_id
  , b.pattern
  , nvl(a.param_value, c.default_value) as param_value
  , c.purpose_id
  , c.order_stage
  , c.display_order
  , c.is_mandatory
  , c.is_template_fixed
  , c.is_editable
  , get_number_value(b.data_type, nvl(a.param_value, c.default_value)) param_number_value
  , get_char_value  (b.data_type, nvl(a.param_value, c.default_value)) param_char_value
  , get_date_value  (b.data_type, nvl(a.param_value, c.default_value)) param_date_value
  , get_lov_value   (b.data_type, nvl(a.param_value, c.default_value), b.lov_id) param_lov_value
from
    pmo_order_data a
  , pmo_ui_parameter_vw b
  , pmo_purpose_parameter c
  , pmo_order d
where
    a.param_id = b.id
and
    b.id = c.param_id
and
    d.purpose_id = c.purpose_id
and
    d.id = a.order_id
/
