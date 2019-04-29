create table evt_status_map
(
    id                  number(4)
  , seqnum              number(4)
  , event_type          varchar2(8)
  , initiator           varchar2(8)
  , initial_status      varchar2(8)
  , result_status       varchar2(8)
)
/

comment on table evt_status_map is 'Posible status transitions.'
/

comment on column evt_status_map.id is 'Primary key'
/

comment on column evt_status_map.seqnum is 'Data version number.'
/

comment on column evt_status_map.event_type is 'Event type is used when changing status'
/

comment on column evt_status_map.initiator is 'Initiator changed card status.'
/

comment on column evt_status_map.initial_status is 'Status before changing.'
/

comment on column evt_status_map.result_status is 'Status after changing'
/
alter table evt_status_map add priority number(4)
/
comment on column evt_status_map.priority is 'Posible status priority.'
/

alter table evt_status_map add inst_id number(4)
/
comment on column evt_status_map.inst_id is 'Institution identifier.'
/
