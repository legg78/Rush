alter table csm_progress_map add constraint csm_progress_map_pk primary key(id)
/
alter table csm_progress_map add constraint csm_progress_map_uk unique(msg_type, is_reversal, case_progress, network_id, priority)
/
