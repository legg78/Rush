create table evt_event_type
(
    id                  number(4)
  , seqnum              number(4)
  , event_type          varchar2(8)
  , entity_type         varchar2(8)
  , reason_lov_id       number(4)
)
/

comment on table evt_event_type is 'Event types.'
/

comment on column evt_event_type.id is 'Primary key.'
/

comment on column evt_event_type.seqnum is 'Data version number.'
/

comment on column evt_event_type.event_type is 'Event type code.'
/

comment on column evt_event_type.entity_type is 'Entity type code.'
/

comment on column evt_event_type.reason_lov_id is 'Object status change reson list identifier'
/