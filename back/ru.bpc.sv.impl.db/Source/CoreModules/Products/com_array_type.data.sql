insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1057, 1, 'PRODUCT_NUMBER', 0, 617, 'ENTTPROD', 'DTTPCHAR', 9999, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (1070, 1, 'ATTRIBUTE_NAME', 1, 133, 'ENTTATTR', 'DTTPNMBR', 9999, NULL, NULL)
/
update com_array_type set lov_id = 667 where id = 1070
/
