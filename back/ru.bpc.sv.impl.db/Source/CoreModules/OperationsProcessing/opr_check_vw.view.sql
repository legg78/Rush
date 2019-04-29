create or replace force view opr_check_vw as
select 
    n.id
    , n.seqnum
    , n.check_group_id
    , n.check_type
    , n.exec_order
from 
    opr_check n
/
