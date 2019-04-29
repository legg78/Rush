insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003097, 'APP', 'APPLICATIONS', 'PLVLSYST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003120, 'APP', 'MASKING_CARD_IN_RESPONSE_ON_APPLICATION', 'PLVLINST', '000000000000000000.0000', 'DTTPNMBR', 4, 1032, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003222, 'APP', 'ALLOW_CUSTOMER_PERSON_DUPLICATE', 'PLVLINST', '000000000000000001.0000', 'DTTPNMBR', 4, 10003097, 50)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003299, 'APP', 'ENABLE_CBS_SYNC', 'PLVLINST', '000000000000000000.0000', 'DTTPNMBR', 4, 10003097, 60)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003300, 'APP', 'CBS_SVAPINT_WS_URL', 'PLVLINST', NULL, 'DTTPCHAR', NULL, 10003097, 70)
/
update set_parameter set lowest_level = 'PLVLSYST' where id = 10003299
/
update set_parameter set lowest_level = 'PLVLSYST' where id = 10003300
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003465, 'APP', 'ENABLE_EWALLET_SYNC', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10003097, 80)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003466, 'APP', 'EWALLET_SVAPINT_WS_URL', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10003097, 90)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003791, 'APP', 'DISPUTE_CASE_AUTO_HIDE_GAP', 'PLVLSYST', '000000000000000030.0000', 'DTTPNMBR', NULL, 10003097, 100, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004358, 'APP', 'ENABLE_LINKAGE_REPORTING', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10003097, 73, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10004359, 'APP', 'ENABLE_MULTI_CBS_SYNC', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10003097, 75, NULL)
/
