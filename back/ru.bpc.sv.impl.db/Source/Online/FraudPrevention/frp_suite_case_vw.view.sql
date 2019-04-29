create or replace force view frp_suite_case_vw as 
select 
    suite_id
  , case_id
  , priority
from frp_suite_case
/
