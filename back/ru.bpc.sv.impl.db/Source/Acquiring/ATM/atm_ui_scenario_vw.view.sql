create or replace force view atm_ui_scenario_vw as
select
    a.id
  , a.luno
  , a.atm_type
  , a.config_id
  , get_text ('atm_scenario', 'label', a.id, b.lang) as label
  , get_text ('atm_scenario', 'description', a.id, b.lang) as description
  , sysdate    as date_begin
  , sysdate -1 as date_load
  , 1          as user_load
  , b.lang
  from atm_scenario a
     , com_language_vw b
/ 
