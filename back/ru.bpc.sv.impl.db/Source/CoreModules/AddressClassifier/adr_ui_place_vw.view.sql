create or replace force view adr_ui_place_vw as
select p.id
     , p.parent_id
     , p.lang
     , p.place_code
     , y.code country_code
     , y.name country_name
     , c.comp_name
     , c.abbreviation
     , p.place_name
     , p.comp_level
     , p.postal_code
     , p.region_code
     , substr(place_code, 1,2) region
from adr_place p
   , adr_component c
   , com_country y
where p.comp_id = c.id
  and y.id = c.country_id
/