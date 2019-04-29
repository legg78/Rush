create table sec_key_type (
    entity_type             varchar2(8)
    , key_type              varchar2(8)
    , key_algorithm         varchar2(8)
    , max_index             number(4)
)
/
comment on table sec_key_type is 'List of key types and it usages'
/
comment on column sec_key_type.entity_type is 'Entity type that uses a key'
/
comment on column sec_key_type.key_type is 'Key type'
/
comment on column sec_key_type.key_algorithm is 'Key algorithm (DES/RSA)'
/
comment on column sec_key_type.max_index is 'Maximal number of key instances'
/
