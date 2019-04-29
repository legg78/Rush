insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50000584, 10000884, 10000885, 'DPP_AUTOCONVERTATION', 'DTTPNMBR', 4, 120, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50000586, 10000884, 10000885, 'DPP_AUTOCONVERT_THRESHOLD', 'DTTPNMBR', NULL, 130, 'ENTTLIMT', 'LMTP0401', 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50000588, 10000472, 10001743, 'ISS_USAGE_HYBRID_THRESHOLD', 'DTTPNMBR', 4, 170, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50000589, 10000472, 10001743, 'ISS_HYBRID_THRESHOLD_VALUE', 'DTTPNMBR', NULL, 180, 'ENTTLIMT', 'LMTP5402', 'SADLPRDT', 1)
/
update prd_attribute set object_type = 'LMTP5401' where id = -50000586
/
delete from prd_attribute where id = -50000584
/
delete from prd_attribute where id = -50000586
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (-50000596, 10000502, 10000513, 'CST_ACC_VIRTUAL_NUMBER_FORMAT', 'DTTPNMBR', -5004, 160, NULL, NULL, 'SADLSRVC', 0)
/
