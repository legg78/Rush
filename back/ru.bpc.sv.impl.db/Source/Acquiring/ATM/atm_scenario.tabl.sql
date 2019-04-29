create table atm_scenario (
    id        number(4)
  , luno      number(9)
  , atm_type  varchar2(8)
  , config_id varchar2(200)
)
/

comment on table atm_scenario is 'ATM scenarios.'
/

comment on column atm_scenario.id is 'Primary key.'
/

comment on column atm_scenario.luno is 'Logical unit number.'
/

comment on column atm_scenario.atm_type is 'ATM terminal type.'
/

comment on column atm_scenario.config_id is 'External identifier of configuration defined in current scenario.'
/