create table acm_user(
    id        number(8) not null
  , name      varchar2(200)
  , person_id number(12)
  , status    varchar2(8)
  , inst_id   number(4)
)
/
comment on table acm_user is 'Users.'
/
comment on column acm_user.id is 'Primary key.'
/
comment on column acm_user.name is 'Unique user name.'
/
comment on column acm_user.person_id is 'Reference to person.'
/
comment on column acm_user.status is 'User status (active, inactive).'
/
comment on column acm_user.inst_id is 'Owner institution identifier.'
/
alter table acm_user add password_change_needed number(1) 
/
comment on column acm_user.password_change_needed is 'User must change password on first login flag.'
/
alter table acm_user add creation_date date
/
comment on column acm_user.creation_date is 'Date of user creation.'
/
alter table acm_user modify creation_date date default sysdate
/
alter table acm_user drop column creation_date
/
alter table acm_user add creation_date date
/
comment on column acm_user.creation_date is 'Date of user creation.'
/
alter table acm_user add auth_scheme varchar2(8)
/
comment on column acm_user.auth_scheme is 'Authentication scheme (ATHS dictionary)'
/
