create table crd_debt_interest
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , debt_id             number(16)
  , balance_type        varchar2(8)
  , balance_date        date
  , amount              number(22,4)
  , min_amount_due      number(22,4)
  , interest_amount     number(22,4)
  , fee_id              number(8)
  , is_charged          number(1)
  , is_grace_enable     number(1)
  , invoice_id          number(12)
  , split_hash          number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                        -- [@skip patch]
subpartition by list (split_hash)                                                          -- [@skip patch]
subpartition template                                                                      -- [@skip patch]
(                                                                                          -- [@skip patch]
    <subpartition_list>                                                                    -- [@skip patch]
)                                                                                          -- [@skip patch]
(                                                                                          -- [@skip patch]
    partition crd_debt_interest_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))  -- [@skip patch]
)                                                                                          -- [@skip patch]
******************** partition end ********************/
/

comment on table crd_debt_interest is 'Debt state history. Using for interest calculating.'
/

comment on column crd_debt_interest.id is 'Primary key.'
/
comment on column crd_debt_interest.debt_id is 'Debt identifier.'
/
comment on column crd_debt_interest.balance_type is 'Balance type.'
/
comment on column crd_debt_interest.balance_date is 'Balance date. Date when balance or other environment (period, fee, charge flag) was changed.'
/
comment on column crd_debt_interest.min_amount_due is 'Minimum amount due.'
/
comment on column crd_debt_interest.interest_amount is 'Calculated interest amount.'
/
comment on column crd_debt_interest.fee_id is 'Reference to algorithm using for calculating interest.'
/
comment on column crd_debt_interest.is_charged is 'Interest charged flag.'
/
comment on column crd_debt_interest.is_grace_enable is 'Interest could be canceled in grace period.'
/
comment on column crd_debt_interest.invoice_id is 'Invoice identifier.'
/
comment on column crd_debt_interest.split_hash is 'Hash value to split further processing.'
/
comment on column crd_debt_interest.amount is 'Total amount of macros.'
/
alter table crd_debt_interest add add_fee_id number(8)
/
comment on column crd_debt_interest.add_fee_id is 'Reference to algorithm using for calculating additional interest.'
/
comment on column crd_debt_interest.is_grace_enable is 'Obsolete. Moved to CRD_DEBT table.'
/
alter table crd_debt_interest add posting_order number(8)
/
comment on column crd_debt_interest.posting_order is 'Order of entry posting on balance'
/
alter table crd_debt_interest add event_type varchar2(8)
/
comment on column crd_debt_interest.event_type is 'Event type raising funds flow.'
/
alter table crd_debt_interest add is_waived number(1)
/
comment on column crd_debt_interest.is_waived is 'Interest waived flag.'
/

