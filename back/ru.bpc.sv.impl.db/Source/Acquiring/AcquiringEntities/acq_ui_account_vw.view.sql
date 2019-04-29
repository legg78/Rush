create or replace force view acq_ui_account_vw as
select a.id
     , a.account_type
     , a.account_number
     , a.currency
     , a.inst_id
     , a.agent_id
     , a.status
     , a.contract_id
     , a.customer_id
     , a.split_hash
     , a.scheme_id
     , t.contract_number
     , t.product_id
     , c.entity_type customer_type
     , c.customer_number
     , p.product_type
     , acc_api_balance_pkg.get_aval_balance_amount_only(a.id) balance
  from acc_account a
     , prd_customer c
     , prd_contract t
     , prd_product p
 where a.agent_id in (select agent_id from acm_cu_agent_vw)
   and a.customer_id = c.id
   and a.split_hash = c.split_hash
   and a.contract_id = t.id
   and a.split_hash = t.split_hash
   and t.product_id = p.id
   and p.product_type in ('PRDT0200')
/
