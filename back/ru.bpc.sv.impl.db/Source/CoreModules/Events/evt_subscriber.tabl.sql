create table evt_subscriber
(
    id                  number(4)
  , seqnum              number(4)
  , procedure_name      varchar2(200)
  , event_type          varchar2(8)
  , priority            number(4)
)
/

comment on table evt_subscriber is 'Processes subscribed on events to process objects linked with event.'
/

comment on column evt_subscriber.id is 'Primary key.'
/

comment on column evt_subscriber.seqnum is 'Data version number.'
/

comment on column evt_subscriber.procedure_name is 'Subscriber procedure name.'
/

comment on column evt_subscriber.event_type is 'Reference to event.'
/

comment on column evt_subscriber.priority is 'Event processing priority when subscriber process a few events.'
/