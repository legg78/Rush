create or replace force view prd_contract_vw as
select
    n.id
    , n.seqnum
    , n.product_id
    , n.start_date
    , n.end_date
    , n.contract_number
    , n.inst_id
    , n.agent_id
    , n.customer_id
    , n.split_hash
    , n.contract_type
from
    prd_contract n
/
