create index ntf_message_is_delivered_ndx on ntf_message (decode("IS_DELIVERED",0,"URGENCY_LEVEL",null))
/
create index ntf_message_entity_object_ndx on ntf_message (entity_type, object_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create unique index ntf_message_sms_gate_ref_uk on ntf_message (sms_gate_reference)
/
create index ntf_message_status_ndx on ntf_message (decode(message_status, 'SGMSRDY', urgency_level, null)) 
/
