create or replace force view svy_ui_survey_vw as
select s.id
     , s.seqnum
     , s.inst_id
     , s.entity_type
     , get_article_text(i_article  => s.entity_type) as entity_type_name
     , s.survey_number
     , get_text(
           i_table_name   => 'svy_survey'
         , i_column_name  => 'name'
         , i_object_id    => s.id
         , i_lang         => l.lang
       ) as name
     , get_text(
           i_table_name   => 'svy_survey'
         , i_column_name  => 'description'
         , i_object_id    => s.id
         , i_lang         => l.lang
       ) as description
     , s.status
     , get_article_text(i_article  => s.status) as status_name
     , s.start_date
     , s.end_date
     , l.lang
  from svy_survey s
     , com_language_vw l
/
