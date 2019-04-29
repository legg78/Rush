insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001608, 10001117, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001609, 10001117, 10001146, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001610, 10001117, 10004220, NULL, 30, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001612, 10001118, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001613, 10001118, 10001146, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001614, 10001118, 10004220, NULL, 30, 1, 1, NULL)
/
delete from prc_process_parameter where id = 10001610
/
delete from prc_process_parameter where id = 10001614
/
update prc_process_parameter set display_order = 10 where id = 10001609
/
update prc_process_parameter set display_order = 20, param_id = 10004518, lov_id = 733 where id = 10001608
/
update prc_process_parameter set display_order = 10 where id = 10001613
/
update prc_process_parameter set display_order = 20 where id = 10001612
/
