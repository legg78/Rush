create or replace force view app_ui_history_vw as
select a.id
     , a.seqnum
     , a.appl_id
     , a.change_date
     , a.change_user
     , a.change_action
     , u.name as user_name
     , a.appl_status
     , a.comments
     , case 
           when a.change_action like 'EVNT%'
           then get_article_text(a.change_action, get_user_lang)
           else l.text
       end as change_action_name
     , a.reject_code
  from app_history a
     , acm_user u
     , com_ui_label_vw l
 where u.id(+)         = a.change_user
   and l.name(+)       = a.change_action
   and l.label_type(+) = 'INFO'
   and l.lang(+)       = get_user_lang
/
