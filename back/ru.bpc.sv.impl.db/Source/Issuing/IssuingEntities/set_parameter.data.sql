insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002756, 'ISS', 'ENABLE_TOKENIZATION', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1019, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002779, 'ISS', 'TOKENIZATION', 'PLVLSYST', NULL, NULL, NULL, 1031, 10)
/
update set_parameter set parent_id = 10002779, display_order = 10 where id = 10002756
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002780, 'ISS', 'TOKENIZATOR_HOST', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10002779, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002781, 'ISS', 'TOKENIZATOR_PORT', 'PLVLSYST', NULL, 'DTTPNMBR', NULL, 10002779, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002861, 'ISS', 'MESSAGE_BUS_IS_CAPABLE_OF_TOKEN', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 10002779, 50)
/
delete from set_parameter where id = 10002861
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10003095, 'ISS', 'UID_NAME_FORMAT', 'PLVLINST', null, 'DTTPNMBR', 279, 1032, 30)
/
update set_parameter set default_value = '000000000000001305.0000' where id = 10003095
/
