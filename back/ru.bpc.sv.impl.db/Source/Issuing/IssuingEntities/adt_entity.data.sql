insert into adt_entity (entity_type, table_name, is_active) values ('ENTTCOMP', 'COM_COMPANY', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTIBIN', 'ISS_BIN', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0078', 'ISS_BIN_INDEX_RANGE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0079', 'ISS_PRODUCT_CARD_TYPE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTCARD', 'ISS_CARD', 1)
/
insert into adt_entity (entity_type, table_name, is_active, synch_needed) values ('ENTTCRDH', 'ISS_CARDHOLDER', 0, NULL)
/
delete from adt_entity where entity_type = 'ENTTCARD'
/
delete from adt_entity where entity_type = 'ENTTCRDH'
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTCARD', 'ISS_CARD', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTCINS', 'ISS_CARD_INSTANCE', 0)
/
update adt_entity set is_active = -1 where entity_type = 'ENTTCARD'
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTCRDH', 'ISS_CARDHOLDER', -1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0141', 'ISS_BLACK_LIST', 0)
/
