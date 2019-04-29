insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1338, 10000027, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPCRDS')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type) values (1340, 10000029, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPCRDS')
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1376, 10000877, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPCBLL', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1377, 10000878, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPCSEC', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1382, 10000874, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPCRDN', NULL)
/
update prc_file set saver_id=1012 where id=1382
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1404, 10000029, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPCRDR', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1416, 10000952, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPRCRD', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1487, 10001041, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPCRDS', 1047)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1488, 10001042, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPCRDS', 1049)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1526, 10001106, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRCRD', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1527, 10001106, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPCRDN', 1012)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1541, 10001130, 'FLPSINCM', NULL, 'FLNT0010', NULL, 'FLTPRPRS', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1542, 10001131, 'FLPSINCM', NULL, NULL, NULL, 'FLTPRPRS', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1543, 10001131, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPPINF', NULL)
/
insert into prc_file (id, process_id, file_purpose, saver_class, file_nature, xsd_source, file_type, saver_id) values (1544, 10001132, 'FLPSOUTG', NULL, 'FLNT0010', NULL, 'FLTPCPIF', NULL)
/
update prc_file set saver_id = 1058 where id = 1543
/
update prc_file set saver_id = 1059 where id = 1544
/
