insert into adt_entity (entity_type, table_name, is_active) values ('ENTTNETW', 'NET_NETWORK', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTTMEMB', 'NET_MEMBER', 1)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0081', 'NET_CARD_TYPE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0080', 'NET_CARD_TYPE_MAP', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0082', 'NET_DEVICE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0083', 'NET_INTERFACE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0084', 'NET_LOCAL_BIN_RANGE', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0085', 'NET_MSG_TYPE_MAP', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0086', 'NET_OPER_TYPE_MAP', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0087', 'NET_STTL_MAP', 0)
/
update adt_entity set entity_type = 'ENTTHOST' where table_name = 'NET_MEMBER'
/
update adt_entity set synch_needed = 1 where entity_type in ('ENTTHOST')
/
