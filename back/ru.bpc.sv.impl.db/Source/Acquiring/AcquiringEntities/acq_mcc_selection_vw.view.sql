create or replace force view acq_mcc_selection_vw as
select
    a.id
    , a.terminal_id
    , a.oper_type
    , a.priority
    , a.mcc
    , a.mcc_template_id
    , a.purpose_id
    , a.oper_reason
    , a.merchant_name_spec
from
    acq_mcc_selection a
/
