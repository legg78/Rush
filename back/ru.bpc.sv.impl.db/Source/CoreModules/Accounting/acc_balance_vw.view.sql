create or replace force view acc_balance_vw as
select
    a.id
  , a.split_hash
  , a.account_id
  , a.balance_number
  , a.balance_type
  , a.balance
  , a.rounding_balance
  , a.currency
  , a.entry_count
  , a.status
  , a.inst_id
  , a.open_date
  , a.close_date
  , a.open_sttl_date
  , a.close_sttl_date
from
    acc_balance a
/
