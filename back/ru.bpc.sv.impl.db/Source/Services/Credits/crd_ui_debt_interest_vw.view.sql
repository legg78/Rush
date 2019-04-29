create or replace force view crd_ui_debt_interest_vw as
select id
     , debt_id
     , balance_type
     , balance_date start_date
     , amount
     , min_amount_due
     , interest_amount
     , fee_id
     , crd_cst_interest_pkg.get_fee_desc(i_debt_intr_id => id, i_fee_id => fee_id) fee_desc
     , add_fee_id
     , crd_cst_interest_pkg.get_fee_desc(i_debt_intr_id => id, i_fee_id => add_fee_id) add_fee_desc
     , is_charged
     , is_grace_enable
     , invoice_id
     , split_hash
     , posting_order
     , is_waived
  from crd_debt_interest
/
