create or replace force view atm_scenario_config_vw as
select 
    id
  , atm_scenario_id
  , config_type
  , config_source
  , file_name
from atm_scenario_config
/

