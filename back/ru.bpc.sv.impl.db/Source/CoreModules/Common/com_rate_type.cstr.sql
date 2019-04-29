alter table com_rate_type add constraint com_rate_type_pk primary key (
    id
)
/

create unique index com_rate_type_uk on com_rate_type (
    inst_id
    , rate_type
)
/ 