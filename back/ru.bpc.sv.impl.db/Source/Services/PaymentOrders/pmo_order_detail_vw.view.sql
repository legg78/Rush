create or replace force view pmo_order_detail_vw as
select 
    n.id
    , n.order_id
    , n.entity_type
    , n.object_id
from 
    pmo_order_detail n
/
