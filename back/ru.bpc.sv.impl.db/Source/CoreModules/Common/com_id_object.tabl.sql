create table com_id_object(
    id               number(12)
  , seqnum           number(4)
  , entity_type      varchar2(8)
  , object_id        number(16)
  , id_type          varchar2(8)
  , id_series        varchar2(200)
  , id_number        varchar2(200)
  , id_issuer        varchar2(200)
  , id_issue_date    date
  , id_expire_date   date
  , inst_id          number(4)
)
/

comment on table com_id_object is 'Objects  identities.'
/

comment on column com_id_object.id is 'Primary key.'
/
comment on column com_id_object.entity_type is 'Owner entity type (Person, Company).'
/
comment on column com_id_object.object_id is 'ID owner identifier'
/
comment on column com_id_object.id_type is 'Identity type (Passport, driving license etc.).'
/
comment on column com_id_object.id_series is 'Identity series.'
/
comment on column com_id_object.id_number is 'Identity number.'
/
comment on column com_id_object.id_issuer is 'Autoriry organization.'
/
comment on column com_id_object.id_issue_date is 'Issue date.'
/
comment on column com_id_object.id_expire_date is 'Expiration date.'
/
comment on column com_id_object.inst_id is 'Owner institution identifier.'
/
comment on column com_id_object.seqnum is 'Sequence number. Describe data version.'
/
alter table com_id_object add (country  varchar2(3))
/
comment on column com_id_object.country is 'ISO country code'
/
