create or replace force view com_ui_rate_vw as
select
    id
    , seqnum
    , inst_id
    , eff_date
    , reg_date
    , rate_type
    , src_scale
    , src_currency
    , dst_scale
    , dst_currency
    , status
    , exp_date
    , inverted
    , rate
    , eff_rate
    , initiate_rate_id
from com_rate
/