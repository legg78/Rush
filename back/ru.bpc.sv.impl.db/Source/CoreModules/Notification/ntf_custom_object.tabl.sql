create table ntf_custom_object (
    id                 number(16)
    , custom_event_id  number(12)
    , object_id        number(16)
    , is_active        number(1)
)
/
comment on table ntf_custom_object is 'List of objects about which customer can be notified.'
/
comment on column ntf_custom_object.id is 'Primary key.'
/
comment on column ntf_custom_object.custom_event_id is 'Reference to custom event.'
/
comment on column ntf_custom_object.object_id is 'Object identifier. '
/
comment on column ntf_custom_object.is_active is 'Activation flag. if flag is not active then for current object notification will not be created.'
/
alter table ntf_custom_object add entity_type varchar2(8)
/
comment on column ntf_custom_object.entity_type is 'Type of underlying entity.'
/
comment on column ntf_custom_object.object_id is 'Object identifier (not related to entity_type).'
/
comment on column ntf_custom_object.entity_type is 'Type of underlying entity (not related to object_id).'
/

