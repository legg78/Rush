alter table rul_name_part add constraint rul_name_part_pk primary key (
    id
)
/

create unique index rul_name_part_uk on rul_name_part (
    format_id
    , part_order
)
/