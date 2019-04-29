create unique index com_lov_pk on com_lov(id)
/

alter table com_lov add (constraint com_lov_pk primary key(id))
/