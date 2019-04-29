create table evt_entity
(
    id                  number(4)
  , seqnum              number(4)
  , entity_type         varchar2(8)
  , status_lov_id       number(4)
)
/

comment on table evt_entity is 'Entities using statuses.'
/

comment on column evt_entity.id is 'Primary key'
/

comment on column evt_entity.seqnum is 'Data version number.'
/

comment on column evt_entity.entity_type is 'Entity type.'
/

comment on column evt_entity.status_lov_id is 'Entity statuses list identifier.'
/