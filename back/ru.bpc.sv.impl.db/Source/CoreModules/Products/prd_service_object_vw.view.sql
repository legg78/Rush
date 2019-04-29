create or replace force view prd_service_object_vw as
select
    n.id
    , n.contract_id
    , n.service_id
    , n.entity_type
    , n.object_id
    , n.status
    , n.start_date
    , n.end_date
    , n.split_hash    
from
    prd_service_object n
/