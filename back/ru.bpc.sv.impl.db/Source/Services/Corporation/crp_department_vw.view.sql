create or replace force view crp_department_vw as
select
    n.id
    , n.seqnum
    , n.parent_id
    , n.corp_company_id
    , n.corp_customer_id
    , n.corp_contract_id
    , n.inst_id
from
    crp_department n
/
