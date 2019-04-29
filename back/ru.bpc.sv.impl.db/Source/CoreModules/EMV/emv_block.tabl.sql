create table emv_block (
    id                   number(8) not null
    , seqnum             number(4)
    , application_id     number(8) not null
    , code               varchar2(4) not null
    , include_in_sda     number(1)
    , include_in_afl     number(1)
    , transport_key_id   number(8)
    , encryption_id      number(8)
    , block_order        number(4) not null
    , profile            varchar2(8) not null
)
/
comment on table emv_block is 'EMV data block'
/
comment on column emv_block.id is 'Primary key'
/
comment on column emv_block.seqnum is 'Data version sequencial number.'
/
comment on column emv_block.application_id is 'Application indentifier'
/
comment on column emv_block.code is 'Unique data block code'
/
comment on column emv_block.include_in_sda is 'Block include in sda'
/
comment on column emv_block.include_in_afl is 'Block include in application file locator'
/
comment on column emv_block.transport_key_id is 'Transport key indentifier'
/
comment on column emv_block.encryption_id is 'Encryption indentifier'
/
comment on column emv_block.block_order is 'Order within block'
/
comment on column emv_block.profile is 'Profile of EMV application (EPFL dictionary)'
/
