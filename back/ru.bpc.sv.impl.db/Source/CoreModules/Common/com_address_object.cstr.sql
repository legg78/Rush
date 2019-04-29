alter table com_address_object add (constraint com_address_object_pk primary key(id))
/

alter table com_address_object add (constraint com_address_object_uk unique (object_id, entity_type, address_type))
/
