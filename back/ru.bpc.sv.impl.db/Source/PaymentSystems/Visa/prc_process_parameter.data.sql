insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000496, 10000842, 10001146, '000000000000001003.0000', 10, 1, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000497, 10000842, 10001147, NULL, 20, 1, 0)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000498, 10000841, 10001146, '000000000000001003.0000', 10, 1, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000499, 10000841, 10000372, NULL, 20, 1, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory) values (10000500, 10000841, 10001147, NULL, 30, 1, 0)
/
update prc_process_parameter set is_mandatory = 0 where id in (10000498, 10000499)
/
update prc_process_parameter set display_order = 100 where id = 10000500
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000516, 10000841, 10001349, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000534, 10000017, 10001146, NULL, 10, 1, 1, NULL)
/

insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000558, 10000852, 10001791, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000559, 10000852, 10001792, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000560, 10000852, 10001793, NULL, 30, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000561, 10000852, 10001146, NULL, 40, 1, 1, NULL)
/
update prc_process_parameter set is_mandatory = 0 where id = 10000534
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000588, 10000017, 10000372, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000589, 10000017, 10001383, NULL, 30, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000590, 10000017, 10001384, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000591, 10000842, 10002039, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000801, 10000842, 10002720, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000834, 10000852, 10002777, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000856, 10000841, 10001297, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000857, 10000841, 10001298, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000890, 10000842, 10001349, NULL, 60, 1, 0, NULL)
/

insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000964, 10000934, 10001146, '000000000000001003.0000', 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000965, 10000934, 10001349, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000966, 10000842, 10002865, '000000000000000000.0000', 70, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001022, 10000842, 10001376, NULL, 80, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001024, 10000841, 10003029, '000000000000000000.0000', 60, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001083, 10000852, 10000372, NULL, 60, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001160, 10000841, 10001376, NULL, 70, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001215, 10000852, 10001349, NULL, 70, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001285, 10000842, 10003163, '000000000000000000.0000', 90, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001311, 10001033, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001403, 10001060, 10001297, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001404, 10001060, 10001298, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001462, 10000842, 10003793, '000000000000000000.0000', 100, 1, 0, null)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001475, 10000841, 10003163, '000000000000000000.0000', 110, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001486, 10001090, 10003685, '000000000000000000.0000', 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001487, 10001090, 10000372, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001488, 10001090, 10001146, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001715, 10001033, 10002820, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001724, 10001153, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001725, 10001153, 10002305, NULL, 20, 1, 0, NULL)
/
