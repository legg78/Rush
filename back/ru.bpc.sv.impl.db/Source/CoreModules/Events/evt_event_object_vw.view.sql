create or replace force view  evt_event_object_vw as 
select 
    id
  , event_id
  , procedure_name
  , entity_type
  , object_id
  , eff_date
  , event_timestamp
  , inst_id
  , split_hash
  , session_id
  , status
from evt_event_object
/