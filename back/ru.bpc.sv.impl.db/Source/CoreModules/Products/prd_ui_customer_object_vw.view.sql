create or replace force view prd_ui_customer_object_vw as
select id
  , seqnum
  , entity_type
  , object_id
  , customer_number
  , contract_id
  , inst_id
  , split_hash
  , category
  , relation
  , status
  , resident
  , nationality
  , credit_rating
  , money_laundry_risk
  , money_laundry_reason
  , last_modify_date
  , last_modify_user
  , ext_entity_type
  , ext_object_id
  , reg_date
  , (select count(1) from iss_card x                 where x.customer_id = c.id) card_count
  , (select count(1) from prd_contract x             where x.customer_id = c.id) contract_count
  , (select count(1) from acc_account x              where x.customer_id = c.id) account_count
  , (select count(1) from prd_service_object x       where x.entity_type = 'ENTTCUST' and x.object_id = c.id) service_count
  , (select count(1) from com_id_object x            where x.entity_type = c.entity_type and x.object_id = c.object_id) document_count
  , (select count(1) from fcl_limit_counter x        where x.entity_type = 'ENTTCUST' and x.object_id = c.id) limit_count
  , (select count(1) from fcl_cycle_counter x        where x.entity_type = 'ENTTCUST' and x.object_id = c.id) cycle_count
  , (select count(1) from pmo_order x, pmo_purpose p where x.customer_id = c.id and x.purpose_id = p.id and x.is_template = 0) payment_order_count
--  , (select count(1) from prd_contract a       where a.customer_id = c.id and a.contract_type = 'CNTPSLPR') salary_contract
  , (select count(1) from prd_contract b, prd_product p where c.id = b.customer_id and b.product_id = p.id and p.product_type = 'PRDT0100') iss_product
  , (select count(1) from prd_contract b, prd_product p where c.id = b.customer_id and b.product_id = p.id and p.product_type = 'PRDT0200') acq_product
  , (select count(x.id) from acq_merchant x, prd_contract t where x.contract_id = t.id and t.customer_id = c.id) count_merchant
  , (select count(t1.id) from acq_terminal t1, prd_contract r1 where r1.id = t1.contract_id and c.id = r1.customer_id) count_terminal
  , employment_status
  , employment_period
  , residence_type
  , marital_status
  , marital_status_date
  , income_range
  , number_of_children
  , prd_api_customer_pkg.get_customer_aging(i_customer_id => c.id) as max_aging_period
from prd_customer c
/
