create or replace force view acm_ui_user_role_vw as
select
    a.id
  , a.user_id
  , a.role_id
  , r.name role_name
  , get_text (
      i_table_name  => 'acm_role'
    , i_column_name => 'name'
    , i_object_id   => r.id
    , i_lang        => b.lang
    ) as role_short_desc
  , get_text (
      i_table_name  => 'acm_role'
    , i_column_name => 'description'
    , i_object_id   => r.id
    , i_lang        => b.lang
    ) as role_full_desc
  , b.lang
from
    acm_user_role a
  , com_language_vw b
  , acm_role r
where
    r.id = a.role_id
/
