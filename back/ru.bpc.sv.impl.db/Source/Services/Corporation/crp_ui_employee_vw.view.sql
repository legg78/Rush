create or replace force view crp_ui_employee_vw as
select n.id
     , n.seqnum
     , n.corp_company_id
     , n.corp_customer_id
     , n.corp_contract_id
     , n.dep_id
     , n.entity_type
     , n.object_id
     , n.contract_id
     , n.account_id
     , n.inst_id
     , get_object_desc(i_entity_type => n.entity_type, i_object_id => n.object_id) employee_name
     , a.account_number
     , c.contract_number
  from crp_employee n
     , acc_account a
     , prd_contract c
 where n.inst_id in (select inst_id from acm_cu_inst_vw)
   and n.account_id = a.id(+)
   and n.contract_id = c.id
/
