create or replace force view crd_payment_vw as
select 
    id
  , oper_id
  , is_reversal
  , original_oper_id
  , account_id
  , product_id
  , posting_date
  , sttl_day
  , currency
  , amount
  , pay_amount
  , is_new
  , status
  , inst_id
  , agent_id
  , split_hash
from crd_payment
/
