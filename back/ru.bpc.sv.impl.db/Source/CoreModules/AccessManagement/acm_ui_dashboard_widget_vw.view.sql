create or replace force view acm_ui_dashboard_widget_vw as
select 
    n.id
    , n.seqnum
    , n.dashboard_id
    , n.widget_id
    , n.row_number
    , n.column_number
    , n.is_refresh
    , n.refresh_interval
from 
    acm_dashboard_widget n
/
