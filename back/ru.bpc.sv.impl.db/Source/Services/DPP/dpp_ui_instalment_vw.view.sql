create or replace force view dpp_ui_instalment_vw as
select a.id
     , a.dpp_id
     , a.instalment_number
     , a.instalment_date
     , a.instalment_amount
     , a.payment_amount
     , a.interest_amount
     , a.macros_id
     , nvl2(a.macros_id, 1, 0) as is_bill
     , a.acceleration_type
     , a.split_hash
     , c.currency
     , a.fee_id
     , a.acceleration_reason
  from dpp_instalment_vw a
     , dpp_payment_plan b
     , acc_account c
 where a.dpp_id = b.id
   and b.account_id = c.id
/
