create or replace force view prc_parameter_value_vw as
select
    a.id
  , a.container_id
  , a.param_id
  , a.param_value
from
    prc_parameter_value a
/

