alter table evt_event_type add (
    constraint evt_event_type_pk primary key(id)
)
/

alter table evt_event_type add constraint evt_event_type_uk unique (event_type) using index
/
