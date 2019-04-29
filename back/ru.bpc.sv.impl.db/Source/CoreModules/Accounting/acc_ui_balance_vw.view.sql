create or replace force view acc_ui_balance_vw as
select
    a.id
  , a.split_hash
  , a.account_id
  , a.balance_number
  , a.balance_type
  , case when t.balance_algorithm is null then a.balance + nvl(r.reserv_amount, 0) 
         else acc_cst_balance_pkg.get_balance_amount (a.account_id, t.balance_algorithm)
    end balance
  , a.rounding_balance
  , a.currency
  , a.entry_count
  , a.status
  , a.inst_id
  , a.open_date
  , a.close_date
from
    acc_balance a
    , acc_api_balance_reserv_vw r
    , acc_balance_type t
    , acc_account ac
where 
    a.inst_id in (select inst_id from acm_cu_inst_vw)
    and a.account_id = r.account_id(+)
    and a.balance_type  = r.balance_type (+)
    and t.balance_type  = a.balance_type
    and ac.account_type = t.account_type
    and ac.inst_id      = t.inst_id
    and ac.inst_id      = a.inst_id 
    and ac.id           = a.account_id      
/
