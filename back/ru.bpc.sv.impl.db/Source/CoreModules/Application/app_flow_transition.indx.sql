create index app_flow_transition_id_ndx on app_flow_transition (transition_stage_id)
/
create unique index app_flow_transition_uk on app_flow_transition(stage_id, transition_stage_id, reason_code)
/
