create or replace force view cmn_device_vw as
select a.id
     , a.seqnum
     , a.communication_plugin
     , a.inst_id
     , a.is_enabled
  from cmn_device a
/