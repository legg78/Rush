alter table frp_auth add constraint frp_auth_pk primary key (id)
/
alter table frp_auth drop primary key drop index
/
alter table frp_auth add (constraint frp_auth_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition frp_auth_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
