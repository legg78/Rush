create or replace force view hsm_api_device_vw as
select
    a.id
    , a.comm_protocol
    , a.plugin
from 
    hsm_device a
where 
    a.is_enabled = 1
/