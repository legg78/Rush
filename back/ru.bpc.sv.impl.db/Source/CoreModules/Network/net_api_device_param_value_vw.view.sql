create or replace force view net_api_device_param_value_vw as
with dev as (
    select d.device_id
         , d.host_member_id
         , max(s.id) keep (dense_rank first order by ov.start_date desc) standard_id
         , max(ov.version_id) keep (dense_rank first order by ov.start_date desc) version_id
      from net_device d
         , cmn_standard_version_obj ov
         , cmn_standard_version v
         , cmn_standard s
     where d.host_member_id = ov.object_id
       and ov.entity_type   = 'ENTTHOST'
       and ov.start_date   <= get_sysdate
       and ov.version_id    = v.id
       and v.standard_id    = s.id
       and s.standard_type  in ( 'STDT0001', 'STDT0000' )
  group by d.device_id
         , d.host_member_id
         , s.standard_type
),
dev_param as (
    select dev.device_id
         , dev.host_member_id
         , dev.standard_id
         , dev.version_id
         , pr.param_id
         , pr.param_name
         , pr.data_type
         , nvl(pr.param_value, pr.default_value) default_value
         , nvl(pr.xml_value,   pr.xml_default_value) xml_default_value
      from dev
         , cmn_api_version_parameter_vw pr
     where dev.version_id       = pr.version_id
       and pr.param_entity_type = 'ENTTCMDV'
    )
select p.device_id
     , p.standard_id
     , p.version_id
     , p.param_id
     , p.param_name
     , p.data_type
     , coalesce(v1.param_value, v2.param_value, p.default_value) param_value
     , coalesce(v1.xml_value,   v2.xml_value,   p.xml_default_value) xml_param_value
  from dev_param p
     , cmn_parameter_value v1
     , cmn_parameter_value v2
 where v1.param_id(+)     = p.param_id
   and v1.entity_type(+)  = 'ENTTCMDV'
   and v1.object_id(+)    = p.device_id
   and v1.standard_id(+)  = p.standard_id
   and v1.version_id(+)   = p.version_id
   and v2.param_id(+)     = p.param_id
   and v2.entity_type(+)  = 'ENTTCMDV'
   and v2.object_id(+)    = p.device_id
   and v2.standard_id(+)  = p.standard_id
   and v2.version_id(+)   is null
/
