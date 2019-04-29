create or replace force view rpt_ui_report_vw as
select id
     , seqnum
     , inst_id
     , data_source
     , source_type
     , get_text('RPT_REPORT', 'LABEL',       r.id, l.lang) label
     , get_text('RPT_REPORT', 'DESCRIPTION', r.id, l.lang) description
     , l.lang
     , is_deterministic
     , name_format_id
     , document_type
     , nvl(is_notification, 0) is_notification
  from rpt_report r
     , com_language_vw l
 where r.inst_id in (select inst_id from acm_cu_inst_vw)
/
