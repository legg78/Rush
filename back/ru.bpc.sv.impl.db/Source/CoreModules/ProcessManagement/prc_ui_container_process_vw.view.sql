create or replace force view prc_ui_container_process_vw as
select t.id
     , t.container_process_id
     , t.process_id
     , t.exec_order
     , t.is_parallel
     , t.error_limit
     , t.track_threshold
     , get_text (i_table_name => 'prc_process',
                 i_column_name => 'name',
                 i_object_id => p.id,
                 i_lang => l.lang
       ) name
     , get_text (i_table_name => 'prc_process',
                 i_column_name => 'description',
                 i_object_id => p.id,
                 i_lang => l.lang
       ) description
     , l.lang
     , p.inst_id
     , p.is_container
     , t.parallel_degree
     , get_text (i_table_name    => 'prc_container',
                 i_column_name   => 'description',
                 i_object_id     => t.id,
                 i_lang          => l.lang
       ) link_description
     , t.stop_on_fatal  
     , t.trace_level
     , t.debug_writing_mode
     , t.start_trace_size
     , t.error_trace_size
     , t.max_duration
     , t.min_speed
  from prc_container t
     , prc_process p
     , com_language_vw l 
 where t.process_id = p.id
/
