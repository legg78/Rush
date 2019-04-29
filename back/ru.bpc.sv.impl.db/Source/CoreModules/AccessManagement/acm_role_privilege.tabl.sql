create table acm_role_privilege (
    id       number(8) not null
  , role_id  number(4) not null
  , priv_id  number(8) not null
  , limit_id number(8)
)
/
comment on table acm_role_privilege is 'Role privileges.'
/
comment on column acm_role_privilege.id is 'Primary key.'
/
comment on column acm_role_privilege.role_id is 'Reference to role.'
/
comment on column acm_role_privilege.priv_id is 'Reference to privilege.'
/
comment on column acm_role_privilege.limit_id is 'Reference to privilege limitation.'
/
alter table acm_role_privilege add (filter_limit_id number(8))
/
comment on column acm_role_privilege.filter_limit_id is 'Filter limitation ID.'
/
