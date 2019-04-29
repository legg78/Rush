create or replace view rpt_report_tag_vw as
select a.report_id
     , a.tag_id
  from rpt_report_tag a
/
