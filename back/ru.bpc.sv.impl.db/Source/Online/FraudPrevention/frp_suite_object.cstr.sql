alter table frp_suite_object add (
    constraint frp_suite_object_pk primary key(id)
)
/

create unique index frp_suite_object_uk on frp_suite_object (entity_type, object_id, start_date)
/