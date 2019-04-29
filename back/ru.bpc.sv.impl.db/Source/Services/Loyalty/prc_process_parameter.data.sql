insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000424, 10000745, 10000372, NULL, 10, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000426, 10000745, 10000431, NULL, 30, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000425, 10000745, 10000830, NULL, 20, 1)
/

insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000464, 10000785, 10000372, NULL, 10, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000465, 10000785, 10000830, NULL, 20, 1)
/
update prc_process_parameter set is_mandatory = 1 where id = 10000464
/
update prc_process_parameter set is_mandatory = 1 where id = 10000465
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000887, 10000785, 10002305, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000888, 10000785, 10001297, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000889, 10000785, 10001298, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001313, 10001034, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001662, 10001134, 10000372, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001663, 10001134, 10002202, NULL, 20, 1, 0, NULL)
/
