create table acc_scheme_account(
    id           number(12) not null
  , seqnum       number(4)
  , scheme_id    number(4) not null
  , account_type varchar2(8)
  , entity_type  varchar2(8)
  , object_id    number(16)
  , mod_id       number(4)
  , account_id   number(12) not null
)
/
comment on table acc_scheme_account is 'Account scheme selection'
/

comment on column acc_scheme_account.id is 'Primary key'
/
comment on column acc_scheme_account.seqnum is 'Data version number'
/
comment on column acc_scheme_account.scheme_id is 'Scheme identifier'
/
comment on column acc_scheme_account.account_type is 'Account type'
/
comment on column acc_scheme_account.entity_type is 'Entity type'
/
comment on column acc_scheme_account.object_id is 'Object identifier'
/
comment on column acc_scheme_account.mod_id is 'Modifier identifier'
/
comment on column acc_scheme_account.account_id is 'Account identifier'
/
