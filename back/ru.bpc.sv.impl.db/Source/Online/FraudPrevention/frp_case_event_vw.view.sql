create or replace force view frp_case_event_vw as
select 
    id
  , seqnum
  , case_id
  , event_type
  , resp_code
  , risk_threshold
from frp_case_event
/