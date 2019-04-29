create or replace force view crd_ui_payment_expenditure_vw as 
select d.id
     , d.debt_id
     , d.balance_type
     , d.pay_id
     , d.pay_amount debt_pay_amount
     , d.eff_date
     , x.oper_type
     , x.oper_date
     , x.posting_date
     , x.sttl_day
     , x.currency
     , x.amount
     , x.debt_amount
     , x.status
     , x.oper_id
  from crd_debt_payment d
     , crd_debt x
 where d.debt_id = x.id 
/
