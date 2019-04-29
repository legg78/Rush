create or replace force view prc_ui_stat_summary_vw as
select
    s.id session_id
  , s.parent_id parent_session_id
  , s.thread_count
  , min(s.start_time) start_time
  , max(s.end_time) end_time
  , max(cast(s.end_time as date)) - min(cast(s.start_time as date)) spend_time
  , sum(cast(s.end_time as date) - cast(s.start_time as date)) waste_time
  , s.estimated_count
  , s.processed processed_total
  , s.rejected rejected_total
  , s.excepted excepted_total
  , min(s.result_code) result_code
  , s.process_id
from
    prc_session s
group by
    s.id
  , s.parent_id
  , s.process_id
  , s.thread_count
  , s.estimated_count
  , s.processed
  , s.rejected
  , s.excepted
/
