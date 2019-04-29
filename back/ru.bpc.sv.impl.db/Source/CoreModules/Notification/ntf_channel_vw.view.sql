create or replace force view ntf_channel_vw as
select 
    n.id
    , n.address_pattern
    , n.mess_max_length
    , n.address_source
from 
    ntf_channel n
/
