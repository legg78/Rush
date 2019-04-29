create or replace force view prc_ui_directory_vw as
select
    a.id
  , a.seqnum
  , a.encryption_type
  , get_article_text(a.encryption_type, b.lang) encription_type_desc
  , a.directory_path
  , get_text('PRC_DIRECTORY', 'NAME', a.id, b.lang) as name
  , b.lang
from
    prc_directory a
  , com_language_vw b
/
