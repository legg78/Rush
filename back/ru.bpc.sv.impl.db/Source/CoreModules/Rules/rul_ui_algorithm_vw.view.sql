create or replace force view rul_ui_algorithm_vw as
select a.id
     , a.seqnum
     , a.algorithm
     , com_api_dictionary_pkg.get_article_text(
           i_article      => a.algorithm
         , i_lang         => l.lang
       ) as algorithm_name
     , a.entry_point
     , com_api_dictionary_pkg.get_article_text(
           i_article      => a.entry_point
         , i_lang         => l.lang
       ) as entry_point_name
     , p.id as proc_id
     , p.proc_name as procedure_name
     , com_api_i18n_pkg.get_text(
           i_table_name   => 'rul_proc'
         , i_column_name  => 'name'
         , i_object_id    => p.id
         , i_lang         => l.lang
       ) as procedure_caption
     , com_api_i18n_pkg.get_text(
           i_table_name   => 'rul_proc'
         , i_column_name  => 'description'
         , i_object_id    => p.id
         , i_lang         => l.lang
       ) as procedure_description
     , l.lang
  from rul_algorithm a
     , rul_proc p
     , com_language_vw l
 where a.proc_id = p.id
/
