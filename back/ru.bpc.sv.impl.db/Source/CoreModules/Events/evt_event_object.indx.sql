create index evt_event_object_status on evt_event_object (decode("STATUS",'EVST0001',"PROCEDURE_NAME",null))
/

create index evt_event_object_entity_ndx on evt_event_object (object_id, entity_type)
/****************** partition start ********************
    local
******************** partition end ********************/
/
drop index evt_event_object_status
/
create index evt_event_object_status on evt_event_object (decode(status,'EVST0001',procedure_name,null), decode(status,'EVST0001',split_hash,null))
/
create index evt_event_object_proc_sess_ndx on evt_event_object (proc_session_id)
/
