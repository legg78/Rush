create or replace force view acm_ui_priv_limit_field_vw as
select id
     , priv_limit_id
     , field
     , condition
     , label_id
     , get_text(
           i_table_name  => 'com_label'
         , i_column_name => 'name'
         , i_object_id   => plf.label_id
         , i_lang        => lang.lang
       ) label
     , lang.lang
  from acm_priv_limit_field plf
     , com_language_vw lang
/
