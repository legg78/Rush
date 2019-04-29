create or replace force view net_api_interface_param_val_vw as
with hst as (
    select m.id host_member_id
         , s.standard_type
         , v.standard_id
         , max(ov.version_id) keep (dense_rank first order by ov.start_date desc) version_id
      from net_member m
         , cmn_standard_version_obj ov
         , cmn_standard_version v
         , cmn_standard s
     where m.id = ov.object_id
       and ov.entity_type  = 'ENTTHOST'
       and ov.start_date  <= get_sysdate
       and ov.version_id   = v.id
       and v.standard_id   = s.id
       and s.standard_type in ('STDT0001', 'STDT0201')
  group by m.id
         , s.standard_type
         , v.standard_id
),
ifc_param as (
    select ifc.id                  interface_id
         , ifc.host_member_id      host_member_id
         , ifc.consumer_member_id  consumer_member_id
         , hst.standard_id
         , hst.version_id
         , pr.param_id
         , pr.param_name
         , pr.data_type
         , nvl(pr.param_value, pr.default_value)     default_value
         , nvl(pr.xml_value,   pr.xml_default_value) xml_default_value
         , ifc.msp_member_id
      from hst
         , cmn_api_version_parameter_vw pr
         , net_interface ifc
     where hst.version_id       = pr.version_id
       and pr.param_entity_type = 'ENTTNIFC'
       and hst.host_member_id   = ifc.host_member_id
    )
select i.interface_id
     , i.host_member_id
     , i.consumer_member_id
     , i.standard_id
     , i.version_id
     , i.param_id
     , i.param_name
     , i.data_type
     , coalesce(v1.param_value, v2.param_value, i.default_value)     param_value
     , coalesce(v1.xml_value,   v2.xml_value,   i.xml_default_value) xml_param_value
     , d.device_id
     , i.msp_member_id
  from ifc_param i
      , net_device d
      , cmn_parameter_value v1
      , cmn_parameter_value v2
  where v1.param_id(+)     = i.param_id
    and v1.entity_type(+)  = 'ENTTNIFC'
    and v1.object_id(+)    = i.interface_id
    and v1.standard_id(+)  = i.standard_id
    and v1.version_id(+)   = i.version_id
    and v2.param_id(+)     = i.param_id
    and v2.entity_type(+)  = 'ENTTNIFC'
    and v2.object_id(+)    = i.interface_id
    and v2.standard_id(+)  = i.standard_id
    and v2.version_id(+)   is null
    and i.host_member_id   = d.host_member_id(+)
/
