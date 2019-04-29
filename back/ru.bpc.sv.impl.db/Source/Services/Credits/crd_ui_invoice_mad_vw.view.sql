create or replace force view crd_ui_invoice_mad_vw as
select n.id
     , n.debt_id
     , n.balance_type
     , n.amount
     , n.min_amount_due
	 , d.currency
     , d.oper_id
     , d.macros_type_id
     , d.oper_type
     , d.oper_date
     , d.fee_type            
     , d.debt_amount
     , d.status
     , com_api_i18n_pkg.get_text('acc_macros_type', 'name', d.macros_type_id, l.lang) macros_type_name
     , i.invoice_id
     , l.lang
  from crd_debt_interest n
     , crd_debt d
     , crd_invoice_debt i
     , com_language_vw l
  where i.debt_intr_id = n.id
    and i.debt_id      = d.id
/
