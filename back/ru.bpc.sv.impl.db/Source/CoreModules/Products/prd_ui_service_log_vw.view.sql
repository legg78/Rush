create or replace force view prd_ui_service_log_vw as
select
    n.id
    , n.service_object_id
    , n.start_date
    , n.end_date
    , n.split_hash
from
    prd_service_log n
/
