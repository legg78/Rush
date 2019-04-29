create or replace force view crd_ui_invoice_payment_vw as
select a.pay_id
     , a.invoice_id
     , b.amount
     , b.currency
     , get_text('acc_macros_type', 'name', b.macros_type_id) macros_type
     , c.oper_date
     , c.oper_type
     , c.merchant_name
     , c.merchant_city
     , c.merchant_country
     , c.merchant_street
     , c.oper_amount
     , c.oper_currency
  from crd_invoice_payment a
     , acc_macros b
     , opr_operation c
 where a.pay_id = b.id
   and b.entity_type = 'ENTTOPER'
   and b.object_id = c.id
/
