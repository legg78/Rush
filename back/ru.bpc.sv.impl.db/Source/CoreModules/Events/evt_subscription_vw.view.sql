create or replace force view evt_subscription_vw as
select 
    id
  , seqnum
  , event_id
  , subscr_id
  , mod_id
  , container_id
from evt_subscription
/
