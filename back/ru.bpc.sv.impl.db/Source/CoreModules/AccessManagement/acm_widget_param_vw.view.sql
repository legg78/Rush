create or replace force view acm_widget_param_vw as
select 
    n.id
    , n.seqnum
    , n.param_name
    , n.data_type
    , n.lov_id
    , n.widget_id
from 
    acm_widget_param n
/
