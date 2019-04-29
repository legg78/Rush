create table asc_scenario_selection(
    id             number(8) not null
  , scenario_id    number(4)
  , mod_id         number(4)
  , oper_type      varchar2(8)
  , is_reversal    number(1)
  , sttl_type      varchar2(8)
  , priority       number(4)
  , msg_type       varchar2(8)
)
/

comment on table asc_scenario_selection is 'Selection modifier for the scenario.'
/

comment on column asc_scenario_selection.id is 'Primary key.'
/
comment on column asc_scenario_selection.scenario_id is 'Reference to scenario.'
/
comment on column asc_scenario_selection.mod_id is 'Reference to modifiers.'
/
comment on column asc_scenario_selection.oper_type is 'Operation type.'
/
comment on column asc_scenario_selection.is_reversal is 'Reversal flag.'
/
comment on column asc_scenario_selection.sttl_type is 'Settlement type (STTT key).'
/
comment on column asc_scenario_selection.priority is 'Scenario priority.'
/
comment on column asc_scenario_selection.msg_type is 'Message type.'
/
alter table asc_scenario_selection add (
    terminal_type       varchar2(8)
    , oper_reason       varchar2(8)
)
/
comment on column asc_scenario_selection.terminal_type is 'Terminal type (TRMT dictionary)'
/
comment on column asc_scenario_selection.oper_reason is 'Operation reason (fee type or adjustment type)'
/
