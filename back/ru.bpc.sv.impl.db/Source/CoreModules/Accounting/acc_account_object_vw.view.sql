create or replace force view acc_account_object_vw as
select a.id
     , a.account_id 
     , a.entity_type
     , a.object_id
     , a.usage_order 
     , a.is_pos_default 
     , a.is_atm_default
     , a.is_atm_currency
     , a.is_pos_currency
     , a.account_seq_number
     , a.split_hash
  from acc_account_object a
/
