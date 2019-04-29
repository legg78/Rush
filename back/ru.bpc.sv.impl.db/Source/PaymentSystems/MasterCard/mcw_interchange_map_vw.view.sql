create or replace force view mcw_interchange_map_vw as
select 
    n.id
    , n.seqnum
    , n.arrangement_type
    , n.arrangement_code
    , n.mod_id
    , n.ird
    , n.priority
from 
    mcw_interchange_map n
/
