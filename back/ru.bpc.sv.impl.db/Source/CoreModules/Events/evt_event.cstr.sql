alter table evt_event add (
    constraint evt_event_pk primary key(id)
)
/
alter table evt_event
    add constraint evt_event_un unique (event_type, inst_id) using index
/
