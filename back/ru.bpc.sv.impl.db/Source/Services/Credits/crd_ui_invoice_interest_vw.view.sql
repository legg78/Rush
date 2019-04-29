create or replace force view crd_ui_invoice_interest_vw as
select t.id
     , t.debt_id
     , t.balance_type
     , t.start_date
     , t.amount
     , t.min_amount_due
     , t.interest_amount
     , t.fee_id
     , t.fee_desc
     , t.add_fee_id
     , t.add_fee_desc
     , t.is_charged
     , t.is_grace_enable
     , i.id invoice_id
     , t.split_hash
     , i.invoice_date
     , d.currency
     , d.oper_id
     , d.oper_type
     , d.oper_date
  from crd_ui_debt_interest_vw t
     , crd_invoice i
     , crd_debt d
 where t.debt_id = d.id
   and i.id = t.invoice_id
   and t.interest_amount > 0
   and t.split_hash = i.split_hash
/
