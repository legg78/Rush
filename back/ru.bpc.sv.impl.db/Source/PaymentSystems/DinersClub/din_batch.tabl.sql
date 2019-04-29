create table din_batch(
    id                           number(12)
  , recap_id                     number(12)
  , record_number                number(8)
  , batch_number                 number(3)
  , credit_count                 number(8)
  , credit_amount                number(22, 4)
  , debit_count                  number(8)
  , debit_amount                 number(22, 4)
  , is_rejected                  number(1)
)
/

comment on table din_batch is 'Diners Club batches of messages. There are character codes with field names from the specification in comments (in square brackets)'
/
comment on column din_batch.id is 'Primary key. It contains the same value as in corresponding record in OPR_OPERATION table'
/
comment on column din_batch.recap_id is 'Recap identifier, it relates to the primary key of the table DIN_RECAP'
/
comment on column din_batch.record_number is 'Record number in a clearing file'
/
comment on column din_batch.batch_number is 'Batch number (0..999) [BATCH]'
/
comment on column din_batch.credit_count is 'Number of credit items in a batch [BTNCR]'
/
comment on column din_batch.credit_amount is 'Amount of credit items in a batch [BTACR]'
/
comment on column din_batch.debit_count is 'Number of debit items in a batch [BTNDR]'
/
comment on column din_batch.debit_amount is 'Amount of debit items in a batch [BTADR]'
/
comment on column din_batch.is_rejected is 'Reject flag (reserved)'
/
