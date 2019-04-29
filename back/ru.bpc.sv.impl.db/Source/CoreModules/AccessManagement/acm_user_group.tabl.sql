create table acm_user_group (
    id             number(8)
  , user_id        number(8)
  , group_id       number(8)
)
/
comment on table acm_user_group is 'Users in groups.'
/
comment on column acm_user_group.id is 'Primary key.'
/
comment on column acm_user_group.user_id is 'User ID (acm_user.id)'
/
comment on column acm_user_group.group_id is 'Group ID (acm_group.id)'
/
