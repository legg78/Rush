create table cst_amk_agent_daily_stat(
    id                number(12)
  , customer_id       number(12)
  , customer_number   varchar2(200)
  , account_id        number(12)
  , account_number    varchar2(32)
  , currency_code     varchar2(3)
  , currency_name     varchar2(3)
  , stat_date         date
  , amount_sum        number(22,4)
  , fee_sum           number(22,4)
  , trxn_count_total  number(10)
  , trxn_count_pay    number(10)
  , trxn_count_trf    number(10)
  , trxn_count_dep    number(10)
  , trxn_count_cash   number(10)  
)
/

comment on table cst_amk_agent_daily_stat is 'AMK daily statistic of agents.'
/
comment on column cst_amk_agent_daily_stat.id  is 'Identifier of statistic'
/
comment on column cst_amk_agent_daily_stat.customer_id is 'Identifier of agent customer'
/
comment on column cst_amk_agent_daily_stat.customer_number is 'External (CBS) customer number'
/
comment on column cst_amk_agent_daily_stat.account_id is 'Identifier of acquirer account'
/
comment on column cst_amk_agent_daily_stat.account_number is 'Account number'
/
comment on column cst_amk_agent_daily_stat.currency_code is 'Account currency short code'
/
comment on column cst_amk_agent_daily_stat.currency_name is 'Account currency short name'
/
comment on column cst_amk_agent_daily_stat.stat_date is 'Statistic date'
/
comment on column cst_amk_agent_daily_stat.amount_sum is 'Sum of amount of all transactions on the customer account in the account currency in the date Without fee transactions'
/
comment on column cst_amk_agent_daily_stat.fee_sum is 'Sum of all fees earned on the customer account in the account currency in the date'
/
comment on column cst_amk_agent_daily_stat.trxn_count_total is 'Total count of transactions in the date on the agent account Without fee transactions'
/
comment on column cst_amk_agent_daily_stat.trxn_count_pay is 'Total count of payment transactions in the date on the agent account Payment orders'
/
comment on column cst_amk_agent_daily_stat.trxn_count_trf is 'Total count of money transfer transactions in the date on the agent account Fund transfers'
/
comment on column cst_amk_agent_daily_stat.trxn_count_dep is 'Total count of deposit transactions in the date on the agent account'
/
comment on column cst_amk_agent_daily_stat.trxn_count_cash is 'Total count of cash withdrawal transactions in the date on the agent account'
/
drop table cst_amk_agent_daily_stat
/
