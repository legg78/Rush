alter table pmo_order add constraint pmo_order_pk primary key(id)
/
alter table pmo_order drop primary key drop index
/
alter table pmo_order add (constraint pmo_order_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition pmo_order_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
