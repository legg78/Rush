create or replace force view acm_ui_dashboard_vw as
select d.id
     , d.seqnum
     , d.user_id
     , d.inst_id
     , d.is_shared
     , get_text(
           i_table_name  => 'acm_dashboard'
         , i_column_name => 'label'
         , i_object_id   => d.id
         , i_lang        => l.lang 
       )label
     , get_text(
           i_table_name  => 'acm_dashboard'
         , i_column_name => 'description'
         , i_object_id   => d.id
         , i_lang        => l.lang 
       ) description
     , l.lang
  from acm_dashboard d
     , com_language_vw l
/