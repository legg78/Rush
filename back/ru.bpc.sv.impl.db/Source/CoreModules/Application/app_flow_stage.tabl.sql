create table app_flow_stage (
    id                  number(8)
  , seqnum              number(4)
  , flow_id             number(4)
  , appl_status         varchar2(8)
  , handler             varchar2(200)
  , handler_type        varchar2(8)
)
/

comment on table app_flow_stage is 'Application flow stage.'
/

comment on column app_flow_stage.id is 'Primary key.'
/
comment on column app_flow_stage.seqnum is 'Sequence number. Describe data version.'
/
comment on column app_flow_stage.flow_id is 'Reference to flow identifier.'
/
comment on column app_flow_stage.appl_status is 'Related application status.'
/
comment on column app_flow_stage.handler is 'Application handler in current stage'
/
comment on column app_flow_stage.handler_type is 'Type of entity which will handle current stage'
/

alter table app_flow_stage add (reject_code varchar2(8))
/
comment on column app_flow_stage.reject_code is 'Reject code, dictionaries APST, APRJ'
/
alter table app_flow_stage add (role_id number(8))
/
comment on column app_flow_stage.role_id is 'Foreign key to table ACM_ROLE'
/
