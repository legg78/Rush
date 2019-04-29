create or replace force view crd_ui_debt_payment_vw as 
select d.id
     , d.balance_type
     , d.pay_amount debt_pay_amount
     , d.eff_date
     , d.debt_id
     , p.is_reversal
     , p.original_oper_id
     , p.posting_date
     , p.sttl_day
     , p.currency
     , p.amount
     , p.pay_amount
     , p.is_new
     , p.status
     , o.oper_date
  from crd_debt_payment d
     , crd_payment p
     , opr_operation o
 where d.pay_id  = p.id 
   and p.oper_id = o.id
/
