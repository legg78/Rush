create table acq_reimb_batch
(
    id               number(16)                                       -- [@skip patch]
  , part_key         as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , seqnum           number(4)
  , channel_id       number(4)
  , pos_batch_id     number(12)
  , oper_date        date
  , posting_date     date
  , sttl_day         number(4)
  , reimb_date       date
  , merchant_id      number(8)
  , account_id       number(12)
  , cheque_number    varchar2(200)
  , status           varchar2(8)
  , gross_amount     number(22,4)
  , service_charge   number(22,4)
  , tax_amount       number(22,4)
  , net_amount       number(22,4)
  , oper_count       number(8)
  , inst_id          number(4)
  , session_file_id  number(8)
  , split_hash       number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition acq_reimb_batch_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table acq_reimb_batch is 'Reimbursement batches. Mostly represent a single payment document.'
/

comment on column acq_reimb_batch.id is 'Primary key.'
/
comment on column acq_reimb_batch.channel_id is 'Reference to reimbursement channel.'
/
comment on column acq_reimb_batch.pos_batch_id is 'POS batch identifier.'
/
comment on column acq_reimb_batch.oper_date is 'Operation date.'
/
comment on column acq_reimb_batch.posting_date is 'Posting date.'
/
comment on column acq_reimb_batch.sttl_day is 'Settlement day.'
/
comment on column acq_reimb_batch.reimb_date is 'Reimbursement date.'
/
comment on column acq_reimb_batch.merchant_id is 'Merchant identifier.'
/
comment on column acq_reimb_batch.cheque_number is 'Number of cheque. Generating by pre-defined rules.'
/
comment on column acq_reimb_batch.status is 'Batch status. '
/
comment on column acq_reimb_batch.gross_amount is 'Total batch gross amount.'
/
comment on column acq_reimb_batch.service_charge is 'Amount of service charge.'
/
comment on column acq_reimb_batch.tax_amount is 'Tax amount.'
/
comment on column acq_reimb_batch.net_amount is 'Net amount.'
/
comment on column acq_reimb_batch.oper_count is 'Count of operations in batch.'
/
comment on column acq_reimb_batch.inst_id is 'Insitution identifier.'
/
comment on column acq_reimb_batch.split_hash is 'Split hash value.'
/
comment on column acq_reimb_batch.account_id is 'Account identifier.'
/
comment on column acq_reimb_batch.session_file_id is 'Identifier of file containing uploaded batch.'
/
comment on column acq_reimb_batch.seqnum is 'Sequence number. Describe data version.'
/
