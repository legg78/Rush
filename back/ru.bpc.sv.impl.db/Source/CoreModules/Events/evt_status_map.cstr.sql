alter table evt_status_map add (
    constraint evt_status_map_pk primary key(id)
  , constraint evt_status_map_uk unique (event_type, initiator, initial_status)
)
/
alter table evt_status_map drop constraint evt_status_map_uk cascade
/
alter table evt_status_map add constraint evt_status_map_uk unique (event_type, initiator, initial_status, inst_id)
/
