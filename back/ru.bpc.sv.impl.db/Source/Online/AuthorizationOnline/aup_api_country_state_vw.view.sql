create or replace force view aup_api_country_state_vw as
select y.code country_code
     , p.region_code
from adr_place p
   , adr_component c
   , com_country y
where p.comp_id    = c.id
  and y.id         = c.country_id
  and c.comp_level = 1
/