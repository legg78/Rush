create or replace force view h2h_ui_tag_value_vw as
select v.id
     , v.part_key
     , v.fin_id
     , v.tag_id
     , v.tag_value
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'aup_tag'
         , i_column_name => 'name'
         , i_object_id   => t.fe_tag_id
         , i_lang        => l.lang
       ) as name
     , l.lang
  from h2h_tag_value v
     , h2h_tag t
     , com_language_vw l
 where t.tag = v.tag_id
/
