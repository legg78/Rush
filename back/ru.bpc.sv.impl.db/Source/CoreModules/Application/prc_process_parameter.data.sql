insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000492, 10000836, 10000372, NULL, 10, 1, 0)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000493, 10000836, 10001053, NULL, 20, 1, 0)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000494, 10000836, 10001054, NULL, 30, 1, 0)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000669, 10000879, 10000372, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000670, 10000879, 10001053, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000671, 10000879, 10002355, '000000000000000100.0000', 30, 1, 0, NULL)
/
update prc_process_parameter set default_value = '000000000000000000.0000' where id = 10000671
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000993, 10000045, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001073, 10000045, 10002863, '000000000000000001.0000', 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001173, 10000045, 10002355, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001507, 10000836, 10004059, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001508, 10000879, 10004059, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001727, 10000879, 10004497, '000000000000000001.0000', 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001728, 10000836, 10004497, '000000000000000001.0000', 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001747, 10001162, 10000372, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001748, 10001162, 10001053, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001749, 10001162, 10001054, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001750, 10001162, 10004497, '000000000000000001.0000', 40, 1, 0, NULL)
/
update prc_process_parameter set param_id = 10004590 where id = 10001507
/
