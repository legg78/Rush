create or replace force view prc_parameter_vw as
select
    a.id
  , a.param_name
  , a.data_type
  , a.lov_id
  , a.parent_id
from prc_parameter a
/
