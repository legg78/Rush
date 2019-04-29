create or replace force view rpt_run_parameter_vw as
select
    id
  , run_id
  , param_id
  , param_value
from rpt_run_parameter
/