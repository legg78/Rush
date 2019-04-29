insert into adt_entity (entity_type, table_name, is_active) values ('ENTTREPT', 'RPT_REPORT', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0119', 'RPT_BANNER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0120', 'RPT_PARAMETER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0121', 'RPT_RUN', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0122', 'RPT_TAG', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0123', 'RPT_TEMPLATE', 0)
/
delete from adt_entity where entity_type = 'ENTT0121'
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTDCMT', 'RPT_DOCUMENT', 1)
/
