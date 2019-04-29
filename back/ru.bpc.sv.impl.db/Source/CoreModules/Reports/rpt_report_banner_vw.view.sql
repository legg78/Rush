create or replace force view rpt_report_banner_vw as
select id
     , report_id
     , banner_id
  from rpt_report_banner rb
/