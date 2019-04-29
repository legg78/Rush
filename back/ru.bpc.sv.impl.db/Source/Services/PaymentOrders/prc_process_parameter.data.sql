insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000489, 10000835, 10000372, NULL, 10, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000490, 10000835, 10000967, NULL, 20, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000491, 10000835, 10000968, NULL, 30, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000513, 10000010, 10001309, '000000000000000005.0000', 20, 1, 0)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000514, 10000010, 10001308, 'POSAAWPR', 10, 1, 0)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000605, 10000846, 10001308, 'POSA0001', 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000850, 10000835, 10002791, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001213, 10000835, 10002720, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001425, 10000846, 10003685, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001502, 10000835, 10004027, 'PSCM0001', 60, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001504, 10001093, 10002720, '000000000000000000.0000', 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001506, 10001096, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001545, 10000835, 10003636, NULL, 70, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001726, 10000846, 10000967, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001737, 10001157, 10000372, NULL, 10, 1, 1, NULL)
/
update prc_process_parameter set is_mandatory = 1 where id = 10001504
/
update prc_process_parameter set display_order = 20, is_mandatory = 0 where id = 10001504
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001745, 10001093, 10000372, NULL, 10, 1, 1, NULL)
/
