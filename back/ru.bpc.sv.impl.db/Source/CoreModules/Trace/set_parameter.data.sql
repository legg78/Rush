insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1000, 'TRC', 'TRACE_LEVEL', 'PLVLUSER', '000000000000000005.0000', 'DTTPNMBR', 3, 1008)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1001, 'TRC', 'TRACE_DBMS_OUTPUT', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1008)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1002, 'TRC', 'TRACE_TABLE', 'PLVLSYST', '000000000000000001.0000', 'DTTPNMBR', 4, 1008)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1003, 'TRC', 'TRACE_SESSION', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1008)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1008, 'TRC', 'TRACE', 'PLVLUSER', NULL, NULL, NULL, NULL)
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id) values (1036, 'TRC', 'LOG_MODE', 'PLVLUSER', 'LGMDSSPD', 'DTTPCHAR', 1030, 1008)
/
update set_parameter set display_order = 10 where id = 1000
/
update set_parameter set display_order = 20 where id = 1036
/
update set_parameter set display_order = 30 where id = 1002
/
update set_parameter set display_order = 40 where id = 1003
/
update set_parameter set display_order = 50 where id = 1001
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order) values (10002829, 'TRC', 'TRACE_FILE', 'PLVLSYST', '000000000000000000.0000', 'DTTPNMBR', 4, 1008, 60)
/
delete from set_parameter where id = 10002829
/
insert into set_parameter (id, module_code, name, lowest_level, default_value, data_type, lov_id, parent_id, display_order, is_encrypted) values (10003979, 'TRC', 'LOG_CONFIG_FILE', 'PLVLSYST', NULL, 'DTTPCHAR', NULL, 1008, 60, NULL)
/
