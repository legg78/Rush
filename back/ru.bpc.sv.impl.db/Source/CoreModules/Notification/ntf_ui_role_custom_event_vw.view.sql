create or replace force view ntf_ui_role_custom_event_vw as
select c.id
     , x.scheme_id
     , x.scheme_event_id
     , x.object_id
     , nvl(c.channel_id, x.channel_id) channel_id
     , c.delivery_address
     , nvl(c.delivery_time, x.delivery_time) delivery_time
     , nvl(c.status, x.status) status
     , c.mod_id
     , x.inst_id
     , x.event_type
     , x.entity_type 
     , c.start_date
     , c.end_date
     , get_text('ost_institution', 'name', x.inst_id, l.lang) inst_name
     , get_text('rul_mod', 'name', c.mod_id, l.lang) mod_name
     , get_text('ntf_channel', 'name', nvl(c.channel_id, x.channel_id), l.lang) channel_name
     , l.lang
  from (     
        select s.id scheme_id
             , e.id scheme_event_id
             , r.id object_id
             , e.channel_id
             , e.delivery_time
             , e.status
             , s.inst_id
             , e.event_type
             , e.entity_type 
          from ntf_scheme s
             , acm_role r 
             , ntf_scheme_event e
         where e.scheme_id = s.id
           and s.id        = r.notif_scheme_id
       ) x
     , ntf_custom_event c
     , com_language_vw l
 where 'ENTTROLE'   = c.entity_type(+)
   and x.object_id  = c.object_id(+)
   and x.event_type = c.event_type(+)
/
