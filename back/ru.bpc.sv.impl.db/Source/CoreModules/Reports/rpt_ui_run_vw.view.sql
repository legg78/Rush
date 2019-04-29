create or replace force view rpt_ui_run_vw as
select
    r.id
  , r.report_id
  , r.start_date
  , r.finish_date
  , r.user_id
  , r.status
  , r.inst_id
  , r.run_hash
  , dc.save_path
  , dc.file_name
  , dc.content_type
  , r.first_run_id
  , get_text('RPT_REPORT', 'LABEL', r.report_id, l.lang) label
  , get_text('RPT_REPORT', 'DESCRIPTION', r.report_id, l.lang) description
  , l.lang
from
    rpt_run r
  , rpt_document d
  , rpt_document_content dc
  , com_language_vw l
where
    r.inst_id in (select inst_id from acm_cu_inst_vw)
and
    r.document_id = d.id(+)
and
    d.id = dc.document_id(+)
/
