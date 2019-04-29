create or replace force view nbc_ui_session_log_vw 
as 
  select rownum            as id
       , t.trace_timestamp as event_date
       , t.trace_level     as log_level
       , t.user_id         as logger
       , t.trace_text      as message
       , f.session_id      as session_id
       , f.id as file_id
    from nbc_file m
       , prc_session_file f
       , trc_log t 
   where m.session_file_id = f.id
     and t.session_id      = f.session_id
order by f.session_id
       , t.trace_timestamp  
/
