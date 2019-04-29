create or replace force view cmn_ui_tcp_ip_vw as
select a.id
     , a.remote_address
     , a.local_port
     , a.remote_port
     , a.initiator
     , a.format
     , a.keep_alive
     , a.seqnum
     , b.is_enabled
     , a.monitor_connection
     , a.multiple_connection
  from cmn_tcp_ip a
     , cmn_device b
 where a.id = b.id
/