create or replace force view opr_entity_oper_type_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.entity_type
    , n.oper_type
    , n.invoke_method
    , n.reason_lov_id
    , n.object_type
    , n.wizard_id
    , n.entity_object_type
from
    opr_entity_oper_type n
/
