create or replace force view acc_balance_type_vw as
select a.id
     , a.seqnum
     , a.account_type
     , a.balance_type
     , a.inst_id
     , a.currency
     , a.rate_type
     , a.aval_impact
     , a.status
     , a.number_format_id
     , a.number_prefix
     , a.update_macros_type
     , a.balance_algorithm
from acc_balance_type a
/
