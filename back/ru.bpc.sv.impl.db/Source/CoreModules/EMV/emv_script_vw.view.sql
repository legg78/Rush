create or replace force view emv_script_vw as
select 
    n.id
    , n.object_id
    , n.entity_type
    , n.type_id
    , n.class_byte
    , n.instruction_byte
    , n.parameter1
    , n.parameter2
    , n.length
    , n.data
    , n.status
    , n.change_date
from 
    emv_script n
/
