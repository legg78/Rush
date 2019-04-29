create or replace force view iss_bin_vw as
select 
    n.id
    , n.bin
    , n.inst_id
    , n.network_id
    , n.bin_currency
    , n.sttl_currency
    , n.pan_length
    , n.card_type_id
    , n.country
    , n.seqnum
from 
    iss_bin n
/
