create or replace force view com_ui_array_vw as
select a.id
     , a.seqnum
     , a.array_type_id
     , a.inst_id
     , get_text (
           i_table_name  => 'com_array'
         , i_column_name => 'label'
         , i_object_id   => a.id
         , i_lang        => l.lang
       ) label
     , get_text (
           i_table_name  => 'com_array'
         , i_column_name => 'description'
         , i_object_id   => a.id
         , i_lang        => l.lang
       ) description
     , a.mod_id  
     , a.agent_id
     , l.lang     
     , a.is_private
     , t.class_name
  from com_array a
     , com_array_type t
     , com_language_vw l
 where a.array_type_id = t.id    
/