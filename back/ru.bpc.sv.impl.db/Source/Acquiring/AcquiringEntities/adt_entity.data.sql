insert into adt_entity (entity_type, table_name, is_active) values ('ENTTBLSC', 'ACQ_ACCOUNT_SCHEME', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTRMCH', 'ACQ_REIMB_CHANNEL', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTRMMT', 'ACQ_REIMB_MACROS_TYPE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0017', 'ACQ_ACCOUNT_CUSTOMER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0018', 'ACQ_ACCOUNT_PATTERN', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0019', 'ACQ_MCC_SELECTION', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0020', 'ACQ_REIMB_BATCH', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0021', 'ACQ_REVENUE_SHARING', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTMRCH', 'ACQ_MERCHANT', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTTRMN', 'ACQ_TERMINAL', 0)
/
delete from adt_entity where entity_type = 'ENTTMRCH'
/
delete from adt_entity where entity_type = 'ENTTTRMN'
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTMRCH', 'ACQ_MERCHANT', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTTRMN', 'ACQ_TERMINAL', 0)
/
update adt_entity set is_active = -1 where entity_type = 'ENTTMRCH'
/
update adt_entity set is_active = -1 where entity_type = 'ENTTTRMN'
/
update adt_entity set is_active = -1 where entity_type = 'ENTT0020'
/
