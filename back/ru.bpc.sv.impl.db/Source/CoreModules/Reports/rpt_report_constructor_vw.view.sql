create or replace force view rpt_report_constructor_vw as
select id
     , report_name
     , description
     , xml_template
  from rpt_report_constructor
/
