create or replace force view acc_selection_vw as
select
    id
  , seqnum
  , check_aval_balance
from
    acc_selection c
/
