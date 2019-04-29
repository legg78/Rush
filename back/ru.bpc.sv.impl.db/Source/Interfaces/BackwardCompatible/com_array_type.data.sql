insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1014, 1, 'CARD_TYPES', 0, NULL, 'ENTT0080', 'DTTPNMBR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1015, 1, 'CG_CARD_TYPES', 0, NULL, 'ENTT0080', 'DTTPCHAR', 9999, NULL, NULL)
/
update com_array_type set name = 'BLANK_TYPES', entity_type ='ENTT0114' where id = 1014
/
update com_array_type set name = 'CG_BLANK_TYPES', entity_type ='ENTT0114' where id = 1015
/
delete from com_array_type where id in (1014, 1015)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1044, 1, 'FRAUD_MONITORING_VERSION', 1, NULL, 'ENTT0044', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1072, 1, 'CBS_ACCOUNT_TYPES', 1, 1014, 'ENTTACTP', 'DTTPCHAR', 9999, NULL, NULL)
/
