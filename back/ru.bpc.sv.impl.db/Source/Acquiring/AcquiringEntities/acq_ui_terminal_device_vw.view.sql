create or replace force view acq_ui_terminal_device_vw as
select dev.id
     , dev.seqnum
     , dev.communication_plugin
     , dev.standard_id
     , dev.inst_id
     , dev.caption
     , dev.description
     , dev.lang
     , tcp.remote_address
     , decode(tcp.local_port,'ANY','',tcp.local_port) local_port
     , decode(tcp.remote_port,'ANY','',tcp.remote_port) remote_port
     , tcp.initiator
     , tcp.format
     , tcp.keep_alive
     , tcp.is_enabled
     , tcp.monitor_connection
     , tcp.multiple_connection
     , std.label standard_name
     , inst.name inst_name
     , nvl(dd.status_ok, 0) status_ok
  from cmn_ui_device_vw dev
     , cmn_ui_tcp_ip_vw tcp
     , cmn_ui_standard_vw std
     , ost_ui_institution_sys_vw inst
     , (
        select device_id, count(device_id) as status_ok from cmn_ui_device_connection_vw
        where status = 'DCNSGOOD' group by device_id
     ) dd
 where dev.id = tcp.id(+)
   and std.id(+) = dev.standard_id
   and std.lang(+) = dev.lang
   and inst.id = dev.inst_id
   and inst.lang = dev.lang
   and dd.device_id(+) = dev.id
/
