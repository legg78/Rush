create or replace force view svy_ui_survey_parameter_vw as
select s.id
     , s.survey_id
     , s.param_id
     , p.param_name
     , get_text(
           i_table_name   => 'svy_parameter'
         , i_column_name  => 'name'
         , i_object_id    => p.id
         , i_lang         => l.lang
       ) as name
     , p.data_type
     , get_article_text(i_article  => p.data_type) as data_type_name
     , p.is_system_param
     , l.lang
  from svy_survey_parameter s
     , svy_parameter p
     , com_language_vw l
 where s.param_id = p.id
/
