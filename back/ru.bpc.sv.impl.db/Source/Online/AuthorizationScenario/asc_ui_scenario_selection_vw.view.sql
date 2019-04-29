create or replace force view asc_ui_scenario_selection_vw as
select
    a.id
    , a.scenario_id
    , get_text('asc_scenario', 'name', a.scenario_id, b.lang) name
    , get_text('asc_scenario', 'description', a.scenario_id, b.lang) description
    , a.mod_id
    , a.oper_type
    , a.is_reversal
    , a.sttl_type
    , a.priority
    , a.msg_type
    , a.terminal_type
    , a.oper_reason
    , b.lang
from
    asc_scenario_selection_vw a
    , com_language_vw b
/
