create or replace force view prd_ui_product_service_vw as
select
     n.id
     , n.seqnum
     , n.parent_id
     , n.service_id
     , n.product_id
     , n.min_count
     , n.max_count
     , n.conditional_group
from
   prd_product_service n
/

