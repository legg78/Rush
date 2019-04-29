create or replace force view rpt_run_vw as
select r.id
     , r.report_id
     , r.start_date
     , r.finish_date
     , r.user_id
     , r.status
     , r.inst_id
     , r.run_hash
     , r.first_run_id
     , r.document_id
  from rpt_run r
/