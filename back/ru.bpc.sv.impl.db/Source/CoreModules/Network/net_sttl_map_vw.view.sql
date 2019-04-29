create or replace force view net_sttl_map_vw as
select
    n.id
    , n.seqnum
    , n.iss_inst_id
    , n.iss_network_id
    , n.acq_inst_id
    , n.acq_network_id
    , n.card_inst_id
    , n.card_network_id
    , n.mod_id
    , n.priority
    , n.sttl_type
    , n.match_status
    , n.oper_type
from net_sttl_map n
/
