create or replace force view rpt_ui_document_content_vw as
select
    a.id
    , a.document_type
    , a.document_number
    , a.document_date
    , b.content_type
    , a.entity_type
    , a.object_id
    , b.report_id
    , b.template_id
    , b.file_name
    , b.mime_type
    , b.save_path
    , a.inst_id
from
    rpt_document a
    , rpt_document_content b
where
    a.id = b.document_id
/
