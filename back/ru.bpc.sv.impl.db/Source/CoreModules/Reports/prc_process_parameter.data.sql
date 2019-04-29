insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000677, 10000884, 10002381, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000678, 10000884, 10002382, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000679, 10000884, 10002202, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001023, 10000954, 10003028, '000000000000000001.0000', 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001470, 10000884, 10002785, '000000000000000000.0000', 40, 1, 0, NULL)
/
delete from prc_process_parameter where id = 10001470
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001496, 10000884, 10003939, NULL, 25, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001505, 10000884, 10004024, '000000000000000000.0000', 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001523, 10001103, 10002381, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001524, 10001103, 10002382, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001525, 10001103, 10002202, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001526, 10001103, 10003939, NULL, 25, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001527, 10001103, 10004024, '000000000000000000.0000', 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001528, 10000884, 10004095, '000000000000000000.0000', 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001535, 10000884, 10002998, NULL, 60, 1, 0, NULL)
/
update prc_process_parameter set is_mandatory = 1 where id = 10001496
/
update prc_process_parameter set is_mandatory = 1 where id = 10001526
/
