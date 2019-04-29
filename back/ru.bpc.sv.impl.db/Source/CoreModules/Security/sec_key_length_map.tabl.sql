create table sec_key_length_map (
    id                  number(4)
    , hsm_manufacturer  varchar2(8)
    , key_type          varchar2(8)
    , key_length        varchar2(8)
)
/
comment on table sec_key_length_map is 'Mapping HSM manufacturer into key length'
/
comment on column sec_key_length_map.id is 'Primary key'
/
comment on column sec_key_length_map.hsm_manufacturer is 'HSM manufacturer (HSMM dictionary)'
/
comment on column sec_key_length_map.key_type is 'Key type (ENKT dictionary)'
/
comment on column sec_key_length_map.key_length is 'Key length (ENKL dictionary)'
/
