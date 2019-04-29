insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (1, 1, 'SYSTEM_LOVS', 1, null, '', 'DTTPNMBR', 9999)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (3, 1, 'CURRENCY_LIST', 1, 25, NULL, 'DTTPCHAR', 9999)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (11, 1, 'ISO_LANGUAGES', 1, NULL, 'ENTTUNDF', 'DTTPCHAR', 9999)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (13, 1, 'ATM_ENCODINGS', 1, 330, 'ENTTATME', 'DTTPCHAR', 9999)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (15, 2, 'ERROR_CODE_CONVERSION', 1, NULL, 'ENTTINST', 'DTTPCHAR', 9999)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (1007, 3, 'ATM_GROUPING', 0, NULL, 'ENTTTRMN', 'DTTPCHAR', 9999)
/
update com_array_type set data_type = 'DTTPNMBR' where id = 1007
/

insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1034, 1, 'ROLE', 0, 1040, 'ENTTROLE', 'DTTPNMBR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1038, 1, 'APPLICATION_STATUS', 0, 7, 'ENTT0026', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1040, 1, 'FE_OPER_TYPE', 1, NULL, 'ENTTUNDF', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1048, 1, 'ENTITY_TYPES', 0, 1017, 'ENTTUNDF', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1049, 1, 'BUNCH_TYPES', 1, NULL, 'ENTT0045', 'DTTPNMBR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1050, 1, 'MACROS_TYPES', 1, NULL, 'ENTT0045', 'DTTPNMBR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1062, 1, 'DELIVERY_STATEMENT_METHOD', 0, NULL, 'ENTT0044', 'DTTPCHAR', 9999, NULL, NULL)
/

insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1076, 1, 'FEE_TYPES', 1, 697, 'ENTTFETP', 'DTTPCHAR', 9999, NULL, NULL)
/
