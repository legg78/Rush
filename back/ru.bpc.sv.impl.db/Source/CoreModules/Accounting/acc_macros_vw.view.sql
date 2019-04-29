create or replace force view acc_macros_vw as
select id
     , entity_type
     , object_id
     , macros_type_id
     , posting_date
     , account_id
     , amount_purpose
     , amount
     , currency
     , fee_id
     , fee_tier_id
     , fee_mod_id
     , details_data
     , conversion_rate
     , rate_type
  from acc_macros
/