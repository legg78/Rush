create or replace force view acm_ui_widget_vw as
select w.id
     , w.seqnum
     , w.path
     , w.css_name
     , w.is_external
     , w.width
     , w.height
     , w.priv_id
     , w.params_path
     , get_text(
           i_table_name  => 'acm_widget'
         , i_column_name => 'label'
         , i_object_id   => w.id
         , i_lang        => l.lang 
       )label
     , get_text(
           i_table_name  => 'acm_widget'
         , i_column_name => 'description'
         , i_object_id   => w.id
         , i_lang        => l.lang 
       ) description
     , l.lang
  from acm_widget w
     , com_language_vw l
/