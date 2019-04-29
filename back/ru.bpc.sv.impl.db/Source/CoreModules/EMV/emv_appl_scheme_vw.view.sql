create or replace force view emv_appl_scheme_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.type
from 
    emv_appl_scheme n
/
