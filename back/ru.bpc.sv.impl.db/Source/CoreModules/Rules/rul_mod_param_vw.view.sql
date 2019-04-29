create or replace force view rul_mod_param_vw as
select 
    id
  , name
  , data_type
  , lov_id
from rul_mod_param
/