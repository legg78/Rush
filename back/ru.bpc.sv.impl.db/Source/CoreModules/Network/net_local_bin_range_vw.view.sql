create or replace force view net_local_bin_range_vw as
select
    n.id
    , n.seqnum
    , n.pan_low
    , n.pan_high
    , n.pan_length
    , n.priority
    , n.card_type_id
    , n.country
    , n.iss_network_id
    , n.iss_inst_id
    , n.card_network_id
    , n.card_inst_id
from
    net_local_bin_range n
/
