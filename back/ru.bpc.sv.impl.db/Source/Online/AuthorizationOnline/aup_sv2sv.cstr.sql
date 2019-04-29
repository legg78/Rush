alter table aup_sv2sv add constraint aup_sv2sv_pk primary key (
    auth_id
    , tech_id
)
/
alter table aup_sv2sv drop primary key drop index
/
alter table aup_sv2sv add (constraint aup_sv2sv_pk primary key(auth_id, tech_id)
/****************** partition start ********************
    using index global
    partition by range (auth_id)
(
    partition aup_sv2sv_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
