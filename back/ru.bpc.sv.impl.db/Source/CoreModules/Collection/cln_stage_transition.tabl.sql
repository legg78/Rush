create table cln_stage_transition (
    id                     number(8)
  , seqnum                 number(4)
  , stage_id               number(8)
  , transition_stage_id    number(8)
  , reason_code            varchar2(8)
)
/
comment on table cln_stage_transition is 'Collection case.'
/
comment on column cln_stage_transition.id is 'Primary key.'
/
comment on column cln_stage_transition.seqnum is 'Sequence number (for data integrity)'
/
comment on column cln_stage_transition.stage_id is 'Source stage identifier'
/
comment on column cln_stage_transition.transition_stage_id is 'Destination stage identifier'
/
comment on column cln_stage_transition.reason_code is 'Reason of the transition. It is an article of dictionary EVNT, CRAT or CSRS.'
/
