create or replace force view pmo_purp_param_value_vw as
select
    a.id
  , a.purp_param_id
  , a.entity_type
  , a.object_id
  , a.param_value
from
    pmo_purp_param_value a
/
