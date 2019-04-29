create table acq_reimb_oper (
    id             number(16)
  , part_key       as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , batch_id       number(12)
  , channel_id     number(4)
  , pos_batch_id   number(12)
  , oper_date      date
  , posting_date   date
  , sttl_day       number(4)
  , reimb_date     date
  , merchant_id    number(8)
  , account_id     number(12)
  , card_number    varchar2(24)
  , auth_code      varchar2(6)
  , refnum         varchar2(12)
  , gross_amount   number(22 , 4)
  , service_charge number(22 , 4)
  , tax_amount     number(22 , 4)
  , net_amount     number(22 , 4)
  , inst_id        number(4)
  , split_hash     number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition acq_reimb_oper_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table acq_reimb_oper is 'Operations for reimbursement.'
/

comment on column acq_reimb_oper.id is 'Primary key. Equal to operation identifier.'
/

comment on column acq_reimb_oper.batch_id is 'Reference to reimbursement batch.'
/
comment on column acq_reimb_oper.channel_id is 'Reference to reimbursement channel.'
/
comment on column acq_reimb_oper.pos_batch_id is 'POS batch identifier.'
/
comment on column acq_reimb_oper.oper_date is 'Operation date.'
/
comment on column acq_reimb_oper.posting_date is 'Posting date.'
/
comment on column acq_reimb_oper.sttl_day is 'Settlement day.'
/
comment on column acq_reimb_oper.reimb_date is 'Reimbursement date.'
/
comment on column acq_reimb_oper.merchant_id is 'Merchant identifier.'
/
comment on column acq_reimb_oper.account_id is 'Account identifier.'
/
comment on column acq_reimb_oper.card_number is 'Card Number.'
/
comment on column acq_reimb_oper.auth_code is 'Authorization Code.'
/
comment on column acq_reimb_oper.refnum is 'Retrieval Reference Number'
/
comment on column acq_reimb_oper.gross_amount is 'Operation gross amount.'
/
comment on column acq_reimb_oper.service_charge is 'Amount of service charge.'
/
comment on column acq_reimb_oper.tax_amount is 'Tax amount.'
/
comment on column acq_reimb_oper.net_amount is 'Net amount.'
/
comment on column acq_reimb_oper.inst_id is 'Insitution identifier.'
/
comment on column acq_reimb_oper.split_hash is 'Split hash value.'
/

