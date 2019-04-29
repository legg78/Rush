create or replace force view rpt_ui_report_banner_vw as

select id
     , report_id
     , get_text('RPT_REPORT', 'LABEL',       r.report_id, l.lang) label_report
     , get_text('RPT_REPORT', 'DESCRIPTION', r.report_id, l.lang) description_report
     , banner_id
     , get_text('RPT_BANNER', 'LABEL',       r.id, l.lang) label_banner
     , get_text('RPT_BANNER', 'DESCRIPTION', r.id, l.lang) description_banner
     , l.lang
  from rpt_report_banner_vw r
     , com_language_vw l
/
