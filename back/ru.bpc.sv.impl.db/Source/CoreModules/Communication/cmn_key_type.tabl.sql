create table cmn_key_type (
    id                   number(8) not null
    , standard_id        number(4) not null
    , seqnum             number(4) not null
    , key_type           varchar2(8) not null
    , standard_key_type  varchar2(8) not null
)
/
comment on table cmn_key_type is 'Key types as it defined in standard'
/
comment on column cmn_key_type.id is 'Record identifier'
/
comment on column cmn_key_type.standard_id is 'Standard identifier'
/
comment on column cmn_key_type.seqnum is 'Sequential number of record data version'
/
comment on column cmn_key_type.key_type is 'System key type'
/
comment on column cmn_key_type.standard_key_type is 'Standard key type'
/
