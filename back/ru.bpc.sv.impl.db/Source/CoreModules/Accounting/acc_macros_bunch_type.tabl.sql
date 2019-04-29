create table acc_macros_bunch_type (
    id              number(4) not null
  , seqnum          number(4) not null
  , macros_type_id  number(4) not null
  , bunch_type_id   number(4) not null
  , inst_id         number(4) not null
)
/

comment on table acc_macros_bunch_type is 'Relationship table between macros type and bunch type'
/
comment on column acc_macros_bunch_type.id is 'Relationship identifier'
/
comment on column acc_macros_bunch_type.seqnum is 'Data version number'
/
comment on column acc_macros_bunch_type.macros_type_id is 'Macros type'
/
comment on column acc_macros_bunch_type.bunch_type_id is 'Bunch type'
/
comment on column acc_macros_bunch_type.inst_id is 'Institution identifier'
/
alter table acc_macros_bunch_type add (status varchar2(8))
/
comment on column acc_macros_bunch_type.status is 'Status of macros upon creation'
/
alter table acc_macros_bunch_type modify macros_type_id null
/
