create table com_contact (
    id              number(12)
  , seqnum          number(4)
  , preferred_lang  varchar2(8)
  , job_title       varchar2(8)
  , person_id       varchar2(12)
  , inst_id         number(4)
)
/

comment on table com_contact is 'Contact information.'
/
comment on column com_contact.id is 'Primary key.'
/
comment on column com_contact.seqnum is 'Sequence number. Describe data version.'
/
comment on column com_contact.preferred_lang is 'Perferred language of communication.'
/
comment on column com_contact.job_title is 'Contact person job title.'
/
comment on column com_contact.person_id is 'Reference to person.'
/
comment on column com_contact.inst_id is 'Owner institution identifier.'
/