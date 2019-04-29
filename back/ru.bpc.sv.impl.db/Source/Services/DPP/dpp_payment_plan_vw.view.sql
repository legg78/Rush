create or replace force view dpp_payment_plan_vw as
select
    a.id
  , a.oper_id
  , a.reg_oper_id
  , a.account_id
  , a.card_id
  , a.product_id
  , a.oper_date
  , a.oper_amount
  , a.oper_currency
  , a.dpp_amount
  , a.dpp_currency
  , a.interest_amount
  , a.status
  , a.instalment_amount
  , a.instalment_total
  , a.instalment_billed
  , a.next_instalment_date
  , a.debt_balance
  , a.inst_id
  , a.split_hash
  , a.posting_date
  , a.oper_type
from
   dpp_payment_plan a
/
