create or replace force view acm_ui_widget_param_value_vw as
select 
    v.id
    , v.seqnum
    , get_number_value(p.data_type, v.param_value) param_number_value
    , get_char_value(p.data_type, v.param_value) param_char_value
    , get_date_value(p.data_type, v.param_value) param_date_value
    , get_lov_value(p.data_type, v.param_value, p.lov_id) param_lov_value
    , p.data_type
    , v.widget_param_id
    , v.dashboard_widget_id
from 
    acm_widget_param_value v
    , acm_widget_param p
where
    v.widget_param_id = p.id
/
