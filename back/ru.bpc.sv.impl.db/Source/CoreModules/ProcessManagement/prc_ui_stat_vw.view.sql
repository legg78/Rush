create or replace force view prc_ui_stat_vw as
select
    a.session_id
  , a.thread_number
  , a.start_time
  , a.current_time
  , a.end_time
  , a.estimated_count
  , a.current_count
  , a.excepted_count
  , a.processed_total
  , a.rejected_total
  , a.excepted_total
  , a.result_code
  , a.measure
from
    prc_stat a
/
