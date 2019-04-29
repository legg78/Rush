insert into adt_entity (entity_type, table_name, is_active) values ('ENTTOPPT', 'OPR_RULE_SELECTION', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0095', 'OPR_CHECK', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0096', 'OPR_ENTITY_OPER_TYPE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTOPPR', 'OPR_PARTICIPANT', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTOPER', 'OPR_OPERATION', 1)
/
update adt_entity set is_active = -1 where entity_type = 'ENTTOPER'
/
update adt_entity set is_active = -1 where entity_type = 'ENTTOPPR'
/
