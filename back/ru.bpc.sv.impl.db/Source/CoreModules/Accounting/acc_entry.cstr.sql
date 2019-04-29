alter table acc_entry add constraint acc_entry_pk primary key (
    id
)
/
alter table acc_entry drop constraint acc_entry_pk
/
alter table acc_entry add (constraint acc_entry_pk primary key (id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition acc_entry_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
