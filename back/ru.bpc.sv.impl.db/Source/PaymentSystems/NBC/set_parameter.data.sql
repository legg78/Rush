insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003448, 'NBC', 'NBC', 'PLVLSYST', NULL, NULL, NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003449, 'NBC', 'NBC_FAST_WS_URL', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10003448, 10, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003450, 'NBC', 'NBC_FAST_USERNAME', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10003448, 20, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003451, 'NBC', 'NBC_FAST_PASSWORD', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 10003448, 30, 1)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003452, 'NBC', 'NBC_FAST_PARTICIPANT_CODE', 'PLVLSYST', 'DTTPCHAR', NULL, NULL, 10003448, 40, NULL)
/
update set_parameter set data_type = 'DTTPCHAR', default_value = null where id = 10003452
/
