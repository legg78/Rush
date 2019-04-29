create or replace force view hsm_connection_vw as
select
   n.hsm_device_id
   , n.status
   , n.connect_number
   , n.action
from
   hsm_connection n
/