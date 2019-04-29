create or replace force view crp_ui_department_vw as
select
    n.id
    , n.seqnum
    , n.parent_id
    , n.corp_company_id
    , n.corp_customer_id
    , n.corp_contract_id
    , prd_api_contract_pkg.get_contract_number(n.corp_contract_id) corp_contract_number
    , n.inst_id
    , get_text (
        i_table_name    => 'crp_department'
        , i_column_name => 'label'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) label
    , l.lang
from
    crp_department n
  , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
