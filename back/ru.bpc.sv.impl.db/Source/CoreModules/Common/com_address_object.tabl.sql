create table com_address_object
(
    id            number(16)
  , entity_type   varchar2(8)
  , object_id     number(16)
  , address_type  varchar2(8)
  , address_id    number(12)
)
/

comment on table com_address_object is 'Links addresses with business-entities.'
/

comment on column com_address_object.id is 'Primary key.'
/

comment on column com_address_object.entity_type is 'Business-entity type.'
/

comment on column com_address_object.object_id is 'Reference to object.'
/

comment on column com_address_object.address_type is 'Address type. Unique on object.'
/

comment on column com_address_object.address_id is 'Reference to address.'
/