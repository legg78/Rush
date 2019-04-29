create table adt_entity
(
    entity_type  varchar2(8)            not null
  , table_name   varchar2(30)
  , is_active    number(1)
)
/

comment on table adt_entity is 'Business entities availabe for audit.'
/

comment on column adt_entity.entity_type is 'Entity type providing entity description.'
/

comment on column adt_entity.table_name is 'DB object name representing business entity.'
/

comment on column adt_entity.is_active is 'On/Off audit flag.'
/

alter table adt_entity add (synch_needed    number(1))
/

comment on column adt_entity.synch_needed is 'Needed synchronization with online server.'
/