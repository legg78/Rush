insert into adt_entity (entity_type, table_name, is_active) values ('ENTTSDPR', 'CMN_PARAMETER', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTSTDR', 'CMN_STANDARD', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTCMDV', 'CMN_DEVICE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTTCIP', 'CMN_TCP_IP', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0038', 'CMN_KEY_TYPE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0039', 'CMN_RESP_CODE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0040', 'CMN_STANDARD_OBJECT', 0)
/
update adt_entity set synch_needed = 1 where entity_type in ('ENTTCMDV')
/
