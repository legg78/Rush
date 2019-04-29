insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0089', 'NTF_CHANNEL', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0090', 'NTF_MESSAGE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0091', 'NTF_NOTIFICATION', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0093', 'NTF_SCHEME', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0092', 'NTF_SCHEME_EVENT', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0094', 'NTF_TEMPLATE', 0)
/
update adt_entity set is_active = -1 where entity_type = 'ENTT0090'
/
