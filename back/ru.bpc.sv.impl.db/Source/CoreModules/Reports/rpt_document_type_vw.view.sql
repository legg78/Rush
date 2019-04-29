create or replace force view rpt_document_type_vw as 
select
    id
    , document_type
    , content_type
    , is_report
from
    rpt_document_type
/
