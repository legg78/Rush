create or replace force view acm_widget_param_value_vw as
select 
    v.id
    , v.seqnum
    , v.param_value
    , v.widget_param_id
    , v.dashboard_widget_id
from 
    acm_widget_param_value v
/
