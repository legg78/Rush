insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10002225, 'MCW', 'MASTERCARD', 'PLVLSYST', null, null, null, null)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10002226, 'MCW', 'LOCAL_CLEARING_CENTRE', 'PLVLSYST', 'NO', 'DTTPCHAR', 405, 10002225)
/
delete set_parameter where id = 10002725
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10002725, 'MCW', 'RATE_VALIDITY_PERIOD', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', NULL, 10002225)
/
delete set_parameter where id = 10002842
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10002842, 'MCW', 'MC_NETWORK_ID', 'PLVLSYST', '000000000000001002.0000', 'DTTPNMBR', NULL, 10002225)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (10004498, 'MCW', 'RECONCILIATION_MANDATORY_AMOUNT', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', 4, 10002225)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004582, 'MCW', 'MASTERCOM', 'PLVLSYST', NULL, NULL, NULL, 10002225, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004583, 'MCW', 'MASTERCOM_PRODUCTION_MODE', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10004582, 10, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004584, 'MCW', 'MASTERCOM_CONSUMER_KEY', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004582, 20, 1)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004585, 'MCW', 'MASTERCOM_KEY_ALIAS', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004582, 30, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004586, 'MCW', 'MASTERCOM_KEY_PASSWORD', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004582, 40, 1)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004587, 'MCW', 'MASTERCOM_PRIVATE_KEY_PATH', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10004582, 50, NULL)
/
