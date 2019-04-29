create or replace force view prd_service_attribute_vw as
select
    n.service_id
    , n.attribute_id
    , n.is_visible
from
    prd_service_attribute n
/
