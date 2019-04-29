alter table com_country add constraint com_country_pk primary key (
    id
)
/

create unique index com_country_uk on com_country (
    code
)
/
