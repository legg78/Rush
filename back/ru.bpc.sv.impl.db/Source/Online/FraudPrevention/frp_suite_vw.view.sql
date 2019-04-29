create or replace force view frp_suite_vw as
select 
    id
  , seqnum
  , entity_type
  , inst_id
from frp_suite
/