create or replace force view emv_script_type_vw as
select 
    n.id
    , n.seqnum
    , n.type
    , n.priority
    , n.mac
    , n.tag_71
    , n.tag_72
    , n.condition
    , n.retransmission
    , n.repeat_count
    , n.class_byte
    , n.instruction_byte
    , n.parameter1
    , n.parameter2
    , n.req_length_data
    , n.is_used_by_user
    , n.form_url
from 
    emv_script_type n
/
