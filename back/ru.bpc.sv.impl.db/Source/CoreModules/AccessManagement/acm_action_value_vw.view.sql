create or replace force view acm_action_value_vw as
select a.id
     , a.action_id
     , a.param_id
     , a.param_value
     , a.param_function
from acm_action_value a
/
