create table hsm_model_number_map (
    id                  number(4) not null
    , hsm_manufacturer  varchar2(8)
    , model_number      varchar2(8)
    , firmware          varchar2(8)
)
/
comment on column hsm_model_number_map.id is 'Primary key'
/
comment on column hsm_model_number_map.hsm_manufacturer is 'HSM manufacturer (HSMM key)'
/
comment on column hsm_model_number_map.model_number is 'HSM device model number (HSMV key)'
/
comment on column hsm_model_number_map.firmware is 'HSM device firmware (HSMF key)'
/
