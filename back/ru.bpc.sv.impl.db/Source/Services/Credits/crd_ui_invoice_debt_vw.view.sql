create or replace force view crd_ui_invoice_debt_vw as
select b.id debt_id
     , a.id invoice_id
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
     , iss_api_card_pkg.get_card_mask(i_card_number => d.card_number) as card_number
     , b.amount_purpose
  from crd_invoice a
     , acc_macros b
     , opr_operation c
     , opr_card d
 where b.id in (select debt_id from crd_invoice_debt d where a.id = d.invoice_id and is_new = 1)
   and b.entity_type = 'ENTTOPER'
   and b.object_id = c.id
   and d.oper_id(+) = c.id
   and d.participant_type(+) = 'PRTYISS'
/
