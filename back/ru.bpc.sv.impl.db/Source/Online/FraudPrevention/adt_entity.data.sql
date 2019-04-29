insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0070', 'FRP_CASE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0069', 'FRP_CASE_EVENT', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0071', 'FRP_CHECK', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0072', 'FRP_MATRIX', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0073', 'FRP_MATRIX_VALUE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0075', 'FRP_SUITE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0074', 'FRP_SUITE_CASE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0138', 'FRP_FRAUD', 0)
/
update adt_entity set is_active = -1 where entity_type = 'ENTT0138'
/
