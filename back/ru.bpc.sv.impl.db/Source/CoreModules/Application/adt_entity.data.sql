insert into adt_entity (entity_type, table_name, is_active) values ('ENTTAPPL', 'APP_APPLICATION', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0023', 'APP_DEPENDENCE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0024', 'APP_ELEMENT', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0026', 'APP_FLOW', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0025', 'APP_FLOW_FILTER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0027', 'APP_FLOW_STAGE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0028', 'APP_FLOW_TRANSITION', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0029', 'APP_STRUCTURE', 0)
/
insert into adt_entity (entity_type, table_name, is_active, synch_needed) values ('ENTT0133', 'APP_FLOW_STEP', 0, NULL)
/
update adt_entity set is_active = -1 where entity_type = 'ENTTAPPL'
/
