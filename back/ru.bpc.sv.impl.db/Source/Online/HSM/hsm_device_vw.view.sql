create or replace force view hsm_device_vw as
select
    n.id
    , n.is_enabled
    , n.seqnum
    , n.comm_protocol
    , n.plugin
    , n.manufacturer
    , n.serial_number
    , n.lmk_id
    , n.model_number
from
    hsm_device n
/
