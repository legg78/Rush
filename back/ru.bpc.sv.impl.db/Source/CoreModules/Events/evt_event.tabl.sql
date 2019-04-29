create table evt_event
(
    id                  number(4)
  , seqnum              number(4)
  , event_type          varchar2(8)
  , scale_id            number(4)
  , is_cached           number(1)
  , inst_id             number(4)
)
/

comment on table evt_event is 'Events raising in the system for exact institution.'
/

comment on column evt_event.id is 'Primary key.'
/

comment on column evt_event.seqnum is 'Data version number.'
/

comment on column evt_event.event_type is 'Event type code.'
/

comment on column evt_event.scale_id is 'Modifier scale which define subscription parametrization.'
/

comment on column evt_event.is_cached is 'Cached (delayed) rule set execution.'
/

comment on column evt_event.inst_id is 'Institution identifier.'
/
comment on column evt_event.is_cached is 'Absolete (Not used).'
/
