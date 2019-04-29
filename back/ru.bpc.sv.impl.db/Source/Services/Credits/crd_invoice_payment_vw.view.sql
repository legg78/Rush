create or replace force view crd_invoice_payment_vw as
select 
    id
    , invoice_id
    , pay_id
    , pay_amount
    , is_new
    , split_hash
from
    crd_invoice_payment
/
