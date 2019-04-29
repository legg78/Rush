create table acc_balance
(
    id                  number(12)
  , split_hash          number(4)
  , account_id          number(12)
  , balance_number      varchar2(32)
  , balance_type        varchar2(8)
  , balance             number(22,4)
  , rounding_balance    number(22,4)
  , currency            varchar2(3)
  , entry_count         number(8)
  , status              varchar2(8)
  , inst_id             number(4)
  , open_date           date
  , close_date          date
  , open_sttl_date      date
  , close_sttl_date     date
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table acc_balance is 'Account balances are stored here.'
/
comment on column acc_balance.entry_count is 'Number of entries been posted on balance.'
/
comment on column acc_balance.status is 'Balance status (BLST).'
/
comment on column acc_balance.id is 'Primary key.'
/
comment on column acc_balance.account_id is 'Account identifier.'
/
comment on column acc_balance.balance_type is 'Balance type.'
/
comment on column acc_balance.balance is 'Balance amount.'
/
comment on column acc_balance.rounding_balance is 'Balance rounding amount.'
/
comment on column acc_balance.currency is 'Currency. Could be differ from account currency.'
/
comment on column acc_balance.split_hash is 'Hash value to split further processing'
/
comment on column acc_balance.balance_number is 'Balance number for external reference'
/
comment on column acc_balance.open_date is 'Date when balance was Activated'
/
comment on column acc_balance.close_date is 'Date when balance was closed'
/
comment on column acc_balance.open_sttl_date is 'Settlement date when balance was Activated'
/
comment on column acc_balance.close_sttl_date is 'Settlement date when balance was closed'
/
comment on column acc_balance.inst_id is 'Institution identifier'
/
alter table acc_balance enable row movement
/
alter table acc_balance modify entry_count number(12)
/
