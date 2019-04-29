alter table prd_customer add constraint prd_customer_pk primary key(id)
/
create index prd_customer_ext_entity_ndx on prd_customer (ext_entity_type, ext_object_id)
/
alter table prd_customer add constraint prd_customer_uk unique (customer_number, inst_id)
/
