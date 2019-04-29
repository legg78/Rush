create or replace force view prc_ui_progress_thread_vw as
select
    a.session_id
  , a.thread_number
  , decode (sum (a.estimated_count), 0, 100,
               (decode (sum (a.current_count), 0, 0, sum (a.current_count))
                / decode (sum (a.estimated_count), 0, 1, sum (a.estimated_count))
                * 100)) progress_bar
from
    prc_stat a
group by
    a.session_id
  , a.thread_number
/
