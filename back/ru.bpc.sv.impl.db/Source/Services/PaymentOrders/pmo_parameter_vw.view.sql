create or replace force view pmo_parameter_vw as
select
    a.id
  , a.seqnum
  , a.param_name
  , a.data_type
  , a.lov_id
  , a.pattern
  , a.tag_id
  , a.param_function
from
    pmo_parameter a
/
