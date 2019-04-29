create or replace force view com_module_vw (
    id
  , name
  , module_code
  , dict_code
) as 
select
    id
  , name
  , module_code
  , dict_code
from com_module
/ 