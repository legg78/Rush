alter table emv_script_type add constraint emv_script_type_pk primary key (
    id
)
/
create unique index emv_script_type_uk on emv_script_type (
    type
)
/
