create or replace force view ntf_message_vw as
select 
    n.id
    , n.channel_id
    , n.text
    , n.lang
    , n.delivery_address
    , n.delivery_date
    , n.is_delivered
    , n.urgency_level
    , n.inst_id
    , n.event_type
    , n.eff_date   
    , n.entity_type
    , n.object_id              
    , n.sms_gate_reference    
    , n.message_status    
    , n.message_status_reference  
    , n.delivery_time 
from 
    ntf_message n
/
