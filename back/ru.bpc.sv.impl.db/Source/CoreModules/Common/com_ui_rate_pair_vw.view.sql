create or replace force view com_ui_rate_pair_vw as
select
    id
    , seqnum
    , rate_type
    , inst_id
    , src_currency
    , dst_currency
    , base_rate_type
    , base_rate_formula
    , input_mode
    , src_scale
    , dst_scale
    , inverted
    , rate_example
    , display_order
    , com_api_i18n_pkg.get_text('COM_RATE_PAIR', 'LABEL', id) as label
from
    com_rate_pair
/