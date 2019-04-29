create or replace force view cmn_ui_device_vw as
select a.id
     , a.seqnum
     , a.communication_plugin
     , s.standard_id
     , a.inst_id
     , a.is_enabled
     , get_text ('cmn_device', 'caption', a.id, b.lang) caption
     , get_text ('cmn_device', 'description', a.id, b.lang) description
     , b.lang
  from cmn_device a
     , cmn_standard_object s
     , com_language_vw b
 where 
    a.inst_id in (select inst_id from acm_cu_inst_vw)
    and a.id = s.object_id
    and s.entity_type = 'ENTTCMDV'
    and s.standard_type in ('STDT0001', 'STDT0002')
/