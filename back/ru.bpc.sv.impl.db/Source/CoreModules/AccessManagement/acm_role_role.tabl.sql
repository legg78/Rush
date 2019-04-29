create table acm_role_role (
    id             number(8) not null
  , parent_role_id number(4) not null
  , child_role_id  number(4) not null )
/
comment on table acm_role_role is 'Roles defined to role.'
/
comment on column acm_role_role.id is 'Primary key.'
/
comment on column acm_role_role.parent_role_id is 'Reference to parent role.'
/
comment on column acm_role_role.child_role_id is 'Reference to child role.'
/
