create or replace force view rpt_ui_report_tag_vw as
select
    a.report_id
  , get_text(
        'rpt_report'
      , 'label'
      , a.report_id
      , b.lang) report_label
  , get_text(
        'rpt_report'
      , 'description'
      , a.report_id
      , b.lang) report_description
  , a.tag_id
  , get_text(
        'rpt_tag'
      , 'label'
      , a.tag_id
      , b.lang) tag_label
  , get_text(
        'rpt_tag'
      , 'description'
      , a.tag_id
      , b.lang) tag_description
  , b.lang
from
    rpt_report_tag_vw a
  , com_language_vw b
/
