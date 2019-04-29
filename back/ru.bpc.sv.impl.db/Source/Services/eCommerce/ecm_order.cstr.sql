alter table ecm_order add (
    constraint ecm_order_pk primary key(id)
)
/
alter table ecm_order drop primary key drop index
/
alter table ecm_order add (constraint ecm_order_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition ecm_order_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
