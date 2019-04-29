create or replace force view com_rate_type_vw as
select
    id
    , seqnum
    , rate_type
    , inst_id
    , use_cross_rate
    , use_base_rate
    , base_currency
    , is_reversible
    , warning_level
    , use_double_typing
    , use_verification
    , adjust_exponent
    , exp_period
    , rounding_accuracy
from
    com_rate_type
/
