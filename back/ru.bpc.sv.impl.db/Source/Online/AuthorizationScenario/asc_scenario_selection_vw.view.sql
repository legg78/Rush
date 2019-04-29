create or replace force view asc_scenario_selection_vw as
select
    a.id
    , a.scenario_id
    , a.mod_id
    , a.oper_type
    , a.is_reversal
    , a.sttl_type
    , a.priority
    , a.msg_type
    , a.terminal_type
    , a.oper_reason
from
    asc_scenario_selection a
/
