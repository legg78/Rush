insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (-5025, 1, 'CST_BOF_ISSUING_NETWORK_IDENTIFIER', 0, NULL, 'ENTTNETW', 'DTTPNMBR', 1001, NULL, NULL)
/
insert into com_array_type (id, seqnum, name, is_unique, lov_id, entity_type, data_type, inst_id, scale_type, class_name) values (-5024, 1, 'CST_BOF_GIM_PAYMENT_PRODUCT_INDEX', 0, NULL, 'ENTTNETW', 'DTTPNMBR', 1001, NULL, NULL)
/
update com_array_type set inst_id = 9999 where id = -5024
/
update com_array_type set inst_id = 9999 where id = -5025
/
