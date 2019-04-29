create or replace force view emv_ui_element_vw as
select 
    n.id
    , n.seqnum
    , n.parent_id
    , n.entity_type
    , n.object_id
    , n.element_order
    , n.code
    , n.tag
    , n.value
    , n.is_optional
    , n.add_length
    , n.start_position
    , n.length
    , n.profile
from 
    emv_element n
/
