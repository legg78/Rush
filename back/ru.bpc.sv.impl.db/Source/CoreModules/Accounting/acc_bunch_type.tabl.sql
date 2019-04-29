create table acc_bunch_type (
    id              number(4) not null
    , seqnum        number(4) not null
)
/
comment on table acc_bunch_type is 'Type of entries bunch'
/
comment on column acc_bunch_type.id is 'Bunch type identifier'
/
comment on column acc_bunch_type.seqnum is 'Data version number'
/
alter table acc_bunch_type add (inst_id number(4))
/
comment on column acc_bunch_type.inst_id is 'Institution identifier'
/
