create or replace force view crd_debt_vw as
select 
    id
  , account_id
  , card_id
  , product_id
  , service_id
  , oper_id
  , oper_type
  , sttl_type
  , fee_type
  , terminal_type
  , oper_date
  , posting_date
  , sttl_day
  , currency
  , amount
  , debt_amount
  , mcc
  , aging_period
  , is_new
  , status
  , inst_id
  , agent_id
  , split_hash
  , macros_type_id
  , is_grace_enable
  , is_grace_applied
  , is_reversal
from crd_debt
/
