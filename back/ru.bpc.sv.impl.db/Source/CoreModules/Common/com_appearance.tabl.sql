create table com_appearance (
    id               number(4)
    , seqnum         number(4)
    , entity_type    varchar2(8)
    , object_id      number(16)
    , css_class      varchar2(200)
)
/

comment on table com_appearance is 'Appearance object.'
/
comment on column com_appearance.id is 'Primary key.'
/
comment on column com_appearance.seqnum is 'Sequence number. Describe data version.'
/
comment on column com_appearance.entity_type is 'Business-entity type.'
/
comment on column com_appearance.object_id is 'Reference to object.'
/
comment on column com_appearance.css_class is '‘SS class.'
/

alter table com_appearance add (object_reference varchar2(200))
/
comment on column com_appearance.object_reference is 'Char reference to some object'
/
comment on column com_appearance.css_class is 'CSS class.'
/