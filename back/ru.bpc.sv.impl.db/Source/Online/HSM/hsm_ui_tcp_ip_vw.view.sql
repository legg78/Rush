create or replace force view hsm_ui_tcp_ip_vw as
select 
    a.id
    , b.address
    , b.port
    , b.max_connection
from 
    hsm_device a
    , hsm_tcp_ip b
where
    a.id = b.id
/