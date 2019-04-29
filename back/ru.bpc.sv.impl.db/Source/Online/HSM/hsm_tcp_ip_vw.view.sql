create or replace force view hsm_tcp_ip_vw as
select 
    n.id
    , n.address
    , n.port
    , n.max_connection
from 
    hsm_tcp_ip n
/
