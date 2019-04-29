create table com_person(
    id                  number(12)
  , seqnum              number(4)
  , lang                varchar2(8)
  , title               varchar2(8)
  , first_name          varchar2(200)
  , second_name         varchar2(200)
  , surname             varchar2(200)
  , suffix              varchar2(8)
  , gender              varchar2(8)
  , birthday            date
  , place_of_birth      varchar2(200)
  , inst_id             number(4)
)
/

comment on table com_person is 'Person''s information.'
/

comment on column com_person.id is 'Primary key.'
/
comment on column com_person.seqnum is 'Sequence number. Describe data version.'
/
comment on column com_person.lang is 'Language.'
/
comment on column com_person.title is 'Person title.'
/
comment on column com_person.first_name is 'First name.'
/
comment on column com_person.second_name is 'Second name.'
/
comment on column com_person.surname is 'Surname.'
/
comment on column com_person.suffix is 'Name suffix.'
/
comment on column com_person.gender is 'Gender (Male, Female).'
/
comment on column com_person.birthday is 'Person date of birth.'
/
comment on column com_person.place_of_birth is 'Person place of birth.'
/
comment on column com_person.inst_id is 'Owner institution identifier.'
/
comment on column com_person.seqnum is 'Sequence number. Describe data version.'
/

