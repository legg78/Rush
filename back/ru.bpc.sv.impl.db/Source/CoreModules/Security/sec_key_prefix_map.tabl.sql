create table sec_key_prefix_map (
    id                  number(4)
    , hsm_manufacturer  varchar2(8)
    , key_length        varchar2(8)
    , key_prefix        varchar2(8)
)
/
comment on table sec_key_prefix_map is 'Mapping hsm manufacturer into key prefix'
/
comment on column sec_key_prefix_map.id is 'Primary key'
/
comment on column sec_key_prefix_map.hsm_manufacturer is 'HSM manufacturer (HSMM dictionary)'
/
comment on column sec_key_prefix_map.key_length is 'Key length (ENKL dictionary)'
/
comment on column sec_key_prefix_map.key_prefix is 'Key prefix (ENKP dictionary)'
/
