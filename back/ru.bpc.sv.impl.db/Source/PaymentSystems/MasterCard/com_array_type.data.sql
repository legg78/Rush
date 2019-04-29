insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id) values (16, 1, 'ACCOUNT_STATUS', 0, 27, 'ENTTACCT', 'DTTPCHAR', 9999)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1045, 1, 'CSTS', 0, NULL, 'ENTT0001', 'DTTPCHAR', 9999, NULL, NULL)
/
update com_array_type set lov_id = 1003, entity_type = 'ENTTUNDF' where id = 1045
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1058, 1, 'MC_LOADED_DICTIONARY_LIST', 0, NULL, 'ENTTUNDF', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1078, 1, 'GLIBC_LANGUAGE_FORMAT', 1, NULL, 'ENTTUNDF', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1079, 1, 'MCW_FILE_EXPRESS_ACCOUNT_CODE', 1, NULL, 'ENTTUNDF', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1081, 1, 'MC_FEE_CLAIM_REASON_CODE', 0, NULL, 'ENTTUNDF', 'DTTPCHAR', 9999, NULL, NULL)
/
