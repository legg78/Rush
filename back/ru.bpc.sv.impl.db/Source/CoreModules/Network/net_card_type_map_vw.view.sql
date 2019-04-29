create or replace force view net_card_type_map_vw as
select
    n.id
    , n.seqnum
    , n.standard_id
    , n.network_card_type
    , n.country
    , n.priority
    , n.card_type_id
from net_card_type_map n
/
