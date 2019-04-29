create or replace force view itf_data_transmission_vw as 
select 
    id
  , entity_type
  , object_id
  , eff_date
  , is_sent
  , is_received
from itf_data_transmission
/
