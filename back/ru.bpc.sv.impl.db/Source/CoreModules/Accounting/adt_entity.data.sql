insert into adt_entity (entity_type, table_name, is_active) values ('ENTTACTP', 'ACC_ACCOUNT_TYPE', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTBLTP', 'ACC_BALANCE_TYPE', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTENTS', 'ACC_BUNCH_TYPE', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTENTL', 'ACC_ENTRY_TPL', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0001', 'ACC_MACROS_TYPE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0002', 'ACC_SELECTION', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0003', 'ACC_SELECTION_PRIORITY', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTACCT', 'ACC_ACCOUNT', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTENTR', 'ACC_ENTRY', 0)
/
delete from adt_entity where entity_type = 'ENTTENTR'
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0137', 'ACC_PRODUCT_ACCOUNT_TYPE', 0)
/
delete from adt_entity where entity_type = 'ENTTACCT'
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTACCT', 'ACC_ACCOUNT', 0)
/
update adt_entity set is_active = -1 where entity_type = 'ENTTACCT'
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0139', 'ACC_SCHEME', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0140', 'ACC_SCHEME_ACCOUNT', 0)
/
