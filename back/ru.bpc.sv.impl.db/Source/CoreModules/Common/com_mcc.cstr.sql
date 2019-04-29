alter table com_mcc add constraint com_mcc_pk primary key (
    id
)
/

create unique index com_mcc_uk on com_mcc (
    mcc
)
/
