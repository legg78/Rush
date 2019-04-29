create or replace force view aap_ui_terminal_account_vw as
select
    t.lang
  , c.inst_id
  , t.id terminal_id
  , a.id account_id
  , a.account_number
  , t.terminal_number
  , m.merchant_number
  , t.description
  , c.contract_number
  , account_type||' '||currency||' '||account_number account_label
  , t.contract_id
  , (select count(id)
       from acc_account_object o
      where o.entity_type = 'ENTTTRMN'
        and o.object_id   = t.id
        and o.account_id  = a.id) is_linked
  , m.risk_indicator
from acq_ui_terminal_vw t
   , acc_account a
   , prd_contract c
   , acq_merchant m
where
    c.id     = a.contract_id
    and c.id = m.contract_id
    and m.id = t.merchant_id
/
