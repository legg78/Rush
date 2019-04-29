create or replace force view prd_ui_contract_type_vw as
select 
    a.id
  , a.seqnum
  , a.contract_type
  , a.customer_entity_type
  , a.product_type
from prd_contract_type_vw a
/

