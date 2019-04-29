create or replace force view frp_case_vw as
select
    id
  , seqnum
  , inst_id
  , hist_depth
from frp_case
/