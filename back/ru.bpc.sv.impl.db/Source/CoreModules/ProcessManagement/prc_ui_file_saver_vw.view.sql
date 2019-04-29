create or replace force view prc_ui_file_saver_vw as
select s.id
     , s.seqnum
     , s.source
     , s.is_parallel
     , s.post_source
     , get_text(
           i_table_name  => 'prc_file_saver'
         , i_column_name => 'name'
         , i_object_id   => s.id
         , i_lang        => l.lang
       ) name
     , l.lang
  from prc_file_saver s
     , com_language_vw l 
/
