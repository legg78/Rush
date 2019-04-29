create or replace force view acc_ui_macros_vw as
select t.id
     , t.entity_type
     , t.object_id
     , t.macros_type_id
     , t.posting_date
     , t.account_id
     , t.amount_purpose
     , t.amount
     , t.currency
     , t.fee_id
     , t.fee_tier_id
     , t.fee_mod_id
     , t.details_data
     , t.conversion_rate
     , t.rate_type
  from acc_macros_vw t
/
