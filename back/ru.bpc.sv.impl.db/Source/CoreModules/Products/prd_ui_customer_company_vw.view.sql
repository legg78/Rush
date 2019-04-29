create or replace force view prd_ui_customer_company_vw as
select c.id
     , c.customer_number
     , c.inst_id
     , c.seqnum
     , c.split_hash
     , c.entity_type
     , c.object_id
     , c.contract_id
     , c.category
     , c.relation
     , c.card_count
     , c.contract_count
     , c.account_count
     , c.service_count
     , c.document_count
     , c.limit_count
     , c.cycle_count
     , c.payment_order_count
     , c.iss_product
     , c.acq_product
     , m.id as company_id
     , m.embossed_name
     , m.incorp_form
     , m.label as company_label
     , m.description as company_description
     , m.lang
     , c.status
     , c.resident
     , c.nationality
     , c.credit_rating
     , c.money_laundry_risk
     , c.money_laundry_reason
     , c.last_modify_date
     , c.last_modify_user
     , c.ext_entity_type
     , c.ext_object_id
     , get_object_desc(c.ext_entity_type, c.ext_object_id, m.lang) as ext_object_desc
     , c.count_merchant
     , c.count_terminal
     , c.employment_status
     , c.employment_period
     , c.residence_type
     , c.marital_status
     , c.marital_status_date
     , c.income_range
     , c.number_of_children
  from prd_ui_customer_object_vw c
     , com_ui_company_vw m
 where c.entity_type = 'ENTTCOMP'
   and m.id          = c.object_id
   and c.inst_id in (select inst_id from acm_cu_inst_vw)
/
