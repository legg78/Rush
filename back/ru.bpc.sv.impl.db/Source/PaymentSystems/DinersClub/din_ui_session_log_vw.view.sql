create or replace force view din_ui_session_log_vw
as
  select rownum            as id
       , l.trace_timestamp as event_date
       , l.trace_level     as log_level
       , l.user_id         as logger
       , l.trace_text      as message
       , f.session_id
       , f.id as file_id
    from din_file d
    join prc_session_file f on f.id         = d.id
    join trc_log l          on l.session_id = f.session_id
order by f.session_id
       , l.trace_timestamp
/
