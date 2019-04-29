alter table sec_rsa_key add constraint sec_rsa_key_pk primary key (id)
/
create unique index sec_rsa_key_uk on sec_rsa_key (key_type, key_index)
/
drop index sec_rsa_key_uk
/
create unique index sec_rsa_key_uk on sec_rsa_key (key_type, key_index, entity_type, decode(entity_type, 'ENTTATHR', object_id, null))
/
drop index sec_rsa_key_uk
/
create unique index sec_rsa_key_uk on sec_rsa_key (key_type, key_index, entity_type, decode(entity_type, 'ENTTATHR', object_id, 'ENTTFLAT', object_id, null))
/
