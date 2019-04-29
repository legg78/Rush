create or replace force view rpt_report_vw as
select id
     , seqnum
     , inst_id
     , data_source
     , source_type
     , is_deterministic
     , name_format_id
     , document_type
     , nvl(is_notification, 0) is_notification
  from rpt_report
/
