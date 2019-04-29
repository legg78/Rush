create or replace force view adr_place_vw as
select 
    id
  , parent_id
  , place_code
  , place_name
  , comp_id
  , comp_level
  , postal_code
  , region_code
  , substr(place_code, 1, 2) region
  , substr(place_code, 3, 3) district
  , substr(place_code, 6, 3) city
  , substr(place_code, 9, 3) settlement
  , case when comp_level > 4 then substr(place_code,12, 4) end street
  , case when comp_level > 5 then substr(place_code,16, 4) end dom
  , case when comp_level <= 4 then substr(place_code, 12,2)  
         when comp_level = 5 then   substr(place_code, 16,2)
    end as status   
  , lang
from adr_place
/