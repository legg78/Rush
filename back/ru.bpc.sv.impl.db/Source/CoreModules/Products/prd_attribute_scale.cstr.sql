alter table prd_attribute_scale add (
    constraint prd_attribute_scale_pk primary key (id)
)
/

alter table prd_attribute_scale add (
    constraint prd_attribute_scale_uk unique (inst_id, attr_id)
)
/