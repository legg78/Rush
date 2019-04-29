create or replace force view acc_entry_vw as
  select id
     , split_hash
     , macros_id
     , bunch_id
     , transaction_id
     , transaction_type
     , account_id
     , amount
     , currency
     , balance_type
     , balance_impact
     , balance
     , rounding_balance
     , rounding_error
     , posting_date
     , posting_order
     , sttl_day
     , sttl_date
     , status
     , ref_entry_id
  from  acc_entry
/
