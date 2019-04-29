create or replace force view crd_debt_interest_vw as
select 
    id
    , debt_id
    , balance_type
    , balance_date
    , amount
    , min_amount_due
    , interest_amount
    , fee_id
    , is_charged
    , is_grace_enable
    , split_hash
    , add_fee_id
    , is_waived
from
    crd_debt_interest
/
