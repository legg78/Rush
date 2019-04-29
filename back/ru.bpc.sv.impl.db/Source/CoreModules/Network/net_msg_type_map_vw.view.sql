create or replace force view net_msg_type_map_vw as
select
    n.id
    , n.seqnum
    , n.standard_id
    , n.network_msg_type
    , n.priority
    , n.msg_type 
from net_msg_type_map n
/
