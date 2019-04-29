create or replace force view frp_fraud_vw as
select
    id
  , seqnum
  , auth_id
  , entity_type
  , object_id
  , is_external
  , case_id
  , event_type
  , resolution
  , resolution_user_id
from frp_fraud
/
