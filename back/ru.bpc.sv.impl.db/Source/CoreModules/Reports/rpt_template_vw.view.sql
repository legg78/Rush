create or replace force view rpt_template_vw as
select id
     , seqnum
     , report_id
     , lang
     , text
     , base64
     , report_processor
     , report_format
     , start_date
     , end_date
from rpt_template
/