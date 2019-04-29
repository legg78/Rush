create or replace force view prd_attribute_vw as
select
    n.id
    , n.service_type_id
    , n.parent_id
    , n.attr_name
    , n.data_type
    , n.lov_id
    , n.display_order
    , n.entity_type
    , n.object_type
    , n.definition_level
    , n.is_visible
from
    prd_attribute n
/
