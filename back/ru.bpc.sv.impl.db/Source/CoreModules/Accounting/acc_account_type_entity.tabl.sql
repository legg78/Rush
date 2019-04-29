create table acc_account_type_entity (
    id                  number(4)
    , seqnum            number(4)
    , account_type      varchar2(8)
    , inst_id           number(4)
    , entity_type       varchar2(8)
)
/
comment on table acc_account_type_entity is 'List of possible associations between account types and entity types'
/
comment on column acc_account_type_entity.id is 'Record identifier'
/
comment on column acc_account_type_entity.seqnum is 'Data version number'
/
comment on column acc_account_type_entity.account_type is 'Account type'
/
comment on column acc_account_type_entity.inst_id is 'Institution identifier'
/
comment on column acc_account_type_entity.entity_type is 'Business entity which owns account'
/
