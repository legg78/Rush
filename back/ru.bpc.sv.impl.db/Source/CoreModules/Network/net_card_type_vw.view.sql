create or replace force view net_card_type_vw as
select
    n.id
    , n.seqnum
    , n.parent_type_id
    , n.network_id
    , n.is_virtual
from
    net_card_type n
/
