create table app_flow_step
(
    id              number(4)
  , seqnum          number(4)
  , flow_id         number(4)
  , appl_status     varchar2(8)
  , step_source     varchar2(200)
  , read_only       number(1)
  , display_order   number(4)
)
/

comment on table app_flow_step is 'Steps to reproduce wizard form.'
/

comment on column app_flow_step.id is 'Primary key'
/

comment on column app_flow_step.seqnum is 'Sequence number. Describe data version.'
/

comment on column app_flow_step.flow_id is 'Reference to application flow.'
/

comment on column app_flow_step.appl_status is 'Application status '
/

comment on column app_flow_step.step_source is 'Source for step visual form.'
/

comment on column app_flow_step.read_only is 'Read only flag (1 - Yes, 0 - No)'
/

comment on column app_flow_step.display_order is 'Order to show step in wizard form.'
/
