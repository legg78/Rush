create or replace force view rpt_ui_document_type_vw as
select
    a.id
  , a.document_type
  , get_article_text(a.document_type, b.lang) document_type_desc
  , a.content_type
  , get_article_text(a.content_type, b.lang) content_type_desc
  , a.is_report
  , b.lang
from
    rpt_document_type a
  , com_language_vw b
/
