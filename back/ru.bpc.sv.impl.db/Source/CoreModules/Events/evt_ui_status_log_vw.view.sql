create or replace force view evt_ui_status_log_vw as
select a.id
     , a.event_type
     , a.entity_type
     , a.object_id
     , a.initiator
     , a.change_date
     , a.status
     , a.reason
     , a.user_id
     , a.session_id
     , c.first_name||' '||c.surname user_name
     , l.lang
     , a.event_date
  from evt_status_log a
     , acm_user b
     , com_person c
     , com_language_vw l
 where a.user_id   = b.id
   and b.person_id = c.id
   and (select min(cp.lang) keep (dense_rank first
                                  order by decode(cp.lang, l.lang, 1,  l.lang, 2, 3)
                                 )
          from com_person cp
         where cp.id = c.id) = c.lang
/
