insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002303, 10001717, NULL, '3D_SECURE_ENABLED_ONE_TIME_PASSWORD', 'DTTPNMBR', 4, 10, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002304, 10001717, NULL, '3D_SECURE_ENABLED_E_TOKEN', 'DTTPNMBR', 4, 15, NULL, NULL, 'SADLPRDT', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002751, 10001717, NULL, '3D_SECURE_OTP', 'DTTPNMBR', NULL, 10, 'ENTTAGRP', NULL, NULL, 1)
/
update prd_attribute set parent_id = 10002751 where id in (10002303)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002752, 10001717, 10002751, '3D_SECURE_LIMIT_TO_SEND_PASSW', 'DTTPNMBR', NULL, 20, 'ENTTLIMT', 'LMTP0138', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002754, 10001717, 10002751, '3D_SECURE_PASSW_PIN_LIMIT_DAY', 'DTTPNMBR', NULL, 30, 'ENTTLIMT', 'LMTP0139', 'SADLSRVC', 1)
/
insert into prd_attribute (id, service_type_id, parent_id, attr_name, data_type, lov_id, display_order, entity_type, object_type, definition_level, is_visible) values (10002755, 10001717, 10002751, '3D_SECURE_PASSW_PIN_LIMIT_AUTH', 'DTTPNMBR', NULL, 35, 'ENTTLIMT', 'LMTP0140', 'SADLSRVC', 1)
/
