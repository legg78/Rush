insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1013, 'PRC', 'INPUT_OUTPUT', 'PLVLINST', NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1014, 'PRC', 'FILE_PARALLEL_DEGREE', 'PLVLINST', '000000000000000001.0000', 'DTTPNMBR', NULL, 1013, 10)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1015, 'PRC', 'INPUT_OUTPUT_HOME', 'PLVLINST', NULL, 'DTTPCHAR', NULL, 1013, 20)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1021, 'PRC', 'DATA_TRANSFER_PROTOCOL', 'PLVLINST', 'DTPLSFTP', 'DTTPCHAR', 109, 1013, 30)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1022, 'PRC', 'DATA_TRANSFER_HOSTNAME', 'PLVLINST', NULL, 'DTTPCHAR', NULL, 1013, 40)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1023, 'PRC', 'DATA_TRANSFER_PORT', 'PLVLINST', NULL, 'DTTPNMBR', NULL, 1013, 50)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1025, 'PRC', 'DATA_TRANSFER_USERNAME', 'PLVLINST', NULL, 'DTTPCHAR', NULL, 1013, 60)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1026, 'PRC', 'DATA_TRANSFER_PASSWORD', 'PLVLINST', NULL, 'DTTPCHAR', NULL, 1013, 70)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (1037, 'PRC', 'SVFE1_CONVERTER_CONFIG_FOLDER_PATH', 'PLVLSYST', null, 'DTTPCHAR', NULL, 1013, 80)
/
