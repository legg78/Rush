create table acm_role (
    id               number(4) not null
  , name             varchar2(200)
  , notif_scheme_id  number(4)
  , inst_id          number(4)
)
/
comment on table acm_role is 'Roles.'
/
comment on column acm_role.id is 'Primary key.'
/
comment on column acm_role.name is 'Unique system name.'
/
comment on column acm_role.notif_scheme_id is 'Reference to notification scheme.'
/
comment on column acm_role.inst_id is 'Owner institution identifier.'
/
alter table acm_role add ext_name varchar2(200)
/
comment on column acm_role.ext_name is 'External system name.'
/
