create or replace force view rpt_document_content_vw as 
select
    a.id
  , a.document_id
  , a.content_type
  , a.report_id
  , a.template_id
  , a.file_name
  , a.mime_type
  , a.save_path
  , a.document_content
from
    rpt_document_content a
/
