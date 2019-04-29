insert into adt_entity (entity_type, table_name, is_active) values ('ENTTCMPN', 'CPN_CAMPAIGN', 1)
/
update adt_entity set is_active = 0 where entity_type = 'ENTTCMPN'
/
