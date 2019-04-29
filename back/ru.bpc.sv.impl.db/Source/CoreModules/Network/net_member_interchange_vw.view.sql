create or replace force view net_member_interchange_vw as
select 
    n.id
    , n.seqnum
    , n.mod_id
    , n.value
from 
    net_member_interchange n
/
