create or replace force view asc_state_param_value_vw as
select
    a.state_id
    , a.param_id
    , a.param_value
from
    asc_state_param_value a
/
