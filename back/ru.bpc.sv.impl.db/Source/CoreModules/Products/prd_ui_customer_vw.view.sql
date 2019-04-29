create or replace force view prd_ui_customer_vw as
select n.id
     , n.seqnum
     , n.entity_type
     , n.object_id
     , n.customer_number
     , n.contract_id
     , n.inst_id
     , n.split_hash
     , n.category
     , n.relation
     , n.resident
     , n.nationality
     , n.credit_rating
     , n.money_laundry_risk
     , n.money_laundry_reason
     , n.last_modify_date
     , n.last_modify_user
     , n.status
     , ext_entity_type
     , ext_object_id
     , reg_date
     , employment_status
     , employment_period
     , residence_type
     , marital_status
     , marital_status_date
     , income_range
     , number_of_children
  from prd_customer  n
 where n.inst_id in (select inst_id from acm_cu_inst_vw)
/
