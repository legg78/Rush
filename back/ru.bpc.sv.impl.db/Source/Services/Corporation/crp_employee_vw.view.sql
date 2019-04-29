create or replace force view crp_employee_vw as
select
    n.id
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
from
    crp_employee n
/
