create table ost_institution
(
    id              number(4)
  , seqnum          number(4)
  , parent_id       number(4)
  , network_id      number(4)
  , inst_type       varchar2(8)
)
/

comment on table ost_institution is 'Institutions registred in the system.'
/

comment on column ost_institution.id is 'Primary key.'
/

comment on column ost_institution.seqnum is 'Sequence number. Describe data version.'
/

comment on column ost_institution.parent_id is 'Reference to parent institution.'
/

comment on column ost_institution.network_id is 'Network identifier which institution belongs to.'
/

comment on column ost_institution.network_id is 'Institution type. Describe institution purpose.'
/

comment on column ost_institution.inst_type is 'Institution type. Describe institution purpose.'
/

comment on column ost_institution.network_id is 'Network identifier which institution belongs to.'
/

alter table ost_institution add institution_number varchar2(4)
/
comment on column ost_institution.institution_number is 'Institution_number.'
/

alter table ost_institution add status varchar2(8)
/
comment on column ost_institution.status is 'Status.'
/
