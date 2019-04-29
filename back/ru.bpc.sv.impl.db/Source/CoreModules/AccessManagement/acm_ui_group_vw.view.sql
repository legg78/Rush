create or replace force view acm_ui_group_vw as
select g.id
     , g.inst_id
     , g.seqnum
     , g.creation_date
     , get_text(
           i_table_name  => 'ACM_GROUP'
         , i_column_name => 'NAME'
         , i_object_id   => g.id
         , i_lang        => l.lang
       ) as description
     , l.lang
  from acm_group g
     , com_language_vw l
/
