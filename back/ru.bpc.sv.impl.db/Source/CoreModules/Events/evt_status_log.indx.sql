create index evt_status_log_entity_obj_ndx on evt_status_log (entity_type, object_id, change_date)
/
create index evt_status_log_session_id_ndx on evt_status_log (session_id)
/
