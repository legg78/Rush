alter table frp_auth_object add (
    constraint frp_auth_object_pk primary key(auth_id, entity_type, object_id, is_external)
)
/
alter table frp_auth_object drop primary key drop index
/
alter table frp_auth_object add (constraint frp_auth_object_pk primary key(auth_id, entity_type, object_id, is_external)
/****************** partition start ********************
    using index global
    partition by range (auth_id)
(
    partition frp_auth_object_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
