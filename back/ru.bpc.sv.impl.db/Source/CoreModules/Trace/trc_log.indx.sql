create index trc_log_timestamp_ndx on trc_log(trace_timestamp)
/

create index trc_log_user_id_ndx on trc_log(user_id)
/

create index trc_log_session_id_ndx on trc_log(session_id)
/

create index trc_log_entity_ndx on trc_log(entity_type, object_id)
/
drop index trc_log_entity_ndx
/
create index trc_log_entity_ndx on trc_log(object_id, entity_type)
/

drop index trc_log_timestamp_ndx
/

drop index trc_log_user_id_ndx
/
