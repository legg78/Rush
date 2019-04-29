create or replace force view acc_selection_step_vw as
select
    id
  , seqnum
  , selection_id
  , exec_order
  , step
from
    acc_selection_step
/
