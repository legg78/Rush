create unique index com_currency_code_uk on com_currency(code)
/

create unique index com_currency_name_uk on com_currency(name)
/

alter table com_currency add (constraint com_currency_pk primary key(id))
/