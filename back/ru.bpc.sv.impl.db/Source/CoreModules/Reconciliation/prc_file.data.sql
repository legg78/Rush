insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1503, 10001061, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTP2100', 1050)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1504, 10001064, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTP2100', 1051)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1508, 10001069, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTP2200', 1053)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1528, 10001111, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTP2300', 1002)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1525, 10001110, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTP2300', 1057)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1548, 10001140, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTP2102', NULL)
/
update prc_file set file_type = 'FLTP2102' where id = 1508
/
update prc_file set file_type = 'FLTP2101' where id = 1528
/
update prc_file set file_type = 'FLTP2101' where id = 1525
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1549, 10001143, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTP2200', 1068)
/
