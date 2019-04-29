create or replace force view cmn_ui_device_connection_vw as
select
    n.device_id
    , n.connect_number
    , n.status
from
    cmn_device_connection n
/
