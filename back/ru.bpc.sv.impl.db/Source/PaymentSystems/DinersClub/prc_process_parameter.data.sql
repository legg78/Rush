insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001101, 10000971, 10001146, '000000000000001012.0000', 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001102, 10000971, 10000372, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001103, 10000971, 10001297, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001104, 10000971, 10001298, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001132, 10000985, 10001146, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001133, 10000985, 10000372, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001134, 10000985, 10001383, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001135, 10000985, 10001384, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001136, 10000985, 10002311, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001137, 10000985, 10002882, NULL, 60, 1, 0, NULL)
/
update prc_process_parameter set is_mandatory = 1 where id in (10001132, 10001133, 10001134, 10001135, 10001136)
/
delete from prc_process_parameter where id = 10001136
/
update prc_process_parameter set display_order = 50 where id = 10001137
/
delete from prc_process_parameter where id = 10001137
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001151, 10000989, 10001146, '000000000000001012.0000', 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001152, 10000989, 10002720, '000000000000000001.0000', 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001636, 10000971, 10003029, '000000000000000000.0000', 50, 1, 0, NULL)
/
