insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000518, 10000011, 10001146, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000519, 10000011, 10001376, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000520, 10000012, 10001146, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000521, 10000012, 10000372, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000522, 10000013, 10001146, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000523, 10000013, 10001376, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000524, 10000013, 10001380, 'IP00FULL', 30, 1, 0, NULL)
/
update prc_process_parameter set display_order = 50 where id = 10000523
/
update prc_process_parameter set display_order = 60 where id = 10000524
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000525, 10000013, 10000372, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000526, 10000013, 10001383, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000527, 10000013, 10001384, NULL, 40, 1, 0, NULL)
/
update prc_process_parameter set is_mandatory = 0 where id = 10000522
/
update prc_process_parameter set is_mandatory = 1 where id = 10000526
/
update prc_process_parameter set default_value = 'AL32UTF8' where id = 10000523
/
delete from prc_process_parameter where id = 10000523
/
update prc_process_parameter set display_order = 50 where id = 10000524
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000528, 10000014, 10001146, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000529, 10000015, 10001146, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000530, 10000015, 10000372, NULL, 20, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000531, 10000013, 10001462, NULL, 60, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000535, 10000011, 10001708, NULL, 30, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000536, 10000851, 10001712, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000537, 10000851, 10001713, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000538, 10000851, 10001714, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000539, 10000851, 10001146, NULL, 40, 1, 0, NULL)
/

delete from prc_process_parameter where id in (10000539, 10000536, 10000537, 10000538)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000554, 10000851, 10001791, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000555, 10000851, 10001792, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000556, 10000851, 10001793, NULL, 30, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000557, 10000851, 10001146, NULL, 40, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000562, 10000012, 10001376, NULL, 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000666, 10000012, 10002347, NULL, 40, 1, 0, NULL)
/
update prc_process_parameter set default_value = '000000000000001002.0000' where id = 10000518
/
update prc_process_parameter set default_value = '000000000000001002.0000' where id = 10000520
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000802, 10000011, 10002720, NULL, 50, 1, 0, NULL)
/

insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000803, 10000885, 10000372, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000804, 10000885, 10001146, NULL, 10, 1, 0, NULL)
/


insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000831, 10000851, 10002770, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000832, 10000889, 10001297, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000833, 10000889, 10001298, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000854, 10000012, 10001297, NULL, 50, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000855, 10000012, 10001298, NULL, 60, 1, 0, NULL)
/

insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000967, 10000011, 10002865, '000000000000000000.0000', 60, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10000995, 10000012, 10001708, NULL, 70, 1, 1, NULL)
/

update prc_process_parameter set is_mandatory = 1, default_value = 'AL32UTF8' where id = 10000519
/
update prc_process_parameter set is_mandatory = 1, default_value = '000000000000000001.0000' where id = 10000802
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001003, 10000013, 10001708, 'RCFM1014', 70, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001015, 10000953, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001016, 10000953, 10001147, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001025, 10000012, 10003029, '000000000000000000.0000', 80, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001082, 10000851, 10000372, NULL, 60, 1, 0, NULL)
/
update prc_process_parameter set is_mandatory = 1 where id = 10000555
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001217, 10000859, 10000372, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001284, 10000011, 10003163, '000000000000000000.0000', 70, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001306, 10001029, 10002305, '000000000000000000.0000', 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001307, 10001029, 10000372, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001308, 10001032, 10000372, NULL, 10, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001312, 10000889, 10002391, '000000000000000000.0000', 30, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001461, 10000851, 10003777, NULL, 45, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001474, 10000012, 10003163, '000000000000000000.0000', 90, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001620, 10000011, 10003793, '000000000000000000.0000', 80, 1, 0, NULL)
/
update prc_process_parameter set is_mandatory = 1 where id = 10000521
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001681, 10000011, 10004392, '000000000000000000.0000', 90, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001686, 10001138, 10000372, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001687, 10001138, 10002202, NULL, 20, 1, 0, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001723, 10001151, 10000372, '000000000000009999.0000', 10, 1, 1, NULL)
/
update prc_process_parameter set param_id = 10004518, lov_id = 45 where id = 10000666
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001739, 10001158, 10001146, NULL, 10, 1, 1, NULL)
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001740, 10001158, 10002720, NULL, 20, 1, 0, NULL)
/
update prc_process_parameter set display_order = 20 where id = 10001739
/
update prc_process_parameter set display_order = 30 where id = 10001740
/
insert into prc_process_parameter (id, process_id, param_id, default_value, display_order, is_format, is_mandatory, lov_id) values (10001746, 10001158, 10000372, NULL, 10, 1, 1, NULL)
/
