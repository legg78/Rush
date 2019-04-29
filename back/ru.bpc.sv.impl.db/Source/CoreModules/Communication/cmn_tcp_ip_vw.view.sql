create or replace force view cmn_tcp_ip_vw as
select id
     , remote_address
     , local_port
     , remote_port
     , initiator
     , format
     , keep_alive
     , seqnum
     , is_enabled
     , monitor_connection
     , multiple_connection
  from cmn_tcp_ip
/
