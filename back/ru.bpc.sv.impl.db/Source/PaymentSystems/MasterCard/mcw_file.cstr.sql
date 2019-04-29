alter table mcw_file add constraint mcw_file_pk primary key (
    id
)
/

create unique index mcw_file_uk on mcw_file (
    p0105
    , network_id
)
/
