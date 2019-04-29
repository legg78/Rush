create or replace force view crd_ui_debt_balance_vw as
select db.id
     , db.debt_id
     , db.debt_intr_id
     , db.balance_type
     , db.amount
     , db.repay_priority
     , db.min_amount_due
     , db.split_hash
	 , d.currency
  from crd_debt_balance db
     , crd_debt d
  where db.debt_id = d.id
/
