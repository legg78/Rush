insert into adt_entity (entity_type, table_name, is_active) values ('ENTTPMNO', 'PMO_ORDER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0098', 'PMO_PARAMETER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0100', 'PMO_PROVIDER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0099', 'PMO_PROVIDER_HOST', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0103', 'PMO_PURPOSE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0101', 'PMO_PURPOSE_FORMATTER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0102', 'PMO_PURPOSE_PARAMETER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0104', 'PMO_SCHEDULE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0105', 'PMO_SERVICE', 0)
/
update adt_entity set is_active = -1 where entity_type = 'ENTTPMNO'
/
update adt_entity set is_active = -1 where entity_type = 'ENTT0104'
/
