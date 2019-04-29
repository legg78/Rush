create or replace force view rpt_ui_template_vw as
select id
     , a.seqnum
     , a.report_id
     , a.lang template_lang
     , a.text
     , a.base64
     , a.report_processor
     , a.report_format
     , get_text ('rpt_template', 'label',       a.id, b.lang) label
     , get_text ('rpt_template', 'description', a.id, b.lang) description
     , b.lang
from rpt_template a, com_language_vw b
/