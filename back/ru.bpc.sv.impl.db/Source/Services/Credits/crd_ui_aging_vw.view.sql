create or replace force view crd_ui_aging_vw as
select n.id
     , n.invoice_id
     , n.aging_period
     , crd_ui_account_info_pkg.get_aging_period_name(i_aging_period => n.aging_period) as aging_period_name
     , n.aging_date
     , n.aging_amount
     , n.split_hash
  from crd_aging n
/
