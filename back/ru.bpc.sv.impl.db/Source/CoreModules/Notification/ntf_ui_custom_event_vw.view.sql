create or replace force view ntf_ui_custom_event_vw as
select c.id
     , s.id scheme_id
     , e.id scheme_event_id
     , c.object_id
     , nvl(c.channel_id, e.channel_id) channel_id
     , c.delivery_address
     , nvl(c.delivery_time, e.delivery_time) delivery_time
     , nvl(c.status, e.status) status
     , c.mod_id
     , s.inst_id
     , e.event_type
     , e.entity_type 
     , c.start_date
     , c.end_date
     , get_text('ost_institution', 'name', s.inst_id, l.lang) inst_name
     , get_text('rul_mod', 'name', c.mod_id, l.lang) mod_name
     , get_text('ntf_channel', 'name', nvl(c.channel_id, e.channel_id), l.lang) channel_name
     , l.lang
  from ntf_custom_event c
     , ntf_scheme s
     , ntf_scheme_event e
     , com_language_vw l
 where c.event_type(+) = e.event_type
   and nvl(c.contact_type(+), e.contact_type) = e.contact_type
   and e.scheme_id = s.id
   and s.inst_id in (select inst_id from acm_cu_inst_vw)
/
