alter table crd_event_bunch_type add (constraint crd_event_bunch_type_pk primary key(id))
/

alter table crd_event_bunch_type add constraint crd_event_bunch_type_uk
unique(event_type, balance_type, bunch_type_id, inst_id)
/

alter table crd_event_bunch_type drop constraint crd_event_bunch_type_uk
/

alter table crd_event_bunch_type add constraint crd_event_bunch_type_uk
unique(event_type, balance_type, inst_id)
/
