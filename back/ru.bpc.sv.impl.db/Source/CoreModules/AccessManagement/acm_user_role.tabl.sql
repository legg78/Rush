create table acm_user_role(
    id      number(8) not null
  , user_id number(8) not null
  , role_id number(4) not null )
/
comment on table acm_user_role is 'User roles.'
/
comment on column acm_user_role.id is 'Primary key.'
/
comment on column acm_user_role.user_id is 'Reference to user.'
/
comment on column acm_user_role.role_id is 'Reference to role.'
/
