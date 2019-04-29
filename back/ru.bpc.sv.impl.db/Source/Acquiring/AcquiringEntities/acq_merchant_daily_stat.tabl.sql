create table acq_merchant_daily_stat(
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

comment on table acq_merchant_daily_stat is 'Daily statistic of merchants.'
/
comment on column acq_merchant_daily_stat.ID is 'Identifier of statistic'
/
comment on column acq_merchant_daily_stat.customer_id is 'Identifier of merchant customer'
/
comment on column acq_merchant_daily_stat.customer_number is 'External (CBS) customer number'
/
comment on column acq_merchant_daily_stat.account_id is 'Identifier of acquirer account'
/
comment on column acq_merchant_daily_stat.account_number is 'Account number'
/
comment on column acq_merchant_daily_stat.currency_code is 'Account currency short code'
/
comment on column acq_merchant_daily_stat.currency_name is 'Account currency short name'
/
comment on column acq_merchant_daily_stat.stat_date is 'Statistic date'
/
comment on column acq_merchant_daily_stat.amount_sum is 'Sum of amount of all transactions on the customer account in the account currency in the date Without fee transactions'
/
comment on column acq_merchant_daily_stat.fee_sum is 'Sum of all fees earned on the customer account in the account currency in the date'
/
comment on column acq_merchant_daily_stat.trxn_count_total is 'Total count of transactions in the date on the merchant account Without fee transactions'
/
comment on column acq_merchant_daily_stat.trxn_count_pay is 'Total count of payment transactions in the date on the merchant account Payment orders'
/
comment on column acq_merchant_daily_stat.trxn_count_trf is 'Total count of money transfer transactions in the date on the merchant account Fund transfers'
/
comment on column acq_merchant_daily_stat.trxn_count_dep is 'Total count of deposit transactions in the date on the merchant account'
/
comment on column acq_merchant_daily_stat.trxn_count_cash is 'Total count of cash withdrawal transactions in the date on the merchant account'
/

drop table acq_merchant_daily_stat
/
create table acq_merchant_daily_stat(
    id                number(16)
  , part_key          as (to_date(substr(to_char(id), 1, 6), 'yymmdd')) virtual
  , split_hash        number(4)
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
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition acq_merchant_dstat_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/

comment on table acq_merchant_daily_stat is 'Daily statistic of merchants.'
/
comment on column acq_merchant_daily_stat.ID is 'Identifier of statistic'
/
comment on column acq_merchant_daily_stat.split_hash is 'Hash value to split further processing'
/
comment on column acq_merchant_daily_stat.customer_id is 'Identifier of merchant customer'
/
comment on column acq_merchant_daily_stat.customer_number is 'External (CBS) customer number'
/
comment on column acq_merchant_daily_stat.account_id is 'Identifier of acquirer account'
/
comment on column acq_merchant_daily_stat.account_number is 'Account number'
/
comment on column acq_merchant_daily_stat.currency_code is 'Account currency short code'
/
comment on column acq_merchant_daily_stat.currency_name is 'Account currency short name'
/
comment on column acq_merchant_daily_stat.stat_date is 'Statistic date'
/
comment on column acq_merchant_daily_stat.amount_sum is 'Sum of amount of all transactions on the customer account in the account currency in the date Without fee transactions'
/
comment on column acq_merchant_daily_stat.fee_sum is 'Sum of all fees earned on the customer account in the account currency in the date'
/
comment on column acq_merchant_daily_stat.trxn_count_total is 'Total count of transactions in the date on the merchant account Without fee transactions'
/
comment on column acq_merchant_daily_stat.trxn_count_pay is 'Total count of payment transactions in the date on the merchant account Payment orders'
/
comment on column acq_merchant_daily_stat.trxn_count_trf is 'Total count of money transfer transactions in the date on the merchant account Fund transfers'
/
comment on column acq_merchant_daily_stat.trxn_count_dep is 'Total count of deposit transactions in the date on the merchant account'
/
comment on column acq_merchant_daily_stat.trxn_count_cash is 'Total count of cash withdrawal transactions in the date on the merchant account'
/

