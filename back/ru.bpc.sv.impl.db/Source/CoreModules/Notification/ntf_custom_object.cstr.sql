alter table ntf_custom_object add constraint ntf_custom_object_pk primary key (
    id
)
/
alter table ntf_custom_object add constraint ntf_custom_object_uk unique (custom_event_id, object_id)
/
