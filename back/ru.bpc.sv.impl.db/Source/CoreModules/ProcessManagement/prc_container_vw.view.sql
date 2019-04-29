create or replace force view prc_container_vw as
select t.id
     , t.container_process_id
     , t.process_id
     , t.exec_order
     , t.is_parallel
     , t.error_limit
     , t.track_threshold
     , t.parallel_degree
     , t.stop_on_fatal
     , t.trace_level
     , t.debug_writing_mode
     , t.start_trace_size
     , t.error_trace_size
     , t.max_duration
     , t.min_speed
  from prc_container t
/
