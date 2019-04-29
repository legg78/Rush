create or replace force view atm_ui_scenario_config_vw
as
select
    a.id
  , a.atm_scenario_id
  , a.config_type
  , a.config_source
  , a.file_name
  , get_text('atm_scenario_config', 'label', a.id, b.lang) as label
  , get_text('atm_scenario_config', 'description', a.id, b.lang) as description
  , b.lang
from atm_scenario_config a
   , com_language_vw b
/

