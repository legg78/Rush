create or replace view rpt_ui_print_document_vw as
select
    d.id
    , d.document_type
    , d.document_number
    , d.document_date
    , d.entity_type
    , d.object_id
    , c.report_id
    , c.template_id
    , c.content_type
    , c.file_name
    , d.start_date
    , d.end_date
    , d.status
from
    rpt_document d
    , rpt_document_content c
where
    c.document_id = d.id
/
