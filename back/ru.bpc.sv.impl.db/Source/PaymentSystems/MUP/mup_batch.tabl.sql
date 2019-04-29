create table mup_batch
(
    id               number(12)
  , file_id          number(16)
  , is_returned      number(1)
  , proc_bin         varchar2(6)
  , proc_date        date
  , batch_number     varchar2(6)
  , center_batch_id  varchar2(8)
  , monetary_total   number(8)
  , tcr_total        number(8)
  , trans_total      number(8)
  , src_amount       number(22,4)
  , dst_amount       number(22,4)
)
/

comment on table mup_batch is 'VISA clearing file batches.'
/

comment on column mup_batch.id is 'Primary key.'
/

comment on column mup_batch.file_id is 'Reference to clearing file.'
/

comment on column mup_batch.is_returned is 'Rejected message flag.'
/

comment on column mup_batch.proc_bin is 'BIN'
/

comment on column mup_batch.proc_date is 'Processing Date'
/

comment on column mup_batch.batch_number is 'Batch Number'
/

comment on column mup_batch.center_batch_id is 'Center Batch ID'
/

comment on column mup_batch.monetary_total is 'Number of Monetary Transactions'
/

comment on column mup_batch.tcr_total is 'Number of TCRs'
/

comment on column mup_batch.trans_total is 'Number of Transactions'
/

comment on column mup_batch.src_amount is 'Source Amount'
/

comment on column mup_batch.dst_amount is 'Destination Amount'
/
alter table mup_batch add (is_rejected NUMBER(1))
/
comment on column mup_batch.is_returned is 'Returned message flag.'
/
comment on column mup_batch.is_rejected is 'Rejected message flag.'
/
