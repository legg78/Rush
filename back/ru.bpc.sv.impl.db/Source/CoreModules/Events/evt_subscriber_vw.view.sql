create or replace force view evt_subscriber_vw as
select 
    id
  , seqnum
  , procedure_name
  , event_type
  , priority
from evt_subscriber
/