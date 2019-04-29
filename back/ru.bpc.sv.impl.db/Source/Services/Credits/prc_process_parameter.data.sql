insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format) values (10000086, 10000263, 10000372, NULL, 10, 1)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000642, 10000866, 10000372, '000000000000009999.0000', 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000643, 10000866, 10001350, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000644, 10000866, 10000857, NULL, 30, 1, NULL, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000645, 10000871, 10000372, NULL, 10, NULL, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000646, 10000872, 10000372, NULL, 10, NULL, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000647, 10000873, 10000372, NULL, 10, NULL, 1, NULL)
/
delete from prc_process_parameter where id in (10000659, 10000660, 10000661)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000659, 10000876, 10000372, '000000000000009999.0000', 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000660, 10000876, 10002340, 'ACTP0130', 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000661, 10000876, 10002305, '000000000000000000.0000', 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000668, 10000263, 10002341, NULL, 20, 1, 0, NULL)
/
update prc_process_parameter set is_format = 1 where id in (10000645, 10000646, 10000647)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000835, 10000890, 10000372, NULL, 10, 1, 1, NULL)
/
update prc_process_parameter set is_mandatory = 1 where id = 10000643
/
update prc_process_parameter set default_value = 'CYDT0001' where id = 10000668
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001412, 10000263, 10003521, '000000000000000000.0000', 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001426, 10000263, 10003698, NULL, 40, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001434, 10001074, 10000372, '000000000000009999.0000', 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001435, 10001074, 10000431, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001436, 10001074, 10003735, NULL, 30, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001437, 10001074, 10003736, NULL, 40, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001438, 10001074, 10003737, NULL, 50, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001439, 10001074, 10001297, NULL, 60, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001440, 10001074, 10001298, NULL, 70, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001460, 10001081, 10000372, NULL, 10, 1, 0, NULL)
/
update prc_process_parameter set is_mandatory = 0 where id = 10001439
/
update prc_process_parameter set is_mandatory = 0 where id = 10001440
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001716, 10001144, 10001384, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001717, 10001144, 10001297, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001718, 10001144, 10001298, NULL, 30, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001719, 10001145, 10001384, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001720, 10001145, 10001297, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001721, 10001145, 10001298, NULL, 30, 1, 1, NULL)
/
update prc_process_parameter set process_id = 10001149 where id = 10001719
/
update prc_process_parameter set process_id = 10001149 where id = 10001720
/
update prc_process_parameter set process_id = 10001149 where id = 10001721
/
