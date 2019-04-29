create or replace force view prs_sort_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.condition
from 
    prs_sort n
/
