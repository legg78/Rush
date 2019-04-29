create or replace force view prd_ui_customer_person_vw as
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
     , nvl(p2.title, p.title) title
     , nvl(p2.first_name, p.first_name) first_name
     , nvl(p2.second_name, p.second_name) second_name
     , nvl(p2.surname, p.surname) surname
     , nvl(p2.suffix, p.suffix) suffix
     , nvl(p2.place_of_birth, p.place_of_birth) place_of_birth
     , nvl(p2.birthday, p.birthday) birthday
     , nvl(p2.gender, p.gender) gender
     , p2.lang
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
     , c.reg_date
     , get_object_desc(c.ext_entity_type, c.ext_object_id, p2.lang) as ext_object_desc
     , c.employment_status
     , c.employment_period
     , c.residence_type
     , c.marital_status
     , c.marital_status_date
     , c.income_range
     , c.number_of_children
     , r.referral_code
     , r.id as referrer_id
  from prd_ui_customer_object_vw c
     , com_person p
     , com_person p2
     , prd_ui_referrer_vw r
 where c.entity_type = 'ENTTPERS'
   and p.id(+)       = c.object_id
   and p.lang(+)     = 'LANGENG'
   and p2.id(+)      = c.object_id
   and c.id          = r.customer_id (+)
   and c.inst_id in (select inst_id from acm_cu_inst_vw)
/
