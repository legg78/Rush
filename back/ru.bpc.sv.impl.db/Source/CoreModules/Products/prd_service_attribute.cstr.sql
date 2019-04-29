alter table prd_service_attribute add (
    constraint prd_service_attribute_pk primary key (service_id, attribute_id)
)
/
