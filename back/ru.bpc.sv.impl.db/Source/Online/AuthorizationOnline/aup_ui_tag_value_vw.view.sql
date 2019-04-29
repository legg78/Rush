create or replace force view aup_ui_tag_value_vw as
select
    v.auth_id
  , v.tag_id
  , v.tag_value
  , get_text (
        i_table_name  => 'aup_tag'
      , i_column_name => 'name'
      , i_object_id   => t.id
      , i_lang        => l.lang
    ) name
  , l.lang
  , v.seq_number
from
    aup_tag_value v
  , aup_tag t
  , com_language_vw l
where
    t.tag = v.tag_id
/
