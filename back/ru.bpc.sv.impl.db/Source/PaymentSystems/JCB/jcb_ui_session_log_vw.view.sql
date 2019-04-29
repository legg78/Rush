create or replace force view jcb_ui_session_log_vw as 
select rownum id
     , t.trace_timestamp event_date
     , t.trace_level log_level
     , t.user_id logger
     , t.trace_text message
     , f.session_id
     , f.id as file_id
  from jcb_file l
     , prc_session_file f
     , trc_log t 
 where l.session_file_id = f.id
   and t.session_id = f.session_id
 order by f.session_id
     , t.trace_timestamp  
/
