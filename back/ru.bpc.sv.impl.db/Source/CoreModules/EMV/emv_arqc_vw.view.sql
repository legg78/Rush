create or replace force view emv_arqc_vw as
select 
    n.id
    , n.seqnum
    , n.object_id
    , n.entity_type
    , n.tag
    , n.tag_order
from 
    emv_arqc n
/
