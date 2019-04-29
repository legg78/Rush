create or replace force view hsm_selection_vw as
select 
    n.id
    , n.seqnum
    , n.hsm_device_id
    , n.action
    , n.inst_id
    , n.mod_id
    , n.max_connection
    , n.firmware
from 
    hsm_selection n
/
