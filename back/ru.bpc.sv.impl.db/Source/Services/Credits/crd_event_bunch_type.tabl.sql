create table crd_event_bunch_type
(
    id            number(4)
  , seqnum        number(4)
  , event_type    varchar2(8)
  , balance_type  varchar2(8)
  , bunch_type_id number(4)
  , inst_id       number(4)
)
/

comment on table crd_event_bunch_type is 'Entry sets using in processing credits. Financial rules.'
/

comment on column crd_event_bunch_type.id is 'Primary key.'
/

comment on column crd_event_bunch_type.seqnum is 'Sequence number. Describe data version.'
/

comment on column crd_event_bunch_type.event_type is 'Event type raising funds flow.'
/

comment on column crd_event_bunch_type.balance_type is 'Balance type.'
/

comment on column crd_event_bunch_type.bunch_type_id is 'Bunch type identifier.'
/

comment on column crd_event_bunch_type.inst_id is 'Institution identifier.'
/

alter table crd_event_bunch_type add (add_bunch_type_id number(4))
/

comment on column crd_event_bunch_type.add_bunch_type_id is 'Additional bunch type identifier.'
/
