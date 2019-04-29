create table crd_debt_payment
(
    id            number(16)
  , part_key      as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , debt_id       number(16)
  , balance_type  varchar2(8)
  , pay_id        number(16)
  , pay_amount    number(22,4)
  , eff_date      date
  , split_hash    number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
subpartition by list (split_hash)                                                         -- [@skip patch]
subpartition template                                                                     -- [@skip patch]
(                                                                                         -- [@skip patch]
    <subpartition_list>                                                                   -- [@skip patch]
)                                                                                         -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition crd_debt_payment_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))  -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table crd_debt_payment is 'Debts paid by payments.'
/

comment on column crd_debt_payment.id is 'Primary key.'
/
comment on column crd_debt_payment.debt_id is 'Debt identifier.'
/
comment on column crd_debt_payment.balance_type is 'Balance type.'
/
comment on column crd_debt_payment.pay_id is 'Payment identifier.'
/
comment on column crd_debt_payment.pay_amount is 'Paid amount.'
/
comment on column crd_debt_payment.eff_date is 'Effective date.'
/
comment on column crd_debt_payment.split_hash is 'Hash value to split further processing.'
/
alter table crd_debt_payment add (pay_mandatory_amount number(22,4))
/
comment on column crd_debt_payment.pay_mandatory_amount is 'Paid mandatory amount'
/
alter table crd_debt_payment add (bunch_id number(16))
/
comment on column crd_debt_payment.bunch_id is 'Bunch of entries created for repayment'
/

