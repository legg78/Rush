alter table prd_service add (
    constraint prd_service_pk primary key (id)
)
/
alter table prd_service add (constraint prd_service_uk unique (service_number, inst_id))
/
