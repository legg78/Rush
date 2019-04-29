create or replace force view crd_aging_vw as
select n.id
     , n.invoice_id
     , n.aging_period
     , n.aging_date
     , n.aging_amount
     , n.split_hash
  from crd_aging n
/
