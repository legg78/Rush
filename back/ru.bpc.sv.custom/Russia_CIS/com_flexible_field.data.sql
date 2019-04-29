insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id) values (10001094, 'ENTTCOMP', NULL, 'PRESENCE_ON_LOCATION', 'DTTPCHAR', 'FM000000000000000000.0000', 4, 1, 9999)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id) values (10001095, 'ENTTCOMP', NULL, 'AUTHORIZED_CAPITAL', 'DTTPNMBR', 'FM000000000000000000.0000', NULL, 1, 9999)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id) values (10001101, 'ENTTCOMP', NULL, 'AUTHORIZED_CAPITAL_CURRENCY', 'DTTPCHAR', NULL, 25, 1, 9999)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id) values (10001117, 'ENTTINST', NULL, 'CORRESPONDENT_ACCOUNT', 'DTTPCHAR', NULL, NULL, 1, 9999)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id) values (10001312, 'ENTTINST', NULL, 'FLX_TAX_ID', 'DTTPCHAR', NULL, NULL, 1, 9999)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id) values (10001118, 'ENTTINST', NULL, 'FLX_BANK_ID_CODE', 'DTTPCHAR', NULL, NULL, 1, 9999)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10001177, 'ENTTACCT', NULL, 'STATEMENT_CREATION_PERIODICITY', 'DTTPCHAR', NULL, 296, 1, 1001, 'STCP0001')
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10001178, 'ENTTACCT', NULL, 'STATEMENT_CREATION_FORM', 'DTTPCHAR', NULL, 295, 1, 1001, 'STCFELEC')
/

insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10001352, 'ENTTINST', NULL, 'RUS_OKPO', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10001353, 'ENTTINST', NULL, 'RUS_OGRN', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10001354, 'ENTTINST', NULL, 'RUS_REG_NUM', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/

insert into com_flexible_field (id, entity_type, object_type, name, data_type, data_format, lov_id, is_user_defined, inst_id, default_value) values (10002015, 'ENTTNETW', NULL, 'NETWORK_NAME_CBRF250', 'DTTPCHAR', NULL, NULL, 1, 9999, NULL)
/
update com_flexible_field set data_type = 'DTTPNMBR' where id = 10001094
/
