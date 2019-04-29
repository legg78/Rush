create table pos_batch_block (
    id                          number(16)
  , batch_file_id               number(8)
  , header_record_type          varchar2(8)
  , header_record_number        number(12)
  , header_batch_reference      varchar2(6)
  , creation_date               varchar2(8)
  , creation_time               varchar2(8)
  , header_batch_amount         number(16, 4)
  , header_debit_credit         varchar2(2)
  , header_merchant_id          varchar2(16)
  , header_terminal_id          varchar2(16)
  , mcc                         varchar2(4)
  , trailer_record_type          varchar2(8)
  , trailer_record_number        number(12)
  , trailer_batch_reference      varchar2(6)
  , trailer_merchant_id          varchar2(16)
  , trailer_terminal_id          varchar2(16)
  , trailer_batch_amount         number(16, 4)
  , trailer_debit_credit         varchar2(2)
  , number_records              number(4)
)
/
comment on table pos_batch_block is 'POS batch list'
/
comment on column pos_batch_block.id is 'Record identifier'
/
comment on column pos_batch_block.batch_file_id is 'POS batch file identifier'
/
comment on column pos_batch_block.header_record_type is 'Header Record Type'
/
comment on column pos_batch_block.header_record_number is 'Header Record Number '
/
comment on column pos_batch_block.header_batch_reference is 'Header Batch Reference'
/
comment on column pos_batch_block.creation_date is 'Creation Batch Date (MMDDYYYY)'
/
comment on column pos_batch_block.creation_time is 'Creation Batch Time (HHMMSS)'
/
comment on column pos_batch_block.header_batch_amount is 'Header Batch Amount'
/
comment on column pos_batch_block.header_debit_credit is 'Header Debit/Credit (DB/CR flag)'
/
comment on column pos_batch_block.header_merchant_id is 'Header Merchant identifier'
/
comment on column pos_batch_block.header_terminal_id is 'Header Terminal identifier '
/
comment on column pos_batch_block.mcc is 'MCC Code'
/
comment on column pos_batch_block.trailer_record_type is 'Trailer Record Type'
/
comment on column pos_batch_block.trailer_record_number is 'Trailer Record Number '
/
comment on column pos_batch_block.trailer_batch_reference is 'Trailer Batch Reference'
/
comment on column pos_batch_block.trailer_merchant_id is 'Trailer Merchant identifier'
/
comment on column pos_batch_block.trailer_terminal_id is 'Trailer Terminal identifier '
/
comment on column pos_batch_block.trailer_batch_amount is 'Trailer Batch Amount'
/
comment on column pos_batch_block.trailer_debit_credit is 'Trailer Debit/Credit (DB/CR flag)'
/
comment on column pos_batch_block.number_records is 'Number of Records in a Batch'
/
