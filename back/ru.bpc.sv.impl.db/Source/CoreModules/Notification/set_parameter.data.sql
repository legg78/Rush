insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001450, 'NTF', 'NOTIFICATIONS', 'PLVLINST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001451, 'NTF', 'PASSWORD_ALGORITHM_TYPE', 'PLVLINST', NULL, 'DTTPCHAR', 340, 10001450, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10001452, 'NTF', 'PASSWORD_LENGTH', 'PLVLINST', NULL, 'DTTPNMBR', NULL, 10001450, 20)
/
update set_parameter set default_value = 'PWTPNMBR' where id = 10001451
/
update set_parameter set default_value = '000000000000000008.0000' where id = 10001452
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003282, 'NTF', 'SUPPORT_NOTIFICATION_METHOD', 'PLVLINST', NULL, 'DTTPCHAR', 441, 10001450, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003283, 'NTF', 'SUPPORT_NOTIFICATION_ADDRESS', 'PLVLINST', NULL, 'DTTPCHAR', NULL, 10001450, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003284, 'NTF', 'ENABLE_PROCESS_NOTIFICATION', 'PLVLINST', '000000000000000000.0000', 'DTTPNMBR', 4, 10001450, 50)
/
