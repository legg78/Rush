create table amx_add (
    id                      number(16) not null
    , fin_id                number(16)
    , file_id               number(16)
    , is_incoming           number(1)
    , mtid                  varchar2(4)
    , addenda_type          varchar2(2)
    , format_code           varchar2(2)
    , message_seq_number    number(3)
    , transaction_id        varchar2(15)
    , message_number        number(8)
    , reject_reason_code    varchar2(40)
)
/
comment on table amx_add is 'Amex addenda/9240 Messages. General Format Industry Specific Detail'
/
comment on column amx_add.id is 'Primary key'
/
comment on column amx_add.fin_id is 'Reference to financial message which addendum belongs to'
/
comment on column amx_add.file_id is 'File identifier'
/
comment on column amx_add.is_incoming is '0 - incoming file, 1 – outgoing file'
/
comment on column amx_add.mtid is 'The Message Type Identifier'
/
comment on column amx_add.addenda_type is 'Addenda Type Code'
/
comment on column amx_add.format_code is 'Format Code'
/
comment on column amx_add.message_seq_number is 'Message Transaction Sequence Number'
/
comment on column amx_add.transaction_id is 'Transaction Identifier (TID)'
/
comment on column amx_add.message_number is 'Message Number'
/
comment on column amx_add.reject_reason_code is 'Reject Reason Codes 1-10'
/
alter table amx_add add reject_id number(16)
/
comment on column amx_add.reject_id is 'Reject message identifier. Reference to amx_rejected.id'
/
