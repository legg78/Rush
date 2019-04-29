create or replace force view rpt_ui_document_vw as
select
    a.id
    , a.seqnum
    , a.document_type
    , a.document_number
    , a.document_date
    , a.entity_type
    , a.object_id
    , a.inst_id
    , a.start_date
    , a.end_date
    , a.status
from
    rpt_document a
where
    a.inst_id in (select inst_id from acm_cu_inst_vw)
/