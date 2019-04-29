create or replace force view trc_log_vw as
select l.trace_timestamp
     , l.trace_level
     , l.trace_text
     , l.trace_section
     , l.user_id
     , l.session_id
     , l.thread_number
     , l.entity_type
     , l.object_id
     , l.event_id
     , l.label_id
     , l.inst_id
     , l.who_called
     , to_char(null) text
  from trc_log l
/
