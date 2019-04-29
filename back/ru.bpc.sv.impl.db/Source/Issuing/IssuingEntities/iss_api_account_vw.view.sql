create or replace force view iss_api_account_vw as
select
    a.id
    , a.split_hash
    , a.account_type
    , a.account_number
    , a.currency
    , a.inst_id
    , a.agent_id
    , a.status
    , a.contract_id
    , a.customer_id
    , acc_api_balance_pkg.get_aval_balance_amount_only(a.id) balance
from acc_account_type t
    , acc_account a
where
    t.account_type = a.account_type
    and t.product_type in ('PRDT0100', 'PRDT0300')
    and t.inst_id = a.inst_id
/
