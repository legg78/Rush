create table com_contact_object (
    id            number(16)
  , entity_type   varchar2(8)
  , object_id     number(16)
  , contact_type  varchar2(8)
  , contact_id    number(12)
)
/

comment on table com_contact_object is 'Links contacts with business-entities.'
/
comment on column com_contact_object.id is 'Primary key.'
/
comment on column com_contact_object.entity_type is 'Business-entity type.'
/
comment on column com_contact_object.object_id is 'Reference to object.'
/
comment on column com_contact_object.contact_type is 'Contact type.'
/
comment on column com_contact_object.contact_id is 'Reference to contact.'
/


