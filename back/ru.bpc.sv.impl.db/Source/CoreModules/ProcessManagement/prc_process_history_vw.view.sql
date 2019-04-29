create or replace force view prc_process_history_vw as
select
    a.id
  , a.session_id
  , a.param_id
  , a.param_value
from
    prc_process_history a
/
