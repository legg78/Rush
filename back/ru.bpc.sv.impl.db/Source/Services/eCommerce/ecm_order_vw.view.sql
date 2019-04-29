create or replace force view ecm_order_vw as
select
      id
    , merchant_id
    , order_number
    , order_details
    , customer_identifier
    , customer_name
    , split_hash
    , order_uuid
from ecm_order
/
