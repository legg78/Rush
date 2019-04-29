create or replace force view prd_ui_contract_vw as
select n.id
     , n.seqnum
     , n.product_id
     , n.start_date
     , n.end_date
     , n.contract_number
     , n.contract_type
     , n.inst_id
     , n.agent_id
     , n.customer_id
     , n.split_hash
     , (select min(product_type) from prd_product p where p.id = n.product_id) as product_type 
  from prd_contract n
 where n.inst_id in (select inst_id from acm_cu_inst_vw)
 and n.agent_id in (select agent_id from acm_cu_agent_vw)
/
