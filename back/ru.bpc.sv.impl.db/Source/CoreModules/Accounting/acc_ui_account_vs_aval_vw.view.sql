create or replace force view acc_ui_account_vs_aval_vw as
select
    a.id
    , a.account_type
    , a.account_number
    , a.currency
    , a.inst_id
    , a.agent_id
    , a.status
    , a.contract_id
    , a.customer_id
    , a.split_hash
    , sum (
        case
            when t.aval_impact = 0 then 0
            when a.currency = b.currency then t.aval_impact * (b.balance + nvl(r.reserv_amount, 0))
            else t.aval_impact * com_api_rate_pkg.convert_amount(b.balance + nvl(r.reserv_amount, 0), b.currency, a.currency, t.rate_type, a.inst_id, sysdate)
        end
    ) balance
from
    acc_account a
    , acc_balance b
    , acc_balance_type t
    , acc_api_balance_reserv_vw r
where
    a.id = b.account_id
    and a.account_type = t.account_type
    and a.inst_id = t.inst_id
    and b.balance_type = t.balance_type
    and b.account_id = r.account_id(+)
    and b.balance_type = r.balance_type (+)
group by
    a.id
    , a.account_type
    , a.account_number
    , a.currency
    , a.inst_id
    , a.agent_id
    , a.status
    , a.contract_id
    , a.customer_id
    , a.split_hash
/    
