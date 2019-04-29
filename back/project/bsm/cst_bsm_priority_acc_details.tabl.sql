create table cst_bsm_priority_acc_details(
    id                number(12)
  , file_date         date
  , customer_number   varchar2(30)
  , account_number    varchar2(30)
  , account_balance   number(22,4)
  , customer_balance  number(22,4)
  , agent_number      varchar2(30)
  , product_number    varchar2(30)
  , priority_flag     varchar2(1)
)
/

comment on table cst_bsm_priority_acc_details is 'Priority account details'
/
comment on column cst_bsm_priority_acc_details.id                is 'Identifier'
/
comment on column cst_bsm_priority_acc_details.file_date         is 'File refresh date'
/
comment on column cst_bsm_priority_acc_details.customer_number   is 'Customer number'
/
comment on column cst_bsm_priority_acc_details.account_number    is 'Account number'
/
comment on column cst_bsm_priority_acc_details.account_balance   is 'Account balance'
/
comment on column cst_bsm_priority_acc_details.customer_balance  is 'Customer Total Balance. For example, of Customer have 5 accounts in 1 CIF, this is total balance from those 5 accounts'
/
comment on column cst_bsm_priority_acc_details.agent_number      is 'Branch Code, where the customer open the Account'
/ 
comment on column cst_bsm_priority_acc_details.product_number    is 'Product code of the account, refer to master Product'
/ 
comment on column cst_bsm_priority_acc_details.priority_flag     is 'Flag to identify if the customer Priority Flag'
/
