create or replace force view com_ui_array_conversion_vw as
select c.id
     , c.seqnum
     , c.in_array_id
     , c.in_lov_id
     , c.out_array_id
     , c.out_lov_id
     , c.conv_type
     , get_text (
           i_table_name  => 'com_array_conversion'
         , i_column_name => 'label'
         , i_object_id   => c.id
         , i_lang        => l.lang
       ) label
     , get_text (
           i_table_name  => 'com_array_conversion'
         , i_column_name => 'description'
         , i_object_id   => c.id
         , i_lang        => l.lang
       ) description
     , l.lang
  from com_array_conversion c
     , com_language_vw l
/