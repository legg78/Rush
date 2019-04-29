create or replace force view rul_name_base_param_vw as
select 
    p.id
    , p.entity_type
    , p.name
from 
    rul_name_base_param p
/