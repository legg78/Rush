create table atm_scenario_config
(
    id               number(4)
  , atm_scenario_id  number(4)
  , config_type      varchar2(8)
  , config_source    clob
  , file_name        varchar2(200)
)
/

comment on table atm_scenario_config is 'ATM scenario configurations.'
/

comment on column atm_scenario_config.id is 'Primary key.'
/
comment on column atm_scenario_config.atm_scenario_id is 'ATM scenario identifier.'
/
comment on column atm_scenario_config.config_type is 'Configuration type.'
/
comment on column atm_scenario_config.config_source is 'Configuration XML source.'
/
comment on column atm_scenario_config.file_name is 'File name.'
/
