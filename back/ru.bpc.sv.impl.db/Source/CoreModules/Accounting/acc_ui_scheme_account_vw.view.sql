create or replace force view acc_ui_scheme_account_vw as
select
    a.id
  , a.seqnum
  , a.scheme_id
  , get_text('acc_scheme', 'name', a.scheme_id, l.lang) as scheme_name
  , a.account_type
  , get_article_text(a.account_type, l.lang) as account_type_name
  , a.entity_type
  , get_article_text(a.entity_type, l.lang) as entity_type_name
  , a.object_id
  , a.mod_id
  , a.account_id
  , l.lang
from
    acc_scheme_account_vw a
  , com_language_vw l
/
