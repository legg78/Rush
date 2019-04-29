create or replace force view trc_ui_log_vw as
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
     , case when length(l.trace_text) > 200 then l.trace_text
            else trc_log_pkg.get_text(l.label_id, l.trace_text)
       end text
     , trc_log_pkg.get_details(i_label_id => label_id, i_trace_text => trace_text) as details
  from trc_log l
/
