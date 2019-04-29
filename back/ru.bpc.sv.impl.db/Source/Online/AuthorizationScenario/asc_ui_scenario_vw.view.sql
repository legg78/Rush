create or replace force view asc_ui_scenario_vw as 
select
    a.id
  , a.seqnum
  , get_text('asc_scenario', 'name', a.id, b.lang) name
  , get_text('asc_scenario', 'description', a.id, b.lang) description
  , b.lang
from
    asc_scenario_vw a
  , com_language_vw b
where
    a.id != 0
/

