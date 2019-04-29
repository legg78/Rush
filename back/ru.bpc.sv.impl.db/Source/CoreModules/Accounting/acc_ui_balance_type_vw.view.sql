create or replace force view acc_ui_balance_type_vw as
select
    id
    , seqnum
    , account_type
    , balance_type
    , inst_id
    , currency
    , rate_type
    , aval_impact
    , status
    , number_format_id
    , number_prefix
    , update_macros_type
    , balance_algorithm    
from acc_balance_type
/
