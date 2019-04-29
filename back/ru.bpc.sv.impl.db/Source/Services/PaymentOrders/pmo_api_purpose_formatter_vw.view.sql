create or replace force view pmo_api_purpose_formatter_vw as
with standards as (
    select s.id standard_id
         , s.application_plugin
         , ov.object_id host_id
         , max(ov.version_id) keep (dense_rank first order by ov.start_date desc) version_id
      from cmn_standard_version_obj ov
         , cmn_standard_version v
         , cmn_standard s
     where ov.entity_type  = 'ENTTHOST'
       and ov.start_date  <= get_sysdate
       and v.id            = ov.version_id
       and s.id            = v.standard_id
       and s.standard_type = 'STDT0001'
  group by s.id
         , s.application_plugin
         , ov.object_id
)
select st.host_id
     , st.application_plugin
     , f.id
     , f.seqnum
     , f.purpose_id
     , f.paym_aggr_msg_type
     , f.formatter
  from pmo_purpose_formatter f
     , standards st
 where st.version_id  = f.version_id
   and st.standard_id = f.standard_id
/
