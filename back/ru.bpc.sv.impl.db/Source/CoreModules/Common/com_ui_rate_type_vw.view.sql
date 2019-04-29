create or replace force view com_ui_rate_type_vw as
select
    t.id
    , t.seqnum
    , t.rate_type
    , t.inst_id
    , t.use_cross_rate
    , t.use_base_rate
    , t.base_currency
    , t.is_reversible
    , t.warning_level
    , t.use_double_typing
    , t.use_verification
    , t.adjust_exponent
    , t.exp_period
    , t.rounding_accuracy
from
    com_rate_type t
where
    t.inst_id in (select i.inst_id from acm_cu_inst_vw i)
/
