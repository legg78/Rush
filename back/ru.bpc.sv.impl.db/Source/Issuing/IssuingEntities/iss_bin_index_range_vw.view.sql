create or replace force view iss_bin_index_range_vw as
select 
    n.id
    , n.seqnum
    , n.bin_id
    , n.index_range_id
from 
    iss_bin_index_range n
/
