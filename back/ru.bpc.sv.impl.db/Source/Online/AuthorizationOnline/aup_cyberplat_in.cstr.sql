alter table aup_cyberplat_in add constraint aup_cyberplat_in_pk primary key (
    auth_id
    , tech_id
)
/
alter table aup_cyberplat_in drop primary key drop index
/
alter table aup_cyberplat_in add (constraint aup_cyberplat_in_pk primary key(auth_id, tech_id)
/****************** partition start ********************
    using index global
    partition by range (auth_id)
(
    partition aup_cyberplat_in_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
