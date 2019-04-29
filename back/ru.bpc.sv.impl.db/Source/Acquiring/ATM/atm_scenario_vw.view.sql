create or replace force view atm_scenario_vw as
select id
     , luno
     , atm_type
     , config_id
  from atm_scenario
/