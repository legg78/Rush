create or replace force view cln_ui_customer_account_vw as
select c.id as case_id
     , c.customer_id
     , c.inst_id
     , c.split_hash
     , a.id as account_id
     , a.account_number
     , a.account_type
     , a.currency as account_currency
     , crd_invoice_pkg.calculate_total_outstanding(
           i_account_id    => a.id
         , i_payoff_date   => get_sysdate
       ) as tad
     , (i.overdue_balance + i.overdue_intr_balance) as overdue
     , i.aging_period
  from cln_case     c
     , acc_account  a
     , crd_invoice  i
 where c.customer_id = a.customer_id
   and c.split_hash  = a.split_hash
   and i.id = crd_invoice_pkg.get_last_invoice_id(a.id, a.split_hash, 1)
/

