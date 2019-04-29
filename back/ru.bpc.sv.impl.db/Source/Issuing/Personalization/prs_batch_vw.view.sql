create or replace force view prs_batch_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.agent_id
    , n.product_id
    , n.card_type_id
    , n.blank_type_id
    , n.card_count
    , n.hsm_device_id
    , n.status
    , n.status_date
    , n.sort_id
    , n.perso_priority
    , n.batch_name
    , n.reissue_reason
from 
    prs_batch n
/
