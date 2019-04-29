create table amx_add_chip (
      id                    number(16) not null
    , fin_id                number(16)
    , file_id               number(16)
    , icc_data              varchar2(512)
    , icc_version_name      varchar2(8)
    , icc_version_number    varchar2(4)
    , emv_9f26              varchar2(16)
    , emv_9f10              varchar2(64)
    , emv_9f37              varchar2(8)
    , emv_9f36              varchar2(4)
    , emv_95                varchar2(10)
    , emv_9a                date
    , emv_9c                number(2)
    , emv_9f02              number(12)
    , emv_5f2a              number(4)
    , emv_9f1a              number(4)
    , emv_82                varchar2(4)
    , emv_9f03              number(12)
    , emv_5f34              number(2)
    , emv_9f27              varchar2(2)
    , message_seq_number    number(3)
    , transaction_id        varchar2(15)
    , message_number        number(8)
)
/
comment on table amx_add_chip is 'Amex addenda/9240 Messages. Chip Card Addendum'
/
comment on column amx_add_chip.id is 'Primary key. Reference to amx_add.id'
/
comment on column amx_add_chip.fin_id is 'Reference to financial message which addendum belongs to'
/
comment on column amx_add_chip.file_id is 'File identifier'
/
comment on column amx_add_chip.icc_data is 'ICC System Related Data'
/
comment on column amx_add_chip.icc_version_name is 'ICC Header Version Name'
/
comment on column amx_add_chip.icc_version_number is 'ICC Header Version Number'
/
comment on column amx_add_chip.emv_9f26 is 'Application Cryptogram'
/
comment on column amx_add_chip.emv_9f10 is 'Issuer Application Data'
/
comment on column amx_add_chip.emv_9f37 is 'Unpredictable Number'
/
comment on column amx_add_chip.emv_9f36 is 'Application Transaction Counter'
/
comment on column amx_add_chip.emv_95 is 'Terminal Verification Results'
/
comment on column amx_add_chip.emv_9a is 'Transaction Date'
/
comment on column amx_add_chip.emv_9c is 'Transaction Type'
/
comment on column amx_add_chip.emv_9f02 is 'Amount Indicator'
/
comment on column amx_add_chip.emv_5f2a is 'Transaction Currency Code'
/
comment on column amx_add_chip.emv_9f1a is 'Terminal Country Code'
/
comment on column amx_add_chip.emv_82 is 'Application Interchange Profile'
/
comment on column amx_add_chip.emv_9f03 is 'Amount Other'
/
comment on column amx_add_chip.emv_5f34 is 'Application PAN Sequence Number'
/
comment on column amx_add_chip.emv_9f27 is 'Cryptogram Information Data'
/
comment on column amx_add_chip.message_seq_number is 'Message Transaction Sequence Number'
/
comment on column amx_add_chip.transaction_id is 'Transaction Identifier (TID)'
/
comment on column amx_add_chip.message_number is 'Message Number'
/
