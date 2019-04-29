create or replace force view opr_reason_vw as
select 
    n.id
    , n.seqnum
    , n.oper_type
    , n.reason_dict
from 
    opr_reason n
/
