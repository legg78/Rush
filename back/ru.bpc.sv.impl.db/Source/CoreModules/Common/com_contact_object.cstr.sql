alter table com_contact_object add (constraint com_contact_object_pk primary key(id))
/

alter table com_contact_object 
add constraint com_contact_object_uk 
unique(object_id, entity_type, contact_type)
/