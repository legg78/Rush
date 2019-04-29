create unique index adt_trail_pk on adt_trail(id)
/

alter table adt_trail add (constraint adt_trail_pk primary key(id))
/