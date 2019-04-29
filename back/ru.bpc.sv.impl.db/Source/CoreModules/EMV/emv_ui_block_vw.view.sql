create or replace force view emv_ui_block_vw as
select 
    n.id
    , n.seqnum
    , n.application_id
    , n.code
    , n.include_in_sda
    , n.include_in_afl
    , n.transport_key_id
    , n.encryption_id
    , n.block_order
    , n.profile
from 
    emv_block n
/
