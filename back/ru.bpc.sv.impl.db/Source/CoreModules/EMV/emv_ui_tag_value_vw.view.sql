create or replace force view emv_ui_tag_value_vw as
select 
    n.id
    , n.object_id
    , n.entity_type
    , n.tag_id
    , n.tag_value
    , n.profile
from 
    emv_tag_value n
/
