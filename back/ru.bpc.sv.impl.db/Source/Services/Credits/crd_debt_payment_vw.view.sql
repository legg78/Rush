create or replace force view crd_debt_payment_vw as
select 
    id
    , debt_id
    , balance_type
    , pay_id
    , pay_amount
    , eff_date
    , split_hash
from
    crd_debt_payment
/
