create table app_flow_transition (
    id                  number(4)
  , seqnum              number(4)
  , stage_id            number(8)
  , transition_stage_id number(8)
  , stage_result        varchar2(8)
)
/

comment on table app_flow_transition is 'Possible transitions between flow stages.'
/

comment on column app_flow_transition.id is 'Primary key.'
/
comment on column app_flow_transition.seqnum is 'Sequence number. Describe data version.'
/
comment on column app_flow_transition.stage_id is 'Stage identifier.'
/
comment on column app_flow_transition.transition_stage_id is 'Stage transition.'
/
comment on column app_flow_transition.stage_result is 'Result of processing application on current stage.'
/
alter table app_flow_transition add event_type varchar2(8)
/
comment on column app_flow_transition.event_type is 'Event type (EVNT dictionary)'
/
alter table app_flow_transition add reason_code varchar2(8)
/
comment on column app_flow_transition.reason_code is 'Reason code'
/
