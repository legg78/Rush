create table prs_key_schema (
    id          number(4)
    , inst_id   number(4)
    , seqnum    number(4)
)
/
comment on table prs_key_schema is 'Schema of keys usage'
/
comment on column prs_key_schema.id is 'Scema identifier'
/
comment on column prs_key_schema.inst_id is 'Owner institution identifier'
/
comment on column prs_key_schema.seqnum is 'Sequential number of record version'
/
