create or replace force view prd_product_vw as
select
    n.id
  , n.product_type
  , n.contract_type
  , n.parent_id
  , n.seqnum
  , n.inst_id
  , n.status
  , n.product_number
  , n.split_hash
from
    prd_product n
/
