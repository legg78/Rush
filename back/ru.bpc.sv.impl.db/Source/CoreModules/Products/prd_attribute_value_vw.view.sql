create or replace force view prd_attribute_value_vw as
select
    n.id
    , n.service_id
    , n.object_id
    , n.entity_type
    , n.attr_id
    , n.mod_id
    , n.start_date
    , n.end_date
    , n.register_timestamp
    , n.attr_value
    , n.split_hash
from
    prd_attribute_value n
/
