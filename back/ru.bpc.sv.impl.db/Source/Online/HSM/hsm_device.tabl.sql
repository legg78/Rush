create table hsm_device (
    id                number(4) not null
    , is_enabled      number(1) not null
    , seqnum          number(4) not null
    , comm_protocol   varchar2(8) not null
    , plugin          varchar2(8) not null
    , manufacturer    varchar2(8) not null
    , serial_number   varchar2(200) not null
    , lmk_id          number(4) not null
    , model_number    varchar2(8) not null
)
/
comment on table hsm_device is 'HSM devices definition.'
/
comment on column hsm_device.id is 'Substitute identifier.'
/
comment on column hsm_device.is_enabled is 'Flag shows if HSM is in work or not.'
/
comment on column hsm_device.seqnum is 'Object version number.'
/
comment on column hsm_device.comm_protocol is 'Protocol of HSM communication. Value is taken from dictionary ''HSMC''.'
/
comment on column hsm_device.plugin is 'HSM plugin name that is used to support interchange with HSM. Valid values are taken from dictionary ''HSMP''.'
/
comment on column hsm_device.manufacturer is 'HSM manufacturer. Valid values are taken from dictionary ''HSMM''.'
/
comment on column hsm_device.serial_number is 'Serial number of HSM device.'
/
comment on column hsm_device.lmk_id is 'HSM LMK identifier'
/
comment on column hsm_device.model_number is 'HSM device model number (HSMV key)'
/
