create or replace force view emv_ui_script_vw as
select 
    s.id
    , s.object_id
    , s.entity_type
    , s.status
    , s.type_id
    , t.type
    , t.priority
    , s.class_byte
    , s.instruction_byte
    , s.parameter1
    , s.parameter2
    , s.length
    , s.data
    , s.change_date
from 
    emv_script s
    , emv_script_type t
where
    t.id = s.type_id
/