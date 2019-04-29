create table acm_user_password(
    user_id             number(8)
  , password_hash       number(12)
  , is_active           number(1)
  , expire_date         date
)
/

comment on table acm_user_password is 'User password.'
/

comment on column acm_user_password.user_id is 'User identifier.'
/
comment on column acm_user_password.password_hash is 'User password hash value.'
/
comment on column acm_user_password.is_active is 'Activation flag.'
/
comment on column acm_user_password.expire_date is 'User password expiration date.'
/

alter table acm_user_password modify (password_hash varchar2(128))
/
comment on column acm_user_password.password_hash is 'User password''s hash value that is stored as a string. It usually should contain a long number in HEX notation.'
/

