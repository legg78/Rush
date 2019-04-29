alter table aup_scheme_object add (
    constraint aup_scheme_object_pk primary key(id)
)
/

create unique index aup_scheme_object_uk on aup_scheme_object (entity_type, object_id, start_date)
/