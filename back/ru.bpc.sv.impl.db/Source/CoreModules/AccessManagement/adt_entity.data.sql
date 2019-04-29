insert into adt_entity (entity_type, table_name, is_active) values ('ENTTROLE', 'ACM_ROLE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTUSER', 'ACM_USER', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0005', 'ACM_ACTION', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0004', 'ACM_ACTION_GROUP', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0006', 'ACM_ACTION_VALUE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0007', 'ACM_COMPONENT_STATE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0008', 'ACM_DASHBOARD', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0009', 'ACM_FAVORITE_PAGE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0011', 'ACM_FILTER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0010', 'ACM_FILTER_COMPONENT', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0012', 'ACM_PRIVILEGE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0014', 'ACM_SECTION', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0013', 'ACM_SECTION_PARAMETER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0016', 'ACM_WIDGET', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0015', 'ACM_WIDGET_PARAM', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTATME','ATM_SCENARIO_ENCODING',0)
/
delete adt_entity where entity_type = 'ENTT0145'
/
insert into adt_entity (entity_type, table_name, is_active, synch_needed) values ('ENTT0145', 'ACM_USER_ROLE', 0, NULL)
/
delete adt_entity where entity_type = 'ENTT0146'
/
insert into adt_entity (entity_type, table_name, is_active, synch_needed) values ('ENTT0146', 'ACM_USER_INST', 0, NULL)
/
delete adt_entity where entity_type = 'ENTT0147'
/
insert into adt_entity (entity_type, table_name, is_active, synch_needed) values ('ENTT0147', 'ACM_USER_AGENT', 0, NULL)
/
delete adt_entity where entity_type = 'ENTT0148'
/
insert into adt_entity (entity_type, table_name, is_active, synch_needed) values ('ENTT0148', 'ACM_ROLE_PRIVILEGE', 0, NULL)
/
update adt_entity set is_active = 1 where table_name = 'ACM_ROLE'
/

