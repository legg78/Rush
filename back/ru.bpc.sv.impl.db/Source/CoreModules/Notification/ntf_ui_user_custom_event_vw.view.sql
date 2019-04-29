create or replace force view ntf_ui_user_custom_event_vw as
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
     , x.is_customizable
  from (select s.id as scheme_id
             , e.id as scheme_event_id
             , u.id as object_id
             , e.channel_id
             , e.delivery_time
             , e.status
             , s.inst_id
             , e.event_type
             , e.entity_type
             , e.is_customizable 
          from ntf_scheme s
             , acm_user u
             , ntf_scheme_event e
         where e.scheme_id = s.id
           and (s.id, u.id) in (
                select b.notif_scheme_id
                     , r.user_id
                  from acm_role b,
                       (select d.user_id
                             , d.role_id
                             , 'DIRECT' as grant_type
                          from acm_user_role d
                         union all
                        select user_id
                             , role_id
                             , grant_type
                          from (select a.user_id
                                     , b.child_role_id role_id
                                     , 'SUBROLES' as grant_type
                                  from acm_user_role a
                                     , acm_role_role b
                                 where a.role_id = b.parent_role_id
                            connect by prior b.child_role_id = b.parent_role_id)
                         where (user_id, role_id) not in (select user_id, role_id from acm_user_role)
                       ) r
                 where r.role_id = b.id
               )
       ) x
     , ntf_custom_event c
     , com_language_vw l
 where 'ENTTUSER'        = c.entity_type(+)
   and x.object_id       = c.object_id(+)
   and x.event_type      = c.event_type(+)
   and x.scheme_event_id = c.scheme_event_id(+)
/




