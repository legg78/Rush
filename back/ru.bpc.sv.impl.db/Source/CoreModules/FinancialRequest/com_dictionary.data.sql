insert into com_dictionary (id, dict, code, is_numeric, is_editable, inst_id, module_code) values (10007061, 'APTP', 'FREQ', 0, 1, 9999, 'FRQ')
/
insert into com_dictionary (id, dict, code, is_numeric, is_editable, inst_id, module_code) values (10008358, 'EVNT', '2400', 1, 1, 9999, 'FRQ')
/
insert into com_dictionary (id, dict, code, is_numeric, is_editable, inst_id, module_code) values (10008359, 'EVNT', '2401', 1, 1, 9999, 'FRQ')
/
insert into com_dictionary (id, dict, code, is_numeric, is_editable, inst_id, module_code) values (10008360, 'EVNT', '2402', 1, 1, 9999, 'FRQ')
/
update com_dictionary set module_code = 'ORQ' where id = 10007061
/
update com_dictionary set module_code = 'ORQ' where id = 10008358
/
update com_dictionary set module_code = 'ORQ' where id = 10008359
/
update com_dictionary set module_code = 'ORQ' where id = 10008360
/
