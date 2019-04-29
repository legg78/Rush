create or replace force view net_api_device_vw as
select a.device_id
     , c.seqnum member_seqnum
     , a.host_member_id
     , nvl(b.is_signed_on, 0) is_signed_on
     , nvl(b.is_connected, 0) is_connected
     , nvl(b.is_in_stand_in, 0) is_in_stand_in
     , c.inst_id
     , c.network_id
     , (select application_plugin 
          from cmn_api_device_standard_vw x
         where x.device_id  = a.device_id) as app_plugin
  from net_device a
     , net_device_dynamic b
     , net_member c
 where a.device_id      = b.device_id(+)
   and a.host_member_id = c.id
   and c.status        != 'HSST0002'
/
