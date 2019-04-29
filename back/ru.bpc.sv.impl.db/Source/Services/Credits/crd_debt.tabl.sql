create table crd_debt
(
    id               number(16)
  , part_key         as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , account_id       number(12)
  , card_id          number(12)
  , product_id       number(8)
  , service_id       number(8)
  , oper_id          number(16)
  , oper_type        varchar2(8)
  , sttl_type        varchar2(8)
  , fee_type         varchar2(8)
  , terminal_type    varchar2(8)
  , oper_date        date
  , posting_date     date
  , sttl_day         number(4)
  , currency         varchar2(3)
  , amount           number(22,4)
  , debt_amount      number(22,4)
  , mcc              varchar2(4)
  , aging_period     number(4)
  , is_new           number(1)
  , status           varchar2(8)
  , inst_id          number(4)
  , agent_id         number(8)
  , split_hash       number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                                     -- [@skip patch]
subpartition by list (split_hash)                                                                       -- [@skip patch]
subpartition template                                                                                   -- [@skip patch]
(                                                                                                       -- [@skip patch]
    <subpartition_list>                                                                                 -- [@skip patch]
)                                                                                                       -- [@skip patch]
(                                                                                                       -- [@skip patch]
    partition crd_debt_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))                        -- [@skip patch]
)                                                                                                       -- [@skip patch]
******************** partition end *********************/
/

comment on table crd_debt is 'List of debts.'
/

comment on column crd_debt.id is 'Primary key. Debt identifier equal to Macros ID.'
/
comment on column crd_debt.account_id is 'Account identifier.'
/
comment on column crd_debt.card_id is 'Card identifier.'
/
comment on column crd_debt.product_id is 'Account product identifier.'
/
comment on column crd_debt.product_id is 'Credit service idebtifier.'
/
comment on column crd_debt.oper_id is 'Refrence to operation.'
/
comment on column crd_debt.oper_type is 'Operation type.'
/
comment on column crd_debt.sttl_type is 'Settlement type.'
/
comment on column crd_debt.fee_type is 'Fee type.'
/
comment on column crd_debt.terminal_type is 'Terminal type.'
/
comment on column crd_debt.oper_date is 'Operation date.'
/
comment on column crd_debt.posting_date is 'Posting date. Date when operation was processed.'
/
comment on column crd_debt.sttl_day is 'Settlement day.'
/
comment on column crd_debt.currency is 'Currency.'
/
comment on column crd_debt.amount is 'Total amount of macros.'
/
comment on column crd_debt.debt_amount is 'Part of macros amount processed as borrowed funds.'
/
comment on column crd_debt.mcc is 'Merchant Category Code.'
/
comment on column crd_debt.aging_period is 'Number of aging period.'
/
comment on column crd_debt.is_new is 'New debt meaning that it was made in current billing period.'
/
comment on column crd_debt.status is 'Debt status (Active, Paid, Suspended, Canceled).'
/
comment on column crd_debt.inst_id is 'Institution identifier.'
/
comment on column crd_debt.agent_id is 'Agent identifier.'
/
comment on column crd_debt.split_hash is 'Hash value to split further processing.'
/
alter table crd_debt add (macros_type_id number(4))
/
comment on column crd_debt.macros_type_id is 'Macros type registred as debt.'
/
comment on column crd_debt.service_id is 'Service identifier'
/
alter table crd_debt add (is_grace_enable number(1))
/
comment on column crd_debt.is_grace_enable is 'Interest could be canceled in grace period.'
/
alter table crd_debt add (is_grace_applied number(1))
/
comment on column crd_debt.is_grace_applied is 'Interest was canceled in grace period.'
/
alter table crd_debt add (is_reversal number(1))
/
comment on column crd_debt.is_reversal is 'Reversal indicator'
/
alter table crd_debt add (original_id number(16))
/
comment on column crd_debt.original_id is 'Identifier of original operation for reversals'
/
alter table crd_debt add (register_timestamp timestamp(6))
/
comment on column crd_debt.register_timestamp is 'Timestamp of registration'
/
alter table crd_debt drop column register_timestamp
/
