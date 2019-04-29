insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0131', 'VCH_BATCH', 0)
/
insert into adt_entity (entity_type, table_name, is_active) values ('ENTT0132', 'VCH_VOUCHER', 0)
/
update adt_entity set is_active = -1 where entity_type = 'ENTT0131'
/
update adt_entity set is_active = -1 where entity_type = 'ENTT0132'
/
