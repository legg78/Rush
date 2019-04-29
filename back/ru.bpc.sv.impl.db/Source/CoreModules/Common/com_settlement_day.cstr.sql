alter table com_settlement_day add constraint com_settlement_day_pk primary key (
    id
)
/

create unique index com_settlement_day_uk on com_settlement_day (
    decode(is_open, 1, inst_id)
)
/

