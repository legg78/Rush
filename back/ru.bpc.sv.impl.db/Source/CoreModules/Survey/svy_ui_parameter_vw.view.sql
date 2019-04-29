create or replace force view svy_ui_parameter_vw as
select p.id
     , p.seqnum
     , p.param_name
     , get_text(
           i_table_name   => 'svy_parameter'
         , i_column_name  => 'name'
         , i_object_id    => p.id
         , i_lang         => l.lang
       ) as name
     , get_text(
           i_table_name   => 'svy_parameter'
         , i_column_name  => 'description'
         , i_object_id    => p.id
         , i_lang         => l.lang
       ) as description
     , p.data_type
     , get_article_text(i_article  => p.data_type) as data_type_name
     , p.display_order
     , p.lov_id
     , get_text(
           i_table_name   => 'com_lov'
         , i_column_name  => 'name'
         , i_object_id    => p.lov_id
         , i_lang         => l.lang
       ) as lov_name
     , p.is_multi_select
     , p.is_system_param
     , p.table_name
     , l.lang
  from svy_parameter p
     , com_language_vw l
/
