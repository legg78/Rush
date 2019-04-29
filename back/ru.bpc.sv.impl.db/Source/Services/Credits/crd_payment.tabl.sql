create table crd_payment
(
    id                number(16)
  , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , oper_id           number(16)
  , is_reversal       number(1)
  , original_oper_id  number(16)
  , account_id        number(12)
  , card_id           number(12)
  , product_id        number(8)
  , posting_date      date
  , sttl_day          number(4)
  , currency          varchar2(3)
  , amount            number(22,4)
  , pay_amount        number(22,4)
  , is_new            number(1)
  , status            varchar2(8)
  , inst_id           number(4)
  , agent_id          number(8)
  , split_hash        number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition crd_payment_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table crd_payment is 'Payments, reversals and refunds.'
/

comment on column crd_payment.id is 'Primary key. Payment identifier equal to Macros ID.'
/
comment on column crd_payment.oper_id is 'Refrence to operation.'
/
comment on column crd_payment.is_reversal is 'Reversal flag.'
/
comment on column crd_payment.original_oper_id is 'Original operation identifier if reversal.'
/
comment on column crd_payment.account_id is 'Account identifier.'
/
comment on column crd_payment.card_id is 'Card identifier.'
/
comment on column crd_payment.product_id is 'Account product identifier.'
/
comment on column crd_payment.posting_date is 'Posting date. Date when operation was processed.'
/
comment on column crd_payment.sttl_day is 'Settlement day.'
/
comment on column crd_payment.currency is 'Currency.'
/
comment on column crd_payment.amount is 'Total amount of macros.'
/
comment on column crd_payment.pay_amount is 'Payment amount remainder.'
/
comment on column crd_payment.is_new is 'New payment meaning that it was made in current billing period.'
/
comment on column crd_payment.status is 'Payment status (Active, Spend).'
/
comment on column crd_payment.inst_id is 'Institution identifier.'
/
comment on column crd_payment.agent_id is 'Agent identifier.'
/
comment on column crd_payment.split_hash is 'Hash value to split further processing.'
/
