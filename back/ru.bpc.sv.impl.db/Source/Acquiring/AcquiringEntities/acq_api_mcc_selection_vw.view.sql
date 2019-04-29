create or replace force view acq_api_mcc_selection_vw as
select
    a.id
    , a.oper_type
    , a.priority
    , a.mcc
    , a.mcc_template_id
    , t.seqnum mcc_template_seqnum
    , a.purpose_id
    , a.oper_reason
    , a.merchant_name_spec
from
    acq_mcc_selection_vw a
    , acq_mcc_selection_tpl_vw t
where
    t.id = a.mcc_template_id
/
