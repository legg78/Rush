alter table evt_event_object add (
    constraint evt_event_object_pk primary key(id)
)
/
alter table evt_event_object drop primary key drop index
/
alter table evt_event_object add (constraint evt_event_object_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition evt_event_object_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
