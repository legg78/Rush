create table com_id_type(
    id               number(4)
  , seqnum           number(4)
  , entity_type      varchar2(8)
  , inst_id          number(4)
  , id_type          varchar2(8)
)
/

comment on table com_id_type is 'Types of used identities by institution.'
/

comment on column com_id_type.id is 'Record identifier'
/
comment on column com_id_type.seqnum is 'Sequence number. Describe data version'
/
comment on column com_id_type.entity_type is 'Owner entity type (Person, Company)'
/
comment on column com_id_type.id_type is 'Identity type (Passport, driving license etc.)'
/
comment on column com_id_type.inst_id is 'Institution identifier'
/
