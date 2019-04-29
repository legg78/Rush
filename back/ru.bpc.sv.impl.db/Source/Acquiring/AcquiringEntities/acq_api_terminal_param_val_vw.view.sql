create or replace force view acq_api_terminal_param_val_vw as
with trmn as (
    select m.id terminal_id
         , m.terminal_number
         , min(s.id) standard_id
         , max(ov.version_id) keep (dense_rank first order by ov.start_date desc) version_id
      from acq_terminal m
         , cmn_standard_version_obj ov
         , cmn_standard_version v
         , cmn_standard s
     where m.id            = ov.object_id
       and ov.entity_type  = 'ENTTTRMN'
       and ov.start_date  <= get_sysdate
       and ov.version_id   = v.id
       and v.standard_id   = s.id
       and s.standard_type = 'STDT0002'
  group by m.id
         , m.terminal_number
    ),
version_parameter as (
    select
        v.id                version_id 
        , v.standard_id     standard_id
        , a.id              param_id
        , a.name            param_name
        , a.entity_type     entity_type
        , a.data_type       data_type
        , a.lov_id          lov_id
        , a.default_value   default_value
        , a.xml_default_value
        , a.scale_id
    from 
        cmn_standard_version v
        , cmn_parameter a
    where
        v.standard_id = a.standard_id
),
ifc_param as (
    select trmn.terminal_id
         , trmn.terminal_number
         , trmn.standard_id
         , trmn.version_id
         , pr.param_id
         , pr.param_name
         , pr.data_type
         , pr.default_value
         , pr.xml_default_value
      from trmn
         , version_parameter pr
     where trmn.version_id = pr.version_id
       and pr.entity_type  = 'ENTTTRMN'
    )
select i.terminal_id
     , i.terminal_number
     , i.standard_id
     , i.version_id
     , i.param_id
     , i.param_name
     , i.data_type
     , coalesce(v1.param_value, v2.param_value, i.default_value) param_value
     , coalesce(v1.xml_value, v2.xml_value, i.xml_default_value) xml_param_value
  from ifc_param i
     , cmn_parameter_value v1
     , cmn_parameter_value v2
 where v1.param_id(+)     = i.param_id
   and v1.entity_type(+)  = 'ENTTTRMN'
   and v1.object_id(+)    = i.terminal_id
   and v1.standard_id(+)  = i.standard_id
   and v1.version_id(+)   = i.version_id
   and v2.param_id(+)     = i.param_id
   and v2.entity_type(+)  = 'ENTTTRMN'
   and v2.object_id(+)    = i.terminal_id
   and v2.standard_id(+)  = i.standard_id
   and v2.version_id(+)   is null
/
