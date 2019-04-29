create or replace force view opr_check_group_vw as
select 
    n.id
    , n.seqnum
from 
    opr_check_group n
/
