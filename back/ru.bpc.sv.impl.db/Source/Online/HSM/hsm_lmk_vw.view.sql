create or replace force view hsm_lmk_vw as
select 
    n.id
    , n.seqnum
    , n.check_value
from 
    hsm_lmk n
/
