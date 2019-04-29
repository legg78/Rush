create or replace force view com_ui_array_type_vw as
select t.id
     , t.seqnum
     , t.name
     , t.is_unique
     , t.lov_id
     , t.entity_type
     , t.data_type
     , t.inst_id
     , get_text (
           i_table_name  => 'com_array_type'
         , i_column_name => 'label'
         , i_object_id   => t.id
         , i_lang        => l.lang
       ) label
     , get_text (
           i_table_name  => 'com_array_type'
         , i_column_name => 'description'
         , i_object_id   => t.id
         , i_lang        => l.lang
       ) description
     , t.scale_type  
     , l.lang
     , t.class_name
  from com_array_type t
     , com_language_vw l
/