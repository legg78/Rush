create table acc_account (
    id                  number(12)
  , split_hash          number(4)
  , account_type        varchar2(8)
  , account_number      varchar2(32)
  , currency            varchar2(3)
  , inst_id             number(4)
  , agent_id            varchar2(12) 
  , customer_id         number(12)
  , contract_id         number(12)
  , status              varchar2(8)
  , scheme_id           number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table acc_account is 'Accounts are stored here.'
/
comment on column acc_account.id is 'Primary key - internal account identifier.'
/
comment on column acc_account.split_hash is 'Hash value to split further processing'
/
comment on column acc_account.account_type is 'Account type (ACTP key).'
/
comment on column acc_account.account_number is 'Account number.'
/
comment on column acc_account.currency is 'Default currency of account balances.'
/
comment on column acc_account.inst_id is 'Institution which owns account.'
/
comment on column acc_account.agent_id is 'Agent which owns account.'
/
comment on column acc_account.customer_id is 'Account owner.'
/
comment on column acc_account.contract_id is 'Reference to contract describing terms of service of account.'
/
comment on column acc_account.status is 'Account status (ACST key).'
/
comment on column acc_account.scheme_id is 'Scheme identifier'
/
alter table acc_account enable row movement
/
