create or replace force view svy_ui_tag_vw as
select t.id
     , t.seqnum
     , get_text(
           i_table_name   => 'svy_tag'
         , i_column_name  => 'name'
         , i_object_id    => t.id
         , i_lang         => l.lang
       ) as name
     , t.inst_id
     , t.entity_type
     , get_article_text(i_article  => t.entity_type) as entity_type_name
     , t.condition
     , l.lang
  from svy_tag t
     , com_language_vw l
/
