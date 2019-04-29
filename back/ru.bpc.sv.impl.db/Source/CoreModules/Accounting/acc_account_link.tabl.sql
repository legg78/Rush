create table acc_account_link (
    id                  number(12)
  , account_id          number(12)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , description         varchar2(200)
  , is_active           number(1)
)
/
comment on table acc_account_link is 'Account link table.'
/
comment on column acc_account_link.id is 'Primary key.'
/
comment on column acc_account_link.account_id is 'Account identifier.'
/
comment on column acc_account_link.entity_type is 'Object entity type.'
/
comment on column acc_account_link.object_id is 'Object identifier.'
/
comment on column acc_account_link.description is 'Object additional description.'
/
comment on column acc_account_link.is_active is 'Activation flag (1 - Active, 0 - Inactive).'
/
