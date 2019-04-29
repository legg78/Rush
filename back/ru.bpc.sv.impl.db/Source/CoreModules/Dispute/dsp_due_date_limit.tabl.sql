create table dsp_due_date_limit (
    id                  number(4) not null
  , seqnum              number(4)
  , standard_id         number(8)
  , message_type        varchar2(8)
  , is_incoming         number(1)
  , reason_code         varchar2(8)
  , respond_due_date    number(4)
  , resolve_due_date    number(4)
)
/
comment on table dsp_due_date_limit is 'Dispute due day limits'
/
comment on column dsp_due_date_limit.id is 'Primary key'
/
comment on column dsp_due_date_limit.seqnum is 'Sequential number'
/
comment on column dsp_due_date_limit.standard_id is 'Standard identifier'
/
comment on column dsp_due_date_limit.message_type is 'Message type'
/
comment on column dsp_due_date_limit.is_incoming is 'Incoming flag: 1 - incoming message, 0 - outgoing message'
/
comment on column dsp_due_date_limit.reason_code is 'Message reason code'
/
comment on column dsp_due_date_limit.respond_due_date is 'Number of days to respond on dispute'
/
comment on column dsp_due_date_limit.resolve_due_date is 'Number of days to resolve a dispute'
/
alter table dsp_due_date_limit add (usage_code varchar2(1))
/
comment on column dsp_due_date_limit.usage_code is 'Usage code'
/

