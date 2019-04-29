create or replace force view pmo_ui_provider_host_vw as
select a.host_member_id
     , a.provider_id
     , a.execution_type
     , a.priority
     , a.mod_id
     , a.inactive_till  
     , b.network_id
     , s1.standard_id online_standard_id
     , s2.standard_id offline_standard_id
     , b.inst_id
     , a.status
  from pmo_provider_host_vw a
     , net_member_vw b
     , cmn_standard_object s1
     , cmn_standard_object s2
 where a.host_member_id = b.id
   and b.inst_id in (select inst_id from acm_cu_inst_vw )
   and b.id                = s1.object_id(+)
   and s1.entity_type(+)   = 'ENTTHOST'
   and s1.standard_type(+) = 'STDT0001'
   and b.id                = s2.object_id(+)
   and s2.entity_type(+)   = 'ENTTHOST'
   and s2.standard_type(+) = 'STDT0201'
/
