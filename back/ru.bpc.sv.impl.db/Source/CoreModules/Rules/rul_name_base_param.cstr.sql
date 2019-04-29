alter table rul_name_base_param add constraint rul_name_base_param_pk primary key (
    id
)
/

create unique index rul_name_base_param_uk on rul_name_base_param (
    entity_type
    , name
)
/
