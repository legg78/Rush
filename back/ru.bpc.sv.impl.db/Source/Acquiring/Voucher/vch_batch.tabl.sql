create table vch_batch (
    id              number(16)
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual             -- [@skip patch]
  , seqnum          number(4)
  , status          varchar2(8)
  , total_amount    number(22 , 4)
  , currency        varchar2(3)
  , total_count     number(4)
  , reg_date        date
  , proc_date       date
  , merchant_id     number(8)
  , terminal_id     number(8)
  , status_reason   varchar2(8)
  , user_id         number(8)
  , inst_id         number(4)
  , card_network_id number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition vch_batch_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))        -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table vch_batch is 'Voucher batches.'
/
comment on column vch_batch.id is 'Primary key.'
/
comment on column vch_batch.seqnum is 'Sequence Number.'
/
comment on column vch_batch.status is 'Status of voucher batch (VCBS dictionary).'
/
comment on column vch_batch.total_amount is 'Total batch amount.'
/
comment on column vch_batch.currency is 'Currency.'
/
comment on column vch_batch.total_count is 'Total Count.'
/
comment on column vch_batch.reg_date is 'Date of batch registration.'
/
comment on column vch_batch.proc_date is 'Batch processing date.'
/
comment on column vch_batch.merchant_id is 'Merchant ID.'
/
comment on column vch_batch.terminal_id is 'Terminal ID.'
/
comment on column vch_batch.status_reason is 'Status Reason.'
/
comment on column vch_batch.user_id is 'User ID.'
/
comment on column vch_batch.inst_id is 'Inst ID.'
/
comment on column vch_batch.card_network_id is 'Card network ID.'
/
