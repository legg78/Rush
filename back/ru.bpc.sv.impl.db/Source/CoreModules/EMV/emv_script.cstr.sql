alter table emv_script add constraint emv_script_pk primary key (
    id
)
/
create unique index emv_script_uk on emv_script (
    object_id
    , entity_type
    , type_id
)
/
drop index emv_script_uk
/
