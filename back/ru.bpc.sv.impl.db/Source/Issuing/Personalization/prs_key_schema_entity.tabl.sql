create table prs_key_schema_entity (
    id                  number(4)
    , seqnum            number(4)
    , key_schema_id     number(4)
    , key_type          varchar2(8)
    , entity_type       varchar2(8)
)
/
comment on table prs_key_schema_entity is 'Detalization of key schema'
/
comment on column prs_key_schema_entity.id is 'Record identifier'
/
comment on column prs_key_schema_entity.seqnum is 'Sequential version of data record'
/
comment on column prs_key_schema_entity.key_schema_id is 'Identifier of schema'
/
comment on column prs_key_schema_entity.key_type is 'Key type (ENKT dictionary)'
/
comment on column prs_key_schema_entity.entity_type is 'Entity type that owns the key (ENTT dictionary)'
/
