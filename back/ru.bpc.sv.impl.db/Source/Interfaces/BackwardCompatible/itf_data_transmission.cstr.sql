alter table itf_data_transmission add constraint itf_data_transmission_pk primary key(id) using index
/
alter table itf_data_transmission add constraint itf_data_transmission_uk unique(entity_type, object_id) using index
/
