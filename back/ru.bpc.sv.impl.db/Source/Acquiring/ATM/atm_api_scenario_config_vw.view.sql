create or replace force view atm_api_scenario_config_vw as
select c.id
     , c.atm_scenario_id
     , c.config_type
     , c.config_source
     , s.atm_type
     , s.luno
     , s.config_id
     , c.file_name
  from atm_scenario s
     , atm_scenario_config c
 where s.id = c.atm_scenario_id
/
