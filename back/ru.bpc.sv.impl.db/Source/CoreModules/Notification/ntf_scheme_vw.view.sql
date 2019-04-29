create or replace force view ntf_scheme_vw as
select 
    n.id
    , n.seqnum
    , n.scheme_type
    , n.inst_id
from 
    ntf_scheme n
/