create or replace force view net_member_vw as
select
    n.id
    , n.seqnum
    , n.network_id
    , n.inst_id
    , n.participant_type
    , n.status
    , n.inactive_till
    , n.scale_id
from
    net_member n
/