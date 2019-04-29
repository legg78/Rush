create or replace force view prd_ui_customers_vw as
select o.id
     , o.customer_number
     , o.inst_id
     , o.seqnum
     , o.split_hash
     , o.entity_type
     , o.object_id
     , o.contract_id
     , o.card_count
     , o.contract_count
     , o.account_count
     , o.service_count
     , o.document_count
     , o.limit_count
     , o.cycle_count
     , o.payment_order_count
     , o.iss_product
     , o.acq_product
     , null salary_contract
     , o.category
     , o.relation
     , n.contract_number
     , n.product_id
     , n.product_type
     , n.start_date contract_start_date
     , n.end_date contract_end_date
     , i.name as inst_name
     , i.lang inst_lang
     , p.id as pers_id
     , p.seqnum as pers_seqnum
     , p.lang as pers_lang
     , p.first_name as pers_first_name
     , p.second_name as pers_second_name
     , p.surname as pers_surname
     , p.title as pers_title
     , p.suffix as pers_suffix
     , p.gender as pers_gender
     , p.birthday as pers_birthday
     , p.place_of_birth as pers_place_of_birth
     , null as comp_id
     , null as comp_seqnum
     , null as comp_lang
     , null as comp_split_hash
     , null as comp_embossed_name
     , null as comp_label
     , null as comp_description
     , p.doc_id
     , p.id_type
     , p.id_series
     , p.id_number
     , o.ext_entity_type
     , o.ext_object_id
     , get_object_desc(o.ext_entity_type, o.ext_object_id, i.lang) ext_object_desc
     , o.status
     , o.resident
     , o.nationality
     , o.credit_rating
     , o.money_laundry_risk
     , o.money_laundry_reason
     , o.last_modify_date
     , o.last_modify_user
     , o.reg_date
     , o.employment_status
     , o.employment_period
     , o.residence_type
     , o.marital_status
     , o.marital_status_date
     , o.income_range
     , o.number_of_children
     , r.referral_code
     , r.id as referrer_id
  from prd_ui_customer_object_vw o
     , com_ui_person_info_vw p
     , prd_ui_contract_vw n
     , ost_ui_institution_sys_vw i
     , prd_ui_referrer_vw r
 where o.entity_type = 'ENTTPERS'
   and p.id(+)       = o.object_id
   and o.contract_id = n.id
   and i.id          = o.inst_id
   and o.id          = r.customer_id (+)
union all
select o.id
     , o.customer_number
     , o.inst_id
     , o.seqnum
     , o.split_hash
     , o.entity_type
     , o.object_id
     , o.contract_id
     , o.card_count
     , o.contract_count
     , o.account_count
     , o.service_count
     , o.document_count
     , o.limit_count
     , o.cycle_count
     , o.payment_order_count
     , o.iss_product
     , o.acq_product
     , null salary_contract
     , o.category
     , o.relation
     , n.contract_number
     , n.product_id
     , n.product_type
     , n.start_date contract_start_date
     , n.end_date contract_end_date
     , i.name as inst_name
     , i.lang inst_lang
     , null as pers_id
     , null as pers_seqnum
     , null as pers_lang
     , null as pers_first_name
     , null as pers_second_name
     , null as pers_surname
     , null as pers_title
     , null as pers_suffix
     , null as pers_gender
     , null as pers_birthday
     , null as pers_place_of_birth
     , m.id as comp_id
     , m.seqnum as comp_seqnum
     , m.lang as comp_lang
     , cast(null as number(4)) as comp_split_hash
     , m.embossed_name as comp_embossed_name
     , m.label as comp_label
     , m.description as comp_description
     , m.doc_id
     , m.id_type
     , m.id_series
     , m.id_number
     , o.ext_entity_type
     , o.ext_object_id
     , get_object_desc(o.ext_entity_type, o.ext_object_id, i.lang) ext_object_desc
     , o.status
     , o.resident
     , o.nationality
     , o.credit_rating
     , o.money_laundry_risk
     , o.money_laundry_reason
     , o.last_modify_date
     , o.last_modify_user
     , o.reg_date
     , o.employment_status
     , o.employment_period
     , o.residence_type
     , o.marital_status
     , o.marital_status_date
     , o.income_range
     , o.number_of_children
     , null as referral_code
     , null as referrer_id
  from prd_ui_customer_object_vw o
     , com_ui_company_info_vw m
     , prd_ui_contract_vw n
     , ost_ui_institution_sys_vw i
 where o.entity_type = 'ENTTCOMP'
   and m.id(+)       = o.object_id
   and o.contract_id = n.id
   and i.id          = o.inst_id
union all
select o.id
     , o.customer_number
     , o.inst_id
     , o.seqnum
     , o.split_hash
     , o.entity_type
     , o.object_id
     , o.contract_id
     , o.card_count
     , o.contract_count
     , o.account_count
     , o.service_count
     , o.document_count
     , o.limit_count
     , o.cycle_count
     , o.payment_order_count
     , o.iss_product
     , o.acq_product
     , null salary_contract
     , o.category
     , o.relation
     , n.contract_number
     , n.product_id
     , n.product_type
     , n.start_date contract_start_date
     , n.end_date contract_end_date
     , i.name as inst_name
     , i.lang inst_lang
     , null as pers_id
     , null as pers_seqnum
     , null as pers_lang
     , null as pers_first_name
     , null as pers_second_name
     , null as pers_surname
     , null as pers_title
     , null as pers_suffix
     , null as pers_gender
     , null as pers_birthday
     , null as pers_place_of_birth
     , null as comp_id
     , null as comp_seqnum
     , null as comp_lang
     , null as comp_split_hash
     , null as comp_embossed_name
     , null as comp_label
     , null as comp_description
     , null as doc_id
     , null as id_type
     , null as id_series
     , null as id_number
     , o.ext_entity_type
     , o.ext_object_id
     , get_object_desc(o.ext_entity_type, o.ext_object_id, i.lang) ext_object_desc
     , o.status
     , o.resident
     , o.nationality
     , o.credit_rating
     , o.money_laundry_risk
     , o.money_laundry_reason
     , o.last_modify_date
     , o.last_modify_user
     , o.reg_date
     , o.employment_status
     , o.employment_period
     , o.residence_type
     , o.marital_status
     , o.marital_status_date
     , o.income_range
     , o.number_of_children
     , null as referral_code
     , null as referrer_id
  from prd_ui_customer_object_vw o
     , prd_ui_contract_vw n
     , ost_ui_institution_sys_vw i
 where o.entity_type = 'ENTTUNDF'
   and o.contract_id = n.id
   and i.id          = o.inst_id
/
