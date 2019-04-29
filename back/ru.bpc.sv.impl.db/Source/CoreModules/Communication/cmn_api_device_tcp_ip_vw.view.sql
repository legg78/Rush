create or replace force view cmn_api_device_tcp_ip_vw as
select
    a.id
  , a.seqnum
  , a.remote_address
  , a.local_port
  , a.remote_port
  , a.initiator
  , a.format
  , a.keep_alive
  , a.monitor_connection
  , a.multiple_connection
from
    cmn_tcp_ip a
  , cmn_device b
where
    a.id         = b.id
and
    b.is_enabled = 1
and exists(
    select 1 from cmn_standard_object s where s.object_id = b.id and s.entity_type = 'ENTTCMDV')
/
