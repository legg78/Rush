insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10000541, 10000540, NULL, 'NOTIFICATION_SCHEME', 'DTTPNMBR', 132, 10, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002001, 10002000, NULL, 'SERVICE_NOTIFICATION_FEE', 'DTTPNMBR', NULL, 10, 'ENTTFEES', 'FETP5001', 'SADLPRDT', 0)
/
update prd_attribute set attr_name = 'NOTIFICATION_SERVICE_USE_FEE', object_type = 'FETP0118', is_visible = 1 where id = 10002001
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002005, 10000540, NULL, 'CONNECTION_NOTIFICATION_FEE', 'DTTPNMBR', NULL, 11, 'ENTTFEES', 'FETP0901', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002013, 10000540, NULL, 'SERVICE_NOTIFICATION_FEE', 'DTTPNMBR', NULL, 12, 'ENTTFEES', 'FETP0902', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002016, 10002000, NULL, 'NOTIFICATION_CONNECTION_CARD_FEE', 'DTTPNMBR', NULL, 11, 'ENTTFEES', 'FETP0121', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002231, 10002228, NULL, 'ACQ_NOTIFICATION_SCHEME', 'DTTPNMBR', 132, 12, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002232, 10002228, NULL, 'ACQ_CONNECTION_NOTIFICATION_FEE', 'DTTPNMBR', NULL, 14, 'ENTTFEES', 'FETP0903', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002233, 10002228, NULL, 'ACQ_SERVICE_NOTIFICATION_FEE', 'DTTPNMBR', NULL, 15, 'ENTTFEES', 'FETP0904', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10003614, 10000540, NULL, 'PROMOTIONAL_MESSAGE', 'DTTPCHAR', NULL, 13, NULL, NULL, 'SADLPRDT', 0)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10004047, 10000403, 10000380, 'CRD_POSTERIOR_MESSAGE_CYCLE', 'DTTPNMBR', NULL, 130, 'ENTTCYCL', 'CYTP0417', 'SADLPRDT', 1)
/
update prd_attribute set object_type = 'CYTP1417' where id = 10004047
/
update prd_attribute set object_type = 'CYTP1017' where id = 10004047
/
