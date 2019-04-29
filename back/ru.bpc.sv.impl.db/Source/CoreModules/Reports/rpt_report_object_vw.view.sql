create or replace force view rpt_report_object_vw as
select id
     , seqnum
	 , report_id
     , entity_type
     , object_type
  from rpt_report_object
/
