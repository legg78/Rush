create or replace force view crd_ui_invoice_vw as
select a.account_number
     , a.currency
     , b.id
     , b.account_id
     , b.serial_number
     , b.invoice_date
     , b.invoice_type
     , b.min_amount_due
     , b.total_amount_due
     , b.own_funds
     , b.exceed_limit
     , b.start_date
     , b.due_date
     , b.grace_date
     , b.penalty_date
     , b.is_mad_paid
     , b.is_tad_paid
     , b.aging_period
     , crd_ui_account_info_pkg.get_aging_period_name(i_aging_period => b.aging_period) as aging_period_name
     , b.agent_id
     , b.inst_id
     , b.overlimit_balance
     , b.overdue_balance
     , b.overdue_intr_balance
     , b.overdraft_balance
     , b.hold_balance
     , b.available_balance
     , b.postal_code
     , b.agent_number
     , b.overdue_date
     , b.interest_balance
     , b.interest_amount
     , b.payment_amount
     , b.expense_amount 
     , b.fee_amount 
     , b.split_hash
     , b.irr
     , b.apr
     , b.waive_interest_amount
  from acc_account a
     , crd_invoice b
 where b.account_id = a.id
/
