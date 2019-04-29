create or replace force view ntf_custom_object_vw as
select 
    n.id
  , n.custom_event_id
  , n.object_id
  , n.entity_type
  , n.is_active
from 
    ntf_custom_object n
/
