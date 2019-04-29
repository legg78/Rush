create or replace force view adr_ui_component_vw as
select 
    id
  , lang
  , abbreviation
  , comp_name
  , comp_level
  , country_id
from adr_component
/