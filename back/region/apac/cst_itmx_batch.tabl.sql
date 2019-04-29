create table cst_itmx_batch
(
    id               number(16)
  , part_key         as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd'))
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
  , is_rejected      number(1)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
(
    partition cst_itmx_batch_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/

comment on table cst_itmx_batch is 'ITMX clearing file batches'
/
comment on column cst_itmx_batch.id is 'Primary key'
/
comment on column cst_itmx_batch.file_id is 'Reference to clearing file'
/
comment on column cst_itmx_batch.is_returned is 'Returned message flag'
/
comment on column cst_itmx_batch.proc_bin is 'BIN'
/
comment on column cst_itmx_batch.proc_date is 'Processing date'
/
comment on column cst_itmx_batch.batch_number is 'Batch number'
/
comment on column cst_itmx_batch.center_batch_id is 'Center batch ID'
/
comment on column cst_itmx_batch.monetary_total is 'Number of monetary transactions'
/
comment on column cst_itmx_batch.tcr_total is 'Number of transaction portions'
/
comment on column cst_itmx_batch.trans_total is 'Number of transactions'
/
comment on column cst_itmx_batch.src_amount is 'Source amount'
/
comment on column cst_itmx_batch.dst_amount is 'Destination amount'
/
comment on column cst_itmx_batch.is_rejected is 'Rejected message flag.'
/
