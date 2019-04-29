create or replace force view ntf_ui_custom_object_vw as
select 
    co.id
  , co.custom_event_id
  , co.object_id
  , co.entity_type 
  , co.is_active
  , c.card_mask as entity_number
from ntf_custom_object co
left join iss_card c
       on co.entity_type = 'ENTTCARD'
      and c.id = co.object_id 
/
